Date: Sun, 18 Apr 2004 10:48:54 -0700
From: Marc Singer <elf@buici.com>
Subject: Re: vmscan.c heuristic adjustment for smaller systems
Message-ID: <20040418174854.GA29162@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Might be worth reading my thread on linux-mm about this and commenting?
> (hint hint)

Did you start a thread about this?  I'm not seeing it.

On Sun, Apr 18, 2004 at 10:29:47AM +0100, Russell King wrote:
> On Sat, Apr 17, 2004 at 05:23:43PM -0700, Marc Singer wrote:
> > All of these tests are performed at the console, one command at a
> > time.  I have a telnet daemon available, so I open a second connection
> > to the target system.  I run a continuous loop of file copies on the
> > console and I execute 'ls -l /proc' in the telnet window.  It's a
> > little slow, but it isn't unreasonable.  Hmm.  I then run the copy
> > command in the telnet window followed by the 'ls -l /proc'.  It works
> > fine.  I logout of the console session and perform the telnet window
> > test again.  The 'ls -l /proc takes 30 seconds.
> > 
> > When there is more than one process running, everything is peachy.
> > When there is only one process (no context switching) I see the slow
> > performance.  I had a hypothesis, but my test of that hypothesis
> > failed.
> 
> Guys, this tends to indicate that we _must_ have up to date aging
> information from the PTE - if not, we're liable to miss out on the
> pressure from user applications.  The "lazy" method which 2.4 will
> allow is not possible with 2.6.
> 
> This means we must flush the TLB when we mark the PTE old.

That has been my hypothesis all along.  But I have failed to prove it
to myself.  Please steer me if I've missed your point about flushing
TLB entries when we age PTEs.

As you recall, I was originally concerned that clearing hardware PTEs
without flushing the related TLB entries was causing my crash.  You
corrected my misunderstanding and the then we found the real culprit.
However, we discussed whether or not it was desirable to always flush
TLBs when aging PTEs instead of being lazy about it as the kernel now
is.

So, I tried this.  Since I don't know the virtual address for a PTE in
the set_pte() routine, I changed it to flush the whole TLB whenever it
sets a hardware PTE entry to zero.  Yet, I still get the slow-down
behavior.  I also changed the TLB flush routines to always do a
complete TLB flush instead of flushing individual entries.  Still, no
change in the slow-down.

So, if my slow-down is related to lazy TLB flushing then I am at a
loss to explain how.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
