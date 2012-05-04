Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 97A8B6B0044
	for <linux-mm@kvack.org>; Fri,  4 May 2012 06:18:03 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3747211dak.14
        for <linux-mm@kvack.org>; Fri, 04 May 2012 03:18:02 -0700 (PDT)
Date: Fri, 4 May 2012 19:17:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Message-ID: <20120504101755.GA2314@barrios>
References: <201205021047.45188.b.zolnierkie@samsung.com>
 <4FA1D56F.9050505@kernel.org>
 <201205041058.55393.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201205041058.55393.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

Hi Bartlomiej, 

On Fri, May 04, 2012 at 10:58:55AM +0200, Bartlomiej Zolnierkiewicz wrote:
> 
> Hi,
> 
> On Thursday 03 May 2012 02:46:39 Minchan Kim wrote:
> > Hi Bartlomiej,
> > 
> > 
> > Looks better than old but still I have some comments. Please see below.
> > 
> > On 05/02/2012 05:47 PM, Bartlomiej Zolnierkiewicz wrote:
> > 
> > > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > Subject: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks
> > > 
> > > When MIGRATE_UNMOVABLE pages are freed from MIGRATE_UNMOVABLE
> > > type pageblock (and some MIGRATE_MOVABLE pages are left in it)
> > > waiting until an allocation takes ownership of the block may
> > > take too long.  The type of the pageblock remains unchanged
> > > so the pageblock cannot be used as a migration target during
> > > compaction.
> > > 
> > > Fix it by:
> > > 
> > > * Adding enum compact_mode (COMPACT_ASYNC_[MOVABLE,UNMOVABLE],
> > >   and COMPACT_SYNC) and then converting sync field in struct
> > >   compact_control to use it.
> > > 
> > > * Adding nr_[pageblocks,skipped] fields to struct compact_control
> > >   and tracking how many destination pageblocks were scanned during
> > >   compaction and how many of them were of MIGRATE_UNMOVABLE type.
> > >   If COMPACT_ASYNC_MOVABLE mode compaction ran fully in
> > >   try_to_compact_pages() (COMPACT_COMPLETE) it implies that
> > >   there is not a suitable page for allocation.  In this case then
> > >   check how if there were enough MIGRATE_UNMOVABLE pageblocks to
> > >   try a second pass in COMPACT_ASYNC_UNMOVABLE mode.
> > > 
> > > * Scanning the MIGRATE_UNMOVABLE pageblocks (during COMPACT_SYNC
> > >   and COMPACT_ASYNC_UNMOVABLE compaction modes) and building
> > >   a count based on finding PageBuddy pages, page_count(page) == 0
> > >   or PageLRU pages.  If all pages within the MIGRATE_UNMOVABLE
> > >   pageblock are in one of those three sets change the whole
> > >   pageblock type to MIGRATE_MOVABLE.
> > > 
> > > 
> > > My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> > > which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> > > - allocate 120000 pages for kernel's usage
> > > - free every second page (60000 pages) of memory just allocated
> > > - allocate and use 60000 pages from user space
> > > - free remaining 60000 pages of kernel memory
> > > (now we have fragmented memory occupied mostly by user space pages)
> > > - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> > > 
> > > The results:
> > > - with compaction disabled I get 11 successful allocations
> > > - with compaction enabled - 14 successful allocations
> > > - with this patch I'm able to get all 100 successful allocations
> > 
> > 
> > Please add following description which is one me and Mel discussed
> > in your change log.
> > 
> > NOTE : 
> > 
> > If we can coded up kswapd is aware of request of order-0 during compaction,
> > we can enhance kswapd with changing mode to COMPACT_ASYNC_FULL.
> > Let's see following thread.
> > 
> > http://marc.info/?l=linux-mm&m=133552069417068&w=2
> 
> Could you please explain it some more?

The problem kswapd can't do ASYNC_FULL is that direct reclaim latency can take long time
while kswapd is going on compaction.
For example, Process A start reclaim and wakes up kswapd for expecting
kswapd free pages for A so that A can return easilty without painful reclaim in
direct reclaim path. But if kswapd is going on compaction when A wake up him,
kswapd can't do anything for A so A should enter deep direct reclaim path.
If we can make kswap is aware of waking up of require order-0, kswapd can stop
compaction immediately and free order-0 pages. :)
I'm not sure my explnation is enought or not.

>  
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > > ---
> > > v2:
> > > - redo the patch basing on review from Mel Gorman
> > >   (http://marc.info/?l=linux-mm&m=133519311025444&w=2)
> > > v3:
> > > - apply review comments from Minchan Kim
> > >   (http://marc.info/?l=linux-mm&m=133531540308862&w=2)
> > > v4:
> > > - more review comments from Mel
> > >   (http://marc.info/?l=linux-mm&m=133545110625042&w=2)
> > > v5:
> > > - even more comments from Mel
> > >   (http://marc.info/?l=linux-mm&m=133577669023492&w=2)
> > > - fix patch description
> > > 
> > >  include/linux/compaction.h |   19 +++++++
> > >  mm/compaction.c            |  109 +++++++++++++++++++++++++++++++++++++--------
> > >  mm/internal.h              |   10 +++-
> > >  mm/page_alloc.c            |    8 +--
> > >  4 files changed, 124 insertions(+), 22 deletions(-)
> > > 
> > > Index: b/include/linux/compaction.h
> > > ===================================================================
> > > --- a/include/linux/compaction.h	2012-05-02 10:39:17.000000000 +0200
> > > +++ b/include/linux/compaction.h	2012-05-02 10:40:03.708727714 +0200
> > > @@ -1,6 +1,8 @@
> > >  #ifndef _LINUX_COMPACTION_H
> > >  #define _LINUX_COMPACTION_H
> > >  
> > > +#include <linux/node.h>
> > > +
> > >  /* Return values for compact_zone() and try_to_compact_pages() */
> > >  /* compaction didn't start as it was not possible or direct reclaim was more suitable */
> > >  #define COMPACT_SKIPPED		0
> > > @@ -11,6 +13,23 @@
> > >  /* The full zone was compacted */
> > >  #define COMPACT_COMPLETE	3
> > >  
> > > +/*
> > > + * compaction supports three modes
> > > + *
> > > + * COMPACT_ASYNC_MOVABLE uses asynchronous migration and only scans
> > > + *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
> > > + * COMPACT_ASYNC_UNMOVABLE uses asynchronous migration and only scans
> > > + *    MIGRATE_MOVABLE pageblocks as migration sources.
> > > + *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
> > > + *    targets and convers them to MIGRATE_MOVABLE if possible
> > > + * COMPACT_SYNC uses synchronous migration and scans all pageblocks
> > > + */
> > > +enum compact_mode {
> > > +	COMPACT_ASYNC_MOVABLE,
> > > +	COMPACT_ASYNC_UNMOVABLE,
> > > +	COMPACT_SYNC,
> > > +};
> > > +
> > >  #ifdef CONFIG_COMPACTION
> > >  extern int sysctl_compact_memory;
> > >  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> > > Index: b/mm/compaction.c
> > > ===================================================================
> > > --- a/mm/compaction.c	2012-05-02 10:39:19.000000000 +0200
> > > +++ b/mm/compaction.c	2012-05-02 10:44:44.380727714 +0200
> > > @@ -235,7 +235,7 @@
> > >  	 */
> > >  	while (unlikely(too_many_isolated(zone))) {
> > >  		/* async migration should just abort */
> > > -		if (!cc->sync)
> > > +		if (cc->mode != COMPACT_SYNC)
> > >  			return 0;
> > >  
> > >  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > @@ -303,7 +303,8 @@
> > >  		 * satisfies the allocation
> > >  		 */
> > >  		pageblock_nr = low_pfn >> pageblock_order;
> > > -		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
> > > +		if (cc->mode != COMPACT_SYNC &&
> > > +		    last_pageblock_nr != pageblock_nr &&
> > >  		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
> > >  			low_pfn += pageblock_nr_pages;
> > >  			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
> > > @@ -324,7 +325,7 @@
> > >  			continue;
> > >  		}
> > >  
> > > -		if (!cc->sync)
> > > +		if (cc->mode != COMPACT_SYNC)
> > >  			mode |= ISOLATE_ASYNC_MIGRATE;
> > >  
> > >  		/* Try isolate the page */
> > > @@ -357,13 +358,59 @@
> > >  
> > >  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
> > >  #ifdef CONFIG_COMPACTION
> > > +static bool rescue_unmovable_pageblock(struct page *page)
> > > +{
> > > +	unsigned long pfn, start_pfn, end_pfn;
> > > +	struct page *start_page, *end_page;
> > > +
> > > +	pfn = page_to_pfn(page);
> > > +	start_pfn = pfn & ~(pageblock_nr_pages - 1);
> > > +	end_pfn = start_pfn + pageblock_nr_pages;
> > > +
> > > +	start_page = pfn_to_page(start_pfn);
> > > +	end_page = pfn_to_page(end_pfn);
> > > +
> > > +	/* Do not deal with pageblocks that overlap zones */
> > > +	if (page_zone(start_page) != page_zone(end_page))
> > > +		return false;
> > > +
> > > +	for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
> > > +								  page++) {
> > > +		if (!pfn_valid_within(pfn))
> > > +			continue;
> > > +
> > > +		if (PageBuddy(page)) {
> > > +			int order = page_order(page);
> > > +
> > > +			pfn += (1 << order) - 1;
> > > +			page += (1 << order) - 1;
> > > +
> > > +			continue;
> > > +		} else if (page_count(page) == 0 || PageLRU(page))
> > > +			continue;
> > > +
> > > +		return false;
> > > +	}
> > > +
> > > +	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> > > +	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
> > > +	return true;
> > > +}
> > >  
> > >  /* Returns true if the page is within a block suitable for migration to */
> > > -static bool suitable_migration_target(struct page *page)
> > > +static bool suitable_migration_target(struct page *page,
> > > +				      struct compact_control *cc,
> > > +				      bool count_pageblocks)
> > >  {
> > >  
> > >  	int migratetype = get_pageblock_migratetype(page);
> > >  
> > > +	if (count_pageblocks && cc->mode == COMPACT_ASYNC_MOVABLE) {
> > 
> > 
> > We don't need to pass compact_control itself but mode.
> > But it seems to be removed by my below comment.
> > 
> > 
> > > +		cc->nr_pageblocks++;
> > 
> > 
> > Why do we need nr_pageblocks?
> > What's the problem if we remove nr_pageblock?
> 
> Currently there is no problem with removing it but it was Mel's
> request to add it and I think that in the final patch he wants some
> more complex code to decide whether run COMPACT_ASYNC_UNMOVABLE or
> not?
> 
> > > +		if (migratetype == MIGRATE_UNMOVABLE)
> > > +			cc->nr_skipped++;
> > > +	}
> > 
> > 
> > I understand why you add count_pageblock because we call suitable_migration_target
> > twice to make sure. But I don't like such trick.
> > If we can remove nr_pageblock, how about this?
> > 
> > 
> > barrios@bbox:~/linux-next$ git diff
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 58f7a93..55f62f9 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -435,8 +435,7 @@ static void isolate_freepages(struct zone *zone,
> >  
> >                 /* Check the block is suitable for migration */
> >                 if (!suitable_migration_target(page))
> > -                       continue;
> > -
> > +                       goto unmovable_pageblock;
> >                 /*
> >                  * Found a block suitable for isolating free pages from. Now
> >                  * we disabled interrupts, double check things are ok and
> > @@ -451,6 +450,10 @@ static void isolate_freepages(struct zone *zone,
> >                                                            freelist, false);
> >                         nr_freepages += isolated;
> >                 }
> > +               else {
> > +                       spin_unlock_irqrestore(&zone->lock, flags);
> > +                       goto unmovable_pageblock;
> > +               }
> >                 spin_unlock_irqrestore(&zone->lock, flags);
> >  
> >                 /*
> > @@ -460,6 +463,15 @@ static void isolate_freepages(struct zone *zone,
> >                  */
> >                 if (isolated)
> >                         high_pfn = max(high_pfn, pfn);
> > +unmovable_pageblock:
> > +               /*
> > +                * check why suitable_migration_target fail.
> > +                * If it fail by the pageblock is unmovable in COMPACT_ASYNC_MOVABLE
> > +                * we will retry it with COMPACT_ASYNC_UNMOVABLE if we can't get
> > +                * a page in try_to_compact_pages.
> > +                */
> > +               if (cc->mode == COMPACT_ASYNC_MOVABLE)
> > +                       cc->nr_skipped++;
> >         }
> >  
> >         /* split_free_page does not map the pages */
> 
> This will count MIGRATE_ISOLATE and MIGRATE_RESERVE pageblocks
> as MIGRATE_UNMOVABLE ones, and will also miss MIGRATE_UNMOVABLE
> pageblocks that contain large free pages ("PageBuddy(page) &&
> page_order(page) >= pageblock_order" case).  The current code
> while tricky seems to work better..

Oops, I missed that, then how about making suitable_migration_target return
why. If suitable_migration_target return FAIL_UNMOVABLE_PAGEBLOCK,
we can count it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
