Date: Sun, 23 Jan 2000 01:39:51 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] kswapd less agressive
Message-ID: <Pine.LNX.4.10.10001230132210.245-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Alan, Andrea,

a few people (hi Andrea :)) have commented that kswapd
is somewhat too agressive in 2.2.15pre4. This patch
should fix that (but don't integrate it yet, I have not
tested it yet).

Basically kswapd used to agressively free pages until
it had reached freepages.high. Now kswapd will only
free pages agressively up to freepages.low, above that
it will pause if it finds it's ->need_resched set.
(which should bring us back to freeing in the background)

Everyone interested: please test 2.2.15pre4 with and
without this test and tell us your results, thank you.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.


--- vmscan.c.combo	Sun Jan 23 01:06:50 2000
+++ vmscan.c	Sun Jan 23 01:06:01 2000
@@ -498,6 +498,8 @@
 			if (!do_try_to_free_pages(GFP_KSWAPD))
 				break;
 			if (tsk->need_resched)
+				if (nr_free_pages > freepages.low)
+					break;
 				schedule();
 		}
 		run_task_queue(&tq_disk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
