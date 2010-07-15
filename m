Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7C96B02A6
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 15:16:30 -0400 (EDT)
Date: Thu, 15 Jul 2010 12:15:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of
 lru_pages,  not page order
Message-Id: <20100715121551.bd5ccc61.akpm@linux-foundation.org>
In-Reply-To: <20100713144008.EA52.A69D9226@jp.fujitsu.com>
References: <20100708163934.CD37.A69D9226@jp.fujitsu.com>
	<AANLkTinwZfaQiTJhP8RcGhlSS-ynEXtbpzorrIZrNyIH@mail.gmail.com>
	<20100713144008.EA52.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 14:41:28 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Now, shrink_slab() has following scanning equation.
> 
>                             lru_scanned        max_pass
>   basic_scan_objects = 4 x -------------  x -----------------------------
>                             lru_pages        shrinker->seeks (default:2)
> 
>   scan_objects = min(basic_scan_objects, max_pass * 2)
> 
> Then, If we pass very small value as lru_pages instead real number of
> lru pages, shrink_slab() drop much objects rather than necessary. and
> now, __zone_reclaim() pass 'order' as lru_pages by mistake. that makes
> bad result.
> 
> Example, If we receive very low memory pressure (scan = 32, order = 0),
> shrink_slab() via zone_reclaim() always drop _all_ icache/dcache
> objects. (see above equation, very small lru_pages make very big
> scan_objects result)
> 
> This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6ff51c0..1bf9f72 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2612,6 +2612,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  
>  	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
>  	if (nr_slab_pages0 > zone->min_slab_pages) {
> +		unsigned long lru_pages = zone_reclaimable_pages(zone);
> +
>  		/*
>  		 * shrink_slab() does not currently allow us to determine how
>  		 * many pages were freed in this zone. So we take the current
> @@ -2622,7 +2624,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		 * Note that shrink_slab will free memory on all zones and may
>  		 * take a long time.
>  		 */
> -		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
> +		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
>  		       (zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
>  			nr_slab_pages0))
>  			;

Wouldn't it be better to recalculate zone_reclaimable_pages() each time
around the loop?  For example, shrink_icache_memory()->prune_icache()
will remove pagecache from an inode if it hits the tail of the list. 
This can change the number of reclaimable pages by squigabytes, but
this code thinks nothing changed?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
