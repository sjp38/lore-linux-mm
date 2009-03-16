Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81A6C6B0062
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:51:28 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 05/27] Break up the allocator entry point into fast and slow paths
Date: Mon, 16 Mar 2009 17:53:19 +0000
Message-Id: <1237226020-14057-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

The core of the page allocator is one giant function which allocates memory
on the stack and makes calculations that may not be needed for every
allocation. This patch breaks up the allocator path into fast and slow
paths for clarity. Note the slow paths are still inlined but the entry is
marked unlikely.  If they were not inlined, it actally increases text size
to generate the as there is only one call site.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |  348 ++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 218 insertions(+), 130 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8024abc..7ba7705 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1462,45 +1462,171 @@ try_next_zone:
 	return page;
 }
 
-/*
- * This is the 'heart' of the zoned buddy allocator.
- */
-struct page *
-__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
-			struct zonelist *zonelist, nodemask_t *nodemask)
+static inline int
+should_alloc_retry(gfp_t gfp_mask, unsigned int order,
+				unsigned long pages_reclaimed)
 {
-	const gfp_t wait = gfp_mask & __GFP_WAIT;
-	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zoneref *z;
-	struct zone *zone;
-	struct page *page;
-	struct reclaim_state reclaim_state;
-	struct task_struct *p = current;
-	int do_retry;
-	int alloc_flags;
-	unsigned long did_some_progress;
-	unsigned long pages_reclaimed = 0;
+	/* Do not loop if specifically requested */
+	if (gfp_mask & __GFP_NORETRY)
+		return 0;
 
-	might_sleep_if(wait);
+	/*
+	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
+	 * means __GFP_NOFAIL, but that may not be true in other
+	 * implementations.
+	 */
+	if (order <= PAGE_ALLOC_COSTLY_ORDER)
+		return 1;
 
-	if (should_fail_alloc_page(gfp_mask, order))
-		return NULL;
+	/*
+	 * For order > PAGE_ALLOC_COSTLY_ORDER, if __GFP_REPEAT is
+	 * specified, then we retry until we no longer reclaim any pages
+	 * (above), or we've reclaimed an order of pages at least as
+	 * large as the allocation's order. In both cases, if the
+	 * allocation still fails, we stop retrying.
+	 */
+	if (gfp_mask & __GFP_REPEAT && pages_reclaimed < (1 << order))
+		return 1;
 
-	/* the list of zones suitable for gfp_mask */
-	z = zonelist->_zonerefs;
-	if (unlikely(!z->zone)) {
-		/*
-		 * Happens if we have an empty zonelist as a result of
-		 * GFP_THISNODE being used on a memoryless node
-		 */
+	/*
+	 * Don't let big-order allocations loop unless the caller
+	 * explicitly requests that.
+	 */
+	if (gfp_mask & __GFP_NOFAIL)
+		return 1;
+
+	return 0;
+}
+
+static inline struct page *
+__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
+	struct zonelist *zonelist, enum zone_type high_zoneidx,
+	nodemask_t *nodemask)
+{
+	struct page *page;
+
+	/* Acquire the OOM killer lock for the zones in zonelist */
+	if (!try_set_zone_oom(zonelist, gfp_mask)) {
+		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
-restart:
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
+	/*
+	 * Go through the zonelist yet one more time, keep very high watermark
+	 * here, this is only to catch a parallel oom killing, we must fail if
+	 * we're still under heavy pressure.
+	 */
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
+		order, zonelist, high_zoneidx,
+		ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 	if (page)
-		goto got_pg;
+		goto out;
+
+	/* The OOM killer will not help higher order allocs */
+	if (order > PAGE_ALLOC_COSTLY_ORDER)
+		goto out;
+
+	/* Exhausted what can be done so it's blamo time */
+	out_of_memory(zonelist, gfp_mask, order);
+
+out:
+	clear_zonelist_oom(zonelist, gfp_mask);
+	return page;
+}
+
+/* The really slow allocator path where we enter direct reclaim */
+static inline struct page *
+__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
+	struct zonelist *zonelist, enum zone_type high_zoneidx,
+	nodemask_t *nodemask, int alloc_flags, unsigned long *did_some_progress)
+{
+	struct page *page = NULL;
+	struct reclaim_state reclaim_state;
+	struct task_struct *p = current;
+
+	cond_resched();
+
+	/* We now go into synchronous reclaim */
+	cpuset_memory_pressure_bump();
+
+	/*
+	 * The task's cpuset might have expanded its set of allowable nodes
+	 */
+	cpuset_update_task_memory_state();
+	p->flags |= PF_MEMALLOC;
+	reclaim_state.reclaimed_slab = 0;
+	p->reclaim_state = &reclaim_state;
+
+	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
+
+	p->reclaim_state = NULL;
+	p->flags &= ~PF_MEMALLOC;
+
+	cond_resched();
+
+	if (order != 0)
+		drain_all_pages();
+
+	if (likely(*did_some_progress))
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
+					zonelist, high_zoneidx, alloc_flags);
+	return page;
+}
+
+static inline int
+is_allocation_high_priority(struct task_struct *p, gfp_t gfp_mask)
+{
+	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
+			&& !in_interrupt())
+		if (!(gfp_mask & __GFP_NOMEMALLOC))
+			return 1;
+	return 0;
+}
+
+/*
+ * This is called in the allocator slow-path if the allocation request is of
+ * sufficient urgency to ignore watermarks and take other desperate measures
+ */
+static inline struct page *
+__alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
+	struct zonelist *zonelist, enum zone_type high_zoneidx,
+	nodemask_t *nodemask)
+{
+	struct page *page;
+
+	do {
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
+			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
+
+		if (!page && gfp_mask & __GFP_NOFAIL)
+			congestion_wait(WRITE, HZ/50);
+	} while (!page && (gfp_mask & __GFP_NOFAIL));
+
+	return page;
+}
+
+static inline
+void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
+						enum zone_type high_zoneidx)
+{
+	struct zoneref *z;
+	struct zone *zone;
+
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+		wakeup_kswapd(zone, order);
+}
+
+static inline struct page *
+__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
+	struct zonelist *zonelist, enum zone_type high_zoneidx,
+	nodemask_t *nodemask)
+{
+	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	struct page *page = NULL;
+	int alloc_flags;
+	unsigned long pages_reclaimed = 0;
+	unsigned long did_some_progress;
+	struct task_struct *p = current;
 
 	/*
 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
@@ -1513,8 +1639,7 @@ restart:
 	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-		wakeup_kswapd(zone, order);
+	wake_all_kswapd(order, zonelist, high_zoneidx);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -1534,6 +1659,7 @@ restart:
 	if (wait)
 		alloc_flags |= ALLOC_CPUSET;
 
+restart:
 	/*
 	 * Go through the zonelist again. Let __GFP_HIGH and allocations
 	 * coming from realtime tasks go deeper into reserves.
@@ -1547,118 +1673,47 @@ restart:
 	if (page)
 		goto got_pg;
 
-	/* This allocation should allow future memory freeing. */
-
-rebalance:
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt()) {
-		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
-nofail_alloc:
-			/* go through the zonelist yet again, ignoring mins */
-			page = get_page_from_freelist(gfp_mask, nodemask, order,
-				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
-			if (page)
-				goto got_pg;
-			if (gfp_mask & __GFP_NOFAIL) {
-				congestion_wait(WRITE, HZ/50);
-				goto nofail_alloc;
-			}
-		}
-		goto nopage;
-	}
+	/* Allocate without watermarks if the context allows */
+	if (is_allocation_high_priority(p, gfp_mask))
+		page = __alloc_pages_high_priority(gfp_mask, order,
+			zonelist, high_zoneidx, nodemask);
+	if (page)
+		goto got_pg;
 
 	/* Atomic allocations - we can't balance anything */
 	if (!wait)
 		goto nopage;
 
-	cond_resched();
+	/* Try direct reclaim and then allocating */
+	page = __alloc_pages_direct_reclaim(gfp_mask, order,
+					zonelist, high_zoneidx,
+					nodemask,
+					alloc_flags, &did_some_progress);
+	if (page)
+		goto got_pg;
 
-	/* We now go into synchronous reclaim */
-	cpuset_memory_pressure_bump();
 	/*
-	 * The task's cpuset might have expanded its set of allowable nodes
+	 * If we failed to make any progress reclaiming, then we are
+	 * running out of options and have to consider going OOM
 	 */
-	cpuset_update_task_memory_state();
-	p->flags |= PF_MEMALLOC;
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
-
-	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
-
-	p->reclaim_state = NULL;
-	p->flags &= ~PF_MEMALLOC;
-
-	cond_resched();
-
-	if (order != 0)
-		drain_all_pages();
+	if (!did_some_progress) {
+		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
+			page = __alloc_pages_may_oom(gfp_mask, order,
+					zonelist, high_zoneidx,
+					nodemask);
+			if (page)
+				goto got_pg;
 
-	if (likely(did_some_progress)) {
-		page = get_page_from_freelist(gfp_mask, nodemask, order,
-					zonelist, high_zoneidx, alloc_flags);
-		if (page)
-			goto got_pg;
-	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
-		if (!try_set_zone_oom(zonelist, gfp_mask)) {
-			schedule_timeout_uninterruptible(1);
 			goto restart;
 		}
-
-		/*
-		 * Go through the zonelist yet one more time, keep
-		 * very high watermark here, this is only to catch
-		 * a parallel oom killing, we must fail if we're still
-		 * under heavy pressure.
-		 */
-		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
-			order, zonelist, high_zoneidx,
-			ALLOC_WMARK_HIGH|ALLOC_CPUSET);
-		if (page) {
-			clear_zonelist_oom(zonelist, gfp_mask);
-			goto got_pg;
-		}
-
-		/* The OOM killer will not help higher order allocs so fail */
-		if (order > PAGE_ALLOC_COSTLY_ORDER) {
-			clear_zonelist_oom(zonelist, gfp_mask);
-			goto nopage;
-		}
-
-		out_of_memory(zonelist, gfp_mask, order);
-		clear_zonelist_oom(zonelist, gfp_mask);
-		goto restart;
 	}
 
-	/*
-	 * Don't let big-order allocations loop unless the caller explicitly
-	 * requests that.  Wait for some write requests to complete then retry.
-	 *
-	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
-	 * means __GFP_NOFAIL, but that may not be true in other
-	 * implementations.
-	 *
-	 * For order > PAGE_ALLOC_COSTLY_ORDER, if __GFP_REPEAT is
-	 * specified, then we retry until we no longer reclaim any pages
-	 * (above), or we've reclaimed an order of pages at least as
-	 * large as the allocation's order. In both cases, if the
-	 * allocation still fails, we stop retrying.
-	 */
+	/* Check if we should retry the allocation */
 	pages_reclaimed += did_some_progress;
-	do_retry = 0;
-	if (!(gfp_mask & __GFP_NORETRY)) {
-		if (order <= PAGE_ALLOC_COSTLY_ORDER) {
-			do_retry = 1;
-		} else {
-			if (gfp_mask & __GFP_REPEAT &&
-				pages_reclaimed < (1 << order))
-					do_retry = 1;
-		}
-		if (gfp_mask & __GFP_NOFAIL)
-			do_retry = 1;
-	}
-	if (do_retry) {
+	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
+		/* Wait for some write requests to complete then retry */
 		congestion_wait(WRITE, HZ/50);
-		goto rebalance;
+		goto restart;
 	}
 
 nopage:
@@ -1671,6 +1726,39 @@ nopage:
 	}
 got_pg:
 	return page;
+
+}
+
+/*
+ * This is the 'heart' of the zoned buddy allocator.
+ */
+struct page *
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask)
+{
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	struct page *page;
+
+	might_sleep_if(gfp_mask & __GFP_WAIT);
+
+	if (should_fail_alloc_page(gfp_mask, order))
+		return NULL;
+
+	/*
+	 * Check the zones suitable for the gfp_mask contain at least one
+	 * valid zone. It's possible to have an empty zonelist as a result
+	 * of GFP_THISNODE and a memoryless node
+	 */
+	if (unlikely(!zonelist->_zonerefs->zone))
+		return NULL;
+
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
+			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
+	if (unlikely(!page))
+		page = __alloc_pages_slowpath(gfp_mask, order,
+				zonelist, high_zoneidx, nodemask);
+
+	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
