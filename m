Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56AC26B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 21:45:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so11210287pgc.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 18:45:10 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g12si31377703pla.142.2016.12.08.18.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 18:45:09 -0800 (PST)
Subject: [PATCH v2 01/11] mm,
 devm_memremap_pages: use multi-order radix for ZONE_DEVICE lookups
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 08 Dec 2016 18:40:59 -0800
Message-ID: <148125125972.13512.15685214840850456163.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, toshi.kani@hpe.com

devm_memremap_pages() records mapped ranges in pgmap_radix with a entry
per section's worth of memory (128MB).  The key for each of those entries is
a section number.

This leads to false positives when devm_memremap_pages() is passed a
section-unaligned range as lookups in the misalignment fail to return
NULL. We can close this hole by using the pfn as the key for entries in
the tree.  The number of entries required to describe a remapped range
is reduced by leveraging multi-order entries.

In practice this approach usually yields just one entry in the tree if
the size and starting address are of the same power-of-2 alignment.
Previously we always needed nr_entries = mapping_size / 128MB.

Link: https://lists.01.org/pipermail/linux-nvdimm/2016-August/006666.html
Reported-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   53 +++++++++++++++++++++++++++++++++++++++--------------
 mm/Kconfig        |    1 +
 2 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index b501e390bb34..8cf34cc71b73 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -194,18 +194,39 @@ void put_zone_device_page(struct page *page)
 }
 EXPORT_SYMBOL(put_zone_device_page);
 
-static void pgmap_radix_release(struct resource *res)
+static unsigned long order_at(struct resource *res, unsigned long pgoff)
 {
-	resource_size_t key, align_start, align_size, align_end;
+	unsigned long phys_pgoff = PHYS_PFN(res->start) + pgoff;
+	unsigned long nr_pages = PHYS_PFN(resource_size(res));
+	unsigned long order_max, order_pgoff;
 
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(res), SECTION_SIZE);
-	align_end = align_start + align_size - 1;
+	if (nr_pages == pgoff)
+		return ULONG_MAX;
+
+	/*
+	 * What is the largest power-of-2 range available from this
+	 * resource pgoff to the end of the resource range, considering
+	 * the alignment of the current pgoff?
+	 */
+	order_pgoff = ilog2(nr_pages | phys_pgoff);
+	order_max = ilog2(nr_pages - pgoff);
+	return min(order_max, order_pgoff);
+}
+
+#define foreach_order_pgoff(res, order, pgoff) \
+	for (pgoff = 0, order = order_at((res), pgoff); order < ULONG_MAX; \
+			pgoff += 1UL << order, order = order_at((res), pgoff))
+
+static void pgmap_radix_release(struct resource *res)
+{
+	unsigned long pgoff, order;
 
 	mutex_lock(&pgmap_lock);
-	for (key = res->start; key <= res->end; key += SECTION_SIZE)
-		radix_tree_delete(&pgmap_radix, key >> PA_SECTION_SHIFT);
+	foreach_order_pgoff(res, order, pgoff)
+		radix_tree_delete(&pgmap_radix, PHYS_PFN(res->start) + pgoff);
 	mutex_unlock(&pgmap_lock);
+
+	synchronize_rcu();
 }
 
 static unsigned long pfn_first(struct page_map *page_map)
@@ -260,7 +281,7 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	page_map = radix_tree_lookup(&pgmap_radix, phys >> PA_SECTION_SHIFT);
+	page_map = radix_tree_lookup(&pgmap_radix, PHYS_PFN(phys));
 	return page_map ? &page_map->pgmap : NULL;
 }
 
@@ -282,12 +303,12 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
-	resource_size_t key, align_start, align_size, align_end;
+	resource_size_t align_start, align_size, align_end;
+	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
 	int error, nid, is_ram;
-	unsigned long pfn;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
@@ -326,11 +347,15 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	mutex_lock(&pgmap_lock);
 	error = 0;
 	align_end = align_start + align_size - 1;
-	for (key = align_start; key <= align_end; key += SECTION_SIZE) {
+
+	/* we're storing full physical addresses in the radix */
+	BUILD_BUG_ON(sizeof(unsigned long) < sizeof(resource_size_t));
+
+	foreach_order_pgoff(res, order, pgoff) {
 		struct dev_pagemap *dup;
 
 		rcu_read_lock();
-		dup = find_dev_pagemap(key);
+		dup = find_dev_pagemap(res->start + PFN_PHYS(pgoff));
 		rcu_read_unlock();
 		if (dup) {
 			dev_err(dev, "%s: %pr collides with mapping for %s\n",
@@ -338,8 +363,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 			error = -EBUSY;
 			break;
 		}
-		error = radix_tree_insert(&pgmap_radix, key >> PA_SECTION_SHIFT,
-				page_map);
+		error = __radix_tree_insert(&pgmap_radix,
+				PHYS_PFN(res->start) + pgoff, order, page_map);
 		if (error) {
 			dev_err(dev, "%s: failed: %d\n", __func__, error);
 			break;
diff --git a/mm/Kconfig b/mm/Kconfig
index 86e3e0e74d20..495e72dcb4da 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -694,6 +694,7 @@ config ZONE_DEVICE
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
 	depends on X86_64 #arch_add_memory() comprehends device memory
+	select RADIX_TREE_MULTIORDER
 
 	help
 	  Device memory hotplug support allows for establishing pmem,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
