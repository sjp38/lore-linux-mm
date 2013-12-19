Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id F109C6B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 08:12:37 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so468754eek.10
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 05:12:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si4231051eeo.233.2013.12.19.05.12.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 05:12:37 -0800 (PST)
Date: Thu, 19 Dec 2013 14:12:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v4
Message-ID: <20131219131236.GG10855@dhcp22.suse.cz>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
 <20131218210617.GC20038@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218210617.GC20038@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 18-12-13 16:06:17, Johannes Weiner wrote:
[...]
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: revert NUMA aspect of fair allocation
>  policy
> 
> 81c0a2bb ("mm: page_alloc: fair zone allocator policy") meant to bring
> aging fairness among zones in system, but it was overzealous and badly
> regressed basic workloads on NUMA systems.
> 
> Due to the way kswapd and page allocator interacts, we still want to
> make sure that all zones in any given node are used equally for all
> allocations to maximize memory utilization and prevent thrashing on
> the highest zone in the node.
> 
> While the same principle applies to NUMA nodes - memory utilization is
> obviously improved by spreading allocations throughout all nodes -
> remote references can be costly and so many workloads prefer locality
> over memory utilization.  The original change assumed that
> zone_reclaim_mode would be a good enough predictor for that, but it
> turned out to be as indicative as a coin flip.

We generaly suggest to disable zone_reclaim_mode because it does more
harm than good in 90% of situations.

> Revert the NUMA aspect of the fairness until we can find a proper way
> to make it configurable and agree on a sane default.

OK, so you have dropped zone_local change which is good IMO. We still
might allocate from !local node but it will be in the local distance so
it shouldn't be harmful from the performance point of view. Zone NUMA
statistics might be skewed a bit - especially NUMA misses but that would
be a separate issue - why do we even count such allocations as misses?
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@kernel.org> # 3.12

Anyway
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_alloc.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd886fac451a..c5939317984f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1919,18 +1919,17 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
>  		 * page was allocated in should have no effect on the
>  		 * time the page has in memory before being reclaimed.
>  		 *
> -		 * When zone_reclaim_mode is enabled, try to stay in
> -		 * local zones in the fastpath.  If that fails, the
> -		 * slowpath is entered, which will do another pass
> -		 * starting with the local zones, but ultimately fall
> -		 * back to remote zones that do not partake in the
> -		 * fairness round-robin cycle of this zonelist.
> +		 * Try to stay in local zones in the fastpath.  If
> +		 * that fails, the slowpath is entered, which will do
> +		 * another pass starting with the local zones, but
> +		 * ultimately fall back to remote zones that do not
> +		 * partake in the fairness round-robin cycle of this
> +		 * zonelist.
>  		 */
>  		if (alloc_flags & ALLOC_WMARK_LOW) {
>  			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
>  				continue;
> -			if (zone_reclaim_mode &&
> -			    !zone_local(preferred_zone, zone))
> +			if (!zone_local(preferred_zone, zone))
>  				continue;
>  		}
>  		/*
> @@ -2396,7 +2395,7 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * thrash fairness information for zones that are not
>  		 * actually part of this zonelist's round-robin cycle.
>  		 */
> -		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
> +		if (!zone_local(preferred_zone, zone))
>  			continue;
>  		mod_zone_page_state(zone, NR_ALLOC_BATCH,
>  				    high_wmark_pages(zone) -
> -- 
> 1.8.4.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
