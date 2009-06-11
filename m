Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AD55C6B0087
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:46:31 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/3] Do not unconditionally treat zones that fail zone_reclaim() as full
Date: Thu, 11 Jun 2009 11:47:52 +0100
Message-Id: <1244717273-15176-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1244717273-15176-1-git-send-email-mel@csn.ul.ie>
References: <1244717273-15176-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On NUMA machines, the administrator can configure zone_reclaim_mode that
is a more targetted form of direct reclaim. On machines with large NUMA
distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
unmapped pages will be reclaimed if the zone watermarks are not being
met. The problem is that zone_reclaim() failing at all means the zone
gets marked full.

This can cause situations where a zone is usable, but is being skipped
because it has been considered full. Take a situation where a large tmpfs
mount is occuping a large percentage of memory overall. The pages do not
get cleaned or reclaimed by zone_reclaim(), but the zone gets marked full
and the zonelist cache considers them not worth trying in the future.

This patch makes zone_reclaim() return more fine-grained information about
what occured when zone_reclaim() failued. The zone only gets marked full if
it really is unreclaimable. If it's a case that the scan did not occur or
if enough pages were not reclaimed with the limited reclaim_mode, then the
zone is simply skipped.

There is a side-effect to this patch. Currently, if zone_reclaim()
successfully reclaimed SWAP_CLUSTER_MAX, an allocation attempt would
go ahead. With this patch applied, zone watermarks are rechecked after
zone_reclaim() does some work.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/internal.h   |    4 ++++
 mm/page_alloc.c |   26 ++++++++++++++++++++++----
 mm/vmscan.c     |   11 ++++++-----
 3 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index f02c750..f290c4d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -259,4 +259,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, int flags,
 		     struct page **pages, struct vm_area_struct **vmas);
 
+#define ZONE_RECLAIM_NOSCAN	-2
+#define ZONE_RECLAIM_FULL	-1
+#define ZONE_RECLAIM_SOME	0
+#define ZONE_RECLAIM_SUCCESS	1
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d35e753..667ffbb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1477,15 +1477,33 @@ zonelist_scan:
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
+			int ret;
+
 			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
-			if (!zone_watermark_ok(zone, order, mark,
-				    classzone_idx, alloc_flags)) {
-				if (!zone_reclaim_mode ||
-				    !zone_reclaim(zone, gfp_mask, order))
+			if (zone_watermark_ok(zone, order, mark,
+				    classzone_idx, alloc_flags))
+				goto try_this_zone;
+
+			if (zone_reclaim_mode == 0)
+				goto this_zone_full;
+
+			ret = zone_reclaim(zone, gfp_mask, order);
+			switch (ret) {
+			case ZONE_RECLAIM_NOSCAN:
+				/* did not scan */
+				goto try_next_zone;
+			case ZONE_RECLAIM_FULL:
+				/* scanned but unreclaimable */
+				goto this_zone_full;
+			default:
+				/* did we reclaim enough */
+				if (!zone_watermark_ok(zone, order, mark,
+						classzone_idx, alloc_flags))
 					goto this_zone_full;
 			}
 		}
 
+try_this_zone:
 		page = buffered_rmqueue(preferred_zone, zone, order,
 						gfp_mask, migratetype);
 		if (page)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d832ba8..7b8eb3f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2465,16 +2465,16 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 */
 	if (zone_pagecache_reclaimable(zone) <= zone->min_unmapped_pages &&
 	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
-		return 0;
+		return ZONE_RECLAIM_FULL;
 
 	if (zone_is_all_unreclaimable(zone))
-		return 0;
+		return ZONE_RECLAIM_FULL;
 
 	/*
 	 * Do not scan if the allocation should not be delayed.
 	 */
 	if (!(gfp_mask & __GFP_WAIT) || (current->flags & PF_MEMALLOC))
-			return 0;
+		return ZONE_RECLAIM_NOSCAN;
 
 	/*
 	 * Only run zone reclaim on the local zone or on zones that do not
@@ -2484,10 +2484,11 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 */
 	node_id = zone_to_nid(zone);
 	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
-		return 0;
+		return ZONE_RECLAIM_NOSCAN;
 
 	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
-		return 0;
+		return ZONE_RECLAIM_NOSCAN;
+
 	ret = __zone_reclaim(zone, gfp_mask, order);
 	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
