Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 983506B02AA
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 07:18:15 -0400 (EDT)
Date: Fri, 16 Jul 2010 12:17:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/7] memcg, vmscan: add memcg reclaim tracepoint
Message-ID: <20100716111754.GI13117@csn.ul.ie>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com> <20100716191608.7378.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100716191608.7378.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 16, 2010 at 07:16:46PM +0900, KOSAKI Motohiro wrote:
> 
> Memcg also need to trace reclaim progress as direct reclaim. This patch
> add it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  include/trace/events/vmscan.h |   28 ++++++++++++++++++++++++++++
>  mm/vmscan.c                   |   19 ++++++++++++++++++-
>  2 files changed, 46 insertions(+), 1 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index bd749c1..cc19cb0 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -99,6 +99,19 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_b
>  	TP_ARGS(order, may_writepage, gfp_flags)
>  );
>  
> +DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
> +
> +	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
> +
> +	TP_ARGS(order, may_writepage, gfp_flags)
> +);
> +
> +DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
> +
> +	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
> +
> +	TP_ARGS(order, may_writepage, gfp_flags)
> +);
>  
>  DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_end_template,
>  
> @@ -124,6 +137,21 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_direct_reclaim_end
>  	TP_ARGS(nr_reclaimed)
>  );
>  
> +DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_reclaim_end,
> +
> +	TP_PROTO(unsigned long nr_reclaimed),
> +
> +	TP_ARGS(nr_reclaimed)
> +);
> +
> +DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_reclaim_end,
> +
> +	TP_PROTO(unsigned long nr_reclaimed),
> +
> +	TP_ARGS(nr_reclaimed)
> +);
> +
> +
>  TRACE_EVENT(mm_vmscan_lru_isolate,
>  
>  	TP_PROTO(int order,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 89b4287..21eb94f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1943,6 +1943,10 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>  
> +	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
> +						      sc.may_writepage,
> +						      sc.gfp_mask);
> +
>  	/*
>  	 * NOTE: Although we can get the priority field, using it
>  	 * here is not a good idea, since it limits the pages we can scan.
> @@ -1951,6 +1955,9 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  	 * the priority and make it zero.
>  	 */
>  	shrink_zone(0, zone, &sc);
> +
> +	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
> +
>  	return sc.nr_reclaimed;
>  }
>  
> @@ -1960,6 +1967,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  					   unsigned int swappiness)
>  {
>  	struct zonelist *zonelist;
> +	unsigned long nr_reclaimed;
>  	struct scan_control sc = {
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
> @@ -1974,7 +1982,16 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>  	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
> -	return do_try_to_free_pages(zonelist, &sc);
> +
> +	trace_mm_vmscan_memcg_reclaim_begin(0,
> +					    sc.may_writepage,
> +					    sc.gfp_mask);
> +
> +	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> +
> +	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
> +
> +	return nr_reclaimed;
>  }
>  #endif
>  
> -- 
> 1.6.5.2
> 
> 
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
