//
//  GameScene.swift
//  5bs
//
//  Created by luozhifan on 2017/7/24.
//  Copyright © 2017年 luozhifan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private let ballCols = [SKColor.red, SKColor.green, SKColor.blue, SKColor.orange,
                           SKColor.cyan, SKColor.yellow, SKColor.purple]
    private let ballsk = SKTexture(imageNamed: "l8")
    private let emitsk = SKTexture(imageNamed: "l9")
    private var nodeMap : [[Int]] = []
    private var nodeBalls : [[SKShapeNode?]] = []
    private var tipBalls : [SKShapeNode] = []
    //    private var highShapeNode : SKShapeNode?
    private let lineradius  : Int = 270
    private let gradcnt     : Int = 9
    var lastpos = (x:-1,y:-1)
    var ballCnt = 0
    var rndCol = [Int](repeating:0, count:3)
    var isMoving = false
    var score = 0
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3 )
        
                //self.spinnyNode = ball
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        drawGrids()
        
        ballCnt = 0
        for _ in 0...8
        {
            nodeMap.append( [Int](repeating:Int(ballCols.count), count:9) )
        }
        
        fillball()
        
        resetgame()
        
    }
    func drawGrids() {

        
        var points = [CGPoint(x: -lineradius, y: -lineradius),CGPoint(x: lineradius, y: -lineradius),
                      CGPoint(x: lineradius, y: lineradius),CGPoint(x: -lineradius, y: lineradius),
                      CGPoint(x: -lineradius, y: -lineradius)]
        for  yind in 0 ... gradcnt
        {
            let ypos = 2*lineradius*yind/gradcnt-lineradius
            points.append(CGPoint(x:-lineradius, y: ypos))
            points.append(CGPoint(x:lineradius, y: ypos))
            points.append(CGPoint(x:lineradius, y: ypos))
            points.append(CGPoint(x:-lineradius, y: ypos))
        }
        for  yind in 0 ... gradcnt
        {
            let ypos = 2*lineradius*yind/gradcnt-lineradius
            points.append(CGPoint(x: ypos, y:-lineradius))
            points.append(CGPoint(x: ypos, y:lineradius))
            points.append(CGPoint(x: ypos, y:lineradius))
            points.append(CGPoint(x: ypos, y:-lineradius))
            
        }
        let splineShapeNode = SKShapeNode(points: &points,
                                          count: points.count)
        splineShapeNode.strokeColor = .gray
        self.addChild(splineShapeNode)
        
        
        
//        
//        var boxpoints = [CGPoint(x: -lineradius/gradcnt, y: -lineradius/gradcnt),
//                         CGPoint(x: -lineradius/gradcnt, y: lineradius/gradcnt),
//                         CGPoint(x: lineradius/gradcnt, y: lineradius/gradcnt),
//                         CGPoint(x: lineradius/gradcnt, y: -lineradius/gradcnt),
//                         CGPoint(x: -lineradius/gradcnt, y: -lineradius/gradcnt)]
//        
//        highShapeNode = SKShapeNode(points: &boxpoints,
//                                    count: boxpoints.count)
//        
//        self.addChild(highShapeNode!)
        
    }
    
    func tipBall() {
        for i in 0 ... rndCol.count-1 {
            rndCol[i] = Int(arc4random())%(ballCols.count)
            tipBalls[i].fillColor = ballCols[rndCol[i]]
            //tipBalls[i].fillTexture = ballsk
        }
        
    }
    func p2s(pos x: Int) -> Int {
        return 2*lineradius*x/gradcnt-lineradius+lineradius/gradcnt
    }
    
    func s2p(pos x: Int) -> Int {
        if x < -lineradius || x > lineradius {
            return -1
        }
        return (x+lineradius)*gradcnt/(2*lineradius)
    }
    
    func fillball0() {
        for x in 0...8
        {
            nodeBalls.append( [SKShapeNode]() )
            
            for _ in 0...8
            {
                nodeBalls[x].append(SKShapeNode())
            }
        }
    }
    
    func fillball() {
        
        for x in 0...8
        {
            nodeBalls.append( [SKShapeNode]() )
            
            for y in 0...8
            {
                    nodeBalls[x].append(nil)
            }
        }
        
        for x in 0...2
        {
            let path = CGMutablePath()
            path.addArc(center: CGPoint.zero,
                        radius: 15,
                        startAngle: 0,
                        endAngle: CGFloat.pi * 2,
                        clockwise: true)
            let ball = SKShapeNode(path: path)
            ball.lineWidth = 0
            //ball.fillColor = CGColor(deviceWhite: 1, alpha: 0)
            ball.strokeColor = .white
            ball.fillTexture = ballsk
            ball.glowWidth = 0.5
            let xpos = -lineradius+35*x+15
            let ypos = lineradius+50
            ball.position = CGPoint(x:xpos, y:ypos)
            
            tipBalls.append(ball)
            self.addChild(ball)
        }
        label?.position = CGPoint(x:-lineradius, y:lineradius+90)
    }
    func testPos( markmap:inout [Int],  nextpos:inout [(Int, Int)], x:Int, y:Int ) {
        if x < gradcnt && x >= 0 && y < gradcnt && y >= 0 && markmap[x+gradcnt*y] == 0 {
            markmap[x+gradcnt*y] = 1
            if( nodeMap[x][y] >= ballCols.count ) {
                nextpos.append((x, y))
            }
        }
    }
    func moveBall(fromX fx : Int, fromY fy : Int, toX tx : Int, toY ty : Int) -> Bool {
        var steppath = [Int:[(Int, Int)]]()
        var step = Int(0)
        let movecol = nodeMap[fx][fy]
        
        steppath[step] = [(tx, ty)]
        
        var finded = 0
        var markmap = [Int](repeating:0, count:gradcnt*gradcnt)
        
        //print("begin move", nodeMap[fx][fy], nodeMap[tx][ty], movecol)
        isMoving = true
        while true {
            var nextpos = [(Int, Int)]()
            
            for v in steppath[step]!
            {
                if (fx-v.0)*(fx-v.0)+(fy-v.1)*(fy-v.1) == 1 {
                    finded = 1
                    break
                }
                testPos(markmap: &markmap, nextpos: &nextpos, x:v.0+1, y:v.1)
                testPos(markmap: &markmap, nextpos: &nextpos, x:v.0-1, y:v.1)
                testPos(markmap: &markmap, nextpos: &nextpos, x:v.0,   y:v.1+1)
                testPos(markmap: &markmap, nextpos: &nextpos, x:v.0,   y:v.1-1)

            }
            if finded == 1 {
                break
            }

            step+=1
            steppath[step] = nextpos
            if nextpos.count == 0  {
                break
            }
        }
        if finded == 1 {
            
            let moveball = nodeBalls[fx][fy]
            //let moveball = nodeBalls[fx][fy]?.copy() as! SKShapeNode?
            moveball?.removeAllActions()
            var sq = [SKAction]()
            var frmx = fx
            var frmy = fy
            sq.append(SKAction.fadeIn(withDuration: 0.01))
            //print("".appendingFormat("fx %d fy %d tx %d ty %d", fx, fy, tx, ty))
            for s in 0 ... step {
                for v in steppath[step-s]! {
                    if (frmx-v.0)*(frmx-v.0)+(frmy-v.1)*(frmy-v.1) == 1 {
                        sq.append(SKAction.move(to: CGPoint(x: p2s(pos: v.0), y: p2s(pos: v.1)), duration: 0.05))
                        frmx = v.0
                        frmy = v.1
                        //print(" ... ".appendingFormat(" %d  %d", frmx, frmy))
                        break
                  }
                }
            }
            sq.append(SKAction.removeFromParent())
            //self.label?.text  =  "gogogo...".appendingFormat("%d %d step:%d %d", tx, ty, sq.count, movecol)
            
            moveball?.run(SKAction.sequence(sq), completion: {
                self.addBall(xpos: tx, ypos: ty, colorInd: movecol, showAnim: false)
                self.emitBalls(bxpos: [fx], bypos: [fy])
                if self.judgeLines(toX: tx, toY: ty) == 0 {
                    self.rndFill(cols: self.rndCol)
                    self.tipBall()
                }

                self.isMoving = false
            })

            lastpos.x = -1
            lastpos.y = -1
            return true
        }
        else {
            //let moveball = nodeBalls[fx][fy]
            let moveball = nodeBalls[fx][fy]?.copy() as! SKShapeNode?
            moveball?.removeAllActions()
            var sq = [SKAction]()
            sq.append(SKAction.move(to: CGPoint(x: p2s(pos: fx)+15, y: p2s(pos: fy)), duration: 0.1))
            sq.append(SKAction.move(to: CGPoint(x: p2s(pos: fx)-15, y: p2s(pos: fy)), duration: 0.1))
            sq.append(SKAction.move(to: CGPoint(x: p2s(pos: fx)+15, y: p2s(pos: fy)), duration: 0.1))
            sq.append(SKAction.move(to: CGPoint(x: p2s(pos: fx)-15, y: p2s(pos: fy)), duration: 0.1))
            
            sq.append(SKAction.removeFromParent())
            moveball?.run(SKAction.sequence(sq), completion: {
                //self.addChild(self.nodeBalls[fx][fy]!)
            })
            //self.removeChildren(in: [nodeBalls[fx][fy]!])
            self.addChild(moveball!)
            isMoving = false
        }
        return false
    }
    func judgeLines( toX tx : Int, toY ty : Int) -> Int {
        var markpos = [(Int, Int)]()
        for x0 in tx-4 ... tx {
            var cnt = 0
            if x0 < 0 || x0 >= gradcnt { continue }
            let col = nodeMap[x0][ty]
            if col >= ballCols.count { continue }
            for x in x0 ... x0+9 {
                if x >= 0 && x < gradcnt && nodeMap[x][ty] == col {
                    cnt+=1
                }
                else {
                    break
                }
            }
            if cnt >= 5 {
                for x in x0 ... x0+cnt-1 {
                    if x == tx {continue}
                    markpos.append((x, ty))
                }
                break
            }
        }
        for y0 in ty-4 ... ty {
            var cnt = 0
            if y0 < 0 || y0 >= gradcnt { continue }
            let col = nodeMap[tx][y0]
            if col >= ballCols.count { continue }
            for y in y0 ... y0+9 {
                if y >= 0 && y < gradcnt && nodeMap[tx][y] == col {
                    cnt+=1
                }
                else {
                    break
                }
            }
            if cnt >= 5 {
                for y in y0 ... y0+cnt-1 {
                    if ty == y {continue}
                    markpos.append((tx, y))
                }
                break
            }
        }
        for d in -4 ... 0 {
            var cnt = 0
            if tx+d < 0 || tx+d >= gradcnt { continue }
            if ty+d < 0 || ty+d >= gradcnt { continue }
            let col = nodeMap[tx+d][ty+d]
            if col >= ballCols.count { continue }
            for d0 in d ... d+9 {
                if tx+d0 >= 0 && tx+d0 < gradcnt && ty+d0 >= 0 && ty+d0 < gradcnt
                    && nodeMap[tx+d0][ty+d0] == col
                {
                    cnt+=1
                }
                else {
                    break
                }
            }
            if cnt >= 5 {
                for d0 in d ... d+cnt-1 {
                    if d0 == 0 {continue}
                    markpos.append((tx+d0, ty+d0))
                }
                break
            }
        }
        for d in -4 ... 0 {
            var cnt = 0
            if tx+d < 0 || tx+d >= gradcnt { continue }
            if ty-d < 0 || ty-d >= gradcnt { continue }
            let col = nodeMap[tx+d][ty-d]
            if col >= ballCols.count { continue }
            for d0 in d ... d+9 {
                if tx+d0 >= 0 && tx+d0 < gradcnt && ty-d0 >= 0 && ty-d0 < gradcnt
                    && nodeMap[tx+d0][ty-d0] == col
                {
                    cnt+=1
                }
                else {
                    break
                }
            }
            if cnt >= 5 {
                for d0 in d ... d+cnt-1 {
                    if d0 == 0 {continue}
                    markpos.append((tx+d0, ty-d0))
                }
                break
            }
        }
        if markpos.count>0 {
            markpos.append((tx, ty))
        }
        if markpos.count >= 5 {
            var emitx = [Int]()
            var emity = [Int]()
        
            for v in markpos {
                emitx.append(v.0)
                emity.append(v.1)
            }
            emitBalls(bxpos: emitx, bypos: emity)
            score += 10*(markpos.count-4)
            let record = UserDefaults().integer(forKey:"record")
            self.label?.text = "得分: \(score)       最高分: \(record)"
        }
        return markpos.count
    }
    func  resetgame() {
        score = 0
        for i in 0 ... 8 {
            for j in 0 ... 8 {
                if nodeMap[i][j] < ballCols.count {
                    emitBalls(bxpos: [i], bypos: [j])
                }
            }
        }
        
        //tipBall()
        _ = rndFill(cols: [Int(arc4random())%(ballCols.count), Int(arc4random())%(ballCols.count), Int(arc4random())%(ballCols.count), Int(arc4random())%(ballCols.count), Int(arc4random())%(ballCols.count)])
        tipBall()
    }
    
    func rndFill( cols rndCol: [Int] ) -> Bool {
        var fillposes = [(Int, Int)]()
        for i in 1 ... rndCol.count {
            if 81 <= ballCnt { break }
            let fillpos = Int(arc4random())%(81-ballCnt)
            var basex = 0
            var basey = 0
            while(nodeMap[basex][basey] < ballCols.count) {
                basex+=1
                if basex>=gradcnt {
                    basey+=1
                    basex=0
                }
            }
            if fillpos > 0 {
                for _ in 1 ... fillpos
                {
                    repeat {
                        basex+=1
                        if basex>=gradcnt {
                            basey+=1
                            basex=0
                        }
                        if basey>=gradcnt {
                            basey=0
                        }
                    } while(nodeMap[basex][basey] < ballCols.count)
                }
            }
            fillposes.append((x:basex, y:basey))
            addBall(xpos: basex, ypos: basey, colorInd: rndCol[i-1], showAnim: true)
        }
        for v in fillposes {
            judgeLines(toX: v.0, toY: v.1)
        }
        
        if ballCnt >= gradcnt*gradcnt {
            var record = UserDefaults().integer(forKey:"record")
            if record < score {
                UserDefaults().set(score, forKey:"record")
            }
            if score >= 1000 || record < score{
                record = score
                self.isMoving = true
                let fire = SKEmitterNode(fileNamed:"MyParticle")
                self.addChild(fire!)
                fire?.setScale(0.1)
                fire?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 2),
                                         SKAction.wait(forDuration: 3),
                                         SKAction.fadeOut(withDuration: 2),
                                         SKAction.removeFromParent()]), completion: {
                                            self.label?.text = "上盘: \(self.score)      最高分: \(record)"
                                            self.resetgame()
                                            self.isMoving = false
                })
            }
            else {
                self.label?.text = "上盘: \(self.score)      最高分: \(record)"
                self.resetgame()
            }
            return false
        }
        return true;
    }
    
    func emitBalls( bxpos xs:[Int], bypos ys:[Int]) {
        if xs.count == 0 { return }
        for ind in 0 ... xs.count-1 {
            let x = xs[ind]
            let y = ys[ind]
            nodeBalls[x][y]?.fillTexture = emitsk
            nodeBalls[x][y]?.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
            nodeBalls[x][y] = nil
            nodeMap[x][y] = ballCols.count
            ballCnt-=1
        }

    }
    
    func addBall(xpos x: Int, ypos y: Int, colorInd col: Int, showAnim show: Bool) {
        if col >= ballCols.count {
            return
        }
        if nodeMap[x][y] < ballCols.count {
            return
        }
        
        nodeMap[x][y] = col
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: 15,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        let ball = SKShapeNode(path: path)
        ball.lineWidth = 0
        ball.strokeColor = .white
        ball.fillColor = ballCols[nodeMap[x][y]]
        //ball.fillColor = .white
        ball.fillTexture = ballsk
        //ball.strokeColor = NSColor(deviceWhite: 1, alpha: 0)
        ball.glowWidth = 0.5
        let xpos = p2s(pos: x)
        let ypos = p2s(pos: y)
        ball.position = CGPoint(x:xpos, y:ypos)
        
        nodeBalls[x][y] = ball
        ballCnt+=1
        if show {
            ball.xScale = 0
            ball.yScale = 0
            ball.run(SKAction.sequence([SKAction.wait(forDuration: 0.2),
                                        SKAction.scale(to: 1, duration: 0.3)]))
        }
        
        self.addChild(ball)
        
    }
    
    func randomColor() -> UIColor
    {
        let r = CGFloat(arc4random()%256)/255.0
        let g = CGFloat(arc4random()%256)/255.0
        let b = CGFloat(arc4random()%256)/255.0
        return SKColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let x = s2p(pos: Int(pos.x))
        let y = s2p(pos: Int(pos.y))
        
        if isMoving {
            return
        }
        
        if x >= 0 && y >= 0 {
            if  nodeMap[x][y] >= Int(ballCols.count) {
                return
            }
            isMoving = true
            if(lastpos.x>=0) {
                let ball = nodeBalls[Int(lastpos.x)][Int(lastpos.y)]
                ball?.removeAllActions()
                ball?.alpha = 1
                //ball?.fillColor = ballCols[nodeMap[Int(lastpos.x)][Int(lastpos.y)]]
                
                
                lastpos.x = -1
                lastpos.y = -1
            }
           
            lastpos = (x:x, y:y)
            let tipBall = nodeBalls[x][y]?.copy() as! SKShapeNode?
            tipBall?.removeAllActions()
            var sq = [SKAction]()
            sq.append(SKAction.scale(to: 1.5, duration: 0.3))
            sq.append(SKAction.removeFromParent())
            tipBall?.run(SKAction.sequence(sq))
            self.addChild(tipBall!)
            nodeBalls[x][y]?.run(SKAction.repeatForever(SKAction.sequence(
                [SKAction.fadeAlpha(to: 0.3, duration: 0.4),
                 SKAction.fadeIn(withDuration: 0.2),
                 SKAction.wait(forDuration: 0.5),])))
            //tipball.
            isMoving = false
        }
        
       //label?.text = " x:y:".appendingFormat("%d %d", x, y)
        
//        NSAlert(error: "x:y:".appendingFormat("%d %d", x, y))
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            //n.fillColor = SKColor.green
//            self.addChild(n)
//        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = randomColor()
//            //SKColor.blue
//            //n.fillColor = SKColor.blue
//            self.addChild(n)
//        }
//        
//        let x = s2p(pos: Int(pos.x))
//        let y = s2p(pos: Int(pos.y))
//        if x>=0 && y>=0 {
//            highShapeNode?.position = CGPoint(x:p2s(pos: x), y:p2s(pos: y))
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let x = s2p(pos: Int(pos.x))
        let y = s2p(pos: Int(pos.y))
        
        if isMoving {
            return
        }
        
        if(lastpos.x < 0) {
            return
        }
        
        if x >= 0 && y >= 0 {
            if  nodeMap[x][y] < Int(ballCols.count) {
                return
            }
            _ = moveBall(fromX: lastpos.x, fromY: lastpos.y, toX: x, toY: y)
        }
    }
//    override func mouseDown(with event: NSEvent) {
//        self.touchDown(atPoint: event.location(in: self))
//    }
//    
//    override func mouseMoved(with event: NSEvent) {
//        //self.touchMoved(toPoint: event.location(in: self))
//    }
//
//    override func mouseDragged(with event: NSEvent) {
//        self.touchMoved(toPoint: event.location(in: self))
//    }
//    
//    override func mouseUp(with event: NSEvent) {
//        self.touchUp(atPoint: event.location(in: self))
//    }
//    
//    override func keyDown(with event: NSEvent) {
//        switch event.keyCode {
//        case 0x31:
//            if let label = self.label {
//                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//            }
//        default:
//            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
