Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BECFA6B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 06:32:29 -0500 (EST)
Date: Mon, 6 Dec 2010 11:32:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/5] mm: kswapd: Stop high-order balancing when any
	suitable zone is balanced
Message-ID: <20101206113209.GB21406@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie> <1291376734-30202-2-git-send-email-mel@csn.ul.ie> <20101206113541.dda0a794.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101206113541.dda0a794.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 06, 2010 at 11:35:41AM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri,  3 Dec 2010 11:45:30 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > When the allocator enters its slow path, kswapd is woken up to balance the
> > node. It continues working until all zones within the node are balanced. For
> > order-0 allocations, this makes perfect sense but for higher orders it can
> > have unintended side-effects. If the zone sizes are imbalanced, kswapd may
> > reclaim heavily within a smaller zone discarding an excessive number of
> > pages. The user-visible behaviour is that kswapd is awake and reclaiming
> > even though plenty of pages are free from a suitable zone.
> > 
> > This patch alters the "balance" logic for high-order reclaim allowing kswapd
> > to stop if any suitable zone becomes balanced to reduce the number of pages
> > it reclaims from other zones. kswapd still tries to ensure that order-0
> > watermarks for all zones are met before sleeping.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> a nitpick.
> 
> > ---
> >  include/linux/mmzone.h |    3 +-
> >  mm/page_alloc.c        |    8 ++++--
> >  mm/vmscan.c            |   55 +++++++++++++++++++++++++++++++++++++++++-------
> >  3 files changed, 54 insertions(+), 12 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 39c24eb..7177f51 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -645,6 +645,7 @@ typedef struct pglist_data {
> >  	wait_queue_head_t kswapd_wait;
> >  	struct task_struct *kswapd;
> >  	int kswapd_max_order;
> > +	enum zone_type classzone_idx;
> >  } pg_data_t;
> >  
> >  #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
> > @@ -660,7 +661,7 @@ typedef struct pglist_data {
> >  
> >  extern struct mutex zonelists_mutex;
> >  void build_all_zonelists(void *data);
> > -void wakeup_kswapd(struct zone *zone, int order);
> > +void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
> >  int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >  		int classzone_idx, int alloc_flags);
> >  enum memmap_context {
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index e409270..82e3499 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1915,13 +1915,14 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
> >  
> >  static inline
> >  void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> > -						enum zone_type high_zoneidx)
> > +						enum zone_type high_zoneidx,
> > +						enum zone_type classzone_idx)
> >  {
> >  	struct zoneref *z;
> >  	struct zone *zone;
> >  
> >  	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> > -		wakeup_kswapd(zone, order);
> > +		wakeup_kswapd(zone, order, classzone_idx);
> >  }
> >  
> >  static inline int
> > @@ -1998,7 +1999,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		goto nopage;
> >  
> >  restart:
> > -	wake_all_kswapd(order, zonelist, high_zoneidx);
> > +	wake_all_kswapd(order, zonelist, high_zoneidx,
> > +						zone_idx(preferred_zone));
> >  
> >  	/*
> >  	 * OK, we're below the kswapd watermark and have kicked background
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d31d7ce..d070d19 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2165,11 +2165,14 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >   * interoperates with the page allocator fallback scheme to ensure that aging
> >   * of pages is balanced across the zones.
> >   */
> > -static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
> > +static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> > +							int classzone_idx)
> >  {
> >  	int all_zones_ok;
> > +	int any_zone_ok;
> >  	int priority;
> >  	int i;
> > +	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> >  	unsigned long total_scanned;
> >  	struct reclaim_state *reclaim_state = current->reclaim_state;
> >  	struct scan_control sc = {
> > @@ -2192,7 +2195,6 @@ loop_again:
> >  	count_vm_event(PAGEOUTRUN);
> >  
> >  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > -		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> >  		unsigned long lru_pages = 0;
> >  		int has_under_min_watermark_zone = 0;
> >  
> > @@ -2201,6 +2203,7 @@ loop_again:
> >  			disable_swap_token();
> >  
> >  		all_zones_ok = 1;
> > +		any_zone_ok = 0;
> >  
> >  		/*
> >  		 * Scan in the highmem->dma direction for the highest
> > @@ -2310,10 +2313,12 @@ loop_again:
> >  				 * spectulatively avoid congestion waits
> >  				 */
> >  				zone_clear_flag(zone, ZONE_CONGESTED);
> > +				if (i <= classzone_idx)
> > +					any_zone_ok = 1;
> >  			}
> >  
> >  		}
> > -		if (all_zones_ok)
> > +		if (all_zones_ok || (order && any_zone_ok))
> >  			break;		/* kswapd: all done */
> >  		/*
> >  		 * OK, kswapd is getting into trouble.  Take a nap, then take
> > @@ -2336,7 +2341,7 @@ loop_again:
> >  			break;
> >  	}
> >  out:
> > -	if (!all_zones_ok) {
> > +	if (!(all_zones_ok || (order && any_zone_ok))) {
> 
> Could you add a comment ?
> 
> And this means...
> 
> 	all_zones_ok .... all_zone_balanced
> 	any_zones_ok .... fallback_allocation_ok
> ?
> 

+
+       /*
+        * order-0: All zones must meet high watermark for a balanced node
+        * high-order: Any zone below pgdats classzone_idx must meet the high
+        *      watermark for a balanced node
+        */

?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
