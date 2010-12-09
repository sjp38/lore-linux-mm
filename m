Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A16E76B0088
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 19:36:40 -0500 (EST)
Date: Wed, 8 Dec 2010 16:36:21 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101209003621.GB3796@hostway.ca>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:

> Kswapd tries to rebalance zones persistently until their high
> watermarks are restored.
> 
> If the amount of unreclaimable pages in a zone makes this impossible
> for reclaim, though, kswapd will end up in a busy loop without a
> chance of reaching its goal.
> 
> This behaviour was observed on a virtual machine with a tiny
> Normal-zone that filled up with unreclaimable slab objects.
> 
> This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> leaves them to direct reclaim.

Hi!

We are experiencing a similar issue, though with a 757 MB Normal zone,
where kswapd tries to rebalance Normal after an order-3 allocation while
page cache allocations (order-0) keep splitting it back up again.  It can
run the whole day like this (SSD storage) without sleeping.

Mel Gorman posted a similar patch to yours, but the logic is instead to
consider order>0 balancing sufficient when there are other balanced zones
totalling at least 25% of pages on this node.  This would probably fix
your case as well.

See "Free memory never fully used, swapping" thread, and "[PATCH 0/5]
Prevent kswapd dumping excessive amounts of memory in response to
high-order allocations V2", and finally "Stop high-order balancing when
any suitable zone is balanced".

It probably makes sense to merge one of these patches, or sort out the
good parts of each.  I'm not sure if your patch alone would solve our
case with a significantly bigger Normal zone but where most pages are
still reclaimable...

On the other hand, I still think it's weird that kswapd can fight with
allocations.  It seems like something should hold the free pages while
balancing is happening to avoid them being split right back up again by
lower-order allocations.

Simon-

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/mmzone.h |    2 ++
>  mm/page_alloc.c        |    4 ++--
>  mm/vmscan.c            |   36 ++++++++++++++++++++++++++++--------
>  3 files changed, 32 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 4890662..0cc1d63 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -655,6 +655,8 @@ typedef struct pglist_data {
>  extern struct mutex zonelists_mutex;
>  void build_all_zonelists(void *data);
>  void wakeup_kswapd(struct zone *zone, int order);
> +bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +			 int classzone_idx, int alloc_flags, long free_pages);
>  bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  		int classzone_idx, int alloc_flags);
>  bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1845a97..c7d2b28 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1458,8 +1458,8 @@ static inline int should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>   * Return true if free pages are above 'mark'. This takes into account the order
>   * of the allocation.
>   */
> -static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> -		      int classzone_idx, int alloc_flags, long free_pages)
> +bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +			 int classzone_idx, int alloc_flags, long free_pages)
>  {
>  	/* free_pages my go negative - that's OK */
>  	long min = mark;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 42a4859..5623f36 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2191,6 +2191,25 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  }
>  #endif
>  
> +static bool zone_needs_scan(struct zone *zone, int order,
> +			    unsigned long goal, int classzone_idx)
> +{
> +	unsigned long free, prospect;
> +
> +	free = zone_page_state(zone, NR_FREE_PAGES);
> +	if (zone->percpu_drift_mark && free < zone->percpu_drift_mark)
> +		free = zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +
> +	if (__zone_watermark_ok(zone, order, goal, classzone_idx, 0, free))
> +		return false;
> +	/*
> +	 * Ensure that the watermark is at all restorable through
> +	 * reclaim.  Otherwise, leave the zone to direct reclaim.
> +	 */
> +	prospect = free + zone_reclaimable_pages(zone);
> +	return prospect >= goal;
> +}
> +
>  /* is kswapd sleeping prematurely? */
>  static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  {
> @@ -2210,8 +2229,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  		if (zone->all_unreclaimable)
>  			continue;
>  
> -		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
> -								0, 0))
> +		if (zone_needs_scan(zone, order, high_wmark_pages(zone), 0))
>  			return 1;
>  	}
>  
> @@ -2282,6 +2300,7 @@ loop_again:
>  		 */
>  		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
>  			struct zone *zone = pgdat->node_zones + i;
> +			unsigned long goal;
>  
>  			if (!populated_zone(zone))
>  				continue;
> @@ -2297,8 +2316,8 @@ loop_again:
>  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
>  							&sc, priority, 0);
>  
> -			if (!zone_watermark_ok_safe(zone, order,
> -					high_wmark_pages(zone), 0, 0)) {
> +			goal = high_wmark_pages(zone);
> +			if (zone_needs_scan(zone, order, goal, 0)) {
>  				end_zone = i;
>  				break;
>  			}
> @@ -2323,6 +2342,7 @@ loop_again:
>  		 */
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
> +			unsigned long goal;
>  			int nr_slab;
>  
>  			if (!populated_zone(zone))
> @@ -2339,12 +2359,13 @@ loop_again:
>  			 */
>  			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
>  
> +			goal = high_wmark_pages(zone);
>  			/*
>  			 * We put equal pressure on every zone, unless one
>  			 * zone has way too many pages free already.
>  			 */
>  			if (!zone_watermark_ok_safe(zone, order,
> -					8*high_wmark_pages(zone), end_zone, 0))
> +						    8 * goal, end_zone, 0))
>  				shrink_zone(priority, zone, &sc);
>  			reclaim_state->reclaimed_slab = 0;
>  			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
> @@ -2373,8 +2394,7 @@ loop_again:
>  				compact_zone_order(zone, sc.order, sc.gfp_mask,
>  							false);
>  
> -			if (!zone_watermark_ok_safe(zone, order,
> -					high_wmark_pages(zone), end_zone, 0)) {
> +			if (zone_needs_scan(zone, order, goal, end_zone)) {
>  				all_zones_ok = 0;
>  				/*
>  				 * We are still under min water mark.  This
> @@ -2587,7 +2607,7 @@ void wakeup_kswapd(struct zone *zone, int order)
>  		pgdat->kswapd_max_order = order;
>  	if (!waitqueue_active(&pgdat->kswapd_wait))
>  		return;
> -	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
> +	if (!zone_needs_scan(zone, order, low_wmark_pages(zone), 0))
>  		return;
>  
>  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
> -- 
> 1.7.3.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
