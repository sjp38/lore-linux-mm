Date: Sun, 23 Jan 2000 03:37:05 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] goeasy without typo :)
Message-ID: <Pine.LNX.4.10.10001230331450.245-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Alan, Andrea,

IBM's James Manning pointed out two forgotten braces
in my last patchlet, so here is a new version (one that
should work). Like the last one it slows down kswapd
once it gets above freepages.low .. because it frees
memory with SWAP_CLUSTER_MAX pages at a time, this won't
give any hysteresis problems.

Between freepages.low and freepages.high kswapd will
do background freeing of pages. When the CPU is idle
it will work until it has reached freepages.high,
otherwise it'll yield the CPU and try again later.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.


--- mm/vmscan.c.combo	Sun Jan 23 01:06:50 2000
+++ mm/vmscan.c	Sun Jan 23 03:30:46 2000
@@ -497,8 +497,11 @@
 		{
 			if (!do_try_to_free_pages(GFP_KSWAPD))
 				break;
-			if (tsk->need_resched)
+			if (tsk->need_resched) {
+				if (nr_free_pages > freepages.low)
+					break;
 				schedule();
+			}
 		}
 		run_task_queue(&tq_disk);
 		interruptible_sleep_on_timeout(&kswapd_wait, HZ);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
