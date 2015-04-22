Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 26C776B0074
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 13:08:15 -0400 (EDT)
Received: by widdi4 with SMTP id di4so185920809wid.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:08:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u3si9992134wiy.42.2015.04.22.10.08.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 10:08:05 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/13] mm: meminit: Only a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Date: Wed, 22 Apr 2015 18:07:47 +0100
Message-Id: <1429722473-28118-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1429722473-28118-1-git-send-email-mgorman@suse.de>
References: <1429722473-28118-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch initalises all low memory struct pages and 2G of the highest zone
on each node during memory initialisation if CONFIG_DEFERRED_STRUCT_PAGE_INIT
is set. That config option cannot be set but will be available in a later
patch.  Parallel initialisation of struct page depends on some features
from memory hotplug and it is necessary to alter alter section annotations.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  8 +++++
 mm/internal.h          |  8 +++++
 mm/page_alloc.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 94 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f78ca65a9884..821f5000dec9 100644
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
index b148c9921740..2d649e0a1f9e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -235,6 +235,67 @@ EXPORT_SYMBOL(nr_online_nodes);
 
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
+	if (!deferred_mem_init_enabled)
+		return true;
+
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
@@ -886,8 +947,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
-							unsigned int order)
+static void __defer_init __free_pages_boot_core(struct page *page,
+					unsigned long pfn, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page *p = page;
@@ -950,6 +1011,14 @@ static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
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
@@ -4222,14 +4291,16 @@ static void setup_zone_migrate_reserve(struct zone *zone)
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
@@ -4241,6 +4312,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 				continue;
 			if (!early_pfn_in_nid(pfn, nid))
 				continue;
+			if (!update_defer_init(pgdat, pfn, end_pfn,
+						&nr_initialised))
+				break;
 		}
 		__init_single_pfn(pfn, zone, nid);
 	}
@@ -5042,6 +5116,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	/* pg_data_t should be reset to zero when it's allocated */
 	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
 
+	reset_deferred_meminit(pgdat);
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
