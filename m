Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD156B01CD
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 07:41:21 -0400 (EDT)
Date: Wed, 24 Mar 2010 11:40:57 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
Message-ID: <20100324114056.GE21147@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-11-git-send-email-mel@csn.ul.ie> <20100324101927.0d54f4ad.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100324101927.0d54f4ad.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 10:19:27AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 23 Mar 2010 12:25:45 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Ordinarily when a high-order allocation fails, direct reclaim is entered to
> > free pages to satisfy the allocation.  With this patch, it is determined if
> > an allocation failed due to external fragmentation instead of low memory
> > and if so, the calling process will compact until a suitable page is
> > freed. Compaction by moving pages in memory is considerably cheaper than
> > paging out to disk and works where there are locked pages or no swap. If
> > compaction fails to free a page of a suitable size, then reclaim will
> > still occur.
> > 
> > Direct compaction returns as soon as possible. As each block is compacted,
> > it is checked if a suitable page has been freed and if so, it returns.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> >  include/linux/compaction.h |   16 +++++-
> >  include/linux/vmstat.h     |    1 +
> >  mm/compaction.c            |  118 ++++++++++++++++++++++++++++++++++++++++++++
> >  mm/page_alloc.c            |   26 ++++++++++
> >  mm/vmstat.c                |   15 +++++-
> >  5 files changed, 172 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index c94890b..b851428 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -1,14 +1,26 @@
> >  #ifndef _LINUX_COMPACTION_H
> >  #define _LINUX_COMPACTION_H
> >  
> > -/* Return values for compact_zone() */
> > +/* Return values for compact_zone() and try_to_compact_pages() */
> >  #define COMPACT_INCOMPLETE	0
> > -#define COMPACT_COMPLETE	1
> > +#define COMPACT_PARTIAL		1
> > +#define COMPACT_COMPLETE	2
> >  
> >  #ifdef CONFIG_COMPACTION
> >  extern int sysctl_compact_memory;
> >  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> >  			void __user *buffer, size_t *length, loff_t *ppos);
> > +
> > +extern int fragmentation_index(struct zone *zone, unsigned int order);
> > +extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > +			int order, gfp_t gfp_mask, nodemask_t *mask);
> > +#else
> > +static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > +			int order, gfp_t gfp_mask, nodemask_t *nodemask)
> > +{
> > +	return COMPACT_INCOMPLETE;
> > +}
> > +
> >  #endif /* CONFIG_COMPACTION */
> >  
> >  #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> > index 56e4b44..b4b4d34 100644
> > --- a/include/linux/vmstat.h
> > +++ b/include/linux/vmstat.h
> > @@ -44,6 +44,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		KSWAPD_SKIP_CONGESTION_WAIT,
> >  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> >  		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
> > +		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
> >  #ifdef CONFIG_HUGETLB_PAGE
> >  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
> >  #endif
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 8df6e3d..6688700 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -34,6 +34,8 @@ struct compact_control {
> >  	unsigned long nr_anon;
> >  	unsigned long nr_file;
> >  
> > +	unsigned int order;		/* order a direct compactor needs */
> > +	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
> >  	struct zone *zone;
> >  };
> >  
> > @@ -301,10 +303,31 @@ static void update_nr_listpages(struct compact_control *cc)
> >  static inline int compact_finished(struct zone *zone,
> >  						struct compact_control *cc)
> >  {
> > +	unsigned int order;
> > +	unsigned long watermark = low_wmark_pages(zone) + (1 << cc->order);
> > +
> >  	/* Compaction run completes if the migrate and free scanner meet */
> >  	if (cc->free_pfn <= cc->migrate_pfn)
> >  		return COMPACT_COMPLETE;
> >  
> > +	/* Compaction run is not finished if the watermark is not met */
> > +	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
> > +		return COMPACT_INCOMPLETE;
> > +
> > +	if (cc->order == -1)
> > +		return COMPACT_INCOMPLETE;
> > +
> > +	/* Direct compactor: Is a suitable page free? */
> > +	for (order = cc->order; order < MAX_ORDER; order++) {
> > +		/* Job done if page is free of the right migratetype */
> > +		if (!list_empty(&zone->free_area[order].free_list[cc->migratetype]))
> > +			return COMPACT_PARTIAL;
> > +
> > +		/* Job done if allocation would set block type */
> > +		if (order >= pageblock_order && zone->free_area[order].nr_free)
> > +			return COMPACT_PARTIAL;
> > +	}
> > +
> >  	return COMPACT_INCOMPLETE;
> >  }
> >  
> > @@ -348,6 +371,101 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >  	return ret;
> >  }
> >  
> > +static inline unsigned long compact_zone_order(struct zone *zone,
> > +						int order, gfp_t gfp_mask)
> > +{
> > +	struct compact_control cc = {
> > +		.nr_freepages = 0,
> > +		.nr_migratepages = 0,
> > +		.order = order,
> > +		.migratetype = allocflags_to_migratetype(gfp_mask),
> > +		.zone = zone,
> > +	};
> > +	INIT_LIST_HEAD(&cc.freepages);
> > +	INIT_LIST_HEAD(&cc.migratepages);
> > +
> > +	return compact_zone(zone, &cc);
> > +}
> > +
> > +/**
> > + * try_to_compact_pages - Direct compact to satisfy a high-order allocation
> > + * @zonelist: The zonelist used for the current allocation
> > + * @order: The order of the current allocation
> > + * @gfp_mask: The GFP mask of the current allocation
> > + * @nodemask: The allowed nodes to allocate from
> > + *
> > + * This is the main entry point for direct page compaction.
> > + */
> > +unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > +			int order, gfp_t gfp_mask, nodemask_t *nodemask)
> > +{
> > +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > +	int may_enter_fs = gfp_mask & __GFP_FS;
> > +	int may_perform_io = gfp_mask & __GFP_IO;
> > +	unsigned long watermark;
> > +	struct zoneref *z;
> > +	struct zone *zone;
> > +	int rc = COMPACT_INCOMPLETE;
> > +
> > +	/* Check whether it is worth even starting compaction */
> > +	if (order == 0 || !may_enter_fs || !may_perform_io)
> > +		return rc;
> > +
> > +	/*
> > +	 * We will not stall if the necessary conditions are not met for
> > +	 * migration but direct reclaim seems to account stalls similarly
> > +	 */
> > +	count_vm_event(COMPACTSTALL);
> > +
> > +	/* Compact each zone in the list */
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> > +								nodemask) {
> > +		int fragindex;
> > +		int status;
> > +
> > +		/*
> > +		 * Watermarks for order-0 must be met for compaction. Note
> > +		 * the 2UL. This is because during migration, copies of
> > +		 * pages need to be allocated and for a short time, the
> > +		 * footprint is higher
> > +		 */
> > +		watermark = low_wmark_pages(zone) + (2UL << order);
> > +		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> > +			continue;
> > +
> > +		/*
> > +		 * fragmentation index determines if allocation failures are
> > +		 * due to low memory or external fragmentation
> > +		 *
> > +		 * index of -1 implies allocations might succeed depending
> > +		 * 	on watermarks
> > +		 * index < 500 implies alloc failure is due to lack of memory
> > +		 *
> > +		 * XXX: The choice of 500 is arbitrary. Reinvestigate
> > +		 *      appropriately to determine a sensible default.
> > +		 *      and what it means when watermarks are also taken
> > +		 *      into account. Consider making it a sysctl
> > +		 */
> > +		fragindex = fragmentation_index(zone, order);
> > +		if (fragindex >= 0 && fragindex <= 500)
> > +			continue;
> > +
> > +		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
> > +			rc = COMPACT_PARTIAL;
> > +			break;
> > +		}
> > +
> > +		status = compact_zone_order(zone, order, gfp_mask);
> > +		rc = max(status, rc);
> 
> Hm...then, scanning over the whole zone until success of migration at
> each failure?

Sorry for my lack of understanding but your question is difficult to
understand.

You might mean "scanning over the whole zonelist" rather than zone. In that
case, the zone_watermark_ok before and after the compaction will exit the
loop rather than moving to the next zone in the list.

I'm not sure what you mean by "at each failure". The worst-case scenario
is that a process compacts the entire zone and still fails to meet the
watermarks. The best-case scenario is that it does a small amount of
compaction in the compact_zone() loop and finds that compact_finished()
causes the loop to exit before the whole zone is compacted.

> Is it meaningful that multiple tasks run direct-compaction against
> a zone (from zone->start_pfn to zone->end_pfn) in parallel ?
> ex) running order=3 compaction while other thread runs order=5 compaction.
> 

It is meaningful in that "it will work" but there is a good chance that it's
pointless. To what degree it's pointless depends on what happened between
Compaction Process A starting and Compaction Process B. If kswapd is also
awake, then it might be worthwhile. By and large, the scanning is fast enough
that it won't be very noticeable.

My feeling is that multiple processes entering compaction at all is a bad
situation to be in. It implies there are multiple processes are requiring
high-order pages. Maybe if transparent huge pages were merged, it'd be
expected but otherwise it'd be a surprise.

> Can't we find a clever way to find [start_pfn, end_pfn) for scanning rather than
> [zone->start_pfn, zone->start_pfn + zone->spanned_pages) ?
> 

For sure. An early iteration of these patches stored the PFNs last scanned
for migration in struct zone and would use that as a starting point. It'd
wrap around at least once when it encountered the free page scanner so
that the zone would be scanned at least once. A more convulated
iteration stored a list of compactors in a linked list. When selecting a
pageblock to migrate pages from, it'd check the list and avoid scanning
the same block as any other process.

I dropped these modifications for a few reasons

a) It added complexity for a situation that may not be encountered in
   practice.
b) Arguably, it would also make sense to simply allow only one compactor
   within a zone at a time and use a mutex
c) I had no data on why multiple processes would be direct compacting

The last point was the most important. I wanted to avoid complexity unless
there was a good reason for it. If we do encounter a situation where
multiple compactors are causing problems, I'd be more likely to ask "why
are there so many high-order allocations happening simultaneously?" than
"how can we make compaction smarter?"

> I'm sorry if I miss something...
> 

I don't think you have. Sorry for my poor understanding if I missed
answering any of your queries.

> > +	}
> > +
> > +	return rc;
> > +}
> > +
> > +
> >  /* Compact all zones within a node */
> >  static int compact_node(int nid)
> >  {
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9708143..e301108 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -49,6 +49,7 @@
> >  #include <linux/debugobjects.h>
> >  #include <linux/kmemleak.h>
> >  #include <linux/memory.h>
> > +#include <linux/compaction.h>
> >  #include <trace/events/kmem.h>
> >  #include <linux/ftrace_event.h>
> >  
> > @@ -1765,6 +1766,31 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> >  
> >  	cond_resched();
> >  
> > +	/* Try memory compaction for high-order allocations before reclaim */
> > +	if (order) {
> > +		*did_some_progress = try_to_compact_pages(zonelist,
> > +						order, gfp_mask, nodemask);
> > +		if (*did_some_progress != COMPACT_INCOMPLETE) {
> > +			page = get_page_from_freelist(gfp_mask, nodemask,
> > +					order, zonelist, high_zoneidx,
> > +					alloc_flags, preferred_zone,
> > +					migratetype);
> > +			if (page) {
> > +				__count_vm_event(COMPACTSUCCESS);
> > +				return page;
> > +			}
> > +
> > +			/*
> > +			 * It's bad if compaction run occurs and fails.
> > +			 * The most likely reason is that pages exist,
> > +			 * but not enough to satisfy watermarks.
> > +			 */
> > +			count_vm_event(COMPACTFAIL);
> > +
> > +			cond_resched();
> > +		}
> > +	}
> > +
> >  	/* We now go into synchronous reclaim */
> >  	cpuset_memory_pressure_bump();
> >  	p->flags |= PF_MEMALLOC;
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index af88647..c88f285 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -560,7 +560,7 @@ static int unusable_show(struct seq_file *m, void *arg)
> >   * The value can be used to determine if page reclaim or compaction
> >   * should be used
> >   */
> > -int fragmentation_index(unsigned int order, struct contig_page_info *info)
> > +int __fragmentation_index(unsigned int order, struct contig_page_info *info)
> >  {
> >  	unsigned long requested = 1UL << order;
> >  
> > @@ -580,6 +580,14 @@ int fragmentation_index(unsigned int order, struct contig_page_info *info)
> >  	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
> >  }
> >  
> > +/* Same as __fragmentation index but allocs contig_page_info on stack */
> > +int fragmentation_index(struct zone *zone, unsigned int order)
> > +{
> > +	struct contig_page_info info;
> > +
> > +	fill_contig_page_info(zone, order, &info);
> > +	return __fragmentation_index(order, &info);
> > +}
> >  
> >  static void extfrag_show_print(struct seq_file *m,
> >  					pg_data_t *pgdat, struct zone *zone)
> > @@ -595,7 +603,7 @@ static void extfrag_show_print(struct seq_file *m,
> >  				zone->name);
> >  	for (order = 0; order < MAX_ORDER; ++order) {
> >  		fill_contig_page_info(zone, order, &info);
> > -		index = fragmentation_index(order, &info);
> > +		index = __fragmentation_index(order, &info);
> >  		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
> >  	}
> >  
> > @@ -895,6 +903,9 @@ static const char * const vmstat_text[] = {
> >  	"compact_blocks_moved",
> >  	"compact_pages_moved",
> >  	"compact_pagemigrate_failed",
> > +	"compact_stall",
> > +	"compact_fail",
> > +	"compact_success",
> >  
> >  #ifdef CONFIG_HUGETLB_PAGE
> >  	"htlb_buddy_alloc_success",
> > -- 
> > 1.6.5
> > 
> > 
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
