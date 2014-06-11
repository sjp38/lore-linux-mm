Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id ED85A6B0164
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 10:56:54 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so4320803wgh.2
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 07:56:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si15731527wiz.23.2014.06.11.07.56.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 07:56:53 -0700 (PDT)
Message-ID: <53986E31.7090500@suse.cz>
Date: Wed, 11 Jun 2014 16:56:49 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 09/10] mm, compaction: try to capture the just-created
 high-order freepage
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-9-git-send-email-vbabka@suse.cz>
In-Reply-To: <1402305982-6928-9-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/09/2014 11:26 AM, Vlastimil Babka wrote:
> Compaction uses watermark checking to determine if it succeeded in creating
> a high-order free page. My testing has shown that this is quite racy and it
> can happen that watermark checking in compaction succeeds, and moments later
> the watermark checking in page allocation fails, even though the number of
> free pages has increased meanwhile.
> 
> It should be more reliable if direct compaction captured the high-order free
> page as soon as it detects it, and pass it back to allocation. This would
> also reduce the window for somebody else to allocate the free page.
> 
> This has been already implemented by 1fb3f8ca0e92 ("mm: compaction: capture a
> suitable high-order page immediately when it is made available"), but later
> reverted by 8fb74b9f ("mm: compaction: partially revert capture of suitable
> high-order page") due to flaws.
> 
> This patch differs from the previous attempt in two aspects:
> 
> 1) The previous patch scanned free lists to capture the page. In this patch,
>     only the cc->order aligned block that the migration scanner just finished
>     is considered, but only if pages were actually isolated for migration in
>     that block. Tracking cc->order aligned blocks also has benefits for the
>     following patch that skips blocks where non-migratable pages were found.
> 
> 2) In this patch, the isolated free page is allocated through extending
>     get_page_from_freelist() and buffered_rmqueue(). This ensures that it gets
>     all operations such as prep_new_page() and page->pfmemalloc setting that
>     was missing in the previous attempt, zone statistics are updated etc.
> 
> Evaluation is pending.

Uh, so if anyone wants to test it, here's a fixed version, as initial evaluation
showed it does not actually capture anything (which should not affect patch 10/10
though) and debugging this took a while.

- for pageblock_order (i.e. THP), capture was never attempted, as the for cycle
  in isolate_migratepages_range() has ended right before the
  low_pfn == next_capture_pfn check
- lru_add_drain() has to be done before pcplists drain. This made a big difference
  (~50 successful captures -> ~1300 successful captures)
  Note that __alloc_pages_direct_compact() is missing lru_add_drain() as well, and
  all the existing watermark-based compaction termination decisions (which happen
  before the drain in __alloc_pages_direct_compact()) don't do any draining at all.
  
-----8<-----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 28 May 2014 17:05:18 +0200
Subject: [PATCH fixed 09/10] mm, compaction: try to capture the just-created
 high-order freepage

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
 include/linux/compaction.h |   5 ++-
 mm/compaction.c            | 103 +++++++++++++++++++++++++++++++++++++++++++--
 mm/internal.h              |   2 +
 mm/page_alloc.c            |  69 ++++++++++++++++++++++++------
 4 files changed, 161 insertions(+), 18 deletions(-)

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
index d1e30ba..2988758 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -541,6 +541,16 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	const isolate_mode_t mode = (cc->mode == MIGRATE_ASYNC ?
 					ISOLATE_ASYNC_MIGRATE : 0) |
 				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
+	unsigned long capture_pfn = 0;   /* current candidate for capturing */
+	unsigned long next_capture_pfn = 0; /* next candidate for capturing */
+
+	if (cc->order > PAGE_ALLOC_COSTLY_ORDER
+		&& gfpflags_to_migratetype(cc->gfp_mask) == MIGRATE_MOVABLE
+			&& cc->order <= pageblock_order) {
+		/* This may be outside the zone, but we check that later */
+		capture_pfn = low_pfn & ~((1UL << cc->order) - 1);
+		next_capture_pfn = ALIGN(low_pfn + 1, (1UL << cc->order));
+	}
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -563,6 +573,19 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
+		if (low_pfn == next_capture_pfn) {
+			/*
+			 * We have a capture candidate if we isolated something
+			 * during the last cc->order aligned block of pages.
+			 */
+			if (nr_isolated && capture_pfn >= zone->zone_start_pfn)
+				break;
+
+			/* Prepare for a new capture candidate */
+			capture_pfn = next_capture_pfn;
+			next_capture_pfn += (1UL << cc->order);
+		}
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -582,6 +605,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		if ((low_pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
 			if (!pfn_valid(low_pfn)) {
 				low_pfn += MAX_ORDER_NR_PAGES - 1;
+				if (next_capture_pfn)
+					next_capture_pfn = low_pfn + 1;
 				continue;
 			}
 		}
@@ -639,8 +664,12 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
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
 
@@ -673,6 +702,9 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			if (!locked)
 				goto next_pageblock;
 			low_pfn += (1 << compound_order(page)) - 1;
+			if (next_capture_pfn)
+				next_capture_pfn =
+					ALIGN(low_pfn + 1, (1UL << cc->order));
 			continue;
 		}
 
@@ -697,6 +729,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 				continue;
 			if (PageTransHuge(page)) {
 				low_pfn += (1 << compound_order(page)) - 1;
+				next_capture_pfn = low_pfn + 1;
 				continue;
 			}
 		}
@@ -728,9 +761,20 @@ isolate_success:
 
 next_pageblock:
 		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
+		if (next_capture_pfn)
+			next_capture_pfn = low_pfn + 1;
 	}
 
 	/*
+	 * For cases when next_capture_pfn == end_pfn, such as end of
+	 * pageblock, we couldn't have determined capture candidate inside
+	 * the for cycle, so we have to do it here.
+	 */
+	if (low_pfn == next_capture_pfn && nr_isolated
+			&& capture_pfn >= zone->zone_start_pfn)
+		cc->capture_page = pfn_to_page(capture_pfn);
+
+	/*
 	 * The PageBuddy() check could have potentially brought us outside
 	 * the range to be scanned.
 	 */
@@ -965,6 +1009,44 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
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
@@ -993,6 +1075,10 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 		return COMPACT_COMPLETE;
 	}
 
+	/* Did we just finish a pageblock that was capture candidate? */
+	if (cc->capture_page && compact_capture_page(cc))
+		return COMPACT_CAPTURED;
+
 	/*
 	 * order == -1 is expected when compacting via
 	 * /proc/sys/vm/compact_memory
@@ -1173,7 +1259,8 @@ out:
 }
 
 static unsigned long compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum migrate_mode mode, bool *contended)
+		gfp_t gfp_mask, enum migrate_mode mode, bool *contended,
+						struct page **captured_page)
 {
 	unsigned long ret;
 	struct compact_control cc = {
@@ -1189,6 +1276,9 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 
 	ret = compact_zone(zone, &cc);
 
+	if (ret == COMPACT_CAPTURED)
+		*captured_page = cc.capture_page;
+
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
 
@@ -1213,7 +1303,8 @@ int sysctl_extfrag_threshold = 500;
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, bool *contended)
+			enum migrate_mode mode, bool *contended,
+			struct page **captured_page)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -1239,9 +1330,13 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
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
index af15461..2b7e5de 100644
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
@@ -155,6 +156,7 @@ struct compact_control {
 					   * contention detected during
 					   * compaction
 					   */
+	struct page *capture_page;	/* Free page captured by compaction */
 };
 
 unsigned long
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a3acb83..6235cad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -954,7 +954,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	return NULL;
 }
 
-
 /*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
@@ -1474,9 +1473,11 @@ static int __isolate_free_page(struct page *page, unsigned int order)
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
@@ -1491,9 +1492,12 @@ static int __isolate_free_page(struct page *page, unsigned int order)
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
@@ -1536,6 +1540,26 @@ int split_free_page(struct page *page)
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
@@ -1544,7 +1568,8 @@ int split_free_page(struct page *page)
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype)
+			gfp_t gfp_flags, int migratetype,
+			struct page *isolated_freepage)
 {
 	unsigned long flags;
 	struct page *page;
@@ -1573,6 +1598,9 @@ again:
 
 		list_del(&page->lru);
 		pcp->count--;
+	} else if (unlikely(isolated_freepage)) {
+		page = isolated_freepage;
+		local_irq_save(flags);
 	} else {
 		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
 			/*
@@ -1588,7 +1616,9 @@ again:
 			WARN_ON_ONCE(order > 1);
 		}
 		spin_lock_irqsave(&zone->lock, flags);
+
 		page = __rmqueue(zone, order, migratetype);
+
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
@@ -1916,7 +1946,8 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int classzone_idx, int migratetype)
+		struct zone *preferred_zone, int classzone_idx, int migratetype,
+		struct page *isolated_freepage)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -1927,6 +1958,13 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
 
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
@@ -2051,7 +2089,7 @@ zonelist_scan:
 
 try_this_zone:
 		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+						gfp_mask, migratetype, NULL);
 		if (page)
 			break;
 this_zone_full:
@@ -2065,6 +2103,7 @@ this_zone_full:
 		goto zonelist_scan;
 	}
 
+got_page:
 	if (page)
 		/*
 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
@@ -2202,7 +2241,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
 		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, classzone_idx, migratetype);
+		preferred_zone, classzone_idx, migratetype, NULL);
 	if (page)
 		goto out;
 
@@ -2241,6 +2280,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
+	struct page *captured_page;
+
 	if (!order)
 		return NULL;
 
@@ -2252,7 +2293,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, mode,
-						contended_compaction);
+						contended_compaction,
+						&captured_page);
 	current->flags &= ~PF_MEMALLOC;
 
 	if (*did_some_progress != COMPACT_SKIPPED) {
@@ -2265,7 +2307,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, classzone_idx, migratetype);
+				preferred_zone, classzone_idx, migratetype,
+				captured_page);
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
 			compaction_defer_reset(preferred_zone, order, true);
@@ -2357,7 +2400,7 @@ retry:
 					zonelist, high_zoneidx,
 					alloc_flags & ~ALLOC_NO_WATERMARKS,
 					preferred_zone, classzone_idx,
-					migratetype);
+					migratetype, NULL);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2387,7 +2430,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+			preferred_zone, classzone_idx, migratetype, NULL);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
@@ -2548,7 +2591,7 @@ rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+			preferred_zone, classzone_idx, migratetype, NULL);
 	if (page)
 		goto got_pg;
 
@@ -2757,7 +2800,7 @@ retry:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, classzone_idx, migratetype);
+			preferred_zone, classzone_idx, migratetype, NULL);
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
