From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080428192939.23649.43846.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080428192839.23649.82172.sendpatchset@skynet.skynet.ie>
References: <20080428192839.23649.82172.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/4] Make defensive checks around PFN values registered for memory usage
Date: Mon, 28 Apr 2008 20:29:39 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, mingo@elte.hu, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

There are a number of different views to how much memory is currently
active. There is the arch-independent zone-sizing view, the bootmem allocator
and memory models view. Architectures register this information at different
times and is not necessarily in sync particularly with respect to some
SPARSEMEM limitations. This patch introduces mminit_validate_memmodel_limits()
which is able to validate and correct PFN ranges with respect to the
memory model. It is only SPARSEMEM that currently validates itself.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/bootmem.c    |    1 +
 mm/internal.h   |   12 ++++++++++++
 mm/page_alloc.c |    2 ++
 mm/sparse.c     |   37 +++++++++++++++++++++++++++++--------
 4 files changed, 44 insertions(+), 8 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020_memmap_init_debug/mm/bootmem.c linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/bootmem.c
--- linux-2.6.25-mm1-0020_memmap_init_debug/mm/bootmem.c	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/bootmem.c	2008-04-28 14:41:59.000000000 +0100
@@ -91,6 +91,7 @@ static unsigned long __init init_bootmem
 	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long mapsize;
 
+	mminit_validate_memmodel_limits(&start, &end);
 	bdata->node_bootmem_map = phys_to_virt(PFN_PHYS(mapstart));
 	bdata->node_boot_start = PFN_PHYS(start);
 	bdata->node_low_pfn = end;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020_memmap_init_debug/mm/internal.h linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/internal.h
--- linux-2.6.25-mm1-0020_memmap_init_debug/mm/internal.h	2008-04-28 14:41:48.000000000 +0100
+++ linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/internal.h	2008-04-28 14:41:59.000000000 +0100
@@ -98,4 +98,16 @@ static inline void mminit_verify_page_li
 {
 }
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
+
+/* mminit_validate_memmodel_limits is independent of CONFIG_DEBUG_MEMORY_INIT */
+#if defined(CONFIG_SPARSEMEM)
+extern void mminit_validate_memmodel_limits(unsigned long *start_pfn,
+				unsigned long *end_pfn);
+#else
+static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
+				unsigned long *end_pfn)
+{
+}
+#endif /* CONFIG_SPARSEMEM */
+
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020_memmap_init_debug/mm/page_alloc.c linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/page_alloc.c
--- linux-2.6.25-mm1-0020_memmap_init_debug/mm/page_alloc.c	2008-04-28 14:41:48.000000000 +0100
+++ linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/page_alloc.c	2008-04-28 14:41:59.000000000 +0100
@@ -3623,6 +3623,8 @@ void __init add_active_range(unsigned in
 			  nid, start_pfn, end_pfn,
 			  nr_nodemap_entries, MAX_ACTIVE_REGIONS);
 
+	mminit_validate_memmodel_limits(&start_pfn, &end_pfn);
+
 	/* Merge with existing active regions if possible */
 	for (i = 0; i < nr_nodemap_entries; i++) {
 		if (early_node_map[i].nid != nid)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020_memmap_init_debug/mm/sparse.c linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/sparse.c
--- linux-2.6.25-mm1-0020_memmap_init_debug/mm/sparse.c	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/sparse.c	2008-04-28 14:41:59.000000000 +0100
@@ -12,6 +12,7 @@
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
+#include "internal.h"
 
 /*
  * Permanent SPARSEMEM data:
@@ -147,22 +148,41 @@ static inline int sparse_early_nid(struc
 	return (section->section_mem_map >> SECTION_NID_SHIFT);
 }
 
-/* Record a memory area against a node. */
-void __init memory_present(int nid, unsigned long start, unsigned long end)
+/* Validate the physical addressing limitations of the model */
+void __meminit mminit_validate_memmodel_limits(unsigned long *start_pfn,
+						unsigned long *end_pfn)
 {
-	unsigned long max_arch_pfn = 1UL << (MAX_PHYSMEM_BITS-PAGE_SHIFT);
-	unsigned long pfn;
+	unsigned long max_sparsemem_pfn = 1UL << (MAX_PHYSMEM_BITS-PAGE_SHIFT);
 
 	/*
 	 * Sanity checks - do not allow an architecture to pass
 	 * in larger pfns than the maximum scope of sparsemem:
 	 */
-	if (start >= max_arch_pfn)
-		return;
-	if (end >= max_arch_pfn)
-		end = max_arch_pfn;
+	if (*start_pfn > max_sparsemem_pfn) {
+		mminit_dprintk(MMINIT_WARNING, "pfnvalidation",
+			"Start of range %lu -> %lu exceeds SPARSEMEM max %lu\n",
+			*start_pfn, *end_pfn, max_sparsemem_pfn);
+		WARN_ON_ONCE(1);
+		*start_pfn = max_sparsemem_pfn;
+		*end_pfn = max_sparsemem_pfn;
+	}
+
+	if (*end_pfn > max_sparsemem_pfn) {
+		mminit_dprintk(MMINIT_WARNING, "pfnvalidation",
+			"End of range %lu -> %lu exceeds SPARSEMEM max %lu\n",
+			*start_pfn, *end_pfn, max_sparsemem_pfn);
+		WARN_ON_ONCE(1);
+		*end_pfn = max_sparsemem_pfn;
+	}
+}
+
+/* Record a memory area against a node. */
+void __init memory_present(int nid, unsigned long start, unsigned long end)
+{
+	unsigned long pfn;
 
 	start &= PAGE_SECTION_MASK;
+	mminit_validate_memmodel_limits(&start, &end);
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
 		unsigned long section = pfn_to_section_nr(pfn);
 		struct mem_section *ms;
@@ -187,6 +207,7 @@ unsigned long __init node_memmap_size_by
 	unsigned long pfn;
 	unsigned long nr_pages = 0;
 
+	mminit_validate_memmodel_limits(&start_pfn, &end_pfn);
 	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
 		if (nid != early_pfn_to_nid(pfn))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
