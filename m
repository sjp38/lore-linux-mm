Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id DCF456B009B
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:49:05 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so6257521wiv.1
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:49:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si3505652wix.3.2014.07.16.06.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:48:58 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 14/15] mm, compaction: try to capture the just-created high-order freepage
Date: Wed, 16 Jul 2014 15:48:22 +0200
Message-Id: <1405518503-27687-15-git-send-email-vbabka@suse.cz>
In-Reply-To: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Compaction uses watermark checking to determine if it succeeded in creating
a high-order free page. My testing has shown that this is quite racy and it
can happen that watermark checking in compaction succeeds, and moments later
the watermark checking in page allocation fails, even though the number of
free pages has increased meanwhile.

It should be more reliable if direct compaction captured the high-order free
page as soon as it detects it, and pass it back to allocation. This would
also reduce the window for somebody else to allocate the free page.

Capture has been implemented before by 1fb3f8ca0e92 ("mm: compaction: capture
a suitable high-order page immediately when it is made available"), but later
reverted by 8fb74b9f ("mm: compaction: partially revert capture of suitable
high-order page") due to a bug.

This patch differs from the previous attempt in two aspects:

1) The previous patch scanned free lists to capture the page. In this patch,
   only the cc->order aligned block that the migration scanner just finished
   is considered, but only if pages were actually isolated for migration in
   that block. Tracking cc->order aligned blocks also has benefits for the
   following patch that skips blocks where non-migratable pages were found.

2) The operations done in buffered_rmqueue() and get_page_from_freelist() are
   closely followed so that page capture mimics normal page allocation as much
   as possible. This includes operations such as prep_new_page() and
   page->pfmemalloc setting (that was missing in the previous attempt), zone
   statistics are updated etc. Due to subtleties with IRQ disabling and
   enabling this cannot be simply factored out from the normal allocation
   functions without affecting the fastpath.

This patch has tripled compaction success rates (as recorded in vmstat) in
stress-highalloc mmtests benchmark, although allocation success rates increased
only by a few percent. Closer inspection shows that due to the racy watermark
checking and lack of lru_add_drain(), the allocations that resulted in direct
compactions were often failing, but later allocations succeeeded in the fast
path. So the benefit of the patch to allocation success rates may be limited,
but it improves the fairness in the sense that whoever spent the time
compacting has a higher change of benefitting from it, and also can stop
compacting sooner, as page availability is detected immediately. With better
success detection, the contribution of compaction to high-order allocation
success success rates is also no longer understated by the vmstats.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/compaction.h |   8 ++-
 mm/compaction.c            | 118 ++++++++++++++++++++++++++++++++++++++++-----
 mm/internal.h              |   4 +-
 mm/page_alloc.c            |  81 ++++++++++++++++++++++++++-----
 4 files changed, 185 insertions(+), 26 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 60bdf8d..b83c142 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -12,6 +12,8 @@
 #define COMPACT_PARTIAL		3
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	4
+/* Captured a high-order free page in direct compaction */
+#define COMPACT_CAPTURED	5
 
 /* Used to signal whether compaction detected need_sched() or lock contention */
 /* No contention detected */
@@ -33,7 +35,8 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			enum migrate_mode mode, int *contended,
-			struct zone **candidate_zone);
+			struct zone **candidate_zone,
+			struct page **captured_page);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
@@ -103,7 +106,8 @@ static inline bool compaction_restarting(struct zone *zone, int order)
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
 			enum migrate_mode mode, int *contended,
-			struct zone **candidate_zone)
+			struct zone **candidate_zone,
+			struct page **captured_page);
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index 279c0b0..4fe091c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -548,6 +548,7 @@ static bool too_many_isolated(struct zone *zone)
  * @low_pfn:	The first PFN to isolate
  * @end_pfn:	The one-past-the-last PFN to isolate, within same pageblock
  * @isolate_mode: Isolation mode to be used.
+ * @capture:    True if page capturing is allowed
  *
  * Isolate all pages that can be migrated from the range specified by
  * [low_pfn, end_pfn). The range is expected to be within same pageblock.
@@ -561,7 +562,8 @@ static bool too_many_isolated(struct zone *zone)
  */
 static unsigned long
 isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
-			unsigned long end_pfn, isolate_mode_t isolate_mode)
+			unsigned long end_pfn, isolate_mode_t isolate_mode,
+			bool capture)
 {
 	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
@@ -570,6 +572,14 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long flags;
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
+	unsigned long capture_pfn = 0;   /* current candidate for capturing */
+	unsigned long next_capture_pfn = 0; /* next candidate for capturing */
+
+	if (cc->order > 0 && cc->order <= pageblock_order && capture) {
+		/* This may be outside the zone, but we check that later */
+		capture_pfn = low_pfn & ~((1UL << cc->order) - 1);
+		next_capture_pfn = ALIGN(low_pfn + 1, (1UL << cc->order));
+	}
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -591,7 +601,27 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		return 0;
 
 	/* Time to isolate some pages for migration */
-	for (; low_pfn < end_pfn; low_pfn++) {
+	for (; low_pfn <= end_pfn; low_pfn++) {
+		if (low_pfn == next_capture_pfn) {
+			/*
+			 * We have a capture candidate if we isolated something
+			 * during the last cc->order aligned block of pages.
+			 */
+			if (nr_isolated &&
+					capture_pfn >= zone->zone_start_pfn) {
+				cc->capture_page = pfn_to_page(capture_pfn);
+				break;
+			}
+
+			/* Prepare for a new capture candidate */
+			capture_pfn = next_capture_pfn;
+			next_capture_pfn += (1UL << cc->order);
+		}
+
+		/* We check that here, in case low_pfn == next_capture_pfn */
+		if (low_pfn == end_pfn)
+			break;
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -625,8 +655,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			 * a valid page order. Consider only values in the
 			 * valid order range to prevent low_pfn overflow.
 			 */
-			if (freepage_order > 0 && freepage_order < MAX_ORDER)
+			if (freepage_order > 0 && freepage_order < MAX_ORDER) {
 				low_pfn += (1UL << freepage_order) - 1;
+				if (next_capture_pfn)
+					next_capture_pfn = ALIGN(low_pfn + 1,
+							(1UL << cc->order));
+			}
 			continue;
 		}
 
@@ -662,6 +696,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			else
 				low_pfn += (1 << compound_order(page)) - 1;
 
+			if (next_capture_pfn)
+				next_capture_pfn =
+					ALIGN(low_pfn + 1, (1UL << cc->order));
 			continue;
 		}
 
@@ -686,6 +723,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 				continue;
 			if (PageTransHuge(page)) {
 				low_pfn += (1 << compound_order(page)) - 1;
+				if (next_capture_pfn)
+					next_capture_pfn = ALIGN(low_pfn + 1,
+							(1UL << cc->order));
 				continue;
 			}
 		}
@@ -770,7 +810,7 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 			continue;
 
 		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
-							ISOLATE_UNEVICTABLE);
+						ISOLATE_UNEVICTABLE, false);
 
 		/*
 		 * In case of fatal failure, release everything that might
@@ -958,7 +998,7 @@ typedef enum {
  * compact_control.
  */
 static isolate_migrate_t isolate_migratepages(struct zone *zone,
-					struct compact_control *cc)
+			struct compact_control *cc, const int migratetype)
 {
 	unsigned long low_pfn, end_pfn;
 	struct page *page;
@@ -980,6 +1020,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	 */
 	for (; end_pfn <= cc->free_pfn;
 			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
+		int pageblock_mt;
 
 		/*
 		 * This can potentially iterate a massively long zone with
@@ -1003,13 +1044,14 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		 * Async compaction is optimistic to see if the minimum amount
 		 * of work satisfies the allocation.
 		 */
+		pageblock_mt = get_pageblock_migratetype(page);
 		if (cc->mode == MIGRATE_ASYNC &&
-		    !migrate_async_suitable(get_pageblock_migratetype(page)))
+					!migrate_async_suitable(pageblock_mt))
 			continue;
 
 		/* Perform the isolation */
 		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
-								isolate_mode);
+							isolate_mode, true);
 
 		if (!low_pfn || cc->contended)
 			return ISOLATE_ABORT;
@@ -1028,6 +1070,44 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
+/*
+ * When called, cc->capture_page is just a candidate. This function will either
+ * successfully capture the page, or reset it to NULL.
+ */
+static bool compact_capture_page(struct compact_control *cc)
+{
+	struct page *page = cc->capture_page;
+	int cpu;
+
+	/* Unsafe check if it's worth to try acquiring the zone->lock at all */
+	if (PageBuddy(page) && page_order_unsafe(page) >= cc->order)
+		goto try_capture;
+
+	/*
+	 * There's a good chance that we have just put free pages on this CPU's
+	 * lru cache and pcplists after the page migrations. Drain them to
+	 * allow merging.
+	 */
+	cpu = get_cpu();
+	lru_add_drain_cpu(cpu);
+	drain_local_pages(NULL);
+	put_cpu();
+
+	/* Did the draining help? */
+	if (PageBuddy(page) && page_order_unsafe(page) >= cc->order)
+		goto try_capture;
+
+	goto fail;
+
+try_capture:
+	if (capture_free_page(page, cc->order))
+		return true;
+
+fail:
+	cc->capture_page = NULL;
+	return false;
+}
+
 static int compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
@@ -1056,6 +1136,10 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 		return COMPACT_COMPLETE;
 	}
 
+	/* Did we just finish a pageblock that was capture candidate? */
+	if (cc->capture_page && compact_capture_page(cc))
+		return COMPACT_CAPTURED;
+
 	/*
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
@@ -1188,7 +1272,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 						COMPACT_CONTINUE) {
 		int err;
 
-		switch (isolate_migratepages(zone, cc)) {
+		switch (isolate_migratepages(zone, cc, migratetype)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_PARTIAL;
 			putback_movable_pages(&cc->migratepages);
@@ -1233,7 +1317,8 @@ out:
 }
 
 static unsigned long compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum migrate_mode mode, int *contended)
+		gfp_t gfp_mask, enum migrate_mode mode, int *contended,
+						struct page **captured_page)
 {
 	unsigned long ret;
 	struct compact_control cc = {
@@ -1250,6 +1335,9 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 	ret = compact_zone(zone, &cc);
 	*contended = cc.contended;
 
+	if (ret == COMPACT_CAPTURED)
+		*captured_page = cc.capture_page;
+
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
 
@@ -1268,13 +1356,15 @@ int sysctl_extfrag_threshold = 500;
  * @contended: Return value that determines if compaction was aborted due to 
  *	       need_resched() or lock contention
  * @candidate_zone: Return the zone where we think allocation should succeed
+ * @captured_page: If successful, return the page captured during compaction
  *
  * This is the main entry point for direct page compaction.
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
 			enum migrate_mode mode, int *contended,
-			struct zone **candidate_zone)
+			struct zone **candidate_zone,
+			struct page **captured_page)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -1305,7 +1395,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			continue;
 
 		status = compact_zone_order(zone, order, gfp_mask, mode,
-							&zone_contended);
+					&zone_contended, captured_page);
 		rc = max(status, rc);
 		/*
 		 * It takes at least one zone that wasn't lock contended
@@ -1314,6 +1404,12 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		all_zones_lock_contended &=
 			(zone_contended == COMPACT_CONTENDED_LOCK);
 
+		/* If we captured a page, stop compacting */
+		if (*captured_page) {
+			*candidate_zone = zone;
+			break;
+		}
+
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
 				      alloc_flags)) {
diff --git a/mm/internal.h b/mm/internal.h
index 8293040..9e659fcd 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -110,6 +110,7 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
+extern bool capture_free_page(struct page *page, unsigned int order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
 #endif
@@ -148,6 +149,7 @@ struct compact_control {
 					 * contention detected during
 					 * compaction
 					 */
+	struct page *capture_page;	/* Free page captured by compaction */
 };
 
 unsigned long
@@ -155,7 +157,7 @@ isolate_freepages_range(struct compact_control *cc,
 			unsigned long start_pfn, unsigned long end_pfn);
 unsigned long
 isolate_migratepages_range(struct compact_control *cc,
-			   unsigned long low_pfn, unsigned long end_pfn);
+			unsigned long low_pfn, unsigned long end_pfn);
 
 #endif
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6f1c6e6..6f2fbfc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1483,9 +1483,11 @@ static int __isolate_free_page(struct page *page, unsigned int order)
 {
 	unsigned long watermark;
 	struct zone *zone;
+	struct free_area *area;
 	int mt;
+	unsigned int freepage_order = page_order(page);
 
-	BUG_ON(!PageBuddy(page));
+	VM_BUG_ON_PAGE((!PageBuddy(page) || freepage_order < order), page);
 
 	zone = page_zone(page);
 	mt = get_pageblock_migratetype(page);
@@ -1500,9 +1502,12 @@ static int __isolate_free_page(struct page *page, unsigned int order)
 	}
 
 	/* Remove page from free list */
+	area = &zone->free_area[freepage_order];
 	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
+	area->nr_free--;
 	rmv_page_order(page);
+	if (freepage_order != order)
+		expand(zone, page, order, freepage_order, area, mt);
 
 	/* Set the pageblock if the isolated page is at least a pageblock */
 	if (order >= pageblock_order - 1) {
@@ -1545,6 +1550,29 @@ int split_free_page(struct page *page)
 	return nr_pages;
 }
 
+bool capture_free_page(struct page *page, unsigned int order)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	if (!PageBuddy(page) || page_order(page) < order
+			|| !__isolate_free_page(page, order)) {
+		spin_unlock_irqrestore(&zone->lock, flags);
+		return false;
+	}
+
+	spin_unlock(&zone->lock);
+
+	/* Mimic what buffered_rmqueue() does */
+	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+	__count_zone_vm_events(PGALLOC, zone, 1 << order);
+	local_irq_restore(flags);
+
+	return true;
+}
+
 /*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
@@ -2251,7 +2279,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	unsigned long *did_some_progress)
 {
 	struct zone *last_compact_zone = NULL;
-	struct page *page;
+	struct page *page = NULL;
 
 	if (!order)
 		return NULL;
@@ -2260,7 +2288,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, mode,
 						contended_compaction,
-						&last_compact_zone);
+						&last_compact_zone, &page);
 	current->flags &= ~PF_MEMALLOC;
 
 	switch (*did_some_progress) {
@@ -2279,14 +2307,43 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	/* Page migration frees to the PCP lists but we want merging */
-	drain_pages(get_cpu());
-	put_cpu();
+	/* Did we capture a page? */
+	if (page) {
+		struct zone *zone;
+		unsigned long flags;
+		/*
+		 * Mimic what buffered_rmqueue() does and capture_new_page()
+		 * has not yet done.
+		 */
+		zone = page_zone(page);
+
+		local_irq_save(flags);
+		zone_statistics(preferred_zone, zone, gfp_mask);
+		local_irq_restore(flags);
 
-	page = get_page_from_freelist(gfp_mask, nodemask,
-			order, zonelist, high_zoneidx,
-			alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+		VM_BUG_ON_PAGE(bad_range(zone, page), page);
+		if (!prep_new_page(page, order, gfp_mask))
+			/* This is normally done in get_page_from_freelist() */
+			page->pfmemalloc = !!(alloc_flags &
+					ALLOC_NO_WATERMARKS);
+		else
+			page = NULL;
+	}
+
+	/* No capture but let's try allocating anyway */
+	if (!page) {
+		/*
+		 * Page migration frees to the PCP lists but we want
+		 * merging
+		 */
+		drain_pages(get_cpu());
+		put_cpu();
+
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
+				zonelist, high_zoneidx,
+				alloc_flags & ~ALLOC_NO_WATERMARKS,
+				preferred_zone, classzone_idx, migratetype);
+	}
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -6303,7 +6360,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 
 		if (list_empty(&cc->migratepages)) {
 			cc->nr_migratepages = 0;
-			pfn = isolate_migratepages_range(cc, pfn, end);
+			pfn = isolate_migratepages_range(cc, pfn, end, false);
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
