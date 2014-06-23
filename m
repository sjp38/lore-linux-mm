Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC4C6B0035
	for <linux-mm@kvack.org>; Sun, 22 Jun 2014 21:38:17 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so5043986pdj.33
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 18:38:17 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id uy5si19668641pac.15.2014.06.22.18.38.15
        for <linux-mm@kvack.org>;
        Sun, 22 Jun 2014 18:38:16 -0700 (PDT)
Date: Mon, 23 Jun 2014 10:39:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 05/13] mm, compaction: report compaction as contended
 only due to lock contention
Message-ID: <20140623013903.GA12413@bbox>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1403279383-5862-6-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

Hello Vlastimil,

On Fri, Jun 20, 2014 at 05:49:35PM +0200, Vlastimil Babka wrote:
> Async compaction aborts when it detects zone lock contention or need_resched()
> is true. David Rientjes has reported that in practice, most direct async
> compactions for THP allocation abort due to need_resched(). This means that a
> second direct compaction is never attempted, which might be OK for a page
> fault, but khugepaged is intended to attempt a sync compaction in such case and
> in these cases it won't.
> 
> This patch replaces "bool contended" in compact_control with an enum that
> distinguieshes between aborting due to need_resched() and aborting due to lock
> contention. This allows propagating the abort through all compaction functions
> as before, but declaring the direct compaction as contended only when lock
> contention has been detected.
> 
> A second problem is that try_to_compact_pages() did not act upon the reported
> contention (both need_resched() or lock contention) and could proceed with
> another zone from the zonelist. When need_resched() is true, that means
> initializing another zone compaction, only to check again need_resched() in
> isolate_migratepages() and aborting. For zone lock contention, the unintended
> consequence is that the contended status reported back to the allocator
> is decided from the last zone where compaction was attempted, which is rather
> arbitrary.
> 
> This patch fixes the problem in the following way:
> - need_resched() being true after async compaction returned from a zone means
>   that further zones should not be tried. We do a cond_resched() so that we
>   do not hog the CPU, and abort. "contended" is reported as false, since we
>   did not fail due to lock contention.
> - aborting zone compaction due to lock contention means we can still try
>   another zone, since it has different locks. We report back "contended" as
>   true only if *all* zones where compaction was attempted, it aborted due to
>   lock contention.
> 
> As a result of these fixes, khugepaged will proceed with second sync compaction
> as intended, when the preceding async compaction aborted due to need_resched().
> Page fault compactions aborting due to need_resched() will spare some cycles
> previously wasted by initializing another zone compaction only to abort again.
> Lock contention will be reported only when compaction in all zones aborted due
> to lock contention, and therefore it's not a good idea to try again after
> reclaim.
> 
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c | 48 +++++++++++++++++++++++++++++++++++++++---------
>  mm/internal.h   | 15 +++++++++++----
>  2 files changed, 50 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index ebe30c9..e8cfac9 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -180,9 +180,14 @@ static void update_pageblock_skip(struct compact_control *cc,
>  }
>  #endif /* CONFIG_COMPACTION */
>  
> -static inline bool should_release_lock(spinlock_t *lock)
> +enum compact_contended should_release_lock(spinlock_t *lock)
>  {
> -	return need_resched() || spin_is_contended(lock);
> +	if (spin_is_contended(lock))
> +		return COMPACT_CONTENDED_LOCK;
> +	else if (need_resched())
> +		return COMPACT_CONTENDED_SCHED;
> +	else
> +		return COMPACT_CONTENDED_NONE;

If you want to raise priority of lock contention than need_resched
intentionally, please write it down on comment.

>  }
>  
>  /*
> @@ -197,7 +202,9 @@ static inline bool should_release_lock(spinlock_t *lock)
>  static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>  				      bool locked, struct compact_control *cc)
>  {
> -	if (should_release_lock(lock)) {
> +	enum compact_contended contended = should_release_lock(lock);
> +
> +	if (contended) {
>  		if (locked) {
>  			spin_unlock_irqrestore(lock, *flags);
>  			locked = false;
> @@ -205,7 +212,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>  
>  		/* async aborts if taking too long or contended */
>  		if (cc->mode == MIGRATE_ASYNC) {
> -			cc->contended = true;
> +			cc->contended = contended;
>  			return false;
>  		}


>  
> @@ -231,7 +238,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
>  	/* async compaction aborts if contended */
>  	if (need_resched()) {
>  		if (cc->mode == MIGRATE_ASYNC) {
> -			cc->contended = true;
> +			cc->contended = COMPACT_CONTENDED_SCHED;
>  			return true;
>  		}
>  
> @@ -1101,7 +1108,8 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
>  	VM_BUG_ON(!list_empty(&cc.freepages));
>  	VM_BUG_ON(!list_empty(&cc.migratepages));
>  
> -	*contended = cc.contended;
> +	/* We only signal lock contention back to the allocator */
> +	*contended = cc.contended == COMPACT_CONTENDED_LOCK;

Please write down *WHY* as well as your intention we can know by looking at code.

>  	return ret;
>  }
>  
> @@ -1132,6 +1140,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  	struct zone *zone;
>  	int rc = COMPACT_SKIPPED;
>  	int alloc_flags = 0;
> +	bool all_zones_contended = true;
>  
>  	/* Check if the GFP flags allow compaction */
>  	if (!order || !may_enter_fs || !may_perform_io)
> @@ -1146,6 +1155,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
>  								nodemask) {
>  		int status;
> +		bool zone_contended;
>  
>  		if (compaction_deferred(zone, order))
>  			continue;
> @@ -1153,8 +1163,9 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  		*deferred = false;
>  
>  		status = compact_zone_order(zone, order, gfp_mask, mode,
> -						contended);
> +							&zone_contended);
>  		rc = max(status, rc);
> +		all_zones_contended &= zone_contended;
>  
>  		/* If a normal allocation would succeed, stop compacting */
>  		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
> @@ -1168,12 +1179,31 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			 * succeeding after all, it will be reset.
>  			 */
>  			defer_compaction(zone, order);
> +			/*
> +			 * If we stopped compacting due to need_resched(), do
> +			 * not try further zones and yield the CPU.
> +			 */

For what? It would make your claim more clear.

> +			if (need_resched()) {

compact_zone_order returns true state of contended only if it was lock contention
so it couldn't return true state of contended by need_resched so you made
need_resched check in here. It's fragile to me because it could be not a result
from ahead compact_zone_order call. More clear thing is compact_zone_order
should return zone_contended as enum, not bool and in here, you could check it.

It means you could return enum in compact_zone_order and make the result bool
in try_to_compact_pages.

> +				/*
> +				 * We might not have tried all the zones, so
> +				 * be conservative and assume they are not
> +				 * all lock contended.
> +				 */
> +				all_zones_contended = false;
> +				cond_resched();
> +				break;
> +			}
>  		}
>  	}
>  
> -	/* If at least one zone wasn't deferred, we count a compaction stall */
> -	if (!*deferred)
> +	/*
> +	 * If at least one zone wasn't deferred, we count a compaction stall
> +	 * and we report if all zones that were tried were contended.
> +	 */
> +	if (!*deferred) {
>  		count_compact_event(COMPACTSTALL);
> +		*contended = all_zones_contended;

Why don't you initialize contended as *false* in function's intro?

> +	}
>  
>  	return rc;
>  }
> diff --git a/mm/internal.h b/mm/internal.h
> index a1b651b..2c187d2 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -117,6 +117,13 @@ extern int user_min_free_kbytes;
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>  
> +/* Used to signal whether compaction detected need_sched() or lock contention */
> +enum compact_contended {
> +	COMPACT_CONTENDED_NONE = 0, /* no contention detected */
> +	COMPACT_CONTENDED_SCHED,    /* need_sched() was true */
> +	COMPACT_CONTENDED_LOCK,     /* zone lock or lru_lock was contended */
> +};
> +
>  /*
>   * in mm/compaction.c
>   */
> @@ -144,10 +151,10 @@ struct compact_control {
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>  	struct zone *zone;
> -	bool contended;			/* True if a lock was contended, or
> -					 * need_resched() true during async
> -					 * compaction
> -					 */
> +	enum compact_contended contended; /* Signal need_sched() or lock
> +					   * contention detected during
> +					   * compaction
> +					   */
>  };
>  
>  unsigned long
> -- 

Anyway, most big concern is that you are changing current behavior as
I said earlier.

Old behavior in THP page fault when it consumes own timeslot was just
abort and fallback 4K page but with your patch, new behavior is
take a rest when it founds need_resched and goes to another round with
async, not sync compaction. I'm not sure we need another round with
async compaction at the cost of increasing latency rather than fallback
4 page.

It might be okay if the VMA has MADV_HUGEPAGE which is good hint to
indicate non-temporal VMA so latency would be trade-off but it's not
for temporal big memory allocation in HUGEPAGE_ALWAYS system.

If you really want to go this, could you show us numbers?

1. How many could we can be successful in direct compaction by this patch?
2. How long could we increase latency for temporal allocation
   for HUGEPAGE_ALWAYS system?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
