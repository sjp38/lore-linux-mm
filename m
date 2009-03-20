Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E3AFC6B0062
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:29:09 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 10/25] Calculate the alloc_flags for allocation only once
Date: Fri, 20 Mar 2009 10:02:57 +0000
Message-Id: <1237543392-11797-11-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Factor out the mapping between GFP and alloc_flags only once. Once factored
out, it only needs to be calculated once but some care must be taken.

[neilb@suse.de says]
As the test:

-       if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-                       && !in_interrupt()) {
-               if (!(gfp_mask & __GFP_NOMEMALLOC)) {

has been replaced with a slightly weaker one:

+       if (alloc_flags & ALLOC_NO_WATERMARKS) {

we need to ensure we don't recurse when PF_MEMALLOC is set.

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/page_alloc.c |   88 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 50 insertions(+), 38 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8771de3..0558eb4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1593,16 +1593,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static inline int
-is_allocation_high_priority(struct task_struct *p, gfp_t gfp_mask)
-{
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt())
-		if (!(gfp_mask & __GFP_NOMEMALLOC))
-			return 1;
-	return 0;
-}
-
 /*
  * This is called in the allocator slow-path if the allocation request is of
  * sufficient urgency to ignore watermarks and take other desperate measures
@@ -1638,6 +1628,42 @@ void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
 		wakeup_kswapd(zone, order);
 }
 
+static inline int
+gfp_to_alloc_flags(gfp_t gfp_mask)
+{
+	struct task_struct *p = current;
+	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
+	const gfp_t wait = gfp_mask & __GFP_WAIT;
+
+	/*
+	 * The caller may dip into page reserves a bit more if the caller
+	 * cannot run direct reclaim, or if the caller has realtime scheduling
+	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
+	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
+	 */
+	if (gfp_mask & __GFP_HIGH)
+		alloc_flags |= ALLOC_HIGH;
+
+	if (!wait) {
+		alloc_flags |= ALLOC_HARDER;
+		/*
+		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
+		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
+		 */
+		alloc_flags &= ~ALLOC_CPUSET;
+	} else if (unlikely(rt_task(p)) && !in_interrupt())
+		alloc_flags |= ALLOC_HARDER;
+
+	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
+		if (!in_interrupt() &&
+		    ((p->flags & PF_MEMALLOC) ||
+		     unlikely(test_thread_flag(TIF_MEMDIE))))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+	}
+
+	return alloc_flags;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -1668,48 +1694,34 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * OK, we're below the kswapd watermark and have kicked background
 	 * reclaim. Now things get more complex, so set up alloc_flags according
 	 * to how we want to proceed.
-	 *
-	 * The caller may dip into page reserves a bit more if the caller
-	 * cannot run direct reclaim, or if the caller has realtime scheduling
-	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
-	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
 	 */
-	alloc_flags = ALLOC_WMARK_MIN;
-	if ((unlikely(rt_task(p)) && !in_interrupt()) || !wait)
-		alloc_flags |= ALLOC_HARDER;
-	if (gfp_mask & __GFP_HIGH)
-		alloc_flags |= ALLOC_HIGH;
-	if (wait)
-		alloc_flags |= ALLOC_CPUSET;
+	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
 restart:
-	/*
-	 * Go through the zonelist again. Let __GFP_HIGH and allocations
-	 * coming from realtime tasks go deeper into reserves.
-	 *
-	 * This is the last chance, in general, before the goto nopage.
-	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
-	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
-	 */
+	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
-						high_zoneidx, alloc_flags,
-						preferred_zone,
-						migratetype);
+			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
+			preferred_zone, migratetype);
 	if (page)
 		goto got_pg;
 
 	/* Allocate without watermarks if the context allows */
-	if (is_allocation_high_priority(p, gfp_mask))
+	if (alloc_flags & ALLOC_NO_WATERMARKS) {
 		page = __alloc_pages_high_priority(gfp_mask, order,
-			zonelist, high_zoneidx, nodemask, preferred_zone,
-			migratetype);
-	if (page)
-		goto got_pg;
+				zonelist, high_zoneidx, nodemask,
+				preferred_zone, migratetype);
+		if (page)
+			goto got_pg;
+	}
 
 	/* Atomic allocations - we can't balance anything */
 	if (!wait)
 		goto nopage;
 
+	/* Avoid recursion of direct reclaim */
+	if (p->flags & PF_MEMALLOC)
+		goto nopage;
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
