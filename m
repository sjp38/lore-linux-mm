Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0096B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 17:42:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t73so15276556oie.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:42:28 -0700 (PDT)
Received: from gateway33.websitewelcome.com (gateway33.websitewelcome.com. [192.185.145.239])
        by mx.google.com with ESMTPS id k7si13795695otd.216.2016.10.18.14.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 14:42:27 -0700 (PDT)
Received: from cm1.websitewelcome.com (cm.websitewelcome.com [192.185.0.102])
	by gateway33.websitewelcome.com (Postfix) with ESMTP id 8326FD669B5E0
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 16:42:27 -0500 (CDT)
From: Stephen Bates <sbates@raithlin.com>
Subject: [PATCH 1/3] memremap.c : Add support for ZONE_DEVICE IO memory with struct pages.
Date: Tue, 18 Oct 2016 15:42:15 -0600
Message-Id: <1476826937-20665-2-git-send-email-sbates@raithlin.com>
In-Reply-To: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org
Cc: dan.j.williams@intel.com, ross.zwisler@linux.intel.com, willy@linux.intel.com, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, hch@infradead.org, axboe@fb.com, corbet@lwn.net, jim.macdonald@everspin.com, sbates@raithin.com, logang@deltatee.com, Stephen Bates <sbates@raithlin.com>

From: Logan Gunthorpe <logang@deltatee.com>

We build on recent work that adds memory regions owned by a device
driver (ZONE_DEVICE) [1] and to add struct page support for these new
regions of memory [2].

1. Add an extra flags argument into dev_memremap_pages to take in a
MEMREMAP_XX argument. We update the existing calls to this function to
reflect the change.

2. For completeness, we add MEMREMAP_WT support to the memremap;
however we have no actual need for this functionality.

3. We add the static functions, add_zone_device_pages and
remove_zone_device pages. These are similar to arch_add_memory except
they don't create the memory mapping. We don't believe these need to be
made arch specific, but are open to other opinions.

4. dev_memremap_pages and devm_memremap_pages_release are updated to
treat IO memory slightly differently. For IO memory we use a combination
of the appropriate io_remap function and the zone_device pages functions
created above. A flags variable and kaddr pointer are added to struct
page_mem to facilitate this for the release function. We also set up
the page attribute tables for the mapped region correctly based on the
desired mapping.

[1] https://lists.01.org/pipermail/linux-nvdimm/2015-August/001810.html
[2] https://lists.01.org/pipermail/linux-nvdimm/2015-October/002387.html

Signed-off-by: Stephen Bates <sbates@raithlin.com>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 drivers/dax/pmem.c                |  4 +-
 drivers/nvdimm/pmem.c             |  4 +-
 include/linux/memremap.h          |  5 ++-
 kernel/memremap.c                 | 80 +++++++++++++++++++++++++++++++++++++--
 tools/testing/nvdimm/test/iomap.c |  3 +-
 5 files changed, 86 insertions(+), 10 deletions(-)

diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index 9630d88..58ac456 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -14,6 +14,7 @@
 #include <linux/memremap.h>
 #include <linux/module.h>
 #include <linux/pfn_t.h>
+#include <linux/pmem.h>
 #include "../nvdimm/pfn.h"
 #include "../nvdimm/nd.h"
 #include "dax.h"
@@ -108,7 +109,8 @@ static int dax_pmem_probe(struct device *dev)
 	if (rc)
 		return rc;

-	addr = devm_memremap_pages(dev, &res, &dax_pmem->ref, altmap);
+	addr = devm_memremap_pages(dev, &res, &dax_pmem->ref, altmap,
+							ARCH_MEMREMAP_PMEM);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 42b3a82..97032a1 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -278,7 +278,7 @@ static int pmem_attach_disk(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	if (is_nd_pfn(dev)) {
 		addr = devm_memremap_pages(dev, &pfn_res, &q->q_usage_counter,
-				altmap);
+				altmap, ARCH_MEMREMAP_PMEM);
 		pfn_sb = nd_pfn->pfn_sb;
 		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
 		pmem->pfn_pad = resource_size(res) - resource_size(&pfn_res);
@@ -287,7 +287,7 @@ static int pmem_attach_disk(struct device *dev,
 		res->start += pmem->data_offset;
 	} else if (pmem_should_map_pages(dev)) {
 		addr = devm_memremap_pages(dev, &nsio->res,
-				&q->q_usage_counter, NULL);
+				&q->q_usage_counter, NULL, ARCH_MEMREMAP_PMEM);
 		pmem->pfn_flags |= PFN_MAP;
 	} else
 		addr = devm_memremap(dev, pmem->phys_addr,
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 9341619..fc99283 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -51,12 +51,13 @@ struct dev_pagemap {

 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap);
+		struct percpu_ref *ref, struct vmem_altmap *altmap,
+		unsigned long flags);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
-		struct vmem_altmap *altmap)
+		struct vmem_altmap *altmap, unsigned long flags)
 {
 	/*
 	 * Fail attempts to call devm_memremap_pages() without
diff --git a/kernel/memremap.c b/kernel/memremap.c
index b501e39..d5f462c 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -175,13 +175,41 @@ static RADIX_TREE(pgmap_radix, GFP_KERNEL);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)

+enum {
+	PAGEMAP_IO_MEM = 1 << 0,
+};
+
 struct page_map {
 	struct resource res;
 	struct percpu_ref *ref;
 	struct dev_pagemap pgmap;
 	struct vmem_altmap altmap;
+	void *kaddr;
+	int flags;
 };

+static int add_zone_device_pages(int nid, u64 start, u64 size)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *zone = pgdat->node_zones + ZONE_DEVICE;
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	return __add_pages(nid, zone, start_pfn, nr_pages);
+}
+
+static void remove_zone_device_pages(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+	int ret;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	ret = __remove_pages(zone, start_pfn, nr_pages);
+	WARN_ON_ONCE(ret);
+}
+
 void get_zone_device_page(struct page *page)
 {
 	percpu_ref_get(page->pgmap->ref);
@@ -246,9 +274,17 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
-	arch_remove_memory(align_start, align_size);
+
+	if (page_map->flags & PAGEMAP_IO_MEM) {
+		remove_zone_device_pages(align_start, align_size);
+		iounmap(page_map->kaddr);
+	} else {
+		arch_remove_memory(align_start, align_size);
+	}
+
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
+
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
 			"%s: failed to free all reserved pages\n", __func__);
 }
@@ -270,6 +306,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
  * @res: "host memory" address range
  * @ref: a live per-cpu reference count
  * @altmap: optional descriptor for allocating the memmap from @res
+ * @flags: either MEMREMAP_WB, MEMREMAP_WT and MEMREMAP_WC
+ *         see memremap() for a description of the flags
  *
  * Notes:
  * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
@@ -280,7 +318,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
  *    this is not enforced.
  */
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap)
+		struct percpu_ref *ref, struct vmem_altmap *altmap,
+		unsigned long flags)
 {
 	resource_size_t key, align_start, align_size, align_end;
 	pgprot_t pgprot = PAGE_KERNEL;
@@ -288,6 +327,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	struct page_map *page_map;
 	int error, nid, is_ram;
 	unsigned long pfn;
+	void *addr = NULL;
+	enum page_cache_mode pcm;

 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
@@ -353,15 +394,44 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (nid < 0)
 		nid = numa_mem_id();

+	if (flags & MEMREMAP_WB)
+		pcm = _PAGE_CACHE_MODE_WB;
+	else if (flags & MEMREMAP_WT)
+		pcm = _PAGE_CACHE_MODE_WT;
+	else if (flags & MEMREMAP_WC)
+		pcm = _PAGE_CACHE_MODE_WC;
+	else
+		pcm = _PAGE_CACHE_MODE_WB;
+
+	pgprot = __pgprot(pgprot_val(pgprot) | cachemode2protval(pcm));
+
 	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
 			align_size);
 	if (error)
 		goto err_pfn_remap;

-	error = arch_add_memory(nid, align_start, align_size, true);
+	if (flags & MEMREMAP_WB || !flags) {
+		error = arch_add_memory(nid, align_start, align_size, true);
+		addr = __va(res->start);
+	} else {
+		page_map->flags |= PAGEMAP_IO_MEM;
+		error = add_zone_device_pages(nid, align_start, align_size);
+	}
+
 	if (error)
 		goto err_add_memory;

+	if (!addr && (flags & MEMREMAP_WT))
+		addr = ioremap_wt(res->start, resource_size(res));
+
+	if (!addr && (flags & MEMREMAP_WC))
+		addr = ioremap_wc(res->start, resource_size(res));
+
+	if (!addr && page_map->flags & PAGEMAP_IO_MEM) {
+		remove_zone_device_pages(res->start, resource_size(res));
+		goto err_add_memory;
+	}
+
 	for_each_device_pfn(pfn, page_map) {
 		struct page *page = pfn_to_page(pfn);

@@ -374,8 +444,10 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		list_del(&page->lru);
 		page->pgmap = pgmap;
 	}
+
+	page_map->kaddr = addr;
 	devres_add(dev, page_map);
-	return __va(res->start);
+	return addr;

  err_add_memory:
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index 3ccef73..b82fecb 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/pfn_t.h>
+#include <linux/pmem.h>
 #include <linux/acpi.h>
 #include <linux/io.h>
 #include <linux/mm.h>
@@ -109,7 +110,7 @@ void *__wrap_devm_memremap_pages(struct device *dev, struct resource *res,

 	if (nfit_res)
 		return nfit_res->buf + offset - nfit_res->res.start;
-	return devm_memremap_pages(dev, res, ref, altmap);
+	return devm_memremap_pages(dev, res, ref, altmap, ARCH_MEMREMAP_PMEM);
 }
 EXPORT_SYMBOL(__wrap_devm_memremap_pages);

--
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
