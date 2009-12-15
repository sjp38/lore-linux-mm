Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8CE696B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 19:16:45 -0500 (EST)
Received: by yxe10 with SMTP id 10so3352712yxe.12
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 16:16:39 -0800 (PST)
Date: Tue, 15 Dec 2009 09:11:07 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 6/8] Stop reclaim quickly when the task reclaimed enough
 lots pages
Message-Id: <20091215091107.219644fe.minchan.kim@barrios-desktop>
In-Reply-To: <20091214213103.BBC0.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	<20091214210823.BBAE.A69D9226@jp.fujitsu.com>
	<20091214213103.BBC0.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 21:31:36 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> From latency view, There isn't any reason shrink_zones() continue to
> reclaim another zone's page if the task reclaimed enough lots pages.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |   16 ++++++++++++----
>  1 files changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0880668..bf229d3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1654,7 +1654,7 @@ static void shrink_zone_end(struct zone *zone, struct scan_control *sc)
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> -static void shrink_zone(int priority, struct zone *zone,
> +static int shrink_zone(int priority, struct zone *zone,
>  			struct scan_control *sc)
>  {
>  	unsigned long nr[NR_LRU_LISTS];
> @@ -1669,7 +1669,7 @@ static void shrink_zone(int priority, struct zone *zone,
>  
>  	ret = shrink_zone_begin(zone, sc);
>  	if (ret)
> -		return;
> +		return ret;
>  
>  	/* If we have no swap space, do not bother scanning anon pages. */
>  	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> @@ -1692,6 +1692,7 @@ static void shrink_zone(int priority, struct zone *zone,
>  					  &reclaim_stat->nr_saved_scan[l]);
>  	}
>  
> +	ret = 0;
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {
>  		for_each_evictable_lru(l) {
> @@ -1712,8 +1713,10 @@ static void shrink_zone(int priority, struct zone *zone,
>  		 * with multiple processes reclaiming pages, the total
>  		 * freeing target can get unreasonably large.
>  		 */
> -		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
> +		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY) {
> +			ret = -ERESTARTSYS;

Just nitpick. 

shrink_zone's return value is matter?
shrink_zones never handle that. 

>  			break;
> +		}
>  	}
>  
>  	sc->nr_reclaimed = nr_reclaimed;
> @@ -1727,6 +1730,8 @@ static void shrink_zone(int priority, struct zone *zone,
>  
>  	throttle_vm_writeout(sc->gfp_mask);
>  	shrink_zone_end(zone, sc);
> +
> +	return ret;
>  }
>  
>  /*
> @@ -1751,6 +1756,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
>  	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
>  	struct zoneref *z;
>  	struct zone *zone;
> +	int ret;
>  
>  	sc->all_unreclaimable = 1;
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> @@ -1780,7 +1786,9 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
>  							priority);
>  		}
>  
> -		shrink_zone(priority, zone, sc);
> +		ret = shrink_zone(priority, zone, sc);
> +		if (ret)
> +			return;
>  	}
>  }


> -- 
> 1.6.5.2
> 
> 
> 

As a matter of fact, I am worried about this patch. 

My opinion is we put aside this patch until we can solve Larry's problem.
We could apply this patch in future.

I don't want to see the side effect while we focus Larry's problem.
But If you mind my suggestion, I also will not bother you by this nitpick.


Thanks for great cleanup and improving VM, Kosaki. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
