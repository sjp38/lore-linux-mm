Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA01851
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 08:09:32 -0500
Date: Thu, 26 Mar 1998 12:22:46 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: [PATCH] swapout speedup 2.1.91-pre2
Message-ID: <Pine.LNX.3.91.980326121934.19975A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

here's the speedup patch I promised earlier.
It:
- increases tries when we're tight on memory
- clusters swapouts from user programs (to save disk movement)
- wraps the above in a nice inline

NOTE: this patch is untested, but otherwise completely trivial :)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux/mm/vmscan.c.pre91-2	Thu Mar 26 11:56:00 1998
+++ linux/mm/vmscan.c	Thu Mar 26 12:08:20 1998
@@ -568,7 +568,7 @@
 		 * per second (1.6MB/s). This should be a /proc
 		 * thing.
 		 */
-		tries = 50;
+		tries = (50 << 3) >> free_memory_available(3);
 	
 		while (tries--) {
 			int gfp_mask;
--- linux/mm/page_alloc.c.pre91-2	Thu Mar 26 12:07:00 1998
+++ linux/mm/page_alloc.c	Thu Mar 26 12:07:00 1998
@@ -282,7 +282,7 @@
 	spin_lock_irqsave(&page_alloc_lock, flags);
 	RMQUEUE(order, maxorder, (gfp_mask & GFP_DMA));
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
-	if ((gfp_mask & __GFP_WAIT) && try_to_free_page(gfp_mask))
+	if ((gfp_mask & __GFP_WAIT) && try_to_free_pages(gfp_mask,SWAP_CLUSTER_MAX))
 		goto repeat;
 nopage:
 	return 0;
--- linux/include/linux/swap.h.pre91-2	Thu Mar 26 12:02:14 1998
+++ linux/include/linux/swap.h	Thu Mar 26 12:06:23 1998
@@ -122,6 +122,21 @@
 }
 
 /*
+ * When we're freeing pages from a user application, we want
+ * to cluster swapouts too.	-- Rik.
+ * linux/mm/page_alloc.c
+ */
+static inline int try_to_free_pages(int gfp_mask, int count)
+{
+	int retval = 0;
+	while (count--) {
+		if (try_to_free_page(gfp_mask))
+			retval = 1;
+	}
+	return retval;
+}
+
+/*
  * Make these inline later once they are working properly.
  */
 extern long find_in_swap_cache(struct page *page);
