Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DE0DF6B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:02:06 -0400 (EDT)
Date: Thu, 8 Jul 2010 13:00:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] vmscan: don't subtraction of unsined
Message-Id: <20100708130048.fccfcdad.akpm@linux-foundation.org>
In-Reply-To: <20100708163401.CD34.A69D9226@jp.fujitsu.com>
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu,  8 Jul 2010 16:38:10 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 'slab_reclaimable' and 'nr_pages' are unsigned. so, subtraction is
> unsafe.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> ---
>  mm/vmscan.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9c7e57c..8715da1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2588,7 +2588,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		.swappiness = vm_swappiness,
>  		.order = order,
>  	};
> -	unsigned long slab_reclaimable;
> +	unsigned long n, m;

Please use better identifiers.

>  	disable_swap_token();
>  	cond_resched();
> @@ -2615,8 +2615,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
>  	}
>  
> -	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> -	if (slab_reclaimable > zone->min_slab_pages) {
> +	n = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> +	if (n > zone->min_slab_pages) {
>  		/*
>  		 * shrink_slab() does not currently allow us to determine how
>  		 * many pages were freed in this zone. So we take the current
> @@ -2628,16 +2628,16 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		 * take a long time.
>  		 */
>  		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
> -			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
> -				slab_reclaimable - nr_pages)
> +		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages > n))
>  			;
>  
>  		/*
>  		 * Update nr_reclaimed by the number of slab pages we
>  		 * reclaimed from this zone.
>  		 */
> -		sc.nr_reclaimed += slab_reclaimable -
> -			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> +		m = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> +		if (m < n)
> +			sc.nr_reclaimed += n - m;

And it's not a completly trivial objection.  Your patch made the above
code snippet quite a lot harder to read (and hence harder to maintain).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
