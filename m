Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19EE06B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:50 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f8so5372242pgs.9
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y3si3811134pgp.554.2017.12.07.07.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:47 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 05/14] mm: better abstract out dev_pagemap offset calculation
Date: Thu,  7 Dec 2017 07:08:31 -0800
Message-Id: <20171207150840.28409-6-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Add a helper that looks up the altmap (or later dev_pagemap) and returns
the offset.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/mm/mem.c    |  9 +++------
 arch/x86/mm/init_64.c    |  6 +-----
 include/linux/memremap.h |  8 ++++++--
 kernel/memremap.c        | 21 +++++++++++++--------
 mm/memory_hotplug.c      |  7 +------
 5 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 4362b86ef84c..c7cf396fdabc 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -152,18 +152,15 @@ int arch_remove_memory(u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct vmem_altmap *altmap;
 	struct page *page;
 	int ret;
 
 	/*
-	 * If we have an altmap then we need to skip over any reserved PFNs
-	 * when querying the zone.
+	 * If we have a device page map then we need to skip over any reserved
+	 * PFNs when querying the zone.
 	 */
 	page = pfn_to_page(start_pfn);
-	altmap = to_vmem_altmap((unsigned long) page);
-	if (altmap)
-		page += vmem_altmap_offset(altmap);
+	page += dev_pagemap_offset(page);
 
 	ret = __remove_pages(page_zone(page), start_pfn, nr_pages);
 	if (ret)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index f5e51b941d19..4f79ee1ef501 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1134,14 +1134,10 @@ int __ref arch_remove_memory(u64 start, u64 size)
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct page *page = pfn_to_page(start_pfn);
-	struct vmem_altmap *altmap;
 	struct zone *zone;
 	int ret;
 
-	/* With altmap the first mapped page is offset from @start */
-	altmap = to_vmem_altmap((unsigned long) page);
-	if (altmap)
-		page += vmem_altmap_offset(altmap);
+	page += dev_pagemap_offset(page);
 	zone = page_zone(page);
 	ret = __remove_pages(zone, start_pfn, nr_pages);
 	WARN_ON_ONCE(ret);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 054397a9414f..d221f4c0ccac 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -26,8 +26,6 @@ struct vmem_altmap {
 	unsigned long alloc;
 };
 
-unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
-
 #ifdef CONFIG_ZONE_DEVICE
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
 #else
@@ -140,6 +138,7 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 static inline bool is_zone_device_page(const struct page *page);
 int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages);
 bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages);
+unsigned long dev_pagemap_offset(struct page *page);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -170,6 +169,11 @@ static inline bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 {
 	return false;
 }
+
+static inline unsigned long dev_pagemap_offset(struct page *page)
+{
+	return 0;
+}
 #endif /* CONFIG_ZONE_DEVICE */
 
 #if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index c86bcd63e2cd..91a5fc1146b5 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -248,6 +248,17 @@ int device_private_entry_fault(struct vm_area_struct *vma,
 EXPORT_SYMBOL(device_private_entry_fault);
 #endif /* CONFIG_DEVICE_PRIVATE */
 
+static unsigned long __dev_pagemap_offset(struct vmem_altmap *pgmap)
+{
+	/* number of pfns from base where pfn_to_page() is valid */
+	return pgmap ? (pgmap->reserve + pgmap->free) : 0;
+}
+
+unsigned long dev_pagemap_offset(struct page *page)
+{
+	return __dev_pagemap_offset(to_vmem_altmap((uintptr_t)page));
+}
+
 static void pgmap_radix_release(struct resource *res)
 {
 	unsigned long pgoff, order;
@@ -269,7 +280,7 @@ static unsigned long pfn_first(struct page_map *page_map)
 
 	pfn = res->start >> PAGE_SHIFT;
 	if (altmap)
-		pfn += vmem_altmap_offset(altmap);
+		pfn += __dev_pagemap_offset(altmap);
 	return pfn;
 }
 
@@ -464,12 +475,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 }
 EXPORT_SYMBOL(devm_memremap_pages);
 
-unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
-{
-	/* number of pfns from base where pfn_to_page() is valid */
-	return altmap->reserve + altmap->free;
-}
-
 int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages)
 {
 	struct vmem_altmap *pgmap;
@@ -479,7 +484,7 @@ int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages)
 		return 0;
 
 	if (pgmap->base_pfn != phys_start_pfn ||
-	    vmem_altmap_offset(pgmap) > nr_pages) {
+	    __dev_pagemap_offset(pgmap) > nr_pages) {
 		pr_warn_once("memory add fail, invalid map\n");
 		return -EINVAL;
 	}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3e7c728f97e3..a7a719f057dc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -565,12 +565,7 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 
 	/* In the ZONE_DEVICE case device driver owns the memory region */
 	if (is_dev_zone(zone)) {
-		struct page *page = pfn_to_page(phys_start_pfn);
-		struct vmem_altmap *altmap;
-
-		altmap = to_vmem_altmap((unsigned long) page);
-		if (altmap)
-			map_offset = vmem_altmap_offset(altmap);
+		map_offset = dev_pagemap_offset(pfn_to_page(phys_start_pfn));
 	} else {
 		resource_size_t start, size;
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
