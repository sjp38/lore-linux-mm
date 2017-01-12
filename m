Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 907AD6B0271
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:29:46 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id t84so19511568qke.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:29:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f4si6317015qke.87.2017.01.12.07.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 07:29:45 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v16 14/15] mm/hmm/devmem: device driver helper to hotplug ZONE_DEVICE memory v2
Date: Thu, 12 Jan 2017 11:30:41 -0500
Message-Id: <1484238642-10674-15-git-send-email-jglisse@redhat.com>
In-Reply-To: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
References: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This introduce a simple struct and associated helpers for device driver
to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
will find a unuse physical address range and trigger memory hotplug for
it which allocates and initialize struct page for the device memory.

Changed since v1:
  - s/devm_memremap_pages_remove/devm_memunmap
  - fixup percpu ref cleanup

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h | 116 ++++++++++++++++++++++++
 mm/Kconfig          |   7 ++
 mm/hmm.c            | 253 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 376 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b1de4e1..674aa79 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -76,6 +76,10 @@
 
 #if IS_ENABLED(CONFIG_HMM)
 
+#include <linux/memremap.h>
+#include <linux/completion.h>
+
+
 struct hmm;
 
 /*
@@ -377,6 +381,118 @@ int hmm_vma_migrate(const struct hmm_migrate_ops *ops,
 #endif /* IS_ENABLED(CONFIG_HMM_MIGRATE) */
 
 
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
+		     unsigned flags,
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
+ * @inuse: is struct in use
+ *
+ * This an helper structure for device driver that do not wish to implement
+ * to gory details related to hotpluging new memoy and in allocating struct
+ * pages.
+ *
+ * Device driver can directly use ZONE_DEVICE memory on their own if they
+ * wish to do so.
+ */
+struct hmm_devmem {
+	struct completion		completion;
+	unsigned long			pfn_first;
+	unsigned long			pfn_last;
+	struct resource			*resource;
+	struct dev_pagemap		*pagemap;
+	struct device			*device;
+	const struct hmm_devmem_ops	*ops;
+	struct percpu_ref		ref;
+	bool				inuse;
+};
+
+/*
+ * To add (hotplug) device memory, it assumes that there is no real resource
+ * that reserve a range in the physical address space (this is intended to be
+ * use by un-addressable device memory). It will reserve a physical range big
+ * enough and allocate struct page for it.
+ *
+ * Device driver can wrap the hmm_devmem struct inside a private device driver
+ * struct. Device driver must call hmm_devmem_remove() before device goes away
+ * and before freeing the hmm_devmem struct memory.
+ */
+int hmm_devmem_add(struct hmm_devmem *devmem,
+		   const struct hmm_devmem_ops *ops,
+		   struct device *device,
+		   unsigned long size);
+bool hmm_devmem_remove(struct hmm_devmem *devmem);
+
+int hmm_devmem_fault_range(struct hmm_devmem *devmem,
+			   struct vm_area_struct *vma,
+			   const struct hmm_migrate_ops *ops,
+			   hmm_pfn_t *src_pfns,
+			   hmm_pfn_t *dst_pfns,
+			   unsigned long start,
+			   unsigned long addr,
+			   unsigned long end,
+			   void *private);
+
+/*
+ * hmm_devmem_page_set_drvdata - set per page driver data field
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
 /* Below are for HMM internal use only ! Not to be used by device driver ! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 3806d69..0d9cdcf 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -321,6 +321,13 @@ config HMM_MIGRATE
 	  migration of ZONE_DEVICE page that have MEMOY_DEVICE_ALLOW_MIGRATE
 	  flag set.
 
+config HMM_DEVMEM
+	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
+	select HMM
+	help
+	  HMM devmem are helpers to leverage new ZONE_DEVICE feature. This is
+	  just to avoid device driver to replicate boiler plate code.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
diff --git a/mm/hmm.c b/mm/hmm.c
index a397d45..a34e54e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -23,10 +23,15 @@
 #include <linux/swap.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/mmzone.h>
+#include <linux/pagemap.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
+#include <linux/memremap.h>
 #include <linux/mmu_notifier.h>
 
+#define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
+
 
 /*
  * struct hmm - HMM per mm struct
@@ -735,3 +740,251 @@ int hmm_vma_fault(struct vm_area_struct *vma,
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
+static void hmm_devmem_release(struct percpu_ref *ref)
+{
+	struct hmm_devmem *devmem;
+
+	devmem = container_of(ref, struct hmm_devmem, ref);
+	complete(&devmem->completion);
+	devmem->inuse = false;
+}
+
+static void hmm_devmem_exit(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct hmm_devmem *devmem;
+
+	devmem = container_of(ref, struct hmm_devmem, ref);
+	percpu_ref_exit(ref);
+	devm_remove_action(devmem->device, hmm_devmem_exit, data);
+}
+
+static void hmm_devmem_kill(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct hmm_devmem *devmem;
+
+	devmem = container_of(ref, struct hmm_devmem, ref);
+	devmem->inuse = false;
+	percpu_ref_kill(ref);
+	wait_for_completion(&devmem->completion);
+	devm_remove_action(devmem->device, hmm_devmem_kill, data);
+}
+
+static int hmm_devmem_fault(struct vm_area_struct *vma,
+			    unsigned long addr,
+			    struct page *page,
+			    unsigned flags,
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
+/*
+ * hmm_devmem_add() - hotplug fake ZONE_DEVICE memory for device memory
+ *
+ * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE memory
+ * @ops: memory event device driver callback (see struct hmm_devmem_ops)
+ * @device: device struct to bind the resource too
+ * @size: size in bytes of the device memory to add
+ * Returns: 0 on success, error code otherwise
+ *
+ * This first find an empty range of physical address big enough to for the new
+ * resource and then hotplug it as ZONE_DEVICE memory allocating struct page.
+ * It does not do anything beside that, all events affecting the memory will go
+ * through the various callback provided by hmm_devmem_ops struct.
+ */
+int hmm_devmem_add(struct hmm_devmem *devmem,
+		   const struct hmm_devmem_ops *ops,
+		   struct device *device,
+		   unsigned long size)
+{
+	const struct resource *res;
+	resource_size_t addr;
+	void *ptr;
+	int ret;
+
+	init_completion(&devmem->completion);
+	devmem->pfn_first = -1UL;
+	devmem->pfn_last = -1UL;
+	devmem->resource = NULL;
+	devmem->device = device;
+	devmem->pagemap = NULL;
+	devmem->inuse = false;
+	devmem->ops = ops;
+
+	ret = percpu_ref_init(&devmem->ref,&hmm_devmem_release,0,GFP_KERNEL);
+	if (ret)
+		return ret;
+
+	ret = devm_add_action(device, hmm_devmem_exit, &devmem->ref);
+	if (ret)
+		goto error;
+
+	size = ALIGN(size, SECTION_SIZE);
+	addr = (1UL << MAX_PHYSMEM_BITS) - size;
+
+	/*
+	 * FIXME add a new helper to quickly walk resource tree and find free
+	 * range
+	 *
+	 * FIXME what about ioport_resource resource ?
+	 */
+	for (; addr > size; addr -= size) {
+		ret = region_intersects(addr, size, 0, IORES_DESC_NONE);
+		if (ret != REGION_DISJOINT)
+			continue;
+
+		devmem->resource = devm_request_mem_region(device, addr, size,
+							   dev_name(device));
+		if (!devmem->resource) {
+			ret = -ENOMEM;
+			goto error;
+		}
+		devmem->resource->desc = IORES_DESC_UNADDRESSABLE_MEMORY;
+		break;
+	}
+	if (!devmem->resource) {
+		ret = -ERANGE;
+		goto error;
+	}
+
+	ptr = devm_memremap_pages(device, devmem->resource, &devmem->ref,
+				  NULL, &devmem->pagemap,
+				  hmm_devmem_fault, hmm_devmem_free, devmem,
+				  MEMORY_DEVICE | MEMORY_DEVICE_ALLOW_MIGRATE |
+				  MEMORY_DEVICE_UNADDRESSABLE);
+	if (IS_ERR(ptr)) {
+		ret = PTR_ERR(ptr);
+		goto error;
+	}
+
+	ret = devm_add_action(device, hmm_devmem_kill, &devmem->ref);
+	if (ret) {
+		hmm_devmem_kill(&devmem->ref);
+		goto error;
+	}
+
+	res = devmem->pagemap->res;
+	devmem->pfn_first = res->start >> PAGE_SHIFT;
+	devmem->pfn_last = (resource_size(res)>>PAGE_SHIFT)+devmem->pfn_first;
+	devmem->inuse = true;
+
+	return 0;
+
+error:
+	hmm_devmem_exit(&devmem->ref);
+	return ret;
+}
+EXPORT_SYMBOL(hmm_devmem_add);
+
+/*
+ * hmm_devmem_remove() - remove device memory (kill and free ZONE_DEVICE)
+ *
+ * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE memory
+ * Returns: true if device memory is no longer in use, false if still in use
+ *
+ * This will hot remove memory that was hotplug by hmm_devmem_add on behalf of
+ * device driver. It will free struct page and remove the resource that reserve
+ * the physical address range for this device memory.
+ *
+ * Device driver can not free the struct while this function return false, it
+ * must call over and over this function until it returns true. Note that if
+ * there is a refcount bug this might never happen !
+ */
+bool hmm_devmem_remove(struct hmm_devmem *devmem)
+{
+	struct device *device = devmem->device;
+
+	hmm_devmem_kill(&devmem->ref);
+
+	if (devmem->pagemap) {
+		const struct resource *res = devmem->pagemap->res;
+
+		devm_memunmap_pages(device, __va(res->start));
+		devmem->pagemap = NULL;
+	}
+
+	hmm_devmem_exit(&devmem->ref);
+
+	/* FIXME maybe wait a bit ? */
+	if (devmem->inuse)
+		return false;
+
+	if (devmem->resource) {
+		resource_size_t size = resource_size(devmem->resource);
+
+		devm_release_mem_region(device, devmem->resource->start, size);
+		devmem->resource = NULL;
+	}
+
+	return true;
+}
+EXPORT_SYMBOL(hmm_devmem_remove);
+
+/*
+ * hmm_devmem_fault_range() - migrate back a virtual range of memory
+ *
+ * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE memory
+ * @vma: virtual memory area containing the range to be migrated
+ * @ops: migration callback for allocating destination memory and copying
+ * @src_pfns: array of hmm_pfn_t containing source pfns
+ * @dst_pfns: array of hmm_pfn_t containing destination pfns
+ * @start: start address of the range to migrate (inclusive)
+ * @addr: fault address (must be inside the range)
+ * @end: end address of the range to migrate (exclusive)
+ * @private: pointer passed back to each of the callback
+ * Returns: 0 on success, VM_FAULT_SIGBUS on error
+ *
+ * This is a wrapper around hmm_vma_migrate() which check the migration status
+ * for a given fault address and return corresponding page fault handler status
+ * ie 0 on success or VM_FAULT_SIGBUS if migration failed for fault address.
+ *
+ * This is an helper intendend to be use by ZONE_DEVICE fault handler.
+ */
+int hmm_devmem_fault_range(struct hmm_devmem *devmem,
+			   struct vm_area_struct *vma,
+			   const struct hmm_migrate_ops *ops,
+			   hmm_pfn_t *src_pfns,
+			   hmm_pfn_t *dst_pfns,
+			   unsigned long start,
+			   unsigned long addr,
+			   unsigned long end,
+			   void *private)
+{
+	if (hmm_vma_migrate(ops, vma, src_pfns, dst_pfns, start, end, private))
+		return VM_FAULT_SIGBUS;
+
+	if (dst_pfns[(addr - start) >> PAGE_SHIFT] & HMM_PFN_ERROR)
+		return VM_FAULT_SIGBUS;
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_devmem_fault_range);
+#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
