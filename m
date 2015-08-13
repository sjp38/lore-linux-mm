Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF1686B0256
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:55:55 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so28276095pab.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:55:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id le8si1499822pab.136.2015.08.12.20.55.54
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:55:54 -0700 (PDT)
Subject: [RFC PATCH 2/7] x86, mm: introduce struct vmem_altmap
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:50:11 -0400
Message-ID: <20150813035011.36913.42952.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, mgorman@suse.de, "H. Peter Anvin" <hpa@zytor.com>, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

This is a preparation patch only, no functional changes.  It simply
makes the following patch easier to read.  struct vmem_altmap modifies
the memory hotplug code to enable it to map "device memory" while
allocating the storage for struct page from that same capacity. The
first user of this capability will be the pmem driver for persistent
memory.

Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/mm/init_64.c      |    7 ++++
 arch/x86/mm/init_64.c          |   79 ++++++++++++++++++++++++++--------------
 include/linux/memory_hotplug.h |   17 ++++++++-
 include/linux/mm.h             |   13 ++++++-
 mm/memory_hotplug.c            |   67 +++++++++++++++++++++-------------
 mm/page_alloc.c                |   11 +++++-
 mm/sparse-vmemmap.c            |   29 ++++++++++++---
 mm/sparse.c                    |   29 +++++++++------
 8 files changed, 177 insertions(+), 75 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index d747dd7bc90b..e3e367399935 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -404,6 +404,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 		}
 	}
 }
+
+void __ref __vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
+{
+	WARN_ONCE(altmap, "vmem_altmap support not implemented.\n");
+	return vmemmap_free(start, end);
+}
 #endif
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 94f0fa56f0ed..c2f872a379d2 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -683,7 +683,8 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-static int __arch_add_memory(int nid, u64 start, u64 size, struct zone *zone)
+static int __arch_add_memory(int nid, u64 start, u64 size, struct zone *zone,
+		struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -691,7 +692,7 @@ static int __arch_add_memory(int nid, u64 start, u64 size, struct zone *zone)
 
 	init_memory_mapping(start, start + size);
 
-	ret = __add_pages(nid, zone, start_pfn, nr_pages);
+	ret = __add_pages_altmap(nid, zone, start_pfn, nr_pages, altmap);
 	WARN_ON_ONCE(ret);
 
 	/*
@@ -714,7 +715,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	struct zone *zone = pgdat->node_zones +
 		zone_for_memory(nid, start, size, ZONE_NORMAL);
 
-	return __arch_add_memory(nid, start, size, zone);
+	return __arch_add_memory(nid, start, size, zone, NULL);
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);
 
@@ -758,7 +759,8 @@ static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd)
 	spin_unlock(&init_mm.page_table_lock);
 }
 
-static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
+static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud,
+		struct vmem_altmap *altmap)
 {
 	pmd_t *pmd;
 	int i;
@@ -869,9 +871,9 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 		update_page_count(PG_LEVEL_4K, -pages);
 }
 
-static void __meminit
+static void noinline __meminit
 remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 bool direct, struct vmem_altmap *altmap)
 {
 	unsigned long next, pages = 0;
 	pte_t *pte_base;
@@ -925,9 +927,9 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		update_page_count(PG_LEVEL_2M, -pages);
 }
 
-static void __meminit
+static void noinline __meminit
 remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 bool direct, struct vmem_altmap *altmap)
 {
 	unsigned long next, pages = 0;
 	pmd_t *pmd_base;
@@ -972,8 +974,8 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 		}
 
 		pmd_base = (pmd_t *)pud_page_vaddr(*pud);
-		remove_pmd_table(pmd_base, addr, next, direct);
-		free_pmd_table(pmd_base, pud);
+		remove_pmd_table(pmd_base, addr, next, direct, altmap);
+		free_pmd_table(pmd_base, pud, altmap);
 	}
 
 	if (direct)
@@ -982,7 +984,8 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 
 /* start and end are both virtual address. */
 static void __meminit
-remove_pagetable(unsigned long start, unsigned long end, bool direct)
+remove_pagetable(unsigned long start, unsigned long end, bool direct,
+		struct vmem_altmap *altmap)
 {
 	unsigned long next;
 	unsigned long addr;
@@ -998,7 +1001,7 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 			continue;
 
 		pud = (pud_t *)pgd_page_vaddr(*pgd);
-		remove_pud_table(pud, addr, next, direct);
+		remove_pud_table(pud, addr, next, direct, altmap);
 		if (free_pud_table(pud, pgd))
 			pgd_changed = true;
 	}
@@ -1009,9 +1012,15 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 	flush_tlb_all();
 }
 
+void __ref __vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
+{
+	remove_pagetable(start, end, false, altmap);
+}
+
 void __ref vmemmap_free(unsigned long start, unsigned long end)
 {
-	remove_pagetable(start, end, false);
+	return __vmemmap_free(start, end, NULL);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -1021,22 +1030,25 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	start = (unsigned long)__va(start);
 	end = (unsigned long)__va(end);
 
-	remove_pagetable(start, end, true);
+	remove_pagetable(start, end, true, NULL);
 }
 
-int __ref arch_remove_memory(u64 start, u64 size)
+static int __ref __arch_remove_memory(u64 start, u64 size, struct zone *zone,
+		struct vmem_altmap *altmap)
 {
-	unsigned long start_pfn = start >> PAGE_SHIFT;
-	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct zone *zone;
-	int ret;
-
-	zone = page_zone(pfn_to_page(start_pfn));
 	kernel_physical_mapping_remove(start, start + size);
-	ret = __remove_pages(zone, start_pfn, nr_pages);
-	WARN_ON_ONCE(ret);
+	return __remove_pages_altmap(zone, __phys_to_pfn(start),
+			__phys_to_pfn(size), altmap);
+}
 
-	return ret;
+int __ref arch_remove_memory(u64 start, u64 size)
+{
+	struct zone *zone = page_zone(pfn_to_page(__phys_to_pfn(start)));
+	int rc;
+
+	rc = __arch_remove_memory(start, size, zone, NULL);
+	WARN_ON_ONCE(rc);
+	return rc;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */
@@ -1244,7 +1256,7 @@ static void __meminitdata *p_start, *p_end;
 static int __meminitdata node_start;
 
 static int __meminit vmemmap_populate_hugepages(unsigned long start,
-						unsigned long end, int node)
+		unsigned long end, int node, struct vmem_altmap *altmap)
 {
 	unsigned long addr;
 	unsigned long next;
@@ -1267,7 +1279,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (pmd_none(*pmd)) {
 			void *p;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			p = vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
 			if (p) {
 				pte_t entry;
 
@@ -1300,12 +1312,18 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 	return 0;
 }
 
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit __vmemmap_populate(unsigned long start, unsigned long end,
+		int node, struct vmem_altmap *altmap)
 {
 	int err;
 
+	if (!cpu_has_pse && altmap) {
+		pr_warn_once("vmemmap: alternate mapping not supported\n");
+		return -ENXIO;
+	}
+
 	if (cpu_has_pse)
-		err = vmemmap_populate_hugepages(start, end, node);
+		err = vmemmap_populate_hugepages(start, end, node, altmap);
 	else
 		err = vmemmap_populate_basepages(start, end, node);
 	if (!err)
@@ -1313,6 +1331,11 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 	return err;
 }
 
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+{
+	return __vmemmap_populate(start, end, node, NULL);
+}
+
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HAVE_BOOTMEM_INFO_NODE)
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 6ffa0ac7f7d6..48a4e0a5e13d 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -11,6 +11,7 @@ struct zone;
 struct pglist_data;
 struct mem_section;
 struct memory_block;
+struct vmem_altmap;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 
@@ -101,6 +102,8 @@ extern int try_online_node(int nid);
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size);
+extern int __remove_pages_altmap(struct zone *zone, unsigned long start_pfn,
+	unsigned long nr_pages, struct vmem_altmap *altmap);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -109,6 +112,14 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 
+/*
+ * Specialized interface for callers that want to control the allocation
+ * of the memmap
+ */
+extern int __add_pages_altmap(int nid, struct zone *zone,
+		unsigned long start_pfn, unsigned long nr_pages,
+		struct vmem_altmap *altmap);
+
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
 #else
@@ -271,8 +282,10 @@ extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
-extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
+extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
+		struct vmem_altmap *altmap);
+extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+		struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 348f69467f54..de44de70e63a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1827,6 +1827,9 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
+extern void __memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
+		enum memmap_context context, struct vmem_altmap *);
+
 extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
@@ -2212,20 +2215,28 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 				   unsigned long map_count,
 				   int nodeid);
 
+struct vmem_altmap;
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid);
+struct page *sparse_alt_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap);
 pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
 pud_t *vmemmap_pud_populate(pgd_t *pgd, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
-void *vmemmap_alloc_block_buf(unsigned long size, int node);
+void *vmemmap_alloc_block_buf(unsigned long size, int node,
+		struct vmem_altmap *altmap);
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
+int __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap);
 int vmemmap_populate(unsigned long start, unsigned long end, int node);
 void vmemmap_populate_print_last(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
 void vmemmap_free(unsigned long start, unsigned long end);
+void __vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap);
 #endif
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6bc5b755ce98..d4bcfeaaec37 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -440,7 +440,8 @@ static void __meminit grow_pgdat_span(struct pglist_data *pgdat, unsigned long s
 					pgdat->node_start_pfn;
 }
 
-static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
+static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn,
+		struct vmem_altmap *altmap)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
@@ -459,25 +460,26 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	grow_pgdat_span(zone->zone_pgdat, phys_start_pfn,
 			phys_start_pfn + nr_pages);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
-	memmap_init_zone(nr_pages, nid, zone_type,
-			 phys_start_pfn, MEMMAP_HOTPLUG);
+	__memmap_init_zone(nr_pages, nid, zone_type,
+			 phys_start_pfn, MEMMAP_HOTPLUG, altmap);
 	return 0;
 }
 
 static int __meminit __add_section(int nid, struct zone *zone,
-					unsigned long phys_start_pfn)
+		unsigned long phys_start_pfn,
+		struct vmem_altmap *altmap)
 {
 	int ret;
 
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(zone, phys_start_pfn);
+	ret = sparse_add_one_section(zone, phys_start_pfn, altmap);
 
 	if (ret < 0)
 		return ret;
 
-	ret = __add_zone(zone, phys_start_pfn);
+	ret = __add_zone(zone, phys_start_pfn, altmap);
 
 	if (ret < 0)
 		return ret;
@@ -491,18 +493,20 @@ static int __meminit __add_section(int nid, struct zone *zone,
  * call this function after deciding the zone to which to
  * add the new pages.
  */
-int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
-			unsigned long nr_pages)
+int __ref __add_pages_altmap(int nid, struct zone *zone,
+		unsigned long phys_start_pfn, unsigned long nr_pages,
+		struct vmem_altmap *altmap)
 {
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
+
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, zone, section_nr_to_pfn(i));
+		err = __add_section(nid, zone, section_nr_to_pfn(i), altmap);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -517,6 +521,12 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 
 	return err;
 }
+
+int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
+			unsigned long nr_pages)
+{
+	return __add_pages_altmap(nid, zone, phys_start_pfn, nr_pages, NULL);
+}
 EXPORT_SYMBOL_GPL(__add_pages);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -722,7 +732,8 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms)
+static int __remove_section(struct zone *zone, struct mem_section *ms,
+		struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn;
 	int scn_nr;
@@ -739,23 +750,12 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	start_pfn = section_nr_to_pfn(scn_nr);
 	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms);
+	sparse_remove_one_section(zone, ms, altmap);
 	return 0;
 }
 
-/**
- * __remove_pages() - remove sections of pages from a zone
- * @zone: zone from which pages need to be removed
- * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
- * @nr_pages: number of pages to remove (must be multiple of section size)
- *
- * Generic helper function to remove section mappings and sysfs entries
- * for the section of the memory we are removing. Caller needs to make
- * sure that pages are marked reserved and zones are adjust properly by
- * calling offline_pages().
- */
-int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
-		 unsigned long nr_pages)
+int __remove_pages_altmap(struct zone *zone, unsigned long phys_start_pfn,
+		 unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long i;
 	int sections_to_remove;
@@ -784,12 +784,29 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
-		ret = __remove_section(zone, __pfn_to_section(pfn));
+		ret = __remove_section(zone, __pfn_to_section(pfn), altmap);
 		if (ret)
 			break;
 	}
 	return ret;
 }
+
+/**
+ * __remove_pages() - remove sections of pages from a zone
+ * @zone: zone from which pages need to be removed
+ * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
+ * @nr_pages: number of pages to remove (must be multiple of section size)
+ *
+ * Generic helper function to remove section mappings and sysfs entries
+ * for the section of the memory we are removing. Caller needs to make
+ * sure that pages are marked reserved and zones are adjust properly by
+ * calling offline_pages().
+ */
+int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+		 unsigned long nr_pages)
+{
+	return __remove_pages_altmap(zone, phys_start_pfn, nr_pages, NULL);
+}
 EXPORT_SYMBOL_GPL(__remove_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0f19b4e18233..c18520831dbc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4577,8 +4577,9 @@ static void setup_zone_migrate_reserve(struct zone *zone)
  * up by free_all_bootmem() once the early boot process is
  * done. Non-atomic initialization, single-pass.
  */
-void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
-		unsigned long start_pfn, enum memmap_context context)
+void __meminit __memmap_init_zone(unsigned long size, int nid,
+		unsigned long zone, unsigned long start_pfn,
+		enum memmap_context context, struct vmem_altmap *altmap)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long end_pfn = start_pfn + size;
@@ -4631,6 +4632,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	}
 }
 
+void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
+		unsigned long start_pfn, enum memmap_context context)
+{
+	return __memmap_init_zone(size, nid, zone, start_pfn, context, NULL);
+}
+
 static void __meminit zone_init_free_lists(struct zone *zone)
 {
 	unsigned int order, t;
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 4cba9c2783a1..16ec1675b793 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -69,8 +69,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 				__pa(MAX_DMA_ADDRESS));
 }
 
-/* need to make sure size is all the same during early stage */
-void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
+static void * __meminit __vmemmap_alloc_block_buf(unsigned long size, int node)
 {
 	void *ptr;
 
@@ -87,6 +86,13 @@ void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
 	return ptr;
 }
 
+/* need to make sure size is all the same during early stage */
+void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node,
+		struct vmem_altmap *altmap)
+{
+	return __vmemmap_alloc_block_buf(size, node);
+}
+
 void __meminit vmemmap_verify(pte_t *pte, int node,
 				unsigned long start, unsigned long end)
 {
@@ -103,7 +109,7 @@ pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte)) {
 		pte_t entry;
-		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
+		void *p = __vmemmap_alloc_block_buf(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
@@ -176,7 +182,15 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 	return 0;
 }
 
-struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
+__weak int __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
+{
+	pr_warn_once("%s: arch does not support vmem_altmap\n", __func__);
+	return -ENOMEM;
+}
+
+struct page * __meminit sparse_alt_map_populate(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
 	unsigned long start;
 	unsigned long end;
@@ -186,12 +200,17 @@ struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
 	start = (unsigned long)map;
 	end = (unsigned long)(map + PAGES_PER_SECTION);
 
-	if (vmemmap_populate(start, end, nid))
+	if (__vmemmap_populate(start, end, nid, altmap))
 		return NULL;
 
 	return map;
 }
 
+struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
+{
+	return sparse_alt_map_populate(pnum, nid, NULL);
+}
+
 void __init sparse_mem_maps_populate_node(struct page **map_map,
 					  unsigned long pnum_begin,
 					  unsigned long pnum_end,
diff --git a/mm/sparse.c b/mm/sparse.c
index d1b48b691ac8..eda783903b1d 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -595,17 +595,19 @@ void __init sparse_init(void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
+static struct page *alloc_section_memmap(unsigned long pnum, int nid,
+		struct vmem_altmap *altmap)
 {
-	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid);
 }
-static void __kfree_section_memmap(struct page *memmap)
+
+static inline void free_section_memmap(struct page *memmap,
+		struct vmem_altmap *altmap)
 {
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
-	vmemmap_free(start, end);
+	__vmemmap_free(start, end, NULL);
 }
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static void free_map_bootmem(struct page *memmap)
@@ -690,7 +692,8 @@ static void free_map_bootmem(struct page *memmap)
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
  */
-int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
+int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
+		struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct pglist_data *pgdat = zone->zone_pgdat;
@@ -707,12 +710,12 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 	ret = sparse_index_init(section_nr, pgdat->node_id);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id);
+	memmap = alloc_section_memmap(section_nr, pgdat->node_id, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
 	if (!usemap) {
-		__kfree_section_memmap(memmap);
+		free_section_memmap(memmap, altmap);
 		return -ENOMEM;
 	}
 
@@ -734,7 +737,7 @@ out:
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap);
+		free_section_memmap(memmap, altmap);
 	}
 	return ret;
 }
@@ -761,7 +764,8 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-static void free_section_usemap(struct page *memmap, unsigned long *usemap)
+static void free_section_usemap(struct page *memmap, unsigned long *usemap,
+		struct vmem_altmap *altmap)
 {
 	struct page *usemap_page;
 
@@ -775,7 +779,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap);
+			free_section_memmap(memmap, altmap);
 		return;
 	}
 
@@ -788,7 +792,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
+void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+		struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL, flags;
@@ -805,7 +810,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 	pgdat_resize_unlock(pgdat, &flags);
 
 	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
-	free_section_usemap(memmap, usemap);
+	free_section_usemap(memmap, usemap, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
