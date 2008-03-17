Message-Id: <20080317191944.208962764@szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
Date: Mon, 17 Mar 2008 20:19:11 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 3/8] mm: rotate_reclaimable_page() cleanup
Content-Disposition: inline; filename=rotate_reclaimable_page_cleanup.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Clean up messy conditional calling of test_clear_page_writeback() from
both rotate_reclaimable_page() and end_page_writeback().

The only user of rotate_reclaimable_page() is end_page_writeback() so
this is OK.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 include/linux/swap.h |    2 +-
 mm/filemap.c         |   10 ++++++----
 mm/swap.c            |   37 ++++++++++++-------------------------
 3 files changed, 19 insertions(+), 30 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2008-03-17 18:24:13.000000000 +0100
+++ linux/include/linux/swap.h	2008-03-17 18:25:38.000000000 +0100
@@ -177,7 +177,7 @@ extern void activate_page(struct page *)
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
-extern int rotate_reclaimable_page(struct page *page);
+extern void rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
Index: linux/mm/filemap.c
===================================================================
--- linux.orig/mm/filemap.c	2008-03-17 18:24:13.000000000 +0100
+++ linux/mm/filemap.c	2008-03-17 18:25:38.000000000 +0100
@@ -577,10 +577,12 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
-	if (!TestClearPageReclaim(page) || rotate_reclaimable_page(page)) {
-		if (!test_clear_page_writeback(page))
-			BUG();
-	}
+	if (TestClearPageReclaim(page))
+		rotate_reclaimable_page(page);
+
+	if (!test_clear_page_writeback(page))
+		BUG();
+
 	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_writeback);
 }
Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2008-03-17 18:24:13.000000000 +0100
+++ linux/mm/swap.c	2008-03-17 18:25:38.000000000 +0100
@@ -133,34 +133,21 @@ static void pagevec_move_tail(struct pag
  * Writeback is about to end against a page which has been marked for immediate
  * reclaim.  If it still appears to be reclaimable, move it to the tail of the
  * inactive list.
- *
- * Returns zero if it cleared PG_writeback.
  */
-int rotate_reclaimable_page(struct page *page)
+void  rotate_reclaimable_page(struct page *page)
 {
-	struct pagevec *pvec;
-	unsigned long flags;
-
-	if (PageLocked(page))
-		return 1;
-	if (PageDirty(page))
-		return 1;
-	if (PageActive(page))
-		return 1;
-	if (!PageLRU(page))
-		return 1;
-
-	page_cache_get(page);
-	local_irq_save(flags);
-	pvec = &__get_cpu_var(lru_rotate_pvecs);
-	if (!pagevec_add(pvec, page))
-		pagevec_move_tail(pvec);
-	local_irq_restore(flags);
-
-	if (!test_clear_page_writeback(page))
-		BUG();
+	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
+	    PageLRU(page)) {
+		struct pagevec *pvec;
+		unsigned long flags;
 
-	return 0;
+		page_cache_get(page);
+		local_irq_save(flags);
+		pvec = &__get_cpu_var(lru_rotate_pvecs);
+		if (!pagevec_add(pvec, page))
+			pagevec_move_tail(pvec);
+		local_irq_restore(flags);
+	}
 }
 
 /*

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
