Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 544386B0146
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:21 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/22] mm: page allocator: Check if interrupts are enabled only once per allocation attempt
Date: Wed,  8 May 2013 17:03:00 +0100
Message-Id: <1368028987-8369-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

in_interrupt() is not that expensive but it's still potentially called
a very large number of times during a page allocation. Ensure it's only
called once. As the check if now firmly in the allocation path, we can
use __GFP_WAIT as an cheaper check for IRQs being disabled.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 67 +++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 44 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3d619e3..b30abe8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1379,7 +1379,8 @@ retry:
 static inline
 struct page *rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype)
+			gfp_t gfp_flags, int migratetype,
+			bool use_magazine)
 {
 	struct page *page = NULL;
 
@@ -1398,11 +1399,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	}
 
 again:
-	/*
-	 * For order-0 allocations that are not from irq context, try
-	 * allocate from a separate magazine of free pages
-	 */
-	if (order == 0 && !in_interrupt() && !irqs_disabled())
+	if (use_magazine)
 		page = rmqueue_magazine(zone, migratetype);
 
 	if (!page) {
@@ -1739,7 +1736,8 @@ static inline void init_zone_allows_reclaim(int nid)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int migratetype)
+		struct zone *preferred_zone, int migratetype,
+		bool use_magazine)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -1845,7 +1843,7 @@ zonelist_scan:
 
 try_this_zone:
 		page = rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+					gfp_mask, migratetype, use_magazine);
 		if (page)
 			break;
 this_zone_full:
@@ -1971,7 +1969,7 @@ static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, bool use_magazine)
 {
 	struct page *page;
 
@@ -1989,7 +1987,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
 		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, migratetype);
+		preferred_zone, migratetype, use_magazine);
 	if (page)
 		goto out;
 
@@ -2024,7 +2022,7 @@ static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, bool sync_migration, bool use_magazine,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2048,7 +2046,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, use_magazine);
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
 			preferred_zone->compact_considered = 0;
@@ -2124,7 +2122,7 @@ static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress)
+	int migratetype, bool use_magazine, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 
@@ -2140,7 +2138,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, migratetype);
+					preferred_zone, migratetype,
+					use_magazine);
 
 	return page;
 }
@@ -2153,14 +2152,14 @@ static inline struct page *
 __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, bool use_magazine)
 {
 	struct page *page;
 
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, use_magazine);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
@@ -2239,7 +2238,7 @@ static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, bool use_magazine)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
@@ -2297,7 +2296,7 @@ rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, use_magazine);
 	if (page)
 		goto got_pg;
 
@@ -2312,7 +2311,7 @@ rebalance:
 
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, use_magazine);
 		if (page) {
 			goto got_pg;
 		}
@@ -2339,6 +2338,7 @@ rebalance:
 					nodemask,
 					alloc_flags, preferred_zone,
 					migratetype, sync_migration,
+					use_magazine,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2361,7 +2361,8 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress);
+					migratetype, use_magazine,
+					&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2380,7 +2381,7 @@ rebalance:
 			page = __alloc_pages_may_oom(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask, preferred_zone,
-					migratetype);
+					migratetype, use_magazine);
 			if (page)
 				goto got_pg;
 
@@ -2424,6 +2425,7 @@ rebalance:
 					nodemask,
 					alloc_flags, preferred_zone,
 					migratetype, sync_migration,
+					use_magazine,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2442,6 +2444,24 @@ got_pg:
 }
 
 /*
+ * For order-0 allocations that are not from irq context, try
+ * allocate from a separate magazine of free pages.
+ */
+static inline bool should_alloc_use_magazine(gfp_t gfp_mask, unsigned int order)
+{
+	if (order)
+		return false;
+
+	if (gfp_mask & __GFP_WAIT)
+		return true;
+
+	if (in_interrupt() || irqs_disabled())
+		return false;
+
+	return true;
+}
+
+/*
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page *
@@ -2455,6 +2475,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
 	struct mem_cgroup *memcg = NULL;
+	bool use_magazine = should_alloc_use_magazine(gfp_mask, order);
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2497,7 +2518,7 @@ retry_cpuset:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, use_magazine);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
@@ -2507,7 +2528,7 @@ retry_cpuset:
 		gfp_mask = memalloc_noio_flags(gfp_mask);
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, use_magazine);
 	}
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
