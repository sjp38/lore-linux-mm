Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A19416B0256
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 11:17:51 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n186so18337304wmn.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 08:17:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o5si27494032wjy.239.2016.02.28.08.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 08:17:50 -0800 (PST)
Date: Sun, 28 Feb 2016 11:17:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 16/27] mm, page_alloc: Consider dirtyable memory in terms
 of nodes
Message-ID: <20160228161746.GG25622@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <20160223151755.GB2854@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223151755.GB2854@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:17:55PM +0000, Mel Gorman wrote:
> @@ -686,6 +680,12 @@ typedef struct pglist_data {
>  	/* Number of pages migrated during the rate limiting time interval */
>  	unsigned long numabalancing_migrate_nr_pages;
>  #endif
> +	/*
> +	 * This is a per-zone reserve of pages that are not available
> +	 * to userspace allocations.
> +	 */
> +	unsigned long		totalreserve_pages;

"per-node reserve"

> @@ -297,22 +306,11 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
>  	int node;
>  	unsigned long x = 0;
>  
> -	for_each_node_state(node, N_HIGH_MEMORY) {
> -		struct zone *z = &NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
> -
> -		x += zone_dirtyable_memory(z);
> -	}
>  	/*
> -	 * Unreclaimable memory (kernel memory or anonymous memory
> -	 * without swap) can bring down the dirtyable pages below
> -	 * the zone's dirty balance reserve and the above calculation
> -	 * will underflow.  However we still want to add in nodes
> -	 * which are below threshold (negative values) to get a more
> -	 * accurate calculation but make sure that the total never
> -	 * underflows.
> +	 * LRU lists are per-node so there is accurate way of accurately
> +	 * calculating dirtyable memory of just the high zone

"no accurate way of calculating"

> @@ -2665,7 +2665,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  		 * will require awareness of zones in the
>  		 * dirty-throttling and the flusher threads.
>  		 */
> -		if (ac->spread_dirty_pages && !zone_dirty_ok(zone))
> +		if (ac->spread_dirty_pages && !node_dirty_ok(zone->zone_pgdat))
>  			continue;

The comment above this branch can be updated. I'm attaching a diff
below, feel free to use it.

>  		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
> @@ -6333,7 +6333,7 @@ static void calculate_totalreserve_pages(void)
>  			if (max > zone->managed_pages)
>  				max = zone->managed_pages;
>  
> -			zone->totalreserve_pages = max;
> +			pgdat->totalreserve_pages += max;

calculate_totalreserve_pages() can be called repeatedly. It needs to
be set freshly in this function, not added to.

---

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c461a94..fedd0b5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2596,28 +2596,21 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				continue;
 		/*
 		 * When allocating a page cache page for writing, we
-		 * want to get it from a zone that is within its dirty
-		 * limit, such that no single zone holds more than its
+		 * want to get it from a node that is within its dirty
+		 * limit, such that no node zone holds more than its
 		 * proportional share of globally allowed dirty pages.
-		 * The dirty limits take into account the zone's
+		 * The dirty limits take into account the node's
 		 * lowmem reserves and high watermark so that kswapd
 		 * should be able to balance it without having to
 		 * write pages from its LRU list.
 		 *
-		 * This may look like it could increase pressure on
-		 * lower zones by failing allocations in higher zones
-		 * before they are full.  But the pages that do spill
-		 * over are limited as the lower zones are protected
-		 * by this very same mechanism.  It should not become
-		 * a practical burden to them.
-		 *
 		 * XXX: For now, allow allocations to potentially
-		 * exceed the per-zone dirty limit in the slowpath
+		 * exceed the per-node dirty limit in the slowpath
 		 * (spread_dirty_pages unset) before going into reclaim,
 		 * which is important when on a NUMA setup the allowed
-		 * zones are together not big enough to reach the
+		 * nodes are together not big enough to reach the
 		 * global limit.  The proper fix for these situations
-		 * will require awareness of zones in the
+		 * will require awareness of nodes in the
 		 * dirty-throttling and the flusher threads.
 		 */
 		if (ac->spread_dirty_pages) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
