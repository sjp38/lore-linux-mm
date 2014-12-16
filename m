Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3E59D6B0032
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 22:07:03 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so16377413wgh.18
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 19:07:02 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vb8si19384919wjc.134.2014.12.15.19.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 19:07:02 -0800 (PST)
Date: Mon, 15 Dec 2014 22:06:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Stalled MM patches for review
Message-ID: <20141216030658.GA18569@phnom.home.cmpxchg.org>
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
 <548F7541.8040407@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <548F7541.8040407@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Dec 16, 2014 at 08:56:49AM +0900, Yasuaki Ishimatsu wrote:
> (2014/12/16 8:02), Andrew Morton wrote:
> >
> >I'm sitting on a bunch of patches which have question marks over them.
> >I'll send them out now.  Can people please dig in and see if we can get
> >them finished off one way or the other?
> >
> >My notes (which may be out of date):
>
> >mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath.patch:
> >   - mhocko wanted a changelog update
> 
> https://lkml.org/lkml/2014/12/4/697

Thanks Yasuaki-san!

Andrew, here is an updated version of this patch with a more detailed
changelog.  Must have fallen through the cracks:

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: embed OOM killing naturally into allocation slowpath
Date: Fri,  5 Dec 2014 09:48:13 -0500
Message-Id: <1417790893-32010-1-git-send-email-hannes@cmpxchg.org>

The OOM killing invocation does a lot of duplicative checks against
the task's allocation context.  Rework it to take advantage of the
existing checks in the allocator slowpath.

The OOM killer is invoked when the allocator is unable to reclaim any
pages but the allocation has to keep looping.  Instead of having a
check for __GFP_NORETRY hidden in oom_gfp_allowed(), just move the OOM
invocation to the true branch of should_alloc_retry().  The __GFP_FS
check from oom_gfp_allowed() can then be moved into the OOM avoidance
branch in __alloc_pages_may_oom(), along with the PF_DUMPCORE test.

__alloc_pages_may_oom() can then signal to the caller whether the OOM
killer was invoked, instead of requiring it to duplicate the order and
high_zoneidx checks to guess this when deciding whether to continue.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/oom.h |  5 ----
 mm/page_alloc.c     | 78 +++++++++++++++++++++++------------------------------
 2 files changed, 33 insertions(+), 50 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index e8d6e1058723..4971874f54db 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -85,11 +85,6 @@ static inline void oom_killer_enable(void)
 	oom_killer_disabled = false;
 }
 
-static inline bool oom_gfp_allowed(gfp_t gfp_mask)
-{
-	return (gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY);
-}
-
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 /* sysctls */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c956b4b..88b64c09a8c0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2232,12 +2232,21 @@ static inline struct page *
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
@@ -2263,12 +2272,18 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
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
@@ -2281,7 +2296,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	}
 	/* Exhausted what can be done so it's blamo time */
 	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
-
+	*did_some_progress = 1;
 out:
 	oom_zonelist_unlock(zonelist, gfp_mask);
 	return page;
@@ -2571,7 +2586,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-restart:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
 		wake_all_kswapds(order, zonelist, high_zoneidx,
 				preferred_zone, nodemask);
@@ -2701,51 +2715,25 @@ rebalance:
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
+			if (!did_some_progress)
+				goto nopage;
+		}
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
