Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 753416B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 05:55:29 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so550529eei.28
        for <linux-mm@kvack.org>; Wed, 07 May 2014 02:55:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n46si15853841eeo.97.2014.05.07.02.55.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 02:55:28 -0700 (PDT)
Message-ID: <536A030D.4070407@suse.cz>
Date: Wed, 07 May 2014 11:55:25 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v3 4/6] mm, compaction: embed migration mode in compact_control
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061921420.18635@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405061921420.18635@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/07/2014 04:22 AM, David Rientjes wrote:
> We're going to want to manipulate the migration mode for compaction in the page
> allocator, and currently compact_control's sync field is only a bool.
>
> Currently, we only do MIGRATE_ASYNC or MIGRATE_SYNC_LIGHT compaction depending
> on the value of this bool.  Convert the bool to enum migrate_mode and pass the
> migration mode in directly.  Later, we'll want to avoid MIGRATE_SYNC_LIGHT for
> thp allocations in the pagefault patch to avoid unnecessary latency.
>
> This also alters compaction triggered from sysfs, either for the entire system
> or for a node, to force MIGRATE_SYNC.
>
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>   include/linux/compaction.h |  4 ++--
>   mm/compaction.c            | 36 +++++++++++++++++++-----------------
>   mm/internal.h              |  2 +-
>   mm/page_alloc.c            | 37 ++++++++++++++++---------------------
>   4 files changed, 38 insertions(+), 41 deletions(-)
>
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -22,7 +22,7 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
>   extern int fragmentation_index(struct zone *zone, unsigned int order);
>   extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>   			int order, gfp_t gfp_mask, nodemask_t *mask,
> -			bool sync, bool *contended);
> +			enum migrate_mode sync, bool *contended);

Everywhere else it's 'mode' and only in this function it's still called 
'sync', that's confusing.
Afterwards:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>   extern void compact_pgdat(pg_data_t *pgdat, int order);
>   extern void reset_isolation_suitable(pg_data_t *pgdat);
>   extern unsigned long compaction_suitable(struct zone *zone, int order);
> @@ -91,7 +91,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
>   #else
>   static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>   			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -			bool sync, bool *contended)
> +			enum migrate_mode sync, bool *contended)
>   {
>   	return COMPACT_CONTINUE;
>   }
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -161,7 +161,8 @@ static void update_pageblock_skip(struct compact_control *cc,
>   			return;
>   		if (pfn > zone->compact_cached_migrate_pfn[0])
>   			zone->compact_cached_migrate_pfn[0] = pfn;
> -		if (cc->sync && pfn > zone->compact_cached_migrate_pfn[1])
> +		if (cc->mode != MIGRATE_ASYNC &&
> +		    pfn > zone->compact_cached_migrate_pfn[1])
>   			zone->compact_cached_migrate_pfn[1] = pfn;
>   	} else {
>   		if (cc->finished_update_free)
> @@ -208,7 +209,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>   		}
>
>   		/* async aborts if taking too long or contended */
> -		if (!cc->sync) {
> +		if (cc->mode == MIGRATE_ASYNC) {
>   			cc->contended = true;
>   			return false;
>   		}
> @@ -479,7 +480,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   	bool locked = false;
>   	struct page *page = NULL, *valid_page = NULL;
>   	bool set_unsuitable = true;
> -	const isolate_mode_t mode = (!cc->sync ? ISOLATE_ASYNC_MIGRATE : 0) |
> +	const isolate_mode_t mode = (cc->mode == MIGRATE_ASYNC ?
> +					ISOLATE_ASYNC_MIGRATE : 0) |
>   				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
>
>   	/*
> @@ -489,7 +491,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   	 */
>   	while (unlikely(too_many_isolated(zone))) {
>   		/* async migration should just abort */
> -		if (!cc->sync)
> +		if (cc->mode == MIGRATE_ASYNC)
>   			return 0;
>
>   		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -554,7 +556,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   			 * the minimum amount of work satisfies the allocation
>   			 */
>   			mt = get_pageblock_migratetype(page);
> -			if (!cc->sync && !migrate_async_suitable(mt)) {
> +			if (cc->mode == MIGRATE_ASYNC &&
> +			    !migrate_async_suitable(mt)) {
>   				set_unsuitable = false;
>   				goto next_pageblock;
>   			}
> @@ -990,6 +993,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   	int ret;
>   	unsigned long start_pfn = zone->zone_start_pfn;
>   	unsigned long end_pfn = zone_end_pfn(zone);
> +	const bool sync = cc->mode != MIGRATE_ASYNC;
>
>   	ret = compaction_suitable(zone, cc->order);
>   	switch (ret) {
> @@ -1015,7 +1019,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   	 * information on where the scanners should start but check that it
>   	 * is initialised by ensuring the values are within zone boundaries.
>   	 */
> -	cc->migrate_pfn = zone->compact_cached_migrate_pfn[cc->sync];
> +	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
>   	cc->free_pfn = zone->compact_cached_free_pfn;
>   	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
>   		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
> @@ -1049,8 +1053,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>
>   		nr_migrate = cc->nr_migratepages;
>   		err = migrate_pages(&cc->migratepages, compaction_alloc,
> -				compaction_free, (unsigned long)cc,
> -				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC,
> +				compaction_free, (unsigned long)cc, cc->mode,
>   				MR_COMPACTION);
>   		update_nr_listpages(cc);
>   		nr_remaining = cc->nr_migratepages;
> @@ -1083,9 +1086,8 @@ out:
>   	return ret;
>   }
>
> -static unsigned long compact_zone_order(struct zone *zone,
> -				 int order, gfp_t gfp_mask,
> -				 bool sync, bool *contended)
> +static unsigned long compact_zone_order(struct zone *zone, int order,
> +		gfp_t gfp_mask, enum migrate_mode mode, bool *contended)
>   {
>   	unsigned long ret;
>   	struct compact_control cc = {
> @@ -1094,7 +1096,7 @@ static unsigned long compact_zone_order(struct zone *zone,
>   		.order = order,
>   		.migratetype = allocflags_to_migratetype(gfp_mask),
>   		.zone = zone,
> -		.sync = sync,
> +		.mode = mode,
>   	};
>   	INIT_LIST_HEAD(&cc.freepages);
>   	INIT_LIST_HEAD(&cc.migratepages);
> @@ -1116,7 +1118,7 @@ int sysctl_extfrag_threshold = 500;
>    * @order: The order of the current allocation
>    * @gfp_mask: The GFP mask of the current allocation
>    * @nodemask: The allowed nodes to allocate from
> - * @sync: Whether migration is synchronous or not
> + * @sync: The migration mode for async, sync light, or sync migration
>    * @contended: Return value that is true if compaction was aborted due to lock contention
>    * @page: Optionally capture a free page of the requested order during compaction
>    *
> @@ -1124,7 +1126,7 @@ int sysctl_extfrag_threshold = 500;
>    */
>   unsigned long try_to_compact_pages(struct zonelist *zonelist,
>   			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -			bool sync, bool *contended)
> +			enum migrate_mode sync, bool *contended)
>   {
>   	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>   	int may_enter_fs = gfp_mask & __GFP_FS;
> @@ -1189,7 +1191,7 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>   						low_wmark_pages(zone), 0, 0))
>   				compaction_defer_reset(zone, cc->order, false);
>   			/* Currently async compaction is never deferred. */
> -			else if (cc->sync)
> +			else if (cc->mode != MIGRATE_ASYNC)
>   				defer_compaction(zone, cc->order);
>   		}
>
> @@ -1202,7 +1204,7 @@ void compact_pgdat(pg_data_t *pgdat, int order)
>   {
>   	struct compact_control cc = {
>   		.order = order,
> -		.sync = false,
> +		.mode = MIGRATE_ASYNC,
>   	};
>
>   	if (!order)
> @@ -1215,7 +1217,7 @@ static void compact_node(int nid)
>   {
>   	struct compact_control cc = {
>   		.order = -1,
> -		.sync = true,
> +		.mode = MIGRATE_SYNC,
>   		.ignore_skip_hint = true,
>   	};
>
> diff --git a/mm/internal.h b/mm/internal.h
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -134,7 +134,7 @@ struct compact_control {
>   	unsigned long nr_migratepages;	/* Number of pages to migrate */
>   	unsigned long free_pfn;		/* isolate_freepages search base */
>   	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> -	bool sync;			/* Synchronous migration */
> +	enum migrate_mode mode;		/* Async or sync migration mode */
>   	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
>   	bool finished_update_free;	/* True when the zone cached pfns are
>   					 * no longer being updated
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2226,7 +2226,7 @@ static struct page *
>   __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>   	struct zonelist *zonelist, enum zone_type high_zoneidx,
>   	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
> -	int migratetype, bool sync_migration,
> +	int migratetype, enum migrate_mode mode,
>   	bool *contended_compaction, bool *deferred_compaction,
>   	unsigned long *did_some_progress)
>   {
> @@ -2240,7 +2240,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>
>   	current->flags |= PF_MEMALLOC;
>   	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
> -						nodemask, sync_migration,
> +						nodemask, mode,
>   						contended_compaction);
>   	current->flags &= ~PF_MEMALLOC;
>
> @@ -2273,7 +2273,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>   		 * As async compaction considers a subset of pageblocks, only
>   		 * defer if the failure was a sync compaction failure.
>   		 */
> -		if (sync_migration)
> +		if (mode != MIGRATE_ASYNC)
>   			defer_compaction(preferred_zone, order);
>
>   		cond_resched();
> @@ -2286,9 +2286,8 @@ static inline struct page *
>   __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>   	struct zonelist *zonelist, enum zone_type high_zoneidx,
>   	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
> -	int migratetype, bool sync_migration,
> -	bool *contended_compaction, bool *deferred_compaction,
> -	unsigned long *did_some_progress)
> +	int migratetype, enum migrate_mode mode, bool *contended_compaction,
> +	bool *deferred_compaction, unsigned long *did_some_progress)
>   {
>   	return NULL;
>   }
> @@ -2483,7 +2482,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   	int alloc_flags;
>   	unsigned long pages_reclaimed = 0;
>   	unsigned long did_some_progress;
> -	bool sync_migration = false;
> +	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>   	bool deferred_compaction = false;
>   	bool contended_compaction = false;
>
> @@ -2577,17 +2576,15 @@ rebalance:
>   	 * Try direct compaction. The first pass is asynchronous. Subsequent
>   	 * attempts after direct reclaim are synchronous
>   	 */
> -	page = __alloc_pages_direct_compact(gfp_mask, order,
> -					zonelist, high_zoneidx,
> -					nodemask,
> -					alloc_flags, preferred_zone,
> -					migratetype, sync_migration,
> -					&contended_compaction,
> +	page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
> +					high_zoneidx, nodemask, alloc_flags,
> +					preferred_zone, migratetype,
> +					migration_mode, &contended_compaction,
>   					&deferred_compaction,
>   					&did_some_progress);
>   	if (page)
>   		goto got_pg;
> -	sync_migration = true;
> +	migration_mode = MIGRATE_SYNC_LIGHT;
>
>   	/*
>   	 * If compaction is deferred for high-order allocations, it is because
> @@ -2662,12 +2659,10 @@ rebalance:
>   		 * direct reclaim and reclaim/compaction depends on compaction
>   		 * being called after reclaim so call directly if necessary
>   		 */
> -		page = __alloc_pages_direct_compact(gfp_mask, order,
> -					zonelist, high_zoneidx,
> -					nodemask,
> -					alloc_flags, preferred_zone,
> -					migratetype, sync_migration,
> -					&contended_compaction,
> +		page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
> +					high_zoneidx, nodemask, alloc_flags,
> +					preferred_zone, migratetype,
> +					migration_mode, &contended_compaction,
>   					&deferred_compaction,
>   					&did_some_progress);
>   		if (page)
> @@ -6254,7 +6249,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>   		.nr_migratepages = 0,
>   		.order = -1,
>   		.zone = page_zone(pfn_to_page(start)),
> -		.sync = true,
> +		.sync = MIGRATE_SYNC_LIGHT,
>   		.ignore_skip_hint = true,
>   	};
>   	INIT_LIST_HEAD(&cc.migratepages);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
