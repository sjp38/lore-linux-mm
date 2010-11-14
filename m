Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 984156B0087
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:59:35 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE5xWb6009848
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:59:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A728445DE57
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:59:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 811F845DE51
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:59:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F942E18001
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:59:32 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E3E97E08003
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:59:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,vmscan: Reclaim order-0 and compact instead of lumpy reclaim when under light pressure
In-Reply-To: <1289502424-12661-4-git-send-email-mel@csn.ul.ie>
References: <1289502424-12661-1-git-send-email-mel@csn.ul.ie> <1289502424-12661-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20101114145617.E025.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 14:59:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Lumpy reclaim is disruptive. It reclaims both a large number of pages
> and ignores the age of the majority of pages it reclaims. This can incur
> significant stalls and potentially increase the number of major faults.
> 
> Compaction has reached the point where it is considered reasonably stable
> (meaning it has passed a lot of testing) and is a potential candidate for
> displacing lumpy reclaim. This patch reduces the use of lumpy reclaim when
> the priority is high enough to indicate low pressure. The basic operation
> is very simple. Instead of selecting a contiguous range of pages to reclaim,
> lumpy compaction reclaims a number of order-0 pages and then calls compaction
> for the zone. If the watermarks are not met, another reclaim+compaction
> cycle occurs.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/compaction.h |    9 ++++++++-
>  mm/compaction.c            |    2 +-
>  mm/vmscan.c                |   38 ++++++++++++++++++++++++++------------
>  3 files changed, 35 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 5ac5155..2ae6613 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -22,7 +22,8 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask);
> -
> +extern unsigned long compact_zone_order(struct zone *zone,
> +			int order, gfp_t gfp_mask);
>  /* Do not skip compaction more than 64 times */
>  #define COMPACT_MAX_DEFER_SHIFT 6
>  
> @@ -59,6 +60,12 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  	return COMPACT_CONTINUE;
>  }
>  
> +static inline unsigned long compact_zone_order(struct zone *zone,
> +			int order, gfp_t gfp_mask)
> +{
> +	return 0;
> +}
> +
>  static inline void defer_compaction(struct zone *zone)
>  {
>  }
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4d709ee..f987f47 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -418,7 +418,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  	return ret;
>  }
>  
> -static unsigned long compact_zone_order(struct zone *zone,
> +unsigned long compact_zone_order(struct zone *zone,
>  						int order, gfp_t gfp_mask)
>  {
>  	struct compact_control cc = {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ffa438e..da35cdb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -32,6 +32,7 @@
>  #include <linux/topology.h>
>  #include <linux/cpu.h>
>  #include <linux/cpuset.h>
> +#include <linux/compaction.h>
>  #include <linux/notifier.h>
>  #include <linux/rwsem.h>
>  #include <linux/delay.h>
> @@ -56,6 +57,7 @@ typedef unsigned __bitwise__ lumpy_mode;
>  #define LUMPY_MODE_ASYNC		((__force lumpy_mode)0x02u)
>  #define LUMPY_MODE_SYNC			((__force lumpy_mode)0x04u)
>  #define LUMPY_MODE_CONTIGRECLAIM	((__force lumpy_mode)0x08u)
> +#define LUMPY_MODE_COMPACTION		((__force lumpy_mode)0x10u)
>  
>  struct scan_control {
>  	/* Incremented by the number of inactive pages that were scanned */
> @@ -274,25 +276,27 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
>  static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
>  				   bool sync)
>  {
> -	lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
> +	lumpy_mode syncmode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
>  
>  	/*
> -	 * Some reclaim have alredy been failed. No worth to try synchronous
> -	 * lumpy reclaim.
> +	 * Initially assume we are entering either lumpy reclaim or lumpy
> +	 * compaction. Depending on the order, we will either set the sync
> +	 * mode or just reclaim order-0 pages later.
>  	 */
> -	if (sync && sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE)
> -		return;
> +	if (COMPACTION_BUILD)
> +		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
> +	else
> +		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
>  
>  	/*
>  	 * If we need a large contiguous chunk of memory, or have
>  	 * trouble getting a small set of contiguous pages, we
>  	 * will reclaim both active and inactive pages.
>  	 */
> -	sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
>  	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> -		sc->lumpy_reclaim_mode |= mode;
> +		sc->lumpy_reclaim_mode |= syncmode;
>  	else if (sc->order && priority < DEF_PRIORITY - 2)
> -		sc->lumpy_reclaim_mode |= mode;
> +		sc->lumpy_reclaim_mode |= syncmode;

Does "LUMPY_MODE_COMPACTION | LUMPY_MODE_SYNC" have any benefit?
I haven't understand this semantics. please elaborate?


>  	else
>  		sc->lumpy_reclaim_mode = LUMPY_MODE_SINGLE | LUMPY_MODE_ASYNC;
>  }
> @@ -1366,11 +1370,18 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  	lru_add_drain();
>  	spin_lock_irq(&zone->lru_lock);
>  
> +	/*
> +	 * If we are lumpy compacting, we bump nr_to_scan to at least
> +	 * the size of the page we are trying to allocate
> +	 */
> +	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
> +		nr_to_scan = max(nr_to_scan, (1UL << sc->order));
> +
>  	if (scanning_global_lru(sc)) {
>  		nr_taken = isolate_pages_global(nr_to_scan,
>  			&page_list, &nr_scanned, sc->order,
> -			sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE ?
> -					ISOLATE_INACTIVE : ISOLATE_BOTH,
> +			sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM ?
> +					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, 0, file);
>  		zone->pages_scanned += nr_scanned;
>  		if (current_is_kswapd())
> @@ -1382,8 +1393,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  	} else {
>  		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
>  			&page_list, &nr_scanned, sc->order,
> -			sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE ?
> -					ISOLATE_INACTIVE : ISOLATE_BOTH,
> +			sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM ?
> +					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, sc->mem_cgroup,
>  			0, file);
>  		/*
> @@ -1416,6 +1427,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  
>  	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
>  
> +	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
> +		compact_zone_order(zone, sc->order, sc->gfp_mask);
> +

If free pages are very little, compaction may not work. don't we need to
check NR_FREE_PAGES?


>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
>  		zone_idx(zone),
>  		nr_scanned, nr_reclaimed,
> -- 
> 1.7.1
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
