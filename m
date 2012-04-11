Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id CB4326B0083
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 12:38:23 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] mm: vmscan: Do not stall on writeback during memory compaction
Date: Wed, 11 Apr 2012 17:38:17 +0100
Message-Id: <1334162298-18942-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1334162298-18942-1-git-send-email-mgorman@suse.de>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch stops reclaim/compaction entering sync reclaim as this was only
intended for lumpy reclaim and an oversight. Page migration has its own
logic for stalling on writeback pages if necessary and memory compaction
is already using it.

Waiting on page writeback is bad for a number of reasons but the primary
one is that waiting on writeback to a slow device like USB can take a
considerable length of time. Page reclaim instead uses wait_iff_congested()
to throttle if too many dirty pages are being scanned.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/vmscan.h |   10 ++---
 mm/vmscan.c                   |   85 ++++-------------------------------------
 2 files changed, 13 insertions(+), 82 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 1c20a1f..044e8ba 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -13,7 +13,7 @@
 #define RECLAIM_WB_ANON		0x0001u
 #define RECLAIM_WB_FILE		0x0002u
 #define RECLAIM_WB_MIXED	0x0010u
-#define RECLAIM_WB_SYNC		0x0004u
+#define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim async */
 #define RECLAIM_WB_ASYNC	0x0008u
 
 #define show_reclaim_flags(flags)				\
@@ -27,13 +27,13 @@
 
 #define trace_reclaim_flags(page, sync) ( \
 	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
+	(RECLAIM_WB_ASYNC) \
 	)
 
 #define trace_shrink_flags(file, sync) ( \
-	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_MIXED : \
-			(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON)) |  \
-	(sync & RECLAIM_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
+	( \
+		(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
+		(RECLAIM_WB_ASYNC) \
 	)
 
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a4b86bd..68319e4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -56,15 +56,11 @@
 /*
  * reclaim_mode determines how the inactive list is shrunk
  * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
- * RECLAIM_MODE_ASYNC:  Do not block
- * RECLAIM_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
  * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number of
  *			order-0 pages and then compact the zone
  */
 typedef unsigned __bitwise__ reclaim_mode_t;
 #define RECLAIM_MODE_SINGLE		((__force reclaim_mode_t)0x01u)
-#define RECLAIM_MODE_ASYNC		((__force reclaim_mode_t)0x02u)
-#define RECLAIM_MODE_SYNC		((__force reclaim_mode_t)0x04u)
 #define RECLAIM_MODE_COMPACTION		((__force reclaim_mode_t)0x10u)
 
 struct scan_control {
@@ -360,12 +356,8 @@ out:
 	return ret;
 }
 
-static void set_reclaim_mode(int priority, struct scan_control *sc,
-				   bool sync)
+static void set_reclaim_mode(int priority, struct scan_control *sc)
 {
-	/* Sync reclaim used only for compaction */
-	reclaim_mode_t syncmode = sync ? RECLAIM_MODE_SYNC : RECLAIM_MODE_ASYNC;
-
 	/*
 	 * Restrict reclaim/compaction to costly allocations or when
 	 * under memory pressure
@@ -373,14 +365,14 @@ static void set_reclaim_mode(int priority, struct scan_control *sc,
 	if (COMPACTION_BUILD && sc->order &&
 			(sc->order > PAGE_ALLOC_COSTLY_ORDER ||
 			 priority < DEF_PRIORITY - 2))
-		sc->reclaim_mode = RECLAIM_MODE_COMPACTION | syncmode;
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
@@ -791,19 +783,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
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
-				goto keep_reclaim_mode;
-			}
+			unlock_page(page);
+			goto keep;
 		}
 
 		references = page_check_references(page, mz, sc);
@@ -886,7 +867,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto activate_locked;
 			case PAGE_SUCCESS:
 				if (PageWriteback(page))
-					goto keep_reclaim_mode;
+					goto keep;
 				if (PageDirty(page))
 					goto keep;
 
@@ -985,8 +966,6 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		reset_reclaim_mode(sc);
-keep_reclaim_mode:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
@@ -1342,47 +1321,6 @@ update_isolated_counts(struct mem_cgroup_zone *mz,
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
-	int stall_priority;
-
-	/* kswapd should not stall on sync IO */
-	if (current_is_kswapd())
-		return false;
-
-	/* Only stall for memory compaction */
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
-		stall_priority = DEF_PRIORITY;
-	else
-		stall_priority = DEF_PRIORITY / 3;
-
-	return priority <= stall_priority;
-}
-
-/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
@@ -1410,7 +1348,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 			return SWAP_CLUSTER_MAX;
 	}
 
-	set_reclaim_mode(priority, sc, false);
+	set_reclaim_mode(priority, sc);
 
 	lru_add_drain();
 
@@ -1442,13 +1380,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
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
