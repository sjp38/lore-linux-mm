Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 78EBE6B0112
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:29:09 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 8/8] mm: vmscan: Rename lumpy_mode to reclaim_mode
Date: Wed, 17 Nov 2010 16:22:49 +0000
Message-Id: <1290010969-26721-9-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

With compaction being used instead of lumpy reclaim, the name lumpy_mode
and associated variables is a bit misleading. Rename lumpy_mode to
reclaim_mode which is a better fit. There is no functional change.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/vmscan.h |    6 ++--
 mm/vmscan.c                   |   72 ++++++++++++++++++++--------------------
 2 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index be76429..ea422aa 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -25,13 +25,13 @@
 
 #define trace_reclaim_flags(page, sync) ( \
 	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-	(sync & LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
+	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
 	)
 
 #define trace_shrink_flags(file, sync) ( \
-	(sync & LUMPY_MODE_SYNC ? RECLAIM_WB_MIXED : \
+	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_MIXED : \
 			(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON)) |  \
-	(sync & LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
+	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
 	)
 
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a0fa57..52a0f0c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -53,22 +53,22 @@
 #include <trace/events/vmscan.h>
 
 /*
- * lumpy_mode determines how the inactive list is shrunk
- * LUMPY_MODE_SINGLE: Reclaim only order-0 pages
- * LUMPY_MODE_ASYNC:  Do not block
- * LUMPY_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
- * LUMPY_MODE_CONTIGRECLAIM: For high-order allocations, take a reference
+ * reclaim_mode determines how the inactive list is shrunk
+ * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
+ * RECLAIM_MODE_ASYNC:  Do not block
+ * RECLAIM_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
+ * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference
  *			page from the LRU and reclaim all pages within a
  *			naturally aligned range
- * LUMPY_MODE_COMPACTION: For high-order allocations, reclaim a number of
+ * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number of
  *			order-0 pages and then compact the zone
  */
-typedef unsigned __bitwise__ lumpy_mode;
-#define LUMPY_MODE_SINGLE		((__force lumpy_mode)0x01u)
-#define LUMPY_MODE_ASYNC		((__force lumpy_mode)0x02u)
-#define LUMPY_MODE_SYNC			((__force lumpy_mode)0x04u)
-#define LUMPY_MODE_CONTIGRECLAIM	((__force lumpy_mode)0x08u)
-#define LUMPY_MODE_COMPACTION		((__force lumpy_mode)0x10u)
+typedef unsigned __bitwise__ reclaim_mode;
+#define RECLAIM_MODE_SINGLE		((__force reclaim_mode)0x01u)
+#define RECLAIM_MODE_ASYNC		((__force reclaim_mode)0x02u)
+#define RECLAIM_MODE_SYNC		((__force reclaim_mode)0x04u)
+#define RECLAIM_MODE_LUMPYRECLAIM	((__force reclaim_mode)0x08u)
+#define RECLAIM_MODE_COMPACTION		((__force reclaim_mode)0x10u)
 
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
@@ -101,7 +101,7 @@ struct scan_control {
 	 * Intend to reclaim enough continuous memory rather than reclaim
 	 * enough amount of memory. i.e, mode for high order allocation.
 	 */
-	lumpy_mode lumpy_reclaim_mode;
+	reclaim_mode reclaim_mode;
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
@@ -282,10 +282,10 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 	return ret;
 }
 
-static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
+static void set_reclaim_mode(int priority, struct scan_control *sc,
 				   bool sync)
 {
-	lumpy_mode syncmode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
+	reclaim_mode syncmode = sync ? RECLAIM_MODE_SYNC : RECLAIM_MODE_ASYNC;
 
 	/*
 	 * Initially assume we are entering either lumpy reclaim or lumpy
@@ -293,9 +293,9 @@ static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
 	 * mode or just reclaim order-0 pages later.
 	 */
 	if (COMPACTION_BUILD)
-		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
+		sc->reclaim_mode = RECLAIM_MODE_COMPACTION;
 	else
-		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
+		sc->reclaim_mode = RECLAIM_MODE_LUMPYRECLAIM;
 
 	/*
 	 * If we need a large contiguous chunk of memory, or have
@@ -303,16 +303,16 @@ static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
 	 * will reclaim both active and inactive pages.
 	 */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		sc->lumpy_reclaim_mode |= syncmode;
+		sc->reclaim_mode |= syncmode;
 	else if (sc->order && priority < DEF_PRIORITY - 2)
-		sc->lumpy_reclaim_mode |= syncmode;
+		sc->reclaim_mode |= syncmode;
 	else
-		sc->lumpy_reclaim_mode = LUMPY_MODE_SINGLE | LUMPY_MODE_ASYNC;
+		sc->reclaim_mode = RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;
 }
 
-static void disable_lumpy_reclaim_mode(struct scan_control *sc)
+static void reset_reclaim_mode(struct scan_control *sc)
 {
-	sc->lumpy_reclaim_mode = LUMPY_MODE_SINGLE | LUMPY_MODE_ASYNC;
+	sc->reclaim_mode = RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;
 }
 
 static inline int is_page_cache_freeable(struct page *page)
@@ -443,7 +443,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 		 * first attempt to free a range of pages fails.
 		 */
 		if (PageWriteback(page) &&
-		    (sc->lumpy_reclaim_mode & LUMPY_MODE_SYNC))
+		    (sc->reclaim_mode & RECLAIM_MODE_SYNC))
 			wait_on_page_writeback(page);
 
 		if (!PageWriteback(page)) {
@@ -451,7 +451,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		trace_mm_vmscan_writepage(page,
-			trace_reclaim_flags(page, sc->lumpy_reclaim_mode));
+			trace_reclaim_flags(page, sc->reclaim_mode));
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
@@ -629,7 +629,7 @@ static enum page_references page_check_references(struct page *page,
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
-	if (sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM)
+	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
 		return PAGEREF_RECLAIM;
 
 	/*
@@ -746,7 +746,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * for any page for which writeback has already
 			 * started.
 			 */
-			if ((sc->lumpy_reclaim_mode & LUMPY_MODE_SYNC) &&
+			if ((sc->reclaim_mode & RECLAIM_MODE_SYNC) &&
 			    may_enter_fs)
 				wait_on_page_writeback(page);
 			else {
@@ -902,7 +902,7 @@ cull_mlocked:
 			try_to_free_swap(page);
 		unlock_page(page);
 		putback_lru_page(page);
-		disable_lumpy_reclaim_mode(sc);
+		reset_reclaim_mode(sc);
 		continue;
 
 activate_locked:
@@ -915,7 +915,7 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		disable_lumpy_reclaim_mode(sc);
+		reset_reclaim_mode(sc);
 keep_lumpy:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
@@ -1331,7 +1331,7 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
 		return false;
 
 	/* Only stall on lumpy reclaim */
-	if (sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE)
+	if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
 		return false;
 
 	/* If we have relaimed everything on the isolated list, no stall */
@@ -1375,7 +1375,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			return SWAP_CLUSTER_MAX;
 	}
 
-	set_lumpy_reclaim_mode(priority, sc, false);
+	set_reclaim_mode(priority, sc, false);
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1383,13 +1383,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	 * If we are lumpy compacting, we bump nr_to_scan to at least
 	 * the size of the page we are trying to allocate
 	 */
-	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
+	if (sc->reclaim_mode & RECLAIM_MODE_COMPACTION)
 		nr_to_scan = max(nr_to_scan, (1UL << sc->order));
 
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM ?
+			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, 0, file);
 		zone->pages_scanned += nr_scanned;
@@ -1402,7 +1402,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM ?
+			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, sc->mem_cgroup,
 			0, file);
@@ -1425,7 +1425,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
-		set_lumpy_reclaim_mode(priority, sc, true);
+		set_reclaim_mode(priority, sc, true);
 		nr_reclaimed += shrink_page_list(&page_list, zone, sc);
 	}
 
@@ -1436,14 +1436,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 
-	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
+	if (sc->reclaim_mode & RECLAIM_MODE_COMPACTION)
 		reclaimcompact_zone_order(zone, sc->order, sc->gfp_mask);
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
 		priority,
-		trace_shrink_flags(file, sc->lumpy_reclaim_mode));
+		trace_shrink_flags(file, sc->reclaim_mode));
 	return nr_reclaimed;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
