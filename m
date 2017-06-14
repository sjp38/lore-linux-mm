Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C23B26B02F3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 16:12:01 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n40so6988821qtb.4
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:12:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si882236qtb.260.2017.06.14.13.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 13:12:00 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-CDM 1/5] mm/device-public-memory: device memory cache coherent with CPU
Date: Wed, 14 Jun 2017 16:11:40 -0400
Message-Id: <20170614201144.9306-2-jglisse@redhat.com>
In-Reply-To: <20170614201144.9306-1-jglisse@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Platform with advance system bus (like CAPI or CCIX) allow device
memory to be accessible from CPU in a cache coherent fashion. Add
a new type of ZONE_DEVICE to represent such memory. The use case
are the same as for the un-addressable device memory but without
all the corners cases.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Balbir Singh <balbirs@au1.ibm.com>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/proc/task_mmu.c       |  2 +-
 include/linux/ioport.h   |  1 +
 include/linux/memremap.h | 21 +++++++++++++++++
 include/linux/mm.h       | 16 ++++++++-----
 kernel/memremap.c        | 11 ++++++---
 mm/Kconfig               | 13 +++++++++++
 mm/gup.c                 |  7 ++++++
 mm/madvise.c             |  2 +-
 mm/memory.c              | 46 +++++++++++++++++++++++++++++++++----
 mm/migrate.c             | 60 ++++++++++++++++++++++++++++++++----------------
 mm/swap.c                | 11 +++++++++
 11 files changed, 154 insertions(+), 36 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 90b2fa4..78b1eca 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1187,7 +1187,7 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 		if (pm->show_pfn)
 			frame = pte_pfn(pte);
 		flags |= PM_PRESENT;
-		page = vm_normal_page(vma, addr, pte);
+		page = _vm_normal_page(vma, addr, pte, true);
 		if (pte_soft_dirty(pte))
 			flags |= PM_SOFT_DIRTY;
 	} else if (is_swap_pte(pte)) {
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 3a4f691..f5cf32e 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -131,6 +131,7 @@ enum {
 	IORES_DESC_PERSISTENT_MEMORY		= 4,
 	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
 	IORES_DESC_DEVICE_PRIVATE_MEMORY	= 6,
+	IORES_DESC_DEVICE_PUBLIC_MEMORY		= 7,
 };
 
 /* helpers to define resources */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index d6909ea..c8506d3 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -56,10 +56,18 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * page must be treated as an opaque object, rather than a "normal" struct page.
  * A more complete discussion of unaddressable memory may be found in
  * include/linux/hmm.h and Documentation/vm/hmm.txt.
+ *
+ * MEMORY_DEVICE_PUBLIC:
+ * Device memory that is cache coherent from device and CPU point of view. This
+ * is use on platform that have an advance system bus (like CAPI or CCIX). A
+ * driver can hotplug the device memory using ZONE_DEVICE and with that memory
+ * type. Any page of a process can be migrated to such memory. However no one
+ * should be allow to pin such memory so that it can always be evicted.
  */
 enum memory_type {
 	MEMORY_DEVICE_PERSISTENT = 0,
 	MEMORY_DEVICE_PRIVATE,
+	MEMORY_DEVICE_PUBLIC,
 };
 
 /*
@@ -91,6 +99,8 @@ enum memory_type {
  * The page_free() callback is called once the page refcount reaches 1
  * (ZONE_DEVICE pages never reach 0 refcount unless there is a refcount bug.
  * This allows the device driver to implement its own memory management.)
+ *
+ * For MEMORY_DEVICE_CACHE_COHERENT only the page_free() callback matter.
  */
 typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
 				unsigned long addr,
@@ -133,6 +143,12 @@ static inline bool is_device_private_page(const struct page *page)
 	return is_zone_device_page(page) &&
 		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
 }
+
+static inline bool is_device_public_page(const struct page *page)
+{
+	return is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
+}
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -156,6 +172,11 @@ static inline bool is_device_private_page(const struct page *page)
 {
 	return false;
 }
+
+static inline bool is_device_public_page(const struct page *page)
+{
+	return false;
+}
 #endif
 
 /**
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e74a183..d267482 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -797,14 +797,15 @@ static inline bool is_zone_device_page(const struct page *page)
 #endif
 
 #ifdef CONFIG_DEVICE_PRIVATE
-void put_zone_device_private_page(struct page *page);
+void put_zone_device_private_or_public_page(struct page *page);
 #else
-static inline void put_zone_device_private_page(struct page *page)
+static inline void put_zone_device_private_or_public_page(struct page *page)
 {
 }
 #endif
 
 static inline bool is_device_private_page(const struct page *page);
+static inline bool is_device_public_page(const struct page *page);
 
 DECLARE_STATIC_KEY_FALSE(device_private_key);
 
@@ -830,8 +831,9 @@ static inline void put_page(struct page *page)
 	 * include/linux/memremap.h and HMM for details.
 	 */
 	if (static_branch_unlikely(&device_private_key) &&
-	    unlikely(is_device_private_page(page))) {
-		put_zone_device_private_page(page);
+	    unlikely(is_device_private_page(page) ||
+		     is_device_public_page(page))) {
+		put_zone_device_private_or_public_page(page);
 		return;
 	}
 
@@ -1220,8 +1222,10 @@ struct zap_details {
 	pgoff_t last_index;			/* Highest page->index to unmap */
 };
 
-struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-		pte_t pte);
+struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			     pte_t pte, bool with_public_device);
+#define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
+
 struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 				pmd_t pmd);
 
diff --git a/kernel/memremap.c b/kernel/memremap.c
index e82456c..da74775 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -466,7 +466,7 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 
 
 #ifdef CONFIG_DEVICE_PRIVATE
-void put_zone_device_private_page(struct page *page)
+void put_zone_device_private_or_public_page(struct page *page)
 {
 	int count = page_ref_dec_return(page);
 
@@ -474,10 +474,15 @@ void put_zone_device_private_page(struct page *page)
 	 * If refcount is 1 then page is freed and refcount is stable as nobody
 	 * holds a reference on the page.
 	 */
-	if (count == 1)
+	if (count == 1) {
+		/* Clear Active bit in case of parallel mark_page_accessed */
+		__ClearPageActive(page);
+		__ClearPageWaiters(page);
+
 		page->pgmap->page_free(page, page->pgmap->data);
+	}
 	else if (!count)
 		__put_page(page);
 }
-EXPORT_SYMBOL(put_zone_device_private_page);
+EXPORT_SYMBOL(put_zone_device_private_or_public_page);
 #endif /* CONFIG_DEVICE_PRIVATE */
diff --git a/mm/Kconfig b/mm/Kconfig
index dd11b4d..ad082b9 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -731,6 +731,19 @@ config DEVICE_PRIVATE
 	  memory; i.e., memory that is only accessible from the device (or
 	  group of devices).
 
+config DEVICE_PUBLIC
+	bool "Unaddressable device memory (GPU memory, ...)"
+	depends on X86_64
+	depends on ZONE_DEVICE
+	depends on MEMORY_HOTPLUG
+	depends on MEMORY_HOTREMOVE
+	depends on SPARSEMEM_VMEMMAP
+
+	help
+	  Allows creation of struct pages to represent addressable device
+	  memory; i.e., memory that is accessible from both the device and
+	  the CPU
+
 config FRAME_VECTOR
 	bool
 
diff --git a/mm/gup.c b/mm/gup.c
index b73e426..d771850 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -438,6 +438,13 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		if ((gup_flags & FOLL_DUMP) || !is_zero_pfn(pte_pfn(*pte)))
 			goto unmap;
 		*page = pte_page(*pte);
+
+		/*
+		 * This should never happen (a device public page in the gate
+		 * area).
+		 */
+		if (is_device_public_page(*page))
+			goto unmap;
 	}
 	get_page(*page);
 out:
diff --git a/mm/madvise.c b/mm/madvise.c
index 8eda184..e66ef0a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -343,7 +343,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			continue;
 		}
 
-		page = vm_normal_page(vma, addr, ptent);
+		page = _vm_normal_page(vma, addr, ptent, true);
 		if (!page)
 			continue;
 
diff --git a/mm/memory.c b/mm/memory.c
index 471ed99..e7f0a4b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -789,8 +789,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 #else
 # define HAVE_PTE_SPECIAL 0
 #endif
-struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-				pte_t pte)
+struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			     pte_t pte, bool with_public_device)
 {
 	unsigned long pfn = pte_pfn(pte);
 
@@ -801,8 +801,31 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			return vma->vm_ops->find_special_page(vma, addr);
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
-		if (!is_zero_pfn(pfn))
-			print_bad_pte(vma, addr, pte, NULL);
+		if (is_zero_pfn(pfn))
+			return NULL;
+
+		/*
+		 * Device public pages are special pages (they are ZONE_DEVICE
+		 * pages but different from persistent memory). They behave
+		 * allmost like normal pages. The difference is that they are
+		 * not on the lru and thus should never be involve with any-
+		 * thing that involve lru manipulation (mlock, numa balancing,
+		 * ...).
+		 *
+		 * This is why we still want to return NULL for such page from
+		 * vm_normal_page() so that we do not have to special case all
+		 * call site of vm_normal_page().
+		 */
+		if (likely(pfn < highest_memmap_pfn)) {
+			struct page *page = pfn_to_page(pfn);
+
+			if (is_device_public_page(page)) {
+				if (with_public_device)
+					return page;
+				return NULL;
+			}
+		}
+		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
 
@@ -983,6 +1006,19 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		get_page(page);
 		page_dup_rmap(page, false);
 		rss[mm_counter(page)]++;
+	} else if (pte_devmap(pte)) {
+		page = pte_page(pte);
+
+		/*
+		 * Cache coherent device memory behave like regular page and
+		 * not like persistent memory page. For more informations see
+		 * MEMORY_DEVICE_CACHE_COHERENT in memory_hotplug.h
+		 */
+		if (is_device_public_page(page)) {
+			get_page(page);
+			page_dup_rmap(page, false);
+			rss[mm_counter(page)]++;
+		}
 	}
 
 out_set_pte:
@@ -1236,7 +1272,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 		if (pte_present(ptent)) {
 			struct page *page;
 
-			page = vm_normal_page(vma, addr, ptent);
+			page = _vm_normal_page(vma, addr, ptent, true);
 			if (unlikely(details) && page) {
 				/*
 				 * unmap_shared_mapping_pages() wants to
diff --git a/mm/migrate.c b/mm/migrate.c
index 729f341..9c3c323 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -229,12 +229,19 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		if (is_write_migration_entry(entry))
 			pte = maybe_mkwrite(pte, vma);
 
-		if (unlikely(is_zone_device_page(new)) &&
-		    is_device_private_page(new)) {
-			entry = make_device_private_entry(new, pte_write(pte));
-			pte = swp_entry_to_pte(entry);
-			if (pte_swp_soft_dirty(*pvmw.pte))
-				pte = pte_mksoft_dirty(pte);
+		if (unlikely(is_zone_device_page(new))) {
+			if (is_device_private_page(new)) {
+				entry = make_device_private_entry(new, pte_write(pte));
+				pte = swp_entry_to_pte(entry);
+				if (pte_swp_soft_dirty(*pvmw.pte))
+					pte = pte_mksoft_dirty(pte);
+			}
+#if IS_ENABLED(CONFIG_DEVICE_PUBLIC)
+			else if (is_device_public_page(new)) {
+				pte = pte_mkdevmap(pte);
+				flush_dcache_page(new);
+			}
+#endif /* IS_ENABLED(CONFIG_DEVICE_PUBLIC) */
 		} else
 			flush_dcache_page(new);
 
@@ -408,12 +415,11 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	void **pslot;
 
 	/*
-	 * ZONE_DEVICE pages have 1 refcount always held by their device
-	 *
-	 * Note that DAX memory will never reach that point as it does not have
-	 * the MEMORY_DEVICE_ALLOW_MIGRATE flag set (see memory_hotplug.h).
+	 * Device public or private pages have an extra refcount as they are
+	 * ZONE_DEVICE pages.
 	 */
-	expected_count += is_zone_device_page(page);
+	expected_count += is_device_private_page(page);
+	expected_count += is_device_public_page(page);
 
 	if (!mapping) {
 		/* Anonymous page without mapping */
@@ -2098,7 +2104,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 #endif /* CONFIG_NUMA */
 
-
 struct migrate_vma {
 	struct vm_area_struct	*vma;
 	unsigned long		*dst;
@@ -2177,7 +2182,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			if (is_write_device_private_entry(entry))
 				mpfn |= MIGRATE_PFN_WRITE;
 		} else {
-			page = vm_normal_page(migrate->vma, addr, pte);
+			page = _vm_normal_page(migrate->vma, addr, pte, true);
 			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
 			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 		}
@@ -2302,13 +2307,18 @@ static bool migrate_vma_check_page(struct page *page)
 
 	/* Page from ZONE_DEVICE have one extra reference */
 	if (is_zone_device_page(page)) {
-		if (is_device_private_page(page)) {
+		if (is_device_private_page(page) ||
+		    is_device_public_page(page))
 			extra++;
-		} else
+		else
 			/* Other ZONE_DEVICE memory type are not supported */
 			return false;
 	}
 
+	/* For file back page */
+	if (page_mapping(page))
+		extra += 1 + page_has_private(page);
+
 	if ((page_count(page) - extra) > page_mapcount(page))
 		return false;
 
@@ -2532,11 +2542,21 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
 	 */
 	__SetPageUptodate(page);
 
-	if (is_zone_device_page(page) && is_device_private_page(page)) {
-		swp_entry_t swp_entry;
+	if (is_zone_device_page(page)) {
+		if (is_device_private_page(page)) {
+			swp_entry_t swp_entry;
 
-		swp_entry = make_device_private_entry(page, vma->vm_flags & VM_WRITE);
-		entry = swp_entry_to_pte(swp_entry);
+			swp_entry = make_device_private_entry(page, vma->vm_flags & VM_WRITE);
+			entry = swp_entry_to_pte(swp_entry);
+		}
+#if IS_ENABLED(CONFIG_DEVICE_PUBLIC)
+		else if (is_device_public_page(page)) {
+			entry = pte_mkold(mk_pte(page, READ_ONCE(vma->vm_page_prot)));
+			if (vma->vm_flags & VM_WRITE)
+				entry = pte_mkwrite(pte_mkdirty(entry));
+			entry = pte_mkdevmap(entry);
+		}
+#endif /* IS_ENABLED(CONFIG_DEVICE_PUBLIC) */
 	} else {
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (vma->vm_flags & VM_WRITE)
@@ -2623,7 +2643,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 					migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 					continue;
 				}
-			} else {
+			} else if (!is_device_public_page(newpage)) {
 				/*
 				 * Other types of ZONE_DEVICE page are not
 				 * supported.
diff --git a/mm/swap.c b/mm/swap.c
index 4f44dbd..212370d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -760,6 +760,17 @@ void release_pages(struct page **pages, int nr, bool cold)
 		if (is_huge_zero_page(page))
 			continue;
 
+		/* Device public page can not be huge page */
+		if (is_device_public_page(page)) {
+			if (locked_pgdat) {
+				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
+						       flags);
+				locked_pgdat = NULL;
+			}
+			put_zone_device_private_or_public_page(page);
+			continue;
+		}
+
 		page = compound_head(page);
 		if (!put_page_testzero(page))
 			continue;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
