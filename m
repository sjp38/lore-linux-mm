Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8738F6B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 08:23:59 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d1-v6so14483794wrr.4
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 05:23:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l138-v6sor1396043wma.65.2018.08.01.05.23.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 05:23:57 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v6 3/5] mm: remove __paginginit
Date: Wed,  1 Aug 2018 14:23:46 +0200
Message-Id: <20180801122348.21588-4-osalvador@techadventures.net>
In-Reply-To: <20180801122348.21588-1-osalvador@techadventures.net>
References: <20180801122348.21588-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com

From: Pavel Tatashin <pasha.tatashin@oracle.com>

__paginginit is the same thing as __meminit except for platforms without
sparsemem, there it is defined as __init.

Remove __paginginit and use __meminit. Use __ref in one single function
that merges __meminit and __init sections: setup_usemap().

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
---
 mm/internal.h   | 12 ------------
 mm/page_alloc.c | 19 ++++++++++---------
 2 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 33c22754d282..87256ae1bef8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -389,18 +389,6 @@ static inline struct page *mem_map_next(struct page *iter,
 	return iter + 1;
 }
 
-/*
- * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
- * so all functions starting at paging_init should be marked __init
- * in those cases. SPARSEMEM, however, allows for memory hotplug,
- * and alloc_bootmem_node is not used.
- */
-#ifdef CONFIG_SPARSEMEM
-#define __paginginit __meminit
-#else
-#define __paginginit __init
-#endif
-
 /* Memory initialisation debug and verification */
 enum mminit_level {
 	MMINIT_WARNING,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 295977c6acae..607f98f8816d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6122,7 +6122,7 @@ static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned l
 	return usemapsize / 8;
 }
 
-static void __init setup_usemap(struct pglist_data *pgdat,
+static void __ref setup_usemap(struct pglist_data *pgdat,
 				struct zone *zone,
 				unsigned long zone_start_pfn,
 				unsigned long zonesize)
@@ -6142,7 +6142,7 @@ static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 
 /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
-void __paginginit set_pageblock_order(void)
+void __meminit set_pageblock_order(void)
 {
 	unsigned int order;
 
@@ -6170,14 +6170,14 @@ void __paginginit set_pageblock_order(void)
  * include/linux/pageblock-flags.h for the values of pageblock_order based on
  * the kernel config
  */
-void __paginginit set_pageblock_order(void)
+void __meminit set_pageblock_order(void)
 {
 }
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
-static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
-						   unsigned long present_pages)
+static unsigned long __meminit calc_memmap_size(unsigned long spanned_pages,
+						unsigned long present_pages)
 {
 	unsigned long pages = spanned_pages;
 
@@ -6235,7 +6235,7 @@ static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
  *
  * NOTE: pgdat should get zeroed by caller.
  */
-static void __paginginit free_area_init_core(struct pglist_data *pgdat)
+static void __meminit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
@@ -6366,8 +6366,9 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 
-void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
-		unsigned long node_start_pfn, unsigned long *zholes_size)
+void __meminit free_area_init_node(int nid, unsigned long *zones_size,
+				   unsigned long node_start_pfn,
+				   unsigned long *zholes_size)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long start_pfn = 0;
@@ -6412,7 +6413,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
  * may be accessed (for example page_to_pfn() on some configuration accesses
  * flags). We must explicitly zero those struct pages.
  */
-void __paginginit zero_resv_unavail(void)
+void __meminit zero_resv_unavail(void)
 {
 	phys_addr_t start, end;
 	unsigned long pfn;
-- 
2.13.6
