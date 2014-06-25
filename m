Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id A0AAC6B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 20:58:01 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rq2so936048pbb.35
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 17:58:01 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id kr8si2765566pbc.32.2014.06.24.17.57.58
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 17:58:00 -0700 (PDT)
Date: Wed, 25 Jun 2014 10:02:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 02/13] mm, compaction: defer each zone individually
 instead of preferred zone
Message-ID: <20140625010242.GB29373@js1304-P5Q-DELUXE>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-3-git-send-email-vbabka@suse.cz>
 <20140624082306.GF4836@js1304-P5Q-DELUXE>
 <53A99957.5050109@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A99957.5050109@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On Tue, Jun 24, 2014 at 05:29:27PM +0200, Vlastimil Babka wrote:
> On 06/24/2014 10:23 AM, Joonsoo Kim wrote:
> >On Fri, Jun 20, 2014 at 05:49:32PM +0200, Vlastimil Babka wrote:
> >>When direct sync compaction is often unsuccessful, it may become deferred for
> >>some time to avoid further useless attempts, both sync and async. Successful
> >>high-order allocations un-defer compaction, while further unsuccessful
> >>compaction attempts prolong the copmaction deferred period.
> >>
> >>Currently the checking and setting deferred status is performed only on the
> >>preferred zone of the allocation that invoked direct compaction. But compaction
> >>itself is attempted on all eligible zones in the zonelist, so the behavior is
> >>suboptimal and may lead both to scenarios where 1) compaction is attempted
> >>uselessly, or 2) where it's not attempted despite good chances of succeeding,
> >>as shown on the examples below:
> >>
> >>1) A direct compaction with Normal preferred zone failed and set deferred
> >>    compaction for the Normal zone. Another unrelated direct compaction with
> >>    DMA32 as preferred zone will attempt to compact DMA32 zone even though
> >>    the first compaction attempt also included DMA32 zone.
> >>
> >>    In another scenario, compaction with Normal preferred zone failed to compact
> >>    Normal zone, but succeeded in the DMA32 zone, so it will not defer
> >>    compaction. In the next attempt, it will try Normal zone which will fail
> >>    again, instead of skipping Normal zone and trying DMA32 directly.
> >>
> >>2) Kswapd will balance DMA32 zone and reset defer status based on watermarks
> >>    looking good. A direct compaction with preferred Normal zone will skip
> >>    compaction of all zones including DMA32 because Normal was still deferred.
> >>    The allocation might have succeeded in DMA32, but won't.
> >>
> >>This patch makes compaction deferring work on individual zone basis instead of
> >>preferred zone. For each zone, it checks compaction_deferred() to decide if the
> >>zone should be skipped. If watermarks fail after compacting the zone,
> >>defer_compaction() is called. The zone where watermarks passed can still be
> >>deferred when the allocation attempt is unsuccessful. When allocation is
> >>successful, compaction_defer_reset() is called for the zone containing the
> >>allocated page. This approach should approximate calling defer_compaction()
> >>only on zones where compaction was attempted and did not yield allocated page.
> >>There might be corner cases but that is inevitable as long as the decision
> >>to stop compacting dues not guarantee that a page will be allocated.
> >>
> >>During testing on a two-node machine with a single very small Normal zone on
> >>node 1, this patch has improved success rates in stress-highalloc mmtests
> >>benchmark. The success here were previously made worse by commit 3a025760fc
> >>("mm: page_alloc: spill to remote nodes before waking kswapd") as kswapd was
> >>no longer resetting often enough the deferred compaction for the Normal zone,
> >>and DMA32 zones on both nodes were thus not considered for compaction.
> >>
> >>Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> >>Cc: Minchan Kim <minchan@kernel.org>
> >>Cc: Mel Gorman <mgorman@suse.de>
> >>Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >>Cc: Michal Nazarewicz <mina86@mina86.com>
> >>Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>Cc: Christoph Lameter <cl@linux.com>
> >>Cc: Rik van Riel <riel@redhat.com>
> >>Cc: David Rientjes <rientjes@google.com>
> >>---
> >>  include/linux/compaction.h |  6 ++++--
> >>  mm/compaction.c            | 29 ++++++++++++++++++++++++-----
> >>  mm/page_alloc.c            | 33 ++++++++++++++++++---------------
> >>  3 files changed, 46 insertions(+), 22 deletions(-)
> >>
> >>diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> >>index 01e3132..76f9beb 100644
> >>--- a/include/linux/compaction.h
> >>+++ b/include/linux/compaction.h
> >>@@ -22,7 +22,8 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
> >>  extern int fragmentation_index(struct zone *zone, unsigned int order);
> >>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >>  			int order, gfp_t gfp_mask, nodemask_t *mask,
> >>-			enum migrate_mode mode, bool *contended);
> >>+			enum migrate_mode mode, bool *contended, bool *deferred,
> >>+			struct zone **candidate_zone);
> >>  extern void compact_pgdat(pg_data_t *pgdat, int order);
> >>  extern void reset_isolation_suitable(pg_data_t *pgdat);
> >>  extern unsigned long compaction_suitable(struct zone *zone, int order);
> >>@@ -91,7 +92,8 @@ static inline bool compaction_restarting(struct zone *zone, int order)
> >>  #else
> >>  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> >>-			enum migrate_mode mode, bool *contended)
> >>+			enum migrate_mode mode, bool *contended, bool *deferred,
> >>+			struct zone **candidate_zone)
> >>  {
> >>  	return COMPACT_CONTINUE;
> >>  }
> >>diff --git a/mm/compaction.c b/mm/compaction.c
> >>index 5175019..7c491d0 100644
> >>--- a/mm/compaction.c
> >>+++ b/mm/compaction.c
> >>@@ -1122,13 +1122,15 @@ int sysctl_extfrag_threshold = 500;
> >>   * @nodemask: The allowed nodes to allocate from
> >>   * @mode: The migration mode for async, sync light, or sync migration
> >>   * @contended: Return value that is true if compaction was aborted due to lock contention
> >>- * @page: Optionally capture a free page of the requested order during compaction
> >>+ * @deferred: Return value that is true if compaction was deferred in all zones
> >>+ * @candidate_zone: Return the zone where we think allocation should succeed
> >>   *
> >>   * This is the main entry point for direct page compaction.
> >>   */
> >>  unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> >>-			enum migrate_mode mode, bool *contended)
> >>+			enum migrate_mode mode, bool *contended, bool *deferred,
> >>+			struct zone **candidate_zone)
> >>  {
> >>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> >>  	int may_enter_fs = gfp_mask & __GFP_FS;
> >>@@ -1142,8 +1144,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >>  	if (!order || !may_enter_fs || !may_perform_io)
> >>  		return rc;
> >>
> >>-	count_compact_event(COMPACTSTALL);
> >>-
> >>+	*deferred = true;
> >>  #ifdef CONFIG_CMA
> >>  	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> >>  		alloc_flags |= ALLOC_CMA;
> >>@@ -1153,16 +1154,34 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >>  								nodemask) {
> >>  		int status;
> >>
> >>+		if (compaction_deferred(zone, order))
> >>+			continue;
> >>+
> >>+		*deferred = false;
> >>+
> >>  		status = compact_zone_order(zone, order, gfp_mask, mode,
> >>  						contended);
> >>  		rc = max(status, rc);
> >>
> >>  		/* If a normal allocation would succeed, stop compacting */
> >>  		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
> >>-				      alloc_flags))
> >>+				      alloc_flags)) {
> >>+			*candidate_zone = zone;
> >>  			break;
> >
> >How about doing compaction_defer_reset() here?
> >
> >As you said before, although this check is successful, it doesn't ensure
> >success of highorder allocation, because of some unknown reason(ex: racy
> >allocation attempt steals this page). But, at least, passing this check
> >means that we succeed compaction and there is much possibility to exit
> >compaction without searching whole zone range.
> 
> Well another reason is that the check is racy wrt NR_FREE counters
> drift. But I think it tends to be false negative rather than false
> positive. So it could work, and with page capture it would be quite
> accurate. I'll try.
> 
> >So, highorder allocation failure doesn't means that we should defer
> >compaction.
> >
> >>+		} else if (mode != MIGRATE_ASYNC) {
> >>+			/*
> >>+			 * We think that allocation won't succeed in this zone
> >>+			 * so we defer compaction there. If it ends up
> >>+			 * succeeding after all, it will be reset.
> >>+			 */
> >>+			defer_compaction(zone, order);
> >>+		}
> >>  	}
> >>
> >>+	/* If at least one zone wasn't deferred, we count a compaction stall */
> >>+	if (!*deferred)
> >>+		count_compact_event(COMPACTSTALL);
> >>+
> >
> >Could you keep this counting in __alloc_pages_direct_compact()?
> >It will help to understand how this statistic works.
> 
> Well, count_compact_event is defined in compaction.c and this would
> be usage in page_alloc.c. I'm not sure if it helps.

Yes, it is defined in compaction.c. But, others, COMPACTSUCCESS/FAIL
are counted by __alloc_pages_direct_compact() in page_alloc.c so counting
this also in __alloc_pages_direct_compact() would be better, IMHO.

> 
> >>  	return rc;
> >>  }
> >
> >And if possible, it is better to makes deferred to one of compaction
> >status likes as COMPACTION_SKIPPDED. It makes code more clear.
> 
> That could work inside try_to_compact_pages() as well.
> 
> >>
> >>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>index ee92384..6593f79 100644
> >>--- a/mm/page_alloc.c
> >>+++ b/mm/page_alloc.c
> >>@@ -2238,18 +2238,17 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >>  	bool *contended_compaction, bool *deferred_compaction,
> >>  	unsigned long *did_some_progress)
> >>  {
> >>-	if (!order)
> >>-		return NULL;
> >>+	struct zone *last_compact_zone = NULL;
> >>
> >>-	if (compaction_deferred(preferred_zone, order)) {
> >>-		*deferred_compaction = true;
> >>+	if (!order)
> >>  		return NULL;
> >>-	}
> >>
> >>  	current->flags |= PF_MEMALLOC;
> >>  	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
> >>  						nodemask, mode,
> >>-						contended_compaction);
> >>+						contended_compaction,
> >>+						deferred_compaction,
> >>+						&last_compact_zone);
> >>  	current->flags &= ~PF_MEMALLOC;
> >>
> >>  	if (*did_some_progress != COMPACT_SKIPPED) {
> >>@@ -2263,27 +2262,31 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >>  				order, zonelist, high_zoneidx,
> >>  				alloc_flags & ~ALLOC_NO_WATERMARKS,
> >>  				preferred_zone, classzone_idx, migratetype);
> >>+
> >>  		if (page) {
> >>-			preferred_zone->compact_blockskip_flush = false;
> >>-			compaction_defer_reset(preferred_zone, order, true);
> >>+			struct zone *zone = page_zone(page);
> >>+
> >>+			zone->compact_blockskip_flush = false;
> >>+			compaction_defer_reset(zone, order, true);
> >>  			count_vm_event(COMPACTSUCCESS);
> >>  			return page;
> >
> >This snippet raise a though to me.
> >Why don't we reset compaction_defer_reset() if we succeed to allocate
> >highorder page on fastpath or some other path? If we succeed to
> >allocate it on some other path rather than here, it means that the status of
> >memory changes. So this deferred check would be stale test.
> 
> Hm, not sure if we want to do that in fast paths. As long as
> somebody succeeds, that means nobody has to try checking for
> deferred compaction and it doesn't matter. When they stop
> succeeding, then it may be stale, yes. But is it worth polluting
> fast paths with defer resets?

Yes, I don't think it is worth polluting fast paths with it.
It is just my quick thought and just want to share the problem I
realized. If you don't have any good solution to this, please skip
this comment. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
