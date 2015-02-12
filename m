Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0E9900016
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:31 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so5578051wiv.2
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si3830808wiv.7.2015.02.12.08.19.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 08:19:15 -0800 (PST)
Message-ID: <54DCD27E.3060304@suse.cz>
Date: Thu, 12 Feb 2015 17:19:10 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in too_many_isolated
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>	<20150115171728.ebc77a48.akpm@linux-foundation.org>	<54BA8DEC.1080508@codeaurora.org> <20150211141433.2a46f06668e5a64c21f94375@linux-foundation.org>
In-Reply-To: <20150211141433.2a46f06668e5a64c21f94375@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, mhocko@suse.cz, mgorman@suse.de, minchan@kernel.org

On 02/11/2015 11:14 PM, Andrew Morton wrote:
> 
> Did we end up deciding to merge this, or is
> http://ozlabs.org/~akpm/mmots/broken-out/vmstat-do-not-use-deferrable-delayed-work-for-vmstat_update.patch
> a sufficient fix?

I think Michal wanted to have the general vmstat worker fix from elsewhere in
the thread tested, if it solves the problem by itself, without this patch.

> From: Vinayak Menon <vinmenon@codeaurora.org>
> Subject: mm: vmscan: fix the page state calculation in too_many_isolated
> 
> It is observed that sometimes multiple tasks get blocked for long in the
> congestion_wait loop below, in shrink_inactive_list.  This is because of
> vm_stat values not being synced.
> 
> (__schedule) from [<c0a03328>]
> (schedule_timeout) from [<c0a04940>]
> (io_schedule_timeout) from [<c01d585c>]
> (congestion_wait) from [<c01cc9d8>]
> (shrink_inactive_list) from [<c01cd034>]
> (shrink_zone) from [<c01cdd08>]
> (try_to_free_pages) from [<c01c442c>]
> (__alloc_pages_nodemask) from [<c01f1884>]
> (new_slab) from [<c09fcf60>]
> (__slab_alloc) from [<c01f1a6c>]
> 
> In one such instance, zone_page_state(zone, NR_ISOLATED_FILE) had returned
> 14, zone_page_state(zone, NR_INACTIVE_FILE) returned 92, and GFP_IOFS was
> set, and this resulted in too_many_isolated returning true.  But one of
> the CPU's pageset vm_stat_diff had NR_ISOLATED_FILE as "-14".  So the
> actual isolated count was zero.  As there weren't any more updates to
> NR_ISOLATED_FILE and vmstat_update deffered work had not been scheduled
> yet, 7 tasks were spinning in the congestion wait loop for around 4
> seconds, in the direct reclaim path.
> 
> This patch uses zone_page_state_snapshot instead, but restricts its usage
> to avoid performance penalty.
> 
> 
> The vmstat sync interval is HZ (sysctl_stat_interval), but since the
> vmstat_work is declared as a deferrable work, the timer trigger can be
> deferred to the next non-defferable timer expiry on the CPU which is in
> idle.  This results in the vmstat syncing on an idle CPU being delayed by
> seconds.  May be in most cases this behavior is fine, except in cases like
> this.
> 
> [akpm@linux-foundation.org: move zone_page_state_snapshot() fallback logic into too_many_isolated()]
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/vmscan.c |   51 +++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 34 insertions(+), 17 deletions(-)
> 
> diff -puN mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated mm/vmscan.c
> --- a/mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated
> +++ a/mm/vmscan.c
> @@ -1363,6 +1363,32 @@ int isolate_lru_page(struct page *page)
>  	return ret;
>  }
>  
> +static int __too_many_isolated(struct zone *zone, int file,
> +			       struct scan_control *sc, int safe)
> +{
> +	unsigned long inactive, isolated;
> +
> +	if (safe) {
> +		inactive = zone_page_state_snapshot(zone,
> +				NR_INACTIVE_ANON + 2 * file);
> +		isolated = zone_page_state_snapshot(zone,
> +				NR_ISOLATED_ANON + file);
> +	} else {
> +		inactive = zone_page_state(zone, NR_INACTIVE_ANON + 2 * file);
> +		isolated = zone_page_state(zone, NR_ISOLATED_ANON + file);
> +	}
> +
> +	/*
> +	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so they
> +	 * won't get blocked by normal direct-reclaimers, forming a circular
> +	 * deadlock.
> +	 */
> +	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
> +		inactive >>= 3;
> +
> +	return isolated > inactive;
> +}
> +
>  /*
>   * A direct reclaimer may isolate SWAP_CLUSTER_MAX pages from the LRU list and
>   * then get resheduled. When there are massive number of tasks doing page
> @@ -1371,33 +1397,24 @@ int isolate_lru_page(struct page *page)
>   * unnecessary swapping, thrashing and OOM.
>   */
>  static int too_many_isolated(struct zone *zone, int file,
> -		struct scan_control *sc)
> +			     struct scan_control *sc)
>  {
> -	unsigned long inactive, isolated;
> -
>  	if (current_is_kswapd())
>  		return 0;
>  
>  	if (!global_reclaim(sc))
>  		return 0;
>  
> -	if (file) {
> -		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> -		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
> -	} else {
> -		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> -		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> -	}
> -
>  	/*
> -	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so they
> -	 * won't get blocked by normal direct-reclaimers, forming a circular
> -	 * deadlock.
> +	 * __too_many_isolated(safe=0) is fast but inaccurate, because it
> +	 * doesn't account for the vm_stat_diff[] counters.  So if it looks
> +	 * like too_many_isolated() is about to return true, fall back to the
> +	 * slower, more accurate zone_page_state_snapshot().
>  	 */
> -	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
> -		inactive >>= 3;
> +	if (unlikely(__too_many_isolated(zone, file, sc, 0)))
> +		return __too_many_isolated(zone, file, sc, 1);
>  
> -	return isolated > inactive;
> +	return 0;
>  }
>  
>  static noinline_for_stack void
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
