Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01AB48E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 12:35:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so6250544pfn.3
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 09:35:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id bh12-v6si9653943plb.425.2018.09.15.09.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Sep 2018 09:35:17 -0700 (PDT)
Subject: [PATCH 1/3] mm: Shuffle initial free memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 15 Sep 2018 09:23:08 -0700
Message-ID: <153702858808.1603922.13788275916530966227.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Some data exfiltration and return-oriented-programming attacks rely on
the ability to infer the location of sensitive data objects. The kernel
page allocator, especially early in system boot, has predictable
first-in-first out behavior for physical pages. Pages are freed in
physical address order when first onlined.

Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
when they are initially populated with free memory.

The shuffling is done in terms of 'shuffle_page_order' sized free pages
where the default shuffle_page_order is MAX_ORDER-1 i.e. 10, 4MB.

The performance impact of the shuffling appears to be in the noise
compared to other memory initialization work. Also the bulk of the work
is done in the background as a part of deferred_init_memmap().

Cc: Michal Hocko <mhocko@suse.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/list.h   |   17 +++++
 include/linux/mm.h     |    2 +
 include/linux/mmzone.h |    4 +
 mm/bootmem.c           |    9 ++-
 mm/nobootmem.c         |    7 ++
 mm/page_alloc.c        |  172 ++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 207 insertions(+), 4 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index de04cc5ed536..43f963328d7c 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -150,6 +150,23 @@ static inline void list_replace_init(struct list_head *old,
 	INIT_LIST_HEAD(old);
 }
 
+/**
+ * list_swap - replace entry1 with entry2 and re-add entry1 at entry2's position
+ * @entry1: the location to place entry2
+ * @entry2: the location to place entry1
+ */
+static inline void list_swap(struct list_head *entry1,
+			     struct list_head *entry2)
+{
+	struct list_head *pos = entry2->prev;
+
+	list_del(entry2);
+	list_replace(entry1, entry2);
+	if (pos == entry1)
+		pos = entry2;
+	list_add(entry1, pos);
+}
+
 /**
  * list_del_init - deletes entry from list and reinitialize it.
  * @entry: the element to delete from the list.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..588f34e4390e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2040,6 +2040,8 @@ extern void adjust_managed_page_count(struct page *page, long count);
 extern void mem_init_print_info(const char *str);
 
 extern void reserve_bootmem_region(phys_addr_t start, phys_addr_t end);
+extern void shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
+		unsigned long end_pfn);
 
 /* Free the reserved page into the buddy system, so it gets managed. */
 static inline void __free_reserved_page(struct page *page)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1e22d96734e0..8f8fc7dab5cb 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1277,6 +1277,10 @@ void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
+static inline int pfn_present(unsigned long pfn)
+{
+	return 1;
+}
 #endif /* CONFIG_SPARSEMEM */
 
 /*
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 97db0e8e362b..7f5ff899c622 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -210,6 +210,7 @@ void __init free_bootmem_late(unsigned long physaddr, unsigned long size)
 static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 {
 	struct page *page;
+	int nid = bdata - bootmem_node_data;
 	unsigned long *map, start, end, pages, cur, count = 0;
 
 	if (!bdata->node_bootmem_map)
@@ -219,8 +220,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	start = bdata->node_min_pfn;
 	end = bdata->node_low_pfn;
 
-	bdebug("nid=%td start=%lx end=%lx\n",
-		bdata - bootmem_node_data, start, end);
+	bdebug("nid=%d start=%lx end=%lx\n", nid, start, end);
 
 	while (start < end) {
 		unsigned long idx, vec;
@@ -276,7 +276,10 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		__free_pages_bootmem(page++, cur++, 0);
 	bdata->node_bootmem_map = NULL;
 
-	bdebug("nid=%td released=%lx\n", bdata - bootmem_node_data, count);
+	shuffle_free_memory(NODE_DATA(nid), bdata->node_min_pfn,
+			bdata->node_low_pfn);
+
+	bdebug("nid=%d released=%lx\n", nid, count);
 
 	return count;
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 439af3b765a7..40b42434e805 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -131,6 +131,7 @@ static unsigned long __init free_low_memory_core_early(void)
 {
 	unsigned long count = 0;
 	phys_addr_t start, end;
+	pg_data_t *pgdat;
 	u64 i;
 
 	memblock_clear_hotplug(0, -1);
@@ -144,8 +145,12 @@ static unsigned long __init free_low_memory_core_early(void)
 	 *  low ram will be on Node1
 	 */
 	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
-				NULL)
+				NULL) {
 		count += __free_memory_core(start, end);
+		for_each_online_pgdat(pgdat)
+			shuffle_free_memory(pgdat, PHYS_PFN(start),
+					PHYS_PFN(end));
+	}
 
 	return count;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 89d2a2ab3fe6..2fff9e69d8f3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -55,6 +55,7 @@
 #include <trace/events/kmem.h>
 #include <trace/events/oom.h>
 #include <linux/prefetch.h>
+#include <linux/random.h>
 #include <linux/mm_inline.h>
 #include <linux/migrate.h>
 #include <linux/hugetlb.h>
@@ -72,6 +73,13 @@
 #include <asm/div64.h>
 #include "internal.h"
 
+/*
+ * page_alloc.shuffle_page_order gates which page orders are shuffled by
+ * shuffle_zone() during memory initialization.
+ */
+static int __read_mostly shuffle_page_order = MAX_ORDER-1;
+module_param(shuffle_page_order, int, 0444);
+
 /* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
 static DEFINE_MUTEX(pcp_batch_high_lock);
 #define MIN_PERCPU_PAGELIST_FRACTION	(8)
@@ -1035,6 +1043,168 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	return true;
 }
 
+/*
+ * For two pages to be swapped in the shuffle, they must be free (on a
+ * 'free_area' lru), have the same order, and have the same migratetype.
+ */
+static struct page * __init shuffle_valid_page(unsigned long pfn, int order)
+{
+	struct page *page;
+
+	/*
+	 * Given we're dealing with randomly selected pfns in a zone we
+	 * need to ask questions like...
+	 */
+
+	/* ...is the pfn even in the memmap? */
+	if (!pfn_valid_within(pfn))
+		return NULL;
+
+	/* ...is the pfn in a present section or a hole? */
+	if (!pfn_present(pfn))
+		return NULL;
+
+	/* ...is the page free and currently on a free_area list? */
+	page = pfn_to_page(pfn);
+	if (!PageBuddy(page))
+		return NULL;
+
+	/*
+	 * ...is the page on the same list as the page we will
+	 * shuffle it with?
+	 */
+	if (page_order(page) != order)
+		return NULL;
+
+	return page;
+}
+
+/*
+ * Fisher-Yates shuffle the freelist which prescribes iterating through
+ * an array, pfns in this case, and randomly swapping each entry with
+ * another in the span, end_pfn - start_pfn.
+ *
+ * To keep the implementation simple it does not attempt to correct for
+ * sources of bias in the distribution, like modulo bias or
+ * pseudo-random number generator bias. I.e. the expectation is that
+ * this shuffling raises the bar for attacks that exploit the
+ * predictability of page allocations, but need not be a perfect
+ * shuffle.
+ *
+ * Note that we don't use @z->zone_start_pfn and zone_end_pfn(@z)
+ * directly since the caller may be aware of holes in the zone and can
+ * improve the accuracy of the random pfn selection.
+ */
+#define SHUFFLE_RETRY 10
+static void __init shuffle_zone_order(struct zone *z, unsigned long start_pfn,
+		unsigned long end_pfn, const int order)
+{
+	unsigned long i, flags;
+	const int order_pages = 1 << order;
+
+	if (start_pfn < z->zone_start_pfn)
+		start_pfn = z->zone_start_pfn;
+	if (end_pfn > zone_end_pfn(z))
+		end_pfn = zone_end_pfn(z);
+
+	/* probably means that start/end were outside the zone */
+	if (end_pfn <= start_pfn)
+		return;
+	spin_lock_irqsave(&z->lock, flags);
+	start_pfn = ALIGN(start_pfn, order_pages);
+	for (i = start_pfn; i < end_pfn; i += order_pages) {
+		unsigned long j;
+		int migratetype, retry;
+		struct page *page_i, *page_j;
+
+		/*
+		 * We expect page_i, in the sub-range of a zone being
+		 * added (@start_pfn to @end_pfn), to more likely be
+		 * valid compared to page_j randomly selected in the
+		 * span @zone_start_pfn to @spanned_pages.
+		 */
+		page_i = shuffle_valid_page(i, order);
+		if (!page_i)
+			continue;
+
+		for (retry = 0; retry < SHUFFLE_RETRY; retry++) {
+			/*
+			 * Pick a random order aligned page from the
+			 * start of the zone. Use the *whole* zone here
+			 * so that if it is freed in tiny pieces that we
+			 * randomize in the whole zone, not just within
+			 * those fragments.
+			 *
+			 * Since page_j comes from a potentially sparse
+			 * address range we want to try a bit harder to
+			 * find a shuffle point for page_i.
+			 */
+			j = z->zone_start_pfn +
+				ALIGN_DOWN(get_random_long() % z->spanned_pages,
+						order_pages);
+			page_j = shuffle_valid_page(j, order);
+			if (page_j && page_j != page_i)
+				break;
+		}
+		if (retry >= SHUFFLE_RETRY) {
+			pr_debug("%s: failed to swap %#lx\n", __func__, i);
+			continue;
+		}
+
+		/*
+		 * Each migratetype corresponds to its own list, make
+		 * sure the types match otherwise we're moving pages to
+		 * lists where they do not belong.
+		 */
+		migratetype = get_pageblock_migratetype(page_i);
+		if (get_pageblock_migratetype(page_j) != migratetype) {
+			pr_debug("%s: migratetype mismatch %#lx\n", __func__, i);
+			continue;
+		}
+
+		list_swap(&page_i->lru, &page_j->lru);
+
+		pr_debug("%s: swap: %#lx -> %#lx\n", __func__, i, j);
+
+		/* take it easy on the zone lock */
+		if ((i % (100 * order_pages)) == 0) {
+			spin_unlock_irqrestore(&z->lock, flags);
+			cond_resched();
+			spin_lock_irqsave(&z->lock, flags);
+		}
+	}
+	spin_unlock_irqrestore(&z->lock, flags);
+}
+
+static void __init shuffle_zone(struct zone *z, unsigned long start_pfn,
+               unsigned long end_pfn)
+{
+       int i;
+
+       /* shuffle all the orders at the specified order and higher */
+       for (i = shuffle_page_order; i < MAX_ORDER; i++)
+               shuffle_zone_order(z, start_pfn, end_pfn, i);
+}
+
+/**
+ * shuffle_free_memory - reduce the predictability of the page allocator
+ * @pgdat: node page data
+ * @start_pfn: Limit the shuffle to the greater of this value or zone start
+ * @end_pfn: Limit the shuffle to the less of this value or zone end
+ *
+ * While shuffle_zone() attempts to avoid holes with pfn_valid() and
+ * pfn_present() they can not report sub-section sized holes. @start_pfn
+ * and @end_pfn limit the shuffle to the exact memory pages being freed.
+ */
+void __init shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+	struct zone *z;
+
+	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
+		shuffle_zone(z, start_pfn, end_pfn);
+}
+
 #ifdef CONFIG_DEBUG_VM
 static inline bool free_pcp_prepare(struct page *page)
 {
@@ -1583,6 +1753,8 @@ static int __init deferred_init_memmap(void *data)
 	}
 	pgdat_resize_unlock(pgdat, &flags);
 
+	shuffle_zone(zone, first_init_pfn, zone_end_pfn(zone));
+
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
 
