Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id D7C906B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:26:44 -0400 (EDT)
Message-ID: <4FECE844.2050803@kernel.org>
Date: Fri, 29 Jun 2012 08:27:00 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where
 it left
References: <20120628135520.0c48b066@annuminas.surriel.com>
In-Reply-To: <20120628135520.0c48b066@annuminas.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com

Hi Rik,

Thanks for quick great work!
I have some nitpick below.

On 06/29/2012 02:55 AM, Rik van Riel wrote:

> Order > 0 compaction stops when enough free pages of the correct
> page order have been coalesced. When doing subsequent higher order
> allocations, it is possible for compaction to be invoked many times.
> 
> However, the compaction code always starts out looking for things to
> compact at the start of the zone, and for free pages to compact things
> to at the end of the zone.
> 
> This can cause quadratic behaviour, with isolate_freepages starting
> at the end of the zone each time, even though previous invocations
> of the compaction code already filled up all free memory on that end
> of the zone.
> 
> This can cause isolate_freepages to take enormous amounts of CPU
> with certain workloads on larger memory systems.
> 
> The obvious solution is to have isolate_freepages remember where
> it left off last time, and continue at that point the next time
> it gets invoked for an order > 0 compaction. This could cause
> compaction to fail if cc->free_pfn and cc->migrate_pfn are close
> together initially, in that case we restart from the end of the
> zone and try once more.
> 
> Forced full (order == -1) compactions are left alone.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Reported-by: Jim Schutt <jaschut@sandia.gov>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> v2: implement Mel's suggestions, handling wrap-around etc
> 
>  include/linux/mmzone.h |    4 ++++
>  mm/compaction.c        |   48 ++++++++++++++++++++++++++++++++++++++++++++----
>  mm/internal.h          |    2 ++
>  mm/page_alloc.c        |    5 +++++
>  4 files changed, 55 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2427706..e629594 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -369,6 +369,10 @@ struct zone {
>  	 */
>  	spinlock_t		lock;
>  	int                     all_unreclaimable; /* All pages pinned */
> +#if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +	/* pfn where the last order > 0 compaction isolated free pages */


How about using  "partial compaction" word instead of (order > 0)?

> +	unsigned long		compact_cached_free_pfn;
> +#endif
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  	/* see spanned/present_pages for more description */
>  	seqlock_t		span_seqlock;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7ea259d..2668b77 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -422,6 +422,17 @@ static void isolate_freepages(struct zone *zone,
>  					pfn -= pageblock_nr_pages) {
>  		unsigned long isolated;
>  
> +		/*
> +		 * Skip ahead if another thread is compacting in the area
> +		 * simultaneously. If we wrapped around, we can only skip
> +		 * ahead if zone->compact_cached_free_pfn also wrapped to
> +		 * above our starting point.
> +		 */
> +		if (cc->order > 0 && (!cc->wrapped ||


So if (partial_compaction(cc) && ... ) or if (!full_compaction(cc) &&  ...)

> +				      zone->compact_cached_free_pfn >
> +				      cc->start_free_pfn))
> +			pfn = min(pfn, zone->compact_cached_free_pfn);


The pfn can be where migrate_pfn below?
I mean we need this?

if (pfn <= low_pfn)
	goto out;

Otherwise, we can steal free pages made by migration just.

> +
>  		if (!pfn_valid(pfn))
>  			continue;
>  
> @@ -463,6 +474,8 @@ static void isolate_freepages(struct zone *zone,
>  		 */
>  		if (isolated)
>  			high_pfn = max(high_pfn, pfn);
> +		if (cc->order > 0)
> +			zone->compact_cached_free_pfn = high_pfn;


Why do we cache high_pfn instead of pfn?
If we can't isolate any page, compact_cached_free_pfn would become low_pfn.
I expect it's not what you want.

>  	}
>  
>  	/* split_free_page does not map the pages */
> @@ -565,8 +578,27 @@ static int compact_finished(struct zone *zone,
>  	if (fatal_signal_pending(current))
>  		return COMPACT_PARTIAL;
>  
> -	/* Compaction run completes if the migrate and free scanner meet */
> -	if (cc->free_pfn <= cc->migrate_pfn)
> +	/*
> +	 * A full (order == -1) compaction run starts at the beginning and
> +	 * end of a zone; it completes when the migrate and free scanner meet. 
> +	 * A partial (order > 0) compaction can start with the free scanner
> +	 * at a random point in the zone, and may have to restart.
> +	 */
> +	if (cc->free_pfn <= cc->migrate_pfn) {
> +		if (cc->order > 0 && !cc->wrapped) {
> +			/* We started partway through; restart at the end. */
> +			unsigned long free_pfn;
> +			free_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +			free_pfn &= ~(pageblock_nr_pages-1);
> +			zone->compact_cached_free_pfn = free_pfn;
> +			cc->wrapped = 1;
> +			return COMPACT_CONTINUE;
> +		}
> +		return COMPACT_COMPLETE;
> +	}
> +
> +	/* We wrapped around and ended up where we started. */
> +	if (cc->wrapped && cc->free_pfn <= cc->start_free_pfn)
>  		return COMPACT_COMPLETE;
>  
>  	/*
> @@ -664,8 +696,16 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  
>  	/* Setup to move all movable pages to the end of the zone */
>  	cc->migrate_pfn = zone->zone_start_pfn;
> -	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> -	cc->free_pfn &= ~(pageblock_nr_pages-1);
> +
> +	if (cc->order > 0) {
> +		/* Incremental compaction. Start where the last one stopped. */
> +		cc->free_pfn = zone->compact_cached_free_pfn;
> +		cc->start_free_pfn = cc->free_pfn;
> +	} else {
> +		/* Order == -1 starts at the end of the zone. */
> +		cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> +		cc->free_pfn &= ~(pageblock_nr_pages-1);
> +	}
>  
>  	migrate_prep_local();
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index 2ba87fb..0b72461 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -118,8 +118,10 @@ struct compact_control {
>  	unsigned long nr_freepages;	/* Number of isolated free pages */
>  	unsigned long nr_migratepages;	/* Number of pages to migrate */
>  	unsigned long free_pfn;		/* isolate_freepages search base */
> +	unsigned long start_free_pfn;	/* where we started the search */


For me, free_pfn and start_free_pfn are rather confusing.
I hope we can add more detail comment for free_pfn and start_free_pfn.
For start_free_pfn,
/* Where incremental compaction starts the search */

For free_pfn,
/* the highest PFN we isolated pages from */

>  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
>  	bool sync;			/* Synchronous migration */
> +	bool wrapped;			/* Last round for order>0 compaction */
>  
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..c353a61 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4394,6 +4394,11 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  
>  		zone->spanned_pages = size;
>  		zone->present_pages = realsize;
> +#if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +		zone->compact_cached_free_pfn = zone->zone_start_pfn +
> +						zone->spanned_pages;
> +		zone->compact_cached_free_pfn &= ~(pageblock_nr_pages-1);
> +#endif
>  #ifdef CONFIG_NUMA
>  		zone->node = nid;
>  		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
