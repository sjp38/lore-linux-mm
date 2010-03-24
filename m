Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C68D6B01CB
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 07:12:22 -0400 (EDT)
Date: Wed, 24 Mar 2010 11:11:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
Message-ID: <20100324111159.GD21147@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-11-git-send-email-mel@csn.ul.ie> <28c262361003231610p3753a136v51720df8568cfa0a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262361003231610p3753a136v51720df8568cfa0a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 08:10:40AM +0900, Minchan Kim wrote:
> Hi, Mel.
> 
> On Tue, Mar 23, 2010 at 9:25 PM, Mel Gorman <mel@csn.ul.ie> wrote:
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
> >  #define COMPACT_INCOMPLETE     0
> > -#define COMPACT_COMPLETE       1
> > +#define COMPACT_PARTIAL                1
> > +#define COMPACT_COMPLETE       2
> >
> >  #ifdef CONFIG_COMPACTION
> >  extern int sysctl_compact_memory;
> >  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> >                        void __user *buffer, size_t *length, loff_t *ppos);
> > +
> > +extern int fragmentation_index(struct zone *zone, unsigned int order);
> > +extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > +                       int order, gfp_t gfp_mask, nodemask_t *mask);
> > +#else
> > +static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > +                       int order, gfp_t gfp_mask, nodemask_t *nodemask)
> > +{
> > +       return COMPACT_INCOMPLETE;
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
> >                KSWAPD_SKIP_CONGESTION_WAIT,
> >                PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> >                COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
> > +               COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
> >  #ifdef CONFIG_HUGETLB_PAGE
> >                HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
> >  #endif
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 8df6e3d..6688700 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -34,6 +34,8 @@ struct compact_control {
> >        unsigned long nr_anon;
> >        unsigned long nr_file;
> >
> > +       unsigned int order;             /* order a direct compactor needs */
> > +       int migratetype;                /* MOVABLE, RECLAIMABLE etc */
> >        struct zone *zone;
> >  };
> >
> > @@ -301,10 +303,31 @@ static void update_nr_listpages(struct compact_control *cc)
> >  static inline int compact_finished(struct zone *zone,
> >                                                struct compact_control *cc)
> >  {
> > +       unsigned int order;
> > +       unsigned long watermark = low_wmark_pages(zone) + (1 << cc->order);
> > +
> >        /* Compaction run completes if the migrate and free scanner meet */
> >        if (cc->free_pfn <= cc->migrate_pfn)
> >                return COMPACT_COMPLETE;
> >
> > +       /* Compaction run is not finished if the watermark is not met */
> > +       if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
> > +               return COMPACT_INCOMPLETE;
> > +
> > +       if (cc->order == -1)
> > +               return COMPACT_INCOMPLETE;
> > +
> > +       /* Direct compactor: Is a suitable page free? */
> > +       for (order = cc->order; order < MAX_ORDER; order++) {
> > +               /* Job done if page is free of the right migratetype */
> > +               if (!list_empty(&zone->free_area[order].free_list[cc->migratetype]))
> > +                       return COMPACT_PARTIAL;
> > +
> > +               /* Job done if allocation would set block type */
> > +               if (order >= pageblock_order && zone->free_area[order].nr_free)
> > +                       return COMPACT_PARTIAL;
> > +       }
> > +
> >        return COMPACT_INCOMPLETE;
> >  }
> >
> > @@ -348,6 +371,101 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >        return ret;
> >  }
> >
> > +static inline unsigned long compact_zone_order(struct zone *zone,
> > +                                               int order, gfp_t gfp_mask)
> > +{
> > +       struct compact_control cc = {
> > +               .nr_freepages = 0,
> > +               .nr_migratepages = 0,
> > +               .order = order,
> > +               .migratetype = allocflags_to_migratetype(gfp_mask),
> > +               .zone = zone,
> > +       };
> > +       INIT_LIST_HEAD(&cc.freepages);
> > +       INIT_LIST_HEAD(&cc.migratepages);
> > +
> > +       return compact_zone(zone, &cc);
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
> > +                       int order, gfp_t gfp_mask, nodemask_t *nodemask)
> > +{
> > +       enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > +       int may_enter_fs = gfp_mask & __GFP_FS;
> > +       int may_perform_io = gfp_mask & __GFP_IO;
> > +       unsigned long watermark;
> > +       struct zoneref *z;
> > +       struct zone *zone;
> > +       int rc = COMPACT_INCOMPLETE;
> > +
> > +       /* Check whether it is worth even starting compaction */
> > +       if (order == 0 || !may_enter_fs || !may_perform_io)
> > +               return rc;
> > +
> > +       /*
> > +        * We will not stall if the necessary conditions are not met for
> > +        * migration but direct reclaim seems to account stalls similarly
> > +        */
> 
> I can't understand this comment.
> In case of direct reclaim, shrink_zones's long time is just stall
> by view point of allocation customer.
> So "Allocation is stalled" makes sense to me.
> 
> But "Compaction is stalled" doesn't make sense to me.

I considered a "stall" to be when the allocator is doing work that is not
allocation-related such as page reclaim or in this case - memory compaction.

> How about "COMPACTION_DIRECT" like "PGSCAN_DIRECT"?

PGSCAN_DIRECT is page-based counter on the number of pages scanned. The
similar naming but very different meaning could be confusing to someone not
familar with the counters. The event being counted here is the number of
times compaction happened just like ALLOCSTALL counts the number of times
direct reclaim happened.

How about COMPACTSTALL like ALLOCSTALL? :/

> I think It's straightforward.
> Naming is important since it makes ABI.
> 
> > +       count_vm_event(COMPACTSTALL);
> > +
> 
> 
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
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
