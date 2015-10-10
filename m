Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3436B0257
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:01:42 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so100746430pab.3
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:01:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id yk2si6408328pac.192.2015.10.09.18.01.38
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:01:41 -0700 (PDT)
Subject: [PATCH v2 04/20] mm: introduce __get_dev_pagemap()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:55:44 -0400
Message-ID: <20151010005544.17221.69747.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ross.zwisler@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de

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
 include/linux/mm.h |   18 ++++++++++++++++++
 kernel/memremap.c  |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80001de019ba..30c3c8764649 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -717,6 +717,24 @@ static inline enum zone_type page_zonenum(const struct page *page)
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
 }
 
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
+struct dev_pagemap *__get_dev_pagemap(resource_size_t phys);
+#else
+static inline struct dev_pagemap *get_dev_pagemap(resource_size_t phys)
+{
+	return NULL;
+}
+#endif
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 3218e8b1fc28..64bfd9fa93aa 100644
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
@@ -138,18 +139,52 @@ void devm_memunmap(struct device *dev, void *addr)
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
 
+static void add_page_map(struct page_map *page_map)
+{
+	spin_lock(&range_lock);
+	list_add_rcu(&page_map->list, &ranges);
+	spin_unlock(&range_lock);
+}
+
+static void del_page_map(struct page_map *page_map)
+{
+	spin_lock(&range_lock);
+	list_del_rcu(&page_map->list);
+	spin_unlock(&range_lock);
+}
+
 static void devm_memremap_pages_release(struct device *dev, void *res)
 {
 	struct page_map *page_map = res;
 
+	del_page_map(page_map);
+
 	/* pages are dead and unused, undo the arch mapping */
 	arch_remove_memory(page_map->res.start, resource_size(&page_map->res));
 }
 
+/* assumes rcu_read_lock() held at entry */
+struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
+{
+	struct page_map *page_map;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	list_for_each_entry_rcu(page_map, &ranges, list)
+		if (phys >= page_map->res.start && phys <= page_map->res.end)
+			return &page_map->pgmap;
+	return NULL;
+}
+
 void *devm_memremap_pages(struct device *dev, struct resource *res)
 {
 	int is_ram = region_intersects(res->start, resource_size(res),
@@ -173,12 +208,17 @@ void *devm_memremap_pages(struct device *dev, struct resource *res)
 
 	memcpy(&page_map->res, res, sizeof(*res));
 
+	page_map->pgmap.dev = dev;
+	INIT_LIST_HEAD(&page_map->list);
+	add_page_map(page_map);
+
 	nid = dev_to_node(dev);
 	if (nid < 0)
 		nid = numa_mem_id();
 
 	error = arch_add_memory(nid, res->start, resource_size(res), true);
 	if (error) {
+		del_page_map(page_map);
 		devres_free(page_map);
 		return ERR_PTR(error);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
