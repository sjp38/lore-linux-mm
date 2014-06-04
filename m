Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6347C6B003A
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 12:12:32 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id r20so8880420wiv.1
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 09:12:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o15si5647926wjq.126.2014.06.04.09.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 09:12:28 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 5/6] mm, compaction: try to capture the just-created high-order freepage
Date: Wed,  4 Jun 2014 18:11:49 +0200
Message-Id: <1401898310-14525-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1401898310-14525-1-git-send-email-vbabka@suse.cz>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com>
 <1401898310-14525-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Compaction uses watermark checking to determine if it succeeded in creating
a high-order free page. My testing has shown that this is quite racy and it
can happen that watermark checking in compaction succeeds, and moments later
the watermark checking in page allocation fails, even though the number of
free pages has increased meanwhile.

It should be more reliable if direct compaction captured the high-order free
page as soon as it detects it, and pass it back to allocation. This would
also reduce the window for somebody else to allocate the free page.

This has been already implemented by 1fb3f8ca0e92 ("mm: compaction: capture a
suitable high-order page immediately when it is made available"), but later
reverted by 8fb74b9f ("mm: compaction: partially revert capture of suitable
high-order page") due to flaws.

This patch differs from the previous attempt in two aspects:

1) The previous patch scanned free lists to capture the page. In this patch,
   only the cc->order aligned block that the migration scanner just finished
   is considered, but only if pages were actually isolated for migration in
   that block. Tracking cc->order aligned blocks also has benefits for the
   following patch that skips blocks where non-migratable pages were found.

2) In this patch, the isolated free page is allocated through extending
   get_page_from_freelist() and buffered_rmqueue(). This ensures that it gets
   all operations such as prep_new_page() and page->pfmemalloc setting that
   was missing in the previous attempt, zone statistics are updated etc.

Evaluation is pending.

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
 include/linux/compaction.h |  5 ++-
 mm/compaction.c            | 85 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/internal.h              |  2 ++
 mm/page_alloc.c            | 70 ++++++++++++++++++++++++++++++--------
 4 files changed, 144 insertions(+), 18 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 01e3132..69579f5 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -10,6 +10,8 @@
 #define COMPACT_PARTIAL		2
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	3
+/* Captured a high-order free page in direct compaction */
+#define COMPACT_CAPTURED	4
 
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
@@ -22,7 +24,8 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			enum migrate_mode mode, bool *contended);
+			enum migrate_mode mode, bool *contended,
+			struct page **captured_page);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
diff --git a/mm/compaction.c b/mm/compaction.c
index 3dce5a7..5909a88 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -555,6 +555,16 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	const isolate_mode_t mode = (cc->mode == MIGRATE_ASYNC ?
 					ISOLATE_ASYNC_MIGRATE : 0) |
 				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
+	unsigned long capture_pfn = 0;   /* current candidate for capturing */
+	unsigned long next_capture_pfn = 0; /* next candidate for capturing */
+
+	if (cc->order > PAGE_ALLOC_COSTLY_ORDER
+			&& cc->migratetype == MIGRATE_MOVABLE
+			&& cc->order <= pageblock_order) {
+		/* This may be outside the zone, but we check that later */
+		capture_pfn = low_pfn & ~((1UL << cc->order) - 1);
+		next_capture_pfn = ALIGN(low_pfn + 1, (1UL << cc->order));
+	}
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -577,6 +587,19 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
+		if (low_pfn == next_capture_pfn) {
+			/*
+			 * We have a capture candidate if we isolated something
+			 * during the last cc->order aligned block of pages
+			 */
+			if (nr_isolated && capture_pfn >= zone->zone_start_pfn) {
+				cc->capture_page = pfn_to_page(capture_pfn);
+				break;
+			}
+			capture_pfn = next_capture_pfn;
+			next_capture_pfn += (1UL << cc->order);
+		}
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -596,6 +619,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		if ((low_pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
 			if (!pfn_valid(low_pfn)) {
 				low_pfn += MAX_ORDER_NR_PAGES - 1;
+				if (next_capture_pfn)
+					next_capture_pfn = low_pfn + 1;
 				continue;
 			}
 		}
@@ -682,6 +707,9 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			if (!locked)
 				goto next_pageblock;
 			low_pfn += (1 << compound_order(page)) - 1;
+			if (next_capture_pfn)
+				next_capture_pfn =
+					ALIGN(low_pfn + 1, (1UL << cc->order));
 			continue;
 		}
 
@@ -707,6 +735,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			continue;
 		if (PageTransHuge(page)) {
 			low_pfn += (1 << compound_order(page)) - 1;
+			next_capture_pfn = low_pfn + 1;
 			continue;
 		}
 
@@ -738,6 +767,8 @@ isolate_success:
 
 next_pageblock:
 		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
+		if (next_capture_pfn)
+			next_capture_pfn = low_pfn + 1;
 	}
 
 	/*
@@ -975,6 +1006,41 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
 }
 
+/*
+ * When called, cc->capture_page is just a candidate. This function will either
+ * successfully capture the page, or reset it to NULL.
+ */
+static bool compact_capture_page(struct compact_control *cc)
+{
+	struct page *page = cc->capture_page;
+
+	/* Unsafe check if it's worth to try acquiring the zone->lock at all */
+	if (PageBuddy(page) && page_order_unsafe(page) >= cc->order)
+		goto try_capture;
+
+	/*
+	 * There's a good chance that we have just put free pages on this CPU's
+	 * pcplists after the page migration. Drain them to allow merging.
+	 */
+	get_cpu();
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
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
@@ -1003,6 +1069,10 @@ static int compact_finished(struct zone *zone,
 		return COMPACT_COMPLETE;
 	}
 
+	/* Did we just finish a pageblock that was capture candidate? */
+	if (cc->capture_page && compact_capture_page(cc))
+		return COMPACT_CAPTURED;
+
 	/*
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
@@ -1181,7 +1251,8 @@ out:
 }
 
 static unsigned long compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum migrate_mode mode, bool *contended)
+		gfp_t gfp_mask, enum migrate_mode mode, bool *contended,
+						struct page **captured_page)
 {
 	unsigned long ret;
 	struct compact_control cc = {
@@ -1197,6 +1268,9 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 
 	ret = compact_zone(zone, &cc);
 
+	if (ret == COMPACT_CAPTURED)
+		*captured_page = cc.capture_page;
+
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
 
@@ -1220,7 +1294,8 @@ int sysctl_extfrag_threshold = 500;
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, bool *contended)
+			enum migrate_mode mode, bool *contended,
+			struct page **captured_page)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -1246,9 +1321,13 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		int status;
 
 		status = compact_zone_order(zone, order, gfp_mask, mode,
-						contended);
+						contended, captured_page);
 		rc = max(status, rc);
 
+		/* If we captured a page, stop compacting */
+		if (*captured_page)
+			break;
+
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
 				      alloc_flags))
diff --git a/mm/internal.h b/mm/internal.h
index 6aa1f74..5f223d3 100644
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
 					 * need_resched() true during async
 					 * compaction
 					 */
+	struct page *capture_page;	/* Free page captured by compaction */
 };
 
 unsigned long
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b3dd64..3788162 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -937,7 +937,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	return NULL;
 }
 
-
 /*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
@@ -1453,9 +1452,11 @@ static int __isolate_free_page(struct page *page, unsigned int order)
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
@@ -1470,9 +1471,12 @@ static int __isolate_free_page(struct page *page, unsigned int order)
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
@@ -1515,6 +1519,26 @@ int split_free_page(struct page *page)
 	return nr_pages;
 }
 
+bool capture_free_page(struct page *page, unsigned int order)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+	bool ret;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	if (!PageBuddy(page) || page_order(page) < order) {
+		ret = false;
+		goto out;
+	}
+
+	ret = __isolate_free_page(page, order);
+
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+	return ret;
+}
+
 /*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
@@ -1523,7 +1547,7 @@ int split_free_page(struct page *page)
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, int order, gfp_t gfp_flags,
-			int migratetype)
+			int migratetype, struct page *isolated_freepage)
 {
 	unsigned long flags;
 	struct page *page;
@@ -1552,6 +1576,9 @@ again:
 
 		list_del(&page->lru);
 		pcp->count--;
+	} else if (unlikely(isolated_freepage)) {
+		page = isolated_freepage;
+		local_irq_save(flags);
 	} else {
 		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
 			/*
@@ -1567,7 +1594,9 @@ again:
 			WARN_ON_ONCE(order > 1);
 		}
 		spin_lock_irqsave(&zone->lock, flags);
+
 		page = __rmqueue(zone, order, migratetype);
+
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
@@ -1907,7 +1936,7 @@ static inline void init_zone_allows_reclaim(int nid)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int migratetype)
+		struct zone *preferred_zone, int migratetype, struct page *isolated_freepage)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -1916,8 +1945,17 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	unsigned long mark;
 
 	classzone_idx = zone_idx(preferred_zone);
+
+	if (isolated_freepage) {
+		zone = page_zone(isolated_freepage);
+		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask,
+						migratetype, isolated_freepage);
+		goto got_page;
+	}
+
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -1925,7 +1963,6 @@ zonelist_scan:
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
-		unsigned long mark;
 
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
@@ -2040,7 +2077,7 @@ zonelist_scan:
 
 try_this_zone:
 		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+						gfp_mask, migratetype, NULL);
 		if (page)
 			break;
 this_zone_full:
@@ -2054,6 +2091,7 @@ this_zone_full:
 		goto zonelist_scan;
 	}
 
+got_page:
 	if (page)
 		/*
 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
@@ -2191,7 +2229,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
 		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, migratetype);
+		preferred_zone, migratetype, NULL);
 	if (page)
 		goto out;
 
@@ -2230,6 +2268,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
+	struct page *captured_page;
+
 	if (!order)
 		return NULL;
 
@@ -2241,7 +2281,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, mode,
-						contended_compaction);
+						contended_compaction,
+						&captured_page);
 	current->flags &= ~PF_MEMALLOC;
 
 	if (*did_some_progress != COMPACT_SKIPPED) {
@@ -2254,7 +2295,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, captured_page);
+
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
 			compaction_defer_reset(preferred_zone, order, true);
@@ -2344,7 +2386,7 @@ retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, migratetype);
+					preferred_zone, migratetype, NULL);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2374,7 +2416,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, NULL);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
@@ -2532,7 +2574,7 @@ rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, NULL);
 	if (page)
 		goto got_pg;
 
@@ -2736,7 +2778,7 @@ retry:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, NULL);
 	if (unlikely(!page)) {
 		/*
 		 * The first pass makes sure allocations are spread
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
