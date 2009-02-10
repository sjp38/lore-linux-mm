Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0906B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 11:21:32 -0500 (EST)
Date: Tue, 10 Feb 2009 17:20:52 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] shrink_all_memory() use sc.nr_reclaimed
Message-ID: <20090210162052.GB2371@cmpxchg.org>
References: <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com> <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210215811.7010.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090210215811.7010.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 10:00:26PM +0900, KOSAKI Motohiro wrote:
> Impact: cleanup
> 
> Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
> direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
> counter into the scan control to accumulate the number of all
> reclaimed pages in a reclaim invocation.
> 
> shrink_all_memory() can use the same mechanism. it increase code 
> consistency.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: MinChan Kim <minchan.kim@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |   49 ++++++++++++++++++++++++-------------------------
>  1 file changed, 24 insertions(+), 25 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2004,16 +2004,15 @@ unsigned long global_lru_pages(void)
>  #ifdef CONFIG_PM
>  /*
>   * Helper function for shrink_all_memory().  Tries to reclaim 'nr_pages' pages
> - * from LRU lists system-wide, for given pass and priority, and returns the
> - * number of reclaimed pages
> + * from LRU lists system-wide, for given pass and priority.
>   *
>   * For pass > 3 we also try to shrink the LRU lists that contain a few pages
>   */
> -static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
> +static void shrink_all_zones(unsigned long nr_pages, int prio,
>  				      int pass, struct scan_control *sc)
>  {
>  	struct zone *zone;
> -	unsigned long nr_to_scan, ret = 0;
> +	unsigned long nr_to_scan;
>  	enum lru_list l;

Basing it on swsusp-clean-up-shrink_all_zones.patch probably makes it
easier for Andrew to pick it up.

>  	for_each_zone(zone) {
> @@ -2038,15 +2037,13 @@ static unsigned long shrink_all_zones(un
>  				nr_to_scan = min(nr_pages,
>  					zone_page_state(zone,
>  							NR_LRU_BASE + l));
> -				ret += shrink_list(l, nr_to_scan, zone,
> -								sc, prio);
> -				if (ret >= nr_pages)
> -					return ret;
> +				sc->nr_reclaimed += shrink_list(l, nr_to_scan,
> +								zone, sc, prio);
> +				if (sc->nr_reclaimed >= nr_pages)
> +					return;
>  			}
>  		}
>  	}
> -
> -	return ret;
>  }
>  
>  /*
> @@ -2060,10 +2057,10 @@ static unsigned long shrink_all_zones(un
>  unsigned long shrink_all_memory(unsigned long nr_pages)
>  {
>  	unsigned long lru_pages, nr_slab;
> -	unsigned long ret = 0;
>  	int pass;
>  	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
> +		.nr_reclaimed = 0,
>  		.gfp_mask = GFP_KERNEL,
>  		.may_swap = 0,
>  		.swap_cluster_max = nr_pages,
> @@ -2083,8 +2080,8 @@ unsigned long shrink_all_memory(unsigned
>  		if (!reclaim_state.reclaimed_slab)
>  			break;
>  
> -		ret += reclaim_state.reclaimed_slab;
> -		if (ret >= nr_pages)
> +		sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> +		if (sc.nr_reclaimed >= nr_pages)
>  			goto out;
>  
>  		nr_slab -= reclaim_state.reclaimed_slab;
> @@ -2108,18 +2105,18 @@ unsigned long shrink_all_memory(unsigned
>  		}
>  
>  		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
> -			unsigned long nr_to_scan = nr_pages - ret;
> +			unsigned long nr_to_scan = nr_pages - sc.nr_reclaimed;
>  
>  			sc.nr_scanned = 0;
> -			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
> -			if (ret >= nr_pages)
> +			shrink_all_zones(nr_to_scan, prio, pass, &sc);
> +			if (sc.nr_reclaimed >= nr_pages)
>  				goto out;
>  
>  			reclaim_state.reclaimed_slab = 0;
>  			shrink_slab(sc.nr_scanned, sc.gfp_mask,
>  					global_lru_pages());
> -			ret += reclaim_state.reclaimed_slab;
> -			if (ret >= nr_pages)
> +			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> +			if (sc.nr_reclaimed >= nr_pages)
>  				goto out;
>  
>  			if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
> @@ -2128,21 +2125,23 @@ unsigned long shrink_all_memory(unsigned
>  	}
>  
>  	/*
> -	 * If ret = 0, we could not shrink LRUs, but there may be something
> -	 * in slab caches
> +	 * If sc.nr_reclaimed = 0, we could not shrink LRUs, but there may be
> +	 * something in slab caches
>  	 */
> -	if (!ret) {
> +	if (!sc.nr_reclaimed) {
>  		do {
>  			reclaim_state.reclaimed_slab = 0;
> -			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
> -			ret += reclaim_state.reclaimed_slab;
> -		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
> +			shrink_slab(nr_pages, sc.gfp_mask,
> +				    global_lru_pages());
> +			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> +		} while (sc.nr_reclaimed < nr_pages &&
> +			 reclaim_state.reclaimed_slab > 0);

:(

Is this really an improvement?  `ret' is better to read than
`sc.nr_reclaimed'.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
