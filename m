Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA19055
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 12:01:36 -0500
Date: Thu, 26 Feb 1998 17:34:17 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: kswapd logic improvement
Message-ID: <Pine.LNX.3.91.980226172956.1153A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
List-ID: <linux-mm.kvack.org>

Hi Linus,

here's another short patch for 2.1.88. Basically
it improves the kswapd logic. Currently kswapd
will give up when it fails three times in a row,
even when it hasn't any memory yet.

With my patch, it'll try (free_pages_high - nr_free_pages)
times, and four times as often when nr_free_pages < free_pages_low.

Furthermore, it doesn't do synchronous swapouts any more
when nr_free_pages < min_free_pages because that's just
too slow (disk seek time etc.), but instead it runs the
disk task queue whenever nr_async_pages >= SWAP_CLUSTER_MAX

I hope it passes your test for 2.1.89 (I've been testing
it for quite a while, and it seems to give a small improvement).

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

--- linux2188orig/mm/vmscan.c	Wed Feb 25 16:39:55 1998
+++ linux-2.1.88/mm/vmscan.c	Thu Feb 26 17:27:39 1998
@@ -434,7 +434,6 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-#define MAX_SWAP_FAIL 3
 /*
  * The background pageout daemon.
  * Started as a kernel thread from the init process.
@@ -462,7 +461,7 @@
 	init_swap_timer();
 	
 	while (1) {
-		int fail;
+		int tries;
 
 		kswapd_awake = 0;
 		flush_signals(current);
@@ -471,13 +470,16 @@
 		kswapd_awake = 1;
 		swapstats.wakeups++;
 		/* Do the background pageout: 
-		 * We now only swap out as many pages as needed.
-		 * When we are truly low on memory, we swap out
-		 * synchronously (WAIT == 1).  -- Rik.
-		 * If we've had too many consecutive failures,
-		 * go back to sleep to let other tasks run.
+		 * We try free_pages_high - nr_free_pages times,
+		 * only when we're truly low on memory we'll try
+		 * more often. -- Rik.
 		 */
-		for (fail = 0; fail++ < MAX_SWAP_FAIL;) {
+		tries = (free_pages_high - nr_free_pages);
+		if (nr_free_pages < free_pages_low)
+			tries <<= 2;
+		if (tries < min_free_pages)
+			tries = min_free_pages;
+		while (tries--) {
 			int pages, gfp_mask;
 
 			pages = nr_free_pages;
@@ -486,10 +488,14 @@
 			if (pages >= free_pages_high)
 				break;
 			gfp_mask = __GFP_IO;
-			if (pages < free_pages_low)
-				gfp_mask |= __GFP_WAIT;
-			if (try_to_free_page(gfp_mask))
-				fail = 0;
+			try_to_free_page(gfp_mask);
+			/* We used to swap out syncronously when we
+			 * were low on memory, but this is simply
+			 * faster. And a fast recovery is all that
+			 * matters when nr_free_pages is too low.
+			 * -- Rik. */
+			if (atomic_read(&nr_async_pages) >= SWAP_CLUSTER_MAX)
+				run_task_queue(&tq_disk);
 		}
 		/*
 		 * Report failure if we couldn't reach the minimum goal.
