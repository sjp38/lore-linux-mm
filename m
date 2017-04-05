Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7046B03B4
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 16:40:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b9so6428737qtg.4
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 13:40:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c198si18747999qka.71.2017.04.05.13.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 13:40:48 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 06/16] mm/migrate: new memory migration helper for use with device memory v4
Date: Wed,  5 Apr 2017 16:40:16 -0400
Message-Id: <20170405204026.3940-7-jglisse@redhat.com>
In-Reply-To: <20170405204026.3940-1-jglisse@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

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

Migration to private device memory will be useful for device that
have large pool of such like GPU, NVidia plans to use HMM for that.

Changes since v3:
  - Rebase

Changes since v2:
  - droped HMM prefix and HMM specific code
Changes since v1:
  - typos fix
  - split early unmap optimization for page with single mapping

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/migrate.h | 104 ++++++++++++
 mm/migrate.c            | 444 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 548 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 78a0fdc..576b3f5 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -127,4 +127,108 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 }
 #endif /* CONFIG_NUMA_BALANCING && CONFIG_TRANSPARENT_HUGEPAGE*/
 
+
+#ifdef CONFIG_MIGRATION
+
+#define MIGRATE_PFN_VALID	(1UL << 0)
+#define MIGRATE_PFN_MIGRATE	(1UL << 1)
+#define MIGRATE_PFN_LOCKED	(1UL << 2)
+#define MIGRATE_PFN_WRITE	(1UL << 3)
+#define MIGRATE_PFN_ERROR	(1UL << 4)
+#define MIGRATE_PFN_SHIFT	5
+
+static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
+{
+	if (!(mpfn & MIGRATE_PFN_VALID))
+		return NULL;
+	return pfn_to_page(mpfn >> MIGRATE_PFN_SHIFT);
+}
+
+static inline unsigned long migrate_pfn(unsigned long pfn)
+{
+	return (pfn << MIGRATE_PFN_SHIFT) | MIGRATE_PFN_VALID;
+}
+
+/*
+ * struct migrate_vma_ops - migrate operation callback
+ *
+ * @alloc_and_copy: alloc destination memory and copy source memory to it
+ * @finalize_and_map: allow caller to map the successfully migrated pages
+ *
+ *
+ * The alloc_and_copy() callback happens once all source pages have been locked,
+ * unmapped and checked (checked whether pinned or not). All pages that can be
+ * migrated will have an entry in the src array set with the pfn value of the
+ * page and with the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set (other
+ * flags might be set but should be ignored by the callback).
+ *
+ * The alloc_and_copy() callback can then allocate destination memory and copy
+ * source memory to it for all those entries (ie with MIGRATE_PFN_VALID and
+ * MIGRATE_PFN_MIGRATE flag set). Once these are allocated and copied, the
+ * callback must update each corresponding entry in the dst array with the pfn
+ * value of the destination page and with the MIGRATE_PFN_VALID and
+ * MIGRATE_PFN_LOCKED flags set (destination pages must have their struct pages
+ * locked, via lock_page()).
+ *
+ * At this point the alloc_and_copy() callback is done and returns.
+ *
+ * Note that the callback does not have to migrate all the pages that are
+ * marked with MIGRATE_PFN_MIGRATE flag in src array unless this is a migration
+ * from device memory to system memory (ie the MIGRATE_PFN_DEVICE flag is also
+ * set in the src array entry). If the device driver cannot migrate a device
+ * page back to system memory, then it must set the corresponding dst array
+ * entry to MIGRATE_PFN_ERROR. This will trigger a SIGBUS if CPU tries to
+ * access any of the virtual addresses originally backed by this page. Because
+ * a SIGBUS is such a severe result for the userspace process, the device
+ * driver should avoid setting MIGRATE_PFN_ERROR unless it is really in an
+ * unrecoverable state.
+ *
+ * THE alloc_and_copy() CALLBACK MUST NOT CHANGE ANY OF THE SRC ARRAY ENTRIES
+ * OR BAD THINGS WILL HAPPEN !
+ *
+ *
+ * The finalize_and_map() callback happens after struct page migration from
+ * source to destination (destination struct pages are the struct pages for the
+ * memory allocated by the alloc_and_copy() callback).  Migration can fail, and
+ * thus the finalize_and_map() allows the driver to inspect which pages were
+ * successfully migrated, and which were not. Successfully migrated pages will
+ * have the MIGRATE_PFN_MIGRATE flag set for their src array entry.
+ *
+ * It is safe to update device page table from within the finalize_and_map()
+ * callback because both destination and source page are still locked, and the
+ * mmap_sem is held in read mode (hence no one can unmap the range being
+ * migrated).
+ *
+ * Once callback is done cleaning up things and updating its page table (if it
+ * chose to do so, this is not an obligation) then it returns. At this point,
+ * the HMM core will finish up the final steps, and the migration is complete.
+ *
+ * THE finalize_and_map() CALLBACK MUST NOT CHANGE ANY OF THE SRC OR DST ARRAY
+ * ENTRIES OR BAD THINGS WILL HAPPEN !
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
+				 const unsigned long *dst,
+				 unsigned long start,
+				 unsigned long end,
+				 void *private);
+};
+
+int migrate_vma(const struct migrate_vma_ops *ops,
+		struct vm_area_struct *vma,
+		unsigned long start,
+		unsigned long end,
+		unsigned long *src,
+		unsigned long *dst,
+		void *private);
+
+#endif /* CONFIG_MIGRATION */
+
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 5176772..b2ce541 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -395,6 +395,14 @@ int migrate_page_move_mapping(struct address_space *mapping,
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
@@ -2075,3 +2083,439 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
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
+	unsigned long		start;
+	unsigned long		end;
+};
+
+static int migrate_vma_collect_hole(unsigned long start,
+				    unsigned long end,
+				    struct mm_walk *walk)
+{
+	struct migrate_vma *migrate = walk->private;
+	unsigned long addr, next;
+
+	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
+		migrate->dst[migrate->npages] = 0;
+		migrate->src[migrate->npages++] = 0;
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
+		unsigned long mpfn, pfn;
+		struct page *page;
+		pte_t pte;
+
+		pte = *ptep;
+		pfn = pte_pfn(pte);
+
+		if (!pte_present(pte)) {
+			mpfn = pfn = 0;
+			goto next;
+		}
+
+		/* FIXME support THP */
+		page = vm_normal_page(migrate->vma, addr, pte);
+		if (!page || !page->mapping || PageTransCompound(page)) {
+			mpfn = pfn = 0;
+			goto next;
+		}
+
+		/*
+		 * By getting a reference on the page we pin it and that blocks
+		 * any kind of migration. Side effect is that it "freezes" the
+		 * pte.
+		 *
+		 * We drop this reference after isolating the page from the lru
+		 * for non device page (device page are not on the lru and thus
+		 * can't be dropped from it).
+		 */
+		get_page(page);
+		migrate->cpages++;
+		mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
+		mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
+
+next:
+		migrate->src[migrate->npages++] = mpfn;
+	}
+	pte_unmap_unlock(ptep - 1, ptl);
+
+	return 0;
+}
+
+/*
+ * migrate_vma_collect() - collect pages over a range of virtual addresses
+ * @migrate: migrate struct containing all migration information
+ *
+ * This will walk the CPU page table. For each virtual address backed by a
+ * valid page, it updates the src array and takes a reference on the page, in
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
+
+	migrate->end = migrate->start + (migrate->npages << PAGE_SHIFT);
+}
+
+/*
+ * migrate_vma_check_page() - check if page is pinned or not
+ * @page: struct page to check
+ *
+ * Pinned pages cannot be migrated. This is the same test as in
+ * migrate_page_move_mapping(), except that here we allow migration of a
+ * ZONE_DEVICE page.
+ */
+static bool migrate_vma_check_page(struct page *page)
+{
+	/*
+	 * One extra ref because caller holds an extra reference, either from
+	 * isolate_lru_page() for a regular page, or migrate_vma_collect() for
+	 * a device page.
+	 */
+	int extra = 1;
+
+	/*
+	 * FIXME support THP (transparent huge page), it is bit more complex to
+	 * check them than regular pages, because they can be mapped with a pmd
+	 * or with a pte (split pte mapping).
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
+ * @migrate: migrate struct containing all migration information
+ *
+ * This locks pages that have been collected by migrate_vma_collect(). Once each
+ * page is locked it is isolated from the lru (for non-device pages). Finally,
+ * the ref taken by migrate_vma_collect() is dropped, as locked pages cannot be
+ * migrated by concurrent kernel threads.
+ */
+static void migrate_vma_prepare(struct migrate_vma *migrate)
+{
+	const unsigned long npages = migrate->npages;
+	const unsigned long start = migrate->start;
+	unsigned long addr, i, restore = 0;
+	bool allow_drain = true;
+
+	lru_add_drain();
+
+	for (i = 0; i < npages; i++) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
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
+ * @migrate: migrate struct containing all migration information
+ *
+ * Replace page mapping (CPU page table pte) with a special migration pte entry
+ * and check again if it has been pinned. Pinned pages are restored because we
+ * cannot migrate them.
+ *
+ * This is the last step before we call the device driver callback to allocate
+ * destination memory and copy contents of original page over to new page.
+ */
+static void migrate_vma_unmap(struct migrate_vma *migrate)
+{
+	int flags = TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	const unsigned long npages = migrate->npages;
+	const unsigned long start = migrate->start;
+	unsigned long addr, i, restore = 0;
+
+	for (i = 0; i < npages; i++) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
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
+	for (addr = start, i = 0; i < npages && restore; addr += PAGE_SIZE, i++) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
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
+ * @migrate: migrate struct containing all migration information
+ *
+ * This migrates struct page meta-data from source struct page to destination
+ * struct page. This effectively finishes the migration from source page to the
+ * destination page.
+ */
+static void migrate_vma_pages(struct migrate_vma *migrate)
+{
+	const unsigned long npages = migrate->npages;
+	const unsigned long start = migrate->start;
+	unsigned long addr, i;
+
+	for (i = 0, addr = start; i < npages; addr += PAGE_SIZE, i++) {
+		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		struct address_space *mapping;
+		int r;
+
+		if (!page || !newpage)
+			continue;
+		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		mapping = page_mapping(page);
+
+		r = migrate_page(mapping, newpage, page, MIGRATE_SYNC_NO_COPY);
+		if (r != MIGRATEPAGE_SUCCESS)
+			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+	}
+}
+
+/*
+ * migrate_vma_finalize() - restore CPU page table entry
+ * @migrate: migrate struct containing all migration information
+ *
+ * This replaces the special migration pte entry with either a mapping to the
+ * new page if migration was successful for that page, or to the original page
+ * otherwise.
+ *
+ * This also unlocks the pages and puts them back on the lru, or drops the extra
+ * refcount, for device pages.
+ */
+static void migrate_vma_finalize(struct migrate_vma *migrate)
+{
+	const unsigned long npages = migrate->npages;
+	unsigned long i;
+
+	for (i = 0; i < npages; i++) {
+		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+
+		if (!page)
+			continue;
+		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE) || !newpage) {
+			if (newpage) {
+				unlock_page(newpage);
+				put_page(newpage);
+			}
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
+ * migrate_vma() - migrate a range of memory inside vma
+ *
+ * @ops: migration callback for allocating destination memory and copying
+ * @vma: virtual memory area containing the range to be migrated
+ * @start: start address of the range to migrate (inclusive)
+ * @end: end address of the range to migrate (exclusive)
+ * @src: array of hmm_pfn_t containing source pfns
+ * @dst: array of hmm_pfn_t containing destination pfns
+ * @private: pointer passed back to each of the callback
+ * Returns: 0 on success, error code otherwise
+ *
+ * This function tries to migrate a range of memory virtual address range, using
+ * callbacks to allocate and copy memory from source to destination. First it
+ * collects all the pages backing each virtual address in the range, saving this
+ * inside the src array. Then it locks those pages and unmaps them. Once the pages
+ * are locked and unmapped, it checks whether each page is pinned or not. Pages
+ * that aren't pinned have the MIGRATE_PFN_MIGRATE flag set (by this function)
+ * in the corresponding src array entry. It then restores any pages that are
+ * pinned, by remapping and unlocking those pages.
+ *
+ * At this point it calls the alloc_and_copy() callback. For documentation on
+ * what is expected from that callback, see struct migrate_vma_ops comments in
+ * include/linux/migrate.h
+ *
+ * After the alloc_and_copy() callback, this function goes over each entry in
+ * the src array that has the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag
+ * set. If the corresponding entry in dst array has MIGRATE_PFN_VALID flag set,
+ * then the function tries to migrate struct page information from the source
+ * struct page to the destination struct page. If it fails to migrate the struct
+ * page information, then it clears the MIGRATE_PFN_MIGRATE flag in the src
+ * array.
+ *
+ * At this point all successfully migrated pages have an entry in the src
+ * array with MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set and the dst
+ * array entry with MIGRATE_PFN_VALID flag set.
+ *
+ * It then calls the finalize_and_map() callback. See comments for "struct
+ * migrate_vma_ops", in include/linux/migrate.h for details about
+ * finalize_and_map() behavior.
+ *
+ * After the finalize_and_map() callback, for successfully migrated pages, this
+ * function updates the CPU page table to point to new pages, otherwise it
+ * restores the CPU page table to point to the original source pages.
+ *
+ * Function returns 0 after the above steps, even if no pages were migrated
+ * (The function only returns an error if any of the arguments are invalid.)
+ *
+ * Both src and dst array must be big enough for (end - start) >> PAGE_SHIFT
+ * unsigned long entries.
+ */
+int migrate_vma(const struct migrate_vma_ops *ops,
+		struct vm_area_struct *vma,
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
+	 * At this point pages are locked and unmapped, and thus they have
+	 * stable content and can safely be copied to destination memory that
+	 * is allocated by the callback.
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
