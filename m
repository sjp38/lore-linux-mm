Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 869166B026B
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:09:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l6so13230086wml.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:09:29 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id g206si10937433wmg.32.2016.04.15.02.09.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:09:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id E205BCF55
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:09:27 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 21/28] mm, page_alloc: Avoid looking up the first zone in a zonelist twice
Date: Fri, 15 Apr 2016 10:07:48 +0100
Message-Id: <1460711275-1130-9-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The allocator fast path looks up the first usable zone in a zonelist
and then get_page_from_freelist does the same job in the zonelist
iterator. This patch preserves the necessary information.

                                           4.6.0-rc2                  4.6.0-rc2
                                      fastmark-v1r20             initonce-v1r20
Min      alloc-odr0-1               364.00 (  0.00%)           359.00 (  1.37%)
Min      alloc-odr0-2               262.00 (  0.00%)           260.00 (  0.76%)
Min      alloc-odr0-4               214.00 (  0.00%)           214.00 (  0.00%)
Min      alloc-odr0-8               186.00 (  0.00%)           186.00 (  0.00%)
Min      alloc-odr0-16              173.00 (  0.00%)           173.00 (  0.00%)
Min      alloc-odr0-32              165.00 (  0.00%)           165.00 (  0.00%)
Min      alloc-odr0-64              161.00 (  0.00%)           162.00 ( -0.62%)
Min      alloc-odr0-128             159.00 (  0.00%)           161.00 ( -1.26%)
Min      alloc-odr0-256             168.00 (  0.00%)           170.00 ( -1.19%)
Min      alloc-odr0-512             180.00 (  0.00%)           181.00 ( -0.56%)
Min      alloc-odr0-1024            190.00 (  0.00%)           190.00 (  0.00%)
Min      alloc-odr0-2048            196.00 (  0.00%)           196.00 (  0.00%)
Min      alloc-odr0-4096            202.00 (  0.00%)           202.00 (  0.00%)
Min      alloc-odr0-8192            206.00 (  0.00%)           205.00 (  0.49%)
Min      alloc-odr0-16384           206.00 (  0.00%)           205.00 (  0.49%)

The benefit is negligible and the results are within the noise but each
cycle counts.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 fs/buffer.c            | 10 +++++-----
 include/linux/mmzone.h | 18 +++++++++++-------
 mm/internal.h          |  2 +-
 mm/mempolicy.c         | 19 ++++++++++---------
 mm/page_alloc.c        | 32 +++++++++++++++-----------------
 5 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index af0d9a82a8ed..754813a6962b 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -255,17 +255,17 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
  */
 static void free_more_memory(void)
 {
-	struct zone *zone;
+	struct zoneref *z;
 	int nid;
 
 	wakeup_flusher_threads(1024, WB_REASON_FREE_MORE_MEM);
 	yield();
 
 	for_each_online_node(nid) {
-		(void)first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
-						gfp_zone(GFP_NOFS), NULL,
-						&zone);
-		if (zone)
+
+		z = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+						gfp_zone(GFP_NOFS), NULL);
+		if (z->zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
 						GFP_NOFS, NULL);
 	}
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f49bb9add372..bf153ed097d5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -962,13 +962,10 @@ static __always_inline struct zoneref *next_zones_zonelist(struct zoneref *z,
  */
 static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx,
-					nodemask_t *nodes,
-					struct zone **zone)
+					nodemask_t *nodes)
 {
-	struct zoneref *z = next_zones_zonelist(zonelist->_zonerefs,
+	return next_zones_zonelist(zonelist->_zonerefs,
 							highest_zoneidx, nodes);
-	*zone = zonelist_zone(z);
-	return z;
 }
 
 /**
@@ -983,10 +980,17 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
  * within a given nodemask
  */
 #define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
-	for (z = first_zones_zonelist(zlist, highidx, nodemask, &zone);	\
+	for (z = first_zones_zonelist(zlist, highidx, nodemask), zone = zonelist_zone(z);	\
 		zone;							\
 		z = next_zones_zonelist(++z, highidx, nodemask),	\
-			zone = zonelist_zone(z))			\
+			zone = zonelist_zone(z))
+
+#define for_next_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
+	for (zone = z->zone;	\
+		zone;							\
+		z = next_zones_zonelist(++z, highidx, nodemask),	\
+			zone = zonelist_zone(z))
+
 
 /**
  * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
diff --git a/mm/internal.h b/mm/internal.h
index f6d0a5875ec4..4c2396cd514c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -102,7 +102,7 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
 struct alloc_context {
 	struct zonelist *zonelist;
 	nodemask_t *nodemask;
-	struct zone *preferred_zone;
+	struct zoneref *preferred_zoneref;
 	int classzone_idx;
 	int migratetype;
 	enum zone_type high_zoneidx;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 36cc01bc950a..66d73efba370 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1744,18 +1744,18 @@ unsigned int mempolicy_slab_node(void)
 		return interleave_nodes(policy);
 
 	case MPOL_BIND: {
+		struct zoneref *z;
+
 		/*
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
 		struct zonelist *zonelist;
-		struct zone *zone;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
 		zonelist = &NODE_DATA(node)->node_zonelists[0];
-		(void)first_zones_zonelist(zonelist, highest_zoneidx,
-							&policy->v.nodes,
-							&zone);
-		return zone ? zone->node : node;
+		z = first_zones_zonelist(zonelist, highest_zoneidx,
+							&policy->v.nodes);
+		return z->zone ? z->zone->node : node;
 	}
 
 	default:
@@ -2284,7 +2284,7 @@ static void sp_free(struct sp_node *n)
 int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol;
-	struct zone *zone;
+	struct zoneref *z;
 	int curnid = page_to_nid(page);
 	unsigned long pgoff;
 	int thiscpu = raw_smp_processor_id();
@@ -2316,6 +2316,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		break;
 
 	case MPOL_BIND:
+
 		/*
 		 * allows binding to multiple nodes.
 		 * use current page if in policy nodemask,
@@ -2324,11 +2325,11 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 */
 		if (node_isset(curnid, pol->v.nodes))
 			goto out;
-		(void)first_zones_zonelist(
+		z = first_zones_zonelist(
 				node_zonelist(numa_node_id(), GFP_HIGHUSER),
 				gfp_zone(GFP_HIGHUSER),
-				&pol->v.nodes, &zone);
-		polnid = zone->node;
+				&pol->v.nodes);
+		polnid = z->zone->node;
 		break;
 
 	default:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8923d74b1707..897e9d2a8500 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2700,7 +2700,7 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
-	struct zoneref *z;
+	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
 	bool fair_skipped = false;
 	bool apply_fair = (alloc_flags & ALLOC_FAIR);
@@ -2710,7 +2710,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
+	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		struct page *page;
 		unsigned long mark;
@@ -2730,7 +2730,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				fair_skipped = true;
 				continue;
 			}
-			if (!zone_local(ac->preferred_zone, zone)) {
+			if (!zone_local(ac->preferred_zoneref->zone, zone)) {
 				if (fair_skipped)
 					goto reset_fair;
 				apply_fair = false;
@@ -2776,7 +2776,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				goto try_this_zone;
 
 			if (zone_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(ac->preferred_zone, zone))
+			    !zone_allows_reclaim(ac->preferred_zoneref->zone, zone))
 				continue;
 
 			ret = zone_reclaim(zone, gfp_mask, order);
@@ -2798,7 +2798,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(ac->preferred_zone, zone, order,
+		page = buffered_rmqueue(ac->preferred_zoneref->zone, zone, order,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
 			if (prep_new_page(page, order, gfp_mask, alloc_flags))
@@ -2827,7 +2827,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 reset_fair:
 		apply_fair = false;
 		fair_skipped = false;
-		reset_alloc_batches(ac->preferred_zone);
+		reset_alloc_batches(ac->preferred_zoneref->zone);
 		goto zonelist_scan;
 	}
 
@@ -3114,7 +3114,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 						ac->high_zoneidx, ac->nodemask)
-		wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone));
+		wakeup_kswapd(zone, order, zonelist_zone_idx(ac->preferred_zoneref));
 }
 
 static inline unsigned int
@@ -3334,7 +3334,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
 	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(ac->preferred_zoneref->zone, BLK_RW_ASYNC, HZ/50);
 		goto retry;
 	}
 
@@ -3372,7 +3372,6 @@ struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
-	struct zoneref *preferred_zoneref;
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
@@ -3408,9 +3407,9 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
 	/* The preferred zone is used for statistics later */
-	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
-				ac.nodemask, &ac.preferred_zone);
-	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
+	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
+				ac.nodemask);
+	ac.classzone_idx = zonelist_zone_idx(ac.preferred_zoneref);
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
@@ -4439,13 +4438,12 @@ static void build_zonelists(pg_data_t *pgdat)
  */
 int local_memory_node(int node)
 {
-	struct zone *zone;
+	struct zoneref *z;
 
-	(void)first_zones_zonelist(node_zonelist(node, GFP_KERNEL),
+	z = first_zones_zonelist(node_zonelist(node, GFP_KERNEL),
 				   gfp_zone(GFP_KERNEL),
-				   NULL,
-				   &zone);
-	return zone->node;
+				   NULL);
+	return z->zone->node;
 }
 #endif
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
