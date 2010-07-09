Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 250A46B024D
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 18:29:29 -0400 (EDT)
Date: Fri, 9 Jul 2010 15:28:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] vmscan: don't subtraction of unsined
Message-Id: <20100709152851.330bf2b2.akpm@linux-foundation.org>
In-Reply-To: <20100709090956.CD51.A69D9226@jp.fujitsu.com>
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com>
	<20100708130048.fccfcdad.akpm@linux-foundation.org>
	<20100709090956.CD51.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri,  9 Jul 2010 10:16:33 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2588,7 +2588,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		.swappiness = vm_swappiness,
>  		.order = order,
>  	};
> -	unsigned long slab_reclaimable;
> +	unsigned long nr_slab_pages0, nr_slab_pages1;
>  
>  	disable_swap_token();
>  	cond_resched();
> @@ -2615,8 +2615,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
>  	}
>  
> -	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> -	if (slab_reclaimable > zone->min_slab_pages) {
> +	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> +	if (nr_slab_pages0 > zone->min_slab_pages) {
>  		/*
>  		 * shrink_slab() does not currently allow us to determine how
>  		 * many pages were freed in this zone.

Well no, but it could do so, with some minor changes to struct
reclaim_state and its handling.  Put a zone* and a counter in
reclaim_state, handle them in sl?b.c.

> So we take the current
> @@ -2628,16 +2628,17 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		 * take a long time.
>  		 */
>  		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
> -			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
> -				slab_reclaimable - nr_pages)
> +		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
> +				nr_slab_pages0))
>  			;
>  
>  		/*
>  		 * Update nr_reclaimed by the number of slab pages we
>  		 * reclaimed from this zone.
>  		 */
> -		sc.nr_reclaimed += slab_reclaimable -
> -			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> +		nr_slab_pages1 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> +		if (nr_slab_pages1 < nr_slab_pages0)
> +			sc.nr_reclaimed += nr_slab_pages0 - nr_slab_pages1;

My, that's horrible.  The whole expression says "this number is
basically a pile of random junk.  Let's add it in anyway".


>  	}
>  
>  	p->reclaim_state = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
