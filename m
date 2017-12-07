Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6724A6B025E
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f7so5846160pfa.21
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j6si3824236pgs.459.2017.12.07.07.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:49 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 14/14] memremap: RCU protect data returned from dev_pagemap lookups
Date: Thu,  7 Dec 2017 07:08:40 -0800
Message-Id: <20171207150840.28409-15-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Take the RCU critical sections into the callers of to_vmem_altmap so that
we can read the page map inside the critical section.  Also rename the
remaining helper to __lookup_dev_pagemap to fit into the current naming
scheme.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/mm/init_64.c |  5 ++-
 arch/x86/mm/init_64.c     |  5 ++-
 include/linux/memremap.h  | 15 ++++----
 kernel/memremap.c         | 90 +++++++++++++++++++++++++----------------------
 4 files changed, 61 insertions(+), 54 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 872eed5a0867..7a78e432813f 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -201,11 +201,14 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 			continue;
 
 		/* pgmap lookups only work at section boundaries */
-		pgmap = to_vmem_altmap(SECTION_ALIGN_DOWN(start));
+		rcu_read_lock();
+		pgmap = __lookup_dev_pagemap((struct page *)
+				SECTION_ALIGN_DOWN(start));
 		if (pgmap)
 			p = dev_pagemap_alloc_block_buf(pgmap, page_size);
 		else
 			p = vmemmap_alloc_block_buf(page_size, node);
+		rcu_read_unlock();
 		if (!p)
 			return -ENOMEM;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bc01dc3b07a5..d07b173d277c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1409,9 +1409,11 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	struct dev_pagemap *pgmap = to_vmem_altmap(start);
+	struct dev_pagemap *pgmap;
 	int err;
 
+	rcu_read_lock();
+	pgmap = __lookup_dev_pagemap((struct page *)start);
 	if (boot_cpu_has(X86_FEATURE_PSE))
 		err = vmemmap_populate_hugepages(start, end, node, pgmap);
 	else if (pgmap) {
@@ -1420,6 +1422,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		err = -ENOMEM;
 	} else
 		err = vmemmap_populate_basepages(start, end, node);
+	rcu_read_unlock();
 	if (!err)
 		sync_global_pgds(start, end - 1);
 	return err;
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 7bea9a1b75f7..a7faf9174977 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -10,15 +10,6 @@
 struct resource;
 struct device;
 
-#ifdef CONFIG_ZONE_DEVICE
-struct dev_pagemap *to_vmem_altmap(unsigned long memmap_start);
-#else
-static inline struct dev_pagemap *to_vmem_altmap(unsigned long memmap_start)
-{
-	return NULL;
-}
-#endif
-
 /*
  * Specialize ZONE_DEVICE memory into multiple types each having differents
  * usage.
@@ -124,6 +115,7 @@ struct dev_pagemap {
 
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
+struct dev_pagemap *__lookup_dev_pagemap(struct page *start_page);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap);
 static inline bool is_zone_device_page(const struct page *page);
@@ -144,6 +136,11 @@ static inline void *devm_memremap_pages(struct device *dev,
 	return ERR_PTR(-ENXIO);
 }
 
+static inline struct dev_pagemap *__lookup_dev_pagemap(struct page *start_page)
+{
+	return NULL;
+}
+
 static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap)
 {
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 01529eeb06ad..b3e8b5028bec 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -241,6 +241,16 @@ int device_private_entry_fault(struct vm_area_struct *vma,
 EXPORT_SYMBOL(device_private_entry_fault);
 #endif /* CONFIG_DEVICE_PRIVATE */
 
+struct dev_pagemap *__lookup_dev_pagemap(struct page *start_page)
+{
+	struct dev_pagemap *pgmap;
+
+	pgmap = radix_tree_lookup(&pgmap_radix, page_to_pfn(start_page));
+	if (!pgmap || !pgmap->base_pfn)
+		return NULL;
+	return pgmap;
+}
+
 static unsigned long __dev_pagemap_offset(struct dev_pagemap *pgmap)
 {
 	/* number of pfns from base where pfn_to_page() is valid */
@@ -249,7 +259,16 @@ static unsigned long __dev_pagemap_offset(struct dev_pagemap *pgmap)
 
 unsigned long dev_pagemap_offset(struct page *page)
 {
-	return __dev_pagemap_offset(to_vmem_altmap((uintptr_t)page));
+	struct dev_pagemap *pgmap;
+	unsigned long ret = 0;
+
+	rcu_read_lock();
+	pgmap = __lookup_dev_pagemap(page);
+	if (pgmap)
+		ret = __dev_pagemap_offset(pgmap);
+	rcu_read_unlock();
+
+	return ret;
 }
 
 static void pgmap_radix_release(struct resource *res)
@@ -430,66 +449,51 @@ EXPORT_SYMBOL(devm_memremap_pages);
 int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages)
 {
 	struct dev_pagemap *pgmap;
+	int ret = 0;
 
-	pgmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
-	if (!pgmap)
-		return 0;
+	rcu_read_lock();
+	pgmap = __lookup_dev_pagemap(pfn_to_page(phys_start_pfn));
+	if (pgmap) {
+		if (pgmap->base_pfn != phys_start_pfn ||
+		    __dev_pagemap_offset(pgmap) > nr_pages) {
+			pr_warn_once("memory add fail, invalid map\n");
+			ret = -EINVAL;
+		}
 
-	if (pgmap->base_pfn != phys_start_pfn ||
-	    __dev_pagemap_offset(pgmap) > nr_pages) {
-		pr_warn_once("memory add fail, invalid map\n");
-		return -EINVAL;
+		pgmap->alloc = 0;
 	}
-
-	pgmap->alloc = 0;
-	return 0;
+	rcu_read_unlock();
+	return ret;
 }
 
 unsigned long dev_pagemap_start_pfn(unsigned long start_pfn)
 {
-	struct dev_pagemap *pgmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
+	struct page *page = (struct page *)__pfn_to_phys(start_pfn);
+	struct dev_pagemap *pgmap;
+	unsigned long ret = 0;
 
+	rcu_read_lock();
+	pgmap = __lookup_dev_pagemap(page);
 	if (pgmap && start_pfn == pgmap->base_pfn)
-		return pgmap->reserve;
-	return 0;
+		ret = pgmap->reserve;
+	rcu_read_unlock();
+	return ret;
 }
 
 bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 {
-	struct dev_pagemap *pgmap = to_vmem_altmap((uintptr_t)page);
-
-	if (!pgmap)
-		return false;
-	pgmap->alloc -= nr_pages;
-	return true;
-}
-
-struct dev_pagemap *to_vmem_altmap(unsigned long memmap_start)
-{
-	/*
-	 * 'memmap_start' is the virtual address for the first "struct
-	 * page" in this range of the vmemmap array.  In the case of
-	 * CONFIG_SPARSEMEM_VMEMMAP a page_to_pfn conversion is simple
-	 * pointer arithmetic, so we can perform this to_vmem_altmap()
-	 * conversion without concern for the initialization state of
-	 * the struct page fields.
-	 */
-	struct page *page = (struct page *) memmap_start;
 	struct dev_pagemap *pgmap;
+	bool ret = false;
 
-	/*
-	 * Unconditionally retrieve a dev_pagemap associated with the
-	 * given physical address, this is only for use in the
-	 * arch_{add|remove}_memory() for setting up and tearing down
-	 * the memmap.
-	 */
 	rcu_read_lock();
-	pgmap = radix_tree_lookup(&pgmap_radix, page_to_pfn(page));
+	pgmap = __lookup_dev_pagemap(page);
+	if (pgmap) {
+		pgmap->alloc -= nr_pages;
+		ret = true;
+	}
 	rcu_read_unlock();
 
-	if (!pgmap || !pgmap->base_pfn)
-		return NULL;
-	return pgmap;
+	return ret;
 }
 
 /**
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
