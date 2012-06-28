Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E868A6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 06:29:23 -0400 (EDT)
Date: Thu, 28 Jun 2012 11:29:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -mm] mm: have order>0 compaction start off where it left
Message-ID: <20120628102919.GQ8103@csn.ul.ie>
References: <20120627233742.53225fc7@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120627233742.53225fc7@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov

On Wed, Jun 27, 2012 at 11:37:42PM -0400, Rik van Riel wrote:
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
> Reported-by: Jim Schutt <jaschut@sandia.gov>
> Signed-off-by: Rik van Riel <riel@redhat.com>

In principal, this is a good idea and I like it. Not so sure about the
details :)

> ---
> CAUTION: due to the time of day, I have only COMPILE tested this code
> 
>  include/linux/mmzone.h |    4 ++++
>  mm/compaction.c        |   25 +++++++++++++++++++++++--
>  mm/internal.h          |    1 +
>  mm/page_alloc.c        |    4 ++++
>  4 files changed, 32 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2427706..b8a5c36 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -369,6 +369,10 @@ struct zone {
>  	 */
>  	spinlock_t		lock;
>  	int                     all_unreclaimable; /* All pages pinned */
> +#if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +	/* pfn where the last order > 0 compaction isolated free pages */
> +	unsigned long		last_free_pfn;
> +#endif

last_free_pfn could be misleading as a name. At a glance it implies that
it stores the PFN of the highest free page. compact_cached_free_pfn?

>  #ifdef CONFIG_MEMORY_HOTPLUG
>  	/* see spanned/present_pages for more description */
>  	seqlock_t		span_seqlock;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7ea259d..0e9e995 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -422,6 +422,10 @@ static void isolate_freepages(struct zone *zone,
>  					pfn -= pageblock_nr_pages) {
>  		unsigned long isolated;
>  
> +		/* Skip ahead if somebody else is compacting simultaneously. */
> +		if (cc->order > 0)
> +			pfn = min(pfn, zone->last_free_pfn);
> +
>  		if (!pfn_valid(pfn))
>  			continue;
>  
> @@ -463,6 +467,8 @@ static void isolate_freepages(struct zone *zone,
>  		 */
>  		if (isolated)
>  			high_pfn = max(high_pfn, pfn);
> +		if (cc->order > 0)
> +			zone->last_free_pfn = high_pfn;
>  	}
>  
>  	/* split_free_page does not map the pages */

This is not necessarily good behaviour.

Lets say there are two parallel compactions running. Process A meets
the migration PFN and moves to the end of the zone to restart. Process B
finishes scanning mid-way through the zone and updates last_free_pfn. This
will cause Process A to "jump" to where Process B left off which is not
necessarily desirable.

Another side effect is that a workload that allocations/frees
aggressively will not compact as well as the "free" scanner is not
scanning the end of the zone each time. It would be better if
last_free_pfn was updated when a full pageblock was encountered

So;

1. Initialise last_free_pfn to the end of the zone
2. On compaction, scan from last_free_pfn and record where it started
3. If a pageblock is full, update last_free_pfn
4. If the migration and free scanner meet, reset last_free_pfn and
   the free scanner. Abort if the free scanner wraps to where it started

Does that make sense?

> @@ -565,9 +571,24 @@ static int compact_finished(struct zone *zone,
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
> +		if (cc->order > 0 && !cc->last_round) {
> +			/* We started partway through; restart at the end. */
> +			unsigned long free_pfn;
> +			free_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +			free_pfn &= ~(pageblock_nr_pages-1);
> +			zone->last_free_pfn = free_pfn;
> +			cc->last_round = 1;
> +			return COMPACT_CONTINUE;
> +		}
>  		return COMPACT_COMPLETE;
> +	}
>  
>  	/*
>  	 * order == -1 is expected when compacting via
> diff --git a/mm/internal.h b/mm/internal.h
> index 2ba87fb..b041874 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -120,6 +120,7 @@ struct compact_control {
>  	unsigned long free_pfn;		/* isolate_freepages search base */
>  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
>  	bool sync;			/* Synchronous migration */
> +	bool last_round;		/* Last round for order>0 compaction */
>  

I don't get what you mean by last_round. Did you mean "wrapped". When
false, it means the free scanner started from last_pfn and when true it
means it started from last_pfn, met the migrate scanner and wrapped
around to the end of the zone?

>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..86de652 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4394,6 +4394,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  
>  		zone->spanned_pages = size;
>  		zone->present_pages = realsize;
> +#if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +		zone->last_free_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +		zone->last_free_pfn &= ~(pageblock_nr_pages-1);
> +#endif
>  #ifdef CONFIG_NUMA
>  		zone->node = nid;
>  		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
