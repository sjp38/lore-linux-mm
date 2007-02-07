Date: Wed, 7 Feb 2007 06:13:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Drop PageReclaim()
Message-ID: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Am I missing something here? I cannot see PageReclaim have any effect?



PageReclaim is only used for dead code. The only current user is
end_page_writeback() which has the following lines:

 if (!TestClearPageReclaim(page) || rotate_reclaimable_page(page)) {
         if (!test_clear_page_writeback(page))
                  BUG();
 }

So the if statement is performed if !PageReclaim(page).
If PageReclaim is set then we call rorate_reclaimable(page) which
does:

 if (!PageLRU(page))
       return 1;

The only user of PageReclaim is shrink_list(). The pages processed
by shrink_list have earlier been taken off the LRU. So !PageLRU is always 
true.

The if statement is therefore always true and the rotating code
is never executed.

So drop all the PageReclaim() stuff. This yields one free
page state flag that we need for PageMlocked().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/mm/page_io.c
===================================================================
--- current.orig/mm/page_io.c	2007-02-07 00:16:20.000000000 -0800
+++ current/mm/page_io.c	2007-02-07 00:18:47.000000000 -0800
@@ -67,7 +67,6 @@ static int end_swap_bio_write(struct bio
 				imajor(bio->bi_bdev->bd_inode),
 				iminor(bio->bi_bdev->bd_inode),
 				(unsigned long long)bio->bi_sector);
-		ClearPageReclaim(page);
 	}
 	end_page_writeback(page);
 	bio_put(bio);
Index: current/mm/swap.c
===================================================================
--- current.orig/mm/swap.c	2007-02-07 00:16:20.000000000 -0800
+++ current/mm/swap.c	2007-02-07 00:18:47.000000000 -0800
@@ -95,47 +95,6 @@ void put_pages_list(struct list_head *pa
 EXPORT_SYMBOL(put_pages_list);
 
 /*
- * Writeback is about to end against a page which has been marked for immediate
- * reclaim.  If it still appears to be reclaimable, move it to the tail of the
- * inactive list.  The page still has PageWriteback set, which will pin it.
- *
- * We don't expect many pages to come through here, so don't bother batching
- * things up.
- *
- * To avoid placing the page at the tail of the LRU while PG_writeback is still
- * set, this function will clear PG_writeback before performing the page
- * motion.  Do that inside the lru lock because once PG_writeback is cleared
- * we may not touch the page.
- *
- * Returns zero if it cleared PG_writeback.
- */
-int rotate_reclaimable_page(struct page *page)
-{
-	struct zone *zone;
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
-	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	if (PageLRU(page) && !PageActive(page)) {
-		list_move_tail(&page->lru, &zone->inactive_list);
-		__count_vm_event(PGROTATED);
-	}
-	if (!test_clear_page_writeback(page))
-		BUG();
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
-	return 0;
-}
-
-/*
  * FIXME: speed this up?
  */
 void fastcall activate_page(struct page *page)
Index: current/mm/vmscan.c
===================================================================
--- current.orig/mm/vmscan.c	2007-02-07 00:16:20.000000000 -0800
+++ current/mm/vmscan.c	2007-02-07 00:18:51.000000000 -0800
@@ -366,18 +366,11 @@ static pageout_t pageout(struct page *pa
 			.for_reclaim = 1,
 		};
 
-		SetPageReclaim(page);
 		res = mapping->a_ops->writepage(page, &wbc);
 		if (res < 0)
 			handle_write_error(mapping, page, res);
-		if (res == AOP_WRITEPAGE_ACTIVATE) {
-			ClearPageReclaim(page);
+		if (res == AOP_WRITEPAGE_ACTIVATE)
 			return PAGE_ACTIVATE;
-		}
-		if (!PageWriteback(page)) {
-			/* synchronous write or broken a_ops? */
-			ClearPageReclaim(page);
-		}
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
Index: current/include/linux/swap.h
===================================================================
--- current.orig/include/linux/swap.h	2007-02-07 00:18:39.000000000 -0800
+++ current/include/linux/swap.h	2007-02-07 00:18:55.000000000 -0800
@@ -185,7 +185,6 @@ extern void FASTCALL(activate_page(struc
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
-extern int rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
Index: current/mm/filemap.c
===================================================================
--- current.orig/mm/filemap.c	2007-02-07 00:18:39.000000000 -0800
+++ current/mm/filemap.c	2007-02-07 00:18:55.000000000 -0800
@@ -530,10 +530,8 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
-	if (!TestClearPageReclaim(page) || rotate_reclaimable_page(page)) {
-		if (!test_clear_page_writeback(page))
-			BUG();
-	}
+	if (!test_clear_page_writeback(page))
+		BUG();
 	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_writeback);
 }
Index: current/include/linux/page-flags.h
===================================================================
--- current.orig/include/linux/page-flags.h	2007-02-07 00:24:56.000000000 -0800
+++ current/include/linux/page-flags.h	2007-02-07 00:25:29.000000000 -0800
@@ -30,7 +30,7 @@
  * PG_uptodate tells whether the page's contents is valid.  When a read
  * completes, the page becomes uptodate, unless a disk I/O error happened.
  *
- * PG_referenced, PG_reclaim are used for page reclaim for anonymous and
+ * PG_referenced is used for page reclaim for anonymous and
  * file-backed pagecache (see mm/vmscan.c).
  *
  * PG_error is set to indicate that an I/O error occurred on this page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
