Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id ADDBA6B0254
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:48:11 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so10926455pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:48:11 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id wp3si7666520pab.160.2015.09.22.21.48.10
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:48:11 -0700 (PDT)
Subject: [PATCH 14/15] mm, dax,
 pmem: introduce {get|put}_dev_pagemap() for dax-gup
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:42:27 -0400
Message-ID: <20150923044227.36490.99741.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

get_dev_page() enables paths like get_user_pages() to pin a dynamically
mapped pfn-range (devm_memremap_pages()) while the resulting struct page
objects are in use.  Unlike get_page() it may fail if the device is, or
is in the process of being, disabled.  While the initial lookup of the
range may be an expensive list walk, the result is cached to speed up
subsequent lookups which are likely to be in the same mapped range.

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c    |    2 +
 include/linux/io.h       |   17 -----------
 include/linux/mm.h       |   62 ++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |    6 +++-
 kernel/memremap.c        |   71 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 140 insertions(+), 18 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 1c670775129b..ac581a2e20e2 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -184,6 +184,7 @@ static void pmem_detach_disk(struct pmem_device *pmem)
 static int pmem_attach_disk(struct device *dev,
 		struct nd_namespace_common *ndns, struct pmem_device *pmem)
 {
+	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
 	int nid = dev_to_node(dev);
 	struct gendisk *disk;
 
@@ -191,6 +192,7 @@ static int pmem_attach_disk(struct device *dev,
 	if (!pmem->pmem_queue)
 		return -ENOMEM;
 
+	devm_register_pagemap(dev, &nsio->res, &pmem->pmem_queue->dax_ref.count);
 	blk_queue_make_request(pmem->pmem_queue, pmem_make_request);
 	blk_queue_physical_block_size(pmem->pmem_queue, PAGE_SIZE);
 	blk_queue_max_hw_sectors(pmem->pmem_queue, UINT_MAX);
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 989c5459bee7..6183549a854c 100644
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
@@ -558,6 +560,28 @@ static inline void init_page_count(struct page *page)
 void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
+#ifdef CONFIG_ZONE_DEVICE
+void *devm_memremap_pages(struct device *dev, struct resource *res);
+void devm_register_pagemap(struct device *dev, struct resource *res,
+		struct percpu_ref *ref);
+#else
+static inline void *devm_memremap_pages(struct device *dev, struct resource *res)
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
+static inline void devm_register_pagemap(struct device *dev, struct resource *res,
+		struct percpu_ref *ref)
+{
+}
+#endif
+
 void split_page(struct page *page, unsigned int order);
 int split_free_page(struct page *page);
 
@@ -717,6 +741,44 @@ static inline enum zone_type page_zonenum(const struct page *page)
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
 }
 
+/**
+ * struct dev_pagemap - reference count for a devm_memremap_pages mapping
+ * @res: physical address range covered by @ref
+ * @ref: reference count that pins the devm_memremap_pages() mapping
+ * @dev: host device of the mapping for debug
+ */
+struct dev_pagemap {
+	const struct resource *res;
+	struct percpu_ref *ref;
+	struct device *dev;
+};
+
+struct dev_pagemap *__get_dev_pagemap(resource_size_t phys);
+
+static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap)
+{
+	resource_size_t phys = PFN_PHYS(pfn);
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
+	return __get_dev_pagemap(phys);
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
index 3d6baa7d4534..20097e7b679a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -49,12 +49,16 @@ struct page {
 					 * updated asynchronously */
 	union {
 		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
+						 * inode address_space, unless
+						 * the page is in ZONE_DEVICE
+						 * then it points to its parent
+						 * dev_pagemap, otherwise NULL.
 						 * If page mapped as anonymous
 						 * memory, low bit is set, and
 						 * it points to anon_vma object:
 						 * see PAGE_MAPPING_ANON below.
 						 */
+		struct dev_pagemap *pgmap;
 		void *s_mem;			/* slab first object */
 	};
 
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 0d818ce04129..74344dc8c31e 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -10,6 +10,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+#include <linux/rculist.h>
 #include <linux/device.h>
 #include <linux/types.h>
 #include <linux/io.h>
@@ -137,16 +138,86 @@ void devm_memunmap(struct device *dev, void *addr)
 EXPORT_SYMBOL(devm_memunmap);
 
 #ifdef CONFIG_ZONE_DEVICE
+static LIST_HEAD(ranges);
+static DEFINE_SPINLOCK(range_lock);
+
 struct page_map {
 	struct resource res;
+	struct dev_pagemap pgmap;
+	struct list_head list;
 };
 
 static void devm_memremap_pages_release(struct device *dev, void *res)
 {
 	struct page_map *page_map = res;
+	struct dev_pagemap *pgmap = &page_map->pgmap;
 
 	/* pages are dead and unused, undo the arch mapping */
 	arch_remove_memory(page_map->res.start, resource_size(&page_map->res));
+
+	if (pgmap->res) {
+		spin_lock(&range_lock);
+		list_del_rcu(&page_map->list);
+		spin_unlock(&range_lock);
+		dev_WARN_ONCE(dev, !percpu_ref_is_zero(pgmap->ref),
+				"page mapping not idle in %s\n", __func__);
+	}
+}
+
+static int page_map_match(struct device *dev, void *res, void *match_data)
+{
+	struct page_map *page_map = res;
+	resource_size_t phys = *(resource_size_t *) match_data;
+
+	return page_map->res.start == phys;
+}
+
+void devm_register_pagemap(struct device *dev, struct resource *res,
+		struct percpu_ref *ref)
+{
+	struct page_map *page_map;
+	struct dev_pagemap *pgmap;
+	unsigned long pfn;
+
+	page_map = devres_find(dev, devm_memremap_pages_release,
+			page_map_match, &res->start);
+	dev_WARN_ONCE(dev, !page_map, "%s: no mapping found for %pa\n",
+			__func__, &res->start);
+	if (!page_map)
+		return;
+
+	pgmap = &page_map->pgmap;
+	pgmap->dev = dev;
+	pgmap->res = &page_map->res;
+	pgmap->ref = ref;
+	INIT_LIST_HEAD(&page_map->list);
+	spin_lock(&range_lock);
+	list_add_rcu(&page_map->list, &ranges);
+	spin_unlock(&range_lock);
+
+	for (pfn = res->start >> PAGE_SHIFT;
+			pfn < res->end >> PAGE_SHIFT; pfn++) {
+		struct page *page = pfn_to_page(pfn);
+
+		page->pgmap = pgmap;
+	}
+}
+EXPORT_SYMBOL(devm_register_pagemap);
+
+struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
+{
+	struct page_map *page_map;
+	struct dev_pagemap *pgmap = NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(page_map, &ranges, list)
+		if (phys >= page_map->res.start && phys <= page_map->res.end) {
+			if (percpu_ref_tryget_live(page_map->pgmap.ref))
+				pgmap = &page_map->pgmap;
+			break;
+		}
+	rcu_read_unlock();
+	return pgmap;
 }
 
 void *devm_memremap_pages(struct device *dev, struct resource *res)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
