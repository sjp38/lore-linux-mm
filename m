From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080416135218.1346.41125.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/4] Make defencive checks around PFN values registered for memory usage
Date: Wed, 16 Apr 2008 14:52:18 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

There are a number of different views to how much memory is currently
active. There is the arch-independent zone-sizing view, the bootmem allocator
and SPARSEMEMs view.  Architectures register this information at different
times and is not necessarily in sync particularly with view to some SPARSEMEM
limitations.

This patch introduces mminit_validate_physlimits() which is able to validate
and correct PFN ranges with respect to SPARSEMEM limitations. Ordinarily
they will be fixed silently but if mminit_debug_level is MMINIT_VERIFY or
higher, a message will be printed to dmesg.

This fixes the same problem as fixed by "[patch] mm: sparsemem
memory_present() memory corruption fix" in a slightly different way. This
patch would obviously be rebased on top of that fix.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/bootmem.c    |    1 +
 mm/internal.h   |    9 +++++++++
 mm/page_alloc.c |    2 ++
 mm/sparse.c     |   24 ++++++++++++++++++++++++
 4 files changed, 36 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0030_display_zonelist/mm/bootmem.c linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/bootmem.c
--- linux-2.6.25-rc9-0030_display_zonelist/mm/bootmem.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/bootmem.c	2008-04-16 14:45:08.000000000 +0100
@@ -91,6 +91,7 @@ static unsigned long __init init_bootmem
 	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long mapsize;
 
+	mminit_validate_physlimits(&start, &end);
 	bdata->node_bootmem_map = phys_to_virt(PFN_PHYS(mapstart));
 	bdata->node_boot_start = PFN_PHYS(start);
 	bdata->node_low_pfn = end;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0030_display_zonelist/mm/internal.h linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/internal.h
--- linux-2.6.25-rc9-0030_display_zonelist/mm/internal.h	2008-04-16 14:44:46.000000000 +0100
+++ linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/internal.h	2008-04-16 14:45:08.000000000 +0100
@@ -67,6 +67,15 @@ enum mminit_levels {
 	MMINIT_TRACE
 };
 
+#ifdef CONFIG_SPARSEMEM
+extern void mminit_validate_physlimits(unsigned long *start_pfn,
+				unsigned long *end_pfn);
+#else
+static inline void mminit_validate_physlimits(unsigned long *start_pfn,
+				unsigned long *end_pfn)
+{
+}
+#endif /* CONFIG_SPARSEMEM */
 extern void mminit_verify_zonelist(void);
 extern void mminit_verify_pageflags(void);
 extern void mminit_verify_page_links(struct page *page, enum zone_type zone,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0030_display_zonelist/mm/page_alloc.c linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/page_alloc.c
--- linux-2.6.25-rc9-0030_display_zonelist/mm/page_alloc.c	2008-04-16 14:44:46.000000000 +0100
+++ linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/page_alloc.c	2008-04-16 14:45:08.000000000 +0100
@@ -3511,6 +3511,8 @@ void __init add_active_range(unsigned in
 			  nid, start_pfn, end_pfn,
 			  nr_nodemap_entries, MAX_ACTIVE_REGIONS);
 
+	mminit_validate_physlimits(&start_pfn, &end_pfn);
+
 	/* Merge with existing active regions if possible */
 	for (i = 0; i < nr_nodemap_entries; i++) {
 		if (early_node_map[i].nid != nid)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0030_display_zonelist/mm/sparse.c linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/sparse.c
--- linux-2.6.25-rc9-0030_display_zonelist/mm/sparse.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0040_defensive_pfn_checks/mm/sparse.c	2008-04-16 14:45:08.000000000 +0100
@@ -11,6 +11,7 @@
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
+#include "internal.h"
 
 /*
  * Permanent SPARSEMEM data:
@@ -146,12 +147,34 @@ static inline int sparse_early_nid(struc
 	return (section->section_mem_map >> SECTION_NID_SHIFT);
 }
 
+/* Validate the physical addressing limitations of the model */
+void __meminit mminit_validate_physlimits(unsigned long *start_pfn,
+						unsigned long *end_pfn)
+{
+	unsigned long max_sparsemem_pfn = 1UL << (MAX_PHYSMEM_BITS-PAGE_SHIFT);
+	if (*start_pfn > max_sparsemem_pfn) {
+		mminit_debug_printk(MMINIT_VERIFY, "pfnvalidation",
+			"Start of range %lu -> %lu exceeds SPARSEMEM max %lu\n",
+			*start_pfn, *end_pfn, max_sparsemem_pfn);
+		*start_pfn = max_sparsemem_pfn;
+		*end_pfn = max_sparsemem_pfn;
+	}
+
+	if (*end_pfn > max_sparsemem_pfn) {
+		mminit_debug_printk(MMINIT_VERIFY, "pfnvalidation",
+			"End of range %lu -> %lu exceeds SPARSEMEM max %lu\n",
+			*start_pfn, *end_pfn, max_sparsemem_pfn);
+		*end_pfn = max_sparsemem_pfn;
+	}
+}
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
 
 	start &= PAGE_SECTION_MASK;
+	mminit_validate_physlimits(&start, &end);
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
 		unsigned long section = pfn_to_section_nr(pfn);
 		struct mem_section *ms;
@@ -176,6 +199,7 @@ unsigned long __init node_memmap_size_by
 	unsigned long pfn;
 	unsigned long nr_pages = 0;
 
+	mminit_validate_physlimits(&start_pfn, &end_pfn);
 	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
 		if (nid != early_pfn_to_nid(pfn))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
