Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 778C96B0009
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:53:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c16so555731pgv.8
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 01:53:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l185si925211pgd.108.2018.03.20.01.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 01:53:50 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0 page unless compaction failed
Date: Tue, 20 Mar 2018 16:54:50 +0800
Message-Id: <20180320085452.24641-3-aaron.lu@intel.com>
In-Reply-To: <20180320085452.24641-1-aaron.lu@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

Running will-it-scale/page_fault1 process mode workload on a 2 sockets
Intel Skylake server showed severe lock contention of zone->lock, as
high as about 80%(42% on allocation path and 35% on free path) CPU
cycles are burnt spinning. With perf, the most time consuming part inside
that lock on free path is cache missing on page structures, mostly on
the to-be-freed page's buddy due to merging.

One way to avoid this overhead is not do any merging at all for order-0
pages. With this approach, the lock contention for zone->lock on free
path dropped to 1.1% but allocation side still has as high as 42% lock
contention. In the meantime, the dropped lock contention on free side
doesn't translate to performance increase, instead, it's consumed by
increased lock contention of the per node lru_lock(rose from 5% to 37%)
and the final performance slightly dropped about 1%.

Though performance dropped a little, it almost eliminated zone lock
contention on free path and it is the foundation for the next patch
that eliminates zone lock contention for allocation path.

A new document file called "struct_page_filed" is added to explain
the newly reused field in "struct page".

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 Documentation/vm/struct_page_field |  5 +++
 include/linux/mm_types.h           |  1 +
 mm/compaction.c                    | 13 +++++-
 mm/internal.h                      | 27 ++++++++++++
 mm/page_alloc.c                    | 89 +++++++++++++++++++++++++++++++++-----
 5 files changed, 122 insertions(+), 13 deletions(-)
 create mode 100644 Documentation/vm/struct_page_field

diff --git a/Documentation/vm/struct_page_field b/Documentation/vm/struct_page_field
new file mode 100644
index 000000000000..1ab6c19ccc7a
--- /dev/null
+++ b/Documentation/vm/struct_page_field
@@ -0,0 +1,5 @@
+buddy_merge_skipped:
+Used to indicate this page skipped merging when added to buddy. This
+field only makes sense if the page is in Buddy and is order zero.
+It's a bug if any higher order pages in Buddy has this field set.
+Shares space with index.
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fd1af6b9591d..7edc4e102a8e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -91,6 +91,7 @@ struct page {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* sl[aou]b first free object */
 		/* page_deferred_list().prev	-- second tail page */
+		bool buddy_merge_skipped; /* skipped merging when added to buddy */
 	};
 
 	union {
diff --git a/mm/compaction.c b/mm/compaction.c
index 2c8999d027ab..fb9031fdca41 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -776,8 +776,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * potential isolation targets.
 		 */
 		if (PageBuddy(page)) {
-			unsigned long freepage_order = page_order_unsafe(page);
+			unsigned long freepage_order;
 
+			/*
+			 * If this is a merge_skipped page, do merge now
+			 * since high-order pages are needed. zone lock
+			 * isn't taken for the merge_skipped check so the
+			 * check could be wrong but the worst case is we
+			 * lose a merge opportunity.
+			 */
+			if (page_merge_was_skipped(page))
+				try_to_merge_page(page);
+
+			freepage_order = page_order_unsafe(page);
 			/*
 			 * Without lock, we cannot be sure that what we got is
 			 * a valid page order. Consider only values in the
diff --git a/mm/internal.h b/mm/internal.h
index e6bd35182dae..2bfbaae2d835 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -538,4 +538,31 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 }
 
 void setup_zone_pageset(struct zone *zone);
+
+static inline bool page_merge_was_skipped(struct page *page)
+{
+	return page->buddy_merge_skipped;
+}
+
+void try_to_merge_page(struct page *page);
+
+#ifdef CONFIG_COMPACTION
+static inline bool can_skip_merge(struct zone *zone, int order)
+{
+	/* Compaction has failed in this zone, we shouldn't skip merging */
+	if (zone->compact_considered)
+		return false;
+
+	/* Only consider no_merge for order 0 pages */
+	if (order)
+		return false;
+
+	return true;
+}
+#else /* CONFIG_COMPACTION */
+static inline bool can_skip_merge(struct zone *zone, int order)
+{
+	return false;
+}
+#endif  /* CONFIG_COMPACTION */
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3cdf1e10d412..eb78014dfbde 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -730,6 +730,16 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype) {}
 #endif
 
+static inline void set_page_merge_skipped(struct page *page)
+{
+	page->buddy_merge_skipped = true;
+}
+
+static inline void clear_page_merge_skipped(struct page *page)
+{
+	page->buddy_merge_skipped = false;
+}
+
 static inline void set_page_order(struct page *page, unsigned int order)
 {
 	set_page_private(page, order);
@@ -739,6 +749,13 @@ static inline void set_page_order(struct page *page, unsigned int order)
 static inline void add_to_buddy_common(struct page *page, struct zone *zone,
 					unsigned int order, int mt)
 {
+	/*
+	 * Always clear buddy_merge_skipped when added to buddy because
+	 * buddy_merge_skipped shares space with index and index could
+	 * be used as migratetype for PCP pages.
+	 */
+	clear_page_merge_skipped(page);
+
 	set_page_order(page, order);
 	zone->free_area[order].nr_free++;
 }
@@ -769,6 +786,7 @@ static inline void remove_from_buddy(struct page *page, struct zone *zone,
 	list_del(&page->lru);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
+	clear_page_merge_skipped(page);
 }
 
 /*
@@ -839,7 +857,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * -- nyc
  */
 
-static inline void __free_one_page(struct page *page,
+static inline void do_merge(struct page *page,
 		unsigned long pfn,
 		struct zone *zone, unsigned int order,
 		int migratetype)
@@ -851,16 +869,6 @@ static inline void __free_one_page(struct page *page,
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
-	VM_BUG_ON(!zone_is_initialized(zone));
-	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
-
-	VM_BUG_ON(migratetype == -1);
-	if (likely(!is_migrate_isolate(migratetype)))
-		__mod_zone_freepage_state(zone, 1 << order, migratetype);
-
-	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
-	VM_BUG_ON_PAGE(bad_range(zone, page), page);
-
 continue_merging:
 	while (order < max_order - 1) {
 		buddy_pfn = __find_buddy_pfn(pfn, order);
@@ -933,6 +941,61 @@ static inline void __free_one_page(struct page *page,
 	add_to_buddy_head(page, zone, order, migratetype);
 }
 
+void try_to_merge_page(struct page *page)
+{
+	unsigned long pfn, buddy_pfn, flags;
+	struct page *buddy;
+	struct zone *zone;
+
+	/*
+	 * No need to do merging if buddy is not free.
+	 * zone lock isn't taken so this could be wrong but worst case
+	 * is we lose a merge opportunity.
+	 */
+	pfn = page_to_pfn(page);
+	buddy_pfn = __find_buddy_pfn(pfn, 0);
+	buddy = page + (buddy_pfn - pfn);
+	if (!PageBuddy(buddy))
+		return;
+
+	zone = page_zone(page);
+	spin_lock_irqsave(&zone->lock, flags);
+	/* Verify again after taking the lock */
+	if (likely(PageBuddy(page) && page_merge_was_skipped(page) &&
+		   PageBuddy(buddy))) {
+		int mt = get_pageblock_migratetype(page);
+
+		remove_from_buddy(page, zone, 0);
+		do_merge(page, pfn, zone, 0, mt);
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
+static inline void __free_one_page(struct page *page,
+		unsigned long pfn,
+		struct zone *zone, unsigned int order,
+		int migratetype)
+{
+	VM_BUG_ON(!zone_is_initialized(zone));
+	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
+
+	VM_BUG_ON(migratetype == -1);
+	if (likely(!is_migrate_isolate(migratetype)))
+		__mod_zone_freepage_state(zone, 1 << order, migratetype);
+
+	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
+	VM_BUG_ON_PAGE(bad_range(zone, page), page);
+
+	if (can_skip_merge(zone, order)) {
+		add_to_buddy_head(page, zone, 0, migratetype);
+		set_page_merge_skipped(page);
+		return;
+	}
+
+	do_merge(page, pfn, zone, order, migratetype);
+}
+
+
 /*
  * A bad page could be due to a number of fields. Instead of multiple branches,
  * try and check multiple fields with one check. The caller must do a detailed
@@ -1183,8 +1246,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			 * can be offset by reduced memory latency later. To
 			 * avoid excessive prefetching due to large count, only
 			 * prefetch buddy for the last pcp->batch nr of pages.
+			 *
+			 * If merge can be skipped, no need to prefetch buddy.
 			 */
-			if (count > pcp->batch)
+			if (can_skip_merge(zone, 0) || count > pcp->batch)
 				continue;
 			pfn = page_to_pfn(page);
 			buddy_pfn = __find_buddy_pfn(pfn, 0);
-- 
2.14.3
