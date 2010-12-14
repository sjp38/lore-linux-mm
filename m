Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B143B6B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 17:43:55 -0500 (EST)
Date: Tue, 14 Dec 2010 14:43:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/6] mm: kswapd: Keep kswapd awake for high-order
 allocations until a percentage of the node is balanced
Message-Id: <20101214144341.71b43cb5.akpm@linux-foundation.org>
In-Reply-To: <1291995985-5913-3-git-send-email-mel@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
	<1291995985-5913-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010 15:46:21 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> When reclaiming for high-orders, kswapd is responsible for balancing a
> node but it should not reclaim excessively. It avoids excessive reclaim by
> considering if any zone in a node is balanced then the node is balanced.

Here you're referring to your [patch 1/6] yes?  Not to current upstream.

> In
> the cases where there are imbalanced zone sizes (e.g. ZONE_DMA with both
> ZONE_DMA32 and ZONE_NORMAL), kswapd can go to sleep prematurely as just
> one small zone was balanced.

Since [1/6]?

> This alters the sleep logic of kswapd slightly. It counts the number of pages
> that make up the balanced zones. If the total number of balanced pages is

Define "balanced page"?  Seems to be the sum of the total sizes of all
zones which have reached their desired free-pages threshold?

But this includes all page orders, whereas here we're targetting a
particular order.  Although things should work out OK due to the
scaling/sizing proportionality.

> more than a quarter of the zone, kswapd will go back to sleep. This should
> keep a node balanced without reclaiming an excessive number of pages.

ick.

> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/vmscan.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 49 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 625dfba..6723101 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2191,10 +2191,40 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  }
>  #endif
>  
> +/*
> + * pgdat_balanced is used when checking if a node is balanced for high-order
> + * allocations.

Is this the correct use of the term "balanced"?  I think "balanced" is
something that happens *between* zones: They've all achieved the same
(perhaps weighted) ratio of free pages.  

>  Only zones that meet watermarks and are in a zone allowed
> + * by the callers classzone_idx are added to balanced_pages. The total of

caller's

> + * balanced pages must be at least 25% of the zones allowed by classzone_idx
> + * for the node to be considered balanced. Forcing all zones to be balanced
> + * for high orders can cause excessive reclaim when there are imbalanced zones.

Excessive reclaim of what?

If one particular zone is having trouble achieving its desired level of
free pages of a partocular order, are you saying that kswapd sits there
madly scanning other zones, which have already reached their desired
level?  If so, that would be bad.

I think you're saying that we just keep on scanning away at this one
zone.  But what was wrong with doing that?

> + * The choice of 25% is due to
> + *   o a 16M DMA zone that is balanced will not balance a zone on any
> + *     reasonable sized machine

How does a zone balance another zone?

> + *   o On all other machines, the top zone must be at least a reasonable
> + *     precentage of the middle zones. For example, on 32-bit x86, highmem
> + *     would need to be at least 256M for it to be balance a whole node.
> + *     Similarly, on x86-64 the Normal zone would need to be at least 1G
> + *     to balance a node on its own. These seemed like reasonable ratios.
> + */
> +static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
> +						int classzone_idx)
> +{
> +	unsigned long present_pages = 0;
> +	int i;
> +
> +	for (i = 0; i <= classzone_idx; i++)
> +		present_pages += pgdat->node_zones[i].present_pages;
> +
> +	return balanced_pages > (present_pages >> 2);
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
