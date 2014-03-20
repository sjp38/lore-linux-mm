Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8E26B0254
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 16:53:45 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id d7so110854bkh.14
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 13:53:44 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ov5si1474733bkb.259.2014.03.20.13.53.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 13:53:44 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: spill to remote nodes before waking kswapd
Date: Thu, 20 Mar 2014 16:53:36 -0400
Message-Id: <1395348816-4733-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On NUMA systems, a node may start thrashing cache or even swap
anonymous pages while there are still free pages on remote nodes.

This is a result of 81c0a2bb515f ("mm: page_alloc: fair zone allocator
policy") and fff4068cba48 ("mm: page_alloc: revert NUMA aspect of fair
allocation policy").  Before those changes, the allocator would first
try all allowed zones, including those on remote nodes, before waking
any kswapds.  But now, the allocator fastpath doubles as the fairness
pass, which in turn can only consider the local node to prevent remote
spilling based on exhausted fairness batches alone.  Remote nodes are
only considered in the slowpath, after the kswapds are woken up.  But
if remote nodes still have free memory, kswapd should not be woken to
rebalance the local node or it may thrash cash or swap prematurely.

Fix this by adding one more unfair pass over the zonelist that is
allowed to spill to remote nodes after the local fairness pass fails
but before entering the slowpath and waking the kswapds.

This also gets rid of the GFP_THISNODE exemption from the fairness
protocol because the unfair pass is no longer tied to kswapd, which
GFP_THISNODE is not allowed to wake up.

However, because remote spills can be more frequent now - we prefer
them over local kswapd reclaim - the allocation batches on remote
nodes could underflow more heavily.  When resetting the batches, use
atomic_long_read() directly instead of zone_page_state() to calculate
the delta as the latter filters negative counter values.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@kernel.org> [3.12+]
---
 mm/internal.h   |  1 +
 mm/page_alloc.c | 89 +++++++++++++++++++++++++++++----------------------------
 2 files changed, 46 insertions(+), 44 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 29e1e761f9eb..3e910000fda4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -370,5 +370,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
+#define ALLOC_FAIR		0x100 /* fair zone allocation */
 
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3bac76ae4b30..7387a671234e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1238,15 +1238,6 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	}
 	local_irq_restore(flags);
 }
-static bool gfp_thisnode_allocation(gfp_t gfp_mask)
-{
-	return (gfp_mask & GFP_THISNODE) == GFP_THISNODE;
-}
-#else
-static bool gfp_thisnode_allocation(gfp_t gfp_mask)
-{
-	return false;
-}
 #endif
 
 /*
@@ -1583,12 +1574,7 @@ again:
 					  get_pageblock_migratetype(page));
 	}
 
-	/*
-	 * NOTE: GFP_THISNODE allocations do not partake in the kswapd
-	 * aging protocol, so they can't be fair.
-	 */
-	if (!gfp_thisnode_allocation(gfp_flags))
-		__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1954,23 +1940,12 @@ zonelist_scan:
 		 * zone size to ensure fair page aging.  The zone a
 		 * page was allocated in should have no effect on the
 		 * time the page has in memory before being reclaimed.
-		 *
-		 * Try to stay in local zones in the fastpath.  If
-		 * that fails, the slowpath is entered, which will do
-		 * another pass starting with the local zones, but
-		 * ultimately fall back to remote zones that do not
-		 * partake in the fairness round-robin cycle of this
-		 * zonelist.
-		 *
-		 * NOTE: GFP_THISNODE allocations do not partake in
-		 * the kswapd aging protocol, so they can't be fair.
 		 */
-		if ((alloc_flags & ALLOC_WMARK_LOW) &&
-		    !gfp_thisnode_allocation(gfp_mask)) {
-			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
-				continue;
+		if (alloc_flags & ALLOC_FAIR) {
 			if (!zone_local(preferred_zone, zone))
 				continue;
+			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
+				continue;
 		}
 		/*
 		 * When allocating a page cache page for writing, we
@@ -2408,32 +2383,40 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
-			     struct zonelist *zonelist,
-			     enum zone_type high_zoneidx,
-			     struct zone *preferred_zone)
+static void reset_alloc_batches(struct zonelist *zonelist,
+				enum zone_type high_zoneidx,
+				struct zone *preferred_zone)
 {
 	struct zoneref *z;
 	struct zone *zone;
 
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-		if (!(gfp_mask & __GFP_NO_KSWAPD))
-			wakeup_kswapd(zone, order, zone_idx(preferred_zone));
 		/*
 		 * Only reset the batches of zones that were actually
-		 * considered in the fast path, we don't want to
-		 * thrash fairness information for zones that are not
+		 * considered in the fairness pass, we don't want to
+		 * trash fairness information for zones that are not
 		 * actually part of this zonelist's round-robin cycle.
 		 */
 		if (!zone_local(preferred_zone, zone))
 			continue;
 		mod_zone_page_state(zone, NR_ALLOC_BATCH,
-				    high_wmark_pages(zone) -
-				    low_wmark_pages(zone) -
-				    zone_page_state(zone, NR_ALLOC_BATCH));
+			high_wmark_pages(zone) - low_wmark_pages(zone) -
+			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
 	}
 }
 
+static void wake_all_kswapds(unsigned int order,
+			     struct zonelist *zonelist,
+			     enum zone_type high_zoneidx,
+			     struct zone *preferred_zone)
+{
+	struct zoneref *z;
+	struct zone *zone;
+
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+		wakeup_kswapd(zone, order, zone_idx(preferred_zone));
+}
+
 static inline int
 gfp_to_alloc_flags(gfp_t gfp_mask)
 {
@@ -2522,12 +2505,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * allowed per node queues are empty and that nodes are
 	 * over allocated.
 	 */
-	if (gfp_thisnode_allocation(gfp_mask))
+	if (IS_ENABLED(CONFIG_NUMA) &&
+	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
 restart:
-	prepare_slowpath(gfp_mask, order, zonelist,
-			 high_zoneidx, preferred_zone);
+	if (!(gfp_mask & __GFP_NO_KSWAPD))
+		wake_all_kswapds(order, zonelist, high_zoneidx, preferred_zone);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2711,7 +2695,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	int migratetype = allocflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
-	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
+	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	struct mem_cgroup *memcg = NULL;
 
 	gfp_mask &= gfp_allowed_mask;
@@ -2752,12 +2736,29 @@ retry_cpuset:
 	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
+retry:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
 			preferred_zone, migratetype);
 	if (unlikely(!page)) {
 		/*
+		 * The first pass makes sure allocations are spread
+		 * fairly within the local node.  However, the local
+		 * node might have free pages left after the fairness
+		 * batches are exhausted, and remote zones haven't
+		 * even been considered yet.  Try once more without
+		 * fairness, and include remote zones now, before
+		 * entering the slowpath and waking kswapd: prefer
+		 * spilling to a remote zone over swapping locally.
+		 */
+		if (alloc_flags & ALLOC_FAIR) {
+			reset_alloc_batches(zonelist, high_zoneidx,
+					    preferred_zone);
+			alloc_flags &= ~ALLOC_FAIR;
+			goto retry;
+		}
+		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
 		 * complete.
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
