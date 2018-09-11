Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9988B8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a23-v6so12251224pfo.23
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:43 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 8/9] mm: use smp_list_splice() on free path
Date: Tue, 11 Sep 2018 13:36:15 +0800
Message-Id: <20180911053616.6894-9-aaron.lu@intel.com>
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

With free path running concurrently, the cache bouncing on free
list head is severe since multiple threads can be freeing pages
and each free will need to add the page to free list head.

To improve performance on free path for order-0 pages, we can
choose to not add the merged pages to Buddy immediately after
merge but keep them on a local percpu list first and then after
all pages are finished merging, add these merged pages to Buddy
with smp_list_splice() in one go.

This optimization caused a problem though: the page we hold on the
local percpu list can be a buddy of other being freed page and we
lose the merge oppotunity for them. With this patch, we will have
mergable pages unmerged in Buddy.

Due to this, I don't see much value of keeping the range lock which
is used to avoid such thing from happening, so the range lock is
removed in this patch.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/mm.h     |   1 +
 include/linux/mmzone.h |   3 -
 init/main.c            |   1 +
 mm/page_alloc.c        | 151 +++++++++++++++++++++++++----------------
 4 files changed, 95 insertions(+), 61 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..a99ba2cb7a0d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2155,6 +2155,7 @@ extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
 extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
+extern void percpu_mergelist_init(void);
 extern void __init mmap_init(void);
 extern void show_mem(unsigned int flags, nodemask_t *nodemask);
 extern long si_mem_available(void);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0ea52e9bb610..e66b8c63d5d1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -467,9 +467,6 @@ struct zone {
 	/* Primarily protects free_area */
 	rwlock_t		lock;
 
-	/* Protects merge operation for a range of order=(MAX_ORDER-1) pages */
-	spinlock_t		*range_locks;
-
 	/* Write-intensive fields used by compaction and vmstats. */
 	ZONE_PADDING(_pad2_)
 
diff --git a/init/main.c b/init/main.c
index 18f8f0140fa0..68a428e1bf15 100644
--- a/init/main.c
+++ b/init/main.c
@@ -517,6 +517,7 @@ static void __init mm_init(void)
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
 	page_ext_init_flatmem();
+	percpu_mergelist_init();
 	mem_init();
 	kmem_cache_init();
 	pgtable_init();
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5f5cc671bcf7..df38c3f2a1cc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -339,17 +339,6 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 }
 #endif
 
-/* Return a pointer to the spinblock for a pageblock this page belongs to */
-static inline spinlock_t *get_range_lock(struct page *page)
-{
-	struct zone *zone = page_zone(page);
-	unsigned long zone_start_pfn = zone->zone_start_pfn;
-	unsigned long range = (page_to_pfn(page) - zone_start_pfn) >>
-								(MAX_ORDER - 1);
-
-	return &zone->range_locks[range];
-}
-
 /* Return a pointer to the bitmap storing bits affecting a block of pages */
 static inline unsigned long *get_pageblock_bitmap(struct page *page,
 							unsigned long pfn)
@@ -711,9 +700,15 @@ static inline void set_page_order(struct page *page, unsigned int order)
 static inline void add_to_buddy(struct page *page, struct zone *zone,
 				unsigned int order, int mt)
 {
+	/*
+	 * Adding page to free list before setting PageBuddy flag
+	 * or other thread doing merge can notice its PageBuddy flag
+	 * and attempt to merge with it, causing list corruption.
+	 */
+	smp_list_add(&page->lru, &zone->free_area[order].free_list[mt]);
+	smp_wmb();
 	set_page_order(page, order);
 	atomic_long_inc(&zone->free_area[order].nr_free);
-	smp_list_add(&page->lru, &zone->free_area[order].free_list[mt]);
 }
 
 static inline void rmv_page_order(struct page *page)
@@ -784,40 +779,17 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
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
- * free pages of length of (1 << order) and marked with PageBuddy.
- * Page's order is recorded in page_private(page) field.
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
+/* Return merged page pointer with order updated */
+static inline struct page *do_merge(struct page *page,
 		unsigned long pfn,
-		struct zone *zone, unsigned int order,
+		struct zone *zone, unsigned int *p_order,
 		int migratetype)
 {
 	unsigned long combined_pfn;
 	unsigned long uninitialized_var(buddy_pfn);
 	struct page *buddy;
 	unsigned int max_order;
-	spinlock_t *range_lock;
+	unsigned int order = *p_order;
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -831,8 +803,6 @@ static inline void __free_one_page(struct page *page,
 	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
-	range_lock = get_range_lock(page);
-	spin_lock(range_lock);
 continue_merging:
 	while (order < max_order - 1) {
 		buddy_pfn = __find_buddy_pfn(pfn, order);
@@ -881,8 +851,41 @@ static inline void __free_one_page(struct page *page,
 	}
 
 done_merging:
+	*p_order = order;
+	return page;
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
+ * free pages of length of (1 << order) and marked with PageBuddy.
+ * Page's order is recorded in page_private(page) field.
+ * So when we are allocating or freeing one, we can derive the state of the
+ * other.  That is, if we allocate a small block, and both were
+ * free, the remainder of the region must be split into blocks.
+ * If a block is freed, and its buddy is also free, then this
+ * triggers coalescing into a block of larger size.
+ *
+ * -- nyc
+ */
+
+static inline void __free_one_page(struct page *page,
+		unsigned long pfn,
+		struct zone *zone, unsigned int order,
+		int migratetype)
+{
+	page = do_merge(page, pfn, zone, &order, migratetype);
 	add_to_buddy(page, zone, order, migratetype);
-	spin_unlock(range_lock);
 }
 
 /*
@@ -1081,6 +1084,20 @@ static inline void prefetch_buddy(struct page *page)
 	prefetch(buddy);
 }
 
+static DEFINE_PER_CPU(struct list_head, merge_lists[MAX_ORDER][MIGRATE_TYPES]);
+
+void __init percpu_mergelist_init(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		unsigned int order, mt;
+
+		for_each_migratetype_order(order, mt)
+			INIT_LIST_HEAD(per_cpu_ptr(&merge_lists[order][mt], cpu));
+	}
+}
+
 /*
  * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
@@ -1101,10 +1118,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	bool isolated_pageblocks;
 	struct page *page, *tmp;
 	LIST_HEAD(head);
+	struct list_head *list;
+	unsigned int order;
 
 	while (count) {
-		struct list_head *list;
-
 		/*
 		 * Remove pages from lists in a round-robin fashion. A
 		 * batch_free count is maintained that is incremented when an
@@ -1157,15 +1174,46 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	 */
 	list_for_each_entry_safe(page, tmp, &head, lru) {
 		int mt = get_pcppage_migratetype(page);
+		struct page *merged_page;
+
 		/* MIGRATE_ISOLATE page should not go to pcplists */
 		VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
 		/* Pageblock could have been isolated meanwhile */
 		if (unlikely(isolated_pageblocks))
 			mt = get_pageblock_migratetype(page);
 
-		__free_one_page(page, page_to_pfn(page), zone, 0, mt);
+		order = 0;
+		merged_page = do_merge(page, page_to_pfn(page), zone, &order, mt);
+		list_add(&merged_page->lru, this_cpu_ptr(&merge_lists[order][mt]));
 		trace_mm_page_pcpu_drain(page, 0, mt);
 	}
+
+	for_each_migratetype_order(order, migratetype) {
+		unsigned long n;
+		struct list_head *entry;
+
+		list = this_cpu_ptr(&merge_lists[order][migratetype]);
+		if (list_empty(list))
+			continue;
+
+		smp_list_splice(list, &zone->free_area[order].free_list[migratetype]);
+
+		/* Add to list first before setting PageBuddy flag */
+		smp_wmb();
+
+		n = 0;
+		entry = list;
+		do {
+			entry = entry->next;
+			page = list_entry(entry, struct page, lru);
+			set_page_order(page, order);
+			n++;
+		} while (entry != list->prev);
+		INIT_LIST_HEAD(list);
+
+		atomic_long_add(n, &zone->free_area[order].nr_free);
+	}
+
 	read_unlock(&zone->lock);
 }
 
@@ -6280,18 +6328,6 @@ void __ref free_area_init_core_hotplug(int nid)
 }
 #endif
 
-static void __init setup_range_locks(struct zone *zone)
-{
-	unsigned long nr = (zone->spanned_pages >> (MAX_ORDER - 1)) + 1;
-	unsigned long size = nr * sizeof(spinlock_t);
-	unsigned long i;
-
-	zone->range_locks = memblock_virt_alloc_node_nopanic(size,
-						zone->zone_pgdat->node_id);
-	for (i = 0; i < nr; i++)
-		spin_lock_init(&zone->range_locks[i]);
-}
-
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -6363,7 +6399,6 @@ static void __init free_area_init_core(struct pglist_data *pgdat)
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
 		init_currently_empty_zone(zone, zone_start_pfn, size);
 		memmap_init(size, nid, j, zone_start_pfn);
-		setup_range_locks(zone);
 	}
 }
 
-- 
2.17.1
