Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4F346B0008
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:45:33 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b31-v6so10931707plb.5
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:45:33 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h8-v6si15645208pls.502.2018.05.21.15.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:45:32 -0700 (PDT)
Subject: [PATCH 4/5] mm,
 hmm: replace hmm_devmem_pages_create() with devm_memremap_pages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 21 May 2018 15:35:34 -0700
Message-ID: <152694213486.5484.5340142369038375338.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit e8d513483300 "memremap: change devm_memremap_pages interface to
use struct dev_pagemap" refactored devm_memremap_pages() to allow a
dev_pagemap instance to be supplied. Passing in a dev_pagemap interface
simplifies the design of pgmap type drivers in that they can rely on
container_of() to lookup any private data associated with the given
dev_pagemap instance.

In addition to the cleanups this also gives hmm users multi-order-radix
improvements that arrived with commit ab1b597ee0e4 "mm,
devm_memremap_pages: use multi-order radix for ZONE_DEVICE lookups"

Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   29 +++++++-
 mm/hmm.c          |  194 +++++++----------------------------------------------
 2 files changed, 49 insertions(+), 174 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 30d96be5a965..bece24419d6d 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -395,11 +395,32 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, altmap, false);
-	if (!error)
-		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-					align_start >> PAGE_SHIFT,
+
+	/*
+	 * For device private memory we call add_pages() as we only need to
+	 * allocate and initialize struct page for the device memory. More-
+	 * over the device memory is un-accessible thus we do not want to
+	 * create a linear mapping for the memory like arch_add_memory()
+	 * would do.
+	 *
+	 * For all other device memory types, which are accessible by
+	 * the CPU, we do want the linear mapping and thus use
+	 * arch_add_memory().
+	 */
+	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
+		error = add_pages(nid, align_start >> PAGE_SHIFT,
+				align_size >> PAGE_SHIFT, NULL, false);
+	} else {
+		struct zone *zone;
+
+		error = arch_add_memory(nid, align_start, align_size, altmap,
+				false);
+		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
+		if (!error)
+			move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
 					align_size >> PAGE_SHIFT, altmap);
+	}
+
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
diff --git a/mm/hmm.c b/mm/hmm.c
index 8aa9d9fbb87b..a4162406067c 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -975,162 +975,6 @@ static void hmm_devmem_free(struct page *page, void *data)
 	devmem->ops->free(devmem, page);
 }
 
-static DEFINE_MUTEX(hmm_devmem_lock);
-static RADIX_TREE(hmm_devmem_radix, GFP_KERNEL);
-
-static void hmm_devmem_radix_release(struct resource *resource)
-{
-	resource_size_t key, align_start, align_size;
-
-	align_start = resource->start & ~(PA_SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(resource), PA_SECTION_SIZE);
-
-	mutex_lock(&hmm_devmem_lock);
-	for (key = resource->start;
-	     key <= resource->end;
-	     key += PA_SECTION_SIZE)
-		radix_tree_delete(&hmm_devmem_radix, key >> PA_SECTION_SHIFT);
-	mutex_unlock(&hmm_devmem_lock);
-}
-
-static void hmm_devmem_release(void *data)
-{
-	struct hmm_devmem *devmem = data;
-	struct device *dev = devmem->device;
-	struct resource *resource = devmem->resource;
-	struct dev_pagemap *pgmap = &devmem->pagemap;
-	unsigned long start_pfn, npages;
-	struct zone *zone;
-	struct page *page;
-
-	if (pgmap->registered && percpu_ref_tryget_live(&devmem->ref)) {
-		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
-		percpu_ref_put(&devmem->ref);
-	}
-
-	/* pages are dead and unused, undo the arch mapping */
-	start_pfn = (resource->start & ~(PA_SECTION_SIZE - 1)) >> PAGE_SHIFT;
-	npages = ALIGN(resource_size(resource), PA_SECTION_SIZE) >> PAGE_SHIFT;
-
-	page = pfn_to_page(start_pfn);
-	zone = page_zone(page);
-
-	mem_hotplug_begin();
-	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
-		__remove_pages(zone, start_pfn, npages, NULL);
-	else
-		arch_remove_memory(start_pfn << PAGE_SHIFT,
-				   npages << PAGE_SHIFT, NULL);
-	mem_hotplug_done();
-
-	hmm_devmem_radix_release(resource);
-}
-
-static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
-{
-	resource_size_t key, align_start, align_size, align_end;
-	struct device *device = devmem->device;
-	int ret, nid, is_ram;
-	unsigned long pfn;
-
-	align_start = devmem->resource->start & ~(PA_SECTION_SIZE - 1);
-	align_size = ALIGN(devmem->resource->start +
-			   resource_size(devmem->resource),
-			   PA_SECTION_SIZE) - align_start;
-
-	is_ram = region_intersects(align_start, align_size,
-				   IORESOURCE_SYSTEM_RAM,
-				   IORES_DESC_NONE);
-	if (is_ram == REGION_MIXED) {
-		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
-				__func__, devmem->resource);
-		return -ENXIO;
-	}
-	if (is_ram == REGION_INTERSECTS)
-		return -ENXIO;
-
-	if (devmem->resource->desc == IORES_DESC_DEVICE_PUBLIC_MEMORY)
-		devmem->pagemap.type = MEMORY_DEVICE_PUBLIC;
-	else
-		devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
-
-	devmem->pagemap.res = *devmem->resource;
-	devmem->pagemap.page_fault = hmm_devmem_fault;
-	devmem->pagemap.page_free = hmm_devmem_free;
-	devmem->pagemap.dev = devmem->device;
-	devmem->pagemap.ref = &devmem->ref;
-	devmem->pagemap.data = devmem;
-
-	mutex_lock(&hmm_devmem_lock);
-	align_end = align_start + align_size - 1;
-	for (key = align_start; key <= align_end; key += PA_SECTION_SIZE) {
-		struct hmm_devmem *dup;
-
-		dup = radix_tree_lookup(&hmm_devmem_radix,
-					key >> PA_SECTION_SHIFT);
-		if (dup) {
-			dev_err(device, "%s: collides with mapping for %s\n",
-				__func__, dev_name(dup->device));
-			mutex_unlock(&hmm_devmem_lock);
-			ret = -EBUSY;
-			goto error;
-		}
-		ret = radix_tree_insert(&hmm_devmem_radix,
-					key >> PA_SECTION_SHIFT,
-					devmem);
-		if (ret) {
-			dev_err(device, "%s: failed: %d\n", __func__, ret);
-			mutex_unlock(&hmm_devmem_lock);
-			goto error_radix;
-		}
-	}
-	mutex_unlock(&hmm_devmem_lock);
-
-	nid = dev_to_node(device);
-	if (nid < 0)
-		nid = numa_mem_id();
-
-	mem_hotplug_begin();
-	/*
-	 * For device private memory we call add_pages() as we only need to
-	 * allocate and initialize struct page for the device memory. More-
-	 * over the device memory is un-accessible thus we do not want to
-	 * create a linear mapping for the memory like arch_add_memory()
-	 * would do.
-	 *
-	 * For device public memory, which is accesible by the CPU, we do
-	 * want the linear mapping and thus use arch_add_memory().
-	 */
-	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
-		ret = arch_add_memory(nid, align_start, align_size, NULL,
-				false);
-	else
-		ret = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
-	if (ret) {
-		mem_hotplug_done();
-		goto error_add_memory;
-	}
-	move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL);
-	mem_hotplug_done();
-
-	for (pfn = devmem->pfn_first; pfn < devmem->pfn_last; pfn++) {
-		struct page *page = pfn_to_page(pfn);
-
-		page->pgmap = &devmem->pagemap;
-	}
-	return 0;
-
-error_add_memory:
-	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
-error_radix:
-	hmm_devmem_radix_release(devmem->resource);
-error:
-	return ret;
-}
-
 /*
  * hmm_devmem_add() - hotplug ZONE_DEVICE memory for device memory
  *
@@ -1154,6 +998,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 {
 	struct hmm_devmem *devmem;
 	resource_size_t addr;
+	void *result;
 	int ret;
 
 	static_branch_enable(&device_private_key);
@@ -1208,14 +1053,18 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
 
-	ret = hmm_devmem_pages_create(devmem);
-	if (ret)
-		return ERR_PTR(ret);
+	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
+	devmem->pagemap.res = *devmem->resource;
+	devmem->pagemap.page_fault = hmm_devmem_fault;
+	devmem->pagemap.page_free = hmm_devmem_free;
+	devmem->pagemap.altmap_valid = false;
+	devmem->pagemap.registered = false;
+	devmem->pagemap.ref = &devmem->ref;
+	devmem->pagemap.data = devmem;
 
-	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
-	if (ret)
-		return ERR_PTR(ret);
-	devmem->pagemap.registered = true;
+	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
+	if (IS_ERR(result))
+		return result;
 
 	ret = devm_add_action_or_reset(device, hmm_devmem_ref_kill, &devmem->ref);
 	if (ret)
@@ -1230,6 +1079,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 					   struct resource *res)
 {
 	struct hmm_devmem *devmem;
+	void *result;
 	int ret;
 
 	if (res->desc != IORES_DESC_DEVICE_PUBLIC_MEMORY)
@@ -1262,14 +1112,18 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
 
-	ret = hmm_devmem_pages_create(devmem);
-	if (ret)
-		return ERR_PTR(ret);
+	devmem->pagemap.type = MEMORY_DEVICE_PUBLIC;
+	devmem->pagemap.res = *devmem->resource;
+	devmem->pagemap.page_fault = hmm_devmem_fault;
+	devmem->pagemap.page_free = hmm_devmem_free;
+	devmem->pagemap.altmap_valid = false;
+	devmem->pagemap.registered = false;
+	devmem->pagemap.ref = &devmem->ref;
+	devmem->pagemap.data = devmem;
 
-	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
-	if (ret)
-		return ERR_PTR(ret);
-	devmem->pagemap.registered = true;
+	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
+	if (IS_ERR(result))
+		return result;
 
 	ret = devm_add_action_or_reset(device, hmm_devmem_ref_kill, &devmem->ref);
 	if (ret)
