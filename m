Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF7282F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:24:25 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so62977800pad.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 22:24:25 -0700 (PDT)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id nc3si8145253pbc.24.2015.10.29.22.24.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 22:24:24 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id CCFBDAC03A5
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 14:24:19 +0900 (JST)
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-2-git-send-email-mhocko@kernel.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <5632FEEF.2050709@jp.fujitsu.com>
Date: Fri, 30 Oct 2015 14:23:59 +0900
MIME-Version: 1.0
In-Reply-To: <1446131835-3263-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2015/10/30 0:17, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_slowpath has traditionally relied on the direct reclaim
> and did_some_progress as an indicator that it makes sense to retry
> allocation rather than declaring OOM. shrink_zones had to rely on
> zone_reclaimable if shrink_zone didn't make any progress to prevent
> from pre mature OOM killer invocation - the LRU might be full of dirty
> or writeback pages and direct reclaim cannot clean those up.
> 
> zone_reclaimable will allow to rescan the reclaimable lists several
> times and restart if a page is freed. This is really subtle behavior
> and it might lead to a livelock when a single freed page keeps allocator
> looping but the current task will not be able to allocate that single
> page. OOM killer would be more appropriate than looping without any
> progress for unbounded amount of time.
> 
> This patch changes OOM detection logic and pulls it out from shrink_zone
> which is too low to be appropriate for any high level decisions such as OOM
> which is per zonelist property. It is __alloc_pages_slowpath which knows
> how many attempts have been done and what was the progress so far
> therefore it is more appropriate to implement this logic.
> 
> The new heuristic tries to be more deterministic and easier to follow.
> Retrying makes sense only if the currently reclaimable memory + free
> pages would allow the current allocation request to succeed (as per
> __zone_watermark_ok) at least for one zone in the usable zonelist.
> 
> This alone wouldn't be sufficient, though, because the writeback might
> get stuck and reclaimable pages might be pinned for a really long time
> or even depend on the current allocation context. Therefore there is a
> feedback mechanism implemented which reduces the reclaim target after
> each reclaim round without any progress. This means that we should
> eventually converge to only NR_FREE_PAGES as the target and fail on the
> wmark check and proceed to OOM. The backoff is simple and linear with
> 1/16 of the reclaimable pages for each round without any progress. We
> are optimistic and reset counter for successful reclaim rounds.
> 
> Costly high order pages mostly preserve their semantic and those without
> __GFP_REPEAT fail right away while those which have the flag set will
> back off after the amount of reclaimable pages reaches equivalent of the
> requested order. The only difference is that if there was no progress
> during the reclaim we rely on zone watermark check. This is more logical
> thing to do than previous 1<<order attempts which were a result of
> zone_reclaimable faking the progress.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   include/linux/swap.h |  1 +
>   mm/page_alloc.c      | 69 ++++++++++++++++++++++++++++++++++++++++++++++------
>   mm/vmscan.c          | 10 +-------
>   3 files changed, 64 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 9c7c4b418498..8298e1dc20f9 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -317,6 +317,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
>   						struct vm_area_struct *vma);
>   
>   /* linux/mm/vmscan.c */
> +extern unsigned long zone_reclaimable_pages(struct zone *zone);
>   extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>   					gfp_t gfp_mask, nodemask_t *mask);
>   extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c73913648357..9c0abb75ad53 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2972,6 +2972,13 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
>   	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
>   }
>   
> +/*
> + * Number of backoff steps for potentially reclaimable pages if the direct reclaim
> + * cannot make any progress. Each step will reduce 1/MAX_STALL_BACKOFF of the
> + * reclaimable memory.
> + */
> +#define MAX_STALL_BACKOFF 16
> +
>   static inline struct page *
>   __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   						struct alloc_context *ac)
> @@ -2984,6 +2991,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>   	bool deferred_compaction = false;
>   	int contended_compaction = COMPACT_CONTENDED_NONE;
> +	struct zone *zone;
> +	struct zoneref *z;
> +	int stall_backoff = 0;
>   
>   	/*
>   	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3135,13 +3145,56 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   	if (gfp_mask & __GFP_NORETRY)
>   		goto noretry;
>   
> -	/* Keep reclaiming pages as long as there is reasonable progress */
> +	/*
> +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> +	 * and even then do not retry endlessly.
> +	 */
>   	pages_reclaimed += did_some_progress;
> -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
> -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
> -		/* Wait for some write requests to complete then retry */
> -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> -		goto retry;
> +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> +		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
> +			goto noretry;
> +
> +		if (did_some_progress)
> +			goto retry;

why directly retry here ?


> +	}
> +
> +	/*
> +	 * Be optimistic and consider all pages on reclaimable LRUs as usable
> +	 * but make sure we converge to OOM if we cannot make any progress after
> +	 * multiple consecutive failed attempts.
> +	 */
> +	if (did_some_progress)
> +		stall_backoff = 0;
> +	else
> +		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF);
> +
> +	/*
> +	 * Keep reclaiming pages while there is a chance this will lead somewhere.
> +	 * If none of the target zones can satisfy our allocation request even
> +	 * if all reclaimable pages are considered then we are screwed and have
> +	 * to go OOM.
> +	 */
> +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
> +		unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
> +		unsigned long reclaimable;
> +		unsigned long target;
> +
> +		reclaimable = zone_reclaimable_pages(zone) +
> +			      zone_page_state(zone, NR_ISOLATED_FILE) +
> +			      zone_page_state(zone, NR_ISOLATED_ANON);
> +		target = reclaimable;
> +		target -= stall_backoff * (1 + target/MAX_STALL_BACKOFF);
> +		target += free;
> +
> +		/*
> +		 * Would the allocation succeed if we reclaimed the whole target?
> +		 */
> +		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> +				ac->high_zoneidx, alloc_flags, target)) {
> +			/* Wait for some write requests to complete then retry */
> +			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> +			goto retry;
> +		}
>   	}
>   
>   	/* Reclaim has failed us, start killing things */
> @@ -3150,8 +3203,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   		goto got_pg;
>   
>   	/* Retry as long as the OOM killer is making progress */
> -	if (did_some_progress)
> +	if (did_some_progress) {
> +		stall_backoff = 0;
>   		goto retry;
> +	}

Umm ? I'm sorry that I didn't notice page allocation may fail even if order < PAGE_ALLOC_COSTLY_ORDER.
I thought old logic ignores did_some_progress. It seems a big change.

So, now, 0-order page allocation may fail in a OOM situation ?

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
