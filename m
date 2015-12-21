Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C6AEE6B0008
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:45:16 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id wq6so93756025pac.1
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:45:16 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id n81si1877168pfa.30.2015.12.20.21.45.10
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:10 -0800 (PST)
Subject: [-mm PATCH v4 05/18] x86,
 mm: introduce vmem_altmap to augment vmemmap_populate()
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:44:33 -0800
Message-ID: <20151221054433.34542.73933.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm@lists.01.org, x86@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

In support of providing struct page for large persistent memory
capacities, use struct vmem_altmap to change the default policy for
allocating memory for the memmap array.  The default vmemmap_populate()
allocates page table storage area from the page allocator.  Given
persistent memory capacities relative to DRAM it may not be feasible to
store the memmap in 'System Memory'.  Instead vmem_altmap represents
pre-allocated "device pages" to satisfy vmemmap_alloc_block_buf()
requests.

Cc: x86@kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init_64.c          |   33 ++++++++++++++---
 drivers/nvdimm/pmem.c          |    6 ++-
 include/linux/memory_hotplug.h |    3 +-
 include/linux/memremap.h       |   39 ++++++++++++++++++---
 include/linux/mm.h             |    9 ++++-
 kernel/memremap.c              |   72 +++++++++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c            |   67 +++++++++++++++++++++++++----------
 mm/page_alloc.c                |   11 +++++-
 mm/sparse-vmemmap.c            |   76 +++++++++++++++++++++++++++++++++++++++-
 mm/sparse.c                    |    8 +++-
 10 files changed, 282 insertions(+), 42 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index ec081fe0ce2c..bdfd418552f2 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -30,6 +30,7 @@
 #include <linux/module.h>
 #include <linux/memory.h>
 #include <linux/memory_hotplug.h>
+#include <linux/memremap.h>
 #include <linux/nmi.h>
 #include <linux/gfp.h>
 #include <linux/kcore.h>
@@ -714,6 +715,12 @@ static void __meminit free_pagetable(struct page *page, int order)
 {
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
+	struct vmem_altmap *altmap = to_vmem_altmap((unsigned long) page);
+
+	if (altmap) {
+		vmem_altmap_free(altmap, nr_pages);
+		return;
+	}
 
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
@@ -1018,13 +1025,19 @@ int __ref arch_remove_memory(u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct page *page = pfn_to_page(start_pfn);
+	struct vmem_altmap *altmap;
 	struct zone *zone;
 	int ret;
 
-	zone = page_zone(pfn_to_page(start_pfn));
-	kernel_physical_mapping_remove(start, start + size);
+	/* With altmap the first mapped page is offset from @start */
+	altmap = to_vmem_altmap((unsigned long) page);
+	if (altmap)
+		page += vmem_altmap_offset(altmap);
+	zone = page_zone(page);
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
+	kernel_physical_mapping_remove(start, start + size);
 
 	return ret;
 }
@@ -1236,7 +1249,7 @@ static void __meminitdata *p_start, *p_end;
 static int __meminitdata node_start;
 
 static int __meminit vmemmap_populate_hugepages(unsigned long start,
-						unsigned long end, int node)
+		unsigned long end, int node, struct vmem_altmap *altmap)
 {
 	unsigned long addr;
 	unsigned long next;
@@ -1259,7 +1272,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (pmd_none(*pmd)) {
 			void *p;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
 			if (p) {
 				pte_t entry;
 
@@ -1280,7 +1293,8 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 				addr_end = addr + PMD_SIZE;
 				p_end = p + PMD_SIZE;
 				continue;
-			}
+			} else if (altmap)
+				return -ENOMEM; /* no fallback */
 		} else if (pmd_large(*pmd)) {
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
 			continue;
@@ -1294,11 +1308,16 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
+	struct vmem_altmap *altmap = to_vmem_altmap(start);
 	int err;
 
 	if (cpu_has_pse)
-		err = vmemmap_populate_hugepages(start, end, node);
-	else
+		err = vmemmap_populate_hugepages(start, end, node, altmap);
+	else if (altmap) {
+		pr_err_once("%s: no cpu support for altmap allocations\n",
+				__func__);
+		err = -ENOMEM;
+	} else
 		err = vmemmap_populate_basepages(start, end, node);
 	if (!err)
 		sync_global_pgds(start, end - 1, 0);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 2afb24ba5a90..103c1f7e6aca 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -144,7 +144,8 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 
 	pmem->pfn_flags = PFN_DEV;
 	if (pmem_should_map_pages(dev)) {
-		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res);
+		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
+				NULL);
 		pmem->pfn_flags |= PFN_MAP;
 	} else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
@@ -356,7 +357,8 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	/* establish pfn range for lookup, and switch to direct map */
 	pmem = dev_get_drvdata(dev);
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
-	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res);
+	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
+			NULL);
 	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2ea574ff9714..43405992d027 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -275,7 +275,8 @@ extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
+extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+		unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index d90721c178bb..aa3e82a80d7b 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -4,21 +4,53 @@
 
 struct resource;
 struct device;
+
+/**
+ * struct vmem_altmap - pre-allocated storage for vmemmap_populate
+ * @base_pfn: base of the entire dev_pagemap mapping
+ * @reserve: pages mapped, but reserved for driver use (relative to @base)
+ * @free: free pages set aside in the mapping for memmap storage
+ * @align: pages reserved to meet allocation alignments
+ * @alloc: track pages consumed, private to vmemmap_populate()
+ */
+struct vmem_altmap {
+	const unsigned long base_pfn;
+	const unsigned long reserve;
+	unsigned long free;
+	unsigned long align;
+	unsigned long alloc;
+};
+
+unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
+void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
+
+#if defined(CONFIG_SPARSEMEM_VMEMMAP) && defined(CONFIG_ZONE_DEVICE)
+struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
+#else
+static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
+{
+	return NULL;
+}
+#endif
+
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
+ * @altmap: pre-allocated/reserved memory for vmemmap allocations
  * @dev: host device of the mapping for debug
  */
 struct dev_pagemap {
-	/* TODO: vmem_altmap and percpu_ref count */
+	struct vmem_altmap *altmap;
+	const struct resource *res;
 	struct device *dev;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
-void *devm_memremap_pages(struct device *dev, struct resource *res);
+void *devm_memremap_pages(struct device *dev, struct resource *res,
+		struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
-		struct resource *res)
+		struct resource *res, struct vmem_altmap *altmap)
 {
 	/*
 	 * Fail attempts to call devm_memremap_pages() without
@@ -34,5 +66,4 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 	return NULL;
 }
 #endif
-
 #endif /* _LINUX_MEMREMAP_H_ */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 57e9546d40dc..5d448a8600b3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2236,7 +2236,14 @@ pud_t *vmemmap_pud_populate(pgd_t *pgd, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
-void *vmemmap_alloc_block_buf(unsigned long size, int node);
+struct vmem_altmap;
+void *__vmemmap_alloc_block_buf(unsigned long size, int node,
+		struct vmem_altmap *altmap);
+static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
+{
+	return __vmemmap_alloc_block_buf(size, node, NULL);
+}
+
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 61cfbf4d3054..562f6471fe90 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -166,6 +166,7 @@ struct page_map {
 	struct resource res;
 	struct percpu_ref *ref;
 	struct dev_pagemap pgmap;
+	struct vmem_altmap altmap;
 };
 
 static void pgmap_radix_release(struct resource *res)
@@ -183,6 +184,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	struct page_map *page_map = data;
 	struct resource *res = &page_map->res;
 	resource_size_t align_start, align_size;
+	struct dev_pagemap *pgmap = &page_map->pgmap;
 
 	pgmap_radix_release(res);
 
@@ -190,6 +192,8 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 	arch_remove_memory(align_start, align_size);
+	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
+			"%s: failed to free all reserved pages\n", __func__);
 }
 
 /* assumes rcu_read_lock() held at entry */
@@ -203,11 +207,23 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 	return page_map ? &page_map->pgmap : NULL;
 }
 
-void *devm_memremap_pages(struct device *dev, struct resource *res)
+/**
+ * devm_memremap_pages - remap and provide memmap backing for the given resource
+ * @dev: hosting device for @res
+ * @res: "host memory" address range
+ * @altmap: optional descriptor for allocating the memmap from @res
+ *
+ * Note, the expectation is that @res is a host memory range that could
+ * feasibly be treated as a "System RAM" range, i.e. not a device mmio
+ * range, but this is not enforced.
+ */
+void *devm_memremap_pages(struct device *dev, struct resource *res,
+		struct vmem_altmap *altmap)
 {
 	int is_ram = region_intersects(res->start, resource_size(res),
 			"System RAM");
 	resource_size_t key, align_start, align_size;
+	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
 	int error, nid;
 
@@ -220,14 +236,27 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 	if (is_ram == REGION_INTERSECTS)
 		return __va(res->start);
 
+	if (altmap && !IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)) {
+		dev_err(dev, "%s: altmap requires CONFIG_SPARSEMEM_VMEMMAP=y\n",
+				__func__);
+		return ERR_PTR(-ENXIO);
+	}
+
 	page_map = devres_alloc_node(devm_memremap_pages_release,
 			sizeof(*page_map), GFP_KERNEL, dev_to_node(dev));
 	if (!page_map)
 		return ERR_PTR(-ENOMEM);
+	pgmap = &page_map->pgmap;
 
 	memcpy(&page_map->res, res, sizeof(*res));
 
-	page_map->pgmap.dev = dev;
+	pgmap->dev = dev;
+	if (altmap) {
+		memcpy(&page_map->altmap, altmap, sizeof(*altmap));
+		pgmap->altmap = &page_map->altmap;
+	}
+	pgmap->res = &page_map->res;
+
 	mutex_lock(&pgmap_lock);
 	error = 0;
 	for (key = res->start; key <= res->end; key += SECTION_SIZE) {
@@ -273,4 +302,43 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL(devm_memremap_pages);
+
+unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
+{
+	/* number of pfns from base where pfn_to_page() is valid */
+	return altmap->reserve + altmap->free;
+}
+
+void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns)
+{
+	altmap->alloc -= nr_pfns;
+}
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
+{
+	/*
+	 * 'memmap_start' is the virtual address for the first "struct
+	 * page" in this range of the vmemmap array.  In the case of
+	 * CONFIG_SPARSE_VMEMMAP a page_to_pfn conversion is simple
+	 * pointer arithmetic, so we can perform this to_vmem_altmap()
+	 * conversion without concern for the initialization state of
+	 * the struct page fields.
+	 */
+	struct page *page = (struct page *) memmap_start;
+	struct dev_pagemap *pgmap;
+
+	/*
+	 * Uncoditionally retrieve a dev_pagemap associated with the
+	 * given physical address, this is only for use in the
+	 * arch_{add|remove}_memory() for setting up and tearing down
+	 * the memmap.
+	 */
+	rcu_read_lock();
+	pgmap = find_dev_pagemap(__pfn_to_phys(page_to_pfn(page)));
+	rcu_read_unlock();
+
+	return pgmap ? pgmap->altmap : NULL;
+}
+#endif /* CONFIG_SPARSEMEM_VMEMMAP */
 #endif /* CONFIG_ZONE_DEVICE */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d8016a25e5c8..7ef9a462d0d8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -17,6 +17,7 @@
 #include <linux/sysctl.h>
 #include <linux/cpu.h>
 #include <linux/memory.h>
+#include <linux/memremap.h>
 #include <linux/memory_hotplug.h>
 #include <linux/highmem.h>
 #include <linux/vmalloc.h>
@@ -505,10 +506,25 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
+	struct vmem_altmap *altmap;
+
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
+	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
+	if (altmap) {
+		/*
+		 * Validate altmap is within bounds of the total request
+		 */
+		if (altmap->base_pfn != phys_start_pfn
+				|| vmem_altmap_offset(altmap) > nr_pages) {
+			pr_warn_once("memory add fail, invalid altmap\n");
+			return -EINVAL;
+		}
+		altmap->alloc = 0;
+	}
+
 	for (i = start_sec; i <= end_sec; i++) {
 		err = __add_section(nid, zone, section_nr_to_pfn(i));
 
@@ -730,7 +746,8 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms)
+static int __remove_section(struct zone *zone, struct mem_section *ms,
+		unsigned long map_offset)
 {
 	unsigned long start_pfn;
 	int scn_nr;
@@ -747,7 +764,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	start_pfn = section_nr_to_pfn(scn_nr);
 	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms);
+	sparse_remove_one_section(zone, ms, map_offset);
 	return 0;
 }
 
@@ -766,9 +783,32 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		 unsigned long nr_pages)
 {
 	unsigned long i;
-	int sections_to_remove;
-	resource_size_t start, size;
-	int ret = 0;
+	unsigned long map_offset = 0;
+	int sections_to_remove, ret = 0;
+
+	/* In the ZONE_DEVICE case device driver owns the memory region */
+	if (is_dev_zone(zone)) {
+		struct page *page = pfn_to_page(phys_start_pfn);
+		struct vmem_altmap *altmap;
+
+		altmap = to_vmem_altmap((unsigned long) page);
+		if (altmap)
+			map_offset = vmem_altmap_offset(altmap);
+	} else {
+		resource_size_t start, size;
+
+		start = phys_start_pfn << PAGE_SHIFT;
+		size = nr_pages * PAGE_SIZE;
+
+		ret = release_mem_region_adjustable(&iomem_resource, start,
+					size);
+		if (ret) {
+			resource_size_t endres = start + size - 1;
+
+			pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
+					&start, &endres, ret);
+		}
+	}
 
 	/*
 	 * We can only remove entire sections
@@ -776,23 +816,12 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
 	BUG_ON(nr_pages % PAGES_PER_SECTION);
 
-	start = phys_start_pfn << PAGE_SHIFT;
-	size = nr_pages * PAGE_SIZE;
-
-	/* in the ZONE_DEVICE case device driver owns the memory region */
-	if (!is_dev_zone(zone))
-		ret = release_mem_region_adjustable(&iomem_resource, start, size);
-	if (ret) {
-		resource_size_t endres = start + size - 1;
-
-		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
-				&start, &endres, ret);
-	}
-
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
-		ret = __remove_section(zone, __pfn_to_section(pfn));
+
+		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset);
+		map_offset = 0;
 		if (ret)
 			break;
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bac8842d4fcf..4c0b3efe73ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -43,6 +43,7 @@
 #include <linux/vmalloc.h>
 #include <linux/vmstat.h>
 #include <linux/mempolicy.h>
+#include <linux/memremap.h>
 #include <linux/stop_machine.h>
 #include <linux/sort.h>
 #include <linux/pfn.h>
@@ -4502,8 +4503,9 @@ static inline unsigned long wait_table_bits(unsigned long size)
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		unsigned long start_pfn, enum memmap_context context)
 {
-	pg_data_t *pgdat = NODE_DATA(nid);
+	struct vmem_altmap *altmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
 	unsigned long end_pfn = start_pfn + size;
+	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long pfn;
 	struct zone *z;
 	unsigned long nr_initialised = 0;
@@ -4511,6 +4513,13 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
+	/*
+	 * Honor reservation requested by the driver for this ZONE_DEVICE
+	 * memory
+	 */
+	if (altmap && start_pfn == altmap->base_pfn)
+		start_pfn += altmap->reserve;
+
 	z = &pgdat->node_zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 4cba9c2783a1..b60802b3e5ea 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -20,6 +20,7 @@
 #include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/bootmem.h>
+#include <linux/memremap.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -70,7 +71,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 }
 
 /* need to make sure size is all the same during early stage */
-void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
+static void * __meminit alloc_block_buf(unsigned long size, int node)
 {
 	void *ptr;
 
@@ -87,6 +88,77 @@ void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
 	return ptr;
 }
 
+static unsigned long __meminit vmem_altmap_next_pfn(struct vmem_altmap *altmap)
+{
+	return altmap->base_pfn + altmap->reserve + altmap->alloc
+		+ altmap->align;
+}
+
+static unsigned long __meminit vmem_altmap_nr_free(struct vmem_altmap *altmap)
+{
+	unsigned long allocated = altmap->alloc + altmap->align;
+
+	if (altmap->free > allocated)
+		return altmap->free - allocated;
+	return 0;
+}
+
+/**
+ * vmem_altmap_alloc - allocate pages from the vmem_altmap reservation
+ * @altmap - reserved page pool for the allocation
+ * @nr_pfns - size (in pages) of the allocation
+ *
+ * Allocations are aligned to the size of the request
+ */
+static unsigned long __meminit vmem_altmap_alloc(struct vmem_altmap *altmap,
+		unsigned long nr_pfns)
+{
+	unsigned long pfn = vmem_altmap_next_pfn(altmap);
+	unsigned long nr_align;
+
+	nr_align = 1UL << find_first_bit(&nr_pfns, BITS_PER_LONG);
+	nr_align = ALIGN(pfn, nr_align) - pfn;
+
+	if (nr_pfns + nr_align > vmem_altmap_nr_free(altmap))
+		return ULONG_MAX;
+	altmap->alloc += nr_pfns;
+	altmap->align += nr_align;
+	return pfn + nr_align;
+}
+
+static void * __meminit altmap_alloc_block_buf(unsigned long size,
+		struct vmem_altmap *altmap)
+{
+	unsigned long pfn, nr_pfns;
+	void *ptr;
+
+	if (size & ~PAGE_MASK) {
+		pr_warn_once("%s: allocations must be multiple of PAGE_SIZE (%ld)\n",
+				__func__, size);
+		return NULL;
+	}
+
+	nr_pfns = size >> PAGE_SHIFT;
+	pfn = vmem_altmap_alloc(altmap, nr_pfns);
+	if (pfn < ULONG_MAX)
+		ptr = __va(__pfn_to_phys(pfn));
+	else
+		ptr = NULL;
+	pr_debug("%s: pfn: %#lx alloc: %ld align: %ld nr: %#lx\n",
+			__func__, pfn, altmap->alloc, altmap->align, nr_pfns);
+
+	return ptr;
+}
+
+/* need to make sure size is all the same during early stage */
+void * __meminit __vmemmap_alloc_block_buf(unsigned long size, int node,
+		struct vmem_altmap *altmap)
+{
+	if (altmap)
+		return altmap_alloc_block_buf(size, altmap);
+	return alloc_block_buf(size, node);
+}
+
 void __meminit vmemmap_verify(pte_t *pte, int node,
 				unsigned long start, unsigned long end)
 {
@@ -103,7 +175,7 @@ pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte)) {
 		pte_t entry;
-		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
+		void *p = alloc_block_buf(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
diff --git a/mm/sparse.c b/mm/sparse.c
index d1b48b691ac8..3717ceed4177 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -748,7 +748,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 	if (!memmap)
 		return;
 
-	for (i = 0; i < PAGES_PER_SECTION; i++) {
+	for (i = 0; i < nr_pages; i++) {
 		if (PageHWPoison(&memmap[i])) {
 			atomic_long_sub(1, &num_poisoned_pages);
 			ClearPageHWPoison(&memmap[i]);
@@ -788,7 +788,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
+void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+		unsigned long map_offset)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL, flags;
@@ -804,7 +805,8 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 	}
 	pgdat_resize_unlock(pgdat, &flags);
 
-	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
+	clear_hwpoisoned_pages(memmap + map_offset,
+			PAGES_PER_SECTION - map_offset);
 	free_section_usemap(memmap, usemap);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
