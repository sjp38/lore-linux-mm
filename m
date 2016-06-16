Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 415676B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:35:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so22982882lfa.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:35:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w137si4519637wme.18.2016.06.16.06.35.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 06:35:20 -0700 (PDT)
Subject: Re: [PATCH 12/27] mm, vmscan: Make shrink_node decisions more
 node-centric
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-13-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a411d98e-acfb-9658-22b1-4bbefb1e00d7@suse.cz>
Date: Thu, 16 Jun 2016 15:35:15 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-13-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Earlier patches focused on having direct reclaim and kswapd use data that
> is node-centric for reclaiming but shrink_node() itself still uses too much
> zone information. This patch removes unnecessary zone-based information
> with the most important decision being whether to continue reclaim or
> not. Some memcg APIs are adjusted as a result even though memcg itself
> still uses some zone information.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

[...]

> @@ -2372,21 +2374,27 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	 * inactive lists are large enough, continue reclaiming
>  	 */
>  	pages_for_compaction = (2UL << sc->order);
> -	inactive_lru_pages = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
> +	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
>  	if (get_nr_swap_pages() > 0)
> -		inactive_lru_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
> +		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
>  	if (sc->nr_reclaimed < pages_for_compaction &&
>  			inactive_lru_pages > pages_for_compaction)
>  		return true;
>
>  	/* If compaction would go ahead or the allocation would succeed, stop */
> -	switch (compaction_suitable(zone, sc->order, 0, 0)) {
> -	case COMPACT_PARTIAL:
> -	case COMPACT_CONTINUE:
> -		return false;
> -	default:
> -		return true;
> +	for (z = 0; z <= sc->reclaim_idx; z++) {
> +		struct zone *zone = &pgdat->node_zones[z];
> +
> +		switch (compaction_suitable(zone, sc->order, 0, 0)) {

Using 0 for classzone_idx here was sort of OK when each zone was 
reclaimed separately, as a Normal allocation not passing appropriate 
classzone_idx (and thus subtracting lowmem reserve from free pages) 
means that a false COMPACT_PARTIAL (or COMPACT_CONTINUE) could be 
returned for e.g. DMA zone. It means a premature end of reclaim for this 
single zone, which is relatively small anyway, so no big deal (and we 
might avoid useless over-reclaim, when even reclaiming everything 
wouldn't get us above the lowmem_reserve).

But in node-centric reclaim, such premature "return false" from a DMA 
zone stops reclaiming the whole node. So I think we should involve the 
real classzone_idx here.

> +		case COMPACT_PARTIAL:
> +		case COMPACT_CONTINUE:
> +			return false;
> +		default:
> +			/* check next zone */
> +			;
> +		}
>  	}
> +	return true;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
