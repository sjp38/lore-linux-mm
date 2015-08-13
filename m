Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0504F6B0256
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:56:02 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so28324690pac.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:56:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z5si1488873pdf.241.2015.08.12.20.56.00
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:56:01 -0700 (PDT)
Subject: [RFC PATCH 3/7] x86, mm: arch_add_dev_memory()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:50:17 -0400
Message-ID: <20150813035017.36913.83188.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, mgorman@suse.de, "H. Peter Anvin" <hpa@zytor.com>, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

Use struct vmem_altmap to augment vmemmap_{populate|free}().

In support of providing struct page coverage for persistent memory,
use struct vmem_altmap to change the default policy for mapping pfns for
a page range.  The default vmemmap_populate() allocates page table
storage area from the page allocator.  In support of storing struct page
infrastructure on device memory (pmem) directly vmem_altmap directs
vmmemap_populate() to use a pre-allocated block of contiguous pfns for
storage of the new vmemmap entries.

Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init_64.c          |   55 +++++++++++++++++++++++++++++++++++++---
 include/linux/memory_hotplug.h |    4 +++
 include/linux/mm.h             |   38 +++++++++++++++++++++++++++-
 mm/memory_hotplug.c            |   12 +++++++++
 mm/page_alloc.c                |    4 +++
 mm/sparse-vmemmap.c            |   31 +++++++++++++++++++++++
 mm/sparse.c                    |   17 +++++++++++-
 7 files changed, 154 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index c2f872a379d2..eda65ec8484e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -719,6 +719,21 @@ int arch_add_memory(int nid, u64 start, u64 size)
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);
 
+#ifdef CONFIG_ZONE_DEVICE
+/*
+ * The primary difference vs arch_add_memory is that the zone is known
+ * apriori.
+ */
+int arch_add_dev_memory(int nid, u64 start, u64 size,
+		struct vmem_altmap *altmap)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *zone = pgdat->node_zones + ZONE_DEVICE;
+
+	return __arch_add_memory(nid, start, size, zone, altmap);
+}
+#endif
+
 #define PAGE_INUSE 0xFD
 
 static void __meminit free_pagetable(struct page *page, int order)
@@ -771,8 +786,13 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud,
 			return;
 	}
 
-	/* free a pmd talbe */
-	free_pagetable(pud_page(*pud), 0);
+	/*
+	 * Free a pmd table if it came from the page allocator (i.e. !altmap).
+	 * In the altmap case the pages are being freed implicitly by the
+	 * section becoming unmapped / unplugged.
+	 */
+	if (!altmap)
+		free_pagetable(pud_page(*pud), 0);
 	spin_lock(&init_mm.page_table_lock);
 	pud_clear(pud);
 	spin_unlock(&init_mm.page_table_lock);
@@ -890,7 +910,7 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		if (pmd_large(*pmd)) {
 			if (IS_ALIGNED(addr, PMD_SIZE) &&
 			    IS_ALIGNED(next, PMD_SIZE)) {
-				if (!direct)
+				if (!direct && !altmap)
 					free_pagetable(pmd_page(*pmd),
 						       get_order(PMD_SIZE));
 
@@ -946,7 +966,7 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 		if (pud_large(*pud)) {
 			if (IS_ALIGNED(addr, PUD_SIZE) &&
 			    IS_ALIGNED(next, PUD_SIZE)) {
-				if (!direct)
+				if (!direct && !altmap)
 					free_pagetable(pud_page(*pud),
 						       get_order(PUD_SIZE));
 
@@ -993,6 +1013,8 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct,
 	pud_t *pud;
 	bool pgd_changed = false;
 
+	WARN_ON_ONCE(direct && altmap);
+
 	for (addr = start; addr < end; addr = next) {
 		next = pgd_addr_end(addr, end);
 
@@ -1041,6 +1063,31 @@ static int __ref __arch_remove_memory(u64 start, u64 size, struct zone *zone,
 			__phys_to_pfn(size), altmap);
 }
 
+int __ref arch_remove_dev_memory(u64 start, u64 size,
+		struct vmem_altmap *altmap)
+{
+	unsigned long pfn = __phys_to_pfn(start);
+	struct zone *zone;
+	int rc;
+
+	/*
+	 * Reserve pages will not have initialized pfns, so we need to
+	 * calulate the page zone from the first valid pfn.
+	 */
+	if (altmap) {
+		if (altmap->base_pfn != pfn) {
+			WARN_ONCE(1, "pfn: %#lx expected: %#lx\n",
+					pfn, altmap->base_pfn);
+			return -EINVAL;
+		}
+		pfn += altmap->reserve;
+	}
+	zone = page_zone(pfn_to_page(pfn));
+	rc = __arch_remove_memory(start, size, zone, altmap);
+	WARN_ON_ONCE(rc);
+	return rc;
+}
+
 int __ref arch_remove_memory(u64 start, u64 size)
 {
 	struct zone *zone = page_zone(pfn_to_page(__phys_to_pfn(start)));
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 48a4e0a5e13d..6a9f05e2c02f 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -102,6 +102,8 @@ extern int try_online_node(int nid);
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size);
+extern int arch_remove_dev_memory(u64 start, u64 size,
+		struct vmem_altmap *altmap);
 extern int __remove_pages_altmap(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages, struct vmem_altmap *altmap);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
@@ -279,6 +281,8 @@ extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 extern int add_memory(int nid, u64 start, u64 size);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default);
 extern int arch_add_memory(int nid, u64 start, u64 size);
+extern int arch_add_dev_memory(int nid, u64 start, u64 size,
+		struct vmem_altmap *altmap);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index de44de70e63a..8a4f24d7fdb0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2215,7 +2215,43 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long map_count,
 				   int nodeid);
 
-struct vmem_altmap;
+/**
+ * struct vmem_altmap - augment vmemap_populate with pre-allocated pte storage
+ * @base: first pfn of the allocation
+ * @reserve: number of pfns reserved by the device relative to base
+ * @free: range of memmap storage / offset to data from section0
+ * @alloc: tracks num pfns consumed for page map, private to vmemmap_populate()
+ */
+struct vmem_altmap {
+	const unsigned long base_pfn;
+	const unsigned long reserve;
+	unsigned long free;
+	unsigned long alloc;
+};
+
+static inline unsigned long vmem_altmap_nr_free(struct vmem_altmap *altmap)
+{
+	if (altmap->free > altmap->alloc)
+		return altmap->free - altmap->alloc;
+	return 0;
+}
+
+static inline unsigned long vmem_altmap_next_pfn(struct vmem_altmap *altmap)
+{
+	return altmap->base_pfn + altmap->alloc;
+}
+
+static inline unsigned long vmem_altmap_alloc(struct vmem_altmap *altmap,
+		unsigned long nr_pfns)
+{
+	unsigned long pfn = vmem_altmap_next_pfn(altmap);
+
+	if (nr_pfns > vmem_altmap_nr_free(altmap))
+		return ULONG_MAX;
+	altmap->alloc += nr_pfns;
+	return pfn;
+}
+
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid);
 struct page *sparse_alt_map_populate(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d4bcfeaaec37..79cb7595b659 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -505,6 +505,18 @@ int __ref __add_pages_altmap(int nid, struct zone *zone,
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
+	if (altmap) {
+		/*
+		 * Validate altmap is within bounds of the total request
+		 */
+		if (altmap->base_pfn != phys_start_pfn || (altmap->reserve
+					+ altmap->free) > nr_pages) {
+			pr_warn_once("memory add fail, invalid altmap\n");
+			return -EINVAL;
+		}
+		altmap->alloc = 0;
+	}
+
 	for (i = start_sec; i <= end_sec; i++) {
 		err = __add_section(nid, zone, section_nr_to_pfn(i), altmap);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c18520831dbc..498193b8811d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4590,6 +4590,10 @@ void __meminit __memmap_init_zone(unsigned long size, int nid,
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
+	/* skip initializing a number of pfns from the start of the section */
+	if (altmap && start_pfn == altmap->base_pfn)
+		start_pfn += altmap->reserve;
+
 	z = &pgdat->node_zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 16ec1675b793..6ea8027daf00 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -86,10 +86,41 @@ static void * __meminit __vmemmap_alloc_block_buf(unsigned long size, int node)
 	return ptr;
 }
 
+static void * __meminit altmap_alloc_block_buf(unsigned long size,
+		struct vmem_altmap *altmap)
+{
+	unsigned long pfn, start_pfn = vmem_altmap_next_pfn(altmap);
+	unsigned long align = 0;
+	void *ptr;
+
+	if (!is_power_of_2(size) || size < PAGE_SIZE) {
+		pr_warn_once("%s: allocations must be multiple of PAGE_SIZE (%ld)\n",
+				__func__, PAGE_SIZE);
+		return NULL;
+	}
+
+	size >>= PAGE_SHIFT;
+	if (start_pfn & (size - 1))
+		align = ALIGN(start_pfn, size) - start_pfn;
+
+	pfn = vmem_altmap_alloc(altmap, align + size);
+	if (pfn < ULONG_MAX)
+		ptr = __va(__pfn_to_phys(pfn));
+	else
+		ptr = NULL;
+	pr_debug("%s: start: %#lx align: %#lx next: %#lx nr: %#lx %p\n",
+			__func__, start_pfn, align,
+			vmem_altmap_next_pfn(altmap), size + align, ptr);
+
+	return ptr;
+}
+
 /* need to make sure size is all the same during early stage */
 void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node,
 		struct vmem_altmap *altmap)
 {
+	if (altmap)
+		return altmap_alloc_block_buf(size, altmap);
 	return __vmemmap_alloc_block_buf(size, node);
 }
 
diff --git a/mm/sparse.c b/mm/sparse.c
index eda783903b1d..529b16509eca 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -369,6 +369,13 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 }
 
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
+struct page __init *sparse_alt_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
+{
+	pr_warn_once("%s: requires CONFIG_SPARSEMEM_VMEMMAP=y\n", __func__);
+	return NULL;
+}
+
 struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid)
 {
 	struct page *map;
@@ -598,7 +605,10 @@ void __init sparse_init(void)
 static struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
-	return sparse_mem_map_populate(pnum, nid);
+	if (altmap)
+		return sparse_alt_map_populate(pnum, nid, altmap);
+	else
+		return sparse_mem_map_populate(pnum, nid);
 }
 
 static inline void free_section_memmap(struct page *memmap,
@@ -607,7 +617,10 @@ static inline void free_section_memmap(struct page *memmap,
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
-	__vmemmap_free(start, end, NULL);
+	if (altmap)
+		__vmemmap_free(start, end, altmap);
+	else
+		__vmemmap_free(start, end, NULL);
 }
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static void free_map_bootmem(struct page *memmap)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
