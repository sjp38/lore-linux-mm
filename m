Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA23910
	for <linux-mm@kvack.org>; Mon, 30 Mar 1998 12:15:24 -0500
Date: Mon, 30 Mar 1998 18:28:50 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: [PATCH] kswapd goal setting
Message-ID: <Pine.LNX.3.91.980330182622.575B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Linus,

after reading the messages in linux-kernel carefully, I
made the following patch (with fixed switch-points).

The choice of the switching points is based on the messages
posted to linux-kernel in the last few days.

It patches cleanly against 2.1.92-pre1, but should also
work for 2.1.91 and 2.1.90 (?).

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- vmscan.c.pre92.1	Mon Mar 30 18:09:44 1998
+++ vmscan.c	Mon Mar 30 18:25:46 1998
@@ -39,6 +39,13 @@
  */
 int swapout_interval = HZ / 4;
 
+/*
+ * This variable is used to determine the final goal of
+ * kswapd's quest...
+ */
+ 
+static int kswapd_goal = 0;
+
 /* 
  * The wait queue for waking up the pageout daemon:
  */
@@ -508,6 +515,16 @@
                s++, i = e - s;
        else
                s = revision, i = -1;
+       /* Here we set the goal for kswapd,
+        * if it's a 40+ MB machine, the full goal
+        * is used, for 16- MB machines we use a even
+        * less agressive goal. -- Rik.
+        */
+       if (num_physpages < 10240) {
+               kswapd_goal++;
+               if (num_physpages < 4096)
+                      kswapd_goal++;
+       }
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
@@ -574,7 +591,7 @@
 		while (tries--) {
 			int gfp_mask;
 
-			if (++tried > SWAP_CLUSTER_MAX && free_memory_available(0))
+			if (++tried > SWAP_CLUSTER_MAX && free_memory_available(kswapd_goal))
 				break;
 			gfp_mask = __GFP_IO;
 			try_to_free_page(gfp_mask);
