Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 042656B025E
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:50:53 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id q71so281210366ywg.1
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:50:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n66si46149ybn.37.2017.01.27.13.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 13:50:51 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v17 03/14] mm/ZONE_DEVICE/unaddressable: add support for un-addressable device memory v3
Date: Fri, 27 Jan 2017 17:52:10 -0500
Message-Id: <1485557541-7806-4-git-send-email-jglisse@redhat.com>
In-Reply-To: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

This add support for un-addressable device memory. Such memory is hotpluged
only so we can have struct page but we should never map them as such memory
can not be accessed by CPU. For that reason it uses a special swap entry for
CPU page table entry.

This patch implement all the logic from special swap type to handling CPU
page fault through a callback specified in the ZONE_DEVICE pgmap struct.

Architecture that wish to support un-addressable device memory should make
sure to never populate the kernel linar mapping for the physical range.

This feature potentially breaks memory hotplug unless every driver using it
magically predicts the future addresses of where memory will be hotplugged.

Changed since v2:
  -  Do not change devm_memremap_pages()
Changed since v1:
  - Add unaddressable memory resource descriptor enum
  - Explain why memory hotplug can fail because of un-addressable memory

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/proc/task_mmu.c             | 10 ++++++-
 include/linux/ioport.h         |  1 +
 include/linux/memory_hotplug.h |  7 +++++
 include/linux/memremap.h       | 20 +++++++++++++
 include/linux/swap.h           | 18 ++++++++++--
 include/linux/swapops.h        | 67 ++++++++++++++++++++++++++++++++++++++++++
 kernel/memremap.c              | 23 +++++++++++++--
 mm/Kconfig                     | 12 ++++++++
 mm/memory.c                    | 64 +++++++++++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c            | 10 +++++--
 mm/mprotect.c                  | 12 ++++++++
 11 files changed, 235 insertions(+), 9 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 958f325..9a6ab71 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -535,8 +535,11 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 			} else {
 				mss->swap_pss += (u64)PAGE_SIZE << PSS_SHIFT;
 			}
-		} else if (is_migration_entry(swpent))
+		} else if (is_migration_entry(swpent)) {
 			page = migration_entry_to_page(swpent);
+		} else if (is_device_entry(swpent)) {
+			page = device_entry_to_page(swpent);
+		}
 	} else if (unlikely(IS_ENABLED(CONFIG_SHMEM) && mss->check_shmem_swap
 							&& pte_none(*pte))) {
 		page = find_get_entry(vma->vm_file->f_mapping,
@@ -699,6 +702,8 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 
 		if (is_migration_entry(swpent))
 			page = migration_entry_to_page(swpent);
+		if (is_device_entry(swpent))
+			page = device_entry_to_page(swpent);
 	}
 	if (page) {
 		int mapcount = page_mapcount(page);
@@ -1182,6 +1187,9 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 		flags |= PM_SWAP;
 		if (is_migration_entry(entry))
 			page = migration_entry_to_page(entry);
+
+		if (is_device_entry(entry))
+			page = device_entry_to_page(entry);
 	}
 
 	if (page && !PageAnon(page))
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 6230064..d154a18 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -130,6 +130,7 @@ enum {
 	IORES_DESC_ACPI_NV_STORAGE		= 3,
 	IORES_DESC_PERSISTENT_MEMORY		= 4,
 	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
+	IORES_DESC_UNADDRESSABLE_MEMORY		= 6,
 };
 
 /* helpers to define resources */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 3f50eb8..e7c5dc6 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -285,15 +285,22 @@ extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
  * never relied on struct page migration so far and new user of might also
  * prefer avoiding struct page migration.
  *
+ * For device memory (which use ZONE_DEVICE) we want differentiate between CPU
+ * accessible memory (persitent memory, device memory on an architecture with a
+ * system bus that allow transparent access to device memory) and unaddressable
+ * memory (device memory that can not be accessed by CPU directly).
+ *
  * New non device memory specific flags can be added if ever needed.
  *
  * MEMORY_REGULAR: regular system memory
  * DEVICE_MEMORY: device memory create a ZONE_DEVICE zone for it
  * DEVICE_MEMORY_ALLOW_MIGRATE: page in that device memory ca be migrated
+ * MEMORY_DEVICE_UNADDRESSABLE: un-addressable memory (CPU can not access it)
  */
 #define MEMORY_NORMAL 0
 #define MEMORY_DEVICE (1 << 0)
 #define MEMORY_DEVICE_ALLOW_MIGRATE (1 << 1)
+#define MEMORY_DEVICE_UNADDRESSABLE (1 << 2)
 
 extern int arch_add_memory(int nid, u64 start, u64 size, int flags);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 06fa74b..041d5b9 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -35,24 +35,33 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 }
 #endif
 
+typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
+				unsigned long addr,
+				struct page *page,
+				unsigned flags,
+				pmd_t *pmdp);
 typedef void (*dev_page_free_t)(struct page *page, void *data);
 
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
+ * @page_fault: callback when CPU fault on an un-addressable device page
  * @page_free: free page callback when page refcount reach 1
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @dev: host device of the mapping for debug
  * @data: privata data pointer for page_free
+ * @flags: device memory flags (look for MEMORY_DEVICE_* memory_hotplug.h)
  */
 struct dev_pagemap {
+	dev_page_fault_t page_fault;
 	dev_page_free_t page_free;
 	struct vmem_altmap *altmap;
 	const struct resource *res;
 	struct percpu_ref *ref;
 	struct device *dev;
 	void *data;
+	int flags;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
@@ -65,6 +74,12 @@ static inline bool dev_page_allow_migrate(const struct page *page)
 	return ((page_zonenum(page) == ZONE_DEVICE) &&
 		(page->pgmap->flags & MEMORY_DEVICE_ALLOW_MIGRATE));
 }
+
+static inline bool is_addressable_page(const struct page *page)
+{
+	return ((page_zonenum(page) != ZONE_DEVICE) ||
+		!(page->pgmap->flags & MEMORY_DEVICE_UNADDRESSABLE));
+}
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -88,6 +103,11 @@ static inline bool dev_page_allow_migrate(const struct page *page)
 {
 	return false;
 }
+
+static inline bool is_addressable_page(const struct page *page)
+{
+	return true;
+}
 #endif
 
 /**
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 09b212d..81b44ea 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -50,6 +50,17 @@ static inline int current_is_kswapd(void)
  */
 
 /*
+ * Un-addressable device memory support
+ */
+#ifdef CONFIG_DEVICE_UNADDRESSABLE
+#define SWP_DEVICE_NUM 2
+#define SWP_DEVICE_WRITE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
+#define SWP_DEVICE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM + 1)
+#else
+#define SWP_DEVICE_NUM 0
+#endif
+
+/*
  * NUMA node memory migration support
  */
 #ifdef CONFIG_MIGRATION
@@ -71,7 +82,8 @@ static inline int current_is_kswapd(void)
 #endif
 
 #define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
+	((1 << MAX_SWAPFILES_SHIFT) - SWP_DEVICE_NUM - \
+	SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
 
 /*
  * Magic header for a swap area. The first part of the union is
@@ -410,8 +422,8 @@ static inline void show_swap_cache_info(void)
 {
 }
 
-#define free_swap_and_cache(swp)	is_migration_entry(swp)
-#define swapcache_prepare(swp)		is_migration_entry(swp)
+#define free_swap_and_cache(e) (is_migration_entry(e) || is_device_entry(e))
+#define swapcache_prepare(e) (is_migration_entry(e) || is_device_entry(e))
 
 static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
 {
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 5c3a5f3..0e339f0 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -100,6 +100,73 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
 	return (void *)(value | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
+#if IS_ENABLED(CONFIG_DEVICE_UNADDRESSABLE)
+static inline swp_entry_t make_device_entry(struct page *page, bool write)
+{
+	return swp_entry(write?SWP_DEVICE_WRITE:SWP_DEVICE, page_to_pfn(page));
+}
+
+static inline bool is_device_entry(swp_entry_t entry)
+{
+	int type = swp_type(entry);
+	return type == SWP_DEVICE || type == SWP_DEVICE_WRITE;
+}
+
+static inline void make_device_entry_read(swp_entry_t *entry)
+{
+	*entry = swp_entry(SWP_DEVICE, swp_offset(*entry));
+}
+
+static inline bool is_write_device_entry(swp_entry_t entry)
+{
+	return unlikely(swp_type(entry) == SWP_DEVICE_WRITE);
+}
+
+static inline struct page *device_entry_to_page(swp_entry_t entry)
+{
+	return pfn_to_page(swp_offset(entry));
+}
+
+int device_entry_fault(struct vm_area_struct *vma,
+		       unsigned long addr,
+		       swp_entry_t entry,
+		       unsigned flags,
+		       pmd_t *pmdp);
+#else /* CONFIG_DEVICE_UNADDRESSABLE */
+static inline swp_entry_t make_device_entry(struct page *page, bool write)
+{
+	return swp_entry(0, 0);
+}
+
+static inline void make_device_entry_read(swp_entry_t *entry)
+{
+}
+
+static inline bool is_device_entry(swp_entry_t entry)
+{
+	return false;
+}
+
+static inline bool is_write_device_entry(swp_entry_t entry)
+{
+	return false;
+}
+
+static inline struct page *device_entry_to_page(swp_entry_t entry)
+{
+	return NULL;
+}
+
+static inline int device_entry_fault(struct vm_area_struct *vma,
+				     unsigned long addr,
+				     swp_entry_t entry,
+				     unsigned flags,
+				     pmd_t *pmdp)
+{
+	return VM_FAULT_SIGBUS;
+}
+#endif /* CONFIG_DEVICE_UNADDRESSABLE */
+
 #ifdef CONFIG_MIGRATION
 static inline swp_entry_t make_migration_entry(struct page *page, int write)
 {
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 2f37c92..a7334fa 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -18,6 +18,8 @@
 #include <linux/io.h>
 #include <linux/mm.h>
 #include <linux/memory_hotplug.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 #ifndef ioremap_cache
 /* temporary while we convert existing ioremap_cache users to memremap */
@@ -200,6 +202,21 @@ void put_zone_device_page(struct page *page)
 }
 EXPORT_SYMBOL(put_zone_device_page);
 
+#if IS_ENABLED(CONFIG_DEVICE_UNADDRESSABLE)
+int device_entry_fault(struct vm_area_struct *vma,
+		       unsigned long addr,
+		       swp_entry_t entry,
+		       unsigned flags,
+		       pmd_t *pmdp)
+{
+	struct page *page = device_entry_to_page(entry);
+
+	BUG_ON(!page->pgmap->page_fault);
+	return page->pgmap->page_fault(vma, addr, page, flags, pmdp);
+}
+EXPORT_SYMBOL(device_entry_fault);
+#endif /* CONFIG_DEVICE_UNADDRESSABLE */
+
 static void pgmap_radix_release(struct resource *res)
 {
 	resource_size_t key, align_start, align_size, align_end;
@@ -252,7 +269,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
-	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
+	arch_remove_memory(align_start, align_size, pgmap->flags);
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
@@ -328,6 +345,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	}
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
+	pgmap->flags = MEMORY_DEVICE;
+	pgmap->page_fault = NULL;
 	pgmap->page_free = NULL;
 	pgmap->data = NULL;
 
@@ -366,7 +385,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (error)
 		goto err_pfn_remap;
 
-	error = arch_add_memory(nid, align_start, align_size, MEMORY_DEVICE);
+	error = arch_add_memory(nid, align_start, align_size, pgmap->flags);
 	if (error)
 		goto err_add_memory;
 
diff --git a/mm/Kconfig b/mm/Kconfig
index e9b7c7e..0c33f46 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -700,6 +700,18 @@ config ZONE_DEVICE
 
 	  If FS_DAX is enabled, then say Y.
 
+config DEVICE_UNADDRESSABLE
+	bool "Un-addressable device memory (GPU memory, ...)"
+	depends on ZONE_DEVICE
+
+	help
+	  Allow to create struct page for un-addressable device memory
+	  ie memory that is only accessible by the device (or group of
+	  devices).
+
+	  Having struct page is necessary for process memory migration
+	  to device memory.
+
 config FRAME_VECTOR
 	bool
 
diff --git a/mm/memory.c b/mm/memory.c
index e870322..69bede9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -45,6 +45,7 @@
 #include <linux/swap.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/memremap.h>
 #include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/export.h>
@@ -890,6 +891,25 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 					pte = pte_swp_mksoft_dirty(pte);
 				set_pte_at(src_mm, addr, src_pte, pte);
 			}
+		} else if (is_device_entry(entry)) {
+			page = device_entry_to_page(entry);
+
+			/*
+			 * Update rss count even for un-addressable page as
+			 * they should be consider just like any other page.
+			 */
+			get_page(page);
+			rss[mm_counter(page)]++;
+			page_dup_rmap(page, false);
+
+			if (is_write_device_entry(entry) &&
+			    is_cow_mapping(vm_flags)) {
+				make_device_entry_read(&entry);
+				pte = swp_entry_to_pte(entry);
+				if (pte_swp_soft_dirty(*src_pte))
+					pte = pte_swp_mksoft_dirty(pte);
+				set_pte_at(src_mm, addr, src_pte, pte);
+			}
 		}
 		goto out_set_pte;
 	}
@@ -1179,6 +1199,32 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			}
 			continue;
 		}
+
+		/*
+		 * Un-addressable page must always be check that are not like
+		 * other swap entries and thus should be check no matter what
+		 * details->check_swap_entries value is.
+		 */
+		entry = pte_to_swp_entry(ptent);
+		if (non_swap_entry(entry) && is_device_entry(entry)) {
+			struct page *page = device_entry_to_page(entry);
+
+			if (unlikely(details)) {
+				/*
+				 * unmap_shared_mapping_pages() wants to
+				 * invalidate cache without truncating:
+				 * unmap shared but keep private pages.
+				 */
+				if (details->check_mapping &&
+				    details->check_mapping != page_rmapping(page))
+					continue;
+			}
+
+			rss[mm_counter(page)]--;
+			page_remove_rmap(page, false);
+			put_page(page);
+		}
+
 		/* only check swap_entries if explicitly asked for in details */
 		if (unlikely(details && !details->check_swap_entries))
 			continue;
@@ -2550,6 +2596,14 @@ int do_swap_page(struct vm_fault *vmf)
 		if (is_migration_entry(entry)) {
 			migration_entry_wait(vma->vm_mm, vmf->pmd,
 					     vmf->address);
+		} else if (is_device_entry(entry)) {
+			/*
+			 * For un-addressable device memory we call the pgmap
+			 * fault handler callback. The callback must migrate
+			 * the page back to some CPU accessible page.
+			 */
+			ret = device_entry_fault(vma, vmf->address, entry,
+						 vmf->flags, vmf->pmd);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
@@ -3518,6 +3572,7 @@ static inline bool vma_is_accessible(struct vm_area_struct *vma)
 static int handle_pte_fault(struct vm_fault *vmf)
 {
 	pte_t entry;
+	struct page *page;
 
 	if (unlikely(pmd_none(*vmf->pmd))) {
 		/*
@@ -3568,9 +3623,16 @@ static int handle_pte_fault(struct vm_fault *vmf)
 	if (pte_protnone(vmf->orig_pte) && vma_is_accessible(vmf->vma))
 		return do_numa_page(vmf);
 
+	/* Catch mapping of un-addressable memory this should never happen */
+	entry = vmf->orig_pte;
+	page = pfn_to_page(pte_pfn(entry));
+	if (!is_addressable_page(page)) {
+		print_bad_pte(vmf->vma, vmf->address, entry, page);
+		return VM_FAULT_SIGBUS;
+	}
+
 	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
 	spin_lock(vmf->ptl);
-	entry = vmf->orig_pte;
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
 	if (vmf->flags & FAULT_FLAG_WRITE) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 096c651..76f5359 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -149,7 +149,7 @@ void mem_hotplug_done(void)
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
-	struct resource *res;
+	struct resource *res, *conflict;
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 	if (!res)
 		return ERR_PTR(-ENOMEM);
@@ -158,7 +158,13 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 	res->start = start;
 	res->end = start + size - 1;
 	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
-	if (request_resource(&iomem_resource, res) < 0) {
+	conflict =  request_resource_conflict(&iomem_resource, res);
+	if (conflict) {
+		if (conflict->desc == IORES_DESC_UNADDRESSABLE_MEMORY) {
+			pr_debug("Device un-addressable memory block "
+				 "memory hotplug at %#010llx !\n",
+				 (unsigned long long)start);
+		}
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
 		return ERR_PTR(-EEXIST);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index cc2459c..fc3dd08 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -140,6 +140,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				pages++;
 			}
+
+			if (is_write_device_entry(entry)) {
+				pte_t newpte;
+
+				make_device_entry_read(&entry);
+				newpte = swp_entry_to_pte(entry);
+				if (pte_swp_soft_dirty(oldpte))
+					newpte = pte_swp_mksoft_dirty(newpte);
+				set_pte_at(mm, addr, pte, newpte);
+
+				pages++;
+			}
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
