Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2297C82F6A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:39:37 -0500 (EST)
Received: by pfnn128 with SMTP id n128so39806370pfn.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:39:36 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fj9si16806705pad.43.2015.12.09.18.39.36
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:39:36 -0800 (PST)
Subject: [-mm PATCH v2 21/25] mm, dax,
 pmem: introduce {get|put}_dev_pagemap() for dax-gup
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:39:06 -0800
Message-ID: <20151210023905.30368.32787.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

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
Tested-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c    |    6 +++--
 include/linux/mm.h       |   49 +++++++++++++++++++++++++++++++++++++++++--
 include/linux/mm_types.h |    5 ++++
 kernel/memremap.c        |   53 +++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 105 insertions(+), 8 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 9060a64628ae..11e483a3fbc9 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -149,7 +149,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	if (pmem_should_map_pages(dev)) {
 		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
-				NULL);
+				&q->q_usage_counter, NULL);
 		pmem->pfn_flags |= PFN_MAP;
 	} else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
@@ -323,6 +323,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	struct vmem_altmap *altmap;
 	struct nd_pfn_sb *pfn_sb;
 	struct pmem_device *pmem;
+	struct request_queue *q;
 	phys_addr_t offset;
 	int rc;
 	struct vmem_altmap __altmap = {
@@ -374,9 +375,10 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e8130b798da8..c74e7eca24c0 100644
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
@@ -745,21 +747,25 @@ static inline void vmem_altmap_free(struct vmem_altmap *altmap,
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
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct vmem_altmap *altmap);
+		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
-		struct resource *res, struct vmem_altmap *altmap)
+		struct resource *res, struct percpu_ref *ref,
+		struct vmem_altmap *altmap)
 {
 	/*
 	 * Fail attempts to call devm_memremap_pages() without
@@ -785,6 +791,45 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 }
 #endif
 
+/**
+ * get_dev_pagemap() - take a new live reference on the dev_pagemap for @pfn
+ * @pfn: page frame number to lookup page_map
+ * @pgmap: optional known pgmap that already has a reference
+ *
+ * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
+ * same mapping.
+ */
+static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap)
+{
+	const struct resource *res = pgmap ? pgmap->res : NULL;
+	resource_size_t phys = __pfn_to_phys(pfn);
+
+	/*
+	 * In the cached case we're already holding a live reference so
+	 * we can simply do a blind increment
+	 */
+	if (res && phys >= res->start && phys <= res->end) {
+		percpu_ref_get(pgmap->ref);
+		return pgmap;
+	}
+
+	/* fall back to slow path lookup */
+	rcu_read_lock();
+	pgmap = find_dev_pagemap(phys);
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
index 22beb225e88f..c67ea476991e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -116,6 +116,11 @@ struct page {
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
index 1fb887227bcb..312e43cd3fa3 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -171,6 +171,29 @@ static void pgmap_radix_release(struct resource *res)
 	mutex_unlock(&pgmap_lock);
 }
 
+static unsigned long pfn_first(struct page_map *page_map)
+{
+	struct dev_pagemap *pgmap = &page_map->pgmap;
+	const struct resource *res = &page_map->res;
+	struct vmem_altmap *altmap = pgmap->altmap;
+	unsigned long pfn;
+
+	pfn = res->start >> PAGE_SHIFT;
+	if (altmap)
+		pfn += vmem_altmap_offset(altmap);
+	return pfn;
+}
+
+static unsigned long pfn_end(struct page_map *page_map)
+{
+	const struct resource *res = &page_map->res;
+
+	return (res->start + resource_size(res)) >> PAGE_SHIFT;
+}
+
+#define for_each_device_pfn(pfn, map) \
+	for (pfn = pfn_first(map); pfn < pfn_end(map); pfn++)
+
 static void devm_memremap_pages_release(struct device *dev, void *data)
 {
 	struct page_map *page_map = data;
@@ -178,6 +201,11 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	resource_size_t align_start, align_size;
 	struct dev_pagemap *pgmap = &page_map->pgmap;
 
+	if (percpu_ref_tryget_live(pgmap->ref)) {
+		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
+		percpu_ref_put(pgmap->ref);
+	}
+
 	pgmap_radix_release(res);
 
 	/* pages are dead and unused, undo the arch mapping */
@@ -203,20 +231,26 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
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
 	resource_size_t key, align_start, align_size;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
+	unsigned long pfn;
 	int error, nid;
 
 	if (is_ram == REGION_MIXED) {
@@ -234,6 +268,9 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		return ERR_PTR(-ENXIO);
 	}
 
+	if (!ref)
+		return ERR_PTR(-EINVAL);
+
 	page_map = devres_alloc_node(devm_memremap_pages_release,
 			sizeof(*page_map), GFP_KERNEL, dev_to_node(dev));
 	if (!page_map)
@@ -247,6 +284,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		memcpy(&page_map->altmap, altmap, sizeof(*altmap));
 		pgmap->altmap = &page_map->altmap;
 	}
+	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
 
 	mutex_lock(&pgmap_lock);
@@ -284,6 +322,13 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_add_memory;
 
+	for_each_device_pfn(pfn, page_map) {
+		struct page *page = pfn_to_page(pfn);
+
+		/* ZONE_DEVICE pages never appear on a slab lru */
+		list_del_poison(&page->lru);
+		page->pgmap = pgmap;
+	}
 	devres_add(dev, page_map);
 	return __va(res->start);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
