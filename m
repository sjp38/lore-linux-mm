Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C41386B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 02:36:27 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id dh6so306358562obb.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 23:36:27 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id u194si29487336ith.14.2016.05.30.23.36.26
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 23:36:27 -0700 (PDT)
Date: Tue, 31 May 2016 15:37:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160531063740.GC30967@js1304-P5Q-DELUXE>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-13-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, May 10, 2016 at 09:36:02AM +0200, Vlastimil Babka wrote:
> During reclaim/compaction loop, compaction priority can be increased by the
> should_compact_retry() function, but the current code is not optimal for
> several reasons:
> 
> - priority is only increased when compaction_failed() is true, which means
>   that compaction has scanned the whole zone. This may not happen even after
>   multiple attempts with the lower priority due to parallel activity, so we
>   might needlessly struggle on the lower priority.
> 
> - should_compact_retry() is only called when should_reclaim_retry() returns
>   false. This means that compaction priority cannot get increased as long
>   as reclaim makes sufficient progress. Theoretically, reclaim should stop
>   retrying for high-order allocations as long as the high-order page doesn't
>   exist but due to races, this may result in spurious retries when the
>   high-order page momentarily does exist.
> 
> We can remove these corner cases by making sure that should_compact_retry() is
> always called, and increases compaction priority if possible. Examining further
> the compaction result can be done only after reaching the highest priority.
> This is a simple solution and we don't need to worry about reaching the highest
> priority "too soon" here - when should_compact_retry() is called it means that
> the system is already struggling and the allocation is supposed to either try
> as hard as possible, or it cannot fail at all. There's not much point staying
> at lower priorities with heuristics that may result in only partial compaction.
> 
> The only exception here is the COMPACT_SKIPPED result, which means that
> compaction could not run at all due to failing order-0 watermarks. In that
> case, don't increase compaction priority, and check if compaction could proceed
> when everything reclaimable was reclaimed. Before this patch, this was tied to
> compaction_withdrawn(), but the other results considered there are in fact only
> due to low compaction priority so we can ignore them thanks to the patch.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_alloc.c | 46 +++++++++++++++++++++++-----------------------
>  1 file changed, 23 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index aa9c39a7f40a..623027fb8121 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3248,28 +3248,27 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
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
> -		if (*compact_priority > 0) {
> -			(*compact_priority)--;
> -			return true;
> -		}
> -		return false;
> -	}
> +	if (compact_result == COMPACT_SKIPPED)
> +		return compaction_zonelist_suitable(ac, order, alloc_flags);
>  
>  	/*
> -	 * make sure the compaction wasn't deferred or didn't bail out early
> -	 * due to locks contention before we declare that we should give up.
> -	 * But do not retry if the given zonelist is not suitable for
> -	 * compaction.
> +	 * Compaction could have withdrawn early or skip some zones or
> +	 * pageblocks. We were asked to retry, which means the allocation
> +	 * should try really hard, so increase the priority if possible.
>  	 */
> -	if (compaction_withdrawn(compact_result))
> -		return compaction_zonelist_suitable(ac, order, alloc_flags);
> +	if (*compact_priority > 0) {
> +		(*compact_priority)--;
> +		return true;
> +	}
>  
>  	/*
> +	 * The remaining possibility is that compaction made progress and
> +	 * created a high-order page, but it was allocated by somebody else.
> +	 * To prevent thrashing, limit the number of retries in such case.
>  	 * !costly requests are much more important than __GFP_REPEAT
>  	 * costly ones because they are de facto nofail and invoke OOM
>  	 * killer to move on while costly can fail and users are ready
> @@ -3527,6 +3526,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  						struct alloc_context *ac)
>  {
>  	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
> +	bool should_retry;
>  	struct page *page = NULL;
>  	unsigned int alloc_flags;
>  	unsigned long did_some_progress;
> @@ -3695,22 +3695,22 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	else
>  		no_progress_loops++;
>  
> -	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> -				 did_some_progress > 0, no_progress_loops))
> -		goto retry;
> -
> +	should_retry = should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> +				 did_some_progress > 0, no_progress_loops);
>  	/*
>  	 * It doesn't make any sense to retry for the compaction if the order-0
>  	 * reclaim is not able to make any progress because the current
>  	 * implementation of the compaction depends on the sufficient amount
>  	 * of free memory (see __compaction_suitable)
>  	 */
> -	if (did_some_progress > 0 &&
> -			should_compact_retry(ac, order, alloc_flags,
> +	if (did_some_progress > 0)
> +		should_retry |= should_compact_retry(ac, order, alloc_flags,
>  				compact_result, &compact_priority,
> -				compaction_retries))
> +				compaction_retries);
> +	if (should_retry)
>  		goto retry;

Hmm... it looks odd that we check should_compact_retry() when
did_some_progress > 0. If system is full of anonymous memory and we
don't have swap, we can't reclaim anything but we can compact.

And, your patchset make me think that it's better to separate retry
loop for order-0 allocation and high-order allocation completely.

Current code is a mix of these two types of criteria and is hard to
follow. Your patchset make it simpler but we can do better if
separating them completely. Any thought?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
