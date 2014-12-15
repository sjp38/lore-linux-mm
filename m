Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 71C2C6B0075
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:03:23 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so11835520ier.14
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:03:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l4si7778194icw.33.2014.12.15.15.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 15:03:22 -0800 (PST)
Date: Mon, 15 Dec 2014 15:03:19 -0800
From: akpm@linux-foundation.org
Subject: [patch 3/6] mm: page_alloc: embed OOM killing naturally into
 allocation slowpath
Message-ID: <548f68b7.cWb8Q7JoeXCA0inA%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, rientjes@google.com

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: page_alloc: embed OOM killing naturally into allocation slowpath

The OOM killing invocation does a lot of duplicative checks against the
task's allocation context.  Rework it to take advantage of the existing
checks in the allocator slowpath.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/oom.h |    5 --
 mm/page_alloc.c     |   80 ++++++++++++++++++------------------------
 2 files changed, 35 insertions(+), 50 deletions(-)

diff -puN include/linux/oom.h~mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath include/linux/oom.h
--- a/include/linux/oom.h~mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath
+++ a/include/linux/oom.h
@@ -85,11 +85,6 @@ static inline void oom_killer_enable(voi
 	oom_killer_disabled = false;
 }
 
-static inline bool oom_gfp_allowed(gfp_t gfp_mask)
-{
-	return (gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY);
-}
-
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 static inline bool task_will_free_mem(struct task_struct *task)
diff -puN mm/page_alloc.c~mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath mm/page_alloc.c
--- a/mm/page_alloc.c~mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath
+++ a/mm/page_alloc.c
@@ -2331,12 +2331,21 @@ static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+	int classzone_idx, int migratetype, unsigned long *did_some_progress)
 {
 	struct page *page;
 
-	/* Acquire the per-zone oom lock for each zone */
+	*did_some_progress = 0;
+
+	if (oom_killer_disabled)
+		return NULL;
+
+	/*
+	 * Acquire the per-zone oom lock for each zone.  If that
+	 * fails, somebody else is making progress for us.
+	 */
 	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
+		*did_some_progress = 1;
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
@@ -2362,12 +2371,18 @@ __alloc_pages_may_oom(gfp_t gfp_mask, un
 		goto out;
 
 	if (!(gfp_mask & __GFP_NOFAIL)) {
+		/* Coredumps can quickly deplete all memory reserves */
+		if (current->flags & PF_DUMPCORE)
+			goto out;
 		/* The OOM killer will not help higher order allocs */
 		if (order > PAGE_ALLOC_COSTLY_ORDER)
 			goto out;
 		/* The OOM killer does not needlessly kill tasks for lowmem */
 		if (high_zoneidx < ZONE_NORMAL)
 			goto out;
+		/* The OOM killer does not compensate for light reclaim */
+		if (!(gfp_mask & __GFP_FS))
+			goto out;
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
 		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
@@ -2380,7 +2395,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, un
 	}
 	/* Exhausted what can be done so it's blamo time */
 	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
-
+	*did_some_progress = 1;
 out:
 	oom_zonelist_unlock(zonelist, gfp_mask);
 	return page;
@@ -2657,7 +2672,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, u
 	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-restart:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
 		wake_all_kswapds(order, zonelist, high_zoneidx,
 				preferred_zone, nodemask);
@@ -2787,51 +2801,27 @@ rebalance:
 	if (page)
 		goto got_pg;
 
-	/*
-	 * If we failed to make any progress reclaiming, then we are
-	 * running out of options and have to consider going OOM
-	 */
-	if (!did_some_progress) {
-		if (oom_gfp_allowed(gfp_mask)) {
-			if (oom_killer_disabled)
-				goto nopage;
-			/* Coredumps can quickly deplete all memory reserves */
-			if ((current->flags & PF_DUMPCORE) &&
-			    !(gfp_mask & __GFP_NOFAIL))
-				goto nopage;
-			page = __alloc_pages_may_oom(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask, preferred_zone,
-					classzone_idx, migratetype);
-			if (page)
-				goto got_pg;
-
-			if (!(gfp_mask & __GFP_NOFAIL)) {
-				/*
-				 * The oom killer is not called for high-order
-				 * allocations that may fail, so if no progress
-				 * is being made, there are no other options and
-				 * retrying is unlikely to help.
-				 */
-				if (order > PAGE_ALLOC_COSTLY_ORDER)
-					goto nopage;
-				/*
-				 * The oom killer is not called for lowmem
-				 * allocations to prevent needlessly killing
-				 * innocent tasks.
-				 */
-				if (high_zoneidx < ZONE_NORMAL)
-					goto nopage;
-			}
-
-			goto restart;
-		}
-	}
-
 	/* Check if we should retry the allocation */
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, did_some_progress,
 						pages_reclaimed)) {
+		/*
+		 * If we fail to make progress by freeing individual
+		 * pages, but the allocation wants us to keep going,
+		 * start OOM killing tasks.
+		 */
+		if (!did_some_progress) {
+			page = __alloc_pages_may_oom(gfp_mask, order, zonelist,
+						high_zoneidx, nodemask,
+						preferred_zone, classzone_idx,
+						migratetype,&did_some_progress);
+			if (page)
+				goto got_pg;
+			if (!did_some_progress) {
+				BUG_ON(gfp_mask & __GFP_NOFAIL);
+				goto nopage;
+			}
+		}
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
