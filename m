Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 00BD16B008C
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:25:38 -0500 (EST)
Date: Fri, 19 Feb 2010 14:25:22 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/12] Direct compact when a high-order allocation fails
Message-ID: <20100219142522.GL30258@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-12-git-send-email-mel@csn.ul.ie> <28c262361002181841i5d1dae43vcca460eae6ec0ce@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262361002181841i5d1dae43vcca460eae6ec0ce@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 11:41:56AM +0900, Minchan Kim wrote:
> On Fri, Feb 19, 2010 at 3:02 AM, Mel Gorman <mel@csn.ul.ie> wrote:
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
> > index 6a2eefd..1cf95e2 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -1,13 +1,25 @@
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
> > index d7f7236..0ea7a38 100644
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
> > index 02579c2..c7c73bb 100644
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
> > @@ -298,10 +300,31 @@ static void update_nr_listpages(struct compact_control *cc)
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
> 
> Where do we set cc->order = -1?
> Sorry but I can't find it.
> 

Good spot, it should have been set in compact_node() to force a full
compaction.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
