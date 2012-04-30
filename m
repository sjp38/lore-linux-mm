Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id A14286B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 07:01:02 -0400 (EDT)
Date: Mon, 30 Apr 2012 12:00:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120430110057.GN9226@suse.de>
References: <201204271257.11501.b.zolnierkie@samsung.com>
 <20120430090239.GL9226@suse.de>
 <201204301208.47866.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201204301208.47866.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Mon, Apr 30, 2012 at 12:08:47PM +0200, Bartlomiej Zolnierkiewicz wrote:
> > <SNIP>
> > 
> > This is looking much better to me. However, I would really like to see
> > COMPACT_ASYNC_UNMOVABLE being used by the page allocator instead of depending
> > on kswapd to do the work. Right now as it uses COMPACT_ASYNC_MOVABLE only,
> > I think it uses COMPACT_SYNC too easily (making latency worse).
> 
> Is the following v4 code in __alloc_pages_direct_compact() not enough?
> 
> @@ -2122,7 +2122,7 @@
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	struct zonelist *zonelist, enum zone_type high_zoneidx,
>  	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
> -	int migratetype, bool sync_migration,
> +	int migratetype, enum compact_mode migration_mode,
>  	bool *deferred_compaction,
>  	unsigned long *did_some_progress)
>  {
> @@ -2285,7 +2285,7 @@
>  	int alloc_flags;
>  	unsigned long pages_reclaimed = 0;
>  	unsigned long did_some_progress;
> -	bool sync_migration = false;
> +	enum compact_mode migration_mode = COMPACT_ASYNC_MOVABLE;
>  	bool deferred_compaction = false;
>  
>  	/*
> @@ -2360,19 +2360,31 @@
>  		goto nopage;
>  
>  	/*
> -	 * Try direct compaction. The first pass is asynchronous. Subsequent
> -	 * attempts after direct reclaim are synchronous
> +	 * Try direct compaction. The first and second pass are asynchronous.
> +	 * Subsequent attempts after direct reclaim are synchronous.
>  	 */
>  	page = __alloc_pages_direct_compact(gfp_mask, order,
>  					zonelist, high_zoneidx,
>  					nodemask,
>  					alloc_flags, preferred_zone,
> -					migratetype, sync_migration,
> +					migratetype, migration_mode,
>  					&deferred_compaction,
>  					&did_some_progress);
>  	if (page)
>  		goto got_pg;
> -	sync_migration = true;
> +
> +	migration_mode = COMPACT_ASYNC_UNMOVABLE;
> +	page = __alloc_pages_direct_compact(gfp_mask, order,
> +					zonelist, high_zoneidx,
> +					nodemask,
> +					alloc_flags, preferred_zone,
> +					migratetype, migration_mode,
> +					&deferred_compaction,
> +					&did_some_progress);
> +	if (page)
> +		goto got_pg;
> +
> +	migration_mode = COMPACT_SYNC;
>  
>  	/*
>  	 * If compaction is deferred for high-order allocations, it is because
> 

Two problems with it.

It moves more knowledge of compaction into page_alloc.c than is
necessary. Second, it does not take into account whether enough
MIGRATE_UNMOVABLE pageblocks were encountered to justify a second
pass and only compaction.c knows that. This is why I suggested that
try_to_compact_pages() continue to take a "sync" parameter and have it
decide whether the second pass with COMPACT_ASYNC_UNMOVABLE is suitable.

> > Specifically
> > 
> > 1. Leave try_to_compact_pages() taking a sync parameter. It is up to
> >    compaction how to treat sync==false
> > 2. When sync==false, start with ASYNC_MOVABLE. Track how many pageblocks
> >    were scanned during compaction and how many of them were
> >    MIGRATE_UNMOVABLE. If compaction ran fully (COMPACT_COMPLETE) it implies
> >    that there is not a suitable page for allocation. In this case then
> >    check how if there were enough MIGRATE_UNMOVABLE pageblocks to try a
> >    second pass in ASYNC_FULL. By keeping all the logic in compaction.c
> >    it prevents too much knowledge of compaction sneaking into
> >    page_alloc.c
> 
> Do you mean that try_to_compact_pages() should handle COMPACT_ASYNC_MOVABLE
> and COMPACT_ASYNC_UNMOVABLE internally while __alloc_pages_direct_compact()
> (and its users) should only pass bool sync to it?
> 

Yes.

> > 3. When scanning ASYNC_FULL, *only* scan the MIGRATE_UNMOVABLE blocks as
> >    migration targets because the first pass would have scanned within
> >    MIGRATE_MOVABLE. This will reduce the cost of the second pass.
> 
> That is what the current v4 code should already be doing with:
> 
> [...]
>  /* Returns true if the page is within a block suitable for migration to */
> -static bool suitable_migration_target(struct page *page)
> +static bool suitable_migration_target(struct page *page,
> +				      enum compact_mode mode)
>  {
>  
>  	int migratetype = get_pageblock_migratetype(page);
> @@ -373,7 +413,13 @@
>  		return true;
>  
>  	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> -	if (migrate_async_suitable(migratetype))
> +	if (mode != COMPACT_ASYNC_UNMOVABLE &&
> +	    migrate_async_suitable(migratetype))
> +		return true;
> +
> +	if (mode != COMPACT_ASYNC_MOVABLE &&
> +	    migratetype == MIGRATE_UNMOVABLE &&
> +	    rescue_unmovable_pageblock(page))
>  		return true;
>  
>  	/* Otherwise skip the block */
> 
> ?
> 

Yes, you're right. When I complained I was thinking that it was still
possible to use pageblocks with large number of free pages in the second pass
which is not exactly the same thing but it is still perfectly reasonable.

Sorry for the noise.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
