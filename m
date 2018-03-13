Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD6E6B0261
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:24:26 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id p5so719666ywg.5
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:24:26 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h206-v6si154737ybh.497.2018.03.13.11.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 11:24:24 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 2/2] mm: initialize pages on demand during boot
Date: Tue, 13 Mar 2018 14:23:55 -0400
Message-Id: <20180313182355.17669-3-pasha.tatashin@oracle.com>
In-Reply-To: <20180313182355.17669-1-pasha.tatashin@oracle.com>
References: <20180313182355.17669-1-pasha.tatashin@oracle.com>
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

Sergey Senozhatsky noticed that while deferred pages currently make sense
only on NUMA machines (we start one thread per latency node), CONFIG_NUMA
is not a requirement for CONFIG_DEFERRED_STRUCT_PAGE_INIT, so that is also
must be addressed in the patch.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Tested-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/memblock.h |  10 ---
 mm/memblock.c            |  23 ------
 mm/page_alloc.c          | 183 +++++++++++++++++++++++++++++++++++++----------
 3 files changed, 144 insertions(+), 72 deletions(-)

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
index b6ba6b7adadc..80a12c64b203 100644
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
index cada509e2176..529e2dce7d16 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -292,40 +292,6 @@ EXPORT_SYMBOL(nr_online_nodes);
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
@@ -361,10 +327,6 @@ static inline bool update_defer_init(pg_data_t *pgdat,
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
@@ -1611,6 +1573,117 @@ static int __init deferred_init_memmap(void *data)
 	pgdat_init_report_one_done();
 	return 0;
 }
+
+/*
+ * During boot we initialize deferred pages on-demand, as needed, but once
+ * page_alloc_init_late() has finished, the deferred pages are all initialized,
+ * and we can permanently disable that path.
+ */
+static DEFINE_STATIC_KEY_TRUE(deferred_pages);
+
+/*
+ * If this zone has deferred pages, try to grow it by initializing enough
+ * deferred pages to satisfy the allocation specified by order, rounded up to
+ * the nearest PAGES_PER_SECTION boundary.  So we're adding memory in increments
+ * of SECTION_SIZE bytes by initializing struct pages in increments of
+ * PAGES_PER_SECTION * sizeof(struct page) bytes.
+ *
+ * Return true when zone was grown, otherwise return false. We return true even
+ * when we grow less than requested, to let the caller decide if there are
+ * enough pages to satisfy the allocation.
+ *
+ * Note: We use noinline because this function is needed only during boot, and
+ * it is called from a __ref function _deferred_grow_zone. This way we are
+ * making sure that it is not inlined into permanent text section.
+ */
+static noinline bool __init
+deferred_grow_zone(struct zone *zone, unsigned int order)
+{
+	int zid = zone_idx(zone);
+	int nid = zone_to_nid(zone);
+	pg_data_t *pgdat = NODE_DATA(nid);
+	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
+	unsigned long nr_pages = 0;
+	unsigned long first_init_pfn, spfn, epfn, t, flags;
+	unsigned long first_deferred_pfn = pgdat->first_deferred_pfn;
+	phys_addr_t spa, epa;
+	u64 i;
+
+	/* Only the last zone may have deferred pages */
+	if (zone_end_pfn(zone) != pgdat_end_pfn(pgdat))
+		return false;
+
+	pgdat_resize_lock(pgdat, &flags);
+
+	/*
+	 * If deferred pages have been initialized while we were waiting for
+ 	 * the lock, return true, as the zone was grown.  The caller will retry
+	 * this zone.  We won't return to this function since the caller also
+	 * has this static branch.
+	 */
+	if (!static_branch_unlikely(&deferred_pages)) {
+		pgdat_resize_unlock(pgdat, &flags);
+		return true;
+	}
+
+	/*
+	 * If someone grew this zone while we were waiting for spinlock, return
+	 * true, as there might be enough pages already.
+	 */
+	if (first_deferred_pfn != pgdat->first_deferred_pfn) {
+		pgdat_resize_unlock(pgdat, &flags);
+		return true;
+	}
+
+	first_init_pfn = max(zone->zone_start_pfn, first_deferred_pfn);
+
+	if (first_init_pfn >= pgdat_end_pfn(pgdat)) {
+		pgdat_resize_unlock(pgdat, &flags);
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
+	pgdat->first_deferred_pfn = first_deferred_pfn;
+	pgdat_resize_unlock(pgdat, &flags);
+
+	return nr_pages > 0;
+}
+
+/*
+ * deferred_grow_zone() is __init, but it is called from
+ * get_page_from_freelist() during early boot until deferred_pages permanently
+ * disables this call. This is why we have refdata wrapper to avoid warning,
+ * and to ensure that the function body gets unloaded.
+ */
+static bool __ref
+_deferred_grow_zone(struct zone *zone, unsigned int order)
+{
+	return deferred_grow_zone(zone, order);
+}
+
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 void __init page_alloc_init_late(void)
@@ -1629,6 +1702,12 @@ void __init page_alloc_init_late(void)
 	/* Block until all are initialised */
 	wait_for_completion(&pgdat_init_all_done_comp);
 
+	/*
+	 * We initialized the rest of the deferred pages.  Permanently disable
+	 * on-demand struct page initialization.
+	 */
+	static_branch_disable(&deferred_pages);
+
 	/* Reinit limits that are based on free pages after the kernel is up */
 	files_maxfiles_init();
 #endif
@@ -3206,6 +3285,16 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -3247,6 +3336,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
 
@@ -6259,7 +6356,15 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 
 	alloc_node_mem_map(pgdat);
 
-	reset_deferred_meminit(pgdat);
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+	/*
+	 * We start only with one section of pages, more pages are added as
+	 * needed until the rest of deferred pages are initialized.
+	 */
+	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
+					 pgdat->node_spanned_pages);
+	pgdat->first_deferred_pfn = ULONG_MAX;
+#endif
 	free_area_init_core(pgdat);
 }
 
-- 
2.16.2
