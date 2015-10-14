Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1806B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 07:38:13 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so96812499wic.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 04:38:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e16si9978729wjz.164.2015.10.14.04.38.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Oct 2015 04:38:11 -0700 (PDT)
Subject: Re: [PATCH v2 7/9] mm/compaction: redesign compaction
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-8-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561E3E9F.9060106@suse.cz>
Date: Wed, 14 Oct 2015 13:38:07 +0200
MIME-Version: 1.0
In-Reply-To: <1440382773-16070-8-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2015 04:19 AM, Joonsoo Kim wrote:

[...]

> This patch solves these problems mentioned in above.
> Freepage scanner is largely changed to scan zone from zone_start_pfn
> to zone_end_pfn. And, by this change, compaction finish condition is also
> changed that migration scanner reach zone_end_pfn. With these changes,
> migration scanner can traverse anywhere in the zone.
> 
> To prevent back and forth migration within one compaction iteration,
> freepage scanner marks skip-bit when scanning pageblock. migration scanner
> checks it and will skip this marked pageblock so back and forth migration
> cannot be possible in one compaction iteration.
> 
> If freepage scanner reachs the end of zone, it restarts at zone_start_pfn.
> In this time, freepage scanner would scan the pageblock where migration
> scanner has migrated some pages but fail to make high order page. This
> leaved freepages means that they can't become high order page due to
> the fragmentation so it is good source for freepage scanner.

Hmm, there might be danger that freepage scanner will proceed faster than
migration scanner, as evidenced by the current code where the scanners meet
earlier than in the middle. Thus, it would likely mark pageblocks as unsuitable
for migration scanner, before it can reach them?

> With this change, above test result is:
> 
> Kernel:	Base vs Redesign
> 
> Test: hogger-frag-movable
> 
> Success(N)                    70              94
> compact_stall                307            3642
> compact_success               64             144
> compact_fail                 243            3498
> pgmigrate_success          34592        15897219
> compact_isolated           73977        31899553
> compact_migrate_scanned  2280770        59146745
> compact_free_scanned     4710313        49566134
> 
> Test: hogger-frag-movable with free memory variation
> 
> 200MB-Success(N)	70	94
> 250MB-Success(N)	38	93
> 300MB-Success(N)	29	89
> 
> Compaction gives us almost all possible high order page. Overhead is
> highly increased, but, further patch will reduce it greatly
> by adjusting depletion check with this new algorithm.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/compaction.c | 145 ++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 77 insertions(+), 68 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index a259608..ca4d6d1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -53,17 +53,17 @@ static const char *const compaction_status_string[] = {
>  static unsigned long release_freepages(struct list_head *freelist)
>  {
>  	struct page *page, *next;
> -	unsigned long high_pfn = 0;
> +	unsigned long low_pfn = ULONG_MAX;
>  
>  	list_for_each_entry_safe(page, next, freelist, lru) {
>  		unsigned long pfn = page_to_pfn(page);
>  		list_del(&page->lru);
>  		__free_page(page);
> -		if (pfn > high_pfn)
> -			high_pfn = pfn;
> +		if (pfn < low_pfn)
> +			low_pfn = pfn;
>  	}
>  
> -	return high_pfn;
> +	return low_pfn;

This assumes that the freelist won't contain both pages from the end of the
zone, and from the beginning the zone after the free scanner has wrapped. Which
is true, but not immediately obvious, so it deserves some comment.

>  }
>  
>  static void map_pages(struct list_head *list)
> @@ -243,7 +243,7 @@ static void __reset_isolation_suitable(struct zone *zone)
>  
>  	zone->compact_cached_migrate_pfn[0] = start_pfn;
>  	zone->compact_cached_migrate_pfn[1] = start_pfn;
> -	zone->compact_cached_free_pfn = end_pfn;
> +	zone->compact_cached_free_pfn = start_pfn;
>  	zone->compact_blockskip_flush = false;
>  
>  	clear_bit(ZONE_COMPACTION_SCANALLFREE, &zone->flags);
> @@ -335,7 +335,7 @@ static void update_pageblock_skip(struct compact_control *cc,
>  		if (!nr_isolated)
>  			set_pageblock_skip_freescan(page);
>  
> -		if (pfn < zone->compact_cached_free_pfn)
> +		if (pfn > zone->compact_cached_free_pfn)
>  			zone->compact_cached_free_pfn = pfn;
>  	}
>  }
> @@ -869,8 +869,11 @@ isolate_success:
>  						nr_scanned, nr_isolated);
>  
>  	count_compact_events(COMPACTMIGRATE_SCANNED, nr_scanned);
> -	if (nr_isolated)
> +	if (nr_isolated) {
>  		count_compact_events(COMPACTISOLATED, nr_isolated);
> +		if (valid_page)
> +			clear_pageblock_skip_freescan(valid_page);

This is explained in changelog, but a comment here would be useful too.

> +	}
>  
>  	return low_pfn;
>  }
> @@ -969,12 +972,14 @@ static void isolate_freepages(struct compact_control *cc)
>  {
>  	struct zone *zone = cc->zone;
>  	struct page *page;
> +	unsigned long pfn;
>  	unsigned long block_start_pfn;	/* start of current pageblock */
> -	unsigned long isolate_start_pfn; /* exact pfn we start at */
>  	unsigned long block_end_pfn;	/* end of current pageblock */
> -	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
>  	struct list_head *freelist = &cc->freepages;
> +	unsigned long nr_isolated;
> +	bool rotated = false;
>  
> +retry:
>  	/*
>  	 * Initialise the free scanner. The starting point is where we last
>  	 * successfully isolated from, zone-cached value, or the end of the
> @@ -986,22 +991,21 @@ static void isolate_freepages(struct compact_control *cc)
>  	 * The low boundary is the end of the pageblock the migration scanner
>  	 * is using.
>  	 */
> -	isolate_start_pfn = cc->free_pfn;
> -	block_start_pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
> -	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
> -						zone_end_pfn(zone));
> -	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
> +	pfn = cc->free_pfn;
>  
> -	/*
> -	 * Isolate free pages until enough are available to migrate the
> -	 * pages on cc->migratepages. We stop searching if the migrate
> -	 * and free page scanners meet or enough free pages are isolated.
> -	 */
> -	for (; block_start_pfn >= low_pfn &&
> -			cc->nr_migratepages > cc->nr_freepages;
> -				block_end_pfn = block_start_pfn,
> -				block_start_pfn -= pageblock_nr_pages,
> -				isolate_start_pfn = block_start_pfn) {
> +	for (; pfn < zone_end_pfn(zone) &&
> +		cc->nr_migratepages > cc->nr_freepages;) {
> +
> +		block_start_pfn = pfn & ~(pageblock_nr_pages-1);
> +		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> +		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
> +
> +		/* Skip the pageblock where migration scan is */
> +		if (block_start_pfn ==
> +			(cc->migrate_pfn & ~(pageblock_nr_pages-1))) {
> +			pfn = block_end_pfn;

Can't this "pfn = block_end_pfn" be in the for-loop header? Can it ever happen
that all of the following is true? I don't think it can?
- isolate_freepages_block() returns before reaching block_end_pfn
- it hasn't isolated enough, so cc->nr_migratepages > cc->nr_freepages is true
- cc->contended is not set

> +			continue;
> +		}
>  
>  		/*
>  		 * This can iterate a massively long zone without finding any
> @@ -1012,35 +1016,31 @@ static void isolate_freepages(struct compact_control *cc)
>  						&& compact_should_abort(cc))
>  			break;
>  
> -		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
> -									zone);
> -		if (!page)
> +		page = pageblock_pfn_to_page(pfn, block_end_pfn, zone);
> +		if (!page) {
> +			pfn = block_end_pfn;
>  			continue;
> +		}
>  
>  		/* Check the block is suitable for migration */
> -		if (!suitable_migration_target(cc, page))
> +		if (!suitable_migration_target(cc, page)) {
> +			pfn = block_end_pfn;
>  			continue;
> +		}
>  
>  		/* If isolation recently failed, do not retry */
> -		if (!isolation_suitable(cc, page, false))
> +		if (!isolation_suitable(cc, page, false)) {
> +			pfn = block_end_pfn;
>  			continue;
> +		}
>  
>  		/* Found a block suitable for isolating free pages from. */
> -		isolate_freepages_block(cc, &isolate_start_pfn,
> +		nr_isolated = isolate_freepages_block(cc, &pfn,
>  					block_end_pfn, freelist, false);
>  
> -		/*
> -		 * Remember where the free scanner should restart next time,
> -		 * which is where isolate_freepages_block() left off.
> -		 * But if it scanned the whole pageblock, isolate_start_pfn
> -		 * now points at block_end_pfn, which is the start of the next
> -		 * pageblock.
> -		 * In that case we will however want to restart at the start
> -		 * of the previous pageblock.
> -		 */
> -		cc->free_pfn = (isolate_start_pfn < block_end_pfn) ?
> -				isolate_start_pfn :
> -				block_start_pfn - pageblock_nr_pages;
> +		/* To prevent back and forth migration */
> +		if (nr_isolated)
> +			set_pageblock_skip_migratescan(page);
>  
>  		/*
>  		 * isolate_freepages_block() might have aborted due to async
> @@ -1053,12 +1053,15 @@ static void isolate_freepages(struct compact_control *cc)
>  	/* split_free_page does not map the pages */
>  	map_pages(freelist);
>  
> -	/*
> -	 * If we crossed the migrate scanner, we want to keep it that way
> -	 * so that compact_finished() may detect this
> -	 */
> -	if (block_start_pfn < low_pfn)
> -		cc->free_pfn = cc->migrate_pfn;
> +	cc->free_pfn = pfn;
> +	if (cc->free_pfn >= zone_end_pfn(zone)) {
> +		cc->free_pfn = zone->zone_start_pfn;
> +		zone->compact_cached_free_pfn = cc->free_pfn;
> +		if (cc->nr_freepages == 0 && !rotated) {
> +			rotated = true;
> +			goto retry;

This too deserves explanation. If we isolated at least something, we can return
and not "rotate" (wrap) to the zone start immediately. But if we isolated
nothing, we need to continue immediately, otherwise migration fails on -ENOMEM
and so will the whole compaction. And the fact, that if we isolated something,
we return immediately, has implications for release_freepages() being correct,
as I noted above.

> +		}
> +	}
>  }
>  
>  /*
> @@ -1144,8 +1147,9 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	 * Iterate over whole pageblocks until we find the first suitable.
>  	 * Do not cross the free scanner.
>  	 */
> -	for (; end_pfn <= cc->free_pfn;
> -			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
> +	for (; low_pfn < zone_end_pfn(zone); low_pfn = end_pfn) {
> +		end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
> +		end_pfn = min(end_pfn, zone_end_pfn(zone));
>  
>  		/*
>  		 * This can potentially iterate a massively long zone with
> @@ -1191,12 +1195,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	}
>  
>  	acct_isolated(zone, cc);
> -	/*
> -	 * Record where migration scanner will be restarted. If we end up in
> -	 * the same pageblock as the free scanner, make the scanners fully
> -	 * meet so that compact_finished() terminates compaction.
> -	 */
> -	cc->migrate_pfn = (end_pfn <= cc->free_pfn) ? low_pfn : cc->free_pfn;
> +	cc->migrate_pfn = low_pfn;
>  
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
> @@ -1211,11 +1210,15 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>  		return COMPACT_PARTIAL;
>  
>  	/* Compaction run completes if the migrate and free scanner meet */

This is no longer true :)

> -	if (cc->free_pfn <= cc->migrate_pfn) {
> +	if (cc->migrate_pfn >= zone_end_pfn(zone)) {
> +		/* Stop the async compaction */
> +		zone->compact_cached_migrate_pfn[0] = zone_end_pfn(zone);
> +		if (cc->mode == MIGRATE_ASYNC)
> +			return COMPACT_PARTIAL;

This is not explained in changelog? And I don't immediately see why this is needed?

> +
>  		/* Let the next compaction start anew. */
>  		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
>  		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
> -		zone->compact_cached_free_pfn = zone_end_pfn(zone);
>  
>  		/*
>  		 * Mark that the PG_migrate_skip information should be cleared
> @@ -1397,11 +1400,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  	 */
>  	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
>  	cc->free_pfn = zone->compact_cached_free_pfn;
> -	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
> -		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
> +	if (cc->mode == MIGRATE_ASYNC && cc->migrate_pfn >= end_pfn)
> +		return COMPACT_SKIPPED;

Ditto. Is this needed for correctness, or another optimization that should be
separate patch?

> +
> +	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
> +		cc->free_pfn = start_pfn;
>  		zone->compact_cached_free_pfn = cc->free_pfn;
>  	}
> -	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
> +	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
>  		cc->migrate_pfn = start_pfn;
>  		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
>  		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
> @@ -1450,11 +1456,16 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  		if (err) {
>  			putback_movable_pages(&cc->migratepages);
>  			/*
> -			 * migrate_pages() may return -ENOMEM when scanners meet
> -			 * and we want compact_finished() to detect it
> +			 * migrate_pages() may return -ENOMEM when free scanner
> +			 * doesn't find any freepage, and, in this case, more
> +			 * compaction attempt is useless because it cannot
> +			 * be successful due to no free memory. We'd like to
> +			 * consider this state as COMPACT_COMPLETE although
> +			 * migration scanner doesn't reach end_pfn of zone and
> +			 * fail to compaction.

Hmm is there a danger of frequent completes like these leading to premature
cached pfn resets, so migration scanner will again not reach the whole zone?

>  			 */
> -			if (err == -ENOMEM && cc->free_pfn > cc->migrate_pfn) {
> -				ret = COMPACT_PARTIAL;
> +			if (err == -ENOMEM) {
> +				ret = COMPACT_COMPLETE;
>  				goto out;
>  			}
>  		}
> @@ -1504,13 +1515,11 @@ out:
>  
>  		cc->nr_freepages = 0;
>  		VM_BUG_ON(free_pfn == 0);
> -		/* The cached pfn is always the first in a pageblock */
> -		free_pfn &= ~(pageblock_nr_pages-1);
>  		/*
>  		 * Only go back, not forward. The cached pfn might have been
>  		 * already reset to zone end in compact_finished()
>  		 */
> -		if (free_pfn > zone->compact_cached_free_pfn)
> +		if (free_pfn < zone->compact_cached_free_pfn)
>  			zone->compact_cached_free_pfn = free_pfn;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
