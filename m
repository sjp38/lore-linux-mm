Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA29335
	for <linux-mm@kvack.org>; Thu, 19 Mar 1998 14:53:59 -0500
Date: Thu, 19 Mar 1998 20:50:15 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH] background swapping enabled again
Message-ID: <Pine.LNX.3.91.980319204635.1963A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I decided to go with your free_pages_available() test,
since Ben and Stephen will provide the framework to
implement it properly even on small-mem machines...

But background swapping (when eg. BUFFER_MEM > max)
has been made impossible in .90.
Since this breaks the maximum limit for buffermem, I
have made the following patch...

It makes sure we at least do SWAP_CLUSTER_MAX calls
to try_to_free_page(), so background works again...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- vmscan.c.orig	Thu Mar 19 01:45:42 1998
+++ vmscan.c	Thu Mar 19 20:46:09 1998
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
