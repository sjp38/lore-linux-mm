Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDB36B0260
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 17:34:02 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 3so127357960pgd.3
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 14:34:02 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 129si1933572pfx.1.2016.12.01.14.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 14:34:01 -0800 (PST)
Subject: [PATCH 01/11] mm,
 devm_memremap_pages: use multi-order radix for ZONE_DEVICE lookups
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Dec 2016 14:29:52 -0800
Message-ID: <148063139194.37496.13883044011361266303.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148063138593.37496.4684424640746238765.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148063138593.37496.4684424640746238765.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, toshi.kani@hpe.com, linux-nvdimm@lists.01.org

devm_memremap_pages() records mapped ranges in pgmap_radix with a entry
per section's worth of memory (128MB).  The key for each of those entries is
a section number.

This leads to false positives when devm_memremap_pages() is passed a
section-unaligned range as lookups in the misalignment fail to return
NULL. We can close this hole by using the unmodified physical address as
the key for entries in the tree.  The number of entries required to
describe a remapped range is reduced by leveraging multi-order entries.

In practice this approach usually yields just one entry in the tree if
the size and starting address is power-of-2 aligned.  Previously we
needed mapping_size / 128MB entries.

Link: https://lists.01.org/pipermail/linux-nvdimm/2016-August/006666.html
Reported-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   53 +++++++++++++++++++++++++++++++++++++++--------------
 mm/Kconfig        |    1 +
 2 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index b501e390bb34..10becd7855ca 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -194,18 +194,39 @@ void put_zone_device_page(struct page *page)
 }
 EXPORT_SYMBOL(put_zone_device_page);
 
-static void pgmap_radix_release(struct resource *res)
+static unsigned order_at(struct resource *res, unsigned long offset)
 {
-	resource_size_t key, align_start, align_size, align_end;
+	unsigned long phys_offset = res->start + offset;
+	resource_size_t size = resource_size(res);
+	unsigned order_max, order_offset;
 
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(res), SECTION_SIZE);
-	align_end = align_start + align_size - 1;
+	if (size == offset)
+		return UINT_MAX;
+
+	/*
+	 * What is the largest power-of-2 range available from this
+	 * resource offset to the end of the resource range, considering
+	 * the alignment of the current offset?
+	 */
+	order_offset = ilog2(size | phys_offset);
+	order_max = ilog2(size - offset);
+	return min(order_max, order_offset);
+}
+
+#define foreach_order_offset(res, order, offset) \
+	for (offset = 0, order = order_at((res), offset); order < UINT_MAX; \
+		offset += 1UL << order, order = order_at((res), offset))
+
+static void pgmap_radix_release(struct resource *res)
+{
+	unsigned long offset, order;
 
 	mutex_lock(&pgmap_lock);
-	for (key = res->start; key <= res->end; key += SECTION_SIZE)
-		radix_tree_delete(&pgmap_radix, key >> PA_SECTION_SHIFT);
+	foreach_order_offset(res, order, offset)
+		radix_tree_delete(&pgmap_radix, res->start + offset);
 	mutex_unlock(&pgmap_lock);
+
+	synchronize_rcu();
 }
 
 static unsigned long pfn_first(struct page_map *page_map)
@@ -260,7 +281,7 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	page_map = radix_tree_lookup(&pgmap_radix, phys >> PA_SECTION_SHIFT);
+	page_map = radix_tree_lookup(&pgmap_radix, phys);
 	return page_map ? &page_map->pgmap : NULL;
 }
 
@@ -282,12 +303,12 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
-	resource_size_t key, align_start, align_size, align_end;
+	resource_size_t align_start, align_size, align_end;
+	unsigned long pfn, offset, order;
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
+	foreach_order_offset(res, order, offset) {
 		struct dev_pagemap *dup;
 
 		rcu_read_lock();
-		dup = find_dev_pagemap(key);
+		dup = find_dev_pagemap(res->start + offset);
 		rcu_read_unlock();
 		if (dup) {
 			dev_err(dev, "%s: %pr collides with mapping for %s\n",
@@ -338,8 +363,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 			error = -EBUSY;
 			break;
 		}
-		error = radix_tree_insert(&pgmap_radix, key >> PA_SECTION_SHIFT,
-				page_map);
+		error = __radix_tree_insert(&pgmap_radix, res->start + offset,
+				order, page_map);
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
