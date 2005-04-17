From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40579.617974.423522@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:36:03 +0400
Subject: [PATCH]: VM 3/8 PG_skipped
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

Don't call ->writepage from VM scanner when page is met for the first time
during scan.

New page flag PG_skipped is used for this. This flag is TestSet-ed just
before calling ->writepage and is cleaned when page enters inactive
list.

One can see this as "second chance" algorithm for the dirty pages on the
inactive list.

BSD does the same: src/sys/vm/vm_pageout.c:vm_pageout_scan(),
PG_WINATCFLS flag.

Reason behind this is that ->writepages() will perform more efficient writeout
than ->writepage(). Skipping of page can be conditioned on zone->pressure.

On the other hand, avoiding ->writepage() increases amount of scanning
performed by kswapd.

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 include/linux/page-flags.h |    7 +++
 mm/swap.c                  |    1 
 mm/truncate.c              |    2 +
 mm/vmscan.c                |   80 +++++++++++++++++++++++++++++++--------------
 4 files changed, 66 insertions(+), 24 deletions(-)

diff -puN mm/vmscan.c~skip-writepage mm/vmscan.c
--- bk-linux/mm/vmscan.c~skip-writepage	2005-04-17 17:52:49.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-17 17:52:49.000000000 +0400
@@ -331,18 +329,50 @@ static pageout_t pageout(struct page *pa
 		return PAGE_ACTIVATE;
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
-
+	/*
+	 * Don't call ->writepage when page is met for the first time during
+	 * scanning. Reasons:
+	 *
+	 *     1. if memory pressure is not too high, skipping ->writepage()
+	 *     may avoid writing out page that will be re-dirtied (should not
+	 *     be too important, because scanning starts from the tail of
+	 *     inactive list, where pages are _supposed_ to be rarely used,
+	 *     but when under constant memory pressure, inactive list is
+	 *     rotated and so is more FIFO than LRU).
+	 *
+	 *     2. ->writepages() writes data more efficiently than
+	 *     ->writepage().
+	 */
+	if (!TestSetPageSkipped(page))
+		return PAGE_KEEP;
 	if (clear_page_dirty_for_io(page)) {
 		int res;
+
 		struct writeback_control wbc = {
 			.sync_mode = WB_SYNC_NONE,
 			.nr_to_write = SWAP_CLUSTER_MAX,
-			.nonblocking = 1,
-			.for_reclaim = 1,
+			/*
+			 * synchronous page reclamation should be non blocking
+			 * for the reasons outlined in the comment above. But
+			 * in the kswapd blocking is ok.
+			 *
+			 * NOTE:
+			 *
+			 *     1. .nonblocking is not analyzed by existing
+			 *     in-tree implementations of ->writepage().
+			 *
+			 *     2. may be if page zone is under considerable
+			 *     memory pressure (zone->prev_priority is low),
+			 *     .nonblocking should be set anyway.
+			 */
+			.nonblocking = !current_is_kswapd(),
+			.for_reclaim = 1 /* XXX not used */
 		};
 
+		ClearPageSkipped(page);
 		SetPageReclaim(page);
 		res = mapping->a_ops->writepage(page, &wbc);
+
 		if (res < 0)
 			handle_write_error(mapping, page, res);
 		if (res == WRITEPAGE_ACTIVATE) {
@@ -353,10 +383,8 @@ static pageout_t pageout(struct page *pa
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
 		}
-
 		return PAGE_SUCCESS;
 	}
-
 	return PAGE_CLEAN;
 }
 
@@ -643,10 +671,13 @@ static void shrink_cache(struct zone *zo
 			if (TestSetPageLRU(page))
 				BUG();
 			list_del(&page->lru);
-			if (PageActive(page))
+			if (PageActive(page)) {
+				if (PageSkipped(page))
+					ClearPageSkipped(page);
 				add_page_to_active_list(zone, page);
-			else
+			} else {
 				add_page_to_inactive_list(zone, page);
+			}
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -757,6 +788,7 @@ refill_inactive_zone(struct zone *zone, 
 			BUG();
 		if (!TestClearPageActive(page))
 			BUG();
+		ClearPageSkipped(page);
 		list_move(&page->lru, &zone->inactive_list);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
diff -puN include/linux/page-flags.h~skip-writepage include/linux/page-flags.h
--- bk-linux/include/linux/page-flags.h~skip-writepage	2005-04-17 17:52:49.000000000 +0400
+++ bk-linux-nikita/include/linux/page-flags.h	2005-04-17 17:52:49.000000000 +0400
@@ -76,6 +76,7 @@
 #define PG_reclaim		18	/* To be reclaimed asap */
 #define PG_nosave_free		19	/* Free, should not be written */
 #define PG_uncached		20	/* Page has been mapped as uncached */
+#define PG_skipped		21	/* ->writepage() was skipped */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -161,6 +162,12 @@ extern void __mod_page_state(unsigned of
 		__mod_page_state(offset, (delta));				\
 	} while (0)
 
+#define PageSkipped(page)	test_bit(PG_skipped, &(page)->flags)
+#define SetPageSkipped(page)	set_bit(PG_skipped, &(page)->flags)
+#define TestSetPageSkipped(page)	test_and_set_bit(PG_skipped, &(page)->flags)
+#define ClearPageSkipped(page)		clear_bit(PG_skipped, &(page)->flags)
+#define TestClearPageSkipped(page)	test_and_clear_bit(PG_skipped, &(page)->flags)
+
 /*
  * Manipulation of page state flags
  */
diff -puN mm/truncate.c~skip-writepage mm/truncate.c
--- bk-linux/mm/truncate.c~skip-writepage	2005-04-17 17:52:49.000000000 +0400
+++ bk-linux-nikita/mm/truncate.c	2005-04-17 17:52:49.000000000 +0400
@@ -54,6 +54,7 @@ truncate_complete_page(struct address_sp
 	clear_page_dirty(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
+	ClearPageSkipped(page);
 	remove_from_page_cache(page);
 	page_cache_release(page);	/* pagecache ref */
 }
@@ -86,6 +87,7 @@ invalidate_complete_page(struct address_
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);
 	ClearPageUptodate(page);
+	ClearPageSkipped(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 }
diff -puN mm/swap.c~skip-writepage mm/swap.c
--- bk-linux/mm/swap.c~skip-writepage	2005-04-17 17:52:49.000000000 +0400
+++ bk-linux-nikita/mm/swap.c	2005-04-17 17:52:49.000000000 +0400
@@ -303,6 +303,7 @@ void __pagevec_lru_add(struct pagevec *p
 		}
 		if (TestSetPageLRU(page))
 			BUG();
+		ClearPageSkipped(page);
 		add_page_to_inactive_list(zone, page);
 	}
 	if (zone)

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
