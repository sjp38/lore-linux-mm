Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 994AE6B0270
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:46:13 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 71so576184845ioe.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:46:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 84si35236683ioq.147.2017.01.06.07.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 07:46:12 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v15 13/16] mm/hmm/migrate: new memory migration helper for use with device memory v2
Date: Fri,  6 Jan 2017 11:46:40 -0500
Message-Id: <1483721203-1678-14-git-send-email-jglisse@redhat.com>
In-Reply-To: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This patch add a new memory migration helpers, which migrate memory
backing a range of virtual address of a process to different memory
(which can be allocated through special allocator). It differs from
numa migration by working on a range of virtual address and thus by
doing migration in chunk that can be large enough to use DMA engine
or special copy offloading engine.

Expected users are any one with heterogeneous memory where different
memory have different characteristics (latency, bandwidth, ...). As
an example IBM platform with CAPI bus can make use of this feature
to migrate between regular memory and CAPI device memory. New CPU
architecture with a pool of high performance memory not manage as
cache but presented as regular memory (while being faster and with
lower latency than DDR) will also be prime user of this patch.

Migration to private device memory will be usefull for device that
have large pool of such like GPU, NVidia plans to use HMM for that.

Changed since v1:
  - typos fix
  - split early unmap optimization for page with single mapping

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h |  66 +++++++-
 mm/Kconfig          |  13 ++
 mm/migrate.c        | 460 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 536 insertions(+), 3 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index f19c2a0..b1de4e1 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -88,10 +88,13 @@ struct hmm;
  * HMM_PFN_ERROR: corresponding CPU page table entry point to poisonous memory
  * HMM_PFN_EMPTY: corresponding CPU page table entry is none (pte_none() true)
  * HMM_PFN_DEVICE: this is device memory (ie a ZONE_DEVICE page)
+ * HMM_PFN_LOCKED: underlying struct page is lock
  * HMM_PFN_SPECIAL: corresponding CPU page table entry is special ie result of
  *      vm_insert_pfn() or vm_insert_page() and thus should not be mirror by a
  *      device (the entry will never have HMM_PFN_VALID set and the pfn value
  *      is undefine)
+ * HMM_PFN_MIGRATE: use by hmm_vma_migrate() to signify which address can be
+ *      migrated
  * HMM_PFN_UNADDRESSABLE: unaddressable device memory (ZONE_DEVICE)
  */
 typedef unsigned long hmm_pfn_t;
@@ -102,9 +105,11 @@ typedef unsigned long hmm_pfn_t;
 #define HMM_PFN_ERROR (1 << 3)
 #define HMM_PFN_EMPTY (1 << 4)
 #define HMM_PFN_DEVICE (1 << 5)
-#define HMM_PFN_SPECIAL (1 << 6)
-#define HMM_PFN_UNADDRESSABLE (1 << 7)
-#define HMM_PFN_SHIFT 8
+#define HMM_PFN_LOCKED (1 << 6)
+#define HMM_PFN_SPECIAL (1 << 7)
+#define HMM_PFN_MIGRATE (1 << 8)
+#define HMM_PFN_UNADDRESSABLE (1 << 9)
+#define HMM_PFN_SHIFT 10
 
 /*
  * hmm_pfn_to_page() - return struct page pointed to by a valid hmm_pfn_t
@@ -317,6 +322,61 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
+#if IS_ENABLED(CONFIG_HMM_MIGRATE)
+/*
+ * struct hmm_migrate_ops - migrate operation callback
+ *
+ * @alloc_and_copy: alloc destination memoiry and copy source to it
+ * @finalize_and_map: allow caller to inspect successfull migrated page
+ *
+ * The new HMM migrate helper hmm_vma_migrate() allow memory migration to use
+ * device DMA engine to perform copy from source to destination memory it also
+ * allow caller to use its own memory allocator for destination memory.
+ *
+ * Note that in alloc_and_copy device driver can decide not to migrate some of
+ * the entry by simply setting corresponding dst_pfns to 0.
+ *
+ * Destination page must locked and HMM_PFN_LOCKED flag set in corresponding
+ * hmm_pfn_t entry of dst_pfns array. It is expected that page allocated will
+ * have an elevated refcount and that a put_page() will free the page.
+ *
+ * Device driver might want to allocate with an extra-refcount if they want to
+ * control deallocation of failed migration inside finalize_and_map() callback.
+ *
+ * Inside finalize_and_map() device driver must use the HMM_PFN_MIGRATE flag to
+ * determine which page have been successfully migrated (this is set inside the
+ * src_pfns array).
+ *
+ * For migration from device memory to system memory device driver must set any
+ * dst_pfns entry to HMM_PFN_ERROR for any entry it can not migrate back due to
+ * hardware fatal failure that can not be recovered. Such failure will trigger
+ * a SIGBUS for the process trying to access such memory.
+ */
+struct hmm_migrate_ops {
+	void (*alloc_and_copy)(struct vm_area_struct *vma,
+			       const hmm_pfn_t *src_pfns,
+			       hmm_pfn_t *dst_pfns,
+			       unsigned long start,
+			       unsigned long end,
+			       void *private);
+	void (*finalize_and_map)(struct vm_area_struct *vma,
+				 const hmm_pfn_t *src_pfns,
+				 hmm_pfn_t *dst_pfns,
+				 unsigned long start,
+				 unsigned long end,
+				 void *private);
+};
+
+int hmm_vma_migrate(const struct hmm_migrate_ops *ops,
+		    struct vm_area_struct *vma,
+		    hmm_pfn_t *src_pfns,
+		    hmm_pfn_t *dst_pfns,
+		    unsigned long start,
+		    unsigned long end,
+		    void *private);
+#endif /* IS_ENABLED(CONFIG_HMM_MIGRATE) */
+
+
 /* Below are for HMM internal use only ! Not to be used by device driver ! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 598c38a..3806d69 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -308,6 +308,19 @@ config HMM_MIRROR
 	  range of virtual address. This require careful synchronization with
 	  CPU page table update.
 
+config HMM_MIGRATE
+	bool "HMM migrate virtual range of process using device driver DMA"
+	select HMM
+	select MIGRATION
+	help
+	  HMM migrate is a new helper to migrate range of virtual address using
+	  special page allocator and copy callback. This allow device driver to
+	  migrate range of a process memory to its memory using its DMA engine.
+
+	  It obyes all rules of memory migration, except that it supports the
+	  migration of ZONE_DEVICE page that have MEMOY_DEVICE_ALLOW_MIGRATE
+	  flag set.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 36e2ed9..365b615 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -41,6 +41,7 @@
 #include <linux/page_idle.h>
 #include <linux/page_owner.h>
 #include <linux/memremap.h>
+#include <linux/hmm.h>
 
 #include <asm/tlbflush.h>
 
@@ -421,6 +422,14 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	int expected_count = 1 + extra_count;
 	void **pslot;
 
+	/*
+	 * ZONE_DEVICE pages have 1 refcount always held by their device
+	 *
+	 * Note that DAX memory will never reach that point as it does not have
+	 * the MEMORY_DEVICE_ALLOW_MIGRATE flag set (see memory_hotplug.h).
+	 */
+	expected_count += is_zone_device_page(page);
+
 	if (!mapping) {
 		/* Anonymous page without mapping */
 		if (page_count(page) != expected_count)
@@ -2087,3 +2096,454 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #endif /* CONFIG_NUMA_BALANCING */
 
 #endif /* CONFIG_NUMA */
+
+
+#if IS_ENABLED(CONFIG_HMM_MIGRATE)
+struct hmm_migrate {
+	struct vm_area_struct	*vma;
+	hmm_pfn_t		*dst_pfns;
+	hmm_pfn_t		*src_pfns;
+	unsigned long		npages;
+	unsigned long		start;
+	unsigned long		end;
+};
+
+static int hmm_collect_walk_pmd(pmd_t *pmdp,
+				unsigned long start,
+				unsigned long end,
+				struct mm_walk *walk)
+{
+	struct hmm_migrate *migrate = walk->private;
+	struct mm_struct *mm = walk->vma->vm_mm;
+	unsigned long addr = start;
+	hmm_pfn_t *src_pfns;
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+again:
+	if (pmd_none(*pmdp))
+		return 0;
+
+	split_huge_pmd(walk->vma, pmdp, addr);
+	if (pmd_trans_unstable(pmdp))
+		goto again;
+
+	src_pfns = &migrate->src_pfns[(addr - migrate->start) >> PAGE_SHIFT];
+	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+
+	for (; addr < end; addr += PAGE_SIZE, src_pfns++, ptep++) {
+		unsigned long pfn;
+		swp_entry_t entry;
+		struct page *page;
+		hmm_pfn_t flags;
+		bool write;
+		pte_t pte;
+
+		pte = *ptep;
+
+		if (!pte_present(pte)) {
+			if (pte_none(pte))
+				continue;
+
+			/*
+			 * Only care about un-addressable device page special
+			 * page table entry. Other special swap entry are not
+			 * migratable and we ignore regular swaped page.
+			 */
+			entry = pte_to_swp_entry(pte);
+			if (!is_device_entry(entry))
+				continue;
+
+			flags = HMM_PFN_DEVICE | HMM_PFN_UNADDRESSABLE;
+			write = is_write_device_entry(entry);
+			page = device_entry_to_page(entry);
+			pfn = page_to_pfn(page);
+
+			if (!dev_page_allow_migrate(page))
+				continue;
+		} else {
+			pfn = pte_pfn(pte);
+			write = pte_write(pte);
+			page = pfn_to_page(pfn);
+			flags = is_zone_device_page(page) ? HMM_PFN_DEVICE : 0;
+		}
+
+		/* FIXME support THP see hmm_migrate_page_check() */
+		if (PageTransCompound(page))
+			continue;
+
+		/*
+		 * Corner case handling:
+		 * 1. When a new swap-cache page is read into, it is added to
+		 * the LRU and treated as swapcache but it has no rmap yet. Skip
+		 * those.
+		 */
+		if (!page->mapping)
+			continue;
+
+		*src_pfns = hmm_pfn_from_pfn(pfn) | HMM_PFN_MIGRATE | flags;
+		*src_pfns |= write ? HMM_PFN_WRITE : 0;
+		migrate->npages++;
+
+		/*
+		 * By getting a reference on the page we pin it and blocks any
+		 * kind of migration. Side effect is that it "freeze" the pte.
+		 *
+		 * We drop this reference after isolating the page from the lru
+		 * for non device page (device page are not on the lru and thus
+		 * can't be drop from it).
+		 */
+		get_page(page);
+	}
+	pte_unmap_unlock(ptep - 1, ptl);
+
+	return 0;
+}
+
+/*
+ * hmm_migrate_collect() - collect page over range of virtual address
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This will go over the CPU page table and for each virtual address back by a
+ * valid page it update the src_pfns array and take a reference on the page in
+ * order to pin the page until we lock it and unmap it.
+ */
+static void hmm_migrate_collect(struct hmm_migrate *migrate)
+{
+	struct mm_walk mm_walk;
+
+	mm_walk.pmd_entry = hmm_collect_walk_pmd;
+	mm_walk.pte_entry = NULL;
+	mm_walk.pte_hole = NULL;
+	mm_walk.hugetlb_entry = NULL;
+	mm_walk.test_walk = NULL;
+	mm_walk.vma = migrate->vma;
+	mm_walk.mm = migrate->vma->vm_mm;
+	mm_walk.private = migrate;
+
+	mmu_notifier_invalidate_range_start(mm_walk.mm,
+					    migrate->start,
+					    migrate->end);
+	walk_page_range(migrate->start, migrate->end, &mm_walk);
+	mmu_notifier_invalidate_range_end(mm_walk.mm,
+					  migrate->start,
+					  migrate->end);
+}
+
+/*
+ * hmm_migrate_page_check() - check if page is pin or not
+ * @page: struct page to check
+ *
+ * Pinned page can not be migrated. Same test in migrate_page_move_mapping()
+ * except that here we allow migration of ZONE_DEVICE page.
+ */
+static inline bool hmm_migrate_page_check(struct page *page)
+{
+	/*
+	 * One extra ref because caller hold an extra reference either from
+	 * either isolate_lru_page() for regular page or hmm_migrate_collect()
+	 * for device page.
+	 */
+	int extra = 1;
+
+	/*
+	 * FIXME support THP (transparent huge page), it is bit more complex to
+	 * check them then regular page because they can be map with a pmd or
+	 * with a pte (split pte mapping).
+	 */
+	if (PageCompound(page))
+		return false;
+
+	/* Page from ZONE_DEVICE have one extra reference */
+	if (is_zone_device_page(page)) {
+		if (!dev_page_allow_migrate(page))
+			return false;
+		extra++;
+	}
+
+	if ((page_count(page) - extra) > page_mapcount(page))
+		return false;
+
+	return true;
+}
+
+/*
+ * hmm_migrate_lock_and_isolate() - lock pages and isolate them from the lru
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This lock pages that have been collected by hmm_migrate_collect(). Once page
+ * is locked it is isolated from the lru (for non device page). Finaly the ref
+ * taken by hmm_migrate_collect() is drop as locked page can not be migrated by
+ * concurrent kernel thread.
+ */
+static void hmm_migrate_lock_and_isolate(struct hmm_migrate *migrate)
+{
+	unsigned long addr = migrate->start, i = 0;
+	bool allow_drain = true;
+
+	lru_add_drain();
+
+	for (; (addr<migrate->end) && migrate->npages; addr+=PAGE_SIZE, i++) {
+		struct page *page = hmm_pfn_to_page(migrate->src_pfns[i]);
+
+		if (!page)
+			continue;
+
+		lock_page(page);
+		migrate->src_pfns[i] |= HMM_PFN_LOCKED;
+
+		/* ZONE_DEVICE page are not on LRU */
+		if (!is_zone_device_page(page)) {
+			if (!PageLRU(page) && allow_drain) {
+				/* Drain CPU's pagevec */
+				lru_add_drain_all();
+				allow_drain = false;
+			}
+
+			if (isolate_lru_page(page)) {
+				migrate->src_pfns[i] = 0;
+				migrate->npages--;
+				unlock_page(page);
+				put_page(page);
+			} else
+				/* Drop the reference we took in collect */
+				put_page(page);
+		}
+
+		if (!hmm_migrate_page_check(page)) {
+			migrate->src_pfns[i] = 0;
+			migrate->npages--;
+			unlock_page(page);
+			put_page(page);
+		}
+	}
+}
+
+/*
+ * hmm_migrate_unmap() - replace page mapping with special migration pte entry
+ * @migrate: migrate struct containing all migration informations
+ *
+ * Replace page mapping (CPU page table pte) with special migration pte entry
+ * and check again if it has be pin. Pin page are restore because we can not
+ * migrate them.
+ *
+ * This is the last step before we call the device driver callback to allocate
+ * destination memory and copy content of original page over to new page.
+ */
+static void hmm_migrate_unmap(struct hmm_migrate *migrate)
+{
+	int flags = TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	unsigned long addr = migrate->start, i = 0, restore = 0;
+
+	for (; addr < migrate->end; addr += PAGE_SIZE, i++) {
+		struct page *page = hmm_pfn_to_page(migrate->src_pfns[i]);
+
+		if (!page || !(migrate->src_pfns[i] & HMM_PFN_MIGRATE))
+			continue;
+
+		try_to_unmap(page, flags);
+		if (page_mapped(page) || !hmm_migrate_page_check(page)) {
+			migrate->src_pfns[i] &= ~HMM_PFN_MIGRATE;
+			migrate->npages--;
+			restore++;
+		}
+	}
+
+	for (; (addr < migrate->end) && restore; addr += PAGE_SIZE, i++) {
+		struct page *page = hmm_pfn_to_page(migrate->src_pfns[i]);
+
+		if (!page || (migrate->src_pfns[i] & HMM_PFN_MIGRATE))
+			continue;
+
+		remove_migration_ptes(page, page, false);
+
+		migrate->src_pfns[i] = 0;
+		unlock_page(page);
+		restore--;
+
+		if (is_zone_device_page(page))
+			put_page(page);
+		else
+			putback_lru_page(page);
+	}
+}
+
+/*
+ * hmm_migrate_struct_page() - migrate meta-data from src page to dst page
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This migrate struct page meta-data from source struct page to destination
+ * struct page. This effectively finish the migration from source page to the
+ * destination page.
+ */
+static void hmm_migrate_struct_page(struct hmm_migrate *migrate)
+{
+	unsigned long addr = migrate->start, i = 0;
+
+	for (; addr < migrate->end; addr += PAGE_SIZE, i++) {
+		struct page *newpage = hmm_pfn_to_page(migrate->dst_pfns[i]);
+		struct page *page = hmm_pfn_to_page(migrate->src_pfns[i]);
+		struct address_space *mapping;
+		int r;
+
+		if (!page || !newpage)
+			continue;
+		if (!(migrate->src_pfns[i] & HMM_PFN_MIGRATE))
+			continue;
+
+		mapping = page_mapping(page);
+
+		/*
+		 * For now only support private anonymous when migrating
+		 * to un-addressable device memory.
+		 */
+		if (mapping && is_zone_device_page(newpage) &&
+		    !is_addressable_page(newpage)) {
+			migrate->src_pfns[i] &= ~HMM_PFN_MIGRATE;
+			continue;
+		}
+
+		r = migrate_page(mapping, newpage, page, MIGRATE_SYNC, false);
+		if (r != MIGRATEPAGE_SUCCESS)
+			migrate->src_pfns[i] &= ~HMM_PFN_MIGRATE;
+	}
+}
+
+/*
+ * hmm_migrate_remove_migration_pte() - restore CPU page table entry
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This replace the special migration pte entry with either a mapping to the
+ * new page if migration was successful for that page or to the original page
+ * otherwise.
+ *
+ * This also unlock the page and put them back on the lru or drop the extra
+ * ref for device page.
+ */
+static void hmm_migrate_remove_migration_pte(struct hmm_migrate *migrate)
+{
+	unsigned long addr = migrate->start, i = 0;
+
+	for (; (addr<migrate->end) && migrate->npages; addr+=PAGE_SIZE, i++) {
+		struct page *newpage = hmm_pfn_to_page(migrate->dst_pfns[i]);
+		struct page *page = hmm_pfn_to_page(migrate->src_pfns[i]);
+
+		if (!page)
+			continue;
+		newpage = newpage ? newpage : page;
+
+		remove_migration_ptes(page, newpage, false);
+		unlock_page(page);
+		migrate->npages--;
+
+		if (is_zone_device_page(page))
+			put_page(page);
+		else
+			putback_lru_page(page);
+
+		if (newpage != page) {
+			unlock_page(newpage);
+			if (is_zone_device_page(newpage))
+				put_page(newpage);
+			else
+				putback_lru_page(newpage);
+		}
+	}
+}
+
+/*
+ * hmm_vma_migrate() - migrate a range of memory inside vma using accel copy
+ *
+ * @ops: migration callback for allocating destination memory and copying
+ * @vma: virtual memory area containing the range to be migrated
+ * @src_pfns: array of hmm_pfn_t containing source pfns
+ * @dst_pfns: array of hmm_pfn_t containing destination pfns
+ * @start: start address of the range to migrate (inclusive)
+ * @end: end address of the range to migrate (exclusive)
+ * @private: pointer passed back to each of the callback
+ * Returns: 0 on success, error code otherwise
+ *
+ * This will try to migrate a range of memory using callback to allocate and
+ * copy memory from source to destination. This function will first collect,
+ * lock and unmap pages in the range and then call alloc_and_copy() callback
+ * for device driver to allocate destination memory and copy from source.
+ *
+ * Then it will proceed and try to effectively migrate the page (struct page
+ * metadata) a step that can fail for various reasons. Before updating CPU page
+ * table it will call finalize_and_map() callback so that device driver can
+ * inspect what have been successfully migrated and update its own page table
+ * (this latter aspect is not mandatory and only make sense for some user of
+ * this API).
+ *
+ * Finaly the function update CPU page table and unlock the pages before
+ * returning 0.
+ *
+ * It will return an error code only if one of the argument is invalid.
+ */
+int hmm_vma_migrate(const struct hmm_migrate_ops *ops,
+		    struct vm_area_struct *vma,
+		    hmm_pfn_t *src_pfns,
+		    hmm_pfn_t *dst_pfns,
+		    unsigned long start,
+		    unsigned long end,
+		    void *private)
+{
+	struct hmm_migrate migrate;
+
+	/* Sanity check the arguments */
+	start &= PAGE_MASK;
+	end &= PAGE_MASK;
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
+		return -EINVAL;
+	if (!vma || !ops || !src_pfns || !dst_pfns || start >= end)
+		return -EINVAL;
+	if (start < vma->vm_start || start >= vma->vm_end)
+		return -EINVAL;
+	if (end <= vma->vm_start || end > vma->vm_end)
+		return -EINVAL;
+
+	memset(src_pfns, 0, sizeof(*src_pfns) * ((end - start) >> PAGE_SHIFT));
+	migrate.src_pfns = src_pfns;
+	migrate.dst_pfns = dst_pfns;
+	migrate.start = start;
+	migrate.npages = 0;
+	migrate.end = end;
+	migrate.vma = vma;
+
+	/* Collect, and try to unmap source pages */
+	hmm_migrate_collect(&migrate);
+	if (!migrate.npages)
+		return 0;
+
+	/* Lock and isolate page */
+	hmm_migrate_lock_and_isolate(&migrate);
+	if (!migrate.npages)
+		return 0;
+
+	/* Unmap pages */
+	hmm_migrate_unmap(&migrate);
+	if (!migrate.npages)
+		return 0;
+
+	/*
+	 * At this point pages are lock and unmap and thus they have stable
+	 * content and can safely be copied to destination memory that is
+	 * allocated by the callback.
+	 *
+	 * Note that migration can fail in hmm_migrate_struct_page() for each
+	 * individual page.
+	 */
+	ops->alloc_and_copy(vma, src_pfns, dst_pfns, start, end, private);
+
+	/* This does the real migration of struct page */
+	hmm_migrate_struct_page(&migrate);
+
+	ops->finalize_and_map(vma, src_pfns, dst_pfns, start, end, private);
+
+	/* Unlock and remap pages */
+	hmm_migrate_remove_migration_pte(&migrate);
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_vma_migrate);
+#endif /* IS_ENABLED(CONFIG_HMM_MIGRATE) */
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
