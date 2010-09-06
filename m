Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 197576B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 06:47:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 06/10] vmscan: Narrow the scenarios lumpy reclaim uses synchrounous reclaim
Date: Mon,  6 Sep 2010 11:47:29 +0100
Message-Id: <1283770053-18833-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

shrink_page_list() can decide to give up reclaiming a page under a
number of conditions such as

  1. trylock_page() failure
  2. page is unevictable
  3. zone reclaim and page is mapped
  4. PageWriteback() is true
  5. page is swapbacked and swap is full
  6. add_to_swap() failure
  7. page is dirty and gfpmask don't have GFP_IO, GFP_FS
  8. page is pinned
  9. IO queue is congested
 10. pageout() start IO, but not finished

When lumpy reclaim, all of failure result in entering synchronous lumpy
reclaim but this can be unnecessary.  In cases (2), (3), (5), (6), (7) and
(8), there is no point retrying.  This patch causes lumpy reclaim to abort
when it is known it will fail.

Case (9) is more interesting. current behavior is,
  1. start shrink_page_list(async)
  2. found queue_congested()
  3. skip pageout write
  4. still start shrink_page_list(sync)
  5. wait on a lot of pages
  6. again, found queue_congested()
  7. give up pageout write again

So, it's meaningless time wasting. However, just skipping page reclaim is
also not a good as as x86 allocating a huge page needs 512 pages for example.
It can have more dirty pages than queue congestion threshold (~=128).

After this patch, pageout() behaves as follows;

 - If order > PAGE_ALLOC_COSTLY_ORDER
	Ignore queue congestion always.
 - If order <= PAGE_ALLOC_COSTLY_ORDER
	skip write page and disable lumpy reclaim.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/vmscan.h |    6 +-
 mm/vmscan.c                   |  122 +++++++++++++++++++++++++---------------
 2 files changed, 79 insertions(+), 49 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 14c1586..6f07c44 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -25,13 +25,13 @@
 
 #define trace_reclaim_flags(page, sync) ( \
 	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-	(sync == PAGEOUT_IO_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
+	(sync == LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
 	)
 
 #define trace_shrink_flags(file, sync) ( \
-	(sync == PAGEOUT_IO_SYNC ? RECLAIM_WB_MIXED : \
+	(sync == LUMPY_MODE_SYNC ? RECLAIM_WB_MIXED : \
 			(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON)) |  \
-	(sync == PAGEOUT_IO_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
+	(sync == LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
 	)
 
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79bd812..21d1153 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -51,6 +51,12 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
+enum lumpy_mode {
+	LUMPY_MODE_NONE,
+	LUMPY_MODE_ASYNC,
+	LUMPY_MODE_SYNC,
+};
+
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
@@ -82,7 +88,7 @@ struct scan_control {
 	 * Intend to reclaim enough contenious memory rather than to reclaim
 	 * enough amount memory. I.e, it's the mode for high order allocation.
 	 */
-	bool lumpy_reclaim_mode;
+	enum lumpy_mode lumpy_reclaim_mode;
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
@@ -265,6 +271,36 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 	return ret;
 }
 
+static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
+				   bool sync)
+{
+	enum lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
+
+	/*
+	 * Some reclaim have alredy been failed. No worth to try synchronous
+	 * lumpy reclaim.
+	 */
+	if (sync && sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
+		return;
+
+	/*
+	 * If we need a large contiguous chunk of memory, or have
+	 * trouble getting a small set of contiguous pages, we
+	 * will reclaim both active and inactive pages.
+	 */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		sc->lumpy_reclaim_mode = mode;
+	else if (sc->order && priority < DEF_PRIORITY - 2)
+		sc->lumpy_reclaim_mode = mode;
+	else
+		sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
+}
+
+static void disable_lumpy_reclaim_mode(struct scan_control *sc)
+{
+	sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
+}
+
 static inline int is_page_cache_freeable(struct page *page)
 {
 	/*
@@ -275,7 +311,8 @@ static inline int is_page_cache_freeable(struct page *page)
 	return page_count(page) - page_has_private(page) == 2;
 }
 
-static int may_write_to_queue(struct backing_dev_info *bdi)
+static int may_write_to_queue(struct backing_dev_info *bdi,
+			      struct scan_control *sc)
 {
 	if (current->flags & PF_SWAPWRITE)
 		return 1;
@@ -283,6 +320,10 @@ static int may_write_to_queue(struct backing_dev_info *bdi)
 		return 1;
 	if (bdi == current->backing_dev_info)
 		return 1;
+
+	/* lumpy reclaim for hugepage often need a lot of write */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		return 1;
 	return 0;
 }
 
@@ -307,12 +348,6 @@ static void handle_write_error(struct address_space *mapping,
 	unlock_page(page);
 }
 
-/* Request for sync pageout. */
-enum pageout_io {
-	PAGEOUT_IO_ASYNC,
-	PAGEOUT_IO_SYNC,
-};
-
 /* possible outcome of pageout() */
 typedef enum {
 	/* failed to write page out, page is locked */
@@ -330,7 +365,7 @@ typedef enum {
  * Calls ->writepage().
  */
 static pageout_t pageout(struct page *page, struct address_space *mapping,
-						enum pageout_io sync_writeback)
+			 struct scan_control *sc)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write
@@ -366,8 +401,10 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	}
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
-	if (!may_write_to_queue(mapping->backing_dev_info))
+	if (!may_write_to_queue(mapping->backing_dev_info, sc)) {
+		disable_lumpy_reclaim_mode(sc);
 		return PAGE_KEEP;
+	}
 
 	if (clear_page_dirty_for_io(page)) {
 		int res;
@@ -394,7 +431,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 		 * direct reclaiming a large contiguous area and the
 		 * first attempt to free a range of pages fails.
 		 */
-		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
+		if (PageWriteback(page) &&
+		    sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC)
 			wait_on_page_writeback(page);
 
 		if (!PageWriteback(page)) {
@@ -402,7 +440,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		trace_mm_vmscan_writepage(page,
-			trace_reclaim_flags(page, sync_writeback));
+			trace_reclaim_flags(page, sc->lumpy_reclaim_mode));
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
@@ -580,7 +618,7 @@ static enum page_references page_check_references(struct page *page,
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
-	if (sc->lumpy_reclaim_mode)
+	if (sc->lumpy_reclaim_mode != LUMPY_MODE_NONE)
 		return PAGEREF_RECLAIM;
 
 	/*
@@ -644,8 +682,7 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-					struct scan_control *sc,
-					enum pageout_io sync_writeback)
+				      struct scan_control *sc)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -665,7 +702,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (sync_writeback == PAGEOUT_IO_SYNC)
+		if (sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC)
 			lock_page(page);
 		else if (!trylock_page(page))
 			goto keep;
@@ -696,10 +733,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * for any page for which writeback has already
 			 * started.
 			 */
-			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
+			if (sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC &&
+			    may_enter_fs)
 				wait_on_page_writeback(page);
-			else
-				goto keep_locked;
+			else {
+				unlock_page(page);
+				goto keep_lumpy;
+			}
 		}
 
 		references = page_check_references(page, sc);
@@ -753,14 +793,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
-			switch (pageout(page, mapping, sync_writeback)) {
+			switch (pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
 			case PAGE_ACTIVATE:
 				goto activate_locked;
 			case PAGE_SUCCESS:
-				if (PageWriteback(page) || PageDirty(page))
+				if (PageWriteback(page))
+					goto keep_lumpy;
+				if (PageDirty(page))
 					goto keep;
+
 				/*
 				 * A synchronous write - probably a ramdisk.  Go
 				 * ahead and try to reclaim the page.
@@ -843,6 +886,7 @@ cull_mlocked:
 			try_to_free_swap(page);
 		unlock_page(page);
 		putback_lru_page(page);
+		disable_lumpy_reclaim_mode(sc);
 		continue;
 
 activate_locked:
@@ -855,6 +899,8 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
+		disable_lumpy_reclaim_mode(sc);
+keep_lumpy:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
@@ -1255,7 +1301,7 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
 		return false;
 
 	/* Only stall on lumpy reclaim */
-	if (!sc->lumpy_reclaim_mode)
+	if (sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
 		return false;
 
 	/* If we have relaimed everything on the isolated list, no stall */
@@ -1300,15 +1346,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			return SWAP_CLUSTER_MAX;
 	}
 
-
+	set_lumpy_reclaim_mode(priority, sc, false);
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode ?
-				ISOLATE_BOTH : ISOLATE_INACTIVE,
+			sc->lumpy_reclaim_mode == LUMPY_MODE_NONE ?
+					ISOLATE_INACTIVE : ISOLATE_BOTH,
 			zone, 0, file);
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1320,8 +1366,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode ?
-				ISOLATE_BOTH : ISOLATE_INACTIVE,
+			sc->lumpy_reclaim_mode == LUMPY_MODE_NONE ?
+					ISOLATE_INACTIVE : ISOLATE_BOTH,
 			zone, sc->mem_cgroup,
 			0, file);
 		/*
@@ -1339,7 +1385,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+	nr_reclaimed = shrink_page_list(&page_list, sc);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
@@ -1350,7 +1396,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		nr_active = clear_active_flags(&page_list, NULL);
 		count_vm_events(PGDEACTIVATE, nr_active);
 
-		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
+		set_lumpy_reclaim_mode(priority, sc, true);
+		nr_reclaimed += shrink_page_list(&page_list, sc);
 	}
 
 	local_irq_disable();
@@ -1727,21 +1774,6 @@ out:
 	}
 }
 
-static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc)
-{
-	/*
-	 * If we need a large contiguous chunk of memory, or have
-	 * trouble getting a small set of contiguous pages, we
-	 * will reclaim both active and inactive pages.
-	 */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		sc->lumpy_reclaim_mode = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
-		sc->lumpy_reclaim_mode = 1;
-	else
-		sc->lumpy_reclaim_mode = 0;
-}
-
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -1756,8 +1788,6 @@ static void shrink_zone(int priority, struct zone *zone,
 
 	get_scan_count(zone, sc, nr, priority);
 
-	set_lumpy_reclaim_mode(priority, sc);
-
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
