From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 10/4  -ac to newer rmap
Message-Id: <20021113193041Z80262-23310+72@imladris.surriel.com>
Date: Wed, 13 Nov 2002 17:30:34 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch updates the part of filemap.c that I know about to the code
which is in -rmap. I'm not sure about the removal of a_ops->removepage,
nor about the directio changes, so those aren't included yet.

I'll merge non-trivial stuff once the trivial things are done.

(ObWork: my patches are sponsored by Conectiva, Inc)
--- linux-2.4.19/mm/filemap.c	2002-11-13 08:48:31.000000000 -0200
+++ linux-2.4-rmap/mm/filemap.c	2002-11-13 12:10:45.000000000 -0200
@@ -237,12 +237,11 @@ static inline void truncate_partial_page
 
 static void truncate_complete_page(struct page *page)
 {
-	/* Page has already been removed from processes, by vmtruncate()  */
-	if (page->pte_chain)
-		BUG();
-
-	/* Leave it on the LRU if it gets converted into anonymous buffers */
-	if (!page->buffers || do_flushpage(page, 0))
+	/*
+	 * Leave it on the LRU if it gets converted into anonymous buffers
+	 * or anonymous process memory.
+	 */
+	if ((!page->buffers || do_flushpage(page, 0)) && !page->pte_chain)
 		lru_cache_del(page);
 
 	/*
@@ -808,33 +807,18 @@ static inline wait_queue_head_t *page_wa
 	/* On some cpus multiply is faster, on others gcc will do shifts */
 	hash *= GOLDEN_RATIO_PRIME;
 #endif
+
 	hash >>= zone->wait_table_shift;
 
 	return &wait[hash];
 }
 
-
 /* 
  * Wait for a page to get unlocked.
  *
  * This must be called with the caller "holding" the page,
  * ie with increased "page->count" so that the page won't
  * go away during the wait..
- *
- * The waiting strategy is to get on a waitqueue determined
- * by hashing. Waiters will then collide, and the newly woken
- * task must then determine whether it was woken for the page
- * it really wanted, and go back to sleep on the waitqueue if
- * that wasn't it. With the waitqueue semantics, it never leaves
- * the waitqueue unless it calls, so the loop moves forward one
- * iteration every time there is
- * (1) a collision 
- * and
- * (2) one of the colliding pages is woken
- *
- * This is the thundering herd problem, but it is expected to
- * be very rare due to the few pages that are actually being
- * waited on at any given time and the quality of the hash function.
  */
 void ___wait_on_page(struct page *page)
 {
@@ -855,11 +839,7 @@ void ___wait_on_page(struct page *page)
 }
 
 /*
- * unlock_page() is the other half of the story just above
- * __wait_on_page(). Here a couple of quick checks are done
- * and a couple of flags are set on the page, and then all
- * of the waiters for all of the pages in the appropriate
- * wait queue are woken.
+ * Unlock the page and wake up sleepers in ___wait_on_page.
  */
 void unlock_page(struct page *page)
 {
@@ -869,13 +849,6 @@ void unlock_page(struct page *page)
 	if (!test_and_clear_bit(PG_locked, &(page)->flags))
 		BUG();
 	smp_mb__after_clear_bit(); 
-
-	/*
-	 * Although the default semantics of wake_up() are
-	 * to wake all, here the specific function is used
-	 * to make it even more explicit that a number of
-	 * pages are being waited on here.
-	 */
 	if (waitqueue_active(waitqueue))
 		wake_up_all(waitqueue);
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
