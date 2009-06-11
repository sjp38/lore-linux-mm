Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 04E3E6B005D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 07:15:27 -0400 (EDT)
Date: Thu, 11 Jun 2009 12:15:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH for mmotm 5/5] fix
	vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
Message-ID: <20090611111550.GF7302@csn.ul.ie>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com> <20090611192757.6D59.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090611192757.6D59.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 07:28:30PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] fix vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch 
> 
> 
> +	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
> +				 zone_page_state(zone, NR_ACTIVE_FILE) -
> +				 zone_page_state(zone, NR_FILE_MAPPED);
> 
> is wrong. it can be underflow because tmpfs pages are not counted NR_*_FILE,
> but they are counted NR_FILE_MAPPED.
> 
> fixing here.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/vmscan.c |   32 ++++++++++++++++++++------------
>  1 file changed, 20 insertions(+), 12 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2333,6 +2333,23 @@ int sysctl_min_unmapped_ratio = 1;
>   */
>  int sysctl_min_slab_ratio = 5;
>  
> +static unsigned long zone_unmapped_file_pages(struct zone *zone)
> +{
> +	long nr_file_pages;
> +	long nr_file_mapped;
> +	long nr_unmapped_file_pages;
> +
> +	nr_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
> +			zone_page_state(zone, NR_ACTIVE_FILE);
> +	nr_file_mapped = zone_page_state(zone, NR_FILE_MAPPED) -
> +			 zone_page_state(zone,
> +					NR_SWAP_BACKED_FILE_MAPPED);
> +	nr_unmapped_file_pages = nr_file_pages - nr_file_mapped;
> +
> +	return nr_unmapped_file_pages > 0 ? nr_unmapped_file_pages : 0;
> +}

This is a more accurate calculation for sure. The question is - is it
necessary?

> +
> +
>  /*
>   * Try to free up some pages from this zone through reclaim.
>   */
> @@ -2355,7 +2372,6 @@ static int __zone_reclaim(struct zone *z
>  		.isolate_pages = isolate_pages_global,
>  	};
>  	unsigned long slab_reclaimable;
> -	long nr_unmapped_file_pages;
>  
>  	disable_swap_token();
>  	cond_resched();
> @@ -2368,11 +2384,7 @@ static int __zone_reclaim(struct zone *z
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
>  
> -	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
> -				 zone_page_state(zone, NR_ACTIVE_FILE) -
> -				 zone_page_state(zone, NR_FILE_MAPPED);
> -
> -	if (nr_unmapped_file_pages > zone->min_unmapped_pages) {
> +	if (zone_unmapped_file_pages(zone) > zone->min_unmapped_pages) {
>  		/*
>  		 * Free memory by calling shrink zone with increasing
>  		 * priorities until we have enough memory freed.
> @@ -2419,8 +2431,7 @@ int zone_reclaim(struct zone *zone, gfp_
>  {
>  	int node_id;
>  	int ret;
> -	long nr_unmapped_file_pages;
> -	long nr_slab_reclaimable;
> +	unsigned long nr_slab_reclaimable;
>  
>  	/*
>  	 * Zone reclaim reclaims unmapped file backed pages and
> @@ -2432,11 +2443,8 @@ int zone_reclaim(struct zone *zone, gfp_
>  	 * if less than a specified percentage of the zone is used by
>  	 * unmapped file backed pages.
>  	 */
> -	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
> -				 zone_page_state(zone, NR_ACTIVE_FILE) -
> -				 zone_page_state(zone, NR_FILE_MAPPED);
>  	nr_slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> -	if (nr_unmapped_file_pages <= zone->min_unmapped_pages &&
> +	if (zone_unmapped_file_pages(zone) <= zone->min_unmapped_pages &&
>  	    nr_slab_reclaimable <= zone->min_slab_pages)
>  		return 0;
>  
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
