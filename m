Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89FAE6B0268
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:50:56 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id l19so283182352ywc.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:50:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c200si43308ybf.108.2017.01.27.13.50.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 13:50:55 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v17 06/14] mm/migrate: new memory migration helper for use with device memory v3
Date: Fri, 27 Jan 2017 17:52:13 -0500
Message-Id: <1485557541-7806-7-git-send-email-jglisse@redhat.com>
In-Reply-To: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

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

Changed since v2:
  - droped HMM prefix and HMM specific code
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
 include/linux/migrate.h |  74 ++++++++
 mm/migrate.c            | 449 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 523 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 37b77ba..cd56e41 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -122,4 +122,78 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 }
 #endif /* CONFIG_NUMA_BALANCING && CONFIG_TRANSPARENT_HUGEPAGE*/
 
+
+#define MIGRATE_PFN_VALID	(1UL << (BITS_PER_LONG_LONG - 1))
+#define MIGRATE_PFN_MIGRATE	(1UL << (BITS_PER_LONG_LONG - 2))
+#define MIGRATE_PFN_HUGE	(1UL << (BITS_PER_LONG_LONG - 3))
+#define MIGRATE_PFN_LOCKED	(1UL << (BITS_PER_LONG_LONG - 4))
+#define MIGRATE_PFN_WRITE	(1UL << (BITS_PER_LONG_LONG - 5))
+#define MIGRATE_PFN_ZERO	(1UL << (BITS_PER_LONG_LONG - 6))
+#define MIGRATE_PFN_MASK	((1UL << (BITS_PER_LONG_LONG - PAGE_SHIFT)) - 1)
+
+static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
+{
+	if (!(mpfn & MIGRATE_PFN_VALID))
+		return NULL;
+	return pfn_to_page(mpfn & MIGRATE_PFN_MASK);
+}
+
+static inline unsigned long migrate_pfn_size(unsigned long mpfn)
+{
+	return mpfn & MIGRATE_PFN_HUGE ? PMD_SIZE : PAGE_SIZE;
+}
+
+/*
+ * struct migrate_vma_ops - migrate operation callback
+ *
+ * @alloc_and_copy: alloc destination memoiry and copy source to it
+ * @finalize_and_map: allow caller to inspect successfull migrated page
+ *
+ * migrate_vma() allow memory migration to use DMA  engine to perform copy from
+ * source to destination memory it also allow caller to use its own memory
+ * allocator for destination memory.
+ *
+ * Note that in alloc_and_copy device driver can decide not to migrate some of
+ * the entry by simply setting corresponding dst entry 0.
+ *
+ * Destination page must locked and MIGRATE_PFN_LOCKED set in the corresponding
+ * entry of dstarray. It is expected that page allocated will have an elevated
+ * refcount and that a put_page() will free the page.
+ *
+ * Device driver might want to allocate with an extra-refcount if they want to
+ * control deallocation of failed migration inside finalize_and_map() callback.
+ *
+ * The finalize_and_map() callback must use the MIGRATE_PFN_MIGRATE flag to
+ * determine which page have been successfully migrated (it is set in the src
+ * array for each entry that have been successfully migrated).
+ *
+ * For migration from device memory to system memory device driver must set any
+ * dst entry to MIGRATE_PFN_ERROR for any entry it can not migrate back due to
+ * hardware fatal failure that can not be recovered. Such failure will trigger
+ * a SIGBUS for the process trying to access such memory.
+ */
+struct migrate_vma_ops {
+	void (*alloc_and_copy)(struct vm_area_struct *vma,
+			       const unsigned long *src,
+			       unsigned long *dst,
+			       unsigned long start,
+			       unsigned long end,
+			       void *private);
+	void (*finalize_and_map)(struct vm_area_struct *vma,
+				 const unsigned long *src,
+				 unsigned long *dst,
+				 unsigned long start,
+				 unsigned long end,
+				 void *private);
+};
+
+int migrate_vma(const struct migrate_vma_ops *ops,
+		struct vm_area_struct *vma,
+		unsigned long mentries,
+		unsigned long start,
+		unsigned long end,
+		unsigned long *src,
+		unsigned long *dst,
+		void *private);
+
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 567674d..150fc4d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -412,6 +412,14 @@ int migrate_page_move_mapping(struct address_space *mapping,
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
@@ -2078,3 +2086,444 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #endif /* CONFIG_NUMA_BALANCING */
 
 #endif /* CONFIG_NUMA */
+
+
+struct migrate_vma {
+	struct vm_area_struct	*vma;
+	unsigned long		*dst;
+	unsigned long		*src;
+	unsigned long		cpages;
+	unsigned long		npages;
+	unsigned long		mpages;
+	unsigned long		start;
+	unsigned long		end;
+};
+
+static inline int migrate_vma_array_full(struct migrate_vma *migrate)
+{
+	return migrate->npages >= migrate->mpages ? -ENOSPC : 0;
+}
+
+static int migrate_vma_collect_hole(unsigned long start,
+				    unsigned long end,
+				    struct mm_walk *walk)
+{
+	struct migrate_vma *migrate = walk->private;
+	unsigned long addr, next;
+
+	for (addr = start & PAGE_MASK; addr < end; addr = next) {
+		unsigned long npages, i;
+		int ret;
+
+		next = pmd_addr_end(addr, end);
+		npages = (next - addr) >> PAGE_SHIFT;
+		if (npages == (PMD_SIZE >> PAGE_SHIFT)) {
+			migrate->src[migrate->npages++] = MIGRATE_PFN_HUGE;
+			ret = migrate_vma_array_full(migrate);
+			if (ret)
+				return ret;
+		} else {
+			for (i = 0; i < npages; ++i) {
+				migrate->src[migrate->npages++] = 0;
+				ret = migrate_vma_array_full(migrate);
+				if (ret)
+					return ret;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static int migrate_vma_collect_pmd(pmd_t *pmdp,
+				   unsigned long start,
+				   unsigned long end,
+				   struct mm_walk *walk)
+{
+	struct migrate_vma *migrate = walk->private;
+	struct mm_struct *mm = walk->vma->vm_mm;
+	unsigned long addr = start;
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+	if (pmd_none(*pmdp) || pmd_trans_unstable(pmdp)) {
+		/* FIXME support THP */
+		return migrate_vma_collect_hole(start, end, walk);
+	}
+
+	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+	for (; addr < end; addr += PAGE_SIZE, ptep++) {
+		unsigned long flags, pfn;
+		struct page *page;
+		pte_t pte;
+		int ret;
+
+		pte = *ptep;
+		pfn = pte_pfn(pte);
+
+		if (!pte_present(pte)) {
+			flags = pfn = 0;
+			goto next;
+		}
+
+		/* FIXME support THP */
+		page = vm_normal_page(migrate->vma, addr, pte);
+		if (!page || !page->mapping || PageTransCompound(page)) {
+			flags = pfn = 0;
+			goto next;
+		}
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
+		migrate->cpages++;
+		flags = MIGRATE_PFN_VALID | MIGRATE_PFN_MIGRATE;
+		flags |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
+
+next:
+		migrate->src[migrate->npages++] = pfn | flags;
+		ret = migrate_vma_array_full(migrate);
+		if (ret) {
+			pte_unmap_unlock(ptep, ptl);
+			return ret;
+		}
+	}
+	pte_unmap_unlock(ptep - 1, ptl);
+
+	return 0;
+}
+
+/*
+ * migrate_vma_collect() - collect page over range of virtual address
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This will go over the CPU page table and for each virtual address back by a
+ * valid page it update the src array and take a reference on the page in
+ * order to pin the page until we lock it and unmap it.
+ */
+static void migrate_vma_collect(struct migrate_vma *migrate)
+{
+	struct mm_walk mm_walk;
+
+	mm_walk.pmd_entry = migrate_vma_collect_pmd;
+	mm_walk.pte_entry = NULL;
+	mm_walk.pte_hole = migrate_vma_collect_hole;
+	mm_walk.hugetlb_entry = NULL;
+	mm_walk.test_walk = NULL;
+	mm_walk.vma = migrate->vma;
+	mm_walk.mm = migrate->vma->vm_mm;
+	mm_walk.private = migrate;
+
+	walk_page_range(migrate->start, migrate->end, &mm_walk);
+}
+
+/*
+ * migrate_vma_check_page() - check if page is pin or not
+ * @page: struct page to check
+ *
+ * Pinned page can not be migrated. Same test in migrate_page_move_mapping()
+ * except that here we allow migration of ZONE_DEVICE page.
+ */
+static bool migrate_vma_check_page(struct page *page)
+{
+	/*
+	 * One extra ref because caller hold an extra reference either from
+	 * either isolate_lru_page() for regular page or migrate_vma_collect()
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
+	if ((page_count(page) - extra) > page_mapcount(page))
+		return false;
+
+	return true;
+}
+
+/*
+ * migrate_vma_prepare() - lock pages and isolate them from the lru
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This lock pages that have been collected by migrate_vma_collect(). Once page
+ * is locked it is isolated from the lru (for non device page). Finaly the ref
+ * taken by migrate_vma_collect() is drop as locked page can not be migrated by
+ * concurrent kernel thread.
+ */
+static void migrate_vma_prepare(struct migrate_vma *migrate)
+{
+	unsigned long addr = migrate->start, i = 0, size;
+	bool allow_drain = true;
+
+	lru_add_drain();
+
+	for (; i < migrate->npages && migrate->cpages; i++, addr += size) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		size = migrate_pfn_size(migrate->src[i]);
+
+		if (!page)
+			continue;
+
+		lock_page(page);
+		migrate->src[i] |= MIGRATE_PFN_LOCKED;
+
+		if (!PageLRU(page) && allow_drain) {
+			/* Drain CPU's pagevec */
+			lru_add_drain_all();
+			allow_drain = false;
+		}
+
+		if (isolate_lru_page(page)) {
+			migrate->src[i] = 0;
+			unlock_page(page);
+			migrate->cpages--;
+			put_page(page);
+			continue;
+		}
+
+		/* Drop the reference we took in collect */
+		put_page(page);
+
+		if (!migrate_vma_check_page(page)) {
+			migrate->src[i] = 0;
+			unlock_page(page);
+			migrate->cpages--;
+
+			putback_lru_page(page);
+		}
+	}
+}
+
+/*
+ * migrate_vma_unmap() - replace page mapping with special migration pte entry
+ * @migrate: migrate struct containing all migration informations
+ *
+ * Replace page mapping (CPU page table pte) with special migration pte entry
+ * and check again if it has be pin. Pin page are restore because we can not
+ * migrate them.
+ *
+ * This is the last step before we call the device driver callback to allocate
+ * destination memory and copy content of original page over to new page.
+ */
+static void migrate_vma_unmap(struct migrate_vma *migrate)
+{
+	int flags = TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	unsigned long addr = migrate->start, i = 0, restore = 0, size;
+
+	for (; addr < migrate->end && migrate->cpages; addr += size, i++) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		size = migrate_pfn_size(migrate->src[i]);
+
+		if (!page || !(migrate->src[i] & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		try_to_unmap(page, flags);
+		if (page_mapped(page) || !migrate_vma_check_page(page)) {
+			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+			migrate->cpages--;
+			restore++;
+		}
+	}
+
+	for (; addr < migrate->end && restore; addr += size, i++) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		size = migrate_pfn_size(migrate->src[i]);
+
+		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		remove_migration_ptes(page, page, false);
+
+		migrate->src[i] = 0;
+		unlock_page(page);
+		restore--;
+
+		putback_lru_page(page);
+	}
+}
+
+/*
+ * migrate_vma_pages() - migrate meta-data from src page to dst page
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This migrate struct page meta-data from source struct page to destination
+ * struct page. This effectively finish the migration from source page to the
+ * destination page.
+ */
+static void migrate_vma_pages(struct migrate_vma *migrate)
+{
+	unsigned long addr = migrate->start, i = 0, size;
+
+	for (; addr < migrate->end; addr += size, i++) {
+		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		struct address_space *mapping;
+		int r;
+
+		size = migrate_pfn_size(migrate->src[i]);
+
+		if (!page || !newpage)
+			continue;
+		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		mapping = page_mapping(page);
+
+		r = migrate_page(mapping, newpage, page, MIGRATE_SYNC, false);
+		if (r != MIGRATEPAGE_SUCCESS)
+			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+	}
+}
+
+/*
+ * migrate_vma_finalize() - restore CPU page table entry
+ * @migrate: migrate struct containing all migration informations
+ *
+ * This replace the special migration pte entry with either a mapping to the
+ * new page if migration was successful for that page or to the original page
+ * otherwise.
+ *
+ * This also unlock the page and put them back on the lru or drop the extra
+ * ref for device page.
+ */
+static void migrate_vma_finalize(struct migrate_vma *migrate)
+{
+	unsigned long addr = migrate->start, i = 0, size;
+
+	for (; addr<migrate->end && migrate->cpages; addr += size, i++) {
+		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		size = migrate_pfn_size(migrate->src[i]);
+
+		if (!page)
+			continue;
+		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE) || !newpage) {
+			if (newpage)
+				put_page(newpage);
+			newpage = page;
+		}
+
+		remove_migration_ptes(page, newpage, false);
+		unlock_page(page);
+		migrate->cpages--;
+
+		putback_lru_page(page);
+
+		if (newpage != page) {
+			unlock_page(newpage);
+			putback_lru_page(newpage);
+		}
+	}
+}
+
+/*
+ * migrate_vma() - migrate a range of memory inside vma using accel copy
+ *
+ * @ops: migration callback for allocating destination memory and copying
+ * @vma: virtual memory area containing the range to be migrated
+ * @mentries: maximum number of entry in src or dst pfns array
+ * @start: start address of the range to migrate (inclusive)
+ * @end: end address of the range to migrate (exclusive)
+ * @src: array of hmm_pfn_t containing source pfns
+ * @dst: array of hmm_pfn_t containing destination pfns
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
+int migrate_vma(const struct migrate_vma_ops *ops,
+		struct vm_area_struct *vma,
+		unsigned long mentries,
+		unsigned long start,
+		unsigned long end,
+		unsigned long *src,
+		unsigned long *dst,
+		void *private)
+{
+	struct migrate_vma migrate;
+
+	/* Sanity check the arguments */
+	start &= PAGE_MASK;
+	end &= PAGE_MASK;
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
+		return -EINVAL;
+	if (!vma || !ops || !src || !dst || start >= end)
+		return -EINVAL;
+	if (start < vma->vm_start || start >= vma->vm_end)
+		return -EINVAL;
+	if (end <= vma->vm_start || end > vma->vm_end)
+		return -EINVAL;
+
+	memset(src, 0, sizeof(*src) * ((end - start) >> PAGE_SHIFT));
+	migrate.src = src;
+	migrate.dst = dst;
+	migrate.start = start;
+	migrate.npages = 0;
+	migrate.cpages = 0;
+	migrate.mpages = mentries;
+	migrate.end = end;
+	migrate.vma = vma;
+
+	/* Collect, and try to unmap source pages */
+	migrate_vma_collect(&migrate);
+	if (!migrate.cpages)
+		return 0;
+
+	/* Lock and isolate page */
+	migrate_vma_prepare(&migrate);
+	if (!migrate.cpages)
+		return 0;
+
+	/* Unmap pages */
+	migrate_vma_unmap(&migrate);
+	if (!migrate.cpages)
+		return 0;
+
+	/*
+	 * At this point pages are lock and unmap and thus they have stable
+	 * content and can safely be copied to destination memory that is
+	 * allocated by the callback.
+	 *
+	 * Note that migration can fail in migrate_vma_struct_page() for each
+	 * individual page.
+	 */
+	ops->alloc_and_copy(vma, src, dst, start, end, private);
+
+	/* This does the real migration of struct page */
+	migrate_vma_pages(&migrate);
+
+	ops->finalize_and_map(vma, src, dst, start, end, private);
+
+	/* Unlock and remap pages */
+	migrate_vma_finalize(&migrate);
+
+	return 0;
+}
+EXPORT_SYMBOL(migrate_vma);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
