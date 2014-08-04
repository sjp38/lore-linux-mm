Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id D3A3F6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 04:56:04 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so4621755wiv.7
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 01:56:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id br11si12174210wib.104.2014.08.04.01.56.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 01:56:02 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 05/13] mm, compaction: move pageblock checks up from isolate_migratepages_range()
Date: Mon,  4 Aug 2014 10:55:16 +0200
Message-Id: <1407142524-2025-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

isolate_migratepages_range() is the main function of the compaction scanner,
called either on a single pageblock by isolate_migratepages() during regular
compaction, or on an arbitrary range by CMA's __alloc_contig_migrate_range().
It currently perfoms two pageblock-wide compaction suitability checks, and
because of the CMA callpath, it tracks if it crossed a pageblock boundary in
order to repeat those checks.

However, closer inspection shows that those checks are always true for CMA:
- isolation_suitable() is true because CMA sets cc->ignore_skip_hint to true
- migrate_async_suitable() check is skipped because CMA uses sync compaction

We can therefore move the compaction-specific checks to isolate_migratepages()
and simplify isolate_migratepages_range(). Furthermore, we can mimic the
freepage scanner family of functions, which has isolate_freepages_block()
function called both by compaction from isolate_freepages() and by CMA from
isolate_freepages_range(), where each use-case adds own specific glue code.
This allows further code simplification.

Thus, we rename isolate_migratepages_range() to isolate_migratepages_block()
and limit its functionality to a single pageblock (or its subset). For CMA,
a new different isolate_migratepages_range() is created as a CMA-specific
wrapper for the _block() function. The checks specific to compaction are moved
to isolate_migratepages(). As part of the unification of these two families of
functions, we remove the redundant zone parameter where applicable, since zone
pointer is already passed in cc->zone.

Furthermore, going back to compact_zone() and compact_finished() when pageblock
is found unsuitable (now by isolate_migratepages()) is wasteful - the checks
are meant to skip pageblocks quickly. The patch therefore also introduces a
simple loop into isolate_migratepages() so that it does not return immediately
on failed pageblock checks, but keeps going until isolate_migratepages_range()
gets called once. Similarily to isolate_freepages(), the function periodically
checks if it needs to reschedule or abort async compaction.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 235 +++++++++++++++++++++++++++++++++-----------------------
 mm/internal.h   |   4 +-
 mm/page_alloc.c |   3 +-
 3 files changed, 141 insertions(+), 101 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9484a4f..0168786 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -132,7 +132,7 @@ void reset_isolation_suitable(pg_data_t *pgdat)
  */
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool set_unsuitable, bool migrate_scanner)
+			bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
 	unsigned long pfn;
@@ -146,12 +146,7 @@ static void update_pageblock_skip(struct compact_control *cc,
 	if (nr_isolated)
 		return;
 
-	/*
-	 * Only skip pageblocks when all forms of compaction will be known to
-	 * fail in the near future.
-	 */
-	if (set_unsuitable)
-		set_pageblock_skip(page);
+	set_pageblock_skip(page);
 
 	pfn = page_to_pfn(page);
 
@@ -180,7 +175,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
 
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool set_unsuitable, bool migrate_scanner)
+			bool migrate_scanner)
 {
 }
 #endif /* CONFIG_COMPACTION */
@@ -345,8 +340,7 @@ isolate_fail:
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, true,
-				      false);
+		update_pageblock_skip(cc, valid_page, total_isolated, false);
 
 	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
 	if (total_isolated)
@@ -451,40 +445,34 @@ static bool too_many_isolated(struct zone *zone)
 }
 
 /**
- * isolate_migratepages_range() - isolate all migrate-able pages in range.
- * @zone:	Zone pages are in.
+ * isolate_migratepages_block() - isolate all migrate-able pages within
+ *				  a single pageblock
  * @cc:		Compaction control structure.
- * @low_pfn:	The first PFN of the range.
- * @end_pfn:	The one-past-the-last PFN of the range.
- * @unevictable: true if it allows to isolate unevictable pages
+ * @low_pfn:	The first PFN to isolate
+ * @end_pfn:	The one-past-the-last PFN to isolate, within same pageblock
+ * @isolate_mode: Isolation mode to be used.
  *
  * Isolate all pages that can be migrated from the range specified by
- * [low_pfn, end_pfn).  Returns zero if there is a fatal signal
- * pending), otherwise PFN of the first page that was not scanned
- * (which may be both less, equal to or more then end_pfn).
- *
- * Assumes that cc->migratepages is empty and cc->nr_migratepages is
- * zero.
+ * [low_pfn, end_pfn). The range is expected to be within same pageblock.
+ * Returns zero if there is a fatal signal pending, otherwise PFN of the
+ * first page that was not scanned (which may be both less, equal to or more
+ * than end_pfn).
  *
- * Apart from cc->migratepages and cc->nr_migratetypes this function
- * does not modify any cc's fields, in particular it does not modify
- * (or read for that matter) cc->migrate_pfn.
+ * The pages are isolated on cc->migratepages list (not required to be empty),
+ * and cc->nr_migratepages is updated accordingly. The cc->migrate_pfn field
+ * is neither read nor updated.
  */
-unsigned long
-isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
-		unsigned long low_pfn, unsigned long end_pfn, bool unevictable)
+static unsigned long
+isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
+			unsigned long end_pfn, isolate_mode_t isolate_mode)
 {
-	unsigned long last_pageblock_nr = 0, pageblock_nr;
+	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	struct lruvec *lruvec;
 	unsigned long flags;
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
-	bool set_unsuitable = true;
-	const isolate_mode_t mode = (cc->mode == MIGRATE_ASYNC ?
-					ISOLATE_ASYNC_MIGRATE : 0) |
-				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -515,19 +503,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			}
 		}
 
-		/*
-		 * migrate_pfn does not necessarily start aligned to a
-		 * pageblock. Ensure that pfn_valid is called when moving
-		 * into a new MAX_ORDER_NR_PAGES range in case of large
-		 * memory holes within the zone
-		 */
-		if ((low_pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
-			if (!pfn_valid(low_pfn)) {
-				low_pfn += MAX_ORDER_NR_PAGES - 1;
-				continue;
-			}
-		}
-
 		if (!pfn_valid_within(low_pfn))
 			continue;
 		nr_scanned++;
@@ -545,28 +520,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		if (!valid_page)
 			valid_page = page;
 
-		/* If isolation recently failed, do not retry */
-		pageblock_nr = low_pfn >> pageblock_order;
-		if (last_pageblock_nr != pageblock_nr) {
-			int mt;
-
-			last_pageblock_nr = pageblock_nr;
-			if (!isolation_suitable(cc, page))
-				goto next_pageblock;
-
-			/*
-			 * For async migration, also only scan in MOVABLE
-			 * blocks. Async migration is optimistic to see if
-			 * the minimum amount of work satisfies the allocation
-			 */
-			mt = get_pageblock_migratetype(page);
-			if (cc->mode == MIGRATE_ASYNC &&
-			    !migrate_async_suitable(mt)) {
-				set_unsuitable = false;
-				goto next_pageblock;
-			}
-		}
-
 		/*
 		 * Skip if free. page_order cannot be used without zone->lock
 		 * as nothing prevents parallel allocations or buddy merging.
@@ -601,8 +554,11 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 */
 		if (PageTransHuge(page)) {
 			if (!locked)
-				goto next_pageblock;
-			low_pfn += (1 << compound_order(page)) - 1;
+				low_pfn = ALIGN(low_pfn + 1,
+						pageblock_nr_pages) - 1;
+			else
+				low_pfn += (1 << compound_order(page)) - 1;
+
 			continue;
 		}
 
@@ -632,7 +588,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, mode) != 0)
+		if (__isolate_lru_page(page, isolate_mode) != 0)
 			continue;
 
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -651,11 +607,6 @@ isolate_success:
 			++low_pfn;
 			break;
 		}
-
-		continue;
-
-next_pageblock:
-		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
 	}
 
 	acct_isolated(zone, locked, cc);
@@ -668,8 +619,7 @@ next_pageblock:
 	 * if the whole pageblock was scanned without isolating any page.
 	 */
 	if (low_pfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, nr_isolated,
-				      set_unsuitable, true);
+		update_pageblock_skip(cc, valid_page, nr_isolated, true);
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
@@ -680,15 +630,62 @@ next_pageblock:
 	return low_pfn;
 }
 
+/**
+ * isolate_migratepages_range() - isolate migrate-able pages in a PFN range
+ * @cc:        Compaction control structure.
+ * @start_pfn: The first PFN to start isolating.
+ * @end_pfn:   The one-past-last PFN.
+ *
+ * Returns zero if isolation fails fatally due to e.g. pending signal.
+ * Otherwise, function returns one-past-the-last PFN of isolated page
+ * (which may be greater than end_pfn if end fell in a middle of a THP page).
+ */
+unsigned long
+isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
+							unsigned long end_pfn)
+{
+	unsigned long pfn, block_end_pfn;
+
+	/* Scan block by block. First and last block may be incomplete */
+	pfn = start_pfn;
+	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+
+	for (; pfn < end_pfn; pfn = block_end_pfn,
+				block_end_pfn += pageblock_nr_pages) {
+
+		block_end_pfn = min(block_end_pfn, end_pfn);
+
+		/* Skip whole pageblock in case of a memory hole */
+		if (!pfn_valid(pfn))
+			continue;
+
+		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
+							ISOLATE_UNEVICTABLE);
+
+		/*
+		 * In case of fatal failure, release everything that might
+		 * have been isolated in the previous iteration, and signal
+		 * the failure back to caller.
+		 */
+		if (!pfn) {
+			putback_movable_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
+			break;
+		}
+	}
+
+	return pfn;
+}
+
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
 /*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
  */
-static void isolate_freepages(struct zone *zone,
-				struct compact_control *cc)
+static void isolate_freepages(struct compact_control *cc)
 {
+	struct zone *zone = cc->zone;
 	struct page *page;
 	unsigned long block_start_pfn;	/* start of current pageblock */
 	unsigned long block_end_pfn;	/* end of current pageblock */
@@ -806,7 +803,7 @@ static struct page *compaction_alloc(struct page *migratepage,
 	 */
 	if (list_empty(&cc->freepages)) {
 		if (!cc->contended)
-			isolate_freepages(cc->zone, cc);
+			isolate_freepages(cc);
 
 		if (list_empty(&cc->freepages))
 			return NULL;
@@ -840,34 +837,81 @@ typedef enum {
 } isolate_migrate_t;
 
 /*
- * Isolate all pages that can be migrated from the block pointed to by
- * the migrate scanner within compact_control.
+ * Isolate all pages that can be migrated from the first suitable block,
+ * starting at the block pointed to by the migrate scanner pfn within
+ * compact_control.
  */
 static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
+	struct page *page;
+	const isolate_mode_t isolate_mode =
+		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
-	/* Do not scan outside zone boundaries */
-	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
+	/*
+	 * Start at where we last stopped, or beginning of the zone as
+	 * initialized by compact_zone()
+	 */
+	low_pfn = cc->migrate_pfn;
 
 	/* Only scan within a pageblock boundary */
 	end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
 
-	/* Do not cross the free scanner or scan within a memory hole */
-	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
-		cc->migrate_pfn = end_pfn;
-		return ISOLATE_NONE;
-	}
+	/*
+	 * Iterate over whole pageblocks until we find the first suitable.
+	 * Do not cross the free scanner.
+	 */
+	for (; end_pfn <= cc->free_pfn;
+			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
+
+		/*
+		 * This can potentially iterate a massively long zone with
+		 * many pageblocks unsuitable, so periodically check if we
+		 * need to schedule, or even abort async compaction.
+		 */
+		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
+						&& compact_should_abort(cc))
+			break;
+
+		/* Skip whole pageblock in case of a memory hole */
+		if (!pfn_valid(low_pfn))
+			continue;
+
+		page = pfn_to_page(low_pfn);
+
+		/* If isolation recently failed, do not retry */
+		if (!isolation_suitable(cc, page))
+			continue;
+
+		/*
+		 * For async compaction, also only scan in MOVABLE blocks.
+		 * Async compaction is optimistic to see if the minimum amount
+		 * of work satisfies the allocation.
+		 */
+		if (cc->mode == MIGRATE_ASYNC &&
+		    !migrate_async_suitable(get_pageblock_migratetype(page)))
+			continue;
+
+		/* Perform the isolation */
+		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
+								isolate_mode);
+
+		if (!low_pfn || cc->contended)
+			return ISOLATE_ABORT;
 
-	/* Perform the isolation */
-	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn, false);
-	if (!low_pfn || cc->contended)
-		return ISOLATE_ABORT;
+		/*
+		 * Either we isolated something and proceed with migration. Or
+		 * we failed and compact_zone should decide if we should
+		 * continue or not.
+		 */
+		break;
+	}
 
+	/* Record where migration scanner will be restarted */
 	cc->migrate_pfn = low_pfn;
 
-	return ISOLATE_SUCCESS;
+	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
 static int compact_finished(struct zone *zone,
@@ -1040,9 +1084,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			;
 		}
 
-		if (!cc->nr_migratepages)
-			continue;
-
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				compaction_free, (unsigned long)cc, cc->mode,
 				MR_COMPACTION);
diff --git a/mm/internal.h b/mm/internal.h
index a1b651b..5a0738f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -154,8 +154,8 @@ unsigned long
 isolate_freepages_range(struct compact_control *cc,
 			unsigned long start_pfn, unsigned long end_pfn);
 unsigned long
-isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
-	unsigned long low_pfn, unsigned long end_pfn, bool unevictable);
+isolate_migratepages_range(struct compact_control *cc,
+			   unsigned long low_pfn, unsigned long end_pfn);
 
 #endif
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f1586bc..5a1e0de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6292,8 +6292,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 
 		if (list_empty(&cc->migratepages)) {
 			cc->nr_migratepages = 0;
-			pfn = isolate_migratepages_range(cc->zone, cc,
-							 pfn, end, true);
+			pfn = isolate_migratepages_range(cc, pfn, end);
 			if (!pfn) {
 				ret = -EINTR;
 				break;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
