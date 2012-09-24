Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1E1B86B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:31:52 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MAU00K9JL4FVD10@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 24 Sep 2012 18:31:49 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MAU003APL4ZUU30@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 24 Sep 2012 18:31:49 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v4 4/4] cma: fix watermark checking
Date: Mon, 24 Sep 2012 11:30:43 +0200
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
 <1347632974-20465-5-git-send-email-b.zolnierkie@samsung.com>
 <20120919125102.4a45e27c.akpm@linux-foundation.org>
In-reply-to: <20120919125102.4a45e27c.akpm@linux-foundation.org>
MIME-version: 1.0
Message-id: <201209241130.43480.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Wednesday 19 September 2012 21:51:02 Andrew Morton wrote:
> On Fri, 14 Sep 2012 16:29:34 +0200
> Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:
> 
> > * Add ALLOC_CMA alloc flag and pass it to [__]zone_watermark_ok()
> >   (from Minchan Kim).
> 
> What is its meaning and why was it added.

ALLOC_CMA flag means that allocation can use CMA areas to get free pages
from.  Free CMA pages are accounted by system as normal free pages
(NR_FREE_PAGES) but they can be used only by movable type allocations
(otherwise they cannot be migrated once we want to do CMA allocation)
so we have to fix free_pages in __zone_watermark_ok() or the watermark
check will be too optimistic for unmovable allocations.

> > * During watermark check decrease available free pages number by
> >   free CMA pages number if necessary (unmovable allocations cannot
> >   use pages from CMA areas).
> > 
> > ...
> >
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -231,6 +231,21 @@ enum zone_watermarks {
> >  #define low_wmark_pages(z) (z->watermark[WMARK_LOW])
> >  #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
> >  
> > +/* The ALLOC_WMARK bits are used as an index to zone->watermark */
> > +#define ALLOC_WMARK_MIN		WMARK_MIN
> > +#define ALLOC_WMARK_LOW		WMARK_LOW
> > +#define ALLOC_WMARK_HIGH	WMARK_HIGH
> > +#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
> > +
> > +/* Mask to get the watermark bits */
> > +#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
> > +
> > +#define ALLOC_HARDER		0x10 /* try to alloc harder */
> > +#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> > +#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> > +
> 
> Unneeded newline.
> 
> > +#define ALLOC_CMA		0x80
> 
> All the other enumerations were documented.  ALLOC_CMA was left
> undocumented, despite sorely needing documentation.
> 
> >  struct per_cpu_pages {
> >  	int count;		/* number of pages in the list */
> >  	int high;		/* high watermark, emptying needed */
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 4b902aa..36d79ea 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -868,6 +868,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >  	struct zoneref *z;
> >  	struct zone *zone;
> >  	int rc = COMPACT_SKIPPED;
> > +	int alloc_flags = 0;
> >  
> >  	/*
> >  	 * Check whether it is worth even starting compaction. The order check is
> > @@ -879,6 +880,10 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >  
> >  	count_vm_event(COMPACTSTALL);
> >  
> > +#ifdef CONFIG_CMA
> > +	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> > +		alloc_flags |= ALLOC_CMA;
> 
> I find this rather obscure.  What is the significance of
> MIGRATE_MOVABLE here?  If it had been 
> 
> :	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_CMA)
> :		alloc_flags |= ALLOC_CMA;
> 
> then I'd have read straight past it.  But it's unclear what's happening
> here.  If we didn't have to resort to telepathy to understand the
> meaning of ALLOC_CMA, this wouldn't be so hard.
> 
> > +#endif
> >  	/* Compact each zone in the list */
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> >  								nodemask) {
> > @@ -889,7 +894,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
> >  		rc = max(status, rc);
> >  
> >  		/* If a normal allocation would succeed, stop compacting */
> > -		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
> > +		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
> > +				      alloc_flags))
> >  			break;
> >  	}
> >  
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 287f79d..5985cbf 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1519,19 +1519,6 @@ failed:
> >  	return NULL;
> >  }
> >  
> > -/* The ALLOC_WMARK bits are used as an index to zone->watermark */
> > -#define ALLOC_WMARK_MIN		WMARK_MIN
> > -#define ALLOC_WMARK_LOW		WMARK_LOW
> > -#define ALLOC_WMARK_HIGH	WMARK_HIGH
> > -#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
> > -
> > -/* Mask to get the watermark bits */
> > -#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
> > -
> > -#define ALLOC_HARDER		0x10 /* try to alloc harder */
> > -#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> > -#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> 
> Perhaps mm/internal.h wouild have been a better place to move these.
> 
> >  #ifdef CONFIG_FAIL_PAGE_ALLOC
> >  
> >  static struct {
> > @@ -1626,7 +1613,10 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >  		min -= min / 2;
> >  	if (alloc_flags & ALLOC_HARDER)
> >  		min -= min / 4;
> > -
> > +#ifdef CONFIG_CMA
> > +	if (!(alloc_flags & ALLOC_CMA))
> > +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> 
> Again, the negated test looks weird or just wrong.
> 
> 
> 
> Please do something to make this code more understandable.

Here is an incremental patch:

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] cma: fix watermark checking cleanup

Changes:
* document ALLOC_CMA
* add comment to __zone_watermark_ok()
* move ALLOC_* defines to mm/internal.h

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/mmzone.h |   15 ---------------
 mm/internal.h          |   14 ++++++++++++++
 mm/page_alloc.c        |    1 +
 3 files changed, 15 insertions(+), 15 deletions(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h	2012-09-24 11:09:10.700992708 +0200
+++ b/include/linux/mmzone.h	2012-09-24 11:11:36.520992691 +0200
@@ -231,21 +231,6 @@ enum zone_watermarks {
 #define low_wmark_pages(z) (z->watermark[WMARK_LOW])
 #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
 
-/* The ALLOC_WMARK bits are used as an index to zone->watermark */
-#define ALLOC_WMARK_MIN		WMARK_MIN
-#define ALLOC_WMARK_LOW		WMARK_LOW
-#define ALLOC_WMARK_HIGH	WMARK_HIGH
-#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
-
-/* Mask to get the watermark bits */
-#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
-
-#define ALLOC_HARDER		0x10 /* try to alloc harder */
-#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
-#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-
-#define ALLOC_CMA		0x80
-
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2012-09-24 11:10:04.848992709 +0200
+++ b/mm/internal.h	2012-09-24 11:11:39.972992691 +0200
@@ -356,3 +356,17 @@ extern unsigned long vm_mmap_pgoff(struc
         unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
+
+/* The ALLOC_WMARK bits are used as an index to zone->watermark */
+#define ALLOC_WMARK_MIN		WMARK_MIN
+#define ALLOC_WMARK_LOW		WMARK_LOW
+#define ALLOC_WMARK_HIGH	WMARK_HIGH
+#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
+
+/* Mask to get the watermark bits */
+#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
+
+#define ALLOC_HARDER		0x10 /* try to alloc harder */
+#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
+#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-09-24 11:12:22.212992717 +0200
+++ b/mm/page_alloc.c	2012-09-24 11:15:28.212992661 +0200
@@ -1614,6 +1614,7 @@ static bool __zone_watermark_ok(struct z
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 #ifdef CONFIG_CMA
+	/* If allocation can't use CMA areas don't use free CMA pages */
 	if (!(alloc_flags & ALLOC_CMA))
 		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
