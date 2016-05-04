Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 012906B0260
	for <linux-mm@kvack.org>; Wed,  4 May 2016 02:30:46 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id u5so85684572igk.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 23:30:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id s76si2354022itb.103.2016.05.03.23.30.44
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 23:30:45 -0700 (PDT)
Date: Wed, 4 May 2016 15:31:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 12/14] mm, oom: protect !costly allocations some more
Message-ID: <20160504063112.GD10899@js1304-P5Q-DELUXE>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-13-git-send-email-mhocko@kernel.org>
 <20160504060123.GB10899@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504060123.GB10899@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, May 04, 2016 at 03:01:24PM +0900, Joonsoo Kim wrote:
> On Wed, Apr 20, 2016 at 03:47:25PM -0400, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > should_reclaim_retry will give up retries for higher order allocations
> > if none of the eligible zones has any requested or higher order pages
> > available even if we pass the watermak check for order-0. This is done
> > because there is no guarantee that the reclaimable and currently free
> > pages will form the required order.
> > 
> > This can, however, lead to situations were the high-order request (e.g.
> > order-2 required for the stack allocation during fork) will trigger
> > OOM too early - e.g. after the first reclaim/compaction round. Such a
> > system would have to be highly fragmented and there is no guarantee
> > further reclaim/compaction attempts would help but at least make sure
> > that the compaction was active before we go OOM and keep retrying even
> > if should_reclaim_retry tells us to oom if
> > 	- the last compaction round backed off or
> > 	- we haven't completed at least MAX_COMPACT_RETRIES active
> > 	  compaction rounds.
> > 
> > The first rule ensures that the very last attempt for compaction
> > was not ignored while the second guarantees that the compaction has done
> > some work. Multiple retries might be needed to prevent occasional
> > pigggy backing of other contexts to steal the compacted pages before
> > the current context manages to retry to allocate them.
> > 
> > compaction_failed() is taken as a final word from the compaction that
> > the retry doesn't make much sense. We have to be careful though because
> > the first compaction round is MIGRATE_ASYNC which is rather weak as it
> > ignores pages under writeback and gives up too easily in other
> > situations. We therefore have to make sure that MIGRATE_SYNC_LIGHT mode
> > has been used before we give up. With this logic in place we do not have
> > to increase the migration mode unconditionally and rather do it only if
> > the compaction failed for the weaker mode. A nice side effect is that
> > the stronger migration mode is used only when really needed so this has
> > a potential of smaller latencies in some cases.
> > 
> > Please note that the compaction doesn't tell us much about how
> > successful it was when returning compaction_made_progress so we just
> > have to blindly trust that another retry is worthwhile and cap the
> > number to something reasonable to guarantee a convergence.
> > 
> > If the given number of successful retries is not sufficient for a
> > reasonable workloads we should focus on the collected compaction
> > tracepoints data and try to address the issue in the compaction code.
> > If this is not feasible we can increase the retries limit.
> > 
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 87 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
> >  1 file changed, 77 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 3b78936eca70..bb4df1be0d43 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2939,6 +2939,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  	return page;
> >  }
> >  
> > +
> > +/*
> > + * Maximum number of compaction retries wit a progress before OOM
> > + * killer is consider as the only way to move forward.
> > + */
> > +#define MAX_COMPACT_RETRIES 16
> > +
> >  #ifdef CONFIG_COMPACTION
> >  /* Try memory compaction for high-order allocations before reclaim */
> >  static struct page *
> > @@ -3006,6 +3013,43 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  
> >  	return NULL;
> >  }
> > +
> > +static inline bool
> > +should_compact_retry(unsigned int order, enum compact_result compact_result,
> > +		     enum migrate_mode *migrate_mode,
> > +		     int compaction_retries)
> > +{
> > +	if (!order)
> > +		return false;
> > +
> > +	/*
> > +	 * compaction considers all the zone as desperately out of memory
> > +	 * so it doesn't really make much sense to retry except when the
> > +	 * failure could be caused by weak migration mode.
> > +	 */
> > +	if (compaction_failed(compact_result)) {
> 
> IIUC, this compaction_failed() means that at least one zone is
> compacted and failed. This is not same with your assumption in the
> comment. If compaction is done and failed on ZONE_DMA, it would be
> premature decision.
> 
> > +		if (*migrate_mode == MIGRATE_ASYNC) {
> > +			*migrate_mode = MIGRATE_SYNC_LIGHT;
> > +			return true;
> > +		}
> > +		return false;
> > +	}
> > +
> > +	/*
> > +	 * !costly allocations are really important and we have to make sure
> > +	 * the compaction wasn't deferred or didn't bail out early due to locks
> > +	 * contention before we go OOM. Still cap the reclaim retry loops with
> > +	 * progress to prevent from looping forever and potential trashing.
> > +	 */
> > +	if (order <= PAGE_ALLOC_COSTLY_ORDER) {
> > +		if (compaction_withdrawn(compact_result))
> > +			return true;
> > +		if (compaction_retries <= MAX_COMPACT_RETRIES)
> > +			return true;
> > +	}
> > +
> > +	return false;
> > +}
> >  #else
> >  static inline struct page *
> >  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> > @@ -3014,6 +3058,14 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  {
> >  	return NULL;
> >  }
> > +
> > +static inline bool
> > +should_compact_retry(unsigned int order, enum compact_result compact_result,
> > +		     enum migrate_mode *migrate_mode,
> > +		     int compaction_retries)
> > +{
> > +	return false;
> > +}
> >  #endif /* CONFIG_COMPACTION */
> >  
> >  /* Perform direct synchronous page reclaim */
> > @@ -3260,6 +3312,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	unsigned long did_some_progress;
> >  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> >  	enum compact_result compact_result;
> > +	int compaction_retries = 0;
> >  	int no_progress_loops = 0;
> >  
> >  	/*
> > @@ -3371,13 +3424,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  			 compaction_failed(compact_result)))
> >  		goto nopage;
> >  
> > -	/*
> > -	 * It can become very expensive to allocate transparent hugepages at
> > -	 * fault, so use asynchronous memory compaction for THP unless it is
> > -	 * khugepaged trying to collapse.
> > -	 */
> > -	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
> > -		migration_mode = MIGRATE_SYNC_LIGHT;
> > +	if (order && compaction_made_progress(compact_result))
> > +		compaction_retries++;
> >  
> >  	/* Try direct reclaim and then allocating */
> >  	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
> > @@ -3408,6 +3456,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  				 no_progress_loops))
> >  		goto retry;
> >  
> > +	/*
> > +	 * It doesn't make any sense to retry for the compaction if the order-0
> > +	 * reclaim is not able to make any progress because the current
> > +	 * implementation of the compaction depends on the sufficient amount
> > +	 * of free memory (see __compaction_suitable)
> > +	 */
> > +	if (did_some_progress > 0 &&
> > +			should_compact_retry(order, compact_result,
> > +				&migration_mode, compaction_retries))
> 
> Checking did_some_progress on each round have subtle corner case. Think
> about following situation.
> 
> round, compaction, did_some_progress, compaction
> 0, defer, 1
> 0, defer, 1
> 0, defer, 1
> 0, defer, 1
> 0, defer, 0

Oops...Example should be below one.

0, defer, 1
1, defer, 1
2, defer, 1
3, defer, 1
4, defer, 0

> 
> In this case, compaction has enough chance to succeed since freepages
> increase, but, compaction will not be triggered.
> 
> 
> Thanks.
> 
> > +		goto retry;
> > +
> >  	/* Reclaim has failed us, start killing things */
> >  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
> >  	if (page)
> > @@ -3421,10 +3480,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  
> >  noretry:
> >  	/*
> > -	 * High-order allocations do not necessarily loop after
> > -	 * direct reclaim and reclaim/compaction depends on compaction
> > -	 * being called after reclaim so call directly if necessary
> > +	 * High-order allocations do not necessarily loop after direct reclaim
> > +	 * and reclaim/compaction depends on compaction being called after
> > +	 * reclaim so call directly if necessary.
> > +	 * It can become very expensive to allocate transparent hugepages at
> > +	 * fault, so use asynchronous memory compaction for THP unless it is
> > +	 * khugepaged trying to collapse. All other requests should tolerate
> > +	 * at least light sync migration.
> >  	 */
> > +	if (is_thp_gfp_mask(gfp_mask) && !(current->flags & PF_KTHREAD))
> > +		migration_mode = MIGRATE_ASYNC;
> > +	else
> > +		migration_mode = MIGRATE_SYNC_LIGHT;
> >  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
> >  					    ac, migration_mode,
> >  					    &compact_result);
> > -- 
> > 2.8.0.rc3
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
