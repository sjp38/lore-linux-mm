Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40C126B039F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 16:29:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n80so24041144qke.6
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 13:29:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q10si5879889qtq.77.2017.04.07.13.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 13:29:11 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC HMM CDM 1/3] mm/cache-coherent-device-memory: new type of ZONE_DEVICE
Date: Fri,  7 Apr 2017 16:28:51 -0400
Message-Id: <1491596933-21669-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
References: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <balbir@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Platform with advance system bus (like CAPI or CCIX) allow device
memory to be accessible from CPU in a cache coherent fashion. Add
a new type of ZONE_DEVICE to represent such memory. The use case
are the same as for the un-addressable device memory but without
all the corners cases.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/ioport.h         |  1 +
 include/linux/memory_hotplug.h |  8 ++++++++
 include/linux/memremap.h       | 26 ++++++++++++++++++++++++++
 mm/Kconfig                     |  9 +++++++++
 mm/gup.c                       |  1 +
 mm/memcontrol.c                | 25 +++++++++++++++++++++++--
 mm/memory.c                    | 18 ++++++++++++++++++
 mm/migrate.c                   | 12 +++++++++++-
 8 files changed, 97 insertions(+), 3 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index ec619dc..55cba87 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -131,6 +131,7 @@ enum {
 	IORES_DESC_PERSISTENT_MEMORY		= 4,
 	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
 	IORES_DESC_DEVICE_MEMORY_UNADDRESSABLE	= 6,
+	IORES_DESC_DEVICE_MEMORY_CACHE_COHERENT	= 7,
 };
 
 /* helpers to define resources */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e60f203..7c587ce 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -36,11 +36,19 @@ struct resource;
  * page must be treated as an opaque object, rather than a "normal" struct page.
  * A more complete discussion of unaddressable memory may be found in
  * include/linux/hmm.h and Documentation/vm/hmm.txt.
+ *
+ * MEMORY_DEVICE_CACHE_COHERENT:
+ * Device memory that is cache coherent from device and CPU point of view. This
+ * is use on platform that have an advance system bus (like CAPI or CCIX). A
+ * driver can hotplug the device memory using ZONE_DEVICE and with that memory
+ * type. Any page of a process can be migrated to such memory. However no one
+ * should be allow to pin such memory so that it can always be evicted.
  */
 enum memory_type {
 	MEMORY_NORMAL = 0,
 	MEMORY_DEVICE_PERSISTENT,
 	MEMORY_DEVICE_UNADDRESSABLE,
+	MEMORY_DEVICE_CACHE_COHERENT,
 };
 
 #ifdef CONFIG_MEMORY_HOTPLUG
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 3a9494e..6029ddf 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -41,6 +41,8 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  *   page_fault()
  *   page_free()
  *
+ * For MEMORY_DEVICE_CACHE_COHERENT only the page_free() callback matter.
+ *
  * Additional notes about MEMORY_DEVICE_UNADDRESSABLE may be found in
  * include/linux/hmm.h and Documentation/vm/hmm.txt. There is also a brief
  * explanation in include/linux/memory_hotplug.h.
@@ -99,12 +101,26 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 
+static inline bool is_device_persistent_page(const struct page *page)
+{
+	/* See MEMORY_DEVICE_UNADDRESSABLE in include/linux/memory_hotplug.h */
+	return ((page_zonenum(page) == ZONE_DEVICE) &&
+		(page->pgmap->type == MEMORY_DEVICE_PERSISTENT));
+}
+
 static inline bool is_device_unaddressable_page(const struct page *page)
 {
 	/* See MEMORY_DEVICE_UNADDRESSABLE in include/linux/memory_hotplug.h */
 	return ((page_zonenum(page) == ZONE_DEVICE) &&
 		(page->pgmap->type == MEMORY_DEVICE_UNADDRESSABLE));
 }
+
+static inline bool is_device_cache_coherent_page(const struct page *page)
+{
+	/* See MEMORY_DEVICE_UNADDRESSABLE in include/linux/memory_hotplug.h */
+	return ((page_zonenum(page) == ZONE_DEVICE) &&
+		(page->pgmap->type == MEMORY_DEVICE_CACHE_COHERENT));
+}
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -124,10 +140,20 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 	return NULL;
 }
 
+static inline bool is_device_persistent_page(const struct page *page)
+{
+	return false;
+}
+
 static inline bool is_device_unaddressable_page(const struct page *page)
 {
 	return false;
 }
+
+static inline bool is_device_cache_coherent_page(const struct page *page)
+{
+	return false;
+}
 #endif
 
 /**
diff --git a/mm/Kconfig b/mm/Kconfig
index 96dcf61..5c7b0ec 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -744,6 +744,15 @@ config DEVICE_UNADDRESSABLE
 	  i.e., memory that is only accessible from the device (or group of
 	  devices).
 
+config DEVICE_CACHE_COHERENT
+	bool "Cache coherent device memory (GPU memory, ...)"
+	depends on ZONE_DEVICE
+
+	help
+	  Allow to create struct page for cache-coherent device memory
+	  which is only do-able with advance system bus like CAPI or
+	  CCIX.
+
 config FRAME_VECTOR
 	bool
 
diff --git a/mm/gup.c b/mm/gup.c
index 4039ec2..4d54220 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -121,6 +121,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 			page = pte_page(pte);
 		else
 			goto no_page;
+		pgmap = get_dev_pagemap(pte_pfn(pte), NULL);
 	} else if (unlikely(!page)) {
 		if (flags & FOLL_DUMP) {
 			/* Avoid special (like zero) pages in core dumps */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 712a687..fd188cf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4388,6 +4388,7 @@ enum mc_target_type {
 	MC_TARGET_NONE = 0,
 	MC_TARGET_PAGE,
 	MC_TARGET_SWAP,
+	MC_TARGET_DEVICE,
 };
 
 static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
@@ -4395,8 +4396,22 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
 {
 	struct page *page = vm_normal_page(vma, addr, ptent);
 
-	if (!page || !page_mapped(page))
+	if (!page || !page_mapped(page)) {
+		if (pte_devmap(pte)) {
+			struct dev_pagemap *pgmap = NULL;
+
+			page = pte_page(ptent);
+			if (!is_device_cache_coherent_page(page))
+				return NULL;
+
+			pgmap = get_dev_pagemap(pte_pfn(pte), NULL);
+			if (pgmap) {
+				get_page(page);
+				return page;
+			}
+		}
 		return NULL;
+	}
 	if (PageAnon(page)) {
 		if (!(mc.flags & MOVE_ANON))
 			return NULL;
@@ -4611,6 +4626,8 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		 */
 		if (page->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
+			if (is_device_cache_coherent_page(page))
+				ret = MC_TARGET_DEVICE;
 			if (target)
 				target->page = page;
 		}
@@ -4896,12 +4913,16 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);
+		bool device = false;
 		swp_entry_t ent;
 
 		if (!mc.precharge)
 			break;
 
 		switch (get_mctgt_type(vma, addr, ptent, &target)) {
+		case MC_TARGET_DEVICE:
+			device = true;
+			/* fall through */
 		case MC_TARGET_PAGE:
 			page = target.page;
 			/*
@@ -4912,7 +4933,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			 */
 			if (PageTransCompound(page))
 				goto put;
-			if (isolate_lru_page(page))
+			if (!device && isolate_lru_page(page))
 				goto put;
 			if (!mem_cgroup_move_account(page, false,
 						mc.from, mc.to)) {
diff --git a/mm/memory.c b/mm/memory.c
index d68c653..bf41258 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -979,6 +979,24 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		get_page(page);
 		page_dup_rmap(page, false);
 		rss[mm_counter(page)]++;
+	} else if (pte_devmap(pte)) {
+		struct dev_pagemap *pgmap = NULL;
+
+		page = pte_page(pte);
+
+		/*
+		 * Cache coherent device memory behave like regular page and
+		 * not like persistent memory page. For more informations see
+		 * MEMORY_DEVICE_CACHE_COHERENT in memory_hotplug.h
+		 */
+		if (is_device_cache_coherent_page(page)) {
+			pgmap = get_dev_pagemap(pte_pfn(pte), NULL);
+			if (pgmap) {
+				get_page(page);
+				page_dup_rmap(page, false);
+				rss[mm_counter(page)]++;
+			}
+		}
 	}
 
 out_set_pte:
diff --git a/mm/migrate.c b/mm/migrate.c
index cbaa4f2..2497357 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -241,6 +241,9 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 			pte = swp_entry_to_pte(entry);
 			if (pte_swp_soft_dirty(*pvmw.pte))
 				pte = pte_mksoft_dirty(pte);
+		} else if (is_device_cache_coherent_page(new)) {
+			pte = pte_mkdevmap(pte);
+			flush_dcache_page(new);
 		} else
 			flush_dcache_page(new);
 		set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
@@ -2300,7 +2303,8 @@ static bool migrate_vma_check_page(struct page *page)
 
 	/* Page from ZONE_DEVICE have one extra reference */
 	if (is_zone_device_page(page)) {
-		if (is_device_unaddressable_page(page)) {
+		if (is_device_unaddressable_page(page) ||
+		    is_device_cache_coherent_page(page)) {
 			extra++;
 		} else
 			/* Other ZONE_DEVICE memory type are not supported */
@@ -2617,6 +2621,12 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 					migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 					continue;
 				}
+			} else if (is_device_cache_coherent_page(newpage)) {
+				/*
+				 * Anything can be migrated to a device cache
+				 * coherent page.
+				 */
+				continue;
 			} else {
 				/*
 				 * Other types of ZONE_DEVICE page are not
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
