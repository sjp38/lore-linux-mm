Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 932D96B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:31:42 -0500 (EST)
Date: Thu, 18 Nov 2010 16:31:24 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 61 of 66] use compaction for GFP_ATOMIC order > 0
Message-ID: <20101118163124.GG8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <b540c09bfe5160120952.1288798116@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <b540c09bfe5160120952.1288798116@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:28:36PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This takes advantage of memory compaction to properly generate pages of order >
> 0 if regular page reclaim fails and priority level becomes more severe and we
> don't reach the proper watermarks.
> 

I don't think this is related to THP although I see what you're doing.
It should be handled on its own. I'd also wonder if some of the tg3
failures are due to MIGRATE_RESERVE not being set properly when
min_free_kbytes is automatically resized.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -11,6 +11,9 @@
>  /* The full zone was compacted */
>  #define COMPACT_COMPLETE	3
>  
> +#define COMPACT_MODE_DIRECT_RECLAIM	0
> +#define COMPACT_MODE_KSWAPD		1
> +
>  #ifdef CONFIG_COMPACTION
>  extern int sysctl_compact_memory;
>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> @@ -20,6 +23,9 @@ extern int sysctl_extfrag_handler(struct
>  			void __user *buffer, size_t *length, loff_t *ppos);
>  
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
> +extern unsigned long compact_zone_order(struct zone *zone,
> +					int order, gfp_t gfp_mask,
> +					int compact_mode);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask);
>  
> @@ -59,6 +65,13 @@ static inline unsigned long try_to_compa
>  	return COMPACT_CONTINUE;
>  }
>  
> +static inline unsigned long compact_zone_order(struct zone *zone,
> +					       int order, gfp_t gfp_mask,
> +					       int compact_mode)
> +{
> +	return COMPACT_CONTINUE;
> +}
> +
>  static inline void defer_compaction(struct zone *zone)
>  {
>  }
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -38,6 +38,8 @@ struct compact_control {
>  	unsigned int order;		/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>  	struct zone *zone;
> +
> +	int compact_mode;
>  };
>  
>  static unsigned long release_freepages(struct list_head *freelist)
> @@ -357,10 +359,10 @@ static void update_nr_listpages(struct c
>  }
>  
>  static int compact_finished(struct zone *zone,
> -						struct compact_control *cc)
> +			    struct compact_control *cc)
>  {
>  	unsigned int order;
> -	unsigned long watermark = low_wmark_pages(zone) + (1 << cc->order);
> +	unsigned long watermark;
>  
>  	if (fatal_signal_pending(current))
>  		return COMPACT_PARTIAL;
> @@ -370,12 +372,27 @@ static int compact_finished(struct zone 
>  		return COMPACT_COMPLETE;
>  
>  	/* Compaction run is not finished if the watermark is not met */
> +	if (cc->compact_mode != COMPACT_MODE_KSWAPD)
> +		watermark = low_wmark_pages(zone);
> +	else
> +		watermark = high_wmark_pages(zone);
> +	watermark += (1 << cc->order);
> +
>  	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
>  		return COMPACT_CONTINUE;
>  
>  	if (cc->order == -1)
>  		return COMPACT_CONTINUE;
>  
> +	/*
> +	 * Generating only one page of the right order is not enough
> +	 * for kswapd, we must continue until we're above the high
> +	 * watermark as a pool for high order GFP_ATOMIC allocations
> +	 * too.
> +	 */
> +	if (cc->compact_mode == COMPACT_MODE_KSWAPD)
> +		return COMPACT_CONTINUE;
> +
>  	/* Direct compactor: Is a suitable page free? */
>  	for (order = cc->order; order < MAX_ORDER; order++) {
>  		/* Job done if page is free of the right migratetype */
> @@ -433,8 +450,9 @@ static int compact_zone(struct zone *zon
>  	return ret;
>  }
>  
> -static unsigned long compact_zone_order(struct zone *zone,
> -						int order, gfp_t gfp_mask)
> +unsigned long compact_zone_order(struct zone *zone,
> +				 int order, gfp_t gfp_mask,
> +				 int compact_mode)
>  {
>  	struct compact_control cc = {
>  		.nr_freepages = 0,
> @@ -442,6 +460,7 @@ static unsigned long compact_zone_order(
>  		.order = order,
>  		.migratetype = allocflags_to_migratetype(gfp_mask),
>  		.zone = zone,
> +		.compact_mode = compact_mode,
>  	};
>  	INIT_LIST_HEAD(&cc.freepages);
>  	INIT_LIST_HEAD(&cc.migratepages);
> @@ -476,7 +495,7 @@ unsigned long try_to_compact_pages(struc
>  	 * made because an assumption is made that the page allocator can satisfy
>  	 * the "cheaper" orders without taking special steps
>  	 */
> -	if (order <= PAGE_ALLOC_COSTLY_ORDER || !may_enter_fs || !may_perform_io)
> +	if (!order || !may_enter_fs || !may_perform_io)
>  		return rc;
>  
>  	count_vm_event(COMPACTSTALL);
> @@ -517,7 +536,8 @@ unsigned long try_to_compact_pages(struc
>  			break;
>  		}
>  
> -		status = compact_zone_order(zone, order, gfp_mask);
> +		status = compact_zone_order(zone, order, gfp_mask,
> +					    COMPACT_MODE_DIRECT_RECLAIM);
>  		rc = max(status, rc);
>  
>  		if (zone_watermark_ok(zone, order, watermark, 0, 0))
> @@ -547,6 +567,7 @@ static int compact_node(int nid)
>  			.nr_freepages = 0,
>  			.nr_migratepages = 0,
>  			.order = -1,
> +			.compact_mode = COMPACT_MODE_DIRECT_RECLAIM,
>  		};
>  
>  		zone = &pgdat->node_zones[zoneid];
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -40,6 +40,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/delayacct.h>
>  #include <linux/sysctl.h>
> +#include <linux/compaction.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -2254,6 +2255,7 @@ loop_again:
>  		 * cause too much scanning of the lower zones.
>  		 */
>  		for (i = 0; i <= end_zone; i++) {
> +			int compaction;
>  			struct zone *zone = pgdat->node_zones + i;
>  			int nr_slab;
>  
> @@ -2283,9 +2285,26 @@ loop_again:
>  						lru_pages);
>  			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
>  			total_scanned += sc.nr_scanned;
> +
> +			compaction = 0;
> +			if (order &&
> +			    zone_watermark_ok(zone, 0,
> +					       high_wmark_pages(zone),
> +					      end_zone, 0) &&
> +			    !zone_watermark_ok(zone, order,
> +					       high_wmark_pages(zone),
> +					       end_zone, 0)) {
> +				compact_zone_order(zone,
> +						   order,
> +						   sc.gfp_mask,
> +						   COMPACT_MODE_KSWAPD);
> +				compaction = 1;
> +			}
> +
>  			if (zone->all_unreclaimable)
>  				continue;
> -			if (nr_slab == 0 && !zone_reclaimable(zone))
> +			if (!compaction && nr_slab == 0 &&
> +			    !zone_reclaimable(zone))
>  				zone->all_unreclaimable = 1;
>  			/*
>  			 * If we've done a decent amount of scanning and
> 

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
