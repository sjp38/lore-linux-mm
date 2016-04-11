Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id A45276B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:39:25 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id n3so107690828wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:39:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o189si6283768wmd.58.2016.04.11.07.39.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 07:39:24 -0700 (PDT)
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570BB719.2030007@suse.cz>
Date: Mon, 11 Apr 2016 16:39:21 +0200
MIME-Version: 1.0
In-Reply-To: <1459855533-4600-10-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/05/2016 01:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> Compaction can provide a wild variation of feedback to the caller. Many
> of them are implementation specific and the caller of the compaction
> (especially the page allocator) shouldn't be bound to specifics of the
> current implementation.
>
> This patch abstracts the feedback into three basic types:
> 	- compaction_made_progress - compaction was active and made some
> 	  progress.
> 	- compaction_failed - compaction failed and further attempts to
> 	  invoke it would most probably fail and therefore it is not
> 	  worth retrying
> 	- compaction_withdrawn - compaction wasn't invoked for an
>            implementation specific reasons. In the current implementation
>            it means that the compaction was deferred, contended or the
>            page scanners met too early without any progress. Retrying is
>            still worthwhile.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   include/linux/compaction.h | 74 ++++++++++++++++++++++++++++++++++++++++++++++
>   mm/page_alloc.c            | 25 ++++------------
>   2 files changed, 80 insertions(+), 19 deletions(-)
>
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index a7b9091ff349..512db9c3f0ed 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -78,6 +78,70 @@ extern void compaction_defer_reset(struct zone *zone, int order,
>   				bool alloc_success);
>   extern bool compaction_restarting(struct zone *zone, int order);
>
> +/* Compaction has made some progress and retrying makes sense */
> +static inline bool compaction_made_progress(enum compact_result result)
> +{
> +	/*
> +	 * Even though this might sound confusing this in fact tells us
> +	 * that the compaction successfully isolated and migrated some
> +	 * pageblocks.
> +	 */
> +	if (result == COMPACT_PARTIAL)
> +		return true;
> +
> +	return false;
> +}
> +
> +/* Compaction has failed and it doesn't make much sense to keep retrying. */
> +static inline bool compaction_failed(enum compact_result result)
> +{
> +	/* All zones where scanned completely and still not result. */

Hmm given that try_to_compact_pages() uses a max() on results, then in 
fact it takes only one zone to get this. Others could have been also 
SKIPPED or DEFERRED. Is that what you want?

> +	if (result == COMPACT_COMPLETE)
> +		return true;
> +
> +	return false;
> +}
> +
> +/*
> + * Compaction  has backed off for some reason. It might be throttling or
> + * lock contention. Retrying is still worthwhile.
> + */
> +static inline bool compaction_withdrawn(enum compact_result result)
> +{
> +	/*
> +	 * Compaction backed off due to watermark checks for order-0
> +	 * so the regular reclaim has to try harder and reclaim something.
> +	 */
> +	if (result == COMPACT_SKIPPED)
> +		return true;
> +
> +	/*
> +	 * If compaction is deferred for high-order allocations, it is
> +	 * because sync compaction recently failed. If this is the case
> +	 * and the caller requested a THP allocation, we do not want
> +	 * to heavily disrupt the system, so we fail the allocation
> +	 * instead of entering direct reclaim.
> +	 */
> +	if (result == COMPACT_DEFERRED)
> +		return true;
> +
> +	/*
> +	 * If compaction in async mode encounters contention or blocks higher
> +	 * priority task we back off early rather than cause stalls.
> +	 */
> +	if (result == COMPACT_CONTENDED)
> +		return true;
> +
> +	/*
> +	 * Page scanners have met but we haven't scanned full zones so this
> +	 * is a back off in fact.
> +	 */
> +	if (result == COMPACT_PARTIAL_SKIPPED)
> +		return true;
> +
> +	return false;
> +}
> +

[...]

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c37e6d1ad643..c05de84c8157 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3362,25 +3362,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   	if (page)
>   		goto got_pg;
>
> -	/* Checks for THP-specific high-order allocations */
> -	if (is_thp_gfp_mask(gfp_mask)) {
> -		/*
> -		 * If compaction is deferred for high-order allocations, it is
> -		 * because sync compaction recently failed. If this is the case
> -		 * and the caller requested a THP allocation, we do not want
> -		 * to heavily disrupt the system, so we fail the allocation
> -		 * instead of entering direct reclaim.
> -		 */
> -		if (compact_result == COMPACT_DEFERRED)
> -			goto nopage;
> -
> -		/*
> -		 * Compaction is contended so rather back off than cause
> -		 * excessive stalls.
> -		 */
> -		if(compact_result == COMPACT_CONTENDED)
> -			goto nopage;
> -	}
> +	/*
> +	 * Checks for THP-specific high-order allocations and back off
> +	 * if the the compaction backed off
> +	 */
> +	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
> +		goto nopage;

The change of semantics for THP is not trivial here and should at least 
be discussed in changelog. CONTENDED and DEFERRED is only subset of 
compaction_withdrawn() as seen above. Why is it useful to back off due 
to COMPACT_PARTIAL_SKIPPED (we were just unlucky in our starting 
position), but not due to COMPACT_COMPLETE (we have seen the whole zone 
but failed anyway)? Why back off due to COMPACT_SKIPPED (not enough 
order-0 pages) without trying reclaim at least once, and then another 
async compaction, like before?

>
>   	/*
>   	 * It can become very expensive to allocate transparent hugepages at
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
