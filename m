Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2AC796B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 04:02:49 -0400 (EDT)
Date: Mon, 8 Oct 2012 17:06:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121008080654.GD13817@bbox>
References: <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
 <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20120928110712.GB29125@suse.de>
 <20120928113924.GA25342@avionic-0098.mockup.avionic-design.de>
 <20120928124332.GC29125@suse.de>
 <20121001142428.GA2798@avionic-0098.mockup.avionic-design.de>
 <20121002124814.GA31316@avionic-0098.mockup.avionic-design.de>
 <20121002144135.GO29125@suse.de>
 <20121002150307.GA1161@avionic-0098.mockup.avionic-design.de>
 <20121002151217.GP29125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121002151217.GP29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Thierry Reding <thierry.reding@avionic-design.de>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

Hi Mel,

On Tue, Oct 02, 2012 at 04:12:17PM +0100, Mel Gorman wrote:
> On Tue, Oct 02, 2012 at 05:03:07PM +0200, Thierry Reding wrote:
> > On Tue, Oct 02, 2012 at 03:41:35PM +0100, Mel Gorman wrote:
> > > On Tue, Oct 02, 2012 at 02:48:14PM +0200, Thierry Reding wrote:
> > > > > So this really isn't all that new, but I just wanted to confirm my
> > > > > results from last week. We'll see if bisection shows up something
> > > > > interesting.
> > > > 
> > > > I just finished bisecting this and git reports:
> > > > 
> > > > 	3750280f8bd0ed01753a72542756a8c82ab27933 is the first bad commit
> > > > 
> > > > I'm attaching the complete bisection log and a diff of all the changes
> > > > applied on top of the bad commit to make it compile and run on my board.
> > > > Most of the patch is probably not important, though. There are two hunks
> > > > which have the pageblock changes I already posted an two other hunks
> > > > with the patch you posted earlier.
> > > > 
> > > > I hope this helps. If you want me to run any other tests, please let me
> > > > know.
> > > > 
> > > 
> > > Can you test with this on top please?
> > 
> > That doesn't build on top of the bad commit. Or is it supposed to go on
> > top of next-20120926?
> > 
> 
> It doesn't build or do you mean it doesn't apply? Assuming the problem
> was that it didn't apply then try this one. It applies on top of
> next-20120928 which is the closest tag I have to next-20120926.
> 
> ---8<---
> mm: compaction: Cache if a pageblock was scanned and no pages were isolated -fix3
> 
> CMA requires that the PG_migrate_skip hint be skipped but it was only
> skipping it when isolating pages for migration, not for free. Ensure
> cc->isolate_skip_hint gets passed in both cases.
> 
> This is a fix for
> mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated-fix.patch
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>

But please resend below compile error fixing.

diff --git a/mm/compaction.c b/mm/compaction.c
index 136debd..ee461b8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -372,22 +372,14 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
  * a free page).
  */
 unsigned long
-isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
+isolate_freepages_range(struct compact_control *cc,
+			unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long isolated, pfn, block_end_pfn;
-	struct zone *zone = NULL;
 	LIST_HEAD(freelist);
 
-	/* cc needed for isolate_freepages_block to acquire zone->lock */
-	struct compact_control cc = {
-		.sync = true,
-	};
-
-	if (pfn_valid(start_pfn))
-		cc.zone = zone = page_zone(pfn_to_page(start_pfn));
-
 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
-		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
+		if (!pfn_valid(pfn) || cc->zone != page_zone(pfn_to_page(pfn)))
 			break;
 
 		/*
@@ -397,7 +389,7 @@ isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		isolated = isolate_freepages_block(&cc, pfn, block_end_pfn,
+		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
 						   &freelist, true);
 
 		/*
diff --git a/mm/internal.h b/mm/internal.h
index 9d5d276..a3ce781 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -135,7 +135,8 @@ struct compact_control {
 };
 
 unsigned long
-isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn);
+isolate_freepages_range(struct compact_control *cc,
+			unsigned long start_pfn, unsigned long end_pfn);
 unsigned long
 isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	unsigned long low_pfn, unsigned long end_pfn, bool unevictable);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e1be1c..d66efcb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5669,7 +5669,8 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
 }
 
 /* [start, end) must belong to a single zone. */
-static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
+static int __alloc_contig_migrate_range(struct compact_control *cc,
+					unsigned long start, unsigned long end)
 {
 	/* This function is based on compact_zone() from compaction.c. */
 	unsigned long nr_reclaimed;
@@ -5677,26 +5678,17 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 	unsigned int tries = 0;
 	int ret = 0;
 
-	struct compact_control cc = {
-		.nr_migratepages = 0,
-		.order = -1,
-		.zone = page_zone(pfn_to_page(start)),
-		.sync = true,
-		.ignore_skip_hint = true,
-	};
-	INIT_LIST_HEAD(&cc.migratepages);
-
 	migrate_prep_local();
 
-	while (pfn < end || !list_empty(&cc.migratepages)) {
+	while (pfn < end || !list_empty(&cc->migratepages)) {
 		if (fatal_signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
 
-		if (list_empty(&cc.migratepages)) {
-			cc.nr_migratepages = 0;
-			pfn = isolate_migratepages_range(cc.zone, &cc,
+		if (list_empty(&cc->migratepages)) {
+			cc->nr_migratepages = 0;
+			pfn = isolate_migratepages_range(cc->zone, cc,
 							 pfn, end, true);
 			if (!pfn) {
 				ret = -EINTR;
@@ -5708,16 +5700,16 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 			break;
 		}
 
-		nr_reclaimed = reclaim_clean_pages_from_list(cc.zone,
-							&cc.migratepages);
-		cc.nr_migratepages -= nr_reclaimed;
+		nr_reclaimed = reclaim_clean_pages_from_list(cc->zone,
+							&cc->migratepages);
+		cc->nr_migratepages -= nr_reclaimed;
 
-		ret = migrate_pages(&cc.migratepages,
+		ret = migrate_pages(&cc->migratepages,
 				    alloc_migrate_target,
 				    0, false, MIGRATE_SYNC);
 	}
 
-	putback_lru_pages(&cc.migratepages);
+	putback_lru_pages(&cc->migratepages);
 	return ret > 0 ? 0 : ret;
 }
 
@@ -5796,6 +5788,15 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	unsigned long outer_start, outer_end;
 	int ret = 0, order;
 
+	struct compact_control cc = {
+		.nr_migratepages = 0,
+		.order = -1,
+		.zone = page_zone(pfn_to_page(start)),
+		.sync = true,
+		.ignore_skip_hint = true,
+	};
+	INIT_LIST_HEAD(&cc.migratepages);
+
 	/*
 	 * What we do here is we mark all pageblocks in range as
 	 * MIGRATE_ISOLATE.  Because pageblock and max order pages may
@@ -5825,7 +5826,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	if (ret)
 		goto done;
 
-	ret = __alloc_contig_migrate_range(start, end);
+	ret = __alloc_contig_migrate_range(&cc, start, end);
 	if (ret)
 		goto done;
 
@@ -5874,7 +5875,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	__reclaim_pages(zone, GFP_HIGHUSER_MOVABLE, end-start);
 
 	/* Grab isolated pages from freelists. */
-	outer_end = isolate_freepages_range(outer_start, end);
+	outer_end = isolate_freepages_range(&cc, outer_start, end);
 	if (!outer_end) {
 		ret = -EBUSY;
 		goto done;

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
