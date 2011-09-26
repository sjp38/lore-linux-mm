Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 022A19000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:02:19 -0400 (EDT)
Date: Mon, 26 Sep 2011 16:02:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -mm] limit direct reclaim for higher order allocations
Message-ID: <20110926150212.GB11313@suse.de>
References: <20110926095507.34a2c48c@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110926095507.34a2c48c@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Sep 26, 2011 at 09:55:07AM -0400, Rik van Riel wrote:
> When suffering from memory fragmentation due to unfreeable pages,
> THP page faults will repeatedly try to compact memory.  Due to
> the unfreeable pages, compaction fails.
> 
> Needless to say, at that point page reclaim also fails to create
> free contiguous 2MB areas.  However, that doesn't stop the current
> code from trying, over and over again, and freeing a minimum of
> 4MB (2UL << sc->order pages) at every single invocation.
> 
> This resulted in my 12GB system having 2-3GB free memory, a
> corresponding amount of used swap and very sluggish response times.
> 
> This can be avoided by having the direct reclaim code not reclaim
> from zones that already have plenty of free memory available for
> compaction.
> 
> If compaction still fails due to unmovable memory, doing additional
> reclaim will only hurt the system, not help.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> I believe Mel has another idea in mind on how to fix this issue. 
> I believe it will be good to compare both approaches side by side...
> 
>  mm/vmscan.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b7719ec..56811a1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2083,6 +2083,22 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
>  				continue;
>  			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
>  				continue;	/* Let kswapd poll it */
> +			if (COMPACTION_BUILD) {
> +				/*
> +				 * If we already have plenty of memory free
> +				 * for compaction, don't free any more.
> +				 */
> +				unsigned long balance_gap;
> +				balance_gap = min(low_wmark_pages(zone),
> +					(zone->present_pages +
> +					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> +					KSWAPD_ZONE_BALANCE_GAP_RATIO);
> +				if (sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> +					zone_watermark_ok_safe(zone, 0,
> +					high_wmark_pages(zone) + balance_gap +
> +					(2UL << sc->order), 0, 0))
> +					continue;
> +			}

I don't have a proper patch prepared but I think it is a mistake for
reclaim and compaction to be using different logic when deciding
if action should be taken. Compaction uses compaction_suitable()
and compaction_deferred() to decide whether it should compact or not
and reclaim/compaction should share the same logic. I don't have a
proper patch but the check would look something like;

                /*
                 * If reclaiming for THP, check if try_to_compact_pages
                 * would try and compact this zone or if compaction is deferred
                 * due to a recent failure. If these conditions are met,
                 * we should not reclaim more pages as the cost of reclaiming an
                 * excessive number of pages exceeds the benefit of using huge
                 * pages. If we are not reclaiming, pretend we have reclaimed
		 * pages so the caller bails.
                 */
                if ((sc->gfp_mask & __GFP_NO_KSWAPD) &&
                        (compaction_suitable(zone, sc->order) ||
                                compaction_deferred(zone))) {
			sc->nr_scanned = SWAP_CLUSTER_MAX;
			sc->nr_reclaimed = SWAP_CLUSTER_MAX;
			continue;
		}

compaction_suitable() takes into account the amount of free memory
so it is similar to your patch in that it takes into account "if we
already have plenty of memory free for compaction".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
