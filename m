Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id F3D266B0068
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 10:42:01 -0400 (EDT)
Date: Tue, 2 Oct 2012 15:41:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121002144135.GO29125@suse.de>
References: <50656459.70309@ti.com>
 <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
 <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
 <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20120928110712.GB29125@suse.de>
 <20120928113924.GA25342@avionic-0098.mockup.avionic-design.de>
 <20120928124332.GC29125@suse.de>
 <20121001142428.GA2798@avionic-0098.mockup.avionic-design.de>
 <20121002124814.GA31316@avionic-0098.mockup.avionic-design.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121002124814.GA31316@avionic-0098.mockup.avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@avionic-design.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Tue, Oct 02, 2012 at 02:48:14PM +0200, Thierry Reding wrote:
> > So this really isn't all that new, but I just wanted to confirm my
> > results from last week. We'll see if bisection shows up something
> > interesting.
> 
> I just finished bisecting this and git reports:
> 
> 	3750280f8bd0ed01753a72542756a8c82ab27933 is the first bad commit
> 
> I'm attaching the complete bisection log and a diff of all the changes
> applied on top of the bad commit to make it compile and run on my board.
> Most of the patch is probably not important, though. There are two hunks
> which have the pageblock changes I already posted an two other hunks
> with the patch you posted earlier.
> 
> I hope this helps. If you want me to run any other tests, please let me
> know.
> 

Can you test with this on top please?

---8<---
diff --git a/mm/compaction.c b/mm/compaction.c
index d6e260a..1f1d46d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -374,20 +374,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
  * a free page).
  */
 unsigned long
-isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
+isolate_freepages_range(struct compact_control *cc,
+			unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long isolated, pfn, block_end_pfn;
-	struct zone *zone = NULL;
+	struct zone *zone = cc->zone;
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
 		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
 			break;
@@ -399,7 +392,7 @@ isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		isolated = isolate_freepages_block(&cc, pfn, block_end_pfn,
+		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
 						   &freelist, true);
 
 		/*
diff --git a/mm/internal.h b/mm/internal.h
index 7052289..ffe0473 100644
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
 			   unsigned long low_pfn, unsigned long end_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a1906b..076d08d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5650,23 +5650,14 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
 }
 
 /* [start, end) must belong to a single zone. */
-static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
+static int __alloc_contig_migrate_range(struct compact_control *cc,
+					unsigned long start, unsigned long end)
 {
 	/* This function is based on compact_zone() from compaction.c. */
-
 	unsigned long pfn = start;
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
 
 	while (pfn < end || !list_empty(&cc.migratepages)) {
@@ -5775,6 +5766,15 @@ int alloc_contig_range(unsigned long start, unsigned long end,
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
@@ -5804,7 +5804,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	if (ret)
 		goto done;
 
-	ret = __alloc_contig_migrate_range(start, end);
+	ret = __alloc_contig_migrate_range(cc, start, end);
 	if (ret)
 		goto done;
 
@@ -5853,7 +5853,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	__reclaim_pages(zone, GFP_HIGHUSER_MOVABLE, end-start);
 
 	/* Grab isolated pages from freelists. */
-	outer_end = isolate_freepages_range(outer_start, end);
+	outer_end = isolate_freepages_range(cc, outer_start, end);
 	if (!outer_end) {
 		ret = -EBUSY;
 		goto done;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
