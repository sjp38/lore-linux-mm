Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 620F082F64
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:45:49 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id q3so73369660pav.3
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:45:49 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id p79si99655pfa.201.2015.12.20.21.45.48
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:48 -0800 (PST)
Subject: [-mm PATCH v4 14/18] mm, dax,
 pmem: introduce {get|put}_dev_pagemap() for dax-gup
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:45:21 -0800
Message-ID: <20151221054521.34542.62283.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
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

ZONE_DEVICE pages always have an elevated count and will never be on an
lru reclaim list.  That space in 'struct page' can be redirected for
other uses, but for safety introduce a poison value that will always
trip __list_add() to assert.  This allows half of the struct list_head
storage to be reclaimed with some assurance to back up the assumption
that the page count never goes to zero and a list_add() is never
attempted.

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Tested-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c    |    6 +++--
 include/linux/list.h     |   12 ++++++++++
 include/linux/memremap.h |   49 +++++++++++++++++++++++++++++++++++++++++--
 include/linux/mm_types.h |    5 ++++
 kernel/memremap.c        |   53 +++++++++++++++++++++++++++++++++++++++++++---
 lib/list_debug.c         |    9 ++++++++
 6 files changed, 126 insertions(+), 8 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 2c6096ab2ce6..37ebf42c0415 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -150,7 +150,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	if (pmem_should_map_pages(dev)) {
 		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
-				NULL);
+				&q->q_usage_counter, NULL);
 		pmem->pfn_flags |= PFN_MAP;
 	} else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
@@ -324,6 +324,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	struct vmem_altmap *altmap;
 	struct nd_pfn_sb *pfn_sb;
 	struct pmem_device *pmem;
+	struct request_queue *q;
 	phys_addr_t offset;
 	int rc;
 	struct vmem_altmap __altmap = {
@@ -375,9 +376,10 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 
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
diff --git a/include/linux/list.h b/include/linux/list.h
index 993395a2e55c..d870ba3315f8 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -113,6 +113,18 @@ extern void __list_del_entry(struct list_head *entry);
 extern void list_del(struct list_head *entry);
 #endif
 
+#ifdef CONFIG_DEBUG_LIST
+/*
+ * See devm_memremap_pages() which wants DEBUG_LIST=y to assert if one
+ * of the pages it allocates is ever passed to list_add()
+ */
+extern void list_force_poison(struct list_head *entry);
+#else
+static inline void list_force_poison(struct list_head *entry)
+{
+}
+#endif
+
 /**
  * list_replace - replace old entry by new one
  * @old : the element to be replaced
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index aa3e82a80d7b..bcaa634139a9 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_MEMREMAP_H_
 #define _LINUX_MEMREMAP_H_
 #include <linux/mm.h>
+#include <linux/ioport.h>
+#include <linux/percpu-refcount.h>
 
 struct resource;
 struct device;
@@ -36,21 +38,25 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
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
@@ -66,4 +72,43 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 	return NULL;
 }
 #endif
+
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
+	resource_size_t phys = PFN_PHYS(pfn);
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
 #endif /* _LINUX_MEMREMAP_H_ */
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
index 562f6471fe90..3eb8944265d5 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -179,6 +179,29 @@ static void pgmap_radix_release(struct resource *res)
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
@@ -186,6 +209,11 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	resource_size_t align_start, align_size;
 	struct dev_pagemap *pgmap = &page_map->pgmap;
 
+	if (percpu_ref_tryget_live(pgmap->ref)) {
+		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
+		percpu_ref_put(pgmap->ref);
+	}
+
 	pgmap_radix_release(res);
 
 	/* pages are dead and unused, undo the arch mapping */
@@ -211,20 +239,26 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
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
@@ -242,6 +276,9 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		return ERR_PTR(-ENXIO);
 	}
 
+	if (!ref)
+		return ERR_PTR(-EINVAL);
+
 	page_map = devres_alloc_node(devm_memremap_pages_release,
 			sizeof(*page_map), GFP_KERNEL, dev_to_node(dev));
 	if (!page_map)
@@ -255,6 +292,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		memcpy(&page_map->altmap, altmap, sizeof(*altmap));
 		pgmap->altmap = &page_map->altmap;
 	}
+	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
 
 	mutex_lock(&pgmap_lock);
@@ -292,6 +330,13 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_add_memory;
 
+	for_each_device_pfn(pfn, page_map) {
+		struct page *page = pfn_to_page(pfn);
+
+		/* ZONE_DEVICE pages must never appear on a slab lru */
+		list_force_poison(&page->lru);
+		page->pgmap = pgmap;
+	}
 	devres_add(dev, page_map);
 	return __va(res->start);
 
diff --git a/lib/list_debug.c b/lib/list_debug.c
index c24c2f7e296f..37fea7c0a7a4 100644
--- a/lib/list_debug.c
+++ b/lib/list_debug.c
@@ -12,6 +12,13 @@
 #include <linux/kernel.h>
 #include <linux/rculist.h>
 
+static struct list_head force_poison;
+void list_force_poison(struct list_head *entry)
+{
+	entry->next = &force_poison;
+	entry->prev = &force_poison;
+}
+
 /*
  * Insert a new entry between two known consecutive entries.
  *
@@ -23,6 +30,8 @@ void __list_add(struct list_head *new,
 			      struct list_head *prev,
 			      struct list_head *next)
 {
+	WARN(new->next == &force_poison || new->prev == &force_poison,
+		"list_add attempted on force-poisoned entry\n");
 	WARN(next->prev != prev,
 		"list_add corruption. next->prev should be "
 		"prev (%p), but was %p. (next=%p).\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
