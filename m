Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 160956B0071
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 15:19:19 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id l18so23828509wgh.16
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 12:19:18 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gs8si47448217wib.50.2014.12.04.12.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Dec 2014 12:19:18 -0800 (PST)
Date: Thu, 4 Dec 2014 15:19:05 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-ID: <20141204201905.GA17790@phnom.home.cmpxchg.org>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
 <20141127102547.GA18833@dhcp22.suse.cz>
 <20141201233040.GB29642@phnom.home.cmpxchg.org>
 <20141203155222.GH23236@dhcp22.suse.cz>
 <20141203181509.GA24567@phnom.home.cmpxchg.org>
 <20141204151758.GC25001@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141204151758.GC25001@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Qiang Huang <h.huangqiang@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 04, 2014 at 04:17:58PM +0100, Michal Hocko wrote:
> On Wed 03-12-14 13:15:09, Johannes Weiner wrote:
> > On Wed, Dec 03, 2014 at 04:52:22PM +0100, Michal Hocko wrote:
> > > On Mon 01-12-14 18:30:40, Johannes Weiner wrote:
> > > > On Thu, Nov 27, 2014 at 11:25:47AM +0100, Michal Hocko wrote:
> > > > > On Wed 26-11-14 14:17:32, David Rientjes wrote:
> > > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > > --- a/mm/page_alloc.c
> > > > > > +++ b/mm/page_alloc.c
> > > > > > @@ -2706,7 +2706,7 @@ rebalance:
> > > > > >  	 * running out of options and have to consider going OOM
> > > > > >  	 */
> > > > > >  	if (!did_some_progress) {
> > > > > > -		if (oom_gfp_allowed(gfp_mask)) {
> > > > > 		/*
> > > > > 		 * Do not attempt to trigger OOM killer for !__GFP_FS
> > > > > 		 * allocations because it would be premature to kill
> > > > > 		 * anything just because the reclaim is stuck on
> > > > > 		 * dirty/writeback pages.
> > > > > 		 * __GFP_NORETRY allocations might fail and so the OOM
> > > > > 		 * would be more harmful than useful.
> > > > > 		 */
> > > > 
> > > > I don't think we need to explain the individual flags, but it would
> > > > indeed be useful to remark here that we shouldn't OOM kill from
> > > > allocations contexts with (severely) limited reclaim abilities.
> > > 
> > > Is __GFP_NORETRY really related to limited reclaim abilities? I thought
> > > it was merely a way to tell the allocator to fail rather than spend too
> > > much time reclaiming.
> > 
> > And you wouldn't call that "limited reclaim ability"?
> 
> I really do not want to go into language lawyering here. But to me the
> reclaim ability is what the reclaim is capable to do with the given gfp.

I was explicitely talking about the reclaim abilities of the
allocation context, in the context of the allocator.  Surely that
includes how often the task can call try_to_free_pages()?

> And __GFP_NORETRY is completely irrelevant for the reclaim. It tells the
> allocator how hard it should try (similar like __GFP_REPEAT or
> __GFP_NOFAIL) unlike __GFP_FS which restricts the reclaim in its
> operation.

Tells the allocator how hard to try *what*?  It's not just looking at
the freelists in a tight loop.  It's reclaiming memory.

You're still thinking about the implementation and get distracted by
the detail that the allocator's reclaim logic is living in a separate
code file.  Look at the architecture.  The GFP flags apply to the
freelist manager and the reclaim code as one big allocator machine
that goes off to get pages, from wherever.  And anything that is
taking pages that are not already on the freelist must be reclaiming
them from somewhere else, by definition.  Thus, the allocation
context's reclaim ability includes whether it can free or migrate used
pages on its own (__GFP_WAIT), whether it can scan and migrate pages
indefinitely or not (__GFP_NOFAIL and __GFP_NORETRY), and whether it
can write and wait for the pages it looks at (__GFP_FS and __GFP_IO).

OOM killing is just another way to reclaim, but the point here is that
it's so disruptive that we want to avoid it unless all other means to
reclaim memory are exhausted.  And yes, continuing to scan pages *is*
a means for the allocator to reclaim memory, and we don't OOM kill
when that is still making progress!

That being said, you ARE right that __GFP_FS and __GFP_NORETRY apply
to different components of the allocator.  While they should have the
same effect on OOM-killing, the fact that they are checked together in
the same branch is a strong signal of how weird this code actually is.

How about the following?  It changes the code flow to clarify what's
actually going on there and gets rid of oom_gfp_allowed() altogether,
instead of awkwardly trying to explain something that has no meaning.

Btw, it looks like there is a bug with oom_killer_disabled, because it
will return NULL for __GFP_NOFAIL.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: embed OOM killing naturally into allocation
 slowpath

The OOM killing invocation does a lot of duplicative checks against
the task's allocation context.  Rework it to take advantage of the
existing checks in the allocator slowpath.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/oom.h |  5 ----
 mm/page_alloc.c     | 80 +++++++++++++++++++++++------------------------------
 2 files changed, 35 insertions(+), 50 deletions(-)

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
index 616a2c956b4b..2df99ca56e28 100644
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
@@ -2701,51 +2715,27 @@ rebalance:
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
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
