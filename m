Date: Thu, 20 Jan 2000 18:11:46 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.10.10001192201020.15862-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001200433150.2314-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2000, Rik van Riel wrote:

>--- linux-2.2.15-pre3/mm/vmscan.c.orig	Wed Jan 19 21:18:54 2000
>+++ linux-2.2.15-pre3/mm/vmscan.c	Wed Jan 19 22:06:34 2000
>@@ -490,12 +490,13 @@
> 		{
> 			if (do_try_to_free_pages(GFP_KSWAPD))
> 			{
>+				run_task_queue(&tq_disk);
> 				if (tsk->need_resched)
> 					schedule();
> 				continue;
> 			}

There's a limit of max swap request, after that a wait_on_page will
trigger I/O. So you'll only decrease performance by doing so as far I can 
tell.

> 			tsk->state = TASK_INTERRUPTIBLE;
>-			schedule_timeout(10*HZ);
>+			schedule_timeout(HZ);

I used 10 sec because if you run oom into kswapd it means you can't hardly
do anything within kswapd in the next 10 seconds. If userspace is
triggering OOM all will continue to run fine and it's way better to remove
kswapd from the game to gracefully allow userspace to detect oom. Note
that a do_try_to_free_pages can take quite some time before failing in a
9giga machine with 9giga allocated in userspace (I am talking 2.2.x, in
2.3.x my page-LRU will allow shrink_mmap to not waste time trying to free
9giga/PAGE_SIZE pages).

If instead atomic allocations caused oom and kswapd failed then you should
give up for some time as well since you know all memory is not freeable
and so only a __free_pages will release memory. Thus kswapd will be
wasted time in such case too and you should instead wait a process to
trigger some allocation to be able to kill it.

> 	wake_up_interruptible(&kswapd_wait);
>-	if (gfp_mask & __GFP_WAIT)
>+	if ((gfp_mask & __GFP_WAIT) && (nr_free_pages < (freepages.low - 4)))
> 		retval = do_try_to_free_pages(gfp_mask);

-4 make no sense as ".low" could be as well set to 3 and theorically the
system should remains stable.

And you are trying to wakeup kswapd instead of blocking. This will make
oom condition worse and it brekas my trashing mem watermark heuristic. The
heuristic is necessary to penalize the hog. It should be a per-process
thing btw.

>--- linux-2.2.15-pre3/mm/page_alloc.c.orig	Wed Jan 19 21:32:05 2000
>+++ linux-2.2.15-pre3/mm/page_alloc.c	Wed Jan 19 21:42:00 2000
>@@ -212,7 +212,7 @@
> 	if (!(current->flags & PF_MEMALLOC)) {
> 		int freed;
> 
>-		if (nr_free_pages > freepages.min) {
>+		if (nr_free_pages > freepages.low) {
> 			if (!low_on_memory)
> 				goto ok_to_allocate;
> 			if (nr_free_pages >= freepages.high) {

freepages.low is unused. With this change you are using low and making min
unused. min seems the right name there. Nobody is allowed to allocate
memory without first free some memory if the system is under the
_min_ memory watermark. If you don't like the current defaults just change
the dyanmic setting at boot in page_alloc.c. They can be changed as well
via /proc/sys/vm/freepages (you just know :).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
