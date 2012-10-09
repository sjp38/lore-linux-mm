Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 5C50F6B0044
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 07:10:28 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBM00GU2HOSZ480@mailout3.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Oct 2012 20:10:26 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MBM00E2LHPB7T40@mmp2.samsung.com> for linux-mm@kvack.org;
 Tue, 09 Oct 2012 20:10:26 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: CMA broken in next-20120926
Date: Tue, 09 Oct 2012 13:08:30 +0200
References: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <201210091040.10811.b.zolnierkie@samsung.com> <20121009101143.GQ29125@suse.de>
In-reply-to: <20121009101143.GQ29125@suse.de>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201210091308.30306.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Thierry Reding <thierry.reding@avionic-design.de>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Tuesday 09 October 2012 12:11:43 Mel Gorman wrote:
> On Tue, Oct 09, 2012 at 10:40:10AM +0200, Bartlomiej Zolnierkiewicz wrote:
> > I also need following patch to make CONFIG_CMA=y && CONFIG_COMPACTION=y case
> > work:
> > 
> > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Subject: [PATCH] mm: compaction: cache if a pageblock was scanned and no pages were isolated - cma fix
> > 
> > Patch "mm: compaction: cache if a pageblock was scanned and no pages
> > were isolated" needs a following fix to successfully boot next-20121002
> > kernel (same with next-20121008) with CONFIG_CMA=y and CONFIG_COMPACTION=y
> > (with applied -fix1, -fix2, -fix3 patches from Mel Gorman and also with
> > cmatest module from Thierry Reding compiled in).
> > 
> 
> Why is it needed to make it boot? CMA should not care about the

It boots without Thierry's cmatest module but then fails on CMA
allocation attempt (I used out-of-tree /dev/cma_test interface to
generate CMA allocation request from user-space).

> PG_migrate_skip hint being set because it should always ignore it in
> alloc_contig_range() due to cc->ignore_skip_hint. It's not obvious to
> me why this fixes a boot failure and I wonder if it's papering over some
> underlying problem. Can you provide more details please?

I just compared CONFIG_COMPACTION=n and =y cases initially, figured
out the difference and did the change.  However on a closer look it
seems that {get,clear,set}_pageblock_skip() use incorrect bit ranges
(please compare to bit ranges used by {get,set}_pageblock_flags()
used for migration types) and can overwrite pageblock migratetype of
the next pageblock in the bitmap (I wonder how could this code ever
worked before?).

> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  mm/compaction.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > Index: b/mm/compaction.c
> > ===================================================================
> > --- a/mm/compaction.c	2012-10-08 18:10:53.491679716 +0200
> > +++ b/mm/compaction.c	2012-10-08 18:11:33.615679713 +0200
> > @@ -117,7 +117,8 @@ static void update_pageblock_skip(struct
> >  			bool migrate_scanner)
> >  {
> >  	struct zone *zone = cc->zone;
> > -	if (!page)
> > +
> > +	if (!page || cc->ignore_skip_hint)
> >  		return;
> >  
> >  	if (!nr_isolated) {

The patch below also fixes the issue for me:

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] mm: compaction: fix bit ranges in {get,clear,set}_pageblock_skip() 

{get,clear,set}_pageblock_skip() use incorrect bit ranges (please compare
to bit ranges used by {get,set}_pageblock_flags() used for migration types)
and can overwrite pageblock migratetype of the next pageblock in the bitmap.

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/pageblock-flags.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: b/include/linux/pageblock-flags.h
===================================================================
--- a/include/linux/pageblock-flags.h	2012-10-09 12:50:20.366340001 +0200
+++ b/include/linux/pageblock-flags.h	2012-10-09 12:50:31.794339996 +0200
@@ -71,13 +71,13 @@ void set_pageblock_flags_group(struct pa
 #ifdef CONFIG_COMPACTION
 #define get_pageblock_skip(page) \
 			get_pageblock_flags_group(page, PB_migrate_skip,     \
-							PB_migrate_skip + 1)
+							PB_migrate_skip)
 #define clear_pageblock_skip(page) \
 			set_pageblock_flags_group(page, 0, PB_migrate_skip,  \
-							PB_migrate_skip + 1)
+							PB_migrate_skip)
 #define set_pageblock_skip(page) \
 			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
-							PB_migrate_skip + 1)
+							PB_migrate_skip)
 #endif /* CONFIG_COMPACTION */
 
 #define get_pageblock_flags(page) \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
