Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BD29D82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 00:10:24 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so55010486pad.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 21:10:24 -0700 (PDT)
Received: from out4133-146.mail.aliyun.com (out4133-146.mail.aliyun.com. [42.120.133.146])
        by mx.google.com with ESMTP id vs7si7656278pab.78.2015.10.29.21.10.23
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 21:10:23 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org> <1446131835-3263-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1446131835-3263-2-git-send-email-mhocko@kernel.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Date: Fri, 30 Oct 2015 12:10:15 +0800
Message-ID: <00f201d112c8$e2377720$a6a66560$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

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
> @@ -2984,6 +2991,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>  	bool deferred_compaction = false;
>  	int contended_compaction = COMPACT_CONTENDED_NONE;
> +	struct zone *zone;
> +	struct zoneref *z;
> +	int stall_backoff = 0;
> 
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3135,13 +3145,56 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (gfp_mask & __GFP_NORETRY)
>  		goto noretry;
> 
> -	/* Keep reclaiming pages as long as there is reasonable progress */
> +	/*
> +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> +	 * and even then do not retry endlessly.
> +	 */
>  	pages_reclaimed += did_some_progress;
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

		target = reclaimable - stall_backoff * (1 + target/MAX_STALL_BACKOFF);
		             = reclaimable - stall_backoff - stall_backoff  * (target/MAX_STALL_BACKOFF);

then the first stall_backoff looks unreasonable.
I guess you mean
		target	= reclaimable - target * (stall_backoff/MAX_STALL_BACKOFF);
			= reclaimable - stall_back * (target/MAX_STALL_BACKOFF);

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
[...]
/*
> @@ -2734,10 +2730,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		goto retry;
>  	}
> 
> -	/* Any of the zones still reclaimable?  Don't OOM. */
> -	if (zones_reclaimable)
> -		return 1;
> -

Looks cleanup of zones_reclaimable left.
>  	return 0;
>  }
> 
> --
> 2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
