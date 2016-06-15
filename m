Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id F07E06B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 08:52:55 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so8139657lfg.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 05:52:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jp7si5811237wjb.155.2016.06.15.05.52.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jun 2016 05:52:54 -0700 (PDT)
Subject: Re: [PATCH 04/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-5-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ce7c8bac-49ca-d8c0-05fd-95465dc2f65b@suse.cz>
Date: Wed, 15 Jun 2016 14:52:52 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-5-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> This patch makes reclaim decisions on a per-node basis. A reclaimer knows
> what zone is required by the allocation request and skips pages from
> higher zones. In many cases this will be ok because it's a GFP_HIGHMEM
> request of some description. On 64-bit, ZONE_DMA32 requests will cause
> some problems but 32-bit devices on 64-bit platforms are increasingly
> rare. Historically it would have been a major problem on 32-bit with big
> Highmem:Lowmem ratios but such configurations are also now rare and even
> where they exist, they are not encouraged. If it really becomes a problem,
> it'll manifest as very low reclaim efficiencies.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 72 ++++++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 47 insertions(+), 25 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f87a5a0f8793..ab1b28e7e20a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -84,6 +84,9 @@ struct scan_control {
>  	/* Scan (total_size >> priority) pages at once */
>  	int priority;
>
> +	/* The highest zone to isolate pages for reclaim from */
> +	enum zone_type reclaim_idx;
> +
>  	unsigned int may_writepage:1;
>
>  	/* Can mapped pages be reclaimed? */
> @@ -1369,6 +1372,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	struct list_head *src = &lruvec->lists[lru];
>  	unsigned long nr_taken = 0;
>  	unsigned long scan;
> +	LIST_HEAD(pages_skipped);
>
>  	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
>  					!list_empty(src); scan++) {
> @@ -1379,6 +1383,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>
>  		VM_BUG_ON_PAGE(!PageLRU(page), page);
>
> +		if (page_zonenum(page) > sc->reclaim_idx) {
> +			list_move(&page->lru, &pages_skipped);
> +			continue;
> +		}
> +
>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:
>  			nr_taken += hpage_nr_pages(page);
> @@ -1395,6 +1404,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		}
>  	}
>
> +	/*
> +	 * Splice any skipped pages to the start of the LRU list. Note that
> +	 * this disrupts the LRU order when reclaiming for lower zones but
> +	 * we cannot splice to the tail. If we did then the SWAP_CLUSTER_MAX
> +	 * scanning would soon rescan the same pages to skip and put the
> +	 * system at risk of premature OOM.
> +	 */
> +	if (!list_empty(&pages_skipped))
> +		list_splice(&pages_skipped, src);

Hmm, that's unfortunate. But probably better than reclaiming the pages 
in the name of LRU order, even though it wouldn't help the allocation at 
hand.

[...]

> @@ -2516,14 +2535,14 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
>   */
> -static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> +static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
> +		enum zone_type classzone_idx)
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
>  	unsigned long nr_soft_reclaimed;
>  	unsigned long nr_soft_scanned;
>  	gfp_t orig_mask;
> -	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
>
>  	/*
>  	 * If the number of buffer_heads in the machine exceeds the maximum
> @@ -2536,15 +2555,15 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
> -		enum zone_type classzone_idx;
> -
>  		if (!populated_zone(zone))
>  			continue;
>
> -		classzone_idx = requested_highidx;
>  		while (!populated_zone(zone->zone_pgdat->node_zones +
> -							classzone_idx))
> +							classzone_idx)) {
> +			sc->reclaim_idx--;
>  			classzone_idx--;
> +			continue;

Isn't this wrong to do this across whole zonelist which will contain 
multiple nodes? Example: a small node 0 without Normal zone will get us 
sc->reclaim_idx == classzone_idx == dma32. Node 1 won't have dma/dma32 
zones so we won't see classzone_idx populated, and the while loop will 
lead to underflow?

And sc->reclaim_idx seems to be unitialized when called via 
try_to_free_pages() -> do_try_to_free_pages() -> shrink_zones() ?
Which means it's zero and we underflow immediately?

> @@ -3207,15 +3228,14 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			sc.may_writepage = 1;
>
>  		/*
> -		 * Now scan the zone in the dma->highmem direction, stopping
> -		 * at the last zone which needs scanning.
> -		 *
> -		 * We do this because the page allocator works in the opposite
> -		 * direction.  This prevents the page allocator from allocating
> -		 * pages behind kswapd's direction of progress, which would
> -		 * cause too much scanning of the lower zones.
> +		 * Continue scanning in the highmem->dma direction stopping at
> +		 * the last zone which needs scanning. This may reclaim lowmem
> +		 * pages that are not necessary for zone balancing but it
> +		 * preserves LRU ordering. It is assumed that the bulk of
> +		 * allocation requests can use arbitrary zones with the
> +		 * possible exception of big highmem:lowmem configurations.
>  		 */
> -		for (i = 0; i <= end_zone; i++) {
> +		for (i = end_zone; i >= end_zone; i--) {

				   i >= 0 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
