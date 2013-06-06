Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5F23D6B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 08:47:17 -0400 (EDT)
Date: Thu, 6 Jun 2013 09:47:00 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 3/7] mm: compaction: don't depend on kswapd to invoke
 reset_isolation_suitable
Message-ID: <20130606124659.GB30387@optiplex.redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370445037-24144-4-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>

On Wed, Jun 05, 2013 at 05:10:33PM +0200, Andrea Arcangeli wrote:
> If kswapd never need to run (only __GFP_NO_KSWAPD allocations and
> plenty of free memory) compaction is otherwise crippled down and stops
> running for a while after the free/isolation cursor meets. After that
> allocation can fail for a full cycle of compaction_deferred, until
> compaction_restarting finally reset it again.
> 
> Stopping compaction for a full cycle after the cursor meets, even if
> it never failed and it's not going to fail, doesn't make sense.
> 
> We already throttle compaction CPU utilization using
> defer_compaction. We shouldn't prevent compaction to run after each
> pass completes when the cursor meets, unless it failed.
> 
> This makes direct compaction functional again. The throttling of
> direct compaction is still controlled by the defer_compaction
> logic.
> 
> kswapd still won't risk to reset compaction, and it will wait direct
> compaction to do so. Not sure if this is ideal but it at least
> decreases the risk of kswapd doing too much work. kswapd will only run
> one pass of compaction until some allocation invokes compaction again.
> 
> This decreased reliability of compaction was introduced in commit
> 62997027ca5b3d4618198ed8b1aba40b61b1137b .
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---

Acked-by: Rafael Aquini <aquini@redhat.com>


>  include/linux/compaction.h |  5 -----
>  include/linux/mmzone.h     |  3 ---
>  mm/compaction.c            | 15 ++++++---------
>  mm/page_alloc.c            |  1 -
>  mm/vmscan.c                |  8 --------
>  5 files changed, 6 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 091d72e..fc3f266 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -24,7 +24,6 @@ extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask,
>  			bool sync, bool *contended);
>  extern void compact_pgdat(pg_data_t *pgdat, int order);
> -extern void reset_isolation_suitable(pg_data_t *pgdat);
>  extern unsigned long compaction_suitable(struct zone *zone, int order);
>  
>  /* Do not skip compaction more than 64 times */
> @@ -84,10 +83,6 @@ static inline void compact_pgdat(pg_data_t *pgdat, int order)
>  {
>  }
>  
> -static inline void reset_isolation_suitable(pg_data_t *pgdat)
> -{
> -}
> -
>  static inline unsigned long compaction_suitable(struct zone *zone, int order)
>  {
>  	return COMPACT_SKIPPED;
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f23b080..9e9d285 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -354,9 +354,6 @@ struct zone {
>  	spinlock_t		lock;
>  	int                     all_unreclaimable; /* All pages pinned */
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> -	/* Set to true when the PG_migrate_skip bits should be cleared */
> -	bool			compact_blockskip_flush;
> -
>  	/* pfns where compaction scanners should start */
>  	unsigned long		compact_cached_free_pfn;
>  	unsigned long		compact_cached_migrate_pfn;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index cac9594..525baaa 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -91,7 +91,6 @@ static void __reset_isolation_suitable(struct zone *zone)
>  
>  	zone->compact_cached_migrate_pfn = start_pfn;
>  	zone->compact_cached_free_pfn = end_pfn;
> -	zone->compact_blockskip_flush = false;
>  
>  	/* Walk the zone and mark every pageblock as suitable for isolation */
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
> @@ -110,7 +109,7 @@ static void __reset_isolation_suitable(struct zone *zone)
>  	}
>  }
>  
> -void reset_isolation_suitable(pg_data_t *pgdat)
> +static void reset_isolation_suitable(pg_data_t *pgdat)
>  {
>  	int zoneid;
>  
> @@ -120,8 +119,7 @@ void reset_isolation_suitable(pg_data_t *pgdat)
>  			continue;
>  
>  		/* Only flush if a full compaction finished recently */
> -		if (zone->compact_blockskip_flush)
> -			__reset_isolation_suitable(zone);
> +		__reset_isolation_suitable(zone);
>  	}
>  }
>  
> @@ -828,13 +826,12 @@ static int compact_finished(struct zone *zone,
>  	/* Compaction run completes if the migrate and free scanner meet */
>  	if (cc->free_pfn <= cc->migrate_pfn) {
>  		/*
> -		 * Mark that the PG_migrate_skip information should be cleared
> -		 * by kswapd when it goes to sleep. kswapd does not set the
> -		 * flag itself as the decision to be clear should be directly
> -		 * based on an allocation request.
> +		 * Clear the PG_migrate_skip information. kswapd does
> +		 * not clear it as the decision to be clear should be
> +		 * directly based on an allocation request.
>  		 */
>  		if (!current_is_kswapd())
> -			zone->compact_blockskip_flush = true;
> +			__reset_isolation_suitable(zone);
>  
>  		return COMPACT_COMPLETE;
>  	}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 378a15b..3931d16 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2188,7 +2188,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  				alloc_flags & ~ALLOC_NO_WATERMARKS,
>  				preferred_zone, migratetype);
>  		if (page) {
> -			preferred_zone->compact_blockskip_flush = false;
>  			preferred_zone->compact_considered = 0;
>  			preferred_zone->compact_defer_shift = 0;
>  			if (order >= preferred_zone->compact_order_failed)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index cc5bb01..825c631 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2920,14 +2920,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>  		 */
>  		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
>  
> -		/*
> -		 * Compaction records what page blocks it recently failed to
> -		 * isolate pages from and skips them in the future scanning.
> -		 * When kswapd is going to sleep, it is reasonable to assume
> -		 * that pages and compaction may succeed so reset the cache.
> -		 */
> -		reset_isolation_suitable(pgdat);
> -
>  		if (!kthread_should_stop())
>  			schedule();
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
