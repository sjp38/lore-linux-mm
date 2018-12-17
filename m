Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5964F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 09:07:06 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s14so11914884pfk.16
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 06:07:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si10156711pgr.133.2018.12.17.06.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 06:07:04 -0800 (PST)
Subject: Re: [PATCH 04/14] mm, compaction: Rename map_pages to split_map_pages
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-5-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b9a6574a-6b0c-11bc-06e5-c650b03e06f3@suse.cz>
Date: Mon, 17 Dec 2018 15:06:59 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-5-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:03 AM, Mel Gorman wrote:
> It's non-obvious that high-order free pages are split into order-0
> pages from the function name. Fix it.

That's fine, but looks like the patch has another change squashed into
it that removes zone parameter from several functions and uses cc->zone
instead.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/compaction.c | 60 ++++++++++++++++++++++++++++-----------------------------
>  1 file changed, 29 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index fb4d9f52ed56..3afa4e9188b6 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -66,7 +66,7 @@ static unsigned long release_freepages(struct list_head *freelist)
>  	return high_pfn;
>  }
>  
> -static void map_pages(struct list_head *list)
> +static void split_map_pages(struct list_head *list)
>  {
>  	unsigned int i, order, nr_pages;
>  	struct page *page, *next;
> @@ -644,7 +644,7 @@ isolate_freepages_range(struct compact_control *cc,
>  	}
>  
>  	/* __isolate_free_page() does not map the pages */
> -	map_pages(&freelist);
> +	split_map_pages(&freelist);
>  
>  	if (pfn < end_pfn) {
>  		/* Loop terminated early, cleanup. */
> @@ -1141,7 +1141,7 @@ static void isolate_freepages(struct compact_control *cc)
>  	}
>  
>  	/* __isolate_free_page() does not map the pages */
> -	map_pages(freelist);
> +	split_map_pages(freelist);
>  
>  	/*
>  	 * Record where the free scanner will restart next time. Either we
> @@ -1300,8 +1300,7 @@ static inline bool is_via_compact_memory(int order)
>  	return order == -1;
>  }
>  
> -static enum compact_result __compact_finished(struct zone *zone,
> -						struct compact_control *cc)
> +static enum compact_result __compact_finished(struct compact_control *cc)
>  {
>  	unsigned int order;
>  	const int migratetype = cc->migratetype;
> @@ -1312,7 +1311,7 @@ static enum compact_result __compact_finished(struct zone *zone,
>  	/* Compaction run completes if the migrate and free scanner meet */
>  	if (compact_scanners_met(cc)) {
>  		/* Let the next compaction start anew. */
> -		reset_cached_positions(zone);
> +		reset_cached_positions(cc->zone);
>  
>  		/*
>  		 * Mark that the PG_migrate_skip information should be cleared
> @@ -1321,7 +1320,7 @@ static enum compact_result __compact_finished(struct zone *zone,
>  		 * based on an allocation request.
>  		 */
>  		if (cc->direct_compaction)
> -			zone->compact_blockskip_flush = true;
> +			cc->zone->compact_blockskip_flush = true;
>  
>  		if (cc->whole_zone)
>  			return COMPACT_COMPLETE;
> @@ -1345,7 +1344,7 @@ static enum compact_result __compact_finished(struct zone *zone,
>  
>  	/* Direct compactor: Is a suitable page free? */
>  	for (order = cc->order; order < MAX_ORDER; order++) {
> -		struct free_area *area = &zone->free_area[order];
> +		struct free_area *area = &cc->zone->free_area[order];
>  		bool can_steal;
>  
>  		/* Job done if page is free of the right migratetype */
> @@ -1391,13 +1390,12 @@ static enum compact_result __compact_finished(struct zone *zone,
>  	return COMPACT_NO_SUITABLE_PAGE;
>  }
>  
> -static enum compact_result compact_finished(struct zone *zone,
> -			struct compact_control *cc)
> +static enum compact_result compact_finished(struct compact_control *cc)
>  {
>  	int ret;
>  
> -	ret = __compact_finished(zone, cc);
> -	trace_mm_compaction_finished(zone, cc->order, ret);
> +	ret = __compact_finished(cc);
> +	trace_mm_compaction_finished(cc->zone, cc->order, ret);
>  	if (ret == COMPACT_NO_SUITABLE_PAGE)
>  		ret = COMPACT_CONTINUE;
>  
> @@ -1524,16 +1522,16 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  	return false;
>  }
>  
> -static enum compact_result compact_zone(struct zone *zone, struct compact_control *cc)
> +static enum compact_result compact_zone(struct compact_control *cc)
>  {
>  	enum compact_result ret;
> -	unsigned long start_pfn = zone->zone_start_pfn;
> -	unsigned long end_pfn = zone_end_pfn(zone);
> +	unsigned long start_pfn = cc->zone->zone_start_pfn;
> +	unsigned long end_pfn = zone_end_pfn(cc->zone);
>  	unsigned long last_migrated_pfn;
>  	const bool sync = cc->mode != MIGRATE_ASYNC;
>  
>  	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
> -	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
> +	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
>  							cc->classzone_idx);
>  	/* Compaction is likely to fail */
>  	if (ret == COMPACT_SUCCESS || ret == COMPACT_SKIPPED)
> @@ -1546,8 +1544,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  	 * Clear pageblock skip if there were failures recently and compaction
>  	 * is about to be retried after being deferred.
>  	 */
> -	if (compaction_restarting(zone, cc->order))
> -		__reset_isolation_suitable(zone);
> +	if (compaction_restarting(cc->zone, cc->order))
> +		__reset_isolation_suitable(cc->zone);
>  
>  	/*
>  	 * Setup to move all movable pages to the end of the zone. Used cached
> @@ -1559,16 +1557,16 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  		cc->migrate_pfn = start_pfn;
>  		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
>  	} else {
> -		cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
> -		cc->free_pfn = zone->compact_cached_free_pfn;
> +		cc->migrate_pfn = cc->zone->compact_cached_migrate_pfn[sync];
> +		cc->free_pfn = cc->zone->compact_cached_free_pfn;
>  		if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
>  			cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
> -			zone->compact_cached_free_pfn = cc->free_pfn;
> +			cc->zone->compact_cached_free_pfn = cc->free_pfn;
>  		}
>  		if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
>  			cc->migrate_pfn = start_pfn;
> -			zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
> -			zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
> +			cc->zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
> +			cc->zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
>  		}
>  
>  		if (cc->migrate_pfn == start_pfn)
> @@ -1582,11 +1580,11 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  
>  	migrate_prep_local();
>  
> -	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
> +	while ((ret = compact_finished(cc)) == COMPACT_CONTINUE) {
>  		int err;
>  		unsigned long start_pfn = cc->migrate_pfn;
>  
> -		switch (isolate_migratepages(zone, cc)) {
> +		switch (isolate_migratepages(cc->zone, cc)) {
>  		case ISOLATE_ABORT:
>  			ret = COMPACT_CONTENDED;
>  			putback_movable_pages(&cc->migratepages);
> @@ -1653,7 +1651,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  			if (last_migrated_pfn < current_block_start) {
>  				cpu = get_cpu();
>  				lru_add_drain_cpu(cpu);
> -				drain_local_pages(zone);
> +				drain_local_pages(cc->zone);
>  				put_cpu();
>  				/* No more flushing until we migrate again */
>  				last_migrated_pfn = 0;
> @@ -1678,8 +1676,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  		 * Only go back, not forward. The cached pfn might have been
>  		 * already reset to zone end in compact_finished()
>  		 */
> -		if (free_pfn > zone->compact_cached_free_pfn)
> -			zone->compact_cached_free_pfn = free_pfn;
> +		if (free_pfn > cc->zone->compact_cached_free_pfn)
> +			cc->zone->compact_cached_free_pfn = free_pfn;
>  	}
>  
>  	count_compact_events(COMPACTMIGRATE_SCANNED, cc->total_migrate_scanned);
> @@ -1716,7 +1714,7 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  	INIT_LIST_HEAD(&cc.freepages);
>  	INIT_LIST_HEAD(&cc.migratepages);
>  
> -	ret = compact_zone(zone, &cc);
> +	ret = compact_zone(&cc);
>  
>  	VM_BUG_ON(!list_empty(&cc.freepages));
>  	VM_BUG_ON(!list_empty(&cc.migratepages));
> @@ -1834,7 +1832,7 @@ static void compact_node(int nid)
>  		INIT_LIST_HEAD(&cc.freepages);
>  		INIT_LIST_HEAD(&cc.migratepages);
>  
> -		compact_zone(zone, &cc);
> +		compact_zone(&cc);
>  
>  		VM_BUG_ON(!list_empty(&cc.freepages));
>  		VM_BUG_ON(!list_empty(&cc.migratepages));
> @@ -1976,7 +1974,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  
>  		if (kthread_should_stop())
>  			return;
> -		status = compact_zone(zone, &cc);
> +		status = compact_zone(&cc);
>  
>  		if (status == COMPACT_SUCCESS) {
>  			compaction_defer_reset(zone, cc.order, false);
> 
