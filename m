Date: Fri, 21 Jan 2000 03:18:35 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] 2.2.15-pre3 kswapd fix
In-Reply-To: <Pine.LNX.4.10.10001210252390.27593-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001210311050.4332-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Rik van Riel wrote:

>About Andrea's freepages.low vs. freepages.min problem,

It's not a problem. It's just that low is unused and you are now making
min unused. You are simply increasing the min value.

>I propose we chose .low here since it's value is higher
>and we're trying to solve a reliability problem here.

So just increase freepages.min as somebody does with sysctl.

>+++ linux-2.2.15-pre3/mm/vmscan.c	Fri Jan 21 02:46:42 2000
>@@ -485,18 +485,16 @@
> 		 * the processes needing more memory will wake us
> 		 * up on a more timely basis.
> 		 */
>-		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
> 		while (nr_free_pages < freepages.high)
> 		{
>-			if (do_try_to_free_pages(GFP_KSWAPD))
>-			{
>-				if (tsk->need_resched)
>-					schedule();
>-				continue;
>-			}
>-			tsk->state = TASK_INTERRUPTIBLE;
>-			schedule_timeout(10*HZ);
>+			if (!do_try_to_free_pages(GFP_KSWAPD))
>+				break;
>+			if (tsk->need_resched)
>+				schedule();
> 		}
>+		run_task_queue(&tq_disk);
>+		tsk->state = TASK_INTERRUPTIBLE;
>+		schedule_timeout(HZ);

How do you get a wakeup now? :) now it's pure too slow polling.

> 	wake_up_interruptible(&kswapd_wait);
>-	if (gfp_mask & __GFP_WAIT)
>+	if ((gfp_mask & __GFP_WAIT) && (nr_free_pages < (freepages.low - 4)))

Again treshing_mem heuristic broken...

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
