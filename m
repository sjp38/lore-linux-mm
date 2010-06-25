Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 879416B01AF
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 10:17:35 -0400 (EDT)
Date: Fri, 25 Jun 2010 09:17:03 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/2] vmscan: don't subtraction of unsined 
In-Reply-To: <20100625202126.806A.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006250912380.18900@router.home>
References: <20100625201915.8067.A69D9226@jp.fujitsu.com> <20100625202126.806A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, KOSAKI Motohiro wrote:

> 'slab_reclaimable' and 'nr_pages' are unsigned. so, subtraction is
> unsafe.

Why? We are subtracting the current value of NR_SLAB_RECLAIMABLE from the
earlier one. The result can be negative (maybe concurrent allocations) and
then the nr_reclaimed gets decremented instead. This is  okay since we
have not reached our goal then of reducing the number of reclaimable slab
pages on the zone.

> @@ -2622,17 +2624,21 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		 * Note that shrink_slab will free memory on all zones and may
>  		 * take a long time.
>  		 */
> -		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
> -			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
> -				slab_reclaimable - nr_pages)

The comparison could be a problem here. So

			zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
				slab_reclaimable

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
