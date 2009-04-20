Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DF7765F000D
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:20:05 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 11/25] Calculate the cold parameter for allocation only once
Date: Mon, 20 Apr 2009 23:19:57 +0100
Message-Id: <1240266011-11140-12-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

GFP mask is checked for __GFP_COLD has been specified when deciding which
end of the PCP lists to use. However, it is happening multiple times per
allocation, at least once per zone traversed. Calculate it once.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1506cd5..51e1ded 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1066,11 +1066,10 @@ void split_page(struct page *page, unsigned int order)
  */
 static struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, int order, gfp_t gfp_flags,
-			int migratetype)
+			int migratetype, int cold)
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
 	int cpu;
 
 again:
@@ -1397,7 +1396,7 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int migratetype)
+		struct zone *preferred_zone, int migratetype, int cold)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -1450,7 +1449,7 @@ zonelist_scan:
 		}
 
 		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+						gfp_mask, migratetype, cold);
 		if (page)
 			break;
 this_zone_full:
@@ -1515,7 +1514,7 @@ static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, int cold)
 {
 	struct page *page;
 
@@ -1533,7 +1532,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
 		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, migratetype);
+		preferred_zone, migratetype, cold);
 	if (page)
 		goto out;
 
@@ -1554,7 +1553,7 @@ static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress)
+	int migratetype, int cold, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
@@ -1588,7 +1587,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags, preferred_zone,
-					migratetype);
+					migratetype, cold);
 	return page;
 }
 
@@ -1600,14 +1599,14 @@ static inline struct page *
 __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, int cold)
 {
 	struct page *page;
 
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, cold);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			congestion_wait(WRITE, HZ/50);
@@ -1667,7 +1666,7 @@ static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, int cold)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
@@ -1700,7 +1699,7 @@ restart:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, cold);
 	if (page)
 		goto got_pg;
 
@@ -1708,7 +1707,7 @@ restart:
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, cold);
 		if (page)
 			goto got_pg;
 	}
@@ -1726,7 +1725,8 @@ restart:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress);
+					migratetype, cold,
+					&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -1739,7 +1739,7 @@ restart:
 			page = __alloc_pages_may_oom(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask, preferred_zone,
-					migratetype);
+					migratetype, cold);
 			if (page)
 				goto got_pg;
 
@@ -1779,6 +1779,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zone *preferred_zone;
 	struct page *page;
 	int migratetype = allocflags_to_migratetype(gfp_mask);
+	int cold = gfp_mask & __GFP_COLD;
 
 	lockdep_trace_alloc(gfp_mask);
 
@@ -1804,11 +1805,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, cold);
 	if (unlikely(!page))
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, cold);
 
 	return page;
 }
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
