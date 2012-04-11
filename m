Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A384D6B007E
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 12:38:24 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm: vmscan: Remove reclaim_mode_t
Date: Wed, 11 Apr 2012 17:38:18 +0100
Message-Id: <1334162298-18942-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1334162298-18942-1-git-send-email-mgorman@suse.de>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

There is little motiviation for reclaim_mode_t once RECLAIM_MODE_[A]SYNC
and lumpy reclaim have been removed. This patch gets rid of reclaim_mode_t
as well and improves the documentation about what reclaim/compaction is
and when it is triggered.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/vmscan.h |    4 +--
 mm/vmscan.c                   |   72 +++++++++++++----------------------------
 2 files changed, 24 insertions(+), 52 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 044e8ba..0794aa2 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -25,12 +25,12 @@
 		{RECLAIM_WB_ASYNC,	"RECLAIM_WB_ASYNC"}	\
 		) : "RECLAIM_WB_NONE"
 
-#define trace_reclaim_flags(page, sync) ( \
+#define trace_reclaim_flags(page) ( \
 	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
 	(RECLAIM_WB_ASYNC) \
 	)
 
-#define trace_shrink_flags(file, sync) ( \
+#define trace_shrink_flags(file) \
 	( \
 		(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
 		(RECLAIM_WB_ASYNC) \
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 68319e4..36c6ad2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -53,16 +53,6 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
-/*
- * reclaim_mode determines how the inactive list is shrunk
- * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
- * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number of
- *			order-0 pages and then compact the zone
- */
-typedef unsigned __bitwise__ reclaim_mode_t;
-#define RECLAIM_MODE_SINGLE		((__force reclaim_mode_t)0x01u)
-#define RECLAIM_MODE_COMPACTION		((__force reclaim_mode_t)0x10u)
-
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
@@ -89,12 +79,6 @@ struct scan_control {
 	int order;
 
 	/*
-	 * Intend to reclaim enough continuous memory rather than reclaim
-	 * enough amount of memory. i.e, mode for high order allocation.
-	 */
-	reclaim_mode_t reclaim_mode;
-
-	/*
 	 * The memory cgroup that hit its limit and as a result is the
 	 * primary target of this reclaim invocation.
 	 */
@@ -356,25 +340,6 @@ out:
 	return ret;
 }
 
-static void set_reclaim_mode(int priority, struct scan_control *sc)
-{
-	/*
-	 * Restrict reclaim/compaction to costly allocations or when
-	 * under memory pressure
-	 */
-	if (COMPACTION_BUILD && sc->order &&
-			(sc->order > PAGE_ALLOC_COSTLY_ORDER ||
-			 priority < DEF_PRIORITY - 2))
-		sc->reclaim_mode = RECLAIM_MODE_COMPACTION;
-	else
-		sc->reclaim_mode = RECLAIM_MODE_SINGLE;
-}
-
-static void reset_reclaim_mode(struct scan_control *sc)
-{
-	sc->reclaim_mode = RECLAIM_MODE_SINGLE;
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	/*
@@ -497,8 +462,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
 		}
-		trace_mm_vmscan_writepage(page,
-			trace_reclaim_flags(page, sc->reclaim_mode));
+		trace_mm_vmscan_writepage(page, trace_reclaim_flags(page));
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
@@ -953,7 +917,6 @@ cull_mlocked:
 			try_to_free_swap(page);
 		unlock_page(page);
 		putback_lru_page(page);
-		reset_reclaim_mode(sc);
 		continue;
 
 activate_locked:
@@ -1348,8 +1311,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 			return SWAP_CLUSTER_MAX;
 	}
 
-	set_reclaim_mode(priority, sc);
-
 	lru_add_drain();
 
 	if (!sc->may_unmap)
@@ -1428,7 +1389,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
 		priority,
-		trace_shrink_flags(file, sc->reclaim_mode));
+		trace_shrink_flags(file));
 	return nr_reclaimed;
 }
 
@@ -1507,8 +1468,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	lru_add_drain();
 
-	reset_reclaim_mode(sc);
-
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)
@@ -1821,23 +1780,35 @@ out:
 	}
 }
 
+/* Use reclaim/compaction for costly allocs or under memory pressure */
+static bool in_reclaim_compaction(int priority, struct scan_control *sc)
+{
+	if (COMPACTION_BUILD && sc->order &&
+			(sc->order > PAGE_ALLOC_COSTLY_ORDER ||
+			 priority < DEF_PRIORITY - 2))
+		return true;
+
+	return false;
+}
+
 /*
- * Reclaim/compaction depends on a number of pages being freed. To avoid
- * disruption to the system, a small number of order-0 pages continue to be
- * rotated and reclaimed in the normal fashion. However, by the time we get
- * back to the allocator and call try_to_compact_zone(), we ensure that
- * there are enough free pages for it to be likely successful
+ * Reclaim/compaction is used for high-order allocation requests. It reclaims
+ * order-0 pages before compacting the zone. should_continue_reclaim() returns
+ * true if more pages should be reclaimed such that when the page allocator
+ * calls try_to_compact_zone() that it will have enough free pages to succeed.
+ * It will give up earlier than that if there is difficulty reclaiming pages.
  */
 static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
+					int priority,
 					struct scan_control *sc)
 {
 	unsigned long pages_for_compaction;
 	unsigned long inactive_lru_pages;
 
 	/* If not in reclaim/compaction mode, stop */
-	if (!(sc->reclaim_mode & RECLAIM_MODE_COMPACTION))
+	if (!in_reclaim_compaction(priority, sc))
 		return false;
 
 	/* Consider stopping depending on scan and reclaim activity */
@@ -1944,7 +1915,8 @@ restart:
 
 	/* reclaim/compaction might need reclaim to continue */
 	if (should_continue_reclaim(mz, nr_reclaimed,
-					sc->nr_scanned - nr_scanned, sc))
+					sc->nr_scanned - nr_scanned,
+					priority, sc))
 		goto restart;
 
 	throttle_vm_writeout(sc->gfp_mask);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
