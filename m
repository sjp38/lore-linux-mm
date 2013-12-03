Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id EC2376B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 09:57:27 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so576972eek.1
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 06:57:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si3343356eeo.74.2013.12.03.06.57.26
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 06:57:27 -0800 (PST)
Date: Tue, 3 Dec 2013 14:57:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm, show_mem: Remove SHOW_MEM_FILTER_PAGE_COUNT
Message-ID: <20131203145721.GQ11295@suse.de>
References: <20131016104228.GM11028@suse.de>
 <alpine.DEB.2.02.1310161809470.12062@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1310161809470.12062@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, James Bottomley <jejb@parisc-linux.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Commit 4b59e6c4 (mm, show_mem: suppress page counts in non-blockable
contexts) introduced SHOW_MEM_FILTER_PAGE_COUNT to suppress PFN walks
on large memory machines. Commit c78e9363 (mm: do not walk all of system
memory during show_mem) avoided a PFN walk in the generic show_mem helper
which removes the requirement for SHOW_MEM_FILTER_PAGE_COUNT in that case.

This patch removes PFN walkers from the arch-specific implementations that
report on a per-node or per-zone granularity. ARM and unicore32 still do
a PFN walk as they report memory usage on each bank which is a much finer
granularity where the debugging information may still be of use. As the
remaining arches doing PFN walks have relatively small amounts of memory,
this patch simply removes SHOW_MEM_FILTER_PAGE_COUNT.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/arm/mm/init.c       |  3 ---
 arch/ia64/mm/contig.c    | 68 ------------------------------------------------
 arch/ia64/mm/discontig.c | 63 --------------------------------------------
 arch/ia64/mm/init.c      | 48 ++++++++++++++++++++++++++++++++++
 arch/parisc/mm/init.c    | 62 ++++++++++++++-----------------------------
 arch/unicore32/mm/init.c |  3 ---
 include/linux/mm.h       |  1 -
 lib/show_mem.c           |  3 ---
 mm/page_alloc.c          |  7 -----
 9 files changed, 68 insertions(+), 190 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 3e8f106..2e71e24 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -92,9 +92,6 @@ void show_mem(unsigned int filter)
 	printk("Mem-info:\n");
 	show_free_areas(filter);
 
-	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
-		return;
-
 	for_each_bank (i, mi) {
 		struct membank *bank = &mi->bank[i];
 		unsigned int pfn1, pfn2;
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index da5237d..52715a7 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -31,74 +31,6 @@
 static unsigned long max_gap;
 #endif
 
-/**
- * show_mem - give short summary of memory stats
- *
- * Shows a simple page count of reserved and used pages in the system.
- * For discontig machines, it does this on a per-pgdat basis.
- */
-void show_mem(unsigned int filter)
-{
-	int i, total_reserved = 0;
-	int total_shared = 0, total_cached = 0;
-	unsigned long total_present = 0;
-	pg_data_t *pgdat;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas(filter);
-	printk(KERN_INFO "Node memory in pages:\n");
-	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
-		return;
-	for_each_online_pgdat(pgdat) {
-		unsigned long present;
-		unsigned long flags;
-		int shared = 0, cached = 0, reserved = 0;
-		int nid = pgdat->node_id;
-
-		if (skip_free_areas_node(filter, nid))
-			continue;
-		pgdat_resize_lock(pgdat, &flags);
-		present = pgdat->node_present_pages;
-		for(i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page;
-			if (unlikely(i % MAX_ORDER_NR_PAGES == 0))
-				touch_nmi_watchdog();
-			if (pfn_valid(pgdat->node_start_pfn + i))
-				page = pfn_to_page(pgdat->node_start_pfn + i);
-			else {
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-				if (max_gap < LARGE_GAP)
-					continue;
-#endif
-				i = vmemmap_find_next_valid_pfn(nid, i) - 1;
-				continue;
-			}
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (page_count(page))
-				shared += page_count(page)-1;
-		}
-		pgdat_resize_unlock(pgdat, &flags);
-		total_present += present;
-		total_reserved += reserved;
-		total_cached += cached;
-		total_shared += shared;
-		printk(KERN_INFO "Node %4d:  RAM: %11ld, rsvd: %8d, "
-		       "shrd: %10d, swpd: %10d\n", nid,
-		       present, reserved, shared, cached);
-	}
-	printk(KERN_INFO "%ld pages of RAM\n", total_present);
-	printk(KERN_INFO "%d reserved pages\n", total_reserved);
-	printk(KERN_INFO "%d pages shared\n", total_shared);
-	printk(KERN_INFO "%d pages swap cached\n", total_cached);
-	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       quicklist_total_size());
-	printk(KERN_INFO "%ld free buffer pages\n", nr_free_buffer_pages());
-}
-
-
 /* physical address where the bootmem map is located */
 unsigned long bootmap_start;
 
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 2de08f4..8786268 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -608,69 +608,6 @@ void *per_cpu_init(void)
 #endif /* CONFIG_SMP */
 
 /**
- * show_mem - give short summary of memory stats
- *
- * Shows a simple page count of reserved and used pages in the system.
- * For discontig machines, it does this on a per-pgdat basis.
- */
-void show_mem(unsigned int filter)
-{
-	int i, total_reserved = 0;
-	int total_shared = 0, total_cached = 0;
-	unsigned long total_present = 0;
-	pg_data_t *pgdat;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas(filter);
-	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
-		return;
-	printk(KERN_INFO "Node memory in pages:\n");
-	for_each_online_pgdat(pgdat) {
-		unsigned long present;
-		unsigned long flags;
-		int shared = 0, cached = 0, reserved = 0;
-		int nid = pgdat->node_id;
-
-		if (skip_free_areas_node(filter, nid))
-			continue;
-		pgdat_resize_lock(pgdat, &flags);
-		present = pgdat->node_present_pages;
-		for(i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page;
-			if (unlikely(i % MAX_ORDER_NR_PAGES == 0))
-				touch_nmi_watchdog();
-			if (pfn_valid(pgdat->node_start_pfn + i))
-				page = pfn_to_page(pgdat->node_start_pfn + i);
-			else {
-				i = vmemmap_find_next_valid_pfn(nid, i) - 1;
-				continue;
-			}
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (page_count(page))
-				shared += page_count(page)-1;
-		}
-		pgdat_resize_unlock(pgdat, &flags);
-		total_present += present;
-		total_reserved += reserved;
-		total_cached += cached;
-		total_shared += shared;
-		printk(KERN_INFO "Node %4d:  RAM: %11ld, rsvd: %8d, "
-		       "shrd: %10d, swpd: %10d\n", nid,
-		       present, reserved, shared, cached);
-	}
-	printk(KERN_INFO "%ld pages of RAM\n", total_present);
-	printk(KERN_INFO "%d reserved pages\n", total_reserved);
-	printk(KERN_INFO "%d pages shared\n", total_shared);
-	printk(KERN_INFO "%d pages swap cached\n", total_cached);
-	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       quicklist_total_size());
-	printk(KERN_INFO "%ld free buffer pages\n", nr_free_buffer_pages());
-}
-
-/**
  * call_pernode_memory - use SRAT to call callback functions with node info
  * @start: physical start of range
  * @len: length of range
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 88504ab..25c3502 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -684,3 +684,51 @@ per_linux32_init(void)
 }
 
 __initcall(per_linux32_init);
+
+/**
+ * show_mem - give short summary of memory stats
+ *
+ * Shows a simple page count of reserved and used pages in the system.
+ * For discontig machines, it does this on a per-pgdat basis.
+ */
+void show_mem(unsigned int filter)
+{
+	int total_reserved = 0;
+	unsigned long total_present = 0;
+	pg_data_t *pgdat;
+
+	printk(KERN_INFO "Mem-info:\n");
+	show_free_areas(filter);
+	printk(KERN_INFO "Node memory in pages:\n");
+	for_each_online_pgdat(pgdat) {
+		unsigned long present;
+		unsigned long flags;
+		int reserved = 0;
+		int nid = pgdat->node_id;
+		int zoneid;
+
+		if (skip_free_areas_node(filter, nid))
+			continue;
+		pgdat_resize_lock(pgdat, &flags);
+
+		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+			struct zone *zone = &pgdat->node_zones[zoneid];
+			if (!populated_zone(zone))
+				continue;
+
+			reserved += zone->present_pages - zone->managed_pages;
+		}
+		present = pgdat->node_present_pages;
+
+		pgdat_resize_unlock(pgdat, &flags);
+		total_present += present;
+		total_reserved += reserved;
+		printk(KERN_INFO "Node %4d:  RAM: %11ld, rsvd: %8d, ",
+		       nid, present, reserved);
+	}
+	printk(KERN_INFO "%ld pages of RAM\n", total_present);
+	printk(KERN_INFO "%d reserved pages\n", total_reserved);
+	printk(KERN_INFO "Total of %ld pages in page table cache\n",
+	       quicklist_total_size());
+	printk(KERN_INFO "%ld free buffer pages\n", nr_free_buffer_pages());
+}
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index b0f96c0..e12d5a7 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -632,55 +632,33 @@ EXPORT_SYMBOL(empty_zero_page);
 
 void show_mem(unsigned int filter)
 {
-	int i,free = 0,total = 0,reserved = 0;
-	int shared = 0, cached = 0;
+	int total = 0,reserved = 0;
+	pg_data_t *pgdat;
 
 	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas(filter);
-	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
-		return;
-#ifndef CONFIG_DISCONTIGMEM
-	i = max_mapnr;
-	while (i-- > 0) {
-		total++;
-		if (PageReserved(mem_map+i))
-			reserved++;
-		else if (PageSwapCache(mem_map+i))
-			cached++;
-		else if (!page_count(&mem_map[i]))
-			free++;
-		else
-			shared += page_count(&mem_map[i]) - 1;
-	}
-#else
-	for (i = 0; i < npmem_ranges; i++) {
-		int j;
 
-		for (j = node_start_pfn(i); j < node_end_pfn(i); j++) {
-			struct page *p;
-			unsigned long flags;
-
-			pgdat_resize_lock(NODE_DATA(i), &flags);
-			p = nid_page_nr(i, j) - node_start_pfn(i);
-
-			total++;
-			if (PageReserved(p))
-				reserved++;
-			else if (PageSwapCache(p))
-				cached++;
-			else if (!page_count(p))
-				free++;
-			else
-				shared += page_count(p) - 1;
-			pgdat_resize_unlock(NODE_DATA(i), &flags);
-        	}
+	for_each_online_pgdat(pgdat) {
+		unsigned long flags;
+		int zoneid;
+
+		pgdat_resize_lock(pgdat, &flags);
+		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+			struct zone *zone = &pgdat->node_zones[zoneid];
+			if (!populated_zone(zone))
+				continue;
+
+			total += zone->present_pages;
+			reserved = zone->present_pages - zone->managed_pages;
+
+			if (is_highmem_idx(zoneid))
+				highmem += zone->present_pages;
+		}
+		pgdat_resize_unlock(pgdat, &flags);
 	}
-#endif
+
 	printk(KERN_INFO "%d pages of RAM\n", total);
 	printk(KERN_INFO "%d reserved pages\n", reserved);
-	printk(KERN_INFO "%d pages shared\n", shared);
-	printk(KERN_INFO "%d pages swap cached\n", cached);
-
 
 #ifdef CONFIG_DISCONTIGMEM
 	{
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index ae6bc03..be2bde9 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -66,9 +66,6 @@ void show_mem(unsigned int filter)
 	printk(KERN_DEFAULT "Mem-info:\n");
 	show_free_areas(filter);
 
-	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
-		return;
-
 	for_each_bank(i, mi) {
 		struct membank *bank = &mi->bank[i];
 		unsigned int pfn1, pfn2;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd00..42b2486 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -984,7 +984,6 @@ extern void pagefault_out_of_memory(void);
  * various contexts.
  */
 #define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
-#define SHOW_MEM_FILTER_PAGE_COUNT	(0x0002u)	/* page type count */
 
 extern void show_free_areas(unsigned int flags);
 extern bool skip_free_areas_node(unsigned int flags, int nid);
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 5847a49..f58689f 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -17,9 +17,6 @@ void show_mem(unsigned int filter)
 	printk("Mem-Info:\n");
 	show_free_areas(filter);
 
-	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
-		return;
-
 	for_each_online_pgdat(pgdat) {
 		unsigned long flags;
 		int zoneid;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 580a5f0..dcb61e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2073,13 +2073,6 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 		return;
 
 	/*
-	 * Walking all memory to count page types is very expensive and should
-	 * be inhibited in non-blockable contexts.
-	 */
-	if (!(gfp_mask & __GFP_WAIT))
-		filter |= SHOW_MEM_FILTER_PAGE_COUNT;
-
-	/*
 	 * This documents exceptions given to allocations in certain
 	 * contexts that are allowed to allocate outside current's set
 	 * of allowed nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
