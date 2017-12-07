Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9616B026C
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:56 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f7so5846381pfa.21
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h126si3839962pgc.289.2017.12.07.07.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:54 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 13/14] memremap: remove struct vmem_altmap
Date: Thu,  7 Dec 2017 07:08:39 -0800
Message-Id: <20171207150840.28409-14-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

There is no value in a separate vmem_altmap vs just embedding it into
struct dev_pagemap, so merge the two.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/mm/init_64.c | 10 +++++-----
 arch/x86/mm/init_64.c     | 16 ++++++++--------
 drivers/nvdimm/pfn_devs.c | 22 ++++++++--------------
 drivers/nvdimm/pmem.c     |  1 -
 include/linux/memremap.h  | 33 ++++++++++++---------------------
 include/linux/mm.h        |  4 ++--
 kernel/memremap.c         | 28 ++++++++++++----------------
 mm/sparse-vmemmap.c       | 19 +++++++++----------
 8 files changed, 56 insertions(+), 77 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index ec706857bdd6..872eed5a0867 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -193,17 +193,17 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 	pr_debug("vmemmap_populate %lx..%lx, node %d\n", start, end, node);
 
 	for (; start < end; start += page_size) {
-		struct vmem_altmap *altmap;
+		struct dev_pagemap *pgmap;
 		void *p;
 		int rc;
 
 		if (vmemmap_populated(start, page_size))
 			continue;
 
-		/* altmap lookups only work at section boundaries */
-		altmap = to_vmem_altmap(SECTION_ALIGN_DOWN(start));
-		if (altmap)
-			p = dev_pagemap_alloc_block_buf(altmap, page_size);
+		/* pgmap lookups only work at section boundaries */
+		pgmap = to_vmem_altmap(SECTION_ALIGN_DOWN(start));
+		if (pgmap)
+			p = dev_pagemap_alloc_block_buf(pgmap, page_size);
 		else
 			p = vmemmap_alloc_block_buf(page_size, node);
 		if (!p)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 131749080874..bc01dc3b07a5 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1343,7 +1343,7 @@ static void __meminitdata *p_start, *p_end;
 static int __meminitdata node_start;
 
 static int __meminit vmemmap_populate_hugepages(unsigned long start,
-		unsigned long end, int node, struct vmem_altmap *altmap)
+		unsigned long end, int node, struct dev_pagemap *pgmap)
 {
 	unsigned long addr;
 	unsigned long next;
@@ -1371,8 +1371,8 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (pmd_none(*pmd)) {
 			void *p;
 
-			if (altmap)
-				p = dev_pagemap_alloc_block_buf(altmap, PMD_SIZE);
+			if (pgmap)
+				p = dev_pagemap_alloc_block_buf(pgmap, PMD_SIZE);
 			else
 				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (p) {
@@ -1395,7 +1395,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 				addr_end = addr + PMD_SIZE;
 				p_end = p + PMD_SIZE;
 				continue;
-			} else if (altmap)
+			} else if (pgmap)
 				return -ENOMEM; /* no fallback */
 		} else if (pmd_large(*pmd)) {
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
@@ -1409,13 +1409,13 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	struct vmem_altmap *altmap = to_vmem_altmap(start);
+	struct dev_pagemap *pgmap = to_vmem_altmap(start);
 	int err;
 
 	if (boot_cpu_has(X86_FEATURE_PSE))
-		err = vmemmap_populate_hugepages(start, end, node, altmap);
-	else if (altmap) {
-		pr_err_once("%s: no cpu support for altmap allocations\n",
+		err = vmemmap_populate_hugepages(start, end, node, pgmap);
+	else if (pgmap) {
+		pr_err_once("%s: no cpu support for device page map allocations\n",
 				__func__);
 		err = -ENOMEM;
 	} else
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 6f58615ddb85..8367cf7bef99 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -525,14 +525,14 @@ EXPORT_SYMBOL(nd_pfn_probe);
  * We hotplug memory at section granularity, pad the reserved area from
  * the previous section base to the namespace base address.
  */
-static unsigned long init_altmap_base(resource_size_t base)
+static unsigned long init_pgmap_base(resource_size_t base)
 {
 	unsigned long base_pfn = PHYS_PFN(base);
 
 	return PFN_SECTION_ALIGN_DOWN(base_pfn);
 }
 
-static unsigned long init_altmap_reserve(resource_size_t base)
+static unsigned long init_pgmap_reserve(resource_size_t base)
 {
 	unsigned long reserve = PHYS_PFN(SZ_8K);
 	unsigned long base_pfn = PHYS_PFN(base);
@@ -544,7 +544,6 @@ static unsigned long init_altmap_reserve(resource_size_t base)
 static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 {
 	struct resource *res = &pgmap->res;
-	struct vmem_altmap *altmap = &pgmap->altmap;
 	struct nd_pfn_sb *pfn_sb = nd_pfn->pfn_sb;
 	u64 offset = le64_to_cpu(pfn_sb->dataoff);
 	u32 start_pad = __le32_to_cpu(pfn_sb->start_pad);
@@ -552,10 +551,6 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 	struct nd_namespace_common *ndns = nd_pfn->ndns;
 	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
 	resource_size_t base = nsio->res.start + start_pad;
-	struct vmem_altmap __altmap = {
-		.base_pfn = init_altmap_base(base),
-		.reserve = init_altmap_reserve(base),
-	};
 
 	memcpy(res, &nsio->res, sizeof(*res));
 	res->start += start_pad;
@@ -565,7 +560,6 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 		if (offset < SZ_8K)
 			return -EINVAL;
 		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
-		pgmap->altmap_valid = false;
 	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
 		nd_pfn->npfns = PFN_SECTION_ALIGN_UP((resource_size(res)
 					- offset) / PAGE_SIZE);
@@ -574,10 +568,10 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 					"number of pfns truncated from %lld to %ld\n",
 					le64_to_cpu(nd_pfn->pfn_sb->npfns),
 					nd_pfn->npfns);
-		memcpy(altmap, &__altmap, sizeof(*altmap));
-		altmap->free = PHYS_PFN(offset - SZ_8K);
-		altmap->alloc = 0;
-		pgmap->altmap_valid = true;
+		pgmap->base_pfn = init_pgmap_base(base),
+		pgmap->reserve = init_pgmap_reserve(base),
+		pgmap->free = PHYS_PFN(offset - SZ_8K);
+		pgmap->alloc = 0;
 	} else
 		return -ENXIO;
 
@@ -660,7 +654,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 			/ PAGE_SIZE);
 	if (nd_pfn->mode == PFN_MODE_PMEM) {
 		/*
-		 * The altmap should be padded out to the block size used
+		 * The page map should be padded out to the block size used
 		 * when populating the vmemmap. This *should* be equal to
 		 * PMD_SIZE for most architectures.
 		 */
@@ -697,7 +691,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 }
 
 /*
- * Determine the effective resource range and vmem_altmap from an nd_pfn
+ * Determine the effective resource range and page map from an nd_pfn
  * instance.
  */
 int nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index cf074b1ce219..9e77a557a9af 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -362,7 +362,6 @@ static int pmem_attach_disk(struct device *dev,
 		bb_res.start += pmem->data_offset;
 	} else if (pmem_should_map_pages(dev)) {
 		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
-		pmem->pgmap.altmap_valid = false;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pmem->pfn_flags |= PFN_MAP;
 		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index e973a069646c..7bea9a1b75f7 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -10,26 +10,10 @@
 struct resource;
 struct device;
 
-/**
- * struct vmem_altmap - pre-allocated storage for vmemmap_populate
- * @base_pfn: base of the entire dev_pagemap mapping
- * @reserve: pages mapped, but reserved for driver use (relative to @base)
- * @free: free pages set aside in the mapping for memmap storage
- * @align: pages reserved to meet allocation alignments
- * @alloc: track pages consumed, private to vmemmap_populate()
- */
-struct vmem_altmap {
-	const unsigned long base_pfn;
-	const unsigned long reserve;
-	unsigned long free;
-	unsigned long align;
-	unsigned long alloc;
-};
-
 #ifdef CONFIG_ZONE_DEVICE
-struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
+struct dev_pagemap *to_vmem_altmap(unsigned long memmap_start);
 #else
-static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
+static inline struct dev_pagemap *to_vmem_altmap(unsigned long memmap_start)
 {
 	return NULL;
 }
@@ -112,7 +96,11 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
  * @page_fault: callback when CPU fault on an unaddressable device page
  * @page_free: free page callback when page refcount reaches 1
- * @altmap: pre-allocated/reserved memory for vmemmap allocations
+ * @base_pfn: base of the entire dev_pagemap mapping
+ * @reserve: pages mapped, but reserved for driver use (relative to @base)
+ * @free: free pages set aside in the mapping for memmap storage
+ * @align: pages reserved to meet allocation alignments
+ * @alloc: track pages consumed, private to vmemmap_populate()
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @dev: host device of the mapping for debug
@@ -122,8 +110,11 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
 struct dev_pagemap {
 	dev_page_fault_t page_fault;
 	dev_page_free_t page_free;
-	struct vmem_altmap altmap;
-	bool altmap_valid;
+	unsigned long base_pfn;
+	unsigned long reserve;
+	unsigned long free;
+	unsigned long align;
+	unsigned long alloc;
 	struct resource res;
 	struct percpu_ref *ref;
 	struct device *dev;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index cd3d1c00f6a3..b718c06a79ba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -33,6 +33,7 @@ struct file_ra_state;
 struct user_struct;
 struct writeback_control;
 struct bdi_writeback;
+struct dev_pagemap;
 
 void init_mm_internals(void);
 
@@ -2545,9 +2546,8 @@ pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
-struct vmem_altmap;
 void *vmemmap_alloc_block_buf(unsigned long size, int node);
-void *dev_pagemap_alloc_block_buf(struct vmem_altmap *pgmap,
+void *dev_pagemap_alloc_block_buf(struct dev_pagemap *pgmap,
 		unsigned long size);
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
diff --git a/kernel/memremap.c b/kernel/memremap.c
index ba5068b9ce07..01529eeb06ad 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -241,7 +241,7 @@ int device_private_entry_fault(struct vm_area_struct *vma,
 EXPORT_SYMBOL(device_private_entry_fault);
 #endif /* CONFIG_DEVICE_PRIVATE */
 
-static unsigned long __dev_pagemap_offset(struct vmem_altmap *pgmap)
+static unsigned long __dev_pagemap_offset(struct dev_pagemap *pgmap)
 {
 	/* number of pfns from base where pfn_to_page() is valid */
 	return pgmap ? (pgmap->reserve + pgmap->free) : 0;
@@ -267,12 +267,11 @@ static void pgmap_radix_release(struct resource *res)
 static unsigned long pfn_first(struct dev_pagemap *pgmap)
 {
 	const struct resource *res = &pgmap->res;
-	struct vmem_altmap *altmap = &pgmap->altmap;
 	unsigned long pfn;
 
 	pfn = res->start >> PAGE_SHIFT;
-	if (pgmap->altmap_valid)
-		pfn += __dev_pagemap_offset(altmap);
+	if (pgmap->base_pfn)
+		pfn += __dev_pagemap_offset(pgmap);
 	return pfn;
 }
 
@@ -312,7 +311,7 @@ static void devm_memremap_pages_release(void *data)
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
-	dev_WARN_ONCE(dev, pgmap->altmap.alloc,
+	dev_WARN_ONCE(dev, pgmap->alloc,
 		      "%s: failed to free all reserved pages\n", __func__);
 }
 
@@ -325,16 +324,13 @@ static void devm_memremap_pages_release(void *data)
  * 1/ At a minimum the res, ref and type members of @pgmap must be initialized
  *    by the caller before passing it to this function
  *
- * 2/ The altmap field may optionally be initialized, in which case altmap_valid
- *    must be set to true
- *
- * 3/ pgmap.ref must be 'live' on entry and 'dead' before devm_memunmap_pages()
+ * 2/ pgmap.ref must be 'live' on entry and 'dead' before devm_memunmap_pages()
  *    time (or devm release event). The expected order of events is that ref has
  *    been through percpu_ref_kill() before devm_memremap_pages_release(). The
  *    wait for the completion of all references being dropped and
  *    percpu_ref_exit() must occur after devm_memremap_pages_release().
  *
- * 4/ res is expected to be a host memory range that could feasibly be
+ * 3/ res is expected to be a host memory range that could feasibly be
  *    treated as a "System RAM" range, i.e. not a device mmio range, but
  *    this is not enforced.
  */
@@ -433,7 +429,7 @@ EXPORT_SYMBOL(devm_memremap_pages);
 
 int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages)
 {
-	struct vmem_altmap *pgmap;
+	struct dev_pagemap *pgmap;
 
 	pgmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
 	if (!pgmap)
@@ -451,7 +447,7 @@ int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages)
 
 unsigned long dev_pagemap_start_pfn(unsigned long start_pfn)
 {
-	struct vmem_altmap *pgmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
+	struct dev_pagemap *pgmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
 
 	if (pgmap && start_pfn == pgmap->base_pfn)
 		return pgmap->reserve;
@@ -460,7 +456,7 @@ unsigned long dev_pagemap_start_pfn(unsigned long start_pfn)
 
 bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 {
-	struct vmem_altmap *pgmap = to_vmem_altmap((uintptr_t)page);
+	struct dev_pagemap *pgmap = to_vmem_altmap((uintptr_t)page);
 
 	if (!pgmap)
 		return false;
@@ -468,7 +464,7 @@ bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 	return true;
 }
 
-struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
+struct dev_pagemap *to_vmem_altmap(unsigned long memmap_start)
 {
 	/*
 	 * 'memmap_start' is the virtual address for the first "struct
@@ -491,9 +487,9 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 	pgmap = radix_tree_lookup(&pgmap_radix, page_to_pfn(page));
 	rcu_read_unlock();
 
-	if (!pgmap || !pgmap->altmap_valid)
+	if (!pgmap || !pgmap->base_pfn)
 		return NULL;
-	return &pgmap->altmap;
+	return pgmap;
 }
 
 /**
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index fef41a6a9f64..541d87c2a2c1 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -91,18 +91,17 @@ void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
 	return ptr;
 }
 
-static unsigned long __meminit vmem_altmap_next_pfn(struct vmem_altmap *altmap)
+static unsigned long __meminit dev_pagemap_next_pfn(struct dev_pagemap *pgmap)
 {
-	return altmap->base_pfn + altmap->reserve + altmap->alloc
-		+ altmap->align;
+	return pgmap->base_pfn + pgmap->reserve + pgmap->alloc + pgmap->align;
 }
 
-static unsigned long __meminit vmem_altmap_nr_free(struct vmem_altmap *altmap)
+static unsigned long __meminit dev_pagemap_nr_free(struct dev_pagemap *pgmap)
 {
-	unsigned long allocated = altmap->alloc + altmap->align;
+	unsigned long allocated = pgmap->alloc + pgmap->align;
 
-	if (altmap->free > allocated)
-		return altmap->free - allocated;
+	if (pgmap->free > allocated)
+		return pgmap->free - allocated;
 	return 0;
 }
 
@@ -113,7 +112,7 @@ static unsigned long __meminit vmem_altmap_nr_free(struct vmem_altmap *altmap)
  *
  * Allocations are aligned to the size of the request.
  */
-void * __meminit dev_pagemap_alloc_block_buf(struct vmem_altmap *pgmap,
+void * __meminit dev_pagemap_alloc_block_buf(struct dev_pagemap *pgmap,
 		unsigned long size)
 {
 	unsigned long pfn, nr_pfns, nr_align;
@@ -124,11 +123,11 @@ void * __meminit dev_pagemap_alloc_block_buf(struct vmem_altmap *pgmap,
 		return NULL;
 	}
 
-	pfn = vmem_altmap_next_pfn(pgmap);
+	pfn = dev_pagemap_next_pfn(pgmap);
 	nr_pfns = size >> PAGE_SHIFT;
 	nr_align = 1UL << find_first_bit(&nr_pfns, BITS_PER_LONG);
 	nr_align = ALIGN(pfn, nr_align) - pfn;
-	if (nr_pfns + nr_align > vmem_altmap_nr_free(pgmap))
+	if (nr_pfns + nr_align > dev_pagemap_nr_free(pgmap))
 		return NULL;
 
 	pgmap->alloc += nr_pfns;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
