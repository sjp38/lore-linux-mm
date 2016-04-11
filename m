Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEF06B027B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:16:02 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id n3so93437511wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:16:02 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id lz8si27528534wjb.121.2016.04.11.01.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:16:01 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id B18F41C1764
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:16:00 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 19/22] mm, page_alloc: Avoid looking up the first zone in a zonelist twice
Date: Mon, 11 Apr 2016 09:13:42 +0100
Message-Id: <1460362424-26369-20-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The allocator fast path looks up the first usable zone in a zonelist
and then get_page_from_freelist does the same job in the zonelist
iterator. This patch preserves the necessary information.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 fs/buffer.c            |  9 +++++----
 include/linux/mmzone.h | 18 +++++++++++-------
 mm/internal.h          |  2 +-
 mm/mempolicy.c         | 19 ++++++++++---------
 mm/page_alloc.c        | 25 ++++++++++++-------------
 5 files changed, 39 insertions(+), 34 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 33be29675358..d4624b567e11 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -262,10 +262,11 @@ static void free_more_memory(void)
 	yield();
 
 	for_each_online_node(nid) {
-		(void)first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
-						gfp_zone(GFP_NOFS), NULL,
-						&zone);
-		if (zone)
+		struct zoneref *z;
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
index c131218913e8..8f53cb3853fc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2699,7 +2699,7 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
-	struct zoneref *z;
+	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
 	bool fair_skipped = false;
 	bool apply_fair = (alloc_flags & ALLOC_FAIR);
@@ -2709,7 +2709,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
+	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		struct page *page;
 		unsigned long mark;
@@ -2729,7 +2729,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				fair_skipped = true;
 				continue;
 			}
-			if (!zone_local(ac->preferred_zone, zone)) {
+			if (!zone_local(ac->preferred_zoneref->zone, zone)) {
 				if (fair_skipped)
 					goto reset_fair;
 				apply_fair = false;
@@ -2775,7 +2775,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				goto try_this_zone;
 
 			if (zone_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(ac->preferred_zone, zone))
+			    !zone_allows_reclaim(ac->preferred_zoneref->zone, zone))
 				continue;
 
 			ret = zone_reclaim(zone, gfp_mask, order);
@@ -2797,7 +2797,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(ac->preferred_zone, zone, order,
+		page = buffered_rmqueue(ac->preferred_zoneref->zone, zone, order,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
 			if (prep_new_page(page, order, gfp_mask, alloc_flags))
@@ -2826,7 +2826,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 reset_fair:
 		apply_fair = false;
 		fair_skipped = false;
-		reset_alloc_batches(ac->preferred_zone);
+		reset_alloc_batches(ac->preferred_zoneref->zone);
 		goto zonelist_scan;
 	}
 
@@ -3113,7 +3113,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 						ac->high_zoneidx, ac->nodemask)
-		wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone));
+		wakeup_kswapd(zone, order, zonelist_zone_idx(ac->preferred_zoneref));
 }
 
 static inline unsigned int
@@ -3333,7 +3333,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
 	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(ac->preferred_zoneref->zone, BLK_RW_ASYNC, HZ/50);
 		goto retry;
 	}
 
@@ -3371,7 +3371,6 @@ struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
-	struct zoneref *preferred_zoneref;
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
@@ -3407,11 +3406,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
 	/* The preferred zone is used for statistics later */
-	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
-				ac.nodemask, &ac.preferred_zone);
-	if (!ac.preferred_zone)
+	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
+				ac.nodemask);
+	if (!ac.preferred_zoneref->zone)
 		goto out;
-	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
+	ac.classzone_idx = zonelist_zone_idx(ac.preferred_zoneref);
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
