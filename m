Date: Sat, 17 Aug 2002 20:05:00 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] VM docs from -ac
Message-ID: <20020817200500.A17270@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[grr, I mis-spelled marcelo again..]

I'm not entirely sure who wrote them, but I think it was wli.
I've made sure they're correct for the mainline VM - they're not
related to page replacement policies anway..

In addition I've reordered mark_page_accessed() to be more readable,
this does not change the functionality at all.


diff -uNr -Xdontdiff -p linux-2.4.20-pre3/mm/filemap.c linux/mm/filemap.c
--- linux-2.4.20-pre3/mm/filemap.c	Tue Aug 13 15:56:05 2002
+++ linux/mm/filemap.c	Sat Aug 17 15:12:56 2002
@@ -803,7 +803,6 @@ static inline wait_queue_head_t *page_wa
 	/* On some cpus multiply is faster, on others gcc will do shifts */
 	hash *= GOLDEN_RATIO_PRIME;
 #endif
-
 	hash >>= zone->wait_table_shift;
 
 	return &wait[hash];
@@ -815,6 +814,21 @@ static inline wait_queue_head_t *page_wa
  * This must be called with the caller "holding" the page,
  * ie with increased "page->count" so that the page won't
  * go away during the wait..
+ *
+ * The waiting strategy is to get on a waitqueue determined
+ * by hashing. Waiters will then collide, and the newly woken
+ * task must then determine whether it was woken for the page
+ * it really wanted, and go back to sleep on the waitqueue if
+ * that wasn't it. With the waitqueue semantics, it never leaves
+ * the waitqueue unless it calls, so the loop moves forward one
+ * iteration every time there is
+ * (1) a collision 
+ * and
+ * (2) one of the colliding pages is woken
+ *
+ * This is the thundering herd problem, but it is expected to
+ * be very rare due to the few pages that are actually being
+ * waited on at any given time and the quality of the hash function.
  */
 void ___wait_on_page(struct page *page)
 {
@@ -835,7 +849,11 @@ void ___wait_on_page(struct page *page)
 }
 
 /*
- * Unlock the page and wake up sleepers in ___wait_on_page.
+ * unlock_page() is the other half of the story just above
+ * __wait_on_page(). Here a couple of quick checks are done
+ * and a couple of flags are set on the page, and then all
+ * of the waiters for all of the pages in the appropriate
+ * wait queue are woken.
  */
 void unlock_page(struct page *page)
 {
@@ -845,6 +863,13 @@ void unlock_page(struct page *page)
 	if (!test_and_clear_bit(PG_locked, &(page)->flags))
 		BUG();
 	smp_mb__after_clear_bit(); 
+
+	/*
+	 * Although the default semantics of wake_up() are
+	 * to wake all, here the specific function is used
+	 * to make it even more explicit that a number of
+	 * pages are being waited on here.
+	 */
 	if (waitqueue_active(waitqueue))
 		wake_up_all(waitqueue);
 }
@@ -1294,21 +1310,16 @@ static void generic_file_readahead(int r
 /*
  * Mark a page as having seen activity.
  *
- * If it was already so marked, move it
- * to the active queue and drop the referenced
- * bit. Otherwise, just mark it for future
- * action..
+ * If it was already so marked, move it to the active queue and drop
+ * the referenced bit.  Otherwise, just mark it for future action..
  */
 void mark_page_accessed(struct page *page)
 {
 	if (!PageActive(page) && PageReferenced(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
-		return;
-	}
-
-	/* Mark the page referenced, AFTER checking for previous usage.. */
-	SetPageReferenced(page);
+	} else
+		SetPageReferenced(page);
 }
 
 /*
diff -uNr -Xdontdiff -p linux-2.4.20-pre3/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-2.4.20-pre3/mm/page_alloc.c	Sat Aug 17 14:54:39 2002
+++ linux/mm/page_alloc.c	Sat Aug 17 15:09:29 2002
@@ -30,8 +30,10 @@ LIST_HEAD(active_list);
 pg_data_t *pgdat_list;
 
 /*
- * Used by page_zone() to look up the address of the struct zone whose
- * id is encoded in the upper bits of page->flags
+ *
+ * The zone_table array is used to look up the address of the
+ * struct zone corresponding to a given zone number (ZONE_DMA,
+ * ZONE_NORMAL, or ZONE_HIGHMEM).
  */
 zone_t *zone_table[MAX_NR_ZONES*MAX_NR_NODES];
 EXPORT_SYMBOL(zone_table);
@@ -53,8 +55,10 @@ static int zone_balance_max[MAX_NR_ZONES
 
 /*
  * Freeing function for a buddy system allocator.
+ * Contrary to prior comments, this is *NOT* hairy, and there
+ * is no reason for anyone not to understand it.
  *
- * The concept of a buddy system is to maintain direct-mapped table
+ * The concept of a buddy system is to maintain direct-mapped tables
  * (containing bit values) for memory blocks of various "orders".
  * The bottom level table contains the map for the smallest allocatable
  * units of memory (here, pages), and each level above it describes
diff -uNr -Xdontdiff -p linux-2.4.20-pre3/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.4.20-pre3/mm/vmscan.c	Tue Aug 13 15:56:05 2002
+++ linux/mm/vmscan.c	Sat Aug 17 15:09:55 2002
@@ -1,6 +1,9 @@
 /*
  *  linux/mm/vmscan.c
  *
+ *  The pageout daemon, decides which pages to evict (swap out) and
+ *  does the actual work of freeing them.
+ *
  *  Copyright (C) 1991, 1992, 1993, 1994  Linus Torvalds
  *
  *  Swap reorganised 29.12.95, Stephen Tweedie.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
