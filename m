Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 462F0828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 17:58:28 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e65so107220380pfe.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 14:58:28 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id fi15si11944339pac.191.2016.01.14.14.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 14:58:27 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id uo6so368607164pac.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 14:58:27 -0800 (PST)
Date: Thu, 14 Jan 2016 14:58:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm, oom: rework oom detection
In-Reply-To: <1450203586-10959-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1601141436410.22665@chino.kir.corp.google.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <1450203586-10959-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 15 Dec 2015, Michal Hocko wrote:

> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 457181844b6e..738ae2206635 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -316,6 +316,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
>  						struct vm_area_struct *vma);
>  
>  /* linux/mm/vmscan.c */
> +extern unsigned long zone_reclaimable_pages(struct zone *zone);
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  					gfp_t gfp_mask, nodemask_t *mask);
>  extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e267faad4649..f77e283fb8c6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2984,6 +2984,75 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
>  	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
>  }
>  
> +/*
> + * Maximum number of reclaim retries without any progress before OOM killer
> + * is consider as the only way to move forward.
> + */
> +#define MAX_RECLAIM_RETRIES 16
> +
> +/*
> + * Checks whether it makes sense to retry the reclaim to make a forward progress
> + * for the given allocation request.
> + * The reclaim feedback represented by did_some_progress (any progress during
> + * the last reclaim round), pages_reclaimed (cumulative number of reclaimed
> + * pages) and no_progress_loops (number of reclaim rounds without any progress
> + * in a row) is considered as well as the reclaimable pages on the applicable
> + * zone list (with a backoff mechanism which is a function of no_progress_loops).
> + *
> + * Returns true if a retry is viable or false to enter the oom path.
> + */
> +static inline bool
> +should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> +		     struct alloc_context *ac, int alloc_flags,
> +		     bool did_some_progress, unsigned long pages_reclaimed,
> +		     int no_progress_loops)
> +{
> +	struct zone *zone;
> +	struct zoneref *z;
> +
> +	/*
> +	 * Make sure we converge to OOM if we cannot make any progress
> +	 * several times in the row.
> +	 */
> +	if (no_progress_loops > MAX_RECLAIM_RETRIES)
> +		return false;
> +
> +	/* Do not retry high order allocations unless they are __GFP_REPEAT */
> +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> +		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
> +			return false;
> +
> +		if (did_some_progress)
> +			return true;
> +	}
> +
> +	/*
> +	 * Keep reclaiming pages while there is a chance this will lead somewhere.
> +	 * If none of the target zones can satisfy our allocation request even
> +	 * if all reclaimable pages are considered then we are screwed and have
> +	 * to go OOM.
> +	 */
> +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
> +		unsigned long available;
> +
> +		available = zone_reclaimable_pages(zone);
> +		available -= DIV_ROUND_UP(no_progress_loops * available, MAX_RECLAIM_RETRIES);
> +		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +
> +		/*
> +		 * Would the allocation succeed if we reclaimed the whole available?
> +		 */
> +		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> +				ac->high_zoneidx, alloc_flags, available)) {
> +			/* Wait for some write requests to complete then retry */
> +			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> +			return true;
> +		}
> +	}

Tetsuo's log of an early oom in this thread shows that this check is 
wrong.  The allocation in question is an order-2 GFP_KERNEL on a system 
with only ZONE_DMA and ZONE_DMA32:

	zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
	zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50

and the watermarks:

	Node 0 DMA free:6908kB min:44kB low:52kB high:64kB ...
	lowmem_reserve[]: 0 1714 1714 1714
	Node 0 DMA32 free:17996kB min:5172kB low:6464kB high:7756kB  ...
	lowmem_reserve[]: 0 0 0 0

and the scary thing is that this triggers when no_progress_loops == 0, so 
this is the first time trying the allocation after progress has been made.

Watermarks clearly indicate that memory is available, the problem is 
fragmentation for the order-2 allocation.  This is not a situation where 
we want to immediately call the oom killer to solve since we have no 
guarantee it is going to free contiguous memory (in fact it wouldn't be 
used at all for PAGE_ALLOC_COSTLY_ORDER).

There is order-2 memory available however:

	Node 0 DMA32: 1113*4kB (UME) 1400*8kB (UME) 116*16kB (UM) 15*32kB (UM) 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18052kB

The failure for ZONE_DMA makes sense for the lowmem_reserve ratio, it's 
oom for this allocation.  ZONE_DMA32 is not, however.

I'm wondering if this has to do with the z->nr_reserved_highatomic 
estimate.  ZONE_DMA32 present pages is 2080640kB, so this would be limited 
to 1%, or 20806kB.  That failure would make sense if free is 17996kB.

Tetsuo, would it be possible to try your workload with just this match and 
also show z->nr_reserved_highatomic?

This patch would need to at least have knowledge of the heuristics used by 
__zone_watermark_ok() since it's making an inference on reclaimability 
based on numbers that include pageblocks that are reserved from usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
