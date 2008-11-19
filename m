Date: Wed, 19 Nov 2008 16:54:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after swap_cluster_max pages
Message-ID: <20081119165443.GB26749@csn.ul.ie>
References: <20081113171208.6985638e@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081113171208.6985638e@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 13, 2008 at 05:12:08PM -0500, Rik van Riel wrote:
> Sometimes the VM spends the first few priority rounds rotating back
> referenced pages and submitting IO.  Once we get to a lower priority,
> sometimes the VM ends up freeing way too many pages.
> 
> The fix is relatively simple: in shrink_zone() we can check how many
> pages we have already freed and break out of the loop.
> 
> However, in order to do this we do need to know how many pages we already
> freed, so move nr_reclaimed into scan_control.
> 
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> 
> ---
>  mm/vmscan.c |   60 ++++++++++++++++++++++++++++++------------------------------
>  1 file changed, 30 insertions(+), 30 deletions(-)
> 
> Index: linux-2.6.28-rc2-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.28-rc2-mm1.orig/mm/vmscan.c	2008-10-30 15:20:06.000000000 -0400
> +++ linux-2.6.28-rc2-mm1/mm/vmscan.c	2008-11-13 17:08:35.000000000 -0500
> @@ -53,6 +53,9 @@ struct scan_control {
>  	/* Incremented by the number of inactive pages that were scanned */
>  	unsigned long nr_scanned;
>  
> +	/* Number of pages that were freed */
> +	unsigned long nr_reclaimed;
> +

Is this not strictly true as this is used as a running count?

/* Number of pages freed so far during a call to shrink_zones() */ 

>  	/* This context's GFP mask */
>  	gfp_t gfp_mask;
>  
> @@ -1408,16 +1411,14 @@ static void get_scan_ratio(struct zone *
>  	percent[1] = 100 - percent[0];
>  }
>  
> -

nit, spurious whitespace change there.

>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> -static unsigned long shrink_zone(int priority, struct zone *zone,
> +static void shrink_zone(int priority, struct zone *zone,
>  				struct scan_control *sc)
>  {
>  	unsigned long nr[NR_LRU_LISTS];
>  	unsigned long nr_to_scan;
> -	unsigned long nr_reclaimed = 0;
>  	unsigned long percent[2];	/* anon @ 0; file @ 1 */
>  	enum lru_list l;
>  
> @@ -1458,10 +1459,18 @@ static unsigned long shrink_zone(int pri
>  					(unsigned long)sc->swap_cluster_max);
>  				nr[l] -= nr_to_scan;
>  
> -				nr_reclaimed += shrink_list(l, nr_to_scan,
> +				sc->nr_reclaimed += shrink_list(l, nr_to_scan,
>  							zone, sc, priority);
>  			}
>  		}
> +		/*
> +		 * On large memory systems, scan >> priority can become
> +		 * really large.  This is OK if we need to scan through
> +		 * that many pages (referenced, dirty, etc), but make
> +		 * sure to stop if we already freed enough.
> +		 */
> +		if (sc->nr_reclaimed > sc->swap_cluster_max)
> +			break;

This triggered alarm bells for me because I thought it would affect lumpy
reclaim. However, lumpy reclaim happens at a lower level and what I'd
expect to happen is that nr_reclaimed be at least the number of base pages
making up a high-order block for example. Thinking about it, this should be
safe but I ran it through the old anti-frag tests for hugepage allocations
(basically allocating hugepages under compile-load).

On some machines the situation improved very slighly but on one, the
success rates under load were severely impaired. On all machines at rest,
a one-shot attempt to resize the hugepage pool is resulting in much lower
success figures. However, multiple attempts eventually succeed and aggressive
resizing of the hugepage pool is resulting in higher success rates on all
but one machine.

Bottom line, hugepage pool resizing is taking more attempts but still
succeeding. While I'm not happy about the one-attempt hugepage pool resizing
being worse, I strongly suspect it's due to the current reclaim algorithm
reclaiming aggressively as a percentage of total memory and this behaviour
seems to make more sense overall. I'll re-examine how dynamic pool resizing
is and look at making it better if this change goes through.

With that out of the way, I also tried thinking about what this change really
means and have a few questions. This is all hand-wavy on my part and possibly
clueless so take it with a grain of salt.  Basically the changes comes down to;

o A process doing direct reclaim is not reclaiming a number of pages
  based on memory size and reclaim priority any more. Instead, it'll reclaim
  a bit and then check to see what the situation is.

Q1. There already is a check higher up to bail out when more than
swap_cluster_max pages are reclaimed. Should that change be now eliminated
as being redundant as it takes place "too late" when a lot of memory may
already been unnecessarily reclaimed?

Q2. In low-memory situations, it would appear that one process entering
direct reclaim (e.g. a process doing all the dirtying) might also have ended
up doing all of the cleaning. Is there a danger that a heavy-dirtying process
is now going to offload its cleaning work in small bits and pieces to every
other process entering direct reclaim?

Q3. Related to Q2, would it make sense to exclude kswapd from the check? On
the plus side, it may get to be the sucker process that does the scanning
and reclaim. On the downside, it may reclaim way more memory than is needed
to bring the free pages above the high watermark and becomes a variation of
the problem you are trying to solve here.

Q4. Less reclaim also means less scanning which means the aging information
of the pages on the lists is that bit older too. Do we care?

I was going to ask if it was easier to go OOM now, but even under very high
stress, we should be making forward progress. It's just in smaller steps so
I can't see it causing a problem.

>  	}
>  
>  	/*
> @@ -1474,7 +1483,6 @@ static unsigned long shrink_zone(int pri
>  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
>  
>  	throttle_vm_writeout(sc->gfp_mask);
> -	return nr_reclaimed;
>  }
>  
>  /*
> @@ -1488,16 +1496,13 @@ static unsigned long shrink_zone(int pri
>   * b) The zones may be over pages_high but they must go *over* pages_high to
>   *    satisfy the `incremental min' zone defense algorithm.
>   *
> - * Returns the number of reclaimed pages.
> - *
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
>   */
> -static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
> +static void shrink_zones(int priority, struct zonelist *zonelist,
>  					struct scan_control *sc)
>  {
>  	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
> -	unsigned long nr_reclaimed = 0;
>  	struct zoneref *z;
>  	struct zone *zone;
>  
> @@ -1528,10 +1533,8 @@ static unsigned long shrink_zones(int pr
>  							priority);
>  		}
>  
> -		nr_reclaimed += shrink_zone(priority, zone, sc);
> +		shrink_zone(priority, zone, sc);
>  	}
> -
> -	return nr_reclaimed;
>  }
>  
>  /*
> @@ -1556,7 +1559,6 @@ static unsigned long do_try_to_free_page
>  	int priority;
>  	unsigned long ret = 0;
>  	unsigned long total_scanned = 0;
> -	unsigned long nr_reclaimed = 0;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long lru_pages = 0;
>  	struct zoneref *z;
> @@ -1584,7 +1586,7 @@ static unsigned long do_try_to_free_page
>  		sc->nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> -		nr_reclaimed += shrink_zones(priority, zonelist, sc);
> +		shrink_zones(priority, zonelist, sc);
>  		/*
>  		 * Don't shrink slabs when reclaiming memory from
>  		 * over limit cgroups
> @@ -1592,13 +1594,13 @@ static unsigned long do_try_to_free_page
>  		if (scan_global_lru(sc)) {
>  			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
>  			if (reclaim_state) {
> -				nr_reclaimed += reclaim_state->reclaimed_slab;
> +				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>  				reclaim_state->reclaimed_slab = 0;
>  			}
>  		}
>  		total_scanned += sc->nr_scanned;
> -		if (nr_reclaimed >= sc->swap_cluster_max) {
> -			ret = nr_reclaimed;
> +		if (sc->nr_reclaimed >= sc->swap_cluster_max) {
> +			ret = sc->nr_reclaimed;
>  			goto out;
>  		}
>  
> @@ -1621,7 +1623,7 @@ static unsigned long do_try_to_free_page
>  	}
>  	/* top priority shrink_zones still had more to do? don't OOM, then */
>  	if (!sc->all_unreclaimable && scan_global_lru(sc))
> -		ret = nr_reclaimed;
> +		ret = sc->nr_reclaimed;
>  out:
>  	/*
>  	 * Now that we've scanned all the zones at this priority level, note
> @@ -1716,7 +1718,6 @@ static unsigned long balance_pgdat(pg_da
>  	int priority;
>  	int i;
>  	unsigned long total_scanned;
> -	unsigned long nr_reclaimed;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
> @@ -1735,7 +1736,7 @@ static unsigned long balance_pgdat(pg_da
>  
>  loop_again:
>  	total_scanned = 0;
> -	nr_reclaimed = 0;
> +	sc.nr_reclaimed = 0;
>  	sc.may_writepage = !laptop_mode;
>  	count_vm_event(PAGEOUTRUN);
>  
> @@ -1821,11 +1822,11 @@ loop_again:
>  			 */
>  			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
>  						end_zone, 0))
> -				nr_reclaimed += shrink_zone(priority, zone, &sc);
> +				shrink_zone(priority, zone, &sc);
>  			reclaim_state->reclaimed_slab = 0;
>  			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
>  						lru_pages);
> -			nr_reclaimed += reclaim_state->reclaimed_slab;
> +			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
>  			total_scanned += sc.nr_scanned;
>  			if (zone_is_all_unreclaimable(zone))
>  				continue;
> @@ -1839,7 +1840,7 @@ loop_again:
>  			 * even in laptop mode
>  			 */
>  			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> -			    total_scanned > nr_reclaimed + nr_reclaimed / 2)
> +			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
>  				sc.may_writepage = 1;
>  		}
>  		if (all_zones_ok)
> @@ -1857,7 +1858,7 @@ loop_again:
>  		 * matches the direct reclaim path behaviour in terms of impact
>  		 * on zone->*_priority.
>  		 */
> -		if (nr_reclaimed >= SWAP_CLUSTER_MAX)
> +		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
>  			break;
>  	}
>  out:
> @@ -1879,7 +1880,7 @@ out:
>  		goto loop_again;
>  	}
>  
> -	return nr_reclaimed;
> +	return sc.nr_reclaimed;
>  }
>  
>  /*
> @@ -2231,7 +2232,6 @@ static int __zone_reclaim(struct zone *z
>  	struct task_struct *p = current;
>  	struct reclaim_state reclaim_state;
>  	int priority;
> -	unsigned long nr_reclaimed = 0;
>  	struct scan_control sc = {
>  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
>  		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> @@ -2264,9 +2264,9 @@ static int __zone_reclaim(struct zone *z
>  		priority = ZONE_RECLAIM_PRIORITY;
>  		do {
>  			note_zone_scanning_priority(zone, priority);
> -			nr_reclaimed += shrink_zone(priority, zone, &sc);
> +			shrink_zone(priority, zone, &sc);
>  			priority--;
> -		} while (priority >= 0 && nr_reclaimed < nr_pages);
> +		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
>  	}
>  
>  	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> @@ -2290,13 +2290,13 @@ static int __zone_reclaim(struct zone *z
>  		 * Update nr_reclaimed by the number of slab pages we
>  		 * reclaimed from this zone.
>  		 */
> -		nr_reclaimed += slab_reclaimable -
> +		sc.nr_reclaimed += slab_reclaimable -
>  			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
>  	}
>  
>  	p->reclaim_state = NULL;
>  	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
> -	return nr_reclaimed >= nr_pages;
> +	return sc.nr_reclaimed >= nr_pages;
>  }
>  
>  int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
