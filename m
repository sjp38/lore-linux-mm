Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 82E6F6B00BB
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:52:46 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 07/22] Calculate the preferred zone for allocation only once
Date: Wed, 22 Apr 2009 14:53:12 +0100
Message-Id: <1240408407-21848-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

get_page_from_freelist() can be called multiple times for an allocation.
Part of this calculates the preferred_zone which is the first usable zone
in the zonelist but the zone depends on the GFP flags specified at the
beginning of the allocation call. This patch calculates preferred_zone
once. It's safe to do this because if preferred_zone is NULL at the start
of the call, no amount of direct reclaim or other actions will change the
fact the allocation will fail.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/page_alloc.c |   53 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b1ae435..e073fa3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1392,23 +1392,18 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
  */
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
-		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
+		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
+		struct zone *preferred_zone)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
 	int classzone_idx;
-	struct zone *zone, *preferred_zone;
+	struct zone *zone;
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
-	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
-							&preferred_zone);
-	if (!preferred_zone)
-		return NULL;
-
 	classzone_idx = zone_idx(preferred_zone);
-
 	VM_BUG_ON(order >= MAX_ORDER);
 
 zonelist_scan:
@@ -1503,7 +1498,7 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask)
+	nodemask_t *nodemask, struct zone *preferred_zone)
 {
 	struct page *page;
 
@@ -1520,7 +1515,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
-		ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
+		preferred_zone);
 	if (page)
 		goto out;
 
@@ -1540,7 +1536,8 @@ out:
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, unsigned long *did_some_progress)
+	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
+	unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
@@ -1572,7 +1569,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	if (likely(*did_some_progress))
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
-					zonelist, high_zoneidx, alloc_flags);
+					zonelist, high_zoneidx,
+					alloc_flags, preferred_zone);
 	return page;
 }
 
@@ -1592,13 +1590,14 @@ is_allocation_high_priority(struct task_struct *p, gfp_t gfp_mask)
 static inline struct page *
 __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask)
+	nodemask_t *nodemask, struct zone *preferred_zone)
 {
 	struct page *page;
 
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
+			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
+			preferred_zone);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			congestion_wait(WRITE, HZ/50);
@@ -1621,7 +1620,7 @@ void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask)
+	nodemask_t *nodemask, struct zone *preferred_zone)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
@@ -1671,7 +1670,8 @@ restart:
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
-						high_zoneidx, alloc_flags);
+						high_zoneidx, alloc_flags,
+						preferred_zone);
 	if (page)
 		goto got_pg;
 
@@ -1681,7 +1681,7 @@ rebalance:
 		/* Do not dip into emergency reserves if specified */
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 			page = __alloc_pages_high_priority(gfp_mask, order,
-				zonelist, high_zoneidx, nodemask);
+				zonelist, high_zoneidx, nodemask, preferred_zone);
 			if (page)
 				goto got_pg;
 		}
@@ -1698,7 +1698,8 @@ rebalance:
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask,
-					alloc_flags, &did_some_progress);
+					alloc_flags, preferred_zone,
+					&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -1710,7 +1711,7 @@ rebalance:
 		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
 			page = __alloc_pages_may_oom(gfp_mask, order,
 					zonelist, high_zoneidx,
-					nodemask);
+					nodemask, preferred_zone);
 			if (page)
 				goto got_pg;
 
@@ -1755,6 +1756,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	struct zone *preferred_zone;
 	struct page *page;
 
 	lockdep_trace_alloc(gfp_mask);
@@ -1772,11 +1774,20 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
+	/* The preferred zone is used for statistics later */
+	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
+							&preferred_zone);
+	if (!preferred_zone)
+		return NULL;
+
+	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
+			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
+			preferred_zone);
 	if (unlikely(!page))
 		page = __alloc_pages_slowpath(gfp_mask, order,
-				zonelist, high_zoneidx, nodemask);
+				zonelist, high_zoneidx, nodemask,
+				preferred_zone);
 
 	return page;
 }
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
