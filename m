Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA11644
	for <linux-mm@kvack.org>; Wed, 11 Mar 1998 12:01:16 -0500
Date: Wed, 11 Mar 1998 16:29:11 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH] milder kswapd
Message-ID: <Pine.LNX.3.91.980311162707.5838C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi there,

since many of you have complained that kswapd is a tad
agressive in 2.1.89, I've made the following patch to
counter that 'bad behaviour'.

happy hacking,

Rik.

(and don't forget your /proc/sys/vm/swapctl!)
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux/mm/vmscan.c.orig	Wed Mar 11 16:23:17 1998
+++ linux/mm/vmscan.c	Wed Mar 11 16:25:52 1998
@@ -511,7 +511,6 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-#define MAX_SWAP_FAIL 3
 /*
  * The background pageout daemon.
  * Started as a kernel thread from the init process.
@@ -559,15 +558,8 @@
 		if (tries < min_free_pages) {
 			tries = min_free_pages;
 		}
-		else if (nr_free_pages < (free_pages_high + free_pages_low) / 2) {
+		else if (nr_free_pages < (free_pages_low + min_free_pages) / 2) 
 			tries <<= 1;
-			if (nr_free_pages < free_pages_low) {
-				tries <<= 1;
-				if (nr_free_pages <= min_free_pages) {
-					tries <<= 1;
-				}
-			}
-		}
 		while (tries--) {
 			int gfp_mask;
 
