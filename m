From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
Date: Sun, 23 Oct 2011 21:05:05 -0700
Message-ID: <809d0a2afe624c06505e0df51e7657f66aaf9007.1319428526.git.mina86__44736.3240797587$1319429148$gmane$org@mina86.com>
References: <20111018122109.GB6660@csn.ul.ie>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1RIBn4-00052W-NF
	for glkm-linux-mm-2@m.gmane.org; Mon, 24 Oct 2011 06:05:35 +0200
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B25AF6B002D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 00:05:29 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p9O45P0q005169
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 21:05:25 -0700
Received: from gyd10 (gyd10.prod.google.com [10.243.49.202])
	by hpaq12.eem.corp.google.com with ESMTP id p9O41gYu001838
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 21:05:24 -0700
Received: by gyd10 with SMTP id 10so8629693gyd.7
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 21:05:21 -0700 (PDT)
In-Reply-To: <20111018122109.GB6660@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>Marek Szyprowski <m.szyprowski@samsung.com>Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

> On Thu, Oct 06, 2011 at 03:54:42PM +0200, Marek Szyprowski wrote:
>> This commit introduces alloc_contig_freed_pages() function
>> which allocates (ie. removes from buddy system) free pages
>> in range. Caller has to guarantee that all pages in range
>> are in buddy system.

On Tue, 18 Oct 2011 05:21:09 -0700, Mel Gorman <mel@csn.ul.ie> wrote:
> Straight away, I'm wondering why you didn't use
> mm/compaction.c#isolate_freepages()

Does the below look like a step in the right direction?

It basically moves isolate_freepages_block() to page_alloc.c (changing
it name to isolate_freepages_range()) and changes it so that depending
on arguments it treats holes (either invalid PFN or non-free page) as
errors so that CMA can use it.

It also accepts a range rather then just assuming a single pageblock
thus the change moves range calculation in compaction.c from
isolate_freepages_block() up to isolate_freepages().

The change also modifies spilt_free_page() so that it does not try to
change pageblock's migrate type if current migrate type is ISOLATE or
CMA.

---
 include/linux/mm.h             |    1 -
 include/linux/page-isolation.h |    4 +-
 mm/compaction.c                |   73 +++--------------------
 mm/internal.h                  |    5 ++
 mm/page_alloc.c                |  128 +++++++++++++++++++++++++---------------
 5 files changed, 95 insertions(+), 116 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fd599f4..98c99c4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -435,7 +435,6 @@ void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
-int split_free_page(struct page *page);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 003c52f..6becc74 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -48,10 +48,8 @@ static inline void unset_migratetype_isolate(struct page *page)
 }
 
 /* The below functions must be run on a range from a single zone. */
-extern unsigned long alloc_contig_freed_pages(unsigned long start,
-					      unsigned long end, gfp_t flag);
 extern int alloc_contig_range(unsigned long start, unsigned long end,
-			      gfp_t flags, unsigned migratetype);
+			      unsigned migratetype);
 extern void free_contig_pages(unsigned long pfn, unsigned nr_pages);
 
 /*
diff --git a/mm/compaction.c b/mm/compaction.c
index 9e5cc59..685a19e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -58,77 +58,15 @@ static unsigned long release_freepages(struct list_head *freelist)
 	return count;
 }
 
-/* Isolate free pages onto a private freelist. Must hold zone->lock */
-static unsigned long isolate_freepages_block(struct zone *zone,
-				unsigned long blockpfn,
-				struct list_head *freelist)
-{
-	unsigned long zone_end_pfn, end_pfn;
-	int nr_scanned = 0, total_isolated = 0;
-	struct page *cursor;
-
-	/* Get the last PFN we should scan for free pages at */
-	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
-
-	/* Find the first usable PFN in the block to initialse page cursor */
-	for (; blockpfn < end_pfn; blockpfn++) {
-		if (pfn_valid_within(blockpfn))
-			break;
-	}
-	cursor = pfn_to_page(blockpfn);
-
-	/* Isolate free pages. This assumes the block is valid */
-	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
-		int isolated, i;
-		struct page *page = cursor;
-
-		if (!pfn_valid_within(blockpfn))
-			continue;
-		nr_scanned++;
-
-		if (!PageBuddy(page))
-			continue;
-
-		/* Found a free page, break it into order-0 pages */
-		isolated = split_free_page(page);
-		total_isolated += isolated;
-		for (i = 0; i < isolated; i++) {
-			list_add(&page->lru, freelist);
-			page++;
-		}
-
-		/* If a page was split, advance to the end of it */
-		if (isolated) {
-			blockpfn += isolated - 1;
-			cursor += isolated - 1;
-		}
-	}
-
-	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
-	return total_isolated;
-}
-
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct page *page)
 {
-
 	int migratetype = get_pageblock_migratetype(page);
 
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
 		return false;
 
-	/* Keep MIGRATE_CMA alone as well. */
-	/*
-	 * XXX Revisit.  We currently cannot let compaction touch CMA
-	 * pages since compaction insists on changing their migration
-	 * type to MIGRATE_MOVABLE (see split_free_page() called from
-	 * isolate_freepages_block() above).
-	 */
-	if (is_migrate_cma(migratetype))
-		return false;
-
 	/* If the page is a large free page, then allow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
 		return true;
@@ -149,7 +87,7 @@ static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn;
+	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
 	unsigned long flags;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
@@ -169,6 +107,8 @@ static void isolate_freepages(struct zone *zone,
 	 */
 	high_pfn = min(low_pfn, pfn);
 
+	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+
 	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
@@ -176,7 +116,7 @@ static void isolate_freepages(struct zone *zone,
 	 */
 	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
 					pfn -= pageblock_nr_pages) {
-		unsigned long isolated;
+		unsigned isolated, scanned;
 
 		if (!pfn_valid(pfn))
 			continue;
@@ -205,7 +145,10 @@ static void isolate_freepages(struct zone *zone,
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
 		if (suitable_migration_target(page)) {
-			isolated = isolate_freepages_block(zone, pfn, freelist);
+			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
+			isolated = isolate_freepages_range(zone, pfn,
+					end_pfn, freelist, &scanned);
+			trace_mm_compaction_isolate_freepages(scanned, isolated);
 			nr_freepages += isolated;
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
diff --git a/mm/internal.h b/mm/internal.h
index d071d380..4a9bb3f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -263,3 +263,8 @@ extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
 extern u64 hwpoison_filter_memcg;
 extern u32 hwpoison_filter_enable;
+
+unsigned isolate_freepages_range(struct zone *zone,
+				 unsigned long start, unsigned long end,
+				 struct list_head *freelist,
+				 unsigned *scannedp);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df69706..adf3f34 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1300,10 +1300,11 @@ void split_page(struct page *page, unsigned int order)
  * Note: this is probably too low level an operation for use in drivers.
  * Please consult with lkml before using this in your driver.
  */
-int split_free_page(struct page *page)
+static unsigned split_free_page(struct page *page)
 {
 	unsigned int order;
 	unsigned long watermark;
+	struct page *endpage;
 	struct zone *zone;
 
 	BUG_ON(!PageBuddy(page));
@@ -1326,14 +1327,18 @@ int split_free_page(struct page *page)
 	set_page_refcounted(page);
 	split_page(page, order);
 
-	if (order >= pageblock_order - 1) {
-		struct page *endpage = page + (1 << order) - 1;
-		for (; page < endpage; page += pageblock_nr_pages)
-			if (!is_pageblock_cma(page))
-				set_pageblock_migratetype(page,
-							  MIGRATE_MOVABLE);
+	if (order < pageblock_order - 1)
+		goto done;
+
+	endpage = page + (1 << order) - 1;
+	for (; page < endpage; page += pageblock_nr_pages) {
+		int mt = get_pageblock_migratetype(page);
+		/* Don't change CMA nor ISOLATE */
+		if (!is_migrate_cma(mt) && mt != MIGRATE_ISOLATE)
+			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 	}
 
+done:
 	return 1 << order;
 }
 
@@ -5723,57 +5728,76 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
-unsigned long alloc_contig_freed_pages(unsigned long start, unsigned long end,
-				       gfp_t flag)
+/**
+ * isolate_freepages_range() - isolate free pages, must hold zone->lock.
+ * @zone:	Zone pages are in.
+ * @start:	The first PFN to start isolating.
+ * @end:	The one-past-last PFN.
+ * @freelist:	A list to save isolated pages to.
+ * @scannedp:	Optional pointer where to save number of scanned pages.
+ *
+ * If @freelist is not provided, holes in range (either non-free pages
+ * or invalid PFN) are considered an error and function undos its
+ * actions and returns zero.
+ *
+ * If @freelist is provided, function will simply skip non-free and
+ * missing pages and put only the ones isolated on the list.  It will
+ * also call trace_mm_compaction_isolate_freepages() at the end.
+ *
+ * Returns number of isolated pages.  This may be more then end-start
+ * if end fell in a middle of a free page.
+ */
+unsigned isolate_freepages_range(struct zone *zone,
+				 unsigned long start, unsigned long end,
+				 struct list_head *freelist, unsigned *scannedp)
 {
-	unsigned long pfn = start, count;
+	unsigned nr_scanned = 0, total_isolated = 0;
+	unsigned long pfn = start;
 	struct page *page;
-	struct zone *zone;
-	int order;
 
 	VM_BUG_ON(!pfn_valid(start));
-	page = pfn_to_page(start);
-	zone = page_zone(page);
 
-	spin_lock_irq(&zone->lock);
+	/* Isolate free pages. This assumes the block is valid */
+	page = pfn_to_page(pfn);
+	while (pfn < end) {
+		unsigned isolated = 1;
 
-	for (;;) {
-		VM_BUG_ON(!page_count(page) || !PageBuddy(page) ||
-			  page_zone(page) != zone);
+		VM_BUG_ON(page_zone(page) != zone);
 
-		list_del(&page->lru);
-		order = page_order(page);
-		count = 1UL << order;
-		zone->free_area[order].nr_free--;
-		rmv_page_order(page);
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -(long)count);
+		if (!pfn_valid_within(blockpfn))
+			goto skip;
+		++nr_scanned;
 
-		pfn += count;
-		if (pfn >= end)
-			break;
-		VM_BUG_ON(!pfn_valid(pfn));
-
-		if (zone_pfn_same_memmap(pfn - count, pfn))
-			page += count;
-		else
-			page = pfn_to_page(pfn);
-	}
+		if (!PageBuddy(page)) {
+skip:
+			if (freelist)
+				goto next;
+			for (; start < pfn; ++start)
+				__free_page(pfn_to_page(pfn));
+			return 0;
+		}
 
-	spin_unlock_irq(&zone->lock);
+		/* Found a free page, break it into order-0 pages */
+		isolated = split_free_page(page);
+		total_isolated += isolated;
+		if (freelist) {
+			struct page *p = page;
+			unsigned i = isolated;
+			for (; i--; ++page)
+				list_add(&p->lru, freelist);
+		}
 
-	/* After this, pages in the range can be freed one be one */
-	count = pfn - start;
-	pfn = start;
-	for (page = pfn_to_page(pfn); count; --count) {
-		prep_new_page(page, 0, flag);
-		++pfn;
-		if (likely(zone_pfn_same_memmap(pfn - 1, pfn)))
-			++page;
+next:		/* Advance to the next page */
+		pfn += isolated;
+		if (zone_pfn_same_memmap(pfn - isolated, pfn))
+			page += isolated;
 		else
 			page = pfn_to_page(pfn);
 	}
 
-	return pfn;
+	if (scannedp)
+		*scannedp = nr_scanned;
+	return total_isolated;
 }
 
 static unsigned long pfn_to_maxpage(unsigned long pfn)
@@ -5837,7 +5861,6 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
  * alloc_contig_range() -- tries to allocate given range of pages
  * @start:	start PFN to allocate
  * @end:	one-past-the-last PFN to allocate
- * @flags:	flags passed to alloc_contig_freed_pages().
  * @migratetype:	migratetype of the underlaying pageblocks (either
  *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
  *			in range must have the same migratetype and it must
@@ -5853,9 +5876,10 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
  * need to be freed with free_contig_pages().
  */
 int alloc_contig_range(unsigned long start, unsigned long end,
-		       gfp_t flags, unsigned migratetype)
+		       unsigned migratetype)
 {
 	unsigned long outer_start, outer_end;
+	struct zone *zone;
 	int ret;
 
 	/*
@@ -5910,7 +5934,17 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 			return -EINVAL;
 
 	outer_start = start & (~0UL << ret);
-	outer_end   = alloc_contig_freed_pages(outer_start, end, flags);
+
+	zone = page_zone(pfn_to_page(outer_start));
+	spin_lock_irq(&zone->lock);
+	outer_end = isolate_freepages_range(zone, outer_start, end, NULL, NULL);
+	spin_unlock_irq(&zone->lock);
+
+	if (!outer_end) {
+		ret = -EBUSY;
+		goto done;
+	}
+	outer_end += outer_start;
 
 	/* Free head and tail (if any) */
 	if (start != outer_start)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
