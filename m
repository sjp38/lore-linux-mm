Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF3282F64
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:33:57 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so3058323pac.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:33:57 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id i27si1303946pfj.107.2015.12.07.17.33.56
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:33:56 -0800 (PST)
Subject: [PATCH -mm 10/25] mm: introduce find_dev_pagemap()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:33:29 -0800
Message-ID: <20151208013329.25030.74643.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm@lists.01.org

There are several scenarios where we need to retrieve and update
metadata associated with a given devm_memremap_pages() mapping, and the
only lookup key available is a pfn in the range:

1/ We want to augment vmemmap_populate() (called via arch_add_memory())
   to allocate memmap storage from pre-allocated pages reserved by the
   device driver.  At vmemmap_alloc_block_buf() time it grabs device pages
   rather than page allocator pages.  This is in support of
   devm_memremap_pages() mappings where the memmap is too large to fit in
   main memory (i.e. large persistent memory devices).

2/ Taking a reference against the mapping when inserting device pages
   into the address_space radix of a given inode.  This facilitates
   unmap_mapping_range() and truncate_inode_pages() operations when the
   driver is tearing down the mapping.

3/ get_user_pages() operations on ZONE_DEVICE memory require taking a
   reference against the mapping so that the driver teardown path can
   revoke and drain usage of device pages.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/io.h |   15 ---------
 include/linux/mm.h |   33 ++++++++++++++++++++
 kernel/memremap.c  |   84 +++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 109 insertions(+), 23 deletions(-)

diff --git a/include/linux/io.h b/include/linux/io.h
index 72c35e0a41d1..32403b5716e5 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -90,21 +90,6 @@ void devm_memunmap(struct device *dev, void *addr);
 
 void *__devm_memremap_pages(struct device *dev, struct resource *res);
 
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
index 9eab91af1e32..5155a448a7f5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -670,6 +670,39 @@ static inline enum zone_type page_zonenum(const struct page *page)
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
 }
 
+struct resource;
+struct device;
+/**
+ * struct dev_pagemap - metadata for ZONE_DEVICE mappings
+ * @dev: host device of the mapping for debug
+ */
+struct dev_pagemap {
+	/* TODO: vmem_altmap and percpu_ref count */
+	struct device *dev;
+};
+
+#ifdef CONFIG_ZONE_DEVICE
+void *devm_memremap_pages(struct device *dev, struct resource *res);
+struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
+#else
+static inline void *devm_memremap_pages(struct device *dev,
+		struct resource *res)
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
+static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
+{
+	return NULL;
+}
+#endif
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 7658d32c5c78..9698d82e5e48 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -10,6 +10,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+#include <linux/radix-tree.h>
 #include <linux/device.h>
 #include <linux/types.h>
 #include <linux/io.h>
@@ -148,22 +149,57 @@ void devm_memunmap(struct device *dev, void *addr)
 EXPORT_SYMBOL(devm_memunmap);
 
 #ifdef CONFIG_ZONE_DEVICE
+static DEFINE_MUTEX(pgmap_lock);
+static RADIX_TREE(pgmap_radix, GFP_KERNEL);
+#define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
+#define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
+
 struct page_map {
 	struct resource res;
+	struct percpu_ref *ref;
+	struct dev_pagemap pgmap;
 };
 
-static void devm_memremap_pages_release(struct device *dev, void *res)
+static void pgmap_radix_release(struct resource *res)
+{
+	resource_size_t key;
+
+	mutex_lock(&pgmap_lock);
+	for (key = res->start; key <= res->end; key += SECTION_SIZE)
+		radix_tree_delete(&pgmap_radix, key >> PA_SECTION_SHIFT);
+	mutex_unlock(&pgmap_lock);
+}
+
+static void devm_memremap_pages_release(struct device *dev, void *data)
 {
-	struct page_map *page_map = res;
+	struct page_map *page_map = data;
+	struct resource *res = &page_map->res;
+	resource_size_t align_start, align_size;
+
+	pgmap_radix_release(res);
 
 	/* pages are dead and unused, undo the arch mapping */
-	arch_remove_memory(page_map->res.start, resource_size(&page_map->res));
+	align_start = res->start & ~(SECTION_SIZE - 1);
+	align_size = ALIGN(resource_size(res), SECTION_SIZE);
+	arch_remove_memory(align_start, align_size);
+}
+
+/* assumes rcu_read_lock() held at entry */
+struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
+{
+	struct page_map *page_map;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	page_map = radix_tree_lookup(&pgmap_radix, phys >> PA_SECTION_SHIFT);
+	return page_map ? &page_map->pgmap : NULL;
 }
 
 void *devm_memremap_pages(struct device *dev, struct resource *res)
 {
 	int is_ram = region_intersects(res->start, resource_size(res),
 			"System RAM");
+	resource_size_t key, align_start, align_size;
 	struct page_map *page_map;
 	int error, nid;
 
@@ -183,18 +219,50 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 
 	memcpy(&page_map->res, res, sizeof(*res));
 
+	page_map->pgmap.dev = dev;
+	mutex_lock(&pgmap_lock);
+	error = 0;
+	for (key = res->start; key <= res->end; key += SECTION_SIZE) {
+		struct dev_pagemap *dup;
+
+		rcu_read_lock();
+		dup = find_dev_pagemap(key);
+		rcu_read_unlock();
+		if (dup) {
+			dev_err(dev, "%s: %pr collides with mapping for %s\n",
+					__func__, res, dev_name(dup->dev));
+			error = -EBUSY;
+			break;
+		}
+		error = radix_tree_insert(&pgmap_radix, key >> PA_SECTION_SHIFT,
+				page_map);
+		if (error) {
+			dev_err(dev, "%s: failed: %d\n", __func__, error);
+			break;
+		}
+	}
+	mutex_unlock(&pgmap_lock);
+	if (error)
+		goto err_radix;
+
 	nid = dev_to_node(dev);
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	error = arch_add_memory(nid, res->start, resource_size(res), true);
-	if (error) {
-		devres_free(page_map);
-		return ERR_PTR(error);
-	}
+	align_start = res->start & ~(SECTION_SIZE - 1);
+	align_size = ALIGN(resource_size(res), SECTION_SIZE);
+	error = arch_add_memory(nid, align_start, align_size, true);
+	if (error)
+		goto err_add_memory;
 
 	devres_add(dev, page_map);
 	return __va(res->start);
+
+ err_add_memory:
+ err_radix:
+	pgmap_radix_release(res);
+	devres_free(page_map);
+	return ERR_PTR(error);
 }
 EXPORT_SYMBOL(devm_memremap_pages);
 #endif /* CONFIG_ZONE_DEVICE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
