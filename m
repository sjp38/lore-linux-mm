Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8FBA96B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 04:35:17 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 1/5] mm, page_alloc: support multiple pages allocation
Date: Wed,  3 Jul 2013 17:34:16 +0900
Message-Id: <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patch introduces multiple pages allocation feature to buddy
allocator. Currently, there is no ability to allocate multiple
pages at once, so we should invoke single page allocation logic
repeatedly. This has some overheads like as function call
overhead with many arguments and overhead for finding proper
node and zone.

With this patchset, we can reduce these overheads. Device I/O is
getting faster rapidly and allocator should catch up this speed.
This patch help this situation.

In this patch, I introduce new arguments, nr_pages and pages, to
core function of allocator and try to allocate multiple pages
in first attempt(fast path). I think that multiple page allocation
is not valid for slow path, so current implementation consider
just fast path.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0f615eb..8bfa87b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -298,13 +298,15 @@ static inline void arch_alloc_page(struct page *page, int order) { }
 
 struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
-		       struct zonelist *zonelist, nodemask_t *nodemask);
+		       struct zonelist *zonelist, nodemask_t *nodemask,
+		       unsigned long *nr_pages, struct page **pages);
 
 static inline struct page *
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist)
 {
-	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
+	return __alloc_pages_nodemask(gfp_mask, order,
+				zonelist, NULL, NULL, NULL);
 }
 
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..b17e48c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2004,7 +2004,8 @@ retry_cpuset:
 	}
 	page = __alloc_pages_nodemask(gfp, order,
 				      policy_zonelist(gfp, pol, node),
-				      policy_nodemask(gfp, pol));
+				      policy_nodemask(gfp, pol),
+				      NULL, NULL);
 	if (unlikely(mpol_needs_cond_ref(pol)))
 		__mpol_put(pol);
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
@@ -2052,7 +2053,8 @@ retry_cpuset:
 	else
 		page = __alloc_pages_nodemask(gfp, order,
 				policy_zonelist(gfp, pol, numa_node_id()),
-				policy_nodemask(gfp, pol));
+				policy_nodemask(gfp, pol),
+				NULL, NULL);
 
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3edb62..1fbbc9a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1846,7 +1846,8 @@ static inline void init_zone_allows_reclaim(int nid)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int migratetype)
+		struct zone *preferred_zone, int migratetype,
+		unsigned long *nr_pages, struct page **pages)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -1855,6 +1856,8 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	unsigned long count = 0;
+	unsigned long mark;
 
 	classzone_idx = zone_idx(preferred_zone);
 zonelist_scan:
@@ -1902,7 +1905,6 @@ zonelist_scan:
 
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
-			unsigned long mark;
 			int ret;
 
 			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
@@ -1966,10 +1968,30 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
-		if (page)
+		do {
+			page = buffered_rmqueue(preferred_zone, zone, order,
+							gfp_mask, migratetype);
+			if (!page)
+				break;
+
+			if (!nr_pages) {
+				count++;
+				break;
+			}
+
+			pages[count++] = page;
+			if (count >= *nr_pages)
+				break;
+
+			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+			if (!zone_watermark_ok(zone, order, mark,
+					classzone_idx, alloc_flags))
+				break;
+		} while (1);
+
+		if (count > 0)
 			break;
+
 this_zone_full:
 		if (IS_ENABLED(CONFIG_NUMA))
 			zlc_mark_zone_full(zonelist, z);
@@ -1981,6 +2003,12 @@ this_zone_full:
 		goto zonelist_scan;
 	}
 
+	if (nr_pages) {
+		*nr_pages = count;
+		if (count > 0)
+			page = pages[0];
+	}
+
 	if (page)
 		/*
 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
@@ -2125,7 +2153,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
 		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, migratetype);
+		preferred_zone, migratetype,
+		NULL, NULL);
 	if (page)
 		goto out;
 
@@ -2188,7 +2217,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype,
+				NULL, NULL);
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
 			preferred_zone->compact_considered = 0;
@@ -2282,7 +2312,8 @@ retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, migratetype);
+					preferred_zone, migratetype,
+					NULL, NULL);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2312,7 +2343,8 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype,
+			NULL, NULL);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
@@ -2449,7 +2481,8 @@ rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype,
+			NULL, NULL);
 	if (page)
 		goto got_pg;
 
@@ -2598,7 +2631,8 @@ got_pg:
  */
 struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
-			struct zonelist *zonelist, nodemask_t *nodemask)
+			struct zonelist *zonelist, nodemask_t *nodemask,
+			unsigned long *nr_pages, struct page **pages)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone *preferred_zone;
@@ -2608,6 +2642,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
 	struct mem_cgroup *memcg = NULL;
 
+	VM_BUG_ON(nr_pages && !pages);
+
 	gfp_mask &= gfp_allowed_mask;
 
 	lockdep_trace_alloc(gfp_mask);
@@ -2647,9 +2683,11 @@ retry_cpuset:
 		alloc_flags |= ALLOC_CMA;
 #endif
 	/* First allocation attempt */
+	/* We only try to allocate nr_pages in first attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype,
+			nr_pages, pages);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
