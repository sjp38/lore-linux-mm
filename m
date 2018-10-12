Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 73FEE6B027B
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:01:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w15-v6so9641772pge.2
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:01:53 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u1-v6si1854596pgj.430.2018.10.12.11.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:01:51 -0700 (PDT)
Subject: [PATCH v7 6/7] mm,
 hmm: Replace hmm_devmem_pages_create() with devm_memremap_pages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 12 Oct 2018 10:50:03 -0700
Message-ID: <153936660337.1198040.15647039831458016806.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153936657159.1198040.4489957977352276272.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit e8d513483300 "memremap: change devm_memremap_pages interface to
use struct dev_pagemap" refactored devm_memremap_pages() to allow a
dev_pagemap instance to be supplied. Passing in a dev_pagemap interface
simplifies the design of pgmap type drivers in that they can rely on
container_of() to lookup any private data associated with the given
dev_pagemap instance.

In addition to the cleanups this also gives hmm users multi-order-radix
improvements that arrived with commit ab1b597ee0e4 "mm,
devm_memremap_pages: use multi-order radix for ZONE_DEVICE lookups"

As part of the conversion to the devm_memremap_pages() method of
handling the percpu_ref relative to when pages are put, the percpu_ref
completion needs to move to hmm_devmem_ref_exit(). See commit
71389703839e ("mm, zone_device: Replace {get, put}_zone_device_page...")
for details.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/hmm.c |  196 ++++++++------------------------------------------------------
 1 file changed, 26 insertions(+), 170 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 60e4b275ad78..2e72cb4188ca 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -938,17 +938,16 @@ static void hmm_devmem_ref_exit(void *data)
 	struct hmm_devmem *devmem;
 
 	devmem = container_of(ref, struct hmm_devmem, ref);
+	wait_for_completion(&devmem->completion);
 	percpu_ref_exit(ref);
 }
 
-static void hmm_devmem_ref_kill(void *data)
+static void hmm_devmem_ref_kill(struct percpu_ref *ref)
 {
-	struct percpu_ref *ref = data;
 	struct hmm_devmem *devmem;
 
 	devmem = container_of(ref, struct hmm_devmem, ref);
 	percpu_ref_kill(ref);
-	wait_for_completion(&devmem->completion);
 }
 
 static int hmm_devmem_fault(struct vm_area_struct *vma,
@@ -971,154 +970,6 @@ static void hmm_devmem_free(struct page *page, void *data)
 	devmem->ops->free(devmem, page);
 }
 
-static DEFINE_MUTEX(hmm_devmem_lock);
-static RADIX_TREE(hmm_devmem_radix, GFP_KERNEL);
-
-static void hmm_devmem_radix_release(struct resource *resource)
-{
-	resource_size_t key;
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
-	struct resource *resource = devmem->resource;
-	unsigned long start_pfn, npages;
-	struct zone *zone;
-	struct page *page;
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
-	/*
-	 * Initialization of the pages has been deferred until now in order
-	 * to allow us to do the work while not holding the hotplug lock.
-	 */
-	memmap_init_zone_device(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, &devmem->pagemap);
-
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
@@ -1142,6 +993,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 {
 	struct hmm_devmem *devmem;
 	resource_size_t addr;
+	void *result;
 	int ret;
 
 	dev_pagemap_get_ops();
@@ -1196,14 +1048,18 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
 
-	ret = hmm_devmem_pages_create(devmem);
-	if (ret)
-		return ERR_PTR(ret);
-
-	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
-	if (ret)
-		return ERR_PTR(ret);
+	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
+	devmem->pagemap.res = *devmem->resource;
+	devmem->pagemap.page_fault = hmm_devmem_fault;
+	devmem->pagemap.page_free = hmm_devmem_free;
+	devmem->pagemap.altmap_valid = false;
+	devmem->pagemap.ref = &devmem->ref;
+	devmem->pagemap.data = devmem;
+	devmem->pagemap.kill = hmm_devmem_ref_kill;
 
+	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
+	if (IS_ERR(result))
+		return result;
 	return devmem;
 }
 EXPORT_SYMBOL(hmm_devmem_add);
@@ -1213,6 +1069,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 					   struct resource *res)
 {
 	struct hmm_devmem *devmem;
+	void *result;
 	int ret;
 
 	if (res->desc != IORES_DESC_DEVICE_PUBLIC_MEMORY)
@@ -1245,19 +1102,18 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
 
-	ret = hmm_devmem_pages_create(devmem);
-	if (ret)
-		return ERR_PTR(ret);
-
-	ret = devm_add_action_or_reset(device, hmm_devmem_release, devmem);
-	if (ret)
-		return ERR_PTR(ret);
-
-	ret = devm_add_action_or_reset(device, hmm_devmem_ref_kill,
-			&devmem->ref);
-	if (ret)
-		return ERR_PTR(ret);
+	devmem->pagemap.type = MEMORY_DEVICE_PUBLIC;
+	devmem->pagemap.res = *devmem->resource;
+	devmem->pagemap.page_fault = hmm_devmem_fault;
+	devmem->pagemap.page_free = hmm_devmem_free;
+	devmem->pagemap.altmap_valid = false;
+	devmem->pagemap.ref = &devmem->ref;
+	devmem->pagemap.data = devmem;
+	devmem->pagemap.kill = hmm_devmem_ref_kill;
 
+	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
+	if (IS_ERR(result))
+		return result;
 	return devmem;
 }
 EXPORT_SYMBOL(hmm_devmem_add_resource);
