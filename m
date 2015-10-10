Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2287B82F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:50 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so100984512pac.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id cr7si6455976pad.107.2015.10.09.18.02.49
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:49 -0700 (PDT)
Subject: [PATCH v2 19/20] mm, pmem: devm_memunmap_pages(),
 truncate and unmap ZONE_DEVICE pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:57:06 -0400
Message-ID: <20151010005706.17221.46569.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave@sr71.net>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, ross.zwisler@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

Before we allow ZONE_DEVICE pages to be put into active use outside of
the pmem driver, we need to arrange for them to be reclaimed when the
driver is shutdown.  devm_memunmap_pages() must wait for all pages to
return to the initial mapcount of 1.  If a given page is mapped by a
process we will truncate it out of its inode mapping and unmap it out of
the process vma.

This truncation is done while the dev_pagemap reference count is "dead",
preventing new references from being taken while the truncate+unmap scan
is in progress.

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Dave Chinner <david@fromorbit.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c |   42 ++++++++++++++++++++++++++++++++++++------
 fs/dax.c              |    2 ++
 include/linux/mm.h    |    5 +++++
 kernel/memremap.c     |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 91 insertions(+), 6 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index f7acce594fa0..2c9aebbc3fea 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -24,12 +24,15 @@
 #include <linux/memory_hotplug.h>
 #include <linux/moduleparam.h>
 #include <linux/vmalloc.h>
+#include <linux/async.h>
 #include <linux/slab.h>
 #include <linux/pmem.h>
 #include <linux/nd.h>
 #include "pfn.h"
 #include "nd.h"
 
+static ASYNC_DOMAIN_EXCLUSIVE(async_pmem);
+
 struct pmem_device {
 	struct request_queue	*pmem_queue;
 	struct gendisk		*pmem_disk;
@@ -164,14 +167,43 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 	return pmem;
 }
 
-static void pmem_detach_disk(struct pmem_device *pmem)
+
+static void async_blk_cleanup_queue(void *data, async_cookie_t cookie)
+{
+	struct pmem_device *pmem = data;
+
+	blk_cleanup_queue(pmem->pmem_queue);
+}
+
+static void pmem_detach_disk(struct device *dev)
 {
+	struct pmem_device *pmem = dev_get_drvdata(dev);
+	struct request_queue *q = pmem->pmem_queue;
+
 	if (!pmem->pmem_disk)
 		return;
 
 	del_gendisk(pmem->pmem_disk);
 	put_disk(pmem->pmem_disk);
-	blk_cleanup_queue(pmem->pmem_queue);
+	async_schedule_domain(async_blk_cleanup_queue, pmem, &async_pmem);
+
+	if (pmem->pfn_flags & PFN_MAP) {
+		/*
+		 * Wait for queue to go dead so that we know no new
+		 * references will be taken against the pages allocated
+		 * by devm_memremap_pages().
+		 */
+		blk_wait_queue_dead(q);
+
+		/*
+		 * Manually release the page mapping so that
+		 * blk_cleanup_queue() can complete queue draining.
+		 */
+		devm_memunmap_pages(dev, (void __force *) pmem->virt_addr);
+	}
+
+	/* Wait for blk_cleanup_queue() to finish */
+	async_synchronize_full_domain(&async_pmem);
 }
 
 static int pmem_attach_disk(struct device *dev,
@@ -299,11 +331,9 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 static int nvdimm_namespace_detach_pfn(struct nd_namespace_common *ndns)
 {
 	struct nd_pfn *nd_pfn = to_nd_pfn(ndns->claim);
-	struct pmem_device *pmem;
 
 	/* free pmem disk */
-	pmem = dev_get_drvdata(&nd_pfn->dev);
-	pmem_detach_disk(pmem);
+	pmem_detach_disk(&nd_pfn->dev);
 
 	/* release nd_pfn resources */
 	kfree(nd_pfn->pfn_sb);
@@ -446,7 +476,7 @@ static int nd_pmem_remove(struct device *dev)
 	else if (is_nd_pfn(dev))
 		nvdimm_namespace_detach_pfn(pmem->ndns);
 	else
-		pmem_detach_disk(pmem);
+		pmem_detach_disk(dev);
 
 	return 0;
 }
diff --git a/fs/dax.c b/fs/dax.c
index 87a070d6e6dc..208e064fafe5 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -46,6 +46,7 @@ static void __pmem *__dax_map_atomic(struct block_device *bdev, sector_t sector,
 		blk_queue_exit(q);
 		return (void __pmem *) ERR_PTR(rc);
 	}
+	rcu_read_lock();
 	return addr;
 }
 
@@ -62,6 +63,7 @@ static void dax_unmap_atomic(struct block_device *bdev, void __pmem *addr)
 	if (IS_ERR(addr))
 		return;
 	blk_queue_exit(bdev->bd_queue);
+	rcu_read_unlock();
 }
 
 /*
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8a84bfb6fa6a..af7597410cb9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -801,6 +801,7 @@ struct dev_pagemap {
 
 #ifdef CONFIG_ZONE_DEVICE
 struct dev_pagemap *__get_dev_pagemap(resource_size_t phys);
+void devm_memunmap_pages(struct device *dev, void *addr);
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
@@ -810,6 +811,10 @@ static inline struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
 	return NULL;
 }
 
+static inline void devm_memunmap_pages(struct device *dev, void *addr)
+{
+}
+
 static inline void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 246446ba6e2f..fa0cf1be2992 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -13,6 +13,7 @@
 #include <linux/rculist.h>
 #include <linux/device.h>
 #include <linux/types.h>
+#include <linux/fs.h>
 #include <linux/io.h>
 #include <linux/mm.h>
 #include <linux/memory_hotplug.h>
@@ -187,10 +188,39 @@ static unsigned long pfn_end(struct dev_pagemap *pgmap)
 
 static void devm_memremap_pages_release(struct device *dev, void *data)
 {
+	unsigned long pfn;
 	struct page_map *page_map = data;
 	struct resource *res = &page_map->res;
+	struct address_space *mapping_prev = NULL;
 	struct dev_pagemap *pgmap = &page_map->pgmap;
 
+	if (percpu_ref_tryget_live(pgmap->ref)) {
+		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
+		percpu_ref_put(pgmap->ref);
+	}
+
+	/* flush in-flight dax_map_atomic() operations */
+	synchronize_rcu();
+
+	for_each_device_pfn(pfn, pgmap) {
+		struct page *page = pfn_to_page(pfn);
+		struct address_space *mapping = page->mapping;
+		struct inode *inode = mapping ? mapping->host : NULL;
+
+		dev_WARN_ONCE(dev, atomic_read(&page->_count) < 1,
+				"%s: ZONE_DEVICE page was freed!\n", __func__);
+
+		if (!mapping || !inode || mapping == mapping_prev) {
+			dev_WARN_ONCE(dev, atomic_read(&page->_count) > 1,
+					"%s: unexpected elevated page count pfn: %lx\n",
+					__func__, pfn);
+			continue;
+		}
+
+		truncate_pagecache(inode, 0);
+		mapping_prev = mapping;
+	}
+
 	/* pages are dead and unused, undo the arch mapping */
 	arch_remove_memory(res->start, resource_size(res));
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
@@ -287,6 +317,24 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 }
 EXPORT_SYMBOL(devm_memremap_pages);
 
+static int page_map_match(struct device *dev, void *res, void *match_data)
+{
+	struct page_map *page_map = res;
+	resource_size_t phys = *(resource_size_t *) match_data;
+
+	return page_map->res.start == phys;
+}
+
+void devm_memunmap_pages(struct device *dev, void *addr)
+{
+	resource_size_t start = __pa(addr);
+
+	if (devres_release(dev, devm_memremap_pages_release, page_map_match,
+				&start) != 0)
+		dev_WARN(dev, "failed to find page map to release\n");
+}
+EXPORT_SYMBOL(devm_memunmap_pages);
+
 /*
  * Uncoditionally retrieve a dev_pagemap associated with the given physical
  * address, this is only for use in the arch_{add|remove}_memory() for setting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
