Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA19885
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 21:05:05 -0500
Date: Mon, 23 Mar 1998 22:31:44 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH] kswapd fix
Message-ID: <Pine.LNX.3.91.980323222552.570B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I've written the following fix for kswapd, it:
- makes sure kswapd doesn't use all of the CPU, even if swapout_interval
  is 0 (this fix is broken, but works for the moment)
- triggers kswapd when free_memory_available() fails
  (it gives a swapout frenzy, but since BUFFER_MEM has a minimum
  quota interactive use suffers far less)
- makes sure kswapd tries at least SWAP_CLUSTER_MAX times before
  quitting (even when free_memory_available() succeeds), this is
  done to avoid loads of context switches when kswapd is triggered
  for another reason

It patches cleanly against 2.1.90.
(my university's internet dialup line is _very_ flaky right
now, so I can't ftp a pre-91 if it exists :-( ).

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- vmscan.c.orig	Thu Mar 19 01:45:42 1998
+++ vmscan.c	Mon Mar 23 22:12:21 1998
@@ -545,6 +545,7 @@
 	add_wait_queue(&kswapd_wait, &wait);
 	while (1) {
 		int tries;
+		int tried = 0;
 
 		current->state = TASK_INTERRUPTIBLE;
 		kswapd_awake = 0;
@@ -563,12 +564,12 @@
 		if (tries < freepages.min) {
 			tries = freepages.min;
 		}
-		if (nr_free_pages < freepages.high + freepages.low)
+		if (nr_free_pages < freepages.low)
 			tries <<= 1;
 		while (tries--) {
 			int gfp_mask;
 
-			if (free_memory_available())
+			if (free_memory_available() && ++tried > SWAP_CLUSTER_MAX)
 				break;
 			gfp_mask = __GFP_IO;
 			try_to_free_page(gfp_mask);
@@ -597,8 +598,8 @@
 
 	if (pages < freepages.low)
 		memory_low = want_wakeup = 1;
-	else if ((pages < freepages.high || BUFFER_MEM > (num_physpages * buffer_mem.max_percent / 100))
-			&& jiffies >= next_swap_jiffies)
+	else if ((pages < freepages.high || BUFFER_MEM > (num_physpages * buffer_mem.max_percent / 100) || !free_memory_available())
+			&& jiffies >= next_swap_jiffies + 5)
 		want_wakeup = 1;
 
 	if (want_wakeup) { 
