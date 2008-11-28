Date: Fri, 28 Nov 2008 23:43:04 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
Message-ID: <20081128224304.GB7828@cmpxchg.org>
References: <20081128060803.73cd59bd@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081128060803.73cd59bd@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 28, 2008 at 06:08:03AM -0500, Rik van Riel wrote:
> Skip freeing memory from zones that already have lots of free memory.
> If one memory zone has harder to free memory, we want to avoid freeing
> excessive amounts of memory from other zones, if only because pageout
> IO from the other zones can slow down page freeing from the problem zone.
> 
> This is similar to the check already done by kswapd in balance_pgdat().
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@saeurebad.de>

> ---
> Kosaki-san, this should address point (3) from your list.
> 
>  mm/vmscan.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> Index: linux-2.6.28-rc5/mm/vmscan.c
> ===================================================================
> --- linux-2.6.28-rc5.orig/mm/vmscan.c	2008-11-28 05:53:56.000000000 -0500
> +++ linux-2.6.28-rc5/mm/vmscan.c	2008-11-28 06:05:29.000000000 -0500
> @@ -1510,6 +1510,9 @@ static unsigned long shrink_zones(int pr
>  			if (zone_is_all_unreclaimable(zone) &&
>  						priority != DEF_PRIORITY)
>  				continue;	/* Let kswapd poll it */
> +			if (zone_watermark_ok(zone, sc->order,
> +					4*zone->pages_high, high_zoneidx, 0))
> +				continue;	/* Lots free already */
>  			sc->all_unreclaimable = 0;
>  		} else {
>  			/*
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
