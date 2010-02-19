Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 912DE6B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 19:55:05 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J0t2LX013609
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Feb 2010 09:55:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EC3D45DE54
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:55:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBCCD45DE51
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:55:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C746A1DB803F
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:55:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C3A81DB8042
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:55:01 +0900 (JST)
Date: Fri, 19 Feb 2010 09:51:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 11/12] Direct compact when a high-order allocation fails
Message-Id: <20100219095132.96baea7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1266516162-14154-12-git-send-email-mel@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
	<1266516162-14154-12-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Feb 2010 18:02:41 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> Ordinarily when a high-order allocation fails, direct reclaim is entered to
> free pages to satisfy the allocation.  With this patch, it is determined if
> an allocation failed due to external fragmentation instead of low memory
> and if so, the calling process will compact until a suitable page is
> freed. Compaction by moving pages in memory is considerably cheaper than
> paging out to disk and works where there are locked pages or no swap. If
> compaction fails to free a page of a suitable size, then reclaim will
> still occur.
> 
> Direct compaction returns as soon as possible. As each block is compacted,
> it is checked if a suitable page has been freed and if so, it returns.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/compaction.h |   16 +++++-
>  include/linux/vmstat.h     |    1 +
>  mm/compaction.c            |  118 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c            |   26 ++++++++++
>  mm/vmstat.c                |   15 +++++-
>  5 files changed, 172 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 6a2eefd..1cf95e2 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,13 +1,25 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>  
> -/* Return values for compact_zone() */
> +/* Return values for compact_zone() and try_to_compact_pages() */
>  #define COMPACT_INCOMPLETE	0
> -#define COMPACT_COMPLETE	1
> +#define COMPACT_PARTIAL		1
> +#define COMPACT_COMPLETE	2
>  
>  #ifdef CONFIG_COMPACTION
>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
>  			void __user *buffer, size_t *length, loff_t *ppos);
> +
> +extern int fragmentation_index(struct zone *zone, unsigned int order);
> +extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
> +			int order, gfp_t gfp_mask, nodemask_t *mask);
> +#else
> +static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
> +			int order, gfp_t gfp_mask, nodemask_t *nodemask)
> +{
> +	return COMPACT_INCOMPLETE;
> +}
> +
>  #endif /* CONFIG_COMPACTION */
>  
>  #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index d7f7236..0ea7a38 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -44,6 +44,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		KSWAPD_SKIP_CONGESTION_WAIT,
>  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
>  		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
> +		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
>  #ifdef CONFIG_HUGETLB_PAGE
>  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
>  #endif
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 02579c2..c7c73bb 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -34,6 +34,8 @@ struct compact_control {
>  	unsigned long nr_anon;
>  	unsigned long nr_file;
>  
> +	unsigned int order;		/* order a direct compactor needs */
> +	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>  	struct zone *zone;
>  };
>  
> @@ -298,10 +300,31 @@ static void update_nr_listpages(struct compact_control *cc)
>  static inline int compact_finished(struct zone *zone,
>  						struct compact_control *cc)
>  {
> +	unsigned int order;
> +	unsigned long watermark = low_wmark_pages(zone) + (1 << cc->order);
> +
>  	/* Compaction run completes if the migrate and free scanner meet */
>  	if (cc->free_pfn <= cc->migrate_pfn)
>  		return COMPACT_COMPLETE;
>  
> +	/* Compaction run is not finished if the watermark is not met */
> +	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
> +		return COMPACT_INCOMPLETE;
> +
> +	if (cc->order == -1)
> +		return COMPACT_INCOMPLETE;
> +
> +	/* Direct compactor: Is a suitable page free? */
> +	for (order = cc->order; order < MAX_ORDER; order++) {
> +		/* Job done if page is free of the right migratetype */
> +		if (!list_empty(&zone->free_area[order].free_list[cc->migratetype]))
> +			return COMPACT_PARTIAL;
> +
> +		/* Job done if allocation would set block type */
> +		if (order >= pageblock_order && zone->free_area[order].nr_free)
> +			return COMPACT_PARTIAL;
> +	}
> +
>  	return COMPACT_INCOMPLETE;
>  }
>  
> @@ -347,6 +370,101 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  	return ret;
>  }
>  
> +static inline unsigned long compact_zone_order(struct zone *zone,
> +						int order, gfp_t gfp_mask)
> +{
> +	struct compact_control cc = {
> +		.nr_freepages = 0,
> +		.nr_migratepages = 0,
> +		.order = order,
> +		.migratetype = allocflags_to_migratetype(gfp_mask),
> +		.zone = zone,
> +	};
> +	INIT_LIST_HEAD(&cc.freepages);
> +	INIT_LIST_HEAD(&cc.migratepages);
> +
> +	return compact_zone(zone, &cc);
> +}
> +
> +/**
> + * try_to_compact_pages - Direct compact to satisfy a high-order allocation
> + * @zonelist: The zonelist used for the current allocation
> + * @order: The order of the current allocation
> + * @gfp_mask: The GFP mask of the current allocation
> + * @nodemask: The allowed nodes to allocate from
> + *
> + * This is the main entry point for direct page compaction.
> + */
> +unsigned long try_to_compact_pages(struct zonelist *zonelist,
> +			int order, gfp_t gfp_mask, nodemask_t *nodemask)
> +{
> +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> +	int may_enter_fs = gfp_mask & __GFP_FS;
> +	int may_perform_io = gfp_mask & __GFP_IO;
> +	unsigned long watermark;
> +	struct zoneref *z;
> +	struct zone *zone;
> +	int rc = COMPACT_INCOMPLETE;
> +
> +	/* Check whether it is worth even starting compaction */
> +	if (order == 0 || !may_enter_fs || !may_perform_io)
> +		return rc;
> +
> +	/*
> +	 * We will not stall if the necessary conditions are not met for
> +	 * migration but direct reclaim seems to account stalls similarly
> +	 */
> +	count_vm_event(COMPACTSTALL);
> +
> +	/* Compact each zone in the list */
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> +								nodemask) {
> +		int fragindex;
> +		int status;
> +
> +		/*
> +		 * Watermarks for order-0 must be met for compaction. Note
> +		 * the 2UL. This is because during migration, copies of
> +		 * pages need to be allocated and for a short time, the
> +		 * footprint is higher
> +		 */
> +		watermark = low_wmark_pages(zone) + (2UL << order);
> +		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> +			continue;
> +
> +		/*
> +		 * fragmentation index determines if allocation failures are
> +		 * due to low memory or external fragmentation
> +		 *
> +		 * index of -1 implies allocations might succeed depending
> +		 * 	on watermarks
> +		 * index < 500 implies alloc failure is due to lack of memory
> +		 *
> +		 * XXX: The choice of 500 is arbitrary. Reinvestigate
> +		 *      appropriately to determine a sensible default.
> +		 *      and what it means when watermarks are also taken
> +		 *      into account. Consider making it a sysctl
> +		 */
> +		fragindex = fragmentation_index(zone, order);
> +		if (fragindex >= 0 && fragindex <= 500)
> +			continue;
> +
> +		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
> +			rc = COMPACT_PARTIAL;
> +			break;
> +		}
> +
> +		status = compact_zone_order(zone, order, gfp_mask);
> +		rc = max(status, rc);
> +
> +		if (zone_watermark_ok(zone, order, watermark, 0, 0))
> +			break;
> +	}
> +
> +	return rc;
> +}
> +
> +
>  /* Compact all zones within a node */
>  static int compact_node(int nid)
>  {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d57154..1910b8b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -49,6 +49,7 @@
>  #include <linux/debugobjects.h>
>  #include <linux/kmemleak.h>
>  #include <linux/memory.h>
> +#include <linux/compaction.h>
>  #include <trace/events/kmem.h>
>  
>  #include <asm/tlbflush.h>
> @@ -1728,6 +1729,31 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  
>  	cond_resched();
>  

Isn't kswapd waken up before we reach here ? Is it intentional ?

Thanks,
-Kame




> +	/* Try memory compaction for high-order allocations before reclaim */
> +	if (order) {
> +		*did_some_progress = try_to_compact_pages(zonelist,
> +						order, gfp_mask, nodemask);
> +		if (*did_some_progress != COMPACT_INCOMPLETE) {
> +			page = get_page_from_freelist(gfp_mask, nodemask,
> +					order, zonelist, high_zoneidx,
> +					alloc_flags, preferred_zone,
> +					migratetype);
> +			if (page) {
> +				__count_vm_event(COMPACTSUCCESS);
> +				return page;
> +			}
> +
> +			/*
> +			 * It's bad if compaction run occurs and fails.
> +			 * The most likely reason is that pages exist,
> +			 * but not enough to satisfy watermarks.
> +			 */
> +			count_vm_event(COMPACTFAIL);
> +
> +			cond_resched();
> +		}
> +	}
> +
>  	/* We now go into synchronous reclaim */
>  	cpuset_memory_pressure_bump();
>  	p->flags |= PF_MEMALLOC;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 0a14d22..189a379 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -558,7 +558,7 @@ static int unusable_show(struct seq_file *m, void *arg)
>   * The value can be used to determine if page reclaim or compaction
>   * should be used
>   */
> -int fragmentation_index(unsigned int order, struct contig_page_info *info)
> +int __fragmentation_index(unsigned int order, struct contig_page_info *info)
>  {
>  	unsigned long requested = 1UL << order;
>  
> @@ -578,6 +578,14 @@ int fragmentation_index(unsigned int order, struct contig_page_info *info)
>  	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
>  }
>  
> +/* Same as __fragmentation index but allocs contig_page_info on stack */
> +int fragmentation_index(struct zone *zone, unsigned int order)
> +{
> +	struct contig_page_info info;
> +
> +	fill_contig_page_info(zone, order, &info);
> +	return __fragmentation_index(order, &info);
> +}
>  
>  static void extfrag_show_print(struct seq_file *m,
>  					pg_data_t *pgdat, struct zone *zone)
> @@ -593,7 +601,7 @@ static void extfrag_show_print(struct seq_file *m,
>  				zone->name);
>  	for (order = 0; order < MAX_ORDER; ++order) {
>  		fill_contig_page_info(zone, order, &info);
> -		index = fragmentation_index(order, &info);
> +		index = __fragmentation_index(order, &info);
>  		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
>  	}
>  
> @@ -893,6 +901,9 @@ static const char * const vmstat_text[] = {
>  	"compact_blocks_moved",
>  	"compact_pages_moved",
>  	"compact_pagemigrate_failed",
> +	"compact_stall",
> +	"compact_fail",
> +	"compact_success",
>  
>  #ifdef CONFIG_HUGETLB_PAGE
>  	"htlb_buddy_alloc_success",
> -- 
> 1.6.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
