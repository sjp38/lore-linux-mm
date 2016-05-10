Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57E2C6B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:42:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so6518166wme.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:42:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si996782wjy.166.2016.05.10.00.37.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:09 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 13/13] mm, compaction: fix and improve watermark handling
Date: Tue, 10 May 2016 09:36:03 +0200
Message-Id: <1462865763-22084-14-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Compaction has been using watermark checks when deciding whether it was
successful, and whether compaction is at all suitable. There are few problems
with these checks.

- __compact_finished() uses low watermark in a check that has to pass if
  the direct compaction is to finish and allocation should succeed. This is
  too pessimistic, as the allocation will typically use min watermark. It
  may happen that during compaction, we drop below the low watermark (due to
  parallel activity), but still form the target high-order page. By checking
  against low watermark, we might needlessly continue compaction. After this
  patch, the check uses direct compactor's alloc_flags to determine the
  watermark, which is effectively the min watermark.

- __compaction_suitable has the same issue in the check whether the allocation
  is already supposed to succeed and we don't need to compact. Fix it the same
  way.

- __compaction_suitable() then checks the low watermark plus a (2 << order) gap
  to decide if there's enough free memory to perform compaction. This check
  uses direct compactor's alloc_flags, but that's wrong. If alloc_flags doesn't
  include ALLOC_CMA, we might fail the check, even though the freepage
  isolation isn't restricted outside of CMA pageblocks. On the other hand,
  alloc_flags may indicate access to memory reserves, making compaction proceed
  and then fail watermark check during freepage isolation, which doesn't pass
  alloc_flags. The fix here is to use fixed ALLOC_CMA flags in the
  __compaction_suitable() check.

- __isolate_free_page uses low watermark check to decide if free page can be
  isolated. It also doesn't use ALLOC_CMA, so add it for the same reasons.

- The use of low watermark checks in __compaction_suitable() and
  __isolate_free_page does perhaps make sense for high-order allocations where
  more freepages increase the chance of success, and we can typically fail
  with some order-0 fallback when the system is struggling. But for low-order
  allocation, forming the page should not be that hard. So using low watermark
  here might just prevent compaction from even trying, and eventually lead to
  OOM killer even if we are above min watermarks. So after this patch, we use
  min watermark for non-costly orders in these checks, by passing the
  alloc_flags parameter to split_page() and __isolate_free_page().

To sum up, after this patch, the kernel should in some situations finish
successful direct compaction sooner, prevent compaction from starting when it's
not needed, proceed with compaction when free memory is in CMA pageblocks, and
for non-costly orders, prevent OOM killing or excessive reclaim when free
memory is between the min and low watermarks.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mm.h  |  2 +-
 mm/compaction.c     | 28 +++++++++++++++++++++++-----
 mm/internal.h       |  3 ++-
 mm/page_alloc.c     | 13 ++++++++-----
 mm/page_isolation.c |  2 +-
 5 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index db8979ce28a3..ce7248022114 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -518,7 +518,7 @@ void __put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
-int split_free_page(struct page *page);
+int split_free_page(struct page *page, unsigned int alloc_flags);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/mm/compaction.c b/mm/compaction.c
index 9bc475dc4c99..207b6c132d6d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -368,6 +368,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	unsigned long flags = 0;
 	bool locked = false;
 	unsigned long blockpfn = *start_pfn;
+	unsigned int alloc_flags;
+
+	/*
+	 * Determine how split_free_page() will check watermarks, in line with
+	 * compaction_suitable(). Pages in CMA pageblocks should be counted
+	 * as free for this purpose as a migratable page is likely movable
+	 */
+	alloc_flags = (cc->order > PAGE_ALLOC_COSTLY_ORDER) ?
+				ALLOC_WMARK_LOW : ALLOC_WMARK_MIN;
+	alloc_flags |= ALLOC_CMA;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -440,7 +450,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		}
 
 		/* Found a free page, break it into order-0 pages */
-		isolated = split_free_page(page);
+		isolated = split_free_page(page, alloc_flags);
 		total_isolated += isolated;
 		for (i = 0; i < isolated; i++) {
 			list_add(&page->lru, freelist);
@@ -1262,7 +1272,7 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 		return COMPACT_CONTINUE;
 
 	/* Compaction run is not finished if the watermark is not met */
-	watermark = low_wmark_pages(zone);
+	watermark = zone->watermark[cc->alloc_flags & ALLOC_WMARK_MASK];
 
 	if (!zone_watermark_ok(zone, cc->order, watermark, cc->classzone_idx,
 							cc->alloc_flags))
@@ -1327,7 +1337,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	if (is_via_compact_memory(order))
 		return COMPACT_CONTINUE;
 
-	watermark = low_wmark_pages(zone);
+	watermark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 	/*
 	 * If watermarks for high-order allocation are already met, there
 	 * should be no need for compaction at all.
@@ -1339,11 +1349,19 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	/*
 	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
 	 * This is because during migration, copies of pages need to be
-	 * allocated and for a short time, the footprint is higher
+	 * allocated and for a short time, the footprint is higher. For
+	 * costly orders, we require low watermark instead of min for
+	 * compaction to proceed to increase its chances. Note that watermark
+	 * and alloc_flags here have to match (or be more pessimistic than)
+	 * the watermark checks done in __isolate_free_page(), and we use the
+	 * direct compactor's classzone_idx to skip over zones where
+	 * lowmem reserves would prevent allocation even if compaction succeeds
 	 */
+	watermark = (order > PAGE_ALLOC_COSTLY_ORDER) ?
+				low_wmark_pages(zone) : min_wmark_pages(zone);
 	watermark += (2UL << order);
 	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
-				 alloc_flags, wmark_target))
+						ALLOC_CMA, wmark_target))
 		return COMPACT_SKIPPED;
 
 	/*
diff --git a/mm/internal.h b/mm/internal.h
index 2acdee8ab0e6..62c1bf61953b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -149,7 +149,8 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 	return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
 }
 
-extern int __isolate_free_page(struct page *page, unsigned int order);
+extern int __isolate_free_page(struct page *page, unsigned int order,
+						unsigned int alloc_flags);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 623027fb8121..2d74eddffcf6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2489,7 +2489,8 @@ void split_page(struct page *page, unsigned int order)
 }
 EXPORT_SYMBOL_GPL(split_page);
 
-int __isolate_free_page(struct page *page, unsigned int order)
+int __isolate_free_page(struct page *page, unsigned int order,
+						unsigned int alloc_flags)
 {
 	unsigned long watermark;
 	struct zone *zone;
@@ -2502,8 +2503,10 @@ int __isolate_free_page(struct page *page, unsigned int order)
 
 	if (!is_migrate_isolate(mt)) {
 		/* Obey watermarks as if the page was being allocated */
-		watermark = low_wmark_pages(zone) + (1 << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+		watermark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+		/* We know our order page exists, so only check order-0 */
+		watermark += (1UL << order);
+		if (!zone_watermark_ok(zone, 0, watermark, 0, alloc_flags))
 			return 0;
 
 		__mod_zone_freepage_state(zone, -(1UL << order), mt);
@@ -2541,14 +2544,14 @@ int __isolate_free_page(struct page *page, unsigned int order)
  * Note: this is probably too low level an operation for use in drivers.
  * Please consult with lkml before using this in your driver.
  */
-int split_free_page(struct page *page)
+int split_free_page(struct page *page, unsigned int alloc_flags)
 {
 	unsigned int order;
 	int nr_pages;
 
 	order = page_order(page);
 
-	nr_pages = __isolate_free_page(page, order);
+	nr_pages = __isolate_free_page(page, order, alloc_flags);
 	if (!nr_pages)
 		return 0;
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 612122bf6a42..0bcb7a32d84c 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -107,7 +107,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 
 			if (pfn_valid_within(page_to_pfn(buddy)) &&
 			    !is_migrate_isolate_page(buddy)) {
-				__isolate_free_page(page, order);
+				__isolate_free_page(page, order, 0);
 				kernel_map_pages(page, (1 << order), 1);
 				set_page_refcounted(page);
 				isolated_page = page;
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
