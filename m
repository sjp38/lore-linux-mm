Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id A8EAC6B0083
	for <linux-mm@kvack.org>; Fri,  4 May 2012 09:07:54 -0400 (EDT)
Date: Fri, 4 May 2012 14:07:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Message-ID: <20120504130749.GM11435@suse.de>
References: <201205021047.45188.b.zolnierkie@samsung.com>
 <20120504110302.GL11435@suse.de>
 <201205041440.41290.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201205041440.41290.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Fri, May 04, 2012 at 02:40:41PM +0200, Bartlomiej Zolnierkiewicz wrote:
> On Friday 04 May 2012 13:03:02 Mel Gorman wrote:
> > On Wed, May 02, 2012 at 10:47:44AM +0200, Bartlomiej Zolnierkiewicz wrote:
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
> > > 
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > 
> > Minor comments only at this point.
> > 
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
> > 
> > Why is it necessary to include linux/node.h?
> 
> Without it I'm getting:
> 

Ah ok, it's because you now include compaction.h from internal.h and it's
C files that are not already importing node.h that are complaining. Fair
enough.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
