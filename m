Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9237D6B0006
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 13:51:26 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id e186so5057785iof.9
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 10:51:26 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l6si414312iog.344.2018.02.08.10.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 10:51:25 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 1/1] mm: initialize pages on demand during boot
Date: Thu,  8 Feb 2018 13:45:55 -0500
Message-Id: <20180208184555.5855-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180208184555.5855-1-pasha.tatashin@oracle.com>
References: <20180208184555.5855-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Deferred page initialization allows the boot cpu to initialize a small
subset of the system's pages early in boot, with other cpus doing the rest
later on.

It is, however, problematic to know how many pages the kernel needs during
boot.  Different modules and kernel parameters may change the requirement,
so the boot cpu either initializes too many pages or runs out of memory.

To fix that, initialize early pages on demand.  This ensures the kernel
does the minimum amount of work to initialize pages during boot and leaves
the rest to be divided in the multithreaded initialization path
(deferred_init_memmap).

The on-demand code is permanently disabled using static branching once
deferred pages are initialized.  After the static branch is changed to
false, the overhead is up-to two branch-always instructions if the zone
watermark check fails or if rmqueue fails.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Tested-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
---
 include/linux/memblock.h |  10 ---
 mm/memblock.c            |  23 -------
 mm/page_alloc.c          | 164 ++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 125 insertions(+), 72 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 8be5077efb5f..6c305afd95ab 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -417,21 +417,11 @@ static inline void early_memtest(phys_addr_t start, phys_addr_t end)
 {
 }
 #endif
-
-extern unsigned long memblock_reserved_memory_within(phys_addr_t start_addr,
-		phys_addr_t end_addr);
 #else
 static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
 {
 	return 0;
 }
-
-static inline unsigned long memblock_reserved_memory_within(phys_addr_t start_addr,
-		phys_addr_t end_addr)
-{
-	return 0;
-}
-
 #endif /* CONFIG_HAVE_MEMBLOCK */
 
 #endif /* __KERNEL__ */
diff --git a/mm/memblock.c b/mm/memblock.c
index 5a9ca2a1751b..4120e9f536f7 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1778,29 +1778,6 @@ static void __init_memblock memblock_dump(struct memblock_type *type)
 	}
 }
 
-extern unsigned long __init_memblock
-memblock_reserved_memory_within(phys_addr_t start_addr, phys_addr_t end_addr)
-{
-	struct memblock_region *rgn;
-	unsigned long size = 0;
-	int idx;
-
-	for_each_memblock_type(idx, (&memblock.reserved), rgn) {
-		phys_addr_t start, end;
-
-		if (rgn->base + rgn->size < start_addr)
-			continue;
-		if (rgn->base > end_addr)
-			continue;
-
-		start = rgn->base;
-		end = start + rgn->size;
-		size += end - start;
-	}
-
-	return size;
-}
-
 void __init_memblock __memblock_dump_all(void)
 {
 	pr_info("MEMBLOCK configuration:\n");
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 81e18ceef579..13d56b28e68e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -291,40 +291,6 @@ EXPORT_SYMBOL(nr_online_nodes);
 int page_group_by_mobility_disabled __read_mostly;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-
-/*
- * Determine how many pages need to be initialized during early boot
- * (non-deferred initialization).
- * The value of first_deferred_pfn will be set later, once non-deferred pages
- * are initialized, but for now set it ULONG_MAX.
- */
-static inline void reset_deferred_meminit(pg_data_t *pgdat)
-{
-	phys_addr_t start_addr, end_addr;
-	unsigned long max_pgcnt;
-	unsigned long reserved;
-
-	/*
-	 * Initialise at least 2G of a node but also take into account that
-	 * two large system hashes that can take up 1GB for 0.25TB/node.
-	 */
-	max_pgcnt = max(2UL << (30 - PAGE_SHIFT),
-			(pgdat->node_spanned_pages >> 8));
-
-	/*
-	 * Compensate the all the memblock reservations (e.g. crash kernel)
-	 * from the initial estimation to make sure we will initialize enough
-	 * memory to boot.
-	 */
-	start_addr = PFN_PHYS(pgdat->node_start_pfn);
-	end_addr = PFN_PHYS(pgdat->node_start_pfn + max_pgcnt);
-	reserved = memblock_reserved_memory_within(start_addr, end_addr);
-	max_pgcnt += PHYS_PFN(reserved);
-
-	pgdat->static_init_pgcnt = min(max_pgcnt, pgdat->node_spanned_pages);
-	pgdat->first_deferred_pfn = ULONG_MAX;
-}
-
 /* Returns true if the struct page for the pfn is uninitialised */
 static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 {
@@ -357,10 +323,6 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 	return true;
 }
 #else
-static inline void reset_deferred_meminit(pg_data_t *pgdat)
-{
-}
-
 static inline bool early_page_uninitialised(unsigned long pfn)
 {
 	return false;
@@ -1604,6 +1566,96 @@ static int __init deferred_init_memmap(void *data)
 	pgdat_init_report_one_done();
 	return 0;
 }
+
+/*
+ * Protects some early interrupt threads, and also for a short period of time
+ * from  smp_init() to page_alloc_init_late() when deferred pages are
+ * initialized.
+ */
+static __initdata DEFINE_SPINLOCK(deferred_zone_grow_lock);
+DEFINE_STATIC_KEY_TRUE(deferred_pages);
+
+/*
+ * If this zone has deferred pages, try to grow it by initializing enough
+ * deferred pages to satisfy the allocation specified by order, rounded up to
+ * the nearest PAGES_PER_SECTION boundary.  So we're adding memory in increments
+ * of SECTION_SIZE bytes by initializing struct pages in increments of
+ * PAGES_PER_SECTION * sizeof(struct page) bytes.
+ */
+static noinline bool __init
+deferred_grow_zone(struct zone *zone, unsigned int order)
+{
+	int zid = zone_idx(zone);
+	int nid = zone->node;
+	pg_data_t *pgdat = NODE_DATA(nid);
+	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
+	unsigned long nr_pages = 0;
+	unsigned long first_init_pfn, first_deferred_pfn, spfn, epfn, t;
+	phys_addr_t spa, epa;
+	u64 i;
+
+	/* Only the last zone may have deferred pages */
+	if (zone_end_pfn(zone) != pgdat_end_pfn(pgdat))
+		return false;
+
+	first_deferred_pfn = READ_ONCE(pgdat->first_deferred_pfn);
+	first_init_pfn = max(zone->zone_start_pfn, first_deferred_pfn);
+
+	if (first_init_pfn >= pgdat_end_pfn(pgdat))
+		return false;
+
+	spin_lock(&deferred_zone_grow_lock);
+	/*
+	 * Bail if we raced with another thread that disabled on demand
+	 * initialization.
+	 */
+	if (!static_branch_unlikely(&deferred_pages)) {
+		spin_unlock(&deferred_zone_grow_lock);
+		return false;
+	}
+
+	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
+		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
+		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+
+		while (spfn < epfn && nr_pages < nr_pages_needed) {
+			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
+			first_deferred_pfn = min(t, epfn);
+			nr_pages += deferred_init_pages(nid, zid, spfn,
+							first_deferred_pfn);
+			spfn = first_deferred_pfn;
+		}
+
+		if (nr_pages >= nr_pages_needed)
+			break;
+	}
+
+	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
+		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
+		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
+		deferred_free_pages(nid, zid, spfn, epfn);
+
+		if (first_deferred_pfn == epfn)
+			break;
+	}
+	WRITE_ONCE(pgdat->first_deferred_pfn, first_deferred_pfn);
+	spin_unlock(&deferred_zone_grow_lock);
+
+	return nr_pages >= nr_pages_needed;
+}
+
+/*
+ * deferred_grow_zone() is __init, but it is called from
+ * get_page_from_freelist() during early boot until deferred_pages permanently
+ * disables this call. This is why, we have refdata wrapper to avoid warning,
+ * and ensure that the function body gets unloaded.
+ */
+static bool __ref
+_deferred_grow_zone(struct zone *zone, unsigned int order)
+{
+	return deferred_grow_zone(zone, order);
+}
+
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 void __init page_alloc_init_late(void)
@@ -1613,6 +1665,14 @@ void __init page_alloc_init_late(void)
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	int nid;
 
+	/*
+	 * We are about to initialize the rest of deferred pages, permanently
+	 * disable on-demand struct page initialization.
+	 */
+	spin_lock(&deferred_zone_grow_lock);
+	static_branch_disable(&deferred_pages);
+	spin_unlock(&deferred_zone_grow_lock);
+
 	/* There will be num_node_state(N_MEMORY) threads */
 	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
 	for_each_node_state(nid, N_MEMORY) {
@@ -3199,6 +3259,16 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				       ac_classzone_idx(ac), alloc_flags)) {
 			int ret;
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+			/*
+			 * Watermark failed for this zone, but see if we can
+			 * grow this zone if it contains deferred pages.
+			 */
+			if (static_branch_unlikely(&deferred_pages)) {
+				if (_deferred_grow_zone(zone, order))
+					goto try_this_zone;
+			}
+#endif
 			/* Checked here to keep the fast path fast */
 			BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 			if (alloc_flags & ALLOC_NO_WATERMARKS)
@@ -3240,6 +3310,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				reserve_highatomic_pageblock(page, zone, order);
 
 			return page;
+		} else {
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+			/* Try again if zone has deferred pages */
+			if (static_branch_unlikely(&deferred_pages)) {
+				if (_deferred_grow_zone(zone, order))
+					goto try_this_zone;
+			}
+#endif
 		}
 	}
 
@@ -6247,7 +6325,15 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 
 	alloc_node_mem_map(pgdat);
 
-	reset_deferred_meminit(pgdat);
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+	/*
+	 * We start only with one section of pages, more pages are added as
+	 * needed until the rest of deferred pages are initialized.
+	 */
+	pgdat->static_init_pgcnt = min(PAGES_PER_SECTION,
+				       pgdat->node_spanned_pages);
+	pgdat->first_deferred_pfn = ULONG_MAX;
+#endif
 	free_area_init_core(pgdat);
 }
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
