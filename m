Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 85B7B6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 04:40:08 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2100E4IUQQRY@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 06 Apr 2012 09:40:02 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2100HH4UQTAY@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Apr 2012 09:40:06 +0100 (BST)
Date: Fri, 06 Apr 2012 10:21:39 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 1/2] mm: compaction: try harder to isolate free pages
In-reply-to: 
 <CAEwNFnAtzd5GHKanNOafZhnc5xQJHgVZn6y93_+q4BJwRGqwsg@mail.gmail.com>
Message-id: <201204061021.39656.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-15
Content-transfer-encoding: 7BIT
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
 <1333643534-1591-2-git-send-email-b.zolnierkie@samsung.com>
 <CAEwNFnAtzd5GHKanNOafZhnc5xQJHgVZn6y93_+q4BJwRGqwsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, Kyungmin Park <kyungmin.park@samsung.com>

On Friday 06 April 2012 08:40:56 Minchan Kim wrote:
> On Fri, Apr 6, 2012 at 1:32 AM, Bartlomiej Zolnierkiewicz <
> b.zolnierkie@samsung.com> wrote:
> 
> > In isolate_freepages() check each page in a pageblock
> > instead of checking only first pages of pageblock_nr_pages
> > intervals (suitable_migration_target(page) is called before
> > isolate_freepages_block() so if page is "unsuitable" whole
> > pageblock_nr_pages pages will be ommited from the check).
> > It greatly improves possibility of finding free pages to
> > isolate during compaction_alloc() phase.
> >
> 
> I doubt how this can help keeping free pages.
> Now, compaction works by pageblock_nr_pages unit so although you work by
> per page, all pages in a block would have same block type.
> It means we can't pass suitable_migration_target. No?

suitable_migration_target() only checks first page of pageblock_nr_pages
block (1024 normal 4KiB pages in my test case cause there is no hugepage
support on ARM) and pages in pageblock_nr_pages block can have different
types otherwise I would not see improvement from this patch.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

> > Cc: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  mm/compaction.c |    5 ++---
> >  1 file changed, 2 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index d9ebebe..bc77135 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -65,7 +65,7 @@ static unsigned long isolate_freepages_block(struct zone
> > *zone,
> >
> >        /* Get the last PFN we should scan for free pages at */
> >        zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> > -       end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
> > +       end_pfn = min(blockpfn + 1, zone_end_pfn);
> >
> >        /* Find the first usable PFN in the block to initialse page cursor
> > */
> >        for (; blockpfn < end_pfn; blockpfn++) {
> > @@ -160,8 +160,7 @@ static void isolate_freepages(struct zone *zone,
> >         * pages on cc->migratepages. We stop searching if the migrate
> >         * and free page scanners meet or enough free pages are isolated.
> >         */
> > -       for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
> > -                                       pfn -= pageblock_nr_pages) {
> > +       for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages; pfn--)
> > {
> >                unsigned long isolated;
> >
> >                if (!pfn_valid(pfn))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
