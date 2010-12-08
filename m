Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E571B6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:21:09 -0500 (EST)
Date: Wed, 8 Dec 2010 14:19:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-Id: <20101208141909.5c9c60e8.akpm@linux-foundation.org>
In-Reply-To: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  8 Dec 2010 16:16:59 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Kswapd tries to rebalance zones persistently until their high
> watermarks are restored.
> 
> If the amount of unreclaimable pages in a zone makes this impossible
> for reclaim, though, kswapd will end up in a busy loop without a
> chance of reaching its goal.
> 
> This behaviour was observed on a virtual machine with a tiny
> Normal-zone that filled up with unreclaimable slab objects.

Doesn't this mean that vmscan is incorrectly handling its
zone->all_unreclaimable logic?

> This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> leaves them to direct reclaim.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2191,6 +2191,25 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  }
>  #endif
>  
> +static bool zone_needs_scan(struct zone *zone, int order,
> +			    unsigned long goal, int classzone_idx)
> +{
> +	unsigned long free, prospect;
> +
> +	free = zone_page_state(zone, NR_FREE_PAGES);
> +	if (zone->percpu_drift_mark && free < zone->percpu_drift_mark)
> +		free = zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +
> +	if (__zone_watermark_ok(zone, order, goal, classzone_idx, 0, free))
> +		return false;
> +	/*
> +	 * Ensure that the watermark is at all restorable through
> +	 * reclaim.  Otherwise, leave the zone to direct reclaim.
> +	 */
> +	prospect = free + zone_reclaimable_pages(zone);
> +	return prospect >= goal;
> +}

presumably in certain cases that's a bit more efficient than doing the
scan and using ->all_unreclaimable.  But the scanner shouldn't have got
stuck!  That's a regresion which got added, and I don't think that new
code of this nature was needed to fix that regression.

Did this zone end up with ->all_unreclaimable set?  If so, why was
kswapd stuck in a loop scanning an all-unreclaimable zone?


Also, if I'm understanding the new logic then if the "goal" is 100
pages and zone_reclaimable_pages() says "50 pages potentially
reclaimable" then kswapd won't reclaim *any* pages.  If so, is that
good behaviour?  Should we instead attempt to reclaim some of those 50
pages and then give up?  That sounds like a better strategy if we want
to keep (say) network Rx happening in a tight memory situation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
