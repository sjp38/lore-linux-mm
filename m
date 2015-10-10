Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2626382F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:39 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so42214659pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id co2si6435659pbb.197.2015.10.09.18.02.38
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:38 -0700 (PDT)
Subject: [PATCH v2 17/20] mm, dax,
 pmem: introduce {get|put}_dev_pagemap() for dax-gup
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:56:55 -0400
Message-ID: <20151010005655.17221.94931.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, ross.zwisler@linux.intel.com

get_dev_page() enables paths like get_user_pages() to pin a dynamically
mapped pfn-range (devm_memremap_pages()) while the resulting struct page
objects are in use.  Unlike get_page() it may fail if the device is, or
is in the process of being, disabled.  While the initial lookup of the
range may be an expensive list walk, the result is cached to speed up
subsequent lookups which are likely to be in the same mapped range.

devm_memremap_pages() now requires a reference counter to be specified
at init time.  For pmem this means moving request_queue allocation into
pmem_alloc() so the existing queue usage counter can track "device
pages".

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c    |   42 +++++++++++++++++++++++++-----------------
 include/linux/mm.h       |   40 ++++++++++++++++++++++++++++++++++++++--
 include/linux/mm_types.h |    5 +++++
 kernel/memremap.c        |   46 ++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 110 insertions(+), 23 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index c950602bbf0b..f7acce594fa0 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -123,6 +123,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		struct resource *res, int id)
 {
 	struct pmem_device *pmem;
+	struct request_queue *q;
 
 	pmem = devm_kzalloc(dev, sizeof(*pmem), GFP_KERNEL);
 	if (!pmem)
@@ -140,19 +141,26 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		return ERR_PTR(-EBUSY);
 	}
 
+	q = blk_alloc_queue_node(GFP_KERNEL, dev_to_node(dev));
+	if (!q)
+		return ERR_PTR(-ENOMEM);
+
 	pmem->pfn_flags = PFN_DEV;
 	if (pmem_should_map_pages(dev)) {
 		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
-				NULL);
+				&q->q_usage_counter, NULL);
 		pmem->pfn_flags |= PFN_MAP;
 	} else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
 				pmem->phys_addr, pmem->size,
 				ARCH_MEMREMAP_PMEM);
 
-	if (IS_ERR(pmem->virt_addr))
+	if (IS_ERR(pmem->virt_addr)) {
+		blk_cleanup_queue(q);
 		return (void __force *) pmem->virt_addr;
+	}
 
+	pmem->pmem_queue = q;
 	return pmem;
 }
 
@@ -169,20 +177,15 @@ static void pmem_detach_disk(struct pmem_device *pmem)
 static int pmem_attach_disk(struct device *dev,
 		struct nd_namespace_common *ndns, struct pmem_device *pmem)
 {
-	int nid = dev_to_node(dev);
 	struct gendisk *disk;
 
-	pmem->pmem_queue = blk_alloc_queue_node(GFP_KERNEL, nid);
-	if (!pmem->pmem_queue)
-		return -ENOMEM;
-
 	blk_queue_make_request(pmem->pmem_queue, pmem_make_request);
 	blk_queue_physical_block_size(pmem->pmem_queue, PAGE_SIZE);
 	blk_queue_max_hw_sectors(pmem->pmem_queue, UINT_MAX);
 	blk_queue_bounce_limit(pmem->pmem_queue, BLK_BOUNCE_ANY);
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, pmem->pmem_queue);
 
-	disk = alloc_disk_node(0, nid);
+	disk = alloc_disk_node(0, dev_to_node(dev));
 	if (!disk) {
 		blk_cleanup_queue(pmem->pmem_queue);
 		return -ENOMEM;
@@ -318,6 +321,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	struct vmem_altmap *altmap;
 	struct nd_pfn_sb *pfn_sb;
 	struct pmem_device *pmem;
+	struct request_queue *q;
 	phys_addr_t offset;
 	int rc;
 	struct vmem_altmap __altmap = {
@@ -369,9 +373,10 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 
 	/* establish pfn range for lookup, and switch to direct map */
 	pmem = dev_get_drvdata(dev);
+	q = pmem->pmem_queue;
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
 	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
-			altmap);
+			&q->q_usage_counter, altmap);
 	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
@@ -410,19 +415,22 @@ static int nd_pmem_probe(struct device *dev)
 	dev_set_drvdata(dev, pmem);
 	ndns->rw_bytes = pmem_rw_bytes;
 
-	if (is_nd_btt(dev))
+	if (is_nd_btt(dev)) {
+		/* btt allocates its own request_queue */
+		blk_cleanup_queue(pmem->pmem_queue);
+		pmem->pmem_queue = NULL;
 		return nvdimm_namespace_attach_btt(ndns);
+	}
 
 	if (is_nd_pfn(dev))
 		return nvdimm_namespace_attach_pfn(ndns);
 
-	if (nd_btt_probe(ndns, pmem) == 0) {
-		/* we'll come back as btt-pmem */
-		return -ENXIO;
-	}
-
-	if (nd_pfn_probe(ndns, pmem) == 0) {
-		/* we'll come back as pfn-pmem */
+	if (nd_btt_probe(ndns, pmem) == 0 || nd_pfn_probe(ndns, pmem) == 0) {
+		/*
+		 * We'll come back as either btt-pmem, or pfn-pmem, so
+		 * drop the queue allocation for now.
+		 */
+		blk_cleanup_queue(pmem->pmem_queue);
 		return -ENXIO;
 	}
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ce173327215d..8a84bfb6fa6a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -15,12 +15,14 @@
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
 #include <linux/range.h>
+#include <linux/percpu-refcount.h>
 #include <linux/pfn.h>
 #include <linux/bit_spinlock.h>
 #include <linux/shrinker.h>
 #include <linux/resource.h>
 #include <linux/page_ext.h>
 #include <linux/err.h>
+#include <linux/ioport.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -786,18 +788,21 @@ static inline void vmem_altmap_free(struct vmem_altmap *altmap,
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
+ * @res: physical address range covered by @ref
+ * @ref: reference count that pins the devm_memremap_pages() mapping
  * @dev: host device of the mapping for debug
  */
 struct dev_pagemap {
 	struct vmem_altmap *altmap;
 	const struct resource *res;
+	struct percpu_ref *ref;
 	struct device *dev;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
 struct dev_pagemap *__get_dev_pagemap(resource_size_t phys);
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct vmem_altmap *altmap);
+		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
 #else
 static inline struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
@@ -806,7 +811,7 @@ static inline struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
 }
 
 static inline void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct vmem_altmap *altmap)
+		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
 	/*
 	 * Fail attempts to call devm_memremap_pages() without
@@ -823,6 +828,37 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 }
 #endif
 
+/* get a live reference on the dev_pagemap hosting the given pfn */
+static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap)
+{
+	resource_size_t phys = __pfn_to_phys(pfn);
+
+	/*
+	 * In the cached case we're already holding a reference so we can
+	 * simply do a blind increment
+	 */
+	if (pgmap && phys >= pgmap->res->start && phys <= pgmap->res->end) {
+		percpu_ref_get(pgmap->ref);
+		return pgmap;
+	}
+
+	/* fall back to slow path lookup */
+	rcu_read_lock();
+	pgmap = __get_dev_pagemap(phys);
+	if (pgmap && !percpu_ref_tryget_live(pgmap->ref))
+		pgmap = NULL;
+	rcu_read_unlock();
+
+	return pgmap;
+}
+
+static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
+{
+	if (pgmap)
+		percpu_ref_put(pgmap->ref);
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3d6baa7d4534..457c3e8a8f4f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -120,6 +120,11 @@ struct page {
 					 * Can be used as a generic list
 					 * by the page owner.
 					 */
+		struct dev_pagemap *pgmap; /* ZONE_DEVICE pages are never on an
+					    * lru or handled by a slab
+					    * allocator, this points to the
+					    * hosting device page map.
+					    */
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
 #ifdef CONFIG_64BIT
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 75161bb68af1..246446ba6e2f 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -163,6 +163,28 @@ static void del_page_map(struct page_map *page_map)
 	spin_unlock(&range_lock);
 }
 
+static unsigned long pfn_first(struct dev_pagemap *pgmap)
+{
+	struct vmem_altmap *altmap = pgmap->altmap;
+	const struct resource *res = pgmap->res;
+	unsigned long pfn;
+
+	pfn = res->start >> PAGE_SHIFT;
+	if (altmap)
+		pfn += vmem_altmap_offset(altmap);
+	return pfn;
+}
+
+static unsigned long pfn_end(struct dev_pagemap *pgmap)
+{
+	const struct resource *res = pgmap->res;
+
+	return (res->start + resource_size(res)) >> PAGE_SHIFT;
+}
+
+#define for_each_device_pfn(pfn, pgmap) \
+	for (pfn = pfn_first(pgmap); pfn < pfn_end(pgmap); pfn++)
+
 static void devm_memremap_pages_release(struct device *dev, void *data)
 {
 	struct page_map *page_map = data;
@@ -193,19 +215,25 @@ struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
  * devm_memremap_pages - remap and provide memmap backing for the given resource
  * @dev: hosting device for @res
  * @res: "host memory" address range
+ * @ref: a live per-cpu reference count
  * @altmap: optional descriptor for allocating the memmap from @res
  *
- * Note, the expectation is that @res is a host memory range that could
- * feasibly be treated as a "System RAM" range, i.e. not a device mmio
- * range, but this is not enforced.
+ * Notes:
+ * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
+ *    (or devm release event).
+ *
+ * 2/ @res is expected to be a host memory range that could feasibly be
+ *    treated as a "System RAM" range, i.e. not a device mmio range, but
+ *    this is not enforced.
  */
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct vmem_altmap *altmap)
+		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
 	int is_ram = region_intersects(res->start, resource_size(res),
 			"System RAM");
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
+	unsigned long pfn;
 	int error, nid;
 
 	if (is_ram == REGION_MIXED) {
@@ -217,6 +245,9 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (is_ram == REGION_INTERSECTS)
 		return __va(res->start);
 
+	if (!ref)
+		return ERR_PTR(-EINVAL);
+
 	page_map = devres_alloc_node(devm_memremap_pages_release,
 			sizeof(*page_map), GFP_KERNEL, dev_to_node(dev));
 	if (!page_map)
@@ -229,6 +260,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		pgmap->altmap = &page_map->altmap;
 	}
 	pgmap->dev = dev;
+	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
 	INIT_LIST_HEAD(&page_map->list);
 	add_page_map(page_map);
@@ -244,6 +276,12 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		return ERR_PTR(error);
 	}
 
+	for_each_device_pfn(pfn, pgmap) {
+		struct page *page = pfn_to_page(pfn);
+
+		list_del_poison(&page->lru);
+		page->pgmap = pgmap;
+	}
 	devres_add(dev, page_map);
 	return __va(res->start);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
