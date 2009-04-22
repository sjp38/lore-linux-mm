Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C28B6B00E5
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:31:36 -0400 (EDT)
Date: Wed, 22 Apr 2009 15:32:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] low order lumpy reclaim also should use
	PAGEOUT_IO_SYNC.
Message-ID: <20090422143201.GE15367@csn.ul.ie>
References: <20090421142056.F127.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421142056.F127.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 02:22:27PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.
> 
> commit 33c120ed2843090e2bd316de1588b8bf8b96cbde (more aggressively use lumpy reclaim)
> change lumpy reclaim using condition. but it isn't enough change.
> 
> lumpy reclaim don't only mean isolate neighber page, but also do pageout as synchronous.
> this patch does it.
> 
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Seems fair although the changelog could be better. Maybe something like?

====

Commit 33c120ed2843090e2bd316de1588b8bf8b96cbde increased how aggressive
lumpy reclaim was by isolating both active and inactive pages for asynchronous
lumpy reclaim on costly-high-order pages and for cheap-high-order when memory
pressure is high. However, if the system is under heavy pressure and there
are dirty pages, asynchronous IO may not be sufficient to reclaim a suitable
page in time.

This patch causes the caller to enter synchronous lumpy reclaim for
costly-high-order pages and for cheap-high-order pages when under memory
pressure.
====

Whether the changelog is updated or not though;

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/vmscan.c |   29 +++++++++++++++--------------
>  1 file changed, 15 insertions(+), 14 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1049,6 +1049,19 @@ static unsigned long shrink_inactive_lis
>  	unsigned long nr_scanned = 0;
>  	unsigned long nr_reclaimed = 0;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> +	int lumpy_reclaim = 0;
> +
> +	/*
> +	 * If we need a large contiguous chunk of memory, or have
> +	 * trouble getting a small set of contiguous pages, we
> +	 * will reclaim both active and inactive pages.
> +	 *
> +	 * We use the same threshold as pageout congestion_wait below.
> +	 */
> +	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> +		lumpy_reclaim = 1;
> +	else if (sc->order && priority < DEF_PRIORITY - 2)
> +		lumpy_reclaim = 1;
>  
>  	pagevec_init(&pvec, 1);
>  
> @@ -1061,19 +1074,7 @@ static unsigned long shrink_inactive_lis
>  		unsigned long nr_freed;
>  		unsigned long nr_active;
>  		unsigned int count[NR_LRU_LISTS] = { 0, };
> -		int mode = ISOLATE_INACTIVE;
> -
> -		/*
> -		 * If we need a large contiguous chunk of memory, or have
> -		 * trouble getting a small set of contiguous pages, we
> -		 * will reclaim both active and inactive pages.
> -		 *
> -		 * We use the same threshold as pageout congestion_wait below.
> -		 */
> -		if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> -			mode = ISOLATE_BOTH;
> -		else if (sc->order && priority < DEF_PRIORITY - 2)
> -			mode = ISOLATE_BOTH;
> +		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
>  
>  		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
>  			     &page_list, &nr_scan, sc->order, mode,
> @@ -1110,7 +1111,7 @@ static unsigned long shrink_inactive_lis
>  		 * but that should be acceptable to the caller
>  		 */
>  		if (nr_freed < nr_taken && !current_is_kswapd() &&
> -					sc->order > PAGE_ALLOC_COSTLY_ORDER) {
> +		    lumpy_reclaim) {
>  			congestion_wait(WRITE, HZ/10);
>  
>  			/*
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
