Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 9DF906B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 06:09:20 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: Text/Plain; charset=iso-8859-15
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M3A002FREUK4J00@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 30 Apr 2012 11:08:44 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3A00KENEVI5F@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 30 Apr 2012 11:09:18 +0100 (BST)
Date: Mon, 30 Apr 2012 12:08:47 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v4] mm: compaction: handle incorrect Unmovable type
 pageblocks
In-reply-to: <20120430090239.GL9226@suse.de>
Message-id: <201204301208.47866.b.zolnierkie@samsung.com>
References: <201204271257.11501.b.zolnierkie@samsung.com>
 <20120430090239.GL9226@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Monday 30 April 2012 11:02:39 Mel Gorman wrote:
> On Fri, Apr 27, 2012 at 12:57:11PM +0200, Bartlomiej Zolnierkiewicz wrote:
> > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Subject: [PATCH v4] mm: compaction: handle incorrect Unmovable type pageblocks
> > 
> > When Unmovable pages are freed from Unmovable type pageblock
> > (and some Movable type pages are left in it) waiting until
> > an allocation takes ownership of the block may take too long.
> > The type of the pageblock remains unchanged so the pageblock
> > cannot be used as a migration target during compaction.
> > 
> > Fix it by:
> > 
> > * Adding enum compact_mode (COMPACT_ASYNC_MOVABLE,
> >   COMPACT_ASYNC_UNMOVABLE and COMPACT_SYNC) and then converting
> >   sync field in struct compact_control to use it.
> > 
> > * Scanning the Unmovable pageblocks (during COMPACT_ASYNC_UNMOVABLE
> >   and COMPACT_SYNC compactions) and building a count based on
> >   finding PageBuddy pages, page_count(page) == 0 or PageLRU pages.
> >   If all pages within the Unmovable pageblock are in one of those
> >   three sets change the whole pageblock type to Movable.
> > 
> > My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> > which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> > - allocate 120000 pages for kernel's usage
> > - free every second page (60000 pages) of memory just allocated
> > - allocate and use 60000 pages from user space
> > - free remaining 60000 pages of kernel memory
> > (now we have fragmented memory occupied mostly by user space pages)
> > - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> > 
> > The results:
> > - with compaction disabled I get 11 successful allocations
> > - with compaction enabled - 14 successful allocations
> > - with this patch I'm able to get all 100 successful allocations
> > 
> 
> This is looking much better to me. However, I would really like to see
> COMPACT_ASYNC_UNMOVABLE being used by the page allocator instead of depending
> on kswapd to do the work. Right now as it uses COMPACT_ASYNC_MOVABLE only,
> I think it uses COMPACT_SYNC too easily (making latency worse).

Is the following v4 code in __alloc_pages_direct_compact() not enough?

@@ -2122,7 +2122,7 @@
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, enum compact_mode migration_mode,
 	bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2285,7 +2285,7 @@
 	int alloc_flags;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
-	bool sync_migration = false;
+	enum compact_mode migration_mode = COMPACT_ASYNC_MOVABLE;
 	bool deferred_compaction = false;
 
 	/*
@@ -2360,19 +2360,31 @@
 		goto nopage;
 
 	/*
-	 * Try direct compaction. The first pass is asynchronous. Subsequent
-	 * attempts after direct reclaim are synchronous
+	 * Try direct compaction. The first and second pass are asynchronous.
+	 * Subsequent attempts after direct reclaim are synchronous.
 	 */
 	page = __alloc_pages_direct_compact(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, sync_migration,
+					migratetype, migration_mode,
 					&deferred_compaction,
 					&did_some_progress);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+
+	migration_mode = COMPACT_ASYNC_UNMOVABLE;
+	page = __alloc_pages_direct_compact(gfp_mask, order,
+					zonelist, high_zoneidx,
+					nodemask,
+					alloc_flags, preferred_zone,
+					migratetype, migration_mode,
+					&deferred_compaction,
+					&did_some_progress);
+	if (page)
+		goto got_pg;
+
+	migration_mode = COMPACT_SYNC;
 
 	/*
 	 * If compaction is deferred for high-order allocations, it is because

> Specifically
> 
> 1. Leave try_to_compact_pages() taking a sync parameter. It is up to
>    compaction how to treat sync==false
> 2. When sync==false, start with ASYNC_MOVABLE. Track how many pageblocks
>    were scanned during compaction and how many of them were
>    MIGRATE_UNMOVABLE. If compaction ran fully (COMPACT_COMPLETE) it implies
>    that there is not a suitable page for allocation. In this case then
>    check how if there were enough MIGRATE_UNMOVABLE pageblocks to try a
>    second pass in ASYNC_FULL. By keeping all the logic in compaction.c
>    it prevents too much knowledge of compaction sneaking into
>    page_alloc.c

Do you mean that try_to_compact_pages() should handle COMPACT_ASYNC_MOVABLE
and COMPACT_ASYNC_UNMOVABLE internally while __alloc_pages_direct_compact()
(and its users) should only pass bool sync to it?

> 3. When scanning ASYNC_FULL, *only* scan the MIGRATE_UNMOVABLE blocks as
>    migration targets because the first pass would have scanned within
>    MIGRATE_MOVABLE. This will reduce the cost of the second pass.

That is what the current v4 code should already be doing with:

[...]
 /* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+static bool suitable_migration_target(struct page *page,
+				      enum compact_mode mode)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
@@ -373,7 +413,13 @@
 		return true;
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
+	if (mode != COMPACT_ASYNC_UNMOVABLE &&
+	    migrate_async_suitable(migratetype))
+		return true;
+
+	if (mode != COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE &&
+	    rescue_unmovable_pageblock(page))
 		return true;
 
 	/* Otherwise skip the block */

?

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
