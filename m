Date: Fri, 21 Jan 2000 03:29:23 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [patch] 2.2.15-pre3 kswapd fix
In-Reply-To: <Pine.LNX.4.21.0001210311050.4332-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001210326330.27593-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Andrea Arcangeli wrote:
> On Fri, 21 Jan 2000, Rik van Riel wrote:
> 
> >About Andrea's freepages.low vs. freepages.min problem,
> 
> It's not a problem. It's just that low is unused and you are now making
> min unused. You are simply increasing the min value.

More than that. Min is supposed to be the absolute boundary
below which nothing can allocate memory (except for ATOMIC
allocations). It's not with the old code, that's broken.

> >+++ linux-2.2.15-pre3/mm/vmscan.c	Fri Jan 21 02:46:42 2000
> >@@ -485,18 +485,16 @@
> > 		 * the processes needing more memory will wake us
> > 		 * up on a more timely basis.
> > 		 */
> >-		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
> > 		while (nr_free_pages < freepages.high)
> > 		{
> >-			if (do_try_to_free_pages(GFP_KSWAPD))
> >-			{
> >-				if (tsk->need_resched)
> >-					schedule();
> >-				continue;
> >-			}
> >-			tsk->state = TASK_INTERRUPTIBLE;
> >-			schedule_timeout(10*HZ);
> >+			if (!do_try_to_free_pages(GFP_KSWAPD))
> >+				break;
> >+			if (tsk->need_resched)
> >+				schedule();
> > 		}
> >+		run_task_queue(&tq_disk);
> >+		tsk->state = TASK_INTERRUPTIBLE;
> >+		schedule_timeout(HZ);
> 
> How do you get a wakeup now? :) now it's pure too slow polling.

I copied this from the 2.3 code in the expectation that
schedule_timeout(HZ); is interruptible. If it's not, then
we've just found a 2.3 bug :)

> > 	wake_up_interruptible(&kswapd_wait);
> >-	if (gfp_mask & __GFP_WAIT)
> >+	if ((gfp_mask & __GFP_WAIT) && (nr_free_pages < (freepages.low - 4)))
> 
> Again treshing_mem heuristic broken...

Please explain to me why this is broken? I've carefully
explained why this makes sense and you haven't given
any practical explanation on your point of view...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
