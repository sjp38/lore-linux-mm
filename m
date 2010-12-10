Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 231C66B0088
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:22:40 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA1MXMu004762
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Dec 2010 10:22:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3CBF45DE67
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:22:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B810245DE5B
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:22:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8AA71DB8043
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:22:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 422641DB8042
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:22:32 +0900 (JST)
Date: Fri, 10 Dec 2010 10:16:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: kswapd: Keep kswapd awake for high-order
 allocations until a percentage of the node is balanced
Message-Id: <20101210101649.824e35ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291893500-12342-3-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu,  9 Dec 2010 11:18:16 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> When reclaiming for high-orders, kswapd is responsible for balancing a
> node but it should not reclaim excessively. It avoids excessive reclaim by
> considering if any zone in a node is balanced then the node is balanced. In
> the cases where there are imbalanced zone sizes (e.g. ZONE_DMA with both
> ZONE_DMA32 and ZONE_NORMAL), kswapd can go to sleep prematurely as just
> one small zone was balanced.
> 
> This alters the sleep logic of kswapd slightly. It counts the number of pages
> that make up the balanced zones. If the total number of balanced pages is
> more than a quarter of the zone, kswapd will go back to sleep. This should
> keep a node balanced without reclaiming an excessive number of pages.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Hmm, does this work well in

for example, x86-32,
	DMA: 16MB
	NORMAL: 700MB
	HIGHMEM: 11G
?

At 1st look, it's balanced when HIGHMEM has enough free pages...
This is not good for NICs which requests high-order allocations.

Can't we take claszone_idx into account at checking rather than
node->present_pages ?

as
	balanced > present_pages_below_classzone_idx(node, classzone_idx)/4

?
Thanks,
-Kame

> ---
>  mm/vmscan.c |   43 ++++++++++++++++++++++++++++++++++---------
>  1 files changed, 34 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 25cb373..b4472a1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2117,10 +2117,26 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  }
>  #endif
>  
> +/*
> + * pgdat_balanced is used when checking if a node is balanced for high-order
> + * allocations. Only zones that meet watermarks make up "balanced".
> + * The total of balanced pages must be at least 25% of the node for the
> + * node to be considered balanced. Forcing all zones to be balanced for high
> + * orders can cause excessive reclaim when there are imbalanced zones.
> + * Similarly, we do not want kswapd to go to sleep because ZONE_DMA happens
> + * to be balanced when ZONE_DMA32 is huge in comparison and unbalanced
> + */
> +static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced)
> +{
> +	return balanced > pgdat->node_present_pages / 4;
> +}
> +
>  /* is kswapd sleeping prematurely? */
>  static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  {
>  	int i;
> +	unsigned long balanced = 0;
> +	bool all_zones_ok = true;
>  
>  	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
>  	if (remaining)
> @@ -2138,10 +2154,19 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  
>  		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
>  								0, 0))
> -			return 1;
> +			all_zones_ok = false;
> +		else
> +			balanced += zone->present_pages;
>  	}
>  
> -	return 0;
> +	/*
> +	 * For high-order requests, any zone meeting the watermark allows
> +	 * kswapd to sleep. For order-0, all zones must be balanced
> +	 */
> +	if (order)
> +		return pgdat_balanced(pgdat, balanced);
> +	else
> +		return !all_zones_ok;
>  }
>  
>  /*
> @@ -2169,7 +2194,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  							int classzone_idx)
>  {
>  	int all_zones_ok;
> -	int any_zone_ok;
> +	unsigned long balanced;
>  	int priority;
>  	int i;
>  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> @@ -2203,7 +2228,7 @@ loop_again:
>  			disable_swap_token();
>  
>  		all_zones_ok = 1;
> -		any_zone_ok = 0;
> +		balanced = 0;
>  
>  		/*
>  		 * Scan in the highmem->dma direction for the highest
> @@ -2314,11 +2339,11 @@ loop_again:
>  				 */
>  				zone_clear_flag(zone, ZONE_CONGESTED);
>  				if (i <= classzone_idx)
> -					any_zone_ok = 1;
> +					balanced += zone->present_pages;
>  			}
>  
>  		}
> -		if (all_zones_ok || (order && any_zone_ok))
> +		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced)))
>  			break;		/* kswapd: all done */
>  		/*
>  		 * OK, kswapd is getting into trouble.  Take a nap, then take
> @@ -2344,10 +2369,10 @@ out:
>  
>  	/*
>  	 * order-0: All zones must meet high watermark for a balanced node
> -	 * high-order: Any zone below pgdats classzone_idx must meet the high
> -	 *             watermark for a balanced node
> +	 * high-order: Balanced zones must make up at least 25% of the node
> +	 *             for the node to be balanced
>  	 */
> -	if (!(all_zones_ok || (order && any_zone_ok))) {
> +	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced)))) {
>  		cond_resched();
>  
>  		try_to_freeze();
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
