Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 685CC6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 05:19:57 -0500 (EST)
Date: Fri, 10 Dec 2010 10:19:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/6] mm: kswapd: Keep kswapd awake for high-order
	allocations until a percentage of the node is balanced
Message-ID: <20101210101935.GI20133@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie> <1291893500-12342-3-git-send-email-mel@csn.ul.ie> <20101209154258.GC1740@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101209154258.GC1740@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 12:42:58AM +0900, Minchan Kim wrote:
> On Thu, Dec 09, 2010 at 11:18:16AM +0000, Mel Gorman wrote:
> > When reclaiming for high-orders, kswapd is responsible for balancing a
> > node but it should not reclaim excessively. It avoids excessive reclaim by
> > considering if any zone in a node is balanced then the node is balanced. In
> > the cases where there are imbalanced zone sizes (e.g. ZONE_DMA with both
> > ZONE_DMA32 and ZONE_NORMAL), kswapd can go to sleep prematurely as just
> > one small zone was balanced.
> > 
> > This alters the sleep logic of kswapd slightly. It counts the number of pages
> > that make up the balanced zones. If the total number of balanced pages is
> > more than a quarter of the zone, kswapd will go back to sleep. This should
> > keep a node balanced without reclaiming an excessive number of pages.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Just below trivials.
> 
> > ---
> >  mm/vmscan.c |   43 ++++++++++++++++++++++++++++++++++---------
> >  1 files changed, 34 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 25cb373..b4472a1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2117,10 +2117,26 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> >  }
> >  #endif
> >  
> > +/*
> > + * pgdat_balanced is used when checking if a node is balanced for high-order
> > + * allocations. Only zones that meet watermarks make up "balanced".
> > + * The total of balanced pages must be at least 25% of the node for the
> 
> Could you write down why you select 25% in description?
> It could help someone who try to change that watermark in future.
> 

Sure, how about;

+/*
+ * pgdat_balanced is used when checking if a node is balanced for high-order
+ * allocations. Only zones that meet watermarks make up "balanced".
+ * The total of balanced pages must be at least 25% of the node for the
+ * node to be considered balanced. Forcing all zones to be balanced for high
+ * orders can cause excessive reclaim when there are imbalanced zones.
+ * The choice of 25% is due to
+ *   o a 16M DMA zone that is balanced will not balance a zone on any
+ *     reasonable sized machine
+ *   o On all other machines, the top zone must be at least a reasonable
+ *     precentage of the middle zones. For example, on 32-bit x86, highmem
+ *     would need to be at least 256M for it to be balance a whole node.
+ *     Similarly, on x86-64 the Normal zone would need to be at least 1G
+ *     to balance a node on its own. These seemed like reasonable ratios.
+ */
+static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced)
+{
+       return balanced > pgdat->node_present_pages / 4;
+}

?

> > + * node to be considered balanced. Forcing all zones to be balanced for high
> > + * orders can cause excessive reclaim when there are imbalanced zones.
> > + * Similarly, we do not want kswapd to go to sleep because ZONE_DMA happens
> > + * to be balanced when ZONE_DMA32 is huge in comparison and unbalanced
> > + */
> > +static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced)
> 
> I think balanced_pages is more clear.
> But it's a preference.
> 

Updated.

> > +{
> > +	return balanced > pgdat->node_present_pages / 4;
> > +}
> > +
> >  /* is kswapd sleeping prematurely? */
> >  static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >  {
> >  	int i;
> > +	unsigned long balanced = 0;
> > +	bool all_zones_ok = true;
> >  
> >  	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
> >  	if (remaining)
> > @@ -2138,10 +2154,19 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >  
> >  		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
> >  								0, 0))
> > -			return 1;
> > +			all_zones_ok = false;
> > +		else
> > +			balanced += zone->present_pages;
> >  	}
> >  
> > -	return 0;
> > +	/*
> > +	 * For high-order requests, any zone meeting the watermark allows
> > +	 * kswapd to sleep. For order-0, all zones must be balanced
> 
> The comment isn't exact.
> could allow?
> 

Correct;

+       /*
+        * For high-order requests, the balanced zones must contain at least
+        * 25% of the nodes pages for kswapd to sleep. For order-0, all zones
+        * must be balanced
+        */
+       if (order)
+               return pgdat_balanced(pgdat, balanced);
+       else
+               return !all_zones_ok;

Thanks

> > +	 */
> > +	if (order)
> > +		return pgdat_balanced(pgdat, balanced);
> > +	else
> > +		return !all_zones_ok;
> >  }
> >  
> >  /*
> > @@ -2169,7 +2194,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  							int classzone_idx)
> >  {
> >  	int all_zones_ok;
> > -	int any_zone_ok;
> > +	unsigned long balanced;
> >  	int priority;
> >  	int i;
> >  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> > @@ -2203,7 +2228,7 @@ loop_again:
> >  			disable_swap_token();
> >  
> >  		all_zones_ok = 1;
> > -		any_zone_ok = 0;
> > +		balanced = 0;
> >  
> >  		/*
> >  		 * Scan in the highmem->dma direction for the highest
> > @@ -2314,11 +2339,11 @@ loop_again:
> >  				 */
> >  				zone_clear_flag(zone, ZONE_CONGESTED);
> >  				if (i <= classzone_idx)
> > -					any_zone_ok = 1;
> > +					balanced += zone->present_pages;
> >  			}
> >  
> >  		}
> > -		if (all_zones_ok || (order && any_zone_ok))
> > +		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced)))
> >  			break;		/* kswapd: all done */
> >  		/*
> >  		 * OK, kswapd is getting into trouble.  Take a nap, then take
> > @@ -2344,10 +2369,10 @@ out:
> >  
> >  	/*
> >  	 * order-0: All zones must meet high watermark for a balanced node
> > -	 * high-order: Any zone below pgdats classzone_idx must meet the high
> > -	 *             watermark for a balanced node
> > +	 * high-order: Balanced zones must make up at least 25% of the node
> > +	 *             for the node to be balanced
> >  	 */
> > -	if (!(all_zones_ok || (order && any_zone_ok))) {
> > +	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced)))) {
> >  		cond_resched();
> >  
> >  		try_to_freeze();

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
