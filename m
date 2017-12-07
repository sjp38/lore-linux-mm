Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36AB36B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o123so2463451pga.22
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 11si3918986plc.483.2017.12.07.07.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:48 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/14] memremap: drop private struct page_map
Date: Thu,  7 Dec 2017 07:08:35 -0800
Message-Id: <20171207150840.28409-10-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

From: Logan Gunthorpe <logang@deltatee.com>

'struct page_map' is a private structure of 'struct dev_pagemap' but the
latter replicates all the same fields as the former so there isn't much
value in it. Thus drop it in favour of a completely public struct.

This is a clean up in preperation for a more generally useful
'devm_memeremap_pages' interface.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h |  5 ++--
 kernel/memremap.c        | 67 +++++++++++++++++++-----------------------------
 mm/hmm.c                 |  2 +-
 3 files changed, 30 insertions(+), 44 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index fe60b4895f56..316effd61f16 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -122,8 +122,9 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
 struct dev_pagemap {
 	dev_page_fault_t page_fault;
 	dev_page_free_t page_free;
-	struct vmem_altmap *altmap;
-	const struct resource *res;
+	struct vmem_altmap altmap;
+	bool altmap_valid;
+	struct resource res;
 	struct percpu_ref *ref;
 	struct device *dev;
 	void *data;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 01025c5f3037..31bcfeea4a73 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -188,13 +188,6 @@ static RADIX_TREE(pgmap_radix, GFP_KERNEL);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
-struct page_map {
-	struct resource res;
-	struct percpu_ref *ref;
-	struct dev_pagemap pgmap;
-	struct vmem_altmap altmap;
-};
-
 static unsigned long order_at(struct resource *res, unsigned long pgoff)
 {
 	unsigned long phys_pgoff = PHYS_PFN(res->start) + pgoff;
@@ -271,22 +264,21 @@ static void pgmap_radix_release(struct resource *res)
 	synchronize_rcu();
 }
 
-static unsigned long pfn_first(struct page_map *page_map)
+static unsigned long pfn_first(struct dev_pagemap *pgmap)
 {
-	struct dev_pagemap *pgmap = &page_map->pgmap;
-	const struct resource *res = &page_map->res;
-	struct vmem_altmap *altmap = pgmap->altmap;
+	const struct resource *res = &pgmap->res;
+	struct vmem_altmap *altmap = &pgmap->altmap;
 	unsigned long pfn;
 
 	pfn = res->start >> PAGE_SHIFT;
-	if (altmap)
+	if (pgmap->altmap_valid)
 		pfn += __dev_pagemap_offset(altmap);
 	return pfn;
 }
 
-static unsigned long pfn_end(struct page_map *page_map)
+static unsigned long pfn_end(struct dev_pagemap *pgmap)
 {
-	const struct resource *res = &page_map->res;
+	const struct resource *res = &pgmap->res;
 
 	return (res->start + resource_size(res)) >> PAGE_SHIFT;
 }
@@ -296,13 +288,12 @@ static unsigned long pfn_end(struct page_map *page_map)
 
 static void devm_memremap_pages_release(struct device *dev, void *data)
 {
-	struct page_map *page_map = data;
-	struct resource *res = &page_map->res;
+	struct dev_pagemap *pgmap = data;
+	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
-	struct dev_pagemap *pgmap = &page_map->pgmap;
 	unsigned long pfn;
 
-	for_each_device_pfn(pfn, page_map)
+	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
 
 	if (percpu_ref_tryget_live(pgmap->ref)) {
@@ -320,19 +311,16 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
-	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
-			"%s: failed to free all reserved pages\n", __func__);
+	dev_WARN_ONCE(dev, pgmap->altmap.alloc,
+		      "%s: failed to free all reserved pages\n", __func__);
 }
 
 /* assumes rcu_read_lock() held at entry */
 static struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
-	struct page_map *page_map;
-
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	page_map = radix_tree_lookup(&pgmap_radix, PHYS_PFN(phys));
-	return page_map ? &page_map->pgmap : NULL;
+	return radix_tree_lookup(&pgmap_radix, PHYS_PFN(phys));
 }
 
 /**
@@ -360,7 +348,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
 	struct dev_pagemap *pgmap;
-	struct page_map *page_map;
 	int error, nid, is_ram, i = 0;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
@@ -381,21 +368,19 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (!ref)
 		return ERR_PTR(-EINVAL);
 
-	page_map = devres_alloc_node(devm_memremap_pages_release,
-			sizeof(*page_map), GFP_KERNEL, dev_to_node(dev));
-	if (!page_map)
+	pgmap = devres_alloc_node(devm_memremap_pages_release,
+			sizeof(*pgmap), GFP_KERNEL, dev_to_node(dev));
+	if (!pgmap)
 		return ERR_PTR(-ENOMEM);
-	pgmap = &page_map->pgmap;
 
-	memcpy(&page_map->res, res, sizeof(*res));
+	memcpy(&pgmap->res, res, sizeof(*res));
 
 	pgmap->dev = dev;
 	if (altmap) {
-		memcpy(&page_map->altmap, altmap, sizeof(*altmap));
-		pgmap->altmap = &page_map->altmap;
+		memcpy(&pgmap->altmap, altmap, sizeof(*altmap));
+		pgmap->altmap_valid = true;
 	}
 	pgmap->ref = ref;
-	pgmap->res = &page_map->res;
 	pgmap->type = MEMORY_DEVICE_HOST;
 	pgmap->page_fault = NULL;
 	pgmap->page_free = NULL;
@@ -418,7 +403,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 			break;
 		}
 		error = __radix_tree_insert(&pgmap_radix,
-				PHYS_PFN(res->start) + pgoff, order, page_map);
+				PHYS_PFN(res->start) + pgoff, order, pgmap);
 		if (error) {
 			dev_err(dev, "%s: failed: %d\n", __func__, error);
 			break;
@@ -447,7 +432,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_add_memory;
 
-	for_each_device_pfn(pfn, page_map) {
+	for_each_device_pfn(pfn, pgmap) {
 		struct page *page = pfn_to_page(pfn);
 
 		/*
@@ -462,7 +447,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		if (!(++i % 1024))
 			cond_resched();
 	}
-	devres_add(dev, page_map);
+	devres_add(dev, pgmap);
 	return __va(res->start);
 
  err_add_memory:
@@ -470,7 +455,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
  err_pfn_remap:
  err_radix:
 	pgmap_radix_release(res);
-	devres_free(page_map);
+	devres_free(pgmap);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL(devm_memremap_pages);
@@ -535,7 +520,9 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 	pgmap = find_dev_pagemap(__pfn_to_phys(page_to_pfn(page)));
 	rcu_read_unlock();
 
-	return pgmap ? pgmap->altmap : NULL;
+	if (!pgmap || !pgmap->altmap_valid)
+		return NULL;
+	return &pgmap->altmap;
 }
 
 /**
@@ -555,9 +542,7 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 	 * In the cached case we're already holding a live reference.
 	 */
 	if (pgmap) {
-		const struct resource *res = pgmap ? pgmap->res : NULL;
-
-		if (res && phys >= res->start && phys <= res->end)
+		if (phys >= pgmap->res.start && phys <= pgmap->res.end)
 			return pgmap;
 		put_dev_pagemap(pgmap);
 	}
diff --git a/mm/hmm.c b/mm/hmm.c
index 3a5c172af560..6d45c499c761 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -882,7 +882,7 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	else
 		devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
 
-	devmem->pagemap.res = devmem->resource;
+	devmem->pagemap.res = *devmem->resource;
 	devmem->pagemap.page_fault = hmm_devmem_fault;
 	devmem->pagemap.page_free = hmm_devmem_free;
 	devmem->pagemap.dev = devmem->device;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
