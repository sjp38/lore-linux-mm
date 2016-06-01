Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCFDD6B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 09:51:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so10149606lfg.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 06:51:27 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id c127si43626429wma.75.2016.06.01.06.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 06:51:26 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q62so7005380wmg.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 06:51:26 -0700 (PDT)
Date: Wed, 1 Jun 2016 15:51:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 12/18] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160601135124.GS26601@dhcp22.suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-13-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531130818.28724-13-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Tue 31-05-16 15:08:12, Vlastimil Babka wrote:
> During reclaim/compaction loop, compaction priority can be increased by the
> should_compact_retry() function, but the current code is not optimal. Priority
> is only increased when compaction_failed() is true, which means that compaction
> has scanned the whole zone. This may not happen even after multiple attempts
> with the lower priority due to parallel activity, so we might needlessly
> struggle on the lower priority.
> 
> We can remove these corner cases by increasing compaction priority regardless
> of compaction_failed(). Examining further the compaction result can be
> postponed only after reaching the highest priority. This is a simple solution
> and we don't need to worry about reaching the highest priority "too soon" here,
> because hen should_compact_retry() is called it means that the system is
> already struggling and the allocation is supposed to either try as hard as
> possible, or it cannot fail at all. There's not much point staying at lower
> priorities with heuristics that may result in only partial compaction.
> 
> The only exception here is the COMPACT_SKIPPED result, which means that
> compaction could not run at all due to being below order-0 watermarks. In that
> case, don't increase compaction priority, and check if compaction could proceed
> when everything reclaimable was reclaimed. Before this patch, this was tied to
> compaction_withdrawn(), but the other results considered there are in fact only
> possible due to low compaction priority so we can ignore them thanks to the
> patch. Since there are no other callers of compaction_withdrawn(), remove it.

I agree with the change in general. I think that keeping compaction_withdrawn
even with a single check is better because it abstracts the fact from a
specific constant.

Now that I think about that some more I guess you also want to update
compaction_retries inside should_compact_retry as well, or at least
update it only when we have reached the lowest priority. What do you
think?
 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Other than that this makes sense
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/compaction.h | 46 ----------------------------------------------
>  mm/page_alloc.c            | 37 ++++++++++++++++++++++---------------
>  2 files changed, 22 insertions(+), 61 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 29dc7c05bd3b..4bef69a83f8f 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -105,47 +105,6 @@ static inline bool compaction_failed(enum compact_result result)
>  	return false;
>  }
>  
> -/*
> - * Compaction  has backed off for some reason. It might be throttling or
> - * lock contention. Retrying is still worthwhile.
> - */
> -static inline bool compaction_withdrawn(enum compact_result result)
> -{
> -	/*
> -	 * Compaction backed off due to watermark checks for order-0
> -	 * so the regular reclaim has to try harder and reclaim something.
> -	 */
> -	if (result == COMPACT_SKIPPED)
> -		return true;
> -
> -	/*
> -	 * If compaction is deferred for high-order allocations, it is
> -	 * because sync compaction recently failed. If this is the case
> -	 * and the caller requested a THP allocation, we do not want
> -	 * to heavily disrupt the system, so we fail the allocation
> -	 * instead of entering direct reclaim.
> -	 */
> -	if (result == COMPACT_DEFERRED)
> -		return true;
> -
> -	/*
> -	 * If compaction in async mode encounters contention or blocks higher
> -	 * priority task we back off early rather than cause stalls.
> -	 */
> -	if (result == COMPACT_CONTENDED)
> -		return true;
> -
> -	/*
> -	 * Page scanners have met but we haven't scanned full zones so this
> -	 * is a back off in fact.
> -	 */
> -	if (result == COMPACT_PARTIAL_SKIPPED)
> -		return true;
> -
> -	return false;
> -}
> -
> -
>  bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  					int alloc_flags);
>  
> @@ -183,11 +142,6 @@ static inline bool compaction_failed(enum compact_result result)
>  	return false;
>  }
>  
> -static inline bool compaction_withdrawn(enum compact_result result)
> -{
> -	return true;
> -}
> -
>  static inline int kcompactd_run(int nid)
>  {
>  	return 0;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 27923af8e534..dee486936ccf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3235,28 +3235,35 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  		return false;
>  
>  	/*
> -	 * compaction considers all the zone as desperately out of memory
> -	 * so it doesn't really make much sense to retry except when the
> -	 * failure could be caused by insufficient priority
> +	 * Compaction backed off due to watermark checks for order-0
> +	 * so the regular reclaim has to try harder and reclaim something
> +	 * Retry only if it looks like reclaim might have a chance.
>  	 */
> -	if (compaction_failed(compact_result)) {
> -		if (*compact_priority > MIN_COMPACT_PRIORITY) {
> -			(*compact_priority)--;
> -			return true;
> -		}
> -		return false;
> +	if (compact_result == COMPACT_SKIPPED)
> +		return compaction_zonelist_suitable(ac, order, alloc_flags);
> +
> +	/*
> +	 * Compaction could have withdrawn early or skip some zones or
> +	 * pageblocks. We were asked to retry, which means the allocation
> +	 * should try really hard, so increase the priority if possible.
> +	 */
> +	if (*compact_priority > MIN_COMPACT_PRIORITY) {
> +		(*compact_priority)--;
> +		return true;
>  	}
>  
>  	/*
> -	 * make sure the compaction wasn't deferred or didn't bail out early
> -	 * due to locks contention before we declare that we should give up.
> -	 * But do not retry if the given zonelist is not suitable for
> -	 * compaction.
> +	 * Compaction considers all the zones as unfixably fragmented and we
> +	 * are on the highest priority, which means it can't be due to
> +	 * heuristics and it doesn't really make much sense to retry.
>  	 */
> -	if (compaction_withdrawn(compact_result))
> -		return compaction_zonelist_suitable(ac, order, alloc_flags);
> +	if (compaction_failed(compact_result))
> +		return false;
>  
>  	/*
> +	 * The remaining possibility is that compaction made progress and
> +	 * created a high-order page, but it was allocated by somebody else.
> +	 * To prevent thrashing, limit the number of retries in such case.
>  	 * !costly requests are much more important than __GFP_REPEAT
>  	 * costly ones because they are de facto nofail and invoke OOM
>  	 * killer to move on while costly can fail and users are ready
> -- 
> 2.8.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
