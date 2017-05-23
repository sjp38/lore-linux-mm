Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07AA26B02F4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 17:37:19 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f96so67031797qki.14
        for <linux-mm@kvack.org>; Tue, 23 May 2017 14:37:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a4si22537738qkf.331.2017.05.23.14.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 14:37:17 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 09/18] mm/hmm/devmem: device memory hotplug using ZONE_DEVICE v5
Date: Tue, 23 May 2017 17:37:12 -0400
Message-Id: <20170523213712.23706-1-jglisse@redhat.com>
In-Reply-To: <20170522165206.6284-10-jglisse@redhat.com>
References: <20170522165206.6284-10-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This introduce a simple struct and associated helpers for device driver
to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
will find a unuse physical address range and trigger memory hotplug for
it which allocates and initialize struct page for the device memory.

Changed since v4:
  - enable device_private_key static key when adding device memory
Changed since v3:
  - s/device unaddressable/device private/
Changed since v2:
  - s/SECTION_SIZE/PA_SECTION_SIZE
Changed since v1:
  - change to adapt to new add_pages() helper
  - make this x86-64 only for now

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h | 114 ++++++++++++++
 mm/Kconfig          |   9 ++
 mm/hmm.c            | 416 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 538 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 248a6e0..0865afd 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -72,6 +72,11 @@
 
 #if IS_ENABLED(CONFIG_HMM)
 
+#include <linux/migrate.h>
+#include <linux/memremap.h>
+#include <linux/completion.h>
+
+
 struct hmm;
 
 /*
@@ -322,6 +327,115 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
+#if IS_ENABLED(CONFIG_HMM_DEVMEM)
+struct hmm_devmem;
+
+struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
+				       unsigned long addr);
+
+/*
+ * struct hmm_devmem_ops - callback for ZONE_DEVICE memory events
+ *
+ * @free: call when refcount on page reach 1 and thus is no longer use
+ * @fault: call when there is a page fault to unaddressable memory
+ */
+struct hmm_devmem_ops {
+	void (*free)(struct hmm_devmem *devmem, struct page *page);
+	int (*fault)(struct hmm_devmem *devmem,
+		     struct vm_area_struct *vma,
+		     unsigned long addr,
+		     struct page *page,
+		     unsigned int flags,
+		     pmd_t *pmdp);
+};
+
+/*
+ * struct hmm_devmem - track device memory
+ *
+ * @completion: completion object for device memory
+ * @pfn_first: first pfn for this resource (set by hmm_devmem_add())
+ * @pfn_last: last pfn for this resource (set by hmm_devmem_add())
+ * @resource: IO resource reserved for this chunk of memory
+ * @pagemap: device page map for that chunk
+ * @device: device to bind resource to
+ * @ops: memory operations callback
+ * @ref: per CPU refcount
+ *
+ * This an helper structure for device drivers that do not wish to implement
+ * the gory details related to hotplugging new memoy and allocating struct
+ * pages.
+ *
+ * Device drivers can directly use ZONE_DEVICE memory on their own if they
+ * wish to do so.
+ */
+struct hmm_devmem {
+	struct completion		completion;
+	unsigned long			pfn_first;
+	unsigned long			pfn_last;
+	struct resource			*resource;
+	struct device			*device;
+	struct dev_pagemap		pagemap;
+	const struct hmm_devmem_ops	*ops;
+	struct percpu_ref		ref;
+};
+
+/*
+ * To add (hotplug) device memory, HMM assumes that there is no real resource
+ * that reserves a range in the physical address space (this is intended to be
+ * use by unaddressable device memory). It will reserve a physical range big
+ * enough and allocate struct page for it.
+ *
+ * The device driver can wrap the hmm_devmem struct inside a private device
+ * driver struct. The device driver must call hmm_devmem_remove() before the
+ * device goes away and before freeing the hmm_devmem struct memory.
+ */
+struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
+				  struct device *device,
+				  unsigned long size);
+void hmm_devmem_remove(struct hmm_devmem *devmem);
+
+int hmm_devmem_fault_range(struct hmm_devmem *devmem,
+			   struct vm_area_struct *vma,
+			   const struct migrate_vma_ops *ops,
+			   unsigned long *src,
+			   unsigned long *dst,
+			   unsigned long start,
+			   unsigned long addr,
+			   unsigned long end,
+			   void *private);
+
+/*
+ * hmm_devmem_page_set_drvdata - set per-page driver data field
+ *
+ * @page: pointer to struct page
+ * @data: driver data value to set
+ *
+ * Because page can not be on lru we have an unsigned long that driver can use
+ * to store a per page field. This just a simple helper to do that.
+ */
+static inline void hmm_devmem_page_set_drvdata(struct page *page,
+					       unsigned long data)
+{
+	unsigned long *drvdata = (unsigned long *)&page->pgmap;
+
+	drvdata[1] = data;
+}
+
+/*
+ * hmm_devmem_page_get_drvdata - get per page driver data field
+ *
+ * @page: pointer to struct page
+ * Return: driver data value
+ */
+static inline unsigned long hmm_devmem_page_get_drvdata(struct page *page)
+{
+	unsigned long *drvdata = (unsigned long *)&page->pgmap;
+
+	return drvdata[1];
+}
+#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
+
+
 /* Below are for HMM internal use only! Not to be used by device driver! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/Kconfig b/mm/Kconfig
index f5357ff..46296d5 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -314,6 +314,15 @@ config HMM_MIRROR
 	  page tables (at PAGE_SIZE granularity), and must be able to recover from
 	  the resulting potential page faults.
 
+config HMM_DEVMEM
+	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
+	depends on ARCH_HAS_HMM
+	select HMM
+	help
+	  HMM devmem is a set of helper routines to leverage the ZONE_DEVICE
+	  feature. This is just to avoid having device drivers to replicating a lot
+	  of boiler plate code.  See Documentation/vm/hmm.txt.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
diff --git a/mm/hmm.c b/mm/hmm.c
index ed97051..87cc130 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -23,9 +23,15 @@
 #include <linux/swap.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/mmzone.h>
+#include <linux/pagemap.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
+#include <linux/memremap.h>
 #include <linux/mmu_notifier.h>
+#include <linux/memory_hotplug.h>
+
+#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
@@ -427,7 +433,15 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			 * This is a special swap entry, ignore migration, use
 			 * device and report anything else as error.
 			 */
-			if (is_migration_entry(entry)) {
+			if (is_device_private_entry(entry)) {
+				pfns[i] = hmm_pfn_t_from_pfn(swp_offset(entry));
+				if (is_write_device_private_entry(entry)) {
+					pfns[i] |= HMM_PFN_WRITE;
+				} else if (write_fault)
+					goto fault;
+				pfns[i] |= HMM_PFN_DEVICE_UNADDRESSABLE;
+				pfns[i] |= flag;
+			} else if (is_migration_entry(entry)) {
 				if (hmm_vma_walk->fault) {
 					pte_unmap(ptep);
 					hmm_vma_walk->last = addr;
@@ -721,3 +735,403 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 }
 EXPORT_SYMBOL(hmm_vma_fault);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
+
+
+#if IS_ENABLED(CONFIG_HMM_DEVMEM)
+struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
+				       unsigned long addr)
+{
+	struct page *page;
+
+	page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
+	if (!page)
+		return NULL;
+	lock_page(page);
+	return page;
+}
+EXPORT_SYMBOL(hmm_vma_alloc_locked_page);
+
+
+static void hmm_devmem_ref_release(struct percpu_ref *ref)
+{
+	struct hmm_devmem *devmem;
+
+	devmem = container_of(ref, struct hmm_devmem, ref);
+	complete(&devmem->completion);
+}
+
+static void hmm_devmem_ref_exit(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct hmm_devmem *devmem;
+
+	devmem = container_of(ref, struct hmm_devmem, ref);
+	percpu_ref_exit(ref);
+	devm_remove_action(devmem->device, &hmm_devmem_ref_exit, data);
+}
+
+static void hmm_devmem_ref_kill(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct hmm_devmem *devmem;
+
+	devmem = container_of(ref, struct hmm_devmem, ref);
+	percpu_ref_kill(ref);
+	wait_for_completion(&devmem->completion);
+	devm_remove_action(devmem->device, &hmm_devmem_ref_kill, data);
+}
+
+static int hmm_devmem_fault(struct vm_area_struct *vma,
+			    unsigned long addr,
+			    struct page *page,
+			    unsigned int flags,
+			    pmd_t *pmdp)
+{
+	struct hmm_devmem *devmem = page->pgmap->data;
+
+	return devmem->ops->fault(devmem, vma, addr, page, flags, pmdp);
+}
+
+static void hmm_devmem_free(struct page *page, void *data)
+{
+	struct hmm_devmem *devmem = data;
+
+	devmem->ops->free(devmem, page);
+}
+
+static DEFINE_MUTEX(hmm_devmem_lock);
+static RADIX_TREE(hmm_devmem_radix, GFP_KERNEL);
+
+static void hmm_devmem_radix_release(struct resource *resource)
+{
+	resource_size_t key, align_start, align_size, align_end;
+
+	align_start = resource->start & ~(PA_SECTION_SIZE - 1);
+	align_size = ALIGN(resource_size(resource), PA_SECTION_SIZE);
+	align_end = align_start + align_size - 1;
+
+	mutex_lock(&hmm_devmem_lock);
+	for (key = resource->start;
+	     key <= resource->end;
+	     key += PA_SECTION_SIZE)
+		radix_tree_delete(&hmm_devmem_radix, key >> PA_SECTION_SHIFT);
+	mutex_unlock(&hmm_devmem_lock);
+}
+
+static void hmm_devmem_release(struct device *dev, void *data)
+{
+	struct hmm_devmem *devmem = data;
+	struct resource *resource = devmem->resource;
+	unsigned long start_pfn, npages;
+	struct zone *zone;
+	struct page *page;
+
+	if (percpu_ref_tryget_live(&devmem->ref)) {
+		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
+		percpu_ref_put(&devmem->ref);
+	}
+
+	/* pages are dead and unused, undo the arch mapping */
+	start_pfn = (resource->start & ~(PA_SECTION_SIZE - 1)) >> PAGE_SHIFT;
+	npages = ALIGN(resource_size(resource), PA_SECTION_SIZE) >> PAGE_SHIFT;
+
+	page = pfn_to_page(start_pfn);
+	zone = page_zone(page);
+
+	mem_hotplug_begin();
+	__remove_pages(zone, start_pfn, npages);
+	mem_hotplug_done();
+
+	hmm_devmem_radix_release(resource);
+}
+
+static struct hmm_devmem *hmm_devmem_find(resource_size_t phys)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	return radix_tree_lookup(&hmm_devmem_radix, phys >> PA_SECTION_SHIFT);
+}
+
+static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
+{
+	resource_size_t key, align_start, align_size, align_end;
+	struct device *device = devmem->device;
+	int ret, nid, is_ram;
+	unsigned long pfn;
+
+	align_start = devmem->resource->start & ~(PA_SECTION_SIZE - 1);
+	align_size = ALIGN(devmem->resource->start +
+			   resource_size(devmem->resource),
+			   PA_SECTION_SIZE) - align_start;
+
+	is_ram = region_intersects(align_start, align_size,
+				   IORESOURCE_SYSTEM_RAM,
+				   IORES_DESC_NONE);
+	if (is_ram == REGION_MIXED) {
+		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
+				__func__, devmem->resource);
+		return -ENXIO;
+	}
+	if (is_ram == REGION_INTERSECTS)
+		return -ENXIO;
+
+	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
+	devmem->pagemap.res = devmem->resource;
+	devmem->pagemap.page_fault = hmm_devmem_fault;
+	devmem->pagemap.page_free = hmm_devmem_free;
+	devmem->pagemap.dev = devmem->device;
+	devmem->pagemap.ref = &devmem->ref;
+	devmem->pagemap.data = devmem;
+
+	mutex_lock(&hmm_devmem_lock);
+	align_end = align_start + align_size - 1;
+	for (key = align_start; key <= align_end; key += PA_SECTION_SIZE) {
+		struct hmm_devmem *dup;
+
+		rcu_read_lock();
+		dup = hmm_devmem_find(key);
+		rcu_read_unlock();
+		if (dup) {
+			dev_err(device, "%s: collides with mapping for %s\n",
+				__func__, dev_name(dup->device));
+			mutex_unlock(&hmm_devmem_lock);
+			ret = -EBUSY;
+			goto error;
+		}
+		ret = radix_tree_insert(&hmm_devmem_radix,
+					key >> PA_SECTION_SHIFT,
+					devmem);
+		if (ret) {
+			dev_err(device, "%s: failed: %d\n", __func__, ret);
+			mutex_unlock(&hmm_devmem_lock);
+			goto error_radix;
+		}
+	}
+	mutex_unlock(&hmm_devmem_lock);
+
+	nid = dev_to_node(device);
+	if (nid < 0)
+		nid = numa_mem_id();
+
+	mem_hotplug_begin();
+	ret = add_pages(nid, align_start >> PAGE_SHIFT,
+			align_size >> PAGE_SHIFT, false);
+	if (ret) {
+		mem_hotplug_done();
+		goto error_add_memory;
+	}
+	move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
+				align_start >> PAGE_SHIFT,
+				align_size >> PAGE_SHIFT);
+	mem_hotplug_done();
+
+	for (pfn = devmem->pfn_first; pfn < devmem->pfn_last; pfn++) {
+		struct page *page = pfn_to_page(pfn);
+
+		/*
+		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
+		 * pointer.  It is a bug if a ZONE_DEVICE page is ever
+		 * freed or placed on a driver-private list. Therefore,
+		 * seed the storage with LIST_POISON* values.
+		 */
+		list_del(&page->lru);
+		page->pgmap = &devmem->pagemap;
+	}
+	return 0;
+
+error_add_memory:
+	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+error_radix:
+	hmm_devmem_radix_release(devmem->resource);
+error:
+	return ret;
+}
+
+static int hmm_devmem_match(struct device *dev, void *data, void *match_data)
+{
+	struct hmm_devmem *devmem = data;
+
+	return devmem->resource == match_data;
+}
+
+static void hmm_devmem_pages_remove(struct hmm_devmem *devmem)
+{
+	devres_release(devmem->device, &hmm_devmem_release,
+		       &hmm_devmem_match, devmem->resource);
+}
+
+/*
+ * hmm_devmem_add() - hotplug ZONE_DEVICE memory for device memory
+ *
+ * @ops: memory event device driver callback (see struct hmm_devmem_ops)
+ * @device: device struct to bind the resource too
+ * @size: size in bytes of the device memory to add
+ * Returns: pointer to new hmm_devmem struct ERR_PTR otherwise
+ *
+ * This first finds an empty range of physical address big enough to contain the
+ * new resource, and then hotplugs it as ZONE_DEVICE memory, which in turn
+ * allocates struct pages. It does not do anything beyond that; all events
+ * affecting the memory will go through the various callbacks provided by
+ * hmm_devmem_ops struct.
+ */
+struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
+				  struct device *device,
+				  unsigned long size)
+{
+	struct hmm_devmem *devmem;
+	resource_size_t addr;
+	int ret;
+
+	static_branch_enable(&device_private_key);
+
+	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
+				   GFP_KERNEL, dev_to_node(device));
+	if (!devmem)
+		return ERR_PTR(-ENOMEM);
+
+	init_completion(&devmem->completion);
+	devmem->pfn_first = -1UL;
+	devmem->pfn_last = -1UL;
+	devmem->resource = NULL;
+	devmem->device = device;
+	devmem->ops = ops;
+
+	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
+			      0, GFP_KERNEL);
+	if (ret)
+		goto error_percpu_ref;
+
+	ret = devm_add_action(device, hmm_devmem_ref_exit, &devmem->ref);
+	if (ret)
+		goto error_devm_add_action;
+
+	size = ALIGN(size, PA_SECTION_SIZE);
+	addr = min((unsigned long)iomem_resource.end, 1UL << MAX_PHYSMEM_BITS);
+	addr = addr - size + 1UL;
+
+	/*
+	 * FIXME add a new helper to quickly walk resource tree and find free
+	 * range
+	 *
+	 * FIXME what about ioport_resource resource ?
+	 */
+	for (; addr > size && addr >= iomem_resource.start; addr -= size) {
+		ret = region_intersects(addr, size, 0, IORES_DESC_NONE);
+		if (ret != REGION_DISJOINT)
+			continue;
+
+		devmem->resource = devm_request_mem_region(device, addr, size,
+							   dev_name(device));
+		if (!devmem->resource) {
+			ret = -ENOMEM;
+			goto error_no_resource;
+		}
+		break;
+	}
+	if (!devmem->resource) {
+		ret = -ERANGE;
+		goto error_no_resource;
+	}
+
+	devmem->resource->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
+	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
+	devmem->pfn_last = devmem->pfn_first +
+			   (resource_size(devmem->resource) >> PAGE_SHIFT);
+
+	ret = hmm_devmem_pages_create(devmem);
+	if (ret)
+		goto error_pages;
+
+	devres_add(device, devmem);
+
+	ret = devm_add_action(device, hmm_devmem_ref_kill, &devmem->ref);
+	if (ret) {
+		hmm_devmem_remove(devmem);
+		return ERR_PTR(ret);
+	}
+
+	return devmem;
+
+error_pages:
+	devm_release_mem_region(device, devmem->resource->start,
+				resource_size(devmem->resource));
+error_no_resource:
+error_devm_add_action:
+	hmm_devmem_ref_kill(&devmem->ref);
+	hmm_devmem_ref_exit(&devmem->ref);
+error_percpu_ref:
+	devres_free(devmem);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(hmm_devmem_add);
+
+/*
+ * hmm_devmem_remove() - remove device memory (kill and free ZONE_DEVICE)
+ *
+ * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE memory
+ *
+ * This will hot-unplug memory that was hotplugged by hmm_devmem_add on behalf
+ * of the device driver. It will free struct page and remove the resource that
+ * reserved the physical address range for this device memory.
+ */
+void hmm_devmem_remove(struct hmm_devmem *devmem)
+{
+	resource_size_t start, size;
+	struct device *device;
+
+	if (!devmem)
+		return;
+
+	device = devmem->device;
+	start = devmem->resource->start;
+	size = resource_size(devmem->resource);
+
+	hmm_devmem_ref_kill(&devmem->ref);
+	hmm_devmem_ref_exit(&devmem->ref);
+	hmm_devmem_pages_remove(devmem);
+
+	devm_release_mem_region(device, start, size);
+}
+EXPORT_SYMBOL(hmm_devmem_remove);
+
+/*
+ * hmm_devmem_fault_range() - migrate back a virtual range of memory
+ *
+ * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE memory
+ * @vma: virtual memory area containing the range to be migrated
+ * @ops: migration callback for allocating destination memory and copying
+ * @src: array of unsigned long containing source pfns
+ * @dst: array of unsigned long containing destination pfns
+ * @start: start address of the range to migrate (inclusive)
+ * @addr: fault address (must be inside the range)
+ * @end: end address of the range to migrate (exclusive)
+ * @private: pointer passed back to each of the callback
+ * Returns: 0 on success, VM_FAULT_SIGBUS on error
+ *
+ * This is a wrapper around migrate_vma() which checks the migration status
+ * for a given fault address and returns the corresponding page fault handler
+ * status. That will be 0 on success, or VM_FAULT_SIGBUS if migration failed
+ * for the faulting address.
+ *
+ * This is a helper intendend to be used by the ZONE_DEVICE fault handler.
+ */
+int hmm_devmem_fault_range(struct hmm_devmem *devmem,
+			   struct vm_area_struct *vma,
+			   const struct migrate_vma_ops *ops,
+			   unsigned long *src,
+			   unsigned long *dst,
+			   unsigned long start,
+			   unsigned long addr,
+			   unsigned long end,
+			   void *private)
+{
+	if (migrate_vma(ops, vma, start, end, src, dst, private))
+		return VM_FAULT_SIGBUS;
+
+	if (dst[(addr - start) >> PAGE_SHIFT] & MIGRATE_PFN_ERROR)
+		return VM_FAULT_SIGBUS;
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_devmem_fault_range);
+#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
