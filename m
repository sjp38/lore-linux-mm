Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 697916B0274
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:55:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q6so12022509pff.16
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:55:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 5si27718207plf.645.2017.12.28.23.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:55:29 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 15/17] memremap: drop private struct page_map
Date: Fri, 29 Dec 2017 08:54:04 +0100
Message-Id: <20171229075406.1936-16-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Logan Gunthorpe <logang@deltatee.com>

'struct page_map' is a private structure of 'struct dev_pagemap' but the
latter replicates all the same fields as the former so there isn't much
value in it. Thus drop it in favour of a completely public struct.

This is a clean up in preperation for a more generally useful
'devm_memeremap_pages' interface.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memremap.h |  5 ++--
 kernel/memremap.c        | 68 ++++++++++++++++++------------------------------
 mm/hmm.c                 |  2 +-
 3 files changed, 30 insertions(+), 45 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 3fddcfe57bb0..1cb5f39d25c1 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -113,8 +113,9 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
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
index 12e78528fea4..9207c44cce20 100644
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
@@ -260,22 +253,21 @@ static void pgmap_radix_release(struct resource *res)
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
 		pfn += vmem_altmap_offset(altmap);
 	return pfn;
 }
 
-static unsigned long pfn_end(struct page_map *page_map)
+static unsigned long pfn_end(struct dev_pagemap *pgmap)
 {
-	const struct resource *res = &page_map->res;
+	const struct resource *res = &pgmap->res;
 
 	return (res->start + resource_size(res)) >> PAGE_SHIFT;
 }
@@ -285,13 +277,12 @@ static unsigned long pfn_end(struct page_map *page_map)
 
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
@@ -304,24 +295,22 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size, pgmap->altmap);
+	arch_remove_memory(align_start, align_size, pgmap->altmap_valid ?
+			&pgmap->altmap : NULL);
 	mem_hotplug_done();
 
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
@@ -349,7 +338,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
 	struct dev_pagemap *pgmap;
-	struct page_map *page_map;
 	int error, nid, is_ram, i = 0;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
@@ -370,22 +358,20 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
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
-		altmap = pgmap->altmap;
+		memcpy(&pgmap->altmap, altmap, sizeof(*altmap));
+		pgmap->altmap_valid = true;
+		altmap = &pgmap->altmap;
 	}
 	pgmap->ref = ref;
-	pgmap->res = &page_map->res;
 	pgmap->type = MEMORY_DEVICE_HOST;
 	pgmap->page_fault = NULL;
 	pgmap->page_free = NULL;
@@ -397,7 +383,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 
 	foreach_order_pgoff(res, order, pgoff) {
 		error = __radix_tree_insert(&pgmap_radix,
-				PHYS_PFN(res->start) + pgoff, order, page_map);
+				PHYS_PFN(res->start) + pgoff, order, pgmap);
 		if (error) {
 			dev_err(dev, "%s: failed: %d\n", __func__, error);
 			break;
@@ -426,7 +412,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_add_memory;
 
-	for_each_device_pfn(pfn, page_map) {
+	for_each_device_pfn(pfn, pgmap) {
 		struct page *page = pfn_to_page(pfn);
 
 		/*
@@ -441,7 +427,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		if (!(++i % 1024))
 			cond_resched();
 	}
-	devres_add(dev, page_map);
+	devres_add(dev, pgmap);
 	return __va(res->start);
 
  err_add_memory:
@@ -449,7 +435,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
  err_pfn_remap:
  err_radix:
 	pgmap_radix_release(res);
-	devres_free(page_map);
+	devres_free(pgmap);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL(devm_memremap_pages);
@@ -482,9 +468,7 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
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
index 2f2e13c61040..320fdc87f064 100644
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
