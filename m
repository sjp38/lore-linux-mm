Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DB48C6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 18:01:41 -0500 (EST)
Received: by pacej9 with SMTP id ej9so94961576pac.2
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:01:41 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id o6si14512948pap.162.2015.11.19.15.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 15:01:40 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so95031132pac.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:01:40 -0800 (PST)
Date: Thu, 19 Nov 2015 15:01:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
In-Reply-To: <1447851840-15640-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511191455310.17510@chino.kir.corp.google.com>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org> <1447851840-15640-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>

On Wed, 18 Nov 2015, Michal Hocko wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8034909faad2..020c005c5bc0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2992,6 +2992,13 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
>  	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
>  }
>  
> +/*
> + * Number of backoff steps for potentially reclaimable pages if the direct reclaim
> + * cannot make any progress. Each step will reduce 1/MAX_STALL_BACKOFF of the
> + * reclaimable memory.
> + */
> +#define MAX_STALL_BACKOFF 16
> +
>  static inline struct page *
>  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  						struct alloc_context *ac)
> @@ -3004,6 +3011,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>  	bool deferred_compaction = false;
>  	int contended_compaction = COMPACT_CONTENDED_NONE;
> +	struct zone *zone;
> +	struct zoneref *z;
> +	int stall_backoff = 0;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3155,13 +3165,57 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (gfp_mask & __GFP_NORETRY)
>  		goto noretry;
>  
> -	/* Keep reclaiming pages as long as there is reasonable progress */
> +	/*
> +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> +	 * and even then do not retry endlessly unless explicitly told so
> +	 */
>  	pages_reclaimed += did_some_progress;
> -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
> -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
> -		/* Wait for some write requests to complete then retry */
> -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> -		goto retry;
> +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> +		if (!(gfp_mask & __GFP_NOFAIL) &&
> +		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> +			goto noretry;
> +
> +		if (did_some_progress)
> +			goto retry;
> +	}

First of all, thanks very much for attacking this issue!

I'm concerned that we'll reach stall_backoff == MAX_STALL_BACKOFF too 
quickly if the wait_iff_congested() is removed.  While not immediately 
being available for reclaim, this has at least partially stalled in the 
past which may have resulted in external memory freeing.  I'm wondering if 
it would make sense to keep if nothing more than to avoid an immediate 
retry.

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

This is concerning, I would think that you would want to use 
zone_page_state_snapshot() at the very list for when 
stall_backoff == MAX_STALL_BACKOFF.

> +		unsigned long reclaimable;
> +		unsigned long target;
> +
> +		reclaimable = zone_reclaimable_pages(zone) +
> +			      zone_page_state(zone, NR_ISOLATED_FILE) +
> +			      zone_page_state(zone, NR_ISOLATED_ANON);

Does NR_ISOLATED_ANON mean anything relevant here in swapless 
environments?

> +		target = reclaimable;
> +		target -= DIV_ROUND_UP(stall_backoff * target, MAX_STALL_BACKOFF);
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
>  	}
>  
>  	/* Reclaim has failed us, start killing things */
> @@ -3170,8 +3224,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto got_pg;
>  
>  	/* Retry as long as the OOM killer is making progress */
> -	if (did_some_progress)
> +	if (did_some_progress) {
> +		stall_backoff = 0;
>  		goto retry;
> +	}
>  
>  noretry:
>  	/*
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a4507ecaefbf..9060a71e5a90 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -192,7 +192,7 @@ static bool sane_reclaim(struct scan_control *sc)
>  }
>  #endif
>  
> -static unsigned long zone_reclaimable_pages(struct zone *zone)
> +unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
>  	unsigned long nr;
>  
> @@ -2594,10 +2594,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  
>  		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
>  			reclaimable = true;
> -
> -		if (global_reclaim(sc) &&
> -		    !reclaimable && zone_reclaimable(zone))
> -			reclaimable = true;
>  	}
>  
>  	/*

It's possible to just make shrink_zones() void and drop the reclaimable 
variable.

Otherwise looks good!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
