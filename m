Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 49FF46B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 14:00:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k192so33504129lfb.1
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 11:00:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gl2si15058969wjd.222.2016.06.10.11.00.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jun 2016 11:00:54 -0700 (PDT)
Subject: Re: [PATCH 03/27] mm, vmscan: Move LRU lists to node
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-4-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <575B0054.7090202@suse.cz>
Date: Fri, 10 Jun 2016 20:00:52 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

[+CC Michal Hocko]

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> This moves the LRU lists from the zone to the node and all related data
> such as counters, tracing, congestion tracking and writeback tracking.
> This is mostly a mechanical patch but note that it introduces a number
> of anomalies. For example, the scans are per-zone but using per-node
> counters. We also mark a node as congested when a zone is congested. This
> causes weird problems that are fixed later but is easier to review.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>


> @@ -535,17 +525,21 @@ struct zone {
>  
>  enum zone_flags {
>  	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
> -	ZONE_CONGESTED,			/* zone has many dirty pages backed by
> +	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */

This one has been zapped recently, looks like rebasing resurrected it.

> @@ -1455,13 +1455,22 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  		enum compact_result compact_result;
>  
>  		/*
> +		 * This over-estimates the number of pages available for
> +		 * reclaim/compaction but walking the LRU would take too
> +		 * long. The consequences are that compaction may retry
> +		 * longer than it should for a zone-constrained allocation
> +		 * request.
> +		 */
> +		available = pgdat_reclaimable_pages(zone->zone_pgdat);

I'm worried if "longer than it should" means "potentially forever", as
the limit on retries in should_compact_retry() doesn't apply when this
function returns true. Unless some later patches change that.

I'm starting to wonder if it's a good idea to give up per-zone LRU
accounting, because we still have per-zone watermarks that we are trying
to satisfy. How will we even recognize situation where a small zone is
so depleted of LRU pages that it can't even reach its watermarks,
causing a massive whole-node reclaim? Couldn't we have a combination of
per-node lru with per-zone accounting?

> +
> +		/*
>  		 * Do not consider all the reclaimable memory because we do not
>  		 * want to trash just for a single high order allocation which
>  		 * is even not guaranteed to appear even if __compaction_suitable
>  		 * is happy about the watermark check.
>  		 */
> -		available = zone_reclaimable_pages(zone) / order;

This removed the scaling by order. Accidentally I guess, as the comment
is still there.

>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +		available = min(zone->managed_pages, available);
>  		compact_result = __compaction_suitable(zone, order, alloc_flags,
>  				ac_classzone_idx(ac), available);
>  		if (compact_result != COMPACT_SKIPPED &&

[...]

> @@ -1826,7 +1827,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  	}
>  
>  	page_lru = page_is_file_cache(page);
> -	mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
> +	mod_node_page_state(page_zone(page)->zone_pgdat, NR_ISOLATED_ANON + page_lru,

This again, I won't point out further. But I think a page_node() (or
page_pgdat()?) function is called for?

> @@ -3486,10 +3486,19 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		unsigned long available;
>  		unsigned long reclaimable;
>  
> -		available = reclaimable = zone_reclaimable_pages(zone);
> -		available -= DIV_ROUND_UP(no_progress_loops * available,
> +		/*
> +		 * This over-estimates the number of pages available for
> +		 * reclaim but walking the LRU would take too long. The
> +		 * consequences are that this may continue trying to
> +		 * reclaim for zone-constrained allocations even if those
> +		 * zones are already depleted.
> +		 */
> +		reclaimable = pgdat_reclaimable_pages(zone->zone_pgdat);
> +		reclaimable = min(zone->managed_pages, reclaimable);
> +		available = reclaimable - DIV_ROUND_UP(no_progress_loops * reclaimable,
>  					  MAX_RECLAIM_RETRIES);
>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +		available = min(zone->managed_pages, available);
>  
>  		/*
>  		 * Would the allocation succeed if we reclaimed the whole

This adds to my worries about per-node LRU accounting :/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
