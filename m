Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB6D6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:17:51 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id av4so9887936igc.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:17:51 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id e69si5729236pfd.66.2016.03.11.04.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 04:17:40 -0800 (PST)
Received: by mail-pa0-x231.google.com with SMTP id fl4so96138799pad.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:17:40 -0800 (PST)
Date: Fri, 11 Mar 2016 04:17:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
In-Reply-To: <20160309111109.GG27018@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1603110354360.7920@eggly.anvils>
References: <20160307160838.GB5028@dhcp22.suse.cz> <1457444565-10524-1-git-send-email-mhocko@kernel.org> <1457444565-10524-4-git-send-email-mhocko@kernel.org> <20160309111109.GG27018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 9 Mar 2016, Michal Hocko wrote:
> Joonsoo has pointed out that this attempt is still not sufficient
> becasuse we might have invoked only a single compaction round which
> is might be not enough. I fully agree with that. Here is my take on
> that. It is again based on the number of retries loop.
> 
> I was also playing with an idea of doing something similar to the
> reclaim retry logic:
> 	if (order) {
> 		if (compaction_made_progress(compact_result)
> 			no_compact_progress = 0;
> 		else if (compaction_failed(compact_result)
> 			no_compact_progress++;
> 	}
> but it is compaction_failed() part which is not really
> straightforward to define. Is it COMPACT_NO_SUITABLE_PAGE
> resp. COMPACT_NOT_SUITABLE_ZONE sufficient? compact_finished and
> compaction_suitable however hide this from compaction users so it
> seems like we can never see it.
> 
> Maybe we can update the feedback mechanism from the compaction but
> retries count seems reasonably easy to understand and pragmatic. If
> we cannot form a order page after we tried for N times then it really
> doesn't make much sense to continue and we are oom for this order. I am
> holding my breath to hear from Hugh on this, though.

Never a wise strategy.  But I just got around to it tonight.

I do believe you've nailed it with this patch!  Thank you!

I've applied 1/3, 2/3 and this (ah, it became the missing 3/3 later on)
on top of 4.5.0-rc5-mm1 (I think there have been a couple of mmotms since,
but I've not got to them yet): so far it is looking good on all machines.

After a quick go with the simple make -j20 in tmpfs, which survived
a cycle on the laptop, I've switched back to my original tougher load,
and that's going well so far: no sign of any OOMs.  But I've interrupted
on the laptop to report back to you now, then I'll leave it running
overnight.

> In case it doesn't
> then I would be really interested whether changing MAX_COMPACT_RETRIES
> makes any difference.
> 
> I haven't preserved Tested-by from Sergey to be on the safe side even
> though strictly speaking this should be less prone to high order OOMs
> because we clearly retry more times.
> ---
> From 33f08d6eeb0f5eaf1c73c292f070102ddec5878a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 9 Mar 2016 10:57:42 +0100
> Subject: [PATCH] mm, oom: protect !costly allocations some more
> 
> should_reclaim_retry will give up retries for higher order allocations
> if none of the eligible zones has any requested or higher order pages
> available even if we pass the watermak check for order-0. This is done
> because there is no guarantee that the reclaimable and currently free
> pages will form the required order.
> 
> This can, however, lead to situations were the high-order request (e.g.
> order-2 required for the stack allocation during fork) will trigger
> OOM too early - e.g. after the first reclaim/compaction round. Such a
> system would have to be highly fragmented and there is no guarantee
> further reclaim/compaction attempts would help but at least make sure
> that the compaction was active before we go OOM and keep retrying even
> if should_reclaim_retry tells us to oom if
> 	- the last compaction round was either inactive (deferred,
> 	  skipped or bailed out early due to contention) or
> 	- we haven't completed at least MAX_COMPACT_RETRIES successful
> 	  (either COMPACT_PARTIAL or COMPACT_COMPLETE) compaction
> 	  rounds.
> 
> The first rule ensures that the very last attempt for compaction
> was ignored while the second guarantees that the compaction has done
> some work. Multiple retries might be needed to prevent occasional
> pigggy packing of other contexts to steal the compacted pages while
> the current context manages to retry to allocate them.
> 
> If the given number of successful retries is not sufficient for a
> reasonable workloads we should focus on the collected compaction
> tracepoints data and try to address the issue in the compaction code.
> If this is not feasible we can increase the retries limit.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/compaction.h | 10 +++++++
>  mm/page_alloc.c            | 68 +++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 62 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index b167801187e7..7d028ccf440a 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -61,6 +61,12 @@ extern void compaction_defer_reset(struct zone *zone, int order,
>  				bool alloc_success);
>  extern bool compaction_restarting(struct zone *zone, int order);
>  
> +static inline bool compaction_made_progress(enum compact_result result)
> +{
> +	return (compact_result > COMPACT_SKIPPED &&
> +				compact_result < COMPACT_NO_SUITABLE_PAGE)

That line didn't build at all:

        return result > COMPACT_SKIPPED && result < COMPACT_NO_SUITABLE_PAGE;

> +}
> +
>  #else
>  static inline enum compact_result try_to_compact_pages(gfp_t gfp_mask,
>  			unsigned int order, int alloc_flags,
> @@ -93,6 +99,10 @@ static inline bool compaction_deferred(struct zone *zone, int order)
>  	return true;
>  }
>  
> +static inline bool compaction_made_progress(enum compact_result result)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_COMPACTION */
>  
>  #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4acc0aa1aee0..5f1fc3793836 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2813,34 +2813,33 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	return page;
>  }
>  
> +
> +/*
> + * Maximum number of compaction retries wit a progress before OOM
> + * killer is consider as the only way to move forward.
> + */
> +#define MAX_COMPACT_RETRIES 16
> +
>  #ifdef CONFIG_COMPACTION
>  /* Try memory compaction for high-order allocations before reclaim */
>  static struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		int alloc_flags, const struct alloc_context *ac,
>  		enum migrate_mode mode, int *contended_compaction,
> -		bool *deferred_compaction)
> +		enum compact_result *compact_result)
>  {
> -	enum compact_result compact_result;
>  	struct page *page;
>  
>  	if (!order)
>  		return NULL;
>  
>  	current->flags |= PF_MEMALLOC;
> -	compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> +	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>  						mode, contended_compaction);
>  	current->flags &= ~PF_MEMALLOC;
>  
> -	switch (compact_result) {
> -	case COMPACT_DEFERRED:
> -		*deferred_compaction = true;
> -		/* fall-through */
> -	case COMPACT_SKIPPED:
> +	if (*compact_result <= COMPACT_SKIPPED)
>  		return NULL;
> -	default:
> -		break;
> -	}
>  
>  	/*
>  	 * At least in one zone compaction wasn't deferred or skipped, so let's
> @@ -2870,15 +2869,44 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  
>  	return NULL;
>  }
> +
> +static inline bool
> +should_compact_retry(unsigned int order, enum compact_result compact_result,
> +		     int contended_compaction, int compaction_retries)
> +{
> +	/*
> +	 * !costly allocations are really important and we have to make sure
> +	 * the compaction wasn't deferred or didn't bail out early due to locks
> +	 * contention before we go OOM. Still cap the reclaim retry loops with
> +	 * progress to prevent from looping forever and potential trashing.
> +	 */
> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> +		if (compact_result <= COMPACT_SKIPPED)
> +			return true;
> +		if (contended_compaction > COMPACT_CONTENDED_NONE)
> +			return true;
> +		if (compaction_retries <= MAX_COMPACT_RETRIES)
> +			return true;
> +	}
> +
> +	return false;
> +}
>  #else
>  static inline struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		int alloc_flags, const struct alloc_context *ac,
>  		enum migrate_mode mode, int *contended_compaction,
> -		bool *deferred_compaction)
> +		enum compact_result *compact_result)
>  {
>  	return NULL;
>  }
> +
> +static inline bool
> +should_compact_retry(unsigned int order, enum compact_result compact_result,
> +		     int contended_compaction, int compaction_retries)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_COMPACTION */
>  
>  /* Perform direct synchronous page reclaim */
> @@ -3118,7 +3146,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	int alloc_flags;
>  	unsigned long did_some_progress;
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> -	bool deferred_compaction = false;
> +	enum compact_result compact_result;
> +	int compaction_retries = 0;
>  	int contended_compaction = COMPACT_CONTENDED_NONE;
>  	int no_progress_loops = 0;
>  
> @@ -3227,10 +3256,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
>  					migration_mode,
>  					&contended_compaction,
> -					&deferred_compaction);
> +					&compact_result);
>  	if (page)
>  		goto got_pg;
>  
> +	if (order && compaction_made_progress(compact_result))
> +		compaction_retries++;
> +
>  	/* Checks for THP-specific high-order allocations */
>  	if (is_thp_gfp_mask(gfp_mask)) {
>  		/*
> @@ -3240,7 +3272,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * to heavily disrupt the system, so we fail the allocation
>  		 * instead of entering direct reclaim.
>  		 */
> -		if (deferred_compaction)
> +		if (compact_result == COMPACT_DEFERRED)
>  			goto nopage;
>  
>  		/*
> @@ -3294,6 +3326,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				 did_some_progress > 0, no_progress_loops))
>  		goto retry;
>  
> +	if (should_compact_retry(order, compact_result, contended_compaction,
> +				 compaction_retries))
> +		goto retry;
> +
>  	/* Reclaim has failed us, start killing things */
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>  	if (page)
> @@ -3314,7 +3350,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
>  					    ac, migration_mode,
>  					    &contended_compaction,
> -					    &deferred_compaction);
> +					    &compact_result);
>  	if (page)
>  		goto got_pg;
>  nopage:
> -- 
> 2.7.0
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
