Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 050466B0257
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:34:42 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l68so152572182wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:34:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si4132083wjf.128.2016.03.08.06.34.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 06:34:40 -0800 (PST)
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-4-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEE2FD.4000105@suse.cz>
Date: Tue, 8 Mar 2016 15:34:37 +0100
MIME-Version: 1.0
In-Reply-To: <1457444565-10524-4-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 03/08/2016 02:42 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
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
> if should_reclaim_retry tells us to oom if the last compaction round
> was either inactive (deferred, skipped or bailed out early due to
> contention) or it told us to continue.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/compaction.h |  5 +++++
>  mm/page_alloc.c            | 53 ++++++++++++++++++++++++++++++++--------------
>  2 files changed, 42 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index b167801187e7..49e04326dcb8 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -14,6 +14,11 @@ enum compact_result {
>  	/* compaction should continue to another pageblock */
>  	COMPACT_CONTINUE,
>  	/*
> +	 * whoever is calling compaction should retry because it was either
> +	 * not active or it tells us there is more work to be done.
> +	 */
> +	COMPACT_SHOULD_RETRY = COMPACT_CONTINUE,

Hmm, I'm not sure about this. AFAIK compact_zone() doesn't ever return
COMPACT_CONTINUE, and thus try_to_compact_pages() also doesn't. This
overloading of CONTINUE only applies to compaction_suitable(). But the
value that should_compact_retry() is testing comes only from
try_to_compact_pages(). So this is not wrong, but perhaps a bit misleading?

> +	/*
>  	 * direct compaction partially compacted a zone and there are suitable
>  	 * pages
>  	 */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4acc0aa1aee0..041aeb1dc3b4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2819,28 +2819,20 @@ static struct page *
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
> @@ -2870,15 +2862,41 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  
>  	return NULL;
>  }
> +
> +static inline bool
> + (unsigned int order, enum compact_result compact_result,
> +		     int contended_compaction)
> +{
> +	/*
> +	 * !costly allocations are really important and we have to make sure
> +	 * the compaction wasn't deferred or didn't bail out early due to locks
> +	 * contention before we go OOM.
> +	 */
> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> +		if (compact_result <= COMPACT_SHOULD_RETRY)
> +			return true;
> +		if (contended_compaction > COMPACT_CONTENDED_NONE)
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
> +		     int contended_compaction)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_COMPACTION */
>  
>  /* Perform direct synchronous page reclaim */
> @@ -3118,7 +3136,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	int alloc_flags;
>  	unsigned long did_some_progress;
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> -	bool deferred_compaction = false;
> +	enum compact_result compact_result;
>  	int contended_compaction = COMPACT_CONTENDED_NONE;
>  	int no_progress_loops = 0;
>  
> @@ -3227,7 +3245,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
>  					migration_mode,
>  					&contended_compaction,
> -					&deferred_compaction);
> +					&compact_result);
>  	if (page)
>  		goto got_pg;
>  
> @@ -3240,7 +3258,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * to heavily disrupt the system, so we fail the allocation
>  		 * instead of entering direct reclaim.
>  		 */
> -		if (deferred_compaction)
> +		if (compact_result == COMPACT_DEFERRED)
>  			goto nopage;
>  
>  		/*
> @@ -3294,6 +3312,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				 did_some_progress > 0, no_progress_loops))
>  		goto retry;
>  
> +	if (should_compact_retry(order, compact_result, contended_compaction))
> +		goto retry;
> +
>  	/* Reclaim has failed us, start killing things */
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>  	if (page)
> @@ -3314,7 +3335,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
>  					    ac, migration_mode,
>  					    &contended_compaction,
> -					    &deferred_compaction);
> +					    &compact_result);
>  	if (page)
>  		goto got_pg;
>  nopage:
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
