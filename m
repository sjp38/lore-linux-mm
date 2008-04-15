Date: Tue, 15 Apr 2008 09:51:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Smarter retry of costly-order allocations
Message-ID: <20080415085154.GA20316@csn.ul.ie>
References: <20080411233500.GA19078@us.ibm.com> <20080411233553.GB19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080411233553.GB19078@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (11/04/08 16:35), Nishanth Aravamudan didst pronounce:
> Because of page order checks in __alloc_pages(), hugepage (and similarly
> large order) allocations will not retry unless explicitly marked
> __GFP_REPEAT. However, the current retry logic is nearly an infinite
> loop (or until reclaim does no progress whatsoever). For these costly
> allocations, that seems like overkill and could potentially never
> terminate.
> 
> Modify try_to_free_pages() to indicate how many pages were reclaimed.
> Use that information in __alloc_pages() to eventually fail a large
> __GFP_REPEAT allocation when we've reclaimed an order of pages equal to
> or greater than the allocation's order. This relies on lumpy reclaim
> functioning as advertised. Due to fragmentation, lumpy reclaim may not
> be able to free up the order needed in one invocation, so multiple
> iterations may be requred. In other words, the more fragmented memory
> is, the more retry attempts __GFP_REPEAT will make (particularly for
> higher order allocations).
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Changelog is a lot clearer now. Thanks.

Tested-by: Mel Gorman <mel@csn.ul.ie>

> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1db36da..1a0cc4d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1541,7 +1541,8 @@ __alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
>  	struct task_struct *p = current;
>  	int do_retry;
>  	int alloc_flags;
> -	int did_some_progress;
> +	unsigned long did_some_progress;
> +	unsigned long pages_reclaimed = 0;
>  
>  	might_sleep_if(wait);
>  
> @@ -1691,15 +1692,26 @@ nofail_alloc:
>  	 * Don't let big-order allocations loop unless the caller explicitly
>  	 * requests that.  Wait for some write requests to complete then retry.
>  	 *
> -	 * In this implementation, either order <= PAGE_ALLOC_COSTLY_ORDER or
> -	 * __GFP_REPEAT mean __GFP_NOFAIL, but that may not be true in other
> +	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
> +	 * means __GFP_NOFAIL, but that may not be true in other
>  	 * implementations.
> +	 *
> +	 * For order > PAGE_ALLOC_COSTLY_ORDER, if __GFP_REPEAT is
> +	 * specified, then we retry until we no longer reclaim any pages
> +	 * (above), or we've reclaimed an order of pages at least as
> +	 * large as the allocation's order. In both cases, if the
> +	 * allocation still fails, we stop retrying.
>  	 */
> +	pages_reclaimed += did_some_progress;
>  	do_retry = 0;
>  	if (!(gfp_mask & __GFP_NORETRY)) {
> -		if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
> -						(gfp_mask & __GFP_REPEAT))
> +		if (order <= PAGE_ALLOC_COSTLY_ORDER) {
>  			do_retry = 1;
> +		} else {
> +			if (gfp_mask & __GFP_REPEAT &&
> +				pages_reclaimed < (1 << order))
> +					do_retry = 1;
> +		}
>  		if (gfp_mask & __GFP_NOFAIL)
>  			do_retry = 1;
>  	}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 83f42c9..d106b2c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1319,6 +1319,9 @@ static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
>   * hope that some of these pages can be written.  But if the allocating task
>   * holds filesystem locks which prevent writeout this might not work, and the
>   * allocation attempt will fail.
> + *
> + * returns:	0, if no pages reclaimed
> + * 		else, the number of pages reclaimed
>   */
>  static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  					struct scan_control *sc)
> @@ -1368,7 +1371,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		}
>  		total_scanned += sc->nr_scanned;
>  		if (nr_reclaimed >= sc->swap_cluster_max) {
> -			ret = 1;
> +			ret = nr_reclaimed;
>  			goto out;
>  		}
>  
> @@ -1391,7 +1394,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	}
>  	/* top priority shrink_caches still had more to do? don't OOM, then */
>  	if (!sc->all_unreclaimable && scan_global_lru(sc))
> -		ret = 1;
> +		ret = nr_reclaimed;
>  out:
>  	/*
>  	 * Now that we've scanned all the zones at this priority level, note
> 
> -- 
> Nishanth Aravamudan <nacc@us.ibm.com>
> IBM Linux Technology Center
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
