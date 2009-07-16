Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8DBC66B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 19:53:42 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6GNrlUd016433
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Jul 2009 08:53:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CA192AEA81
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:53:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B60B45DE4D
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:53:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 615BD1DB803B
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:53:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F9531DB803A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:53:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: count only reclaimable lru pages v2
In-Reply-To: <20090716150901.GA31204@localhost>
References: <4A5F3C70.7010001@redhat.com> <20090716150901.GA31204@localhost>
Message-Id: <20090717085108.A8FD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 08:53:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> ---
> mm: count only reclaimable lru pages 
> 
> global_lru_pages() / zone_lru_pages() can be used in two ways:
> - to estimate max reclaimable pages in determine_dirtyable_memory()  
> - to calculate the slab scan ratio
> 
> When swap is full or not present, the anon lru lists are not reclaimable
> and also won't be scanned. So the anon pages shall not be counted in both
> usage scenarios. Also rename to _reclaimable_pages: now they are counting
> the possibly reclaimable lru pages.
> 
> It can greatly (and correctly) increase the slab scan rate under high memory
> pressure (when most file pages have been reclaimed and swap is full/absent),
> thus reduce false OOM kills.
> 
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/vmstat.h |   11 +-------
>  mm/page-writeback.c    |    5 ++-
>  mm/vmscan.c            |   50 ++++++++++++++++++++++++++++++---------
>  3 files changed, 44 insertions(+), 22 deletions(-)
> 
> --- linux.orig/include/linux/vmstat.h
> +++ linux/include/linux/vmstat.h
> @@ -166,15 +166,8 @@ static inline unsigned long zone_page_st
>  	return x;
>  }
>  
> -extern unsigned long global_lru_pages(void);
> -
> -static inline unsigned long zone_lru_pages(struct zone *zone)
> -{
> -	return (zone_page_state(zone, NR_ACTIVE_ANON)
> -		+ zone_page_state(zone, NR_ACTIVE_FILE)
> -		+ zone_page_state(zone, NR_INACTIVE_ANON)
> -		+ zone_page_state(zone, NR_INACTIVE_FILE));
> -}
> +extern unsigned long global_reclaimable_pages(void);
> +extern unsigned long zone_reclaimable_pages(struct zone *zone);
>  
>  #ifdef CONFIG_NUMA
>  /*
> --- linux.orig/mm/page-writeback.c
> +++ linux/mm/page-writeback.c
> @@ -380,7 +380,8 @@ static unsigned long highmem_dirtyable_m
>  		struct zone *z =
>  			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
>  
> -		x += zone_page_state(z, NR_FREE_PAGES) + zone_lru_pages(z);
> +		x += zone_page_state(z, NR_FREE_PAGES) +
> +		     zone_reclaimable_pages(z);
>  	}
>  	/*
>  	 * Make sure that the number of highmem pages is never larger
> @@ -404,7 +405,7 @@ unsigned long determine_dirtyable_memory
>  {
>  	unsigned long x;
>  
> -	x = global_page_state(NR_FREE_PAGES) + global_lru_pages();
> +	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
>  
>  	if (!vm_highmem_is_dirtyable)
>  		x -= highmem_dirtyable_memory(x);
> --- linux.orig/mm/vmscan.c
> +++ linux/mm/vmscan.c
> @@ -1735,7 +1735,7 @@ static unsigned long do_try_to_free_page
>  			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  				continue;
>  
> -			lru_pages += zone_lru_pages(zone);
> +			lru_pages += zone_reclaimable_pages(zone);
>  		}
>  	}
>  
> @@ -1952,7 +1952,7 @@ loop_again:
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
>  
> -			lru_pages += zone_lru_pages(zone);
> +			lru_pages += zone_reclaimable_pages(zone);
>  		}
>  
>  		/*
> @@ -1996,7 +1996,7 @@ loop_again:
>  			if (zone_is_all_unreclaimable(zone))
>  				continue;
>  			if (nr_slab == 0 && zone->pages_scanned >=
> -						(zone_lru_pages(zone) * 6))
> +					(zone_reclaimable_pages(zone) * 6))
>  					zone_set_flag(zone,
>  						      ZONE_ALL_UNRECLAIMABLE);
>  			/*
> @@ -2163,12 +2163,39 @@ void wakeup_kswapd(struct zone *zone, in
>  	wake_up_interruptible(&pgdat->kswapd_wait);
>  }
>  
> -unsigned long global_lru_pages(void)
> +/*
> + * The reclaimable count would be mostly accurate.
> + * The less reclaimable pages may be
> + * - mlocked pages, which will be moved to unevictable list when encountered
> + * - mapped pages, which may require several travels to be reclaimed
> + * - dirty pages, which is not "instantly" reclaimable
> + */
> +unsigned long global_reclaimable_pages(void)
>  {
> -	return global_page_state(NR_ACTIVE_ANON)
> -		+ global_page_state(NR_ACTIVE_FILE)
> -		+ global_page_state(NR_INACTIVE_ANON)
> -		+ global_page_state(NR_INACTIVE_FILE);
> +	int nr;
> +
> +	nr = global_page_state(NR_ACTIVE_FILE) +
> +	     global_page_state(NR_INACTIVE_FILE);
> +
> +	if (nr_swap_pages > 0)
> +		nr += global_page_state(NR_ACTIVE_ANON) +
> +		      global_page_state(NR_INACTIVE_ANON);
> +
> +	return nr;
> +}
> +
> +unsigned long zone_reclaimable_pages(struct zone *zone)
> +{
> +	int nr;
> +
> +	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> +	     zone_page_state(zone, NR_INACTIVE_FILE);
> +
> +	if (nr_swap_pages > 0)
> +		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> +		      zone_page_state(zone, NR_INACTIVE_ANON);
> +
> +	return nr;
>  }
>  
>  #ifdef CONFIG_HIBERNATION
> @@ -2240,7 +2267,7 @@ unsigned long shrink_all_memory(unsigned
>  
>  	current->reclaim_state = &reclaim_state;
>  
> -	lru_pages = global_lru_pages();
> +	lru_pages = global_reclaimable_pages();
>  	nr_slab = global_page_state(NR_SLAB_RECLAIMABLE);
>  	/* If slab caches are huge, it's better to hit them first */
>  	while (nr_slab >= lru_pages) {
> @@ -2282,7 +2309,7 @@ unsigned long shrink_all_memory(unsigned
>  
>  			reclaim_state.reclaimed_slab = 0;
>  			shrink_slab(sc.nr_scanned, sc.gfp_mask,
> -					global_lru_pages());
> +				    global_reclaimable_pages());
>  			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
>  			if (sc.nr_reclaimed >= nr_pages)
>  				goto out;
> @@ -2299,7 +2326,8 @@ unsigned long shrink_all_memory(unsigned
>  	if (!sc.nr_reclaimed) {
>  		do {
>  			reclaim_state.reclaimed_slab = 0;
> -			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
> +			shrink_slab(nr_pages, sc.gfp_mask,
> +				    global_reclaimable_pages());
>  			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
>  		} while (sc.nr_reclaimed < nr_pages &&
>  				reclaim_state.reclaimed_slab > 0);
> 

I feel like I already reviewed this patch past days..
Anyway,

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
