Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B0DA06B0085
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 06:13:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9QADgP7022833
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 26 Oct 2010 19:13:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E270445DE50
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:13:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C3AF445DE4F
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:13:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A27091DB8012
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:13:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3515AE38001
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:13:38 +0900 (JST)
Date: Tue, 26 Oct 2010 19:08:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/3] a big contig memory allocator
Message-Id: <20101026190809.4869b4f0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Add an function to allocate contiguous memory larger than MAX_ORDER.
The main difference between usual page allocator is that this uses
memory offline technique (Isolate pages and migrate remaining pages.).

I think this is not 100% solution because we can't avoid fragmentation,
but we have kernelcore= boot option and can create MOVABLE zone. That
helps us to allow allocate a contiguous range on demand.

The new function is

  alloc_contig_pages(base, end, nr_pages, alignment)

This function will allocate contiguous pages of nr_pages from the range
[base, end). If [base, end) is bigger than nr_pages, some pfn which
meats alignment will be allocated. If alignment is smaller than MAX_ORDER,
it will be raised to be MAX_ORDER.

__alloc_contig_pages() has much more arguments.

Some drivers allocates contig pages by bootmem or hiding some memory
from the kernel at boot. But if contig pages are necessary only in some
situation, kernelcore= boot option and using page migration is a choice.

Note: I'm not 100% sure __GFP_HARDWALL check is required or not..


Changelog: 2010-10-26
 - support gfp_t
 - support zonelist/nodemask
 - support [base, end) 
 - support alignment

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page-isolation.h |   15 ++
 mm/page_alloc.c                |   29 ++++
 mm/page_isolation.c            |  239 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 283 insertions(+)

Index: mmotm-1024/mm/page_isolation.c
===================================================================
--- mmotm-1024.orig/mm/page_isolation.c
+++ mmotm-1024/mm/page_isolation.c
@@ -5,6 +5,7 @@
 #include <linux/mm.h>
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
+#include <linux/swap.h>
 #include <linux/memcontrol.h>
 #include <linux/migrate.h>
 #include <linux/memory_hotplug.h>
@@ -398,3 +399,241 @@ retry:
 	}
 	return 0;
 }
+
+/*
+ * Comparing user specified [user_start, user_end) with physical memory layout
+ * [phys_start, phys_end). If no intersection of length nr_pages, return 1.
+ * If there is an intersection, return 0 and fill range in [*start, *end)
+ */
+static int
+__calc_search_range(unsigned long user_start, unsigned long user_end,
+		unsigned long nr_pages,
+		unsigned long phys_start, unsigned long phys_end,
+		unsigned long *start, unsigned long *end)
+{
+	if ((user_start >= phys_end) || (user_end <= phys_start))
+		return 1;
+	if (user_start <= phys_start) {
+		*start = phys_start;
+		*end = min(user_end, phys_end);
+	} else {
+		*start = user_start;
+		*end = min(user_end, phys_end);
+	}
+	if (*end - *start < nr_pages)
+		return 1;
+	return 0;
+}
+
+
+/**
+ * __alloc_contig_pages - allocate a contiguous physical pages
+ * @base: the lowest pfn which caller wants.
+ * @end:  the highest pfn which caller wants.
+ * @nr_pages: the length of a chunk of pages to be allocated.
+ * @align_order: alignment of start address of returned chunk in order.
+ *   Returned' page's order will be aligned to (1 << align_order).If smaller
+ *   than MAX_ORDER, it's raised to MAX_ORDER.
+ * @node: allocate near memory to the node, If -1, current node is used.
+ * @gfpflag: used to specify what zone the memory should be from.
+ * @nodemask: allocate memory within the nodemask.
+ *
+ * Search a memory range [base, end) and allocates physically contiguous
+ * pages. If end - base is larger than nr_pages, a chunk in [base, end) will
+ * be allocated
+ *
+ * This returns a page of the beginning of contiguous block. At failure, NULL
+ * is returned.
+ *
+ * Limitation: at allocation, nr_pages may be increased to be aligned to
+ * MAX_ORDER before searching a range. So, even if there is a enough chunk
+ * for nr_pages, it may not be able to be allocated. Extra tail pages of
+ * allocated chunk is returned to buddy allocator before returning the caller.
+ */
+
+#define MIGRATION_RETRY	(5)
+struct page *__alloc_contig_pages(unsigned long base, unsigned long end,
+			unsigned long nr_pages, int align_order,
+			int node, gfp_t gfpflag, nodemask_t *mask)
+{
+	unsigned long found, aligned_pages, start;
+	struct page *ret = NULL;
+	int migration_failed;
+	bool no_search = false;
+	unsigned long align_mask;
+	struct zoneref *z;
+	struct zone *zone;
+	struct zonelist *zonelist;
+	enum zone_type highzone_idx = gfp_zone(gfpflag);
+	unsigned long zone_start, zone_end, rs, re, pos;
+
+	if (node == -1)
+		node = numa_node_id();
+
+	/* check unsupported flags */
+	if (gfpflag & __GFP_NORETRY)
+		return NULL;
+	if ((gfpflag & (__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)) !=
+		(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL))
+		return NULL;
+
+	if (gfpflag & __GFP_THISNODE)
+		zonelist = &NODE_DATA(node)->node_zonelists[1];
+	else
+		zonelist = &NODE_DATA(node)->node_zonelists[0];
+	/*
+	 * Base/nr_page/end should be aligned to MAX_ORDER
+	 */
+	found = 0;
+
+	if (align_order < MAX_ORDER)
+		align_order = MAX_ORDER;
+
+	align_mask = (1 << align_order) - 1;
+	if (end - base == nr_pages)
+		no_search = true;
+	/*
+	 * We allocates MAX_ORDER aligned pages and cut tail pages later.
+	 */
+	aligned_pages = ALIGN(nr_pages, (1 << MAX_ORDER));
+	/*
+	 * If end - base == nr_pages, we can't search range. base must be
+	 * aligned.
+	 */
+	if ((end - base == nr_pages) && (base & align_mask))
+		return NULL;
+
+	base = ALIGN(base, (1 << align_order));
+	if ((end <= base) || (end - base < aligned_pages))
+		return NULL;
+
+	/*
+	 * searching contig memory range within [pos, end).
+	 * pos is updated at migration failure to find next chunk in zone.
+	 * pos is reset to the base at searching next zone.
+	 * (see for_each_zone_zonelist_nodemask in mmzone.h)
+	 *
+	 * Note: we cannot assume zones/nodes are in linear memory layout.
+	 */
+	z = first_zones_zonelist(zonelist, highzone_idx, mask, &zone);
+	pos = base;
+retry:
+	if (!zone)
+		return NULL;
+
+	zone_start = ALIGN(zone->zone_start_pfn, 1 << align_order);
+	zone_end = zone->zone_start_pfn + zone->spanned_pages;
+
+	/* check [pos, end) is in this zone. */
+	if ((pos >= end) ||
+	     (__calc_search_range(pos, end, aligned_pages,
+			zone_start, zone_end, &rs, &re))) {
+next_zone:
+		/* go to the next zone */
+		z = next_zones_zonelist(++z, highzone_idx, mask, &zone);
+		/* reset the pos */
+		pos = base;
+		goto retry;
+	}
+	/* [pos, end) is trimmed to [rs, re) in this zone. */
+	pos = rs;
+
+	found = find_contig_block(rs, re, aligned_pages, align_order, zone);
+	if (!found)
+		goto next_zone;
+
+	/*
+	 * OK, here, we have contiguous pageblock marked as "isolated"
+	 * try migration.
+	 */
+	drain_all_pages();
+	lru_add_drain_all();
+
+	/*
+	 * scan_lru_pages() finds the next PG_lru page in the range
+	 * scan_lru_pages() returns 0 when it reaches the end.
+	 */
+	migration_failed = 0;
+	rs = found;
+	re = found + aligned_pages;
+	for (rs = scan_lru_pages(rs, re);
+	     rs && rs < re;
+	     rs = scan_lru_pages(rs, re)) {
+		if (do_migrate_range(rs, re)) {
+			/* it's better to try another block ? */
+			if (++migration_failed >= MIGRATION_RETRY)
+				break;
+			/* take a rest and synchronize LRU etc. */
+			drain_all_pages();
+			lru_add_drain_all();
+		} else /* reset migration_failure counter */
+			migration_failed = 0;
+	}
+
+	if (!migration_failed) {
+		drain_all_pages();
+		lru_add_drain_all();
+	}
+	/* Check all pages are isolated */
+	if (test_pages_isolated(found, found + aligned_pages)) {
+		undo_isolate_page_range(found, aligned_pages);
+		/*
+		 * We failed at [found...found+aligned_pages) migration.
+		 * "rs" is the last pfn scan_lru_pages() found that the page
+		 * is LRU page. Update pos and try next chunk.
+		 */
+		pos = ALIGN(rs + 1, (1 << align_order));
+		goto retry; /* goto next chunk */
+	}
+	/*
+	 * OK, here, [found...found+pages) memory are isolated.
+	 * All pages in the range will be moved into the list with
+	 * page_count(page)=1.
+	 */
+	ret = pfn_to_page(found);
+	alloc_contig_freed_pages(found, found + aligned_pages, gfpflag);
+	/* unset ISOLATE */
+	undo_isolate_page_range(found, aligned_pages);
+	/* Free unnecessary pages in tail */
+	for (start = found + nr_pages; start < found + aligned_pages; start++)
+		__free_page(pfn_to_page(start));
+	return ret;
+
+}
+EXPORT_SYMBOL_GPL(__alloc_contig_pages);
+
+void free_contig_pages(struct page *page, int nr_pages)
+{
+	int i;
+	for (i = 0; i < nr_pages; i++)
+		__free_page(page + i);
+}
+EXPORT_SYMBOL_GPL(free_contig_pages);
+
+/*
+ * Allocated pages will not be MOVABLE but MOVABLE zone is a suitable
+ * for allocating big chunk. So, using ZONE_MOVABLE is a default.
+ */
+
+struct page *alloc_contig_pages(unsigned long base, unsigned long end,
+			unsigned long nr_pages, int align_order)
+{
+	return __alloc_contig_pages(base, end, nr_pages, align_order, -1,
+				GFP_KERNEL | __GFP_MOVABLE, NULL);
+}
+EXPORT_SYMBOL_GPL(alloc_contig_pages);
+
+struct page *alloc_contig_pages_host(unsigned long nr_pages, int align_order)
+{
+	return __alloc_contig_pages(0, max_pfn, nr_pages, align_order, -1,
+				GFP_KERNEL | __GFP_MOVABLE, NULL);
+}
+EXPORT_SYMBOL_GPL(alloc_contig_pages_host);
+
+struct page *alloc_contig_pages_node(int nid, unsigned long nr_pages,
+				int align_order)
+{
+	return __alloc_contig_pages(0, max_pfn, nr_pages, align_order, nid,
+			GFP_KERNEL | __GFP_THISNODE | __GFP_MOVABLE, NULL);
+}
+EXPORT_SYMBOL_GPL(alloc_contig_pages_node);
Index: mmotm-1024/include/linux/page-isolation.h
===================================================================
--- mmotm-1024.orig/include/linux/page-isolation.h
+++ mmotm-1024/include/linux/page-isolation.h
@@ -32,6 +32,8 @@ test_pages_isolated(unsigned long start_
  */
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
+extern void alloc_contig_freed_pages(unsigned long pfn,
+		unsigned long pages, gfp_t flag);
 
 /*
  * For migration.
@@ -41,4 +43,17 @@ int test_pages_in_a_zone(unsigned long s
 unsigned long scan_lru_pages(unsigned long start, unsigned long end);
 int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
 
+/*
+ * For large alloc.
+ */
+struct page *__alloc_contig_pages(unsigned long base, unsigned long end,
+				unsigned long nr_pages, int align_order,
+				int node, gfp_t flag, nodemask_t *mask);
+struct page *alloc_contig_pages(unsigned long base, unsigned long end,
+				unsigned long nr_pages, int align_order);
+struct page *alloc_contig_pages_host(unsigned long nr_pages, int align_order);
+struct page *alloc_contig_pages_node(int nid, unsigned long nr_pages,
+		int align_order);
+void free_contig_pages(struct page *page, int nr_pages);
+
 #endif
Index: mmotm-1024/mm/page_alloc.c
===================================================================
--- mmotm-1024.orig/mm/page_alloc.c
+++ mmotm-1024/mm/page_alloc.c
@@ -5430,6 +5430,35 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+
+void alloc_contig_freed_pages(unsigned long pfn,  unsigned long end, gfp_t flag)
+{
+	struct page *page;
+	struct zone *zone;
+	int order;
+	unsigned long start = pfn;
+
+	zone = page_zone(pfn_to_page(pfn));
+	spin_lock_irq(&zone->lock);
+	while (pfn < end) {
+		VM_BUG_ON(!pfn_valid(pfn));
+		page = pfn_to_page(pfn);
+		VM_BUG_ON(page_count(page));
+		VM_BUG_ON(!PageBuddy(page));
+		list_del(&page->lru);
+		order = page_order(page);
+		zone->free_area[order].nr_free--;
+		rmv_page_order(page);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+		pfn += 1 << order;
+	}
+	spin_unlock_irq(&zone->lock);
+
+	/*After this, pages in the range can be freed one be one */
+	for (pfn = start; pfn < end; pfn++)
+		prep_new_page(pfn_to_page(pfn), 0, flag);
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
