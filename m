Date: Thu, 20 Jan 2000 21:30:54 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.21.0001200433150.2314-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001201918361.27593-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2000, Andrea Arcangeli wrote:

> There's a limit of max swap request, after that a wait_on_page
> will trigger I/O. So you'll only decrease performance by doing so
> as far I can tell.

Not really. We want to get the I/O done and we don't want
to wait until the queue fills up.

> > 			tsk->state = TASK_INTERRUPTIBLE;
> >-			schedule_timeout(10*HZ);
> >+			schedule_timeout(HZ);
> 
> I used 10 sec because if you run oom into kswapd it means you
> can't hardly do anything within kswapd in the next 10 seconds.

OOM is not the normal state the system is in. You really want
kswapd to do some work in the background (allowing user programs
to allocate their bits of memory without stalling).

> If instead atomic allocations caused oom and kswapd failed then
> you should give up for some time as well since you know all memory
> is not freeable and so only a __free_pages will release memory.

In the OOM case we'll have to kill a process. Stalling the
system forever is not a solution.

> > 	wake_up_interruptible(&kswapd_wait);
> >-	if (gfp_mask & __GFP_WAIT)
> >+	if ((gfp_mask & __GFP_WAIT) && (nr_free_pages < (freepages.low - 4)))
> > 		retval = do_try_to_free_pages(gfp_mask);
> 
> -4 make no sense as ".low" could be as well set to 3 and
> theorically the system should remains stable.

It does make sense in reality. Please read the explanation
I sent with the patch. I agree that somewhere halfway
freepages.low and freepages.min would be better, but there
is no need to complicate the calculation...

> And you are trying to wakeup kswapd instead of blocking. This will
> make oom condition worse and it brekas my trashing mem watermark
> heuristic. The heuristic is necessary to penalize the hog. It
> should be a per-process thing btw.

If kswapd can keep up, there's no need at all to slow down
processes, not even hogs. If kswapd can't keep up then we'll
start stalling processes (just 5 allocations further away,
_and_ kswapd will have been started by that time and have had
the time to do something).

> >--- linux-2.2.15-pre3/mm/page_alloc.c.orig	Wed Jan 19 21:32:05 2000
> >+++ linux-2.2.15-pre3/mm/page_alloc.c	Wed Jan 19 21:42:00 2000
> >@@ -212,7 +212,7 @@
> > 	if (!(current->flags & PF_MEMALLOC)) {
> > 		int freed;
> > 
> >-		if (nr_free_pages > freepages.min) {
> >+		if (nr_free_pages > freepages.low) {
> > 			if (!low_on_memory)
> > 				goto ok_to_allocate;
> > 			if (nr_free_pages >= freepages.high) {
> 
> freepages.low is unused. With this change you are using low and
> making min unused. min seems the right name there.

I consider the absense of the third boundary a HUGE bug
in current 2.2 VM. You need three boundaries:

- min:  below this boundary only ATOMIC (and GFP_HIGH?)
        allocations can be done
- low:  below this boundary we start swapping agressively
- high: below this boundary we start background swapping
        (once a second, without impact on processes), above
        this boundary we stop swapping

Current (2-border) code makes for bursty swap behaviour,
poor handling of kernel allocations (see the complaints
Alan got about systems which ran OOM on atomic allocations).

There is a good reason why there is a difference between
background swapping and agressive swapping, why there is
a separate swapout daemon, etc...

Performance-wise, current 2.2 went back to the stone age,
we should do something about that.

> Nobody is allowed to allocate memory without first free some
> memory if the system is under the _min_ memory watermark.

That's not the way things were meant to be. Below freepages.low
low-priority allocations should stall, below freepages.min higher
priority allocations should stall and only GFP_ATOMIC and
PF_MEMALLOC allocations should be able to proceed.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
