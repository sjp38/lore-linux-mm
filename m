Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2A20A6B006C
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:33:37 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so13569035wgy.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:33:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 13si13033945wjt.165.2015.04.23.03.33.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 03:33:24 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/13] mm: meminit: Initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Date: Thu, 23 Apr 2015 11:33:10 +0100
Message-Id: <1429785196-7668-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch initalises all low memory struct pages and 2G of the highest zone
on each node during memory initialisation if CONFIG_DEFERRED_STRUCT_PAGE_INIT
is set. That config option cannot be set but will be available in a later
patch.  Parallel initialisation of struct page depends on some features
from memory hotplug and it is necessary to alter alter section annotations.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/base/node.c    | 11 +++++--
 include/linux/mmzone.h |  8 ++++++
 mm/Kconfig             | 18 ++++++++++++
 mm/internal.h          |  8 ++++++
 mm/page_alloc.c        | 78 ++++++++++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 117 insertions(+), 6 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 36fabe43cd44..d03e976b4431 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -361,12 +361,16 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 #define page_initialized(page)  (page->lru.next)
 
-static int get_nid_for_pfn(unsigned long pfn)
+static int get_nid_for_pfn(struct pglist_data *pgdat, unsigned long pfn)
 {
 	struct page *page;
 
 	if (!pfn_valid_within(pfn))
 		return -1;
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+	if (pgdat && pfn >= pgdat->first_deferred_pfn)
+		return early_pfn_to_nid(pfn);
+#endif
 	page = pfn_to_page(pfn);
 	if (!page_initialized(page))
 		return -1;
@@ -378,6 +382,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 {
 	int ret;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
+	struct pglist_data *pgdat = NODE_DATA(nid);
 
 	if (!mem_blk)
 		return -EFAULT;
@@ -390,7 +395,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int page_nid;
 
-		page_nid = get_nid_for_pfn(pfn);
+		page_nid = get_nid_for_pfn(pgdat, pfn);
 		if (page_nid < 0)
 			continue;
 		if (page_nid != nid)
@@ -429,7 +434,7 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
 
-		nid = get_nid_for_pfn(pfn);
+		nid = get_nid_for_pfn(NULL, pfn);
 		if (nid < 0)
 			continue;
 		if (!node_online(nid))
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e3d8a2bd8d78..4882c53b70b5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -762,6 +762,14 @@ typedef struct pglist_data {
 	/* Number of pages migrated during the rate limiting time interval */
 	unsigned long numabalancing_migrate_nr_pages;
 #endif
+
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+	/*
+	 * If memory initialisation on large machines is deferred then this
+	 * is the first PFN that needs to be initialised.
+	 */
+	unsigned long first_deferred_pfn;
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/Kconfig b/mm/Kconfig
index a03131b6ba8e..3e40cb64e226 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -629,3 +629,21 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+# For architectures that support deferred memory initialisation
+config ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
+	bool
+
+config DEFERRED_STRUCT_PAGE_INIT
+	bool "Defer initialisation of struct pages to kswapd"
+	default n
+	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
+	depends on MEMORY_HOTPLUG
+	help
+	  Ordinarily all struct pages are initialised during early boot in a
+	  single thread. On very large machines this can take a considerable
+	  amount of time. If this option is set, large machines will bring up
+	  a subset of memmap at boot and then initialise the rest in parallel
+	  when kswapd starts. This has a potential performance impact on
+	  processes running early in the lifetime of the systemm until kswapd
+	  finishes the initialisation.
diff --git a/mm/internal.h b/mm/internal.h
index 76b605139c7a..4a73f74846bd 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -385,6 +385,14 @@ static inline void mminit_verify_zonelist(void)
 }
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+#define __defermem_init __meminit
+#define __defer_init    __meminit
+#else
+#define __defermem_init
+#define __defer_init __init
+#endif
+
 /* mminit_validate_memmodel_limits is independent of CONFIG_DEBUG_MEMORY_INIT */
 #if defined(CONFIG_SPARSEMEM)
 extern void mminit_validate_memmodel_limits(unsigned long *start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8b4659aa0bc2..c7c2d20c8bb5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -235,6 +235,64 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+static inline void reset_deferred_meminit(pg_data_t *pgdat)
+{
+	pgdat->first_deferred_pfn = ULONG_MAX;
+}
+
+/* Returns true if the struct page for the pfn is uninitialised */
+static inline bool __defermem_init early_page_uninitialised(unsigned long pfn)
+{
+	int nid = early_pfn_to_nid(pfn);
+
+	if (pfn >= NODE_DATA(nid)->first_deferred_pfn)
+		return true;
+
+	return false;
+}
+
+/*
+ * Returns false when the remaining initialisation should be deferred until
+ * later in the boot cycle when it can be parallelised.
+ */
+static inline bool update_defer_init(pg_data_t *pgdat,
+				unsigned long pfn, unsigned long zone_end,
+				unsigned long *nr_initialised)
+{
+	/* Always populate low zones for address-contrained allocations */
+	if (zone_end < pgdat_end_pfn(pgdat))
+		return true;
+
+	/* Initialise at least 2G of the highest zone */
+	(*nr_initialised)++;
+	if (*nr_initialised > (2UL << (30 - PAGE_SHIFT)) &&
+	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
+		pgdat->first_deferred_pfn = pfn;
+		return false;
+	}
+
+	return true;
+}
+#else
+static inline void reset_deferred_meminit(pg_data_t *pgdat)
+{
+}
+
+static inline bool early_page_uninitialised(unsigned long pfn)
+{
+	return false;
+}
+
+static inline bool update_defer_init(pg_data_t *pgdat,
+				unsigned long pfn, unsigned long zone_end,
+				unsigned long *nr_initialised)
+{
+	return true;
+}
+#endif
+
+
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 	if (unlikely(page_group_by_mobility_disabled &&
@@ -886,8 +944,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
-							unsigned int order)
+static void __defer_init __free_pages_boot_core(struct page *page,
+					unsigned long pfn, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page *p = page;
@@ -945,6 +1003,14 @@ static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 }
 #endif
 
+void __defer_init __free_pages_bootmem(struct page *page, unsigned long pfn,
+							unsigned int order)
+{
+	if (early_page_uninitialised(pfn))
+		return;
+	return __free_pages_boot_core(page, pfn, order);
+}
+
 #ifdef CONFIG_CMA
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
@@ -4217,14 +4283,16 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		unsigned long start_pfn, enum memmap_context context)
 {
+	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long end_pfn = start_pfn + size;
 	unsigned long pfn;
 	struct zone *z;
+	unsigned long nr_initialised = 0;
 
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
-	z = &NODE_DATA(nid)->node_zones[zone];
+	z = &pgdat->node_zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
 		 * There can be holes in boot-time mem_map[]s
@@ -4236,6 +4304,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 				continue;
 			if (!early_pfn_in_nid(pfn, nid))
 				continue;
+			if (!update_defer_init(pgdat, pfn, end_pfn,
+						&nr_initialised))
+				break;
 		}
 		__init_single_pfn(pfn, zone, nid);
 	}
@@ -5037,6 +5108,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	/* pg_data_t should be reset to zero when it's allocated */
 	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
 
+	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
