Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A23456B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:12:23 -0500 (EST)
Date: Thu, 12 Jan 2012 16:12:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -mm 2/2] mm: kswapd carefully invoke compaction
Message-ID: <20120112161219.GI3910@csn.ul.ie>
References: <20120109213156.0ff47ee5@annuminas.surriel.com>
 <20120109213357.148e7927@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120109213357.148e7927@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com

On Mon, Jan 09, 2012 at 09:33:57PM -0500, Rik van Riel wrote:
> With CONFIG_COMPACTION enabled, kswapd does not try to free
> contiguous free pages, even when it is woken for a higher order
> request.
> 
> This could be bad for eg. jumbo frame network allocations, which
> are done from interrupt context and cannot compact memory themselves.
> Higher than before allocation failure rates in the network receive
> path have been observed in kernels with compaction enabled.
> 
> Teach kswapd to defragment the memory zones in a node, but only
> if required and compaction is not deferred in a zone.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

heh, this is not the first time we had kswapd doing compaction. It was a
bit of a disaster the last time around but a lot has changed since.

Care is needed here though. There are patches in-bound that implement
sync-light. Part of that series includes a fix that makes compact_node
use sync compaction. This is fine for a process writing to /proc, not to
fine for kswapd. Watch for that.

> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index bb2bbdb..df31dab 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -23,6 +23,7 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask,
>  			bool sync);
> +extern int compact_pgdat(pg_data_t *pgdat, int order, bool force);
>  extern unsigned long compaction_suitable(struct zone *zone, int order);
>  
>  /* Do not skip compaction more than 64 times */
> @@ -62,6 +63,11 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  	return COMPACT_CONTINUE;
>  }
>  
> +static inline int compact_pgdat(pg_data_t *pgdat, int order, bool force)
> +{
> +	return COMPACT_CONTINUE;
> +}
> +
>  static inline unsigned long compaction_suitable(struct zone *zone, int order)
>  {
>  	return COMPACT_SKIPPED;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1253d7a..1962a0e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -651,16 +651,11 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  
>  
>  /* Compact all zones within a node */
> -static int compact_node(int nid)
> +int compact_pgdat(pg_data_t *pgdat, int order, bool force)

force is a bad parameter to have as a VM-internal API to kswapd. By
and large I'm trying to move away from these sort of bools towards
compact_mode of sync, sync-light or async.

I would much prefer if what was exposed to kswapd was a compact_pgdat()
that created a suitable compact_control (async compaction I would
expect) and pass that to a static __compact_pgdat() that is shared by
both kswapd and compact_nodes.

That would stop spreading too much knowledge of compaction to kswapd.

>  {
>  	int zoneid;
> -	pg_data_t *pgdat;
>  	struct zone *zone;
>  
> -	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
> -		return -EINVAL;
> -	pgdat = NODE_DATA(nid);
> -
>  	/* Flush pending updates to the LRU lists */
>  	lru_add_drain_all();
>  
> @@ -668,7 +663,7 @@ static int compact_node(int nid)
>  		struct compact_control cc = {
>  			.nr_freepages = 0,
>  			.nr_migratepages = 0,
> -			.order = -1,
> +			.order = order,
>  		};
>  
>  		zone = &pgdat->node_zones[zoneid];

Just to be clear, there is a fix that applies to here that initialises
sync and that would have caused problems for this patch.

> @@ -679,7 +674,8 @@ static int compact_node(int nid)
>  		INIT_LIST_HEAD(&cc.freepages);
>  		INIT_LIST_HEAD(&cc.migratepages);
>  
> -		compact_zone(zone, &cc);
> +		if (force || !compaction_deferred(zone))
> +			compact_zone(zone, &cc);
>  
>  		VM_BUG_ON(!list_empty(&cc.freepages));
>  		VM_BUG_ON(!list_empty(&cc.migratepages));
> @@ -688,6 +684,16 @@ static int compact_node(int nid)
>  	return 0;
>  }
>  
> +static int compact_node(int nid)
> +{
> +	pg_data_t *pgdat;
> +	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
> +		return -EINVAL;
> +	pgdat = NODE_DATA(nid);
> +
> +	return compact_pgdat(pgdat, -1, true);
> +}
> +
>  /* Compact all nodes in the system */
>  static int compact_nodes(void)
>  {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0fb469a..65bf21db 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2522,6 +2522,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  	int priority;
>  	int i;
>  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> +	int zones_need_compaction = 1;
>  	unsigned long total_scanned;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long nr_soft_reclaimed;
> @@ -2788,9 +2789,17 @@ out:
>  				goto loop_again;
>  			}
>  
> +			/* Check if the memory needs to be defragmented. */
> +			if (zone_watermark_ok(zone, order,
> +				    low_wmark_pages(zone), *classzone_idx, 0))
> +				zones_need_compaction = 0;
> +
>  			/* If balanced, clear the congested flag */
>  			zone_clear_flag(zone, ZONE_CONGESTED);
>  		}
> +
> +		if (zones_need_compaction)
> +			compact_pgdat(pgdat, order, false);

hmm, not fully convinced this is the right way of deciding if compaction
should be used. If patch 1 used compaction_suitable() to decide when to
stop reclaiming instead of a watermark check, we could then call
compact_pgdat() in the exit path to balance_pgdat(). That would minimise
the risk that kswapd gets stuck in compaction when it should be
reclaiming pages. What do you think?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
