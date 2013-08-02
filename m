Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B94666B003D
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:06:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 9/9] mm: zone_reclaim: compaction: add compaction to zone_reclaim_mode
Date: Fri,  2 Aug 2013 18:06:36 +0200
Message-Id: <1375459596-30061-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

This adds compaction to zone_reclaim so THP enabled won't decrease the
NUMA locality with /proc/sys/vm/zone_reclaim_mode > 0.

It is important to boot with numa_zonelist_order=n (n means nodes) to
get more accurate NUMA locality if there are multiple zones per node.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/swap.h |   8 +++-
 mm/page_alloc.c      |   4 +-
 mm/vmscan.c          | 111 ++++++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 102 insertions(+), 21 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d95cde5..d076a54 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -289,10 +289,14 @@ extern unsigned long vm_total_pages;
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
-extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
+extern int zone_reclaim(struct zone *, struct zone *, gfp_t, unsigned int,
+			unsigned long, int, int);
 #else
 #define zone_reclaim_mode 0
-static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
+static inline int zone_reclaim(struct zone *preferred_zone, struct zone *zone,
+			       gfp_t mask, unsigned int order,
+			       unsigned long mark, int classzone_idx,
+			       int alloc_flags)
 {
 	return 0;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 879a3fd..c0bdde6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1982,7 +1982,9 @@ zonelist_scan:
 				!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 
-			ret = zone_reclaim(zone, gfp_mask, order);
+			ret = zone_reclaim(preferred_zone, zone, gfp_mask,
+					   order,
+					   mark, classzone_idx, alloc_flags);
 			switch (ret) {
 			case ZONE_RECLAIM_NOSCAN:
 				/* did not scan */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f2ada36..f28dc00 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3488,6 +3488,24 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	unsigned long nr_slab_pages0, nr_slab_pages1;
 
 	cond_resched();
+
+	/*
+	 * Zone reclaim reclaims unmapped file backed pages and
+	 * slab pages if we are over the defined limits.
+	 *
+	 * A small portion of unmapped file backed pages is needed for
+	 * file I/O otherwise pages read by file I/O will be immediately
+	 * thrown out if the zone is overallocated. So we do not reclaim
+	 * if less than a specified percentage of the zone is used by
+	 * unmapped file backed pages.
+	 */
+	if (zone_pagecache_reclaimable(zone) <= zone->min_unmapped_pages &&
+	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
+		return ZONE_RECLAIM_FULL;
+
+	if (zone->all_unreclaimable)
+		return ZONE_RECLAIM_FULL;
+
 	/*
 	 * We need to be able to allocate from the reserves for RECLAIM_SWAP
 	 * and we also need to be able to write out pages for RECLAIM_WRITE
@@ -3549,27 +3567,35 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	return sc.nr_reclaimed >= nr_pages;
 }
 
-int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
+static int zone_reclaim_compact(struct zone *preferred_zone,
+				struct zone *zone, gfp_t gfp_mask,
+				unsigned int order,
+				bool sync_compaction,
+				bool *need_compaction)
 {
-	int node_id;
-	int ret;
+	bool contended;
 
-	/*
-	 * Zone reclaim reclaims unmapped file backed pages and
-	 * slab pages if we are over the defined limits.
-	 *
-	 * A small portion of unmapped file backed pages is needed for
-	 * file I/O otherwise pages read by file I/O will be immediately
-	 * thrown out if the zone is overallocated. So we do not reclaim
-	 * if less than a specified percentage of the zone is used by
-	 * unmapped file backed pages.
-	 */
-	if (zone_pagecache_reclaimable(zone) <= zone->min_unmapped_pages &&
-	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
-		return ZONE_RECLAIM_FULL;
+	if (compaction_deferred(preferred_zone, order) ||
+	    !order ||
+	    (gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO)) {
+		need_compaction = false;
+		return COMPACT_SKIPPED;
+	}
 
-	if (zone->all_unreclaimable)
-		return ZONE_RECLAIM_FULL;
+	*need_compaction = true;
+	return compact_zone_order(zone, order,
+				  gfp_mask,
+				  sync_compaction,
+				  &contended);
+}
+
+int zone_reclaim(struct zone *preferred_zone, struct zone *zone,
+		 gfp_t gfp_mask, unsigned int order,
+		 unsigned long mark, int classzone_idx, int alloc_flags)
+{
+	int node_id;
+	int ret, c_ret;
+	bool sync_compaction = false, need_compaction = false;
 
 	/*
 	 * Do not scan if the allocation should not be delayed.
@@ -3587,7 +3613,56 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
 		return ZONE_RECLAIM_NOSCAN;
 
+repeat_compaction:
+	/*
+	 * If this allocation may be satisfied by memory compaction,
+	 * run compaction before reclaim.
+	 */
+	c_ret = zone_reclaim_compact(preferred_zone,
+				     zone, gfp_mask, order,
+				     sync_compaction,
+				     &need_compaction);
+	if (need_compaction &&
+	    c_ret != COMPACT_SKIPPED &&
+	    zone_watermark_ok(zone, order, mark,
+			      classzone_idx,
+			      alloc_flags)) {
+#ifdef CONFIG_COMPACTION
+		zone->compact_considered = 0;
+		zone->compact_defer_shift = 0;
+#endif
+		return ZONE_RECLAIM_SUCCESS;
+	}
+
+	/*
+	 * reclaim if compaction failed because not enough memory was
+	 * available or if compaction didn't run (order 0) or didn't
+	 * succeed.
+	 */
 	ret = __zone_reclaim(zone, gfp_mask, order);
+	if (ret == ZONE_RECLAIM_SUCCESS) {
+		if (zone_watermark_ok(zone, order, mark,
+				      classzone_idx,
+				      alloc_flags))
+			return ZONE_RECLAIM_SUCCESS;
+
+		/*
+		 * If compaction run but it was skipped and reclaim was
+		 * successful keep going.
+		 */
+		if (need_compaction && c_ret == COMPACT_SKIPPED) {
+			/*
+			 * If it's ok to wait for I/O we can as well run sync
+			 * compaction
+			 */
+			sync_compaction = !!(zone_reclaim_mode &
+					     (RECLAIM_WRITE|RECLAIM_SWAP));
+			cond_resched();
+			goto repeat_compaction;
+		}
+	}
+	if (need_compaction)
+		defer_compaction(preferred_zone, order);
 
 	if (!ret)
 		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
