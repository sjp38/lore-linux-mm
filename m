Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA08092
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 20:15:16 -0500
Date: Tue, 3 Mar 1998 01:35:41 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH] kswapd fix & logic improvement
Message-ID: <Pine.LNX.3.91.980303013255.7010A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi there,

here's the final patch to improve kswapd behaviour
and improve the performance of the readahead code.

It was diffed against 2.1.89pre2, but since the VM
code hasn't changed up to pre5, it can be applied
easily.

I'm currently running a kernel with those changes,
and it works better than before.

To Linus: this is code is either so trivial or so
well-tested that it _can_ be safely merged into
pre6 or .89-final...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

--- linux/mm/filemap.c.orig	Thu Feb 26 21:10:44 1998
+++ linux/mm/filemap.c	Thu Feb 26 21:19:52 1998
@@ -25,6 +25,7 @@
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/blkdev.h>
+#include <linux/swapctl.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -158,12 +159,15 @@
 
 		switch (atomic_read(&page->count)) {
 			case 1:
-				/* If it has been referenced recently, don't free it */
-				if (test_and_clear_bit(PG_referenced, &page->flags))
-					break;
-
 				/* is it a swap-cache or page-cache page? */
 				if (page->inode) {
+					if (test_and_clear_bit(PG_referenced, &page->flags)) {
+						touch_page(page);
+						break;
+					}
+					age_page(page);
+					if (page->age)
+						break;
 					if (PageSwapCache(page)) {
 						delete_from_swap_cache(page);
 						return 1;
@@ -173,6 +177,10 @@
 					__free_page(page);
 					return 1;
 				}
+				/* It's not a cache page, so we don't do aging.
+				 * If it has been referenced recently, don't free it */
+				if (test_and_clear_bit(PG_referenced, &page->flags))
+					break;
 
 				/* is it a buffer cache page? */
 				if ((gfp_mask & __GFP_IO) && bh && try_to_free_buffer(bh, &bh, 6))
--- linux/mm/page_alloc.c.orig	Mon Mar  2 23:32:16 1998
+++ linux/mm/page_alloc.c	Tue Mar  3 00:03:48 1998
@@ -108,22 +108,51 @@
  * but this had better return false if any reasonable "get_free_page()"
  * allocation could currently fail..
  *
- * Right now we just require that the highest memory order should
- * have at least two entries. Whether this makes sense or not
- * under real load is to be tested, but it also gives us some
- * guarantee about memory fragmentation (essentially, it means
- * that there should be at least two large areas available).
+ * Currently we approve of the following situations:
+ * - the highest memory order has two entries
+ * - the highest memory order has one free entry and:
+ *	- the next-highest memory order has two free entries
+ * - the highest memory order has one free entry and:
+ *	- the next-highest memory order has one free entry
+ *	- the next-next-highest memory order has two free entries
+ *
+ * [previously, there had to be two entries of the highest memory
+ *  order, but this lead to problems on large-memory machines.]
  */
 int free_memory_available(void)
 {
-	int retval;
+	int retval = 0;
 	unsigned long flags;
-	struct free_area_struct * last = free_area + NR_MEM_LISTS - 1;
+	struct free_area_struct * biggest = free_area + NR_MEM_LISTS - 1;
+	struct free_area_struct * bigger = free_area + NR_MEM_LISTS - 2;
+	struct free_area_struct * big = free_area + NR_MEM_LISTS - 3;
 
 	spin_lock_irqsave(&page_alloc_lock, flags);
-	retval =  (last->next != memory_head(last)) && (last->next->next != memory_head(last));
+	if (biggest->next != memory_head(biggest)) {
+		retval = 4;
+		if (biggest->next->next != memory_head(biggest))
+			retval += 4;
+	} else {
+	/* we want at least one free area of the 'biggest' size */
+		goto out;
+	}
+	if (bigger->next != memory_head(bigger)) {
+		retval += 2;
+		if (bigger->next->next != memory_head(bigger))
+			retval += 2;
+	} else {
+	/* if we have only one free area of the 'biggest' size, we also
+	 * want one of the 'bigger' size */
+		goto out;
+	}
+	if (big->next != memory_head(big)) {
+		retval += 1;
+		if (big->next->next != memory_head(big))
+			retval += 1;
+	}
+out:
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
-	return retval;
+	return retval > 7;
 }
 
 static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
--- linux/mm/vmscan.c.orig	Thu Feb 26 21:10:33 1998
+++ linux/mm/vmscan.c	Thu Feb 26 21:57:53 1998
@@ -539,7 +539,7 @@
 	init_swap_timer();
 	add_wait_queue(&kswapd_wait, &wait);
 	while (1) {
-		int async;
+		int tries;
 
 		kswapd_awake = 0;
 		flush_signals(current);
@@ -549,32 +549,45 @@
 		kswapd_awake = 1;
 		swapstats.wakeups++;
 		/* Do the background pageout: 
-		 * We now only swap out as many pages as needed.
-		 * When we are truly low on memory, we swap out
-		 * synchronously (WAIT == 1).  -- Rik.
-		 * If we've had too many consecutive failures,
-		 * go back to sleep to let other tasks run.
+		 * When we've got loads of memory, we try
+		 * (free_pages_high - nr_free_pages) times to
+		 * free memory. As memory gets tighter, kswapd
+		 * gets more and more agressive. -- Rik.
 		 */
-		async = 1;
-		for (;;) {
+		tries = free_pages_high - nr_free_pages;
+		if (tries < min_free_pages) {
+			tries = min_free_pages;
+		}
+		else if (nr_free_pages < (free_pages_high + free_pages_low) / 2) {
+			tries <<= 1;
+			if (nr_free_pages < free_pages_low) {
+				tries <<= 1;
+				if (nr_free_pages <= min_free_pages) {
+					tries <<= 1;
+				}
+			}
+		}
+		while (tries--) {
 			int gfp_mask;
 
 			if (free_memory_available())
 				break;
 			gfp_mask = __GFP_IO;
-			if (!async)
-				gfp_mask |= __GFP_WAIT;
-			async = try_to_free_page(gfp_mask);
-			if (!(gfp_mask & __GFP_WAIT) || async)
-				continue;
-
+			try_to_free_page(gfp_mask);
 			/*
-			 * Not good. We failed to free a page even though
-			 * we were synchronous. Complain and give up..
+			 * Syncing large chunks is faster than swapping
+			 * synchronously (less head movement). -- Rik.
 			 */
-			printk("kswapd: failed to free page\n");
-			break;
+			if (atomic_read(&nr_async_pages) >= SWAP_CLUSTER_MAX)
+				run_task_queue(&tq_disk);
+
 		}
+	/*
+	 * Report failure if we couldn't even reach min_free_pages.
+	 */
+	if (nr_free_pages < min_free_pages)
+		printk("kswapd: failed, got %d of %d\n",
+			nr_free_pages, min_free_pages);
 	}
 	/* As if we could ever get here - maybe we want to make this killable */
 	remove_wait_queue(&kswapd_wait, &wait);
