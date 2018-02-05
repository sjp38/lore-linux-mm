Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE7536B0007
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 00:30:59 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q5so8314337pll.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 21:30:59 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 31-v6si1885332pli.68.2018.02.04.21.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Feb 2018 21:30:58 -0800 (PST)
Date: Mon, 5 Feb 2018 13:31:39 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 1/2] __free_one_page: skip merge for order-0 page unless
 compaction is in progress
Message-ID: <20180205053139.GC16980@intel.com>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180205053013.GB16980@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180205053013.GB16980@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan <daniel.m.jordan@oracle.com>

Running will-it-scale/page_fault1 process mode workload on a 2 sockets
Intel Skylake server showed severe lock contention of zone->lock, as
high as about 80%(43% on allocation path and 38% on free path) CPU
cycles are burnt spinning. With perf, the most time consuming part inside
that lock on free path is cache missing on page structures, mostly on
the to-be-freed page's buddy due to merging.

One way to avoid this overhead is not do any merging at all for order-0
pages and leave the need for high order pages to compaction. With this
approach, the lock contention for zone->lock on free path dropped to 4%
but allocation side still has as high as 43% lock contention. In the
meantime, the dropped lock contention on free side doesn't translate to
performance increase, instead, it's consumed by increased lock contention
of the per node lru_lock(rose from 2% to 33%).

One concern of this approach is, how much impact does it have on high order
page allocation, like for order-9 pages? I have run the stress-highalloc
workload on a Haswell Desktop(8 CPU/4G memory) sometime ago and it showed
similar success rate for vanilla kernel and the patched kernel, both at 74%.
Note that it indeed took longer to finish the test: 244s vs 218s.

1 vanilla
  Attempted allocations:          1917
  Failed allocs:                   494
  Success allocs:                 1423
  % Success:                        74
  Duration alloctest pass:        218s

2 no_merge_in_buddy
  Attempted allocations:         1917
  Failed allocs:                  497
  Success allocs:                1420
  % Success:                       74
  Duration alloctest pass:       244s

The above test was done with the default --ms-delay=100, which means there
is a delay of 100ms between page allocations. If I set the delay to 1ms,
the success rate of this patch will drop to 36% while vanilla could maintain
at about 70%. Though 1ms delay may not be practical, it indeed shows the
possible impact of this patch on high order page allocation.

The next patch deals with allocation path zone->lock contention.

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/compaction.c |  28 ++++++++++++++
 mm/internal.h   |  15 +++++++-
 mm/page_alloc.c | 116 ++++++++++++++++++++++++++++++++++++--------------------
 3 files changed, 117 insertions(+), 42 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 10cd757f1006..b53c4d420533 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -669,6 +669,28 @@ static bool too_many_isolated(struct zone *zone)
 	return isolated > (inactive + active) / 2;
 }
 
+static int merge_page(struct zone *zone, struct page *page, unsigned long pfn)
+{
+	int order = 0;
+	unsigned long buddy_pfn = __find_buddy_pfn(pfn, order);
+	struct page *buddy = page + (buddy_pfn - pfn);
+
+	/* Only do merging if the merge skipped page's buddy is also free */
+	if (PageBuddy(buddy)) {
+		int mt = get_pageblock_migratetype(page);
+		unsigned long flags;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		if (likely(page_merge_skipped(page))) {
+			do_merge(zone, page, mt);
+			order = page_order(page);
+		}
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+
+	return order;
+}
+
 /**
  * isolate_migratepages_block() - isolate all migrate-able pages within
  *				  a single pageblock
@@ -777,6 +799,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (PageBuddy(page)) {
 			unsigned long freepage_order = page_order_unsafe(page);
+			/*
+			 * If the page didn't do merging on free time, now do
+			 * it since we are doing compaction.
+			 */
+			if (page_merge_skipped(page))
+				freepage_order = merge_page(zone, page, low_pfn);
 
 			/*
 			 * Without lock, we cannot be sure that what we got is
diff --git a/mm/internal.h b/mm/internal.h
index e6bd35182dae..d2b0ac02d459 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -228,9 +228,22 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 static inline unsigned int page_order(struct page *page)
 {
 	/* PageBuddy() must be checked by the caller */
-	return page_private(page);
+	return page_private(page) & ~(1 << 16);
 }
 
+/*
+ * This function returns if the page is in buddy but didn't do any merging
+ * for performance reason. This function only makes sense if PageBuddy(page)
+ * is also true. The caller should hold zone->lock for this function to return
+ * correct value, or it can handle invalid values gracefully.
+ */
+static inline bool page_merge_skipped(struct page *page)
+{
+	return PageBuddy(page) && (page->private & (1 << 16));
+}
+
+void do_merge(struct zone *zone, struct page *page, int migratetype);
+
 /*
  * Like page_order(), but for callers who cannot afford to hold the zone lock.
  * PageBuddy() should be checked first by the caller to minimize race window,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ac7fa97dd55..9497c8c5f808 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -781,49 +781,14 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
-/*
- * Freeing function for a buddy system allocator.
- *
- * The concept of a buddy system is to maintain direct-mapped table
- * (containing bit values) for memory blocks of various "orders".
- * The bottom level table contains the map for the smallest allocatable
- * units of memory (here, pages), and each level above it describes
- * pairs of units from the levels below, hence, "buddies".
- * At a high level, all that happens here is marking the table entry
- * at the bottom level available, and propagating the changes upward
- * as necessary, plus some accounting needed to play nicely with other
- * parts of the VM system.
- * At each level, we keep a list of pages, which are heads of continuous
- * free pages of length of (1 << order) and marked with _mapcount
- * PAGE_BUDDY_MAPCOUNT_VALUE. Page's order is recorded in page_private(page)
- * field.
- * So when we are allocating or freeing one, we can derive the state of the
- * other.  That is, if we allocate a small block, and both were
- * free, the remainder of the region must be split into blocks.
- * If a block is freed, and its buddy is also free, then this
- * triggers coalescing into a block of larger size.
- *
- * -- nyc
- */
-
-static inline void __free_one_page(struct page *page,
-		unsigned long pfn,
-		struct zone *zone, unsigned int order,
-		int migratetype)
+static void inline __do_merge(struct page *page, unsigned int order,
+				struct zone *zone, int migratetype)
 {
+	unsigned int max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
+	unsigned long pfn = page_to_pfn(page);
 	unsigned long combined_pfn;
 	unsigned long uninitialized_var(buddy_pfn);
 	struct page *buddy;
-	unsigned int max_order;
-
-	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
-
-	VM_BUG_ON(!zone_is_initialized(zone));
-	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
-
-	VM_BUG_ON(migratetype == -1);
-	if (likely(!is_migrate_isolate(migratetype)))
-		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
 	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
@@ -879,8 +844,6 @@ static inline void __free_one_page(struct page *page,
 	}
 
 done_merging:
-	set_page_order(page, order);
-
 	/*
 	 * If this is not the largest possible page, check if the buddy
 	 * of the next-highest order is free. If it is, it's possible
@@ -905,9 +868,80 @@ static inline void __free_one_page(struct page *page,
 
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
+	set_page_order(page, order);
 	zone->free_area[order].nr_free++;
 }
 
+void do_merge(struct zone *zone, struct page *page, int migratetype)
+{
+	VM_BUG_ON(page_order(page) != 0);
+
+	list_del(&page->lru);
+	zone->free_area[0].nr_free--;
+	rmv_page_order(page);
+
+	__do_merge(page, 0, zone, migratetype);
+}
+
+static inline bool should_skip_merge(struct zone *zone, unsigned int order)
+{
+#ifdef CONFIG_COMPACTION
+	return !zone->compact_considered && !order;
+#else
+	return false;
+#endif
+}
+
+/*
+ * Freeing function for a buddy system allocator.
+ *
+ * The concept of a buddy system is to maintain direct-mapped table
+ * (containing bit values) for memory blocks of various "orders".
+ * The bottom level table contains the map for the smallest allocatable
+ * units of memory (here, pages), and each level above it describes
+ * pairs of units from the levels below, hence, "buddies".
+ * At a high level, all that happens here is marking the table entry
+ * at the bottom level available, and propagating the changes upward
+ * as necessary, plus some accounting needed to play nicely with other
+ * parts of the VM system.
+ * At each level, we keep a list of pages, which are heads of continuous
+ * free pages of length of (1 << order) and marked with _mapcount
+ * PAGE_BUDDY_MAPCOUNT_VALUE. Page's order is recorded in page_private(page)
+ * field.
+ * So when we are allocating or freeing one, we can derive the state of the
+ * other.  That is, if we allocate a small block, and both were
+ * free, the remainder of the region must be split into blocks.
+ * If a block is freed, and its buddy is also free, then this
+ * triggers coalescing into a block of larger size.
+ *
+ * -- nyc
+ */
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
+	if (should_skip_merge(zone, order)) {
+		list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
+		/*
+		 * 1 << 16 set on page->private to indicate this order0
+		 * page skipped merging during free time
+		 */
+		set_page_order(page, order | (1 << 16));
+		zone->free_area[order].nr_free++;
+		return;
+	}
+
+	__do_merge(page, order, zone, migratetype);
+}
+
 /*
  * A bad page could be due to a number of fields. Instead of multiple branches,
  * try and check multiple fields with one check. The caller must do a detailed
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
