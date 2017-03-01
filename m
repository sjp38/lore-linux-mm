Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2456F6B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 09:56:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y51so17959018wry.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 06:56:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j142si7240322wmg.127.2017.03.01.06.56.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 06:56:57 -0800 (PST)
Date: Wed, 1 Mar 2017 15:56:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 9/9] mm: remove unnecessary back-off function when
 retrying page reclaim
Message-ID: <20170301145656.GA11730@dhcp22.suse.cz>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-10-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228214007.5621-10-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 28-02-17 16:40:07, Johannes Weiner wrote:
> The backoff mechanism is not needed. If we have MAX_RECLAIM_RETRIES
> loops without progress, we'll OOM anyway; backing off might cut one or
> two iterations off that in the rare OOM case. If we have intermittent
> success reclaiming a few pages, the backoff function gets reset also,
> and so is of little help in these scenarios.

Yes, as already mentioned elsewhere the original intention was to a more
graceful oom convergence when we are trashing over last few reclaimable
pages but as the code evolved the result is not all that great.
 
> We might want a backoff function for when there IS progress, but not
> enough to be satisfactory. But this isn't that. Remove it.

Completely agreed.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9ac639864bed..223644afed28 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3511,11 +3511,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  /*
>   * Checks whether it makes sense to retry the reclaim to make a forward progress
>   * for the given allocation request.
> - * The reclaim feedback represented by did_some_progress (any progress during
> - * the last reclaim round) and no_progress_loops (number of reclaim rounds without
> - * any progress in a row) is considered as well as the reclaimable pages on the
> - * applicable zone list (with a backoff mechanism which is a function of
> - * no_progress_loops).
> + *
> + * We give up when we either have tried MAX_RECLAIM_RETRIES in a row
> + * without success, or when we couldn't even meet the watermark if we
> + * reclaimed all remaining pages on the LRU lists.
>   *
>   * Returns true if a retry is viable or false to enter the oom path.
>   */
> @@ -3560,13 +3559,11 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		bool wmark;
>  
>  		available = reclaimable = zone_reclaimable_pages(zone);
> -		available -= DIV_ROUND_UP((*no_progress_loops) * available,
> -					  MAX_RECLAIM_RETRIES);
>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>  
>  		/*
> -		 * Would the allocation succeed if we reclaimed the whole
> -		 * available?
> +		 * Would the allocation succeed if we reclaimed all
> +		 * reclaimable pages?
>  		 */
>  		wmark = __zone_watermark_ok(zone, order, min_wmark,
>  				ac_classzone_idx(ac), alloc_flags, available);
> -- 
> 2.11.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
