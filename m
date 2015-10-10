Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 316DF6B0258
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:01:43 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so42198392pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:01:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sy7si6435342pab.136.2015.10.09.18.01.41
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:01:42 -0700 (PDT)
Subject: [PATCH v2 05/20] x86,
 mm: introduce vmem_altmap to augment vmemmap_populate()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:55:49 -0400
Message-ID: <20151010005549.17221.32687.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, ross.zwisler@linux.intel.com, hch@lst.de

In support of providing struct page for large persistent memory
capacities, use struct vmem_altmap to change the default policy for
allocating memory for the memmap array.  The default vmemmap_populate()
allocates page table storage area from the page allocator.  Given
persistent memory capacities relative to DRAM it may not be feasible to
store the memmap in 'System Memory'.  Instead vmem_altmap represents
pre-allocated "device pages" to satisfy vmemmap_alloc_block_buf()
requests.

Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/m68k/include/asm/page_mm.h |    1 
 arch/m68k/include/asm/page_no.h |    1 
 arch/x86/mm/init_64.c           |   32 ++++++++++---
 drivers/nvdimm/pmem.c           |    6 ++
 include/linux/io.h              |   17 -------
 include/linux/memory_hotplug.h  |    3 +
 include/linux/mm.h              |   95 ++++++++++++++++++++++++++++++++++++++-
 kernel/memremap.c               |   69 +++++++++++++++++++++++++---
 mm/memory_hotplug.c             |   66 +++++++++++++++++++--------
 mm/page_alloc.c                 |   10 ++++
 mm/sparse-vmemmap.c             |   37 ++++++++++++++-
 mm/sparse.c                     |    8 ++-
 12 files changed, 282 insertions(+), 63 deletions(-)

diff --git a/arch/m68k/include/asm/page_mm.h b/arch/m68k/include/asm/page_mm.h
index 5029f73e6294..884f2f7e4caf 100644
--- a/arch/m68k/include/asm/page_mm.h
+++ b/arch/m68k/include/asm/page_mm.h
@@ -125,6 +125,7 @@ static inline void *__va(unsigned long x)
  */
 #define virt_to_pfn(kaddr)	(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_virt(pfn)	__va((pfn) << PAGE_SHIFT)
+#define	__pfn_to_phys(pfn)	PFN_PHYS(pfn)
 
 extern int m68k_virt_to_node_shift;
 
diff --git a/arch/m68k/include/asm/page_no.h b/arch/m68k/include/asm/page_no.h
index ef209169579a..7845eca0b36d 100644
--- a/arch/m68k/include/asm/page_no.h
+++ b/arch/m68k/include/asm/page_no.h
@@ -24,6 +24,7 @@ extern unsigned long memory_end;
 
 #define virt_to_pfn(kaddr)	(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_virt(pfn)	__va((pfn) << PAGE_SHIFT)
+#define	__pfn_to_phys(pfn)	PFN_PHYS(pfn)
 
 #define virt_to_page(addr)	(mem_map + (((unsigned long)(addr)-PAGE_OFFSET) >> PAGE_SHIFT))
 #define page_to_virt(page)	__va(((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET))
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index e5d42f1a2a71..cabf8ceb0a6b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -714,6 +714,12 @@ static void __meminit free_pagetable(struct page *page, int order)
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
@@ -1018,13 +1024,19 @@ int __ref arch_remove_memory(u64 start, u64 size)
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
@@ -1234,7 +1246,7 @@ static void __meminitdata *p_start, *p_end;
 static int __meminitdata node_start;
 
 static int __meminit vmemmap_populate_hugepages(unsigned long start,
-						unsigned long end, int node)
+		unsigned long end, int node, struct vmem_altmap *altmap)
 {
 	unsigned long addr;
 	unsigned long next;
@@ -1257,7 +1269,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (pmd_none(*pmd)) {
 			void *p;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			p = vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
 			if (p) {
 				pte_t entry;
 
@@ -1278,7 +1290,8 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 				addr_end = addr + PMD_SIZE;
 				p_end = p + PMD_SIZE;
 				continue;
-			}
+			} else if (altmap)
+				return -ENOMEM; /* no fallback */
 		} else if (pmd_large(*pmd)) {
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
 			continue;
@@ -1292,11 +1305,16 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 
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
index 349f03e7ed06..3c5b8f585441 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -151,7 +151,8 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 	}
 
 	if (pmem_should_map_pages(dev))
-		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res);
+		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
+				NULL);
 	else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
 				pmem->phys_addr, pmem->size,
@@ -362,7 +363,8 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	/* establish pfn range for lookup, and switch to direct map */
 	pmem = dev_get_drvdata(dev);
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
-	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res);
+	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
+			NULL);
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
 		goto err;
diff --git a/include/linux/io.h b/include/linux/io.h
index de64c1e53612..2f2f8859abd9 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -87,23 +87,6 @@ void *devm_memremap(struct device *dev, resource_size_t offset,
 		size_t size, unsigned long flags);
 void devm_memunmap(struct device *dev, void *addr);
 
-void *__devm_memremap_pages(struct device *dev, struct resource *res);
-
-#ifdef CONFIG_ZONE_DEVICE
-void *devm_memremap_pages(struct device *dev, struct resource *res);
-#else
-static inline void *devm_memremap_pages(struct device *dev, struct resource *res)
-{
-	/*
-	 * Fail attempts to call devm_memremap_pages() without
-	 * ZONE_DEVICE support enabled, this requires callers to fall
-	 * back to plain devm_memremap() based on config
-	 */
-	WARN_ON_ONCE(1);
-	return ERR_PTR(-ENXIO);
-}
-#endif
-
 /*
  * Some systems do not have legacy ISA devices.
  * /dev/port is not a valid interface on these systems.
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8f60e899b33c..178e000a7983 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -273,7 +273,8 @@ extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
+extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+		unsigned long map_offset);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 30c3c8764649..b5628cfbf649 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -718,18 +718,106 @@ static inline enum zone_type page_zonenum(const struct page *page)
 }
 
 /**
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
+static inline unsigned long vmem_altmap_nr_free(struct vmem_altmap *altmap)
+{
+	unsigned long allocated = altmap->alloc + altmap->align;
+
+	if (altmap->free > allocated)
+		return altmap->free - allocated;
+	return 0;
+}
+
+static inline unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
+{
+	/* number of pfns from base where pfn_to_page() is valid */
+	return altmap->reserve + altmap->free;
+}
+
+static inline unsigned long vmem_altmap_next_pfn(struct vmem_altmap *altmap)
+{
+	return altmap->base_pfn + altmap->reserve + altmap->alloc
+		+ altmap->align;
+}
+
+/**
+ * vmem_altmap_alloc - allocate pages from the vmem_altmap reservation
+ * @altmap - reserved page pool for the allocation
+ * @nr_pfns - size (in pages) of the allocation
+ *
+ * Allocations are aligned to the size of the request
+ */
+static inline unsigned long vmem_altmap_alloc(struct vmem_altmap *altmap,
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
+static inline void vmem_altmap_free(struct vmem_altmap *altmap,
+		unsigned long nr_pfns)
+{
+	altmap->alloc -= nr_pfns;
+}
+
+/**
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
 struct dev_pagemap *__get_dev_pagemap(resource_size_t phys);
+void *devm_memremap_pages(struct device *dev, struct resource *res,
+		struct vmem_altmap *altmap);
+struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
 #else
-static inline struct dev_pagemap *get_dev_pagemap(resource_size_t phys)
+static inline struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
+{
+	return NULL;
+}
+
+static inline void *devm_memremap_pages(struct device *dev, struct resource *res,
+		struct vmem_altmap *altmap)
+{
+	/*
+	 * Fail attempts to call devm_memremap_pages() without
+	 * ZONE_DEVICE support enabled, this requires callers to fall
+	 * back to plain devm_memremap() based on config
+	 */
+	WARN_ON_ONCE(1);
+	return ERR_PTR(-ENXIO);
+}
+
+static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 {
 	return NULL;
 }
@@ -2245,7 +2333,8 @@ pud_t *vmemmap_pud_populate(pgd_t *pgd, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
-void *vmemmap_alloc_block_buf(unsigned long size, int node);
+void *vmemmap_alloc_block_buf(unsigned long size, int node,
+		struct vmem_altmap *altmap);
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 64bfd9fa93aa..75161bb68af1 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -146,6 +146,7 @@ struct page_map {
 	struct resource res;
 	struct dev_pagemap pgmap;
 	struct list_head list;
+	struct vmem_altmap altmap;
 };
 
 static void add_page_map(struct page_map *page_map)
@@ -162,14 +163,17 @@ static void del_page_map(struct page_map *page_map)
 	spin_unlock(&range_lock);
 }
 
-static void devm_memremap_pages_release(struct device *dev, void *res)
+static void devm_memremap_pages_release(struct device *dev, void *data)
 {
-	struct page_map *page_map = res;
-
-	del_page_map(page_map);
+	struct page_map *page_map = data;
+	struct resource *res = &page_map->res;
+	struct dev_pagemap *pgmap = &page_map->pgmap;
 
 	/* pages are dead and unused, undo the arch mapping */
-	arch_remove_memory(page_map->res.start, resource_size(&page_map->res));
+	arch_remove_memory(res->start, resource_size(res));
+	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
+			"%s: failed to free all reserved pages\n", __func__);
+	del_page_map(page_map);
 }
 
 /* assumes rcu_read_lock() held at entry */
@@ -185,10 +189,22 @@ struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
 	return NULL;
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
+	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
 	int error, nid;
 
@@ -205,10 +221,15 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 			sizeof(*page_map), GFP_KERNEL, dev_to_node(dev));
 	if (!page_map)
 		return ERR_PTR(-ENOMEM);
+	pgmap = &page_map->pgmap;
 
 	memcpy(&page_map->res, res, sizeof(*res));
-
-	page_map->pgmap.dev = dev;
+	if (altmap) {
+		memcpy(&page_map->altmap, altmap, sizeof(*altmap));
+		pgmap->altmap = &page_map->altmap;
+	}
+	pgmap->dev = dev;
+	pgmap->res = &page_map->res;
 	INIT_LIST_HEAD(&page_map->list);
 	add_page_map(page_map);
 
@@ -227,4 +248,36 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 	return __va(res->start);
 }
 EXPORT_SYMBOL(devm_memremap_pages);
+
+/*
+ * Uncoditionally retrieve a dev_pagemap associated with the given physical
+ * address, this is only for use in the arch_{add|remove}_memory() for setting
+ * up and tearing down the memmap.
+ */
+static struct dev_pagemap *lookup_dev_pagemap(resource_size_t phys)
+{
+	struct dev_pagemap *pgmap;
+
+	rcu_read_lock();
+	pgmap = __get_dev_pagemap(phys);
+	rcu_read_unlock();
+	return pgmap;
+}
+
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
+	pgmap = lookup_dev_pagemap(__pfn_to_phys(page_to_pfn(page)));
+	return pgmap ? pgmap->altmap : NULL;
+}
 #endif /* CONFIG_ZONE_DEVICE */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index aa992e2df58a..3521df153de3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -505,10 +505,25 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
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
 
@@ -730,7 +745,8 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms)
+static int __remove_section(struct zone *zone, struct mem_section *ms,
+		unsigned long map_offset)
 {
 	unsigned long start_pfn;
 	int scn_nr;
@@ -747,7 +763,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	start_pfn = section_nr_to_pfn(scn_nr);
 	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms);
+	sparse_remove_one_section(zone, ms, map_offset);
 	return 0;
 }
 
@@ -766,9 +782,32 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
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
@@ -776,23 +815,12 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
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
index 48aaf7b9f253..9dfc431d6271 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4620,8 +4620,9 @@ static void setup_zone_migrate_reserve(struct zone *zone)
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
@@ -4629,6 +4630,13 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
index 4cba9c2783a1..96c1dca4ce6a 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -70,7 +70,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 }
 
 /* need to make sure size is all the same during early stage */
-void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
+static void * __meminit __vmemmap_alloc_block_buf(unsigned long size, int node)
 {
 	void *ptr;
 
@@ -87,6 +87,39 @@ void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
 	return ptr;
 }
 
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
+void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node,
+		struct vmem_altmap *altmap)
+{
+	if (altmap)
+		return altmap_alloc_block_buf(size, altmap);
+	return __vmemmap_alloc_block_buf(size, node);
+}
+
 void __meminit vmemmap_verify(pte_t *pte, int node,
 				unsigned long start, unsigned long end)
 {
@@ -103,7 +136,7 @@ pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte)) {
 		pte_t entry;
-		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
+		void *p = __vmemmap_alloc_block_buf(PAGE_SIZE, node);
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
