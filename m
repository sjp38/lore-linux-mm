Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 3BC916B0102
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 12:06:28 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: vmscan: Remove lumpy reclaim
Date: Wed, 28 Mar 2012 17:06:22 +0100
Message-Id: <1332950783-31662-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1332950783-31662-1-git-send-email-mgorman@suse.de>
References: <1332950783-31662-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

Lumpy reclaim had a purpose but in the mind of some, it was to kick
the system so hard it trashed. For others the purpose was to complicate
vmscan.c. Over time it was giving softer shoes and a nicer attitude but
memory compaction needs to step up and replace it so this patch sends
lumpy reclaim to the farm.

Here are the important notes related to the patch.

1. The tracepoint format changes for isolating LRU pages.

2. This patch stops reclaim/compaction entering sync reclaim as this
   was only intended for lumpy reclaim and an oversight. Page migration
   has its own logic for stalling on writeback pages if necessary and
   memory compaction is already using it. This is a behaviour change.

3. RECLAIM_MODE_SYNC no longer exists. pageout() does not stall
   on PageWriteback with CONFIG_COMPACTION has been this way for a while.
   I am calling it out in case this is a surpise to people. This behaviour
   avoids a situation where we wait on a page being written back to
   slow storage like USB. Currently we depend on wait_iff_congested()
   for throttling if if too many dirty pages are scanned.

4. Reclaim/compaction can no longer queue dirty pages in pageout()
   if the underlying BDI is congested. Lumpy reclaim used this logic and
   reclaim/compaction was using it in error. This is a behaviour change.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/vmscan.h |   36 ++-----
 mm/vmscan.c                   |  209 +++--------------------------------------
 2 files changed, 22 insertions(+), 223 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f64560e..6f60b33 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -13,7 +13,7 @@
 #define RECLAIM_WB_ANON		0x0001u
 #define RECLAIM_WB_FILE		0x0002u
 #define RECLAIM_WB_MIXED	0x0010u
-#define RECLAIM_WB_SYNC		0x0004u
+#define RECLAIM_WB_SYNC		0x0004u	/* Unused, all reclaim async */
 #define RECLAIM_WB_ASYNC	0x0008u
 
 #define show_reclaim_flags(flags)				\
@@ -27,13 +27,13 @@
 
 #define trace_reclaim_flags(page, sync) ( \
 	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
+	(RECLAIM_WB_ASYNC)   \
 	)
 
 #define trace_shrink_flags(file, sync) ( \
-	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_MIXED : \
-			(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON)) |  \
-	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
+	( \
+		(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) |  \
+		(RECLAIM_WB_ASYNC) \
 	)
 
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
@@ -263,22 +263,16 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
-		unsigned long nr_lumpy_taken,
-		unsigned long nr_lumpy_dirty,
-		unsigned long nr_lumpy_failed,
 		isolate_mode_t isolate_mode,
 		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file),
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file),
 
 	TP_STRUCT__entry(
 		__field(int, order)
 		__field(unsigned long, nr_requested)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_taken)
-		__field(unsigned long, nr_lumpy_taken)
-		__field(unsigned long, nr_lumpy_dirty)
-		__field(unsigned long, nr_lumpy_failed)
 		__field(isolate_mode_t, isolate_mode)
 		__field(int, file)
 	),
@@ -288,22 +282,16 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->nr_requested = nr_requested;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_taken = nr_taken;
-		__entry->nr_lumpy_taken = nr_lumpy_taken;
-		__entry->nr_lumpy_dirty = nr_lumpy_dirty;
-		__entry->nr_lumpy_failed = nr_lumpy_failed;
 		__entry->isolate_mode = isolate_mode;
 		__entry->file = file;
 	),
 
-	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu file=%d",
+	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
 		__entry->isolate_mode,
 		__entry->order,
 		__entry->nr_requested,
 		__entry->nr_scanned,
 		__entry->nr_taken,
-		__entry->nr_lumpy_taken,
-		__entry->nr_lumpy_dirty,
-		__entry->nr_lumpy_failed,
 		__entry->file)
 );
 
@@ -313,13 +301,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
-		unsigned long nr_lumpy_taken,
-		unsigned long nr_lumpy_dirty,
-		unsigned long nr_lumpy_failed,
 		isolate_mode_t isolate_mode,
 		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
 
 );
 
@@ -329,13 +314,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
-		unsigned long nr_lumpy_taken,
-		unsigned long nr_lumpy_dirty,
-		unsigned long nr_lumpy_failed,
 		isolate_mode_t isolate_mode,
 		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
 
 );
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33c332b..68319e4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -56,19 +56,11 @@
 /*
  * reclaim_mode determines how the inactive list is shrunk
  * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
- * RECLAIM_MODE_ASYNC:  Do not block
- * RECLAIM_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
- * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference
- *			page from the LRU and reclaim all pages within a
- *			naturally aligned range
  * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number of
  *			order-0 pages and then compact the zone
  */
 typedef unsigned __bitwise__ reclaim_mode_t;
 #define RECLAIM_MODE_SINGLE		((__force reclaim_mode_t)0x01u)
-#define RECLAIM_MODE_ASYNC		((__force reclaim_mode_t)0x02u)
-#define RECLAIM_MODE_SYNC		((__force reclaim_mode_t)0x04u)
-#define RECLAIM_MODE_LUMPYRECLAIM	((__force reclaim_mode_t)0x08u)
 #define RECLAIM_MODE_COMPACTION		((__force reclaim_mode_t)0x10u)
 
 struct scan_control {
@@ -364,37 +356,23 @@ out:
 	return ret;
 }
 
-static void set_reclaim_mode(int priority, struct scan_control *sc,
-				   bool sync)
+static void set_reclaim_mode(int priority, struct scan_control *sc)
 {
-	reclaim_mode_t syncmode = sync ? RECLAIM_MODE_SYNC : RECLAIM_MODE_ASYNC;
-
 	/*
-	 * Initially assume we are entering either lumpy reclaim or
-	 * reclaim/compaction.Depending on the order, we will either set the
-	 * sync mode or just reclaim order-0 pages later.
-	 */
-	if (COMPACTION_BUILD)
-		sc->reclaim_mode = RECLAIM_MODE_COMPACTION;
-	else
-		sc->reclaim_mode = RECLAIM_MODE_LUMPYRECLAIM;
-
-	/*
-	 * Avoid using lumpy reclaim or reclaim/compaction if possible by
-	 * restricting when its set to either costly allocations or when
+	 * Restrict reclaim/compaction to costly allocations or when
 	 * under memory pressure
 	 */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		sc->reclaim_mode |= syncmode;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
-		sc->reclaim_mode |= syncmode;
+	if (COMPACTION_BUILD && sc->order &&
+			(sc->order > PAGE_ALLOC_COSTLY_ORDER ||
+			 priority < DEF_PRIORITY - 2))
+		sc->reclaim_mode = RECLAIM_MODE_COMPACTION;
 	else
-		sc->reclaim_mode = RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;
+		sc->reclaim_mode = RECLAIM_MODE_SINGLE;
 }
 
 static void reset_reclaim_mode(struct scan_control *sc)
 {
-	sc->reclaim_mode = RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;
+	sc->reclaim_mode = RECLAIM_MODE_SINGLE;
 }
 
 static inline int is_page_cache_freeable(struct page *page)
@@ -416,10 +394,6 @@ static int may_write_to_queue(struct backing_dev_info *bdi,
 		return 1;
 	if (bdi == current->backing_dev_info)
 		return 1;
-
-	/* lumpy reclaim for hugepage often need a lot of write */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		return 1;
 	return 0;
 }
 
@@ -710,10 +684,6 @@ static enum page_references page_check_references(struct page *page,
 	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
 
-	/* Lumpy reclaim - ignore references */
-	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
-		return PAGEREF_RECLAIM;
-
 	/*
 	 * Mlock lost the isolation race with us.  Let try_to_unmap()
 	 * move the page to the unevictable list.
@@ -813,19 +783,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		if (PageWriteback(page)) {
 			nr_writeback++;
-			/*
-			 * Synchronous reclaim cannot queue pages for
-			 * writeback due to the possibility of stack overflow
-			 * but if it encounters a page under writeback, wait
-			 * for the IO to complete.
-			 */
-			if ((sc->reclaim_mode & RECLAIM_MODE_SYNC) &&
-			    may_enter_fs)
-				wait_on_page_writeback(page);
-			else {
-				unlock_page(page);
-				goto keep_lumpy;
-			}
+			unlock_page(page);
+			goto keep;
 		}
 
 		references = page_check_references(page, mz, sc);
@@ -908,7 +867,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto activate_locked;
 			case PAGE_SUCCESS:
 				if (PageWriteback(page))
-					goto keep_lumpy;
+					goto keep;
 				if (PageDirty(page))
 					goto keep;
 
@@ -1007,8 +966,6 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		reset_reclaim_mode(sc);
-keep_lumpy:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
@@ -1064,11 +1021,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 	if (!all_lru_mode && !!page_is_file_cache(page) != file)
 		return ret;
 
-	/*
-	 * When this function is being called for lumpy reclaim, we
-	 * initially look into all LRU pages, active, inactive and
-	 * unevictable; only give shrink_page_list evictable pages.
-	 */
+	/* Do not give back unevictable pages for compaction */
 	if (PageUnevictable(page))
 		return ret;
 
@@ -1153,9 +1106,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	struct lruvec *lruvec;
 	struct list_head *src;
 	unsigned long nr_taken = 0;
-	unsigned long nr_lumpy_taken = 0;
-	unsigned long nr_lumpy_dirty = 0;
-	unsigned long nr_lumpy_failed = 0;
 	unsigned long scan;
 	int lru = LRU_BASE;
 
@@ -1168,10 +1118,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
-		unsigned long pfn;
-		unsigned long end_pfn;
-		unsigned long page_pfn;
-		int zone_id;
 
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -1193,84 +1139,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		default:
 			BUG();
 		}
-
-		if (!sc->order || !(sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM))
-			continue;
-
-		/*
-		 * Attempt to take all pages in the order aligned region
-		 * surrounding the tag page.  Only take those pages of
-		 * the same active state as that tag page.  We may safely
-		 * round the target page pfn down to the requested order
-		 * as the mem_map is guaranteed valid out to MAX_ORDER,
-		 * where that page is in a different zone we will detect
-		 * it from its zone id and abort this block scan.
-		 */
-		zone_id = page_zone_id(page);
-		page_pfn = page_to_pfn(page);
-		pfn = page_pfn & ~((1 << sc->order) - 1);
-		end_pfn = pfn + (1 << sc->order);
-		for (; pfn < end_pfn; pfn++) {
-			struct page *cursor_page;
-
-			/* The target page is in the block, ignore it. */
-			if (unlikely(pfn == page_pfn))
-				continue;
-
-			/* Avoid holes within the zone. */
-			if (unlikely(!pfn_valid_within(pfn)))
-				break;
-
-			cursor_page = pfn_to_page(pfn);
-
-			/* Check that we have not crossed a zone boundary. */
-			if (unlikely(page_zone_id(cursor_page) != zone_id))
-				break;
-
-			/*
-			 * If we don't have enough swap space, reclaiming of
-			 * anon page which don't already have a swap slot is
-			 * pointless.
-			 */
-			if (nr_swap_pages <= 0 && PageSwapBacked(cursor_page) &&
-			    !PageSwapCache(cursor_page))
-				break;
-
-			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				unsigned int isolated_pages;
-
-				mem_cgroup_lru_del(cursor_page);
-				list_move(&cursor_page->lru, dst);
-				isolated_pages = hpage_nr_pages(cursor_page);
-				nr_taken += isolated_pages;
-				nr_lumpy_taken += isolated_pages;
-				if (PageDirty(cursor_page))
-					nr_lumpy_dirty += isolated_pages;
-				scan++;
-				pfn += isolated_pages - 1;
-			} else {
-				/*
-				 * Check if the page is freed already.
-				 *
-				 * We can't use page_count() as that
-				 * requires compound_head and we don't
-				 * have a pin on the page here. If a
-				 * page is tail, we may or may not
-				 * have isolated the head, so assume
-				 * it's not free, it'd be tricky to
-				 * track the head status without a
-				 * page pin.
-				 */
-				if (!PageTail(cursor_page) &&
-				    !atomic_read(&cursor_page->_count))
-					continue;
-				break;
-			}
-		}
-
-		/* If we break out of the loop above, lumpy reclaim failed */
-		if (pfn < end_pfn)
-			nr_lumpy_failed++;
 	}
 
 	*nr_scanned = scan;
@@ -1278,7 +1146,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	trace_mm_vmscan_lru_isolate(sc->order,
 			nr_to_scan, scan,
 			nr_taken,
-			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
 			mode, file);
 	return nr_taken;
 }
@@ -1454,47 +1321,6 @@ update_isolated_counts(struct mem_cgroup_zone *mz,
 }
 
 /*
- * Returns true if a direct reclaim should wait on pages under writeback.
- *
- * If we are direct reclaiming for contiguous pages and we do not reclaim
- * everything in the list, try again and wait for writeback IO to complete.
- * This will stall high-order allocations noticeably. Only do that when really
- * need to free the pages under high memory pressure.
- */
-static inline bool should_reclaim_stall(unsigned long nr_taken,
-					unsigned long nr_freed,
-					int priority,
-					struct scan_control *sc)
-{
-	int lumpy_stall_priority;
-
-	/* kswapd should not stall on sync IO */
-	if (current_is_kswapd())
-		return false;
-
-	/* Only stall on lumpy reclaim */
-	if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
-		return false;
-
-	/* If we have reclaimed everything on the isolated list, no stall */
-	if (nr_freed == nr_taken)
-		return false;
-
-	/*
-	 * For high-order allocations, there are two stall thresholds.
-	 * High-cost allocations stall immediately where as lower
-	 * order allocations such as stacks require the scanning
-	 * priority to be much higher before stalling.
-	 */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		lumpy_stall_priority = DEF_PRIORITY;
-	else
-		lumpy_stall_priority = DEF_PRIORITY / 3;
-
-	return priority <= lumpy_stall_priority;
-}
-
-/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
@@ -1522,9 +1348,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 			return SWAP_CLUSTER_MAX;
 	}
 
-	set_reclaim_mode(priority, sc, false);
-	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
-		isolate_mode |= ISOLATE_ACTIVE;
+	set_reclaim_mode(priority, sc);
 
 	lru_add_drain();
 
@@ -1556,13 +1380,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
 						&nr_dirty, &nr_writeback);
 
-	/* Check if we should syncronously wait for writeback */
-	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
-		set_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
-					priority, &nr_dirty, &nr_writeback);
-	}
-
 	spin_lock_irq(&zone->lru_lock);
 
 	reclaim_stat->recent_scanned[0] += nr_anon;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
