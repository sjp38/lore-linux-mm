From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17006.5376.606064.533068@gargle.gargle.HOWL>
Date: Tue, 26 Apr 2005 14:16:32 +0400
Subject: Re: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
In-Reply-To: <20050425212911.31cf6b43.akpm@osdl.org>
References: <16994.40728.397980.431164@gargle.gargle.HOWL>
	<20050425212911.31cf6b43.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:

[...]

 > 
 > To address the race which Nick identified I think we can do it this way?

I think that instead of fixing that race we'd better to make it valid:
let's redefine PG_reclaim to mean

       "page has been seen on the tail of the inactive list, but VM
       failed to reclaim it right away either because it was dirty, or
       there was some race. Reclaim this page as soon as possible."

Nikita.

set PG_reclaimed bit on pages that are under writeback when shrink_list()
looks at them: these pages are at end of the inactive list, and it only makes
sense to reclaim them as soon as possible when writeout finishes.

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 mm/filemap.c    |   10 +++++----
 mm/page_alloc.c |    3 +-
 mm/swap.c       |   12 +----------
 mm/vmscan.c     |   60 +++++++++++++++++++++++++++++++++++++++++---------------
 4 files changed, 54 insertions(+), 31 deletions(-)

diff -puN mm/vmscan.c~SetPageReclaimed-inactive-tail mm/vmscan.c
--- bk-linux/mm/vmscan.c~SetPageReclaimed-inactive-tail	2005-04-22 12:09:59.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-22 12:11:31.000000000 +0400
@@ -41,13 +41,18 @@
 
 /* possible outcome of pageout() */
 typedef enum {
-	/* failed to write page out, page is locked */
+	/* failed to write page out, page is unlocked */
 	PAGE_KEEP,
+	/*
+	 * failed to write page out _now_ owing to some temporary condition,
+	 * page is locked
+	 */
+	PAGE_RACE,
 	/* move page to the active list, page is locked */
 	PAGE_ACTIVATE,
 	/* page has been sent to the disk successfully, page is unlocked */
 	PAGE_SUCCESS,
-	/* page was queued for asynchronous pageout */
+	/* page was queued for asynchronous pageout, page is locked */
 	PAGE_ASYNC,
 	/* page is clean and locked */
 	PAGE_CLEAN,
@@ -285,6 +290,12 @@ static int may_write_to_queue(struct bac
 	return 0;
 }
 
+static inline void set_page_reclaim(struct page *page)
+{
+	if (!PageReclaim(page))
+		SetPageReclaim(page);
+}
+
 /*
  * We detected a synchronous write error writing a page out.  Probably
  * -ENOSPC.  We need to propagate that into the address_space for a subsequent
@@ -464,7 +475,7 @@ static pageout_t pageout(struct page *pa
 	 * swapfile.c:page_queue_congested().
 	 */
 	if (!is_page_cache_freeable(page))
-		return PAGE_KEEP;
+		return PAGE_RACE;
 	if (!mapping) {
 		/*
 		 * Some data journaling orphaned pages can have
@@ -482,7 +493,7 @@ static pageout_t pageout(struct page *pa
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
 	if (!may_write_to_queue(mapping->backing_dev_info))
-		return PAGE_KEEP;
+		return PAGE_RACE;
 	/*
 	 * Don't call ->writepage when page is met for the first time during
 	 * scanning. Reasons:
@@ -570,8 +581,10 @@ static int shrink_list(struct list_head 
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (TestSetPageLocked(page))
+		if (TestSetPageLocked(page)) {
+			set_page_reclaim(page);
 			goto keep;
+		}
 
 		BUG_ON(PageActive(page));
 
@@ -581,7 +594,7 @@ static int shrink_list(struct list_head 
 			sc->nr_scanned++;
 
 		if (PageWriteback(page))
-			goto keep_locked;
+			goto keep_reclaim;
 
 		inuse = page_mapping_inuse(page);
 		referenced = page_referenced(page, 1, sc->priority <= 0,
@@ -614,7 +627,7 @@ static int shrink_list(struct list_head 
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
-				goto keep_locked;
+				goto keep_reclaim;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -624,14 +637,16 @@ static int shrink_list(struct list_head 
 			if (referenced)
 				goto keep_locked;
 			if (!may_enter_fs)
-				goto keep_locked;
+				goto keep_reclaim;
 			if (laptop_mode && !sc->may_writepage)
-				goto keep_locked;
+				goto keep_reclaim;
 
 			/* Page is dirty, try to write it out here */
 			switch(pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
+			case PAGE_RACE:
+				goto keep_reclaim;
 			case PAGE_ACTIVATE:
 				goto activate_locked;
 			case PAGE_ASYNC:
@@ -685,7 +700,7 @@ static int shrink_list(struct list_head 
 		}
 
 		if (!mapping)
-			goto keep_locked;	/* truncate got there first */
+			goto keep_reclaim;	/* truncate got there first */
 
 		write_lock_irq(&mapping->tree_lock);
 
@@ -696,7 +711,7 @@ static int shrink_list(struct list_head 
 		 */
 		if (page_count(page) != 2 || PageDirty(page)) {
 			write_unlock_irq(&mapping->tree_lock);
-			goto keep_locked;
+			goto keep_reclaim;
 		}
 
 #ifdef CONFIG_SWAP
@@ -724,6 +739,14 @@ free_it:
 activate_locked:
 		SetPageActive(page);
 		pgactivate++;
+		goto keep_locked;
+keep_reclaim:
+		/*
+		 * the page reached the end of the inactive list, it should be
+		 * reclaimed as soon as possible to maintain LRU
+		 * approximation.
+		 */
+		set_page_reclaim(page);
 keep_locked:
 		unlock_page(page);
 keep:
@@ -1420,21 +1443,26 @@ static void __kpgout(void)
 		page = lru_to_page(&todo);
 		list_del(&page->lru);
 
-		if (TestSetPageLocked(page))
+		if (TestSetPageLocked(page)) {
+			set_page_reclaim(page);
 			outcome = PAGE_SUCCESS;
-		else if (PageWriteback(page))
-			outcome = PAGE_KEEP;
-		else if (PageDirty(page))
+		} else if (PageWriteback(page)) {
+			outcome = PAGE_RACE;
+		} else if (PageDirty(page)) {
 			outcome = pageout(page,
 					  page_mapping(page), NULL);
-		else
+		} else
 			outcome = PAGE_KEEP;
 
+		if (outcome == PAGE_RACE)
+ 			set_page_reclaim(page);
+
 		switch (outcome) {
 		case PAGE_ASYNC:
 			BUG();
 		case PAGE_ACTIVATE:
 			SetPageActive(page);
+		case PAGE_RACE:
 		case PAGE_KEEP:
 		case PAGE_CLEAN:
 			unlock_page(page);
diff -puN mm/page_alloc.c~SetPageReclaimed-inactive-tail mm/page_alloc.c
--- bk-linux/mm/page_alloc.c~SetPageReclaimed-inactive-tail	2005-04-22 12:09:59.000000000 +0400
+++ bk-linux-nikita/mm/page_alloc.c	2005-04-22 12:09:59.000000000 +0400
@@ -319,13 +319,14 @@ static inline void free_pages_check(cons
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
-			1 << PG_reclaim	|
 			1 << PG_slab	|
 			1 << PG_swapcache |
 			1 << PG_writeback )))
 		bad_page(function, page);
 	if (PageDirty(page))
 		ClearPageDirty(page);
+	if (PageReclaim(page))
+		ClearPageReclaim(page);
 }
 
 /*
diff -puN mm/swap.c~SetPageReclaimed-inactive-tail mm/swap.c
--- bk-linux/mm/swap.c~SetPageReclaimed-inactive-tail	2005-04-22 12:09:59.000000000 +0400
+++ bk-linux-nikita/mm/swap.c	2005-04-22 12:09:59.000000000 +0400
@@ -62,12 +62,7 @@ EXPORT_SYMBOL(put_page);
  * We don't expect many pages to come through here, so don't bother batching
  * things up.
  *
- * To avoid placing the page at the tail of the LRU while PG_writeback is still
- * set, this function will clear PG_writeback before performing the page
- * motion.  Do that inside the lru lock because once PG_writeback is cleared
- * we may not touch the page.
- *
- * Returns zero if it cleared PG_writeback.
+ * Returns zero if page was moved.
  */
 int rotate_reclaimable_page(struct page *page)
 {
@@ -86,12 +81,9 @@ int rotate_reclaimable_page(struct page 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (PageLRU(page) && !PageActive(page)) {
-		list_del(&page->lru);
-		list_add_tail(&page->lru, &zone->inactive_list);
+		list_move_tail(&page->lru, &zone->inactive_list);
 		inc_page_state(pgrotated);
 	}
-	if (!test_clear_page_writeback(page))
-		BUG();
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 	return 0;
 }
diff -puN mm/filemap.c~SetPageReclaimed-inactive-tail mm/filemap.c
--- bk-linux/mm/filemap.c~SetPageReclaimed-inactive-tail	2005-04-22 12:09:59.000000000 +0400
+++ bk-linux-nikita/mm/filemap.c	2005-04-22 12:09:59.000000000 +0400
@@ -445,6 +445,8 @@ void fastcall unlock_page(struct page *p
 	if (!TestClearPageLocked(page))
 		BUG();
 	smp_mb__after_clear_bit();
+	if (unlikely(TestClearPageReclaim(page)))
+		rotate_reclaimable_page(page);
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
@@ -454,10 +456,10 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
-	if (!TestClearPageReclaim(page) || rotate_reclaimable_page(page)) {
-		if (!test_clear_page_writeback(page))
-			BUG();
-	}
+	if (unlikely(TestClearPageReclaim(page)))
+		rotate_reclaimable_page(page);
+	if (!test_clear_page_writeback(page))
+		BUG();
 	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_writeback);
 }

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
