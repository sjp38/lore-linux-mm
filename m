Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 845F86B03A3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 16:29:16 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q54so6817505qta.7
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 13:29:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l1si3636242qtd.17.2017.04.07.13.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 13:29:14 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC HMM CDM 3/3] mm/migrate: memory migration using a device DMA engine
Date: Fri,  7 Apr 2017 16:28:53 -0400
Message-Id: <1491596933-21669-4-git-send-email-jglisse@redhat.com>
In-Reply-To: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
References: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <balbir@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This reuse most of migrate_vma() infrastructure and generalize it
so that you can move any array of page using device DMA.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm.h     |   7 +-
 include/linux/migrate.h |  40 +++---
 mm/hmm.c                |  16 +--
 mm/migrate.c            | 364 +++++++++++++++++++++++++-----------------------
 4 files changed, 219 insertions(+), 208 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e4fda18..eff17d3 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -398,14 +398,11 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 void hmm_devmem_remove(struct hmm_devmem *devmem);
 
 int hmm_devmem_fault_range(struct hmm_devmem *devmem,
+			   struct migrate_dma_ctx *migrate_ctx,
 			   struct vm_area_struct *vma,
-			   const struct migrate_vma_ops *ops,
-			   unsigned long *src,
-			   unsigned long *dst,
 			   unsigned long start,
 			   unsigned long addr,
-			   unsigned long end,
-			   void *private);
+			   unsigned long end);
 
 /*
  * hmm_devmem_page_set_drvdata - set per-page driver data field
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 7dd875a..fa7f53a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -141,7 +141,8 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_WRITE	(1UL << 3)
 #define MIGRATE_PFN_DEVICE	(1UL << 4)
 #define MIGRATE_PFN_ERROR	(1UL << 5)
-#define MIGRATE_PFN_SHIFT	6
+#define MIGRATE_PFN_LRU		(1UL << 6)
+#define MIGRATE_PFN_SHIFT	7
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
 {
@@ -155,8 +156,10 @@ static inline unsigned long migrate_pfn(unsigned long pfn)
 	return (pfn << MIGRATE_PFN_SHIFT) | MIGRATE_PFN_VALID;
 }
 
+struct migrate_dma_ctx;
+
 /*
- * struct migrate_vma_ops - migrate operation callback
+ * struct migrate_dma_ops - migrate operation callback
  *
  * @alloc_and_copy: alloc destination memory and copy source memory to it
  * @finalize_and_map: allow caller to map the successfully migrated pages
@@ -212,28 +215,25 @@ static inline unsigned long migrate_pfn(unsigned long pfn)
  * THE finalize_and_map() CALLBACK MUST NOT CHANGE ANY OF THE SRC OR DST ARRAY
  * ENTRIES OR BAD THINGS WILL HAPPEN !
  */
-struct migrate_vma_ops {
-	void (*alloc_and_copy)(struct vm_area_struct *vma,
-			       const unsigned long *src,
-			       unsigned long *dst,
-			       unsigned long start,
-			       unsigned long end,
-			       void *private);
-	void (*finalize_and_map)(struct vm_area_struct *vma,
-				 const unsigned long *src,
-				 const unsigned long *dst,
-				 unsigned long start,
-				 unsigned long end,
-				 void *private);
+struct migrate_dma_ops {
+	void (*alloc_and_copy)(struct migrate_dma_ctx *ctx);
+	void (*finalize_and_map)(struct migrate_dma_ctx *ctx);
+};
+
+struct migrate_dma_ctx {
+	const struct migrate_dma_ops	*ops;
+	unsigned long			*dst;
+	unsigned long			*src;
+	unsigned long			cpages;
+	unsigned long			npages;
 };
 
-int migrate_vma(const struct migrate_vma_ops *ops,
+int migrate_vma(struct migrate_dma_ctx *ctx,
 		struct vm_area_struct *vma,
 		unsigned long start,
-		unsigned long end,
-		unsigned long *src,
-		unsigned long *dst,
-		void *private);
+		unsigned long end);
+int migrate_dma(struct migrate_dma_ctx *migrate_ctx);
+
 
 #endif /* CONFIG_MIGRATION */
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 28c7fcb..c14aca5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1131,14 +1131,11 @@ EXPORT_SYMBOL(hmm_devmem_remove);
  * hmm_devmem_fault_range() - migrate back a virtual range of memory
  *
  * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE memory
+ * @migrate_ctx: migrate context structure
  * @vma: virtual memory area containing the range to be migrated
- * @ops: migration callback for allocating destination memory and copying
- * @src: array of unsigned long containing source pfns
- * @dst: array of unsigned long containing destination pfns
  * @start: start address of the range to migrate (inclusive)
  * @addr: fault address (must be inside the range)
  * @end: end address of the range to migrate (exclusive)
- * @private: pointer passed back to each of the callback
  * Returns: 0 on success, VM_FAULT_SIGBUS on error
  *
  * This is a wrapper around migrate_vma() which checks the migration status
@@ -1149,16 +1146,15 @@ EXPORT_SYMBOL(hmm_devmem_remove);
  * This is a helper intendend to be used by the ZONE_DEVICE fault handler.
  */
 int hmm_devmem_fault_range(struct hmm_devmem *devmem,
+			   struct migrate_dma_ctx *migrate_ctx,
 			   struct vm_area_struct *vma,
-			   const struct migrate_vma_ops *ops,
-			   unsigned long *src,
-			   unsigned long *dst,
 			   unsigned long start,
 			   unsigned long addr,
-			   unsigned long end,
-			   void *private)
+			   unsigned long end)
 {
-	if (migrate_vma(ops, vma, start, end, src, dst, private))
+	unsigned long *dst = migrate_ctx->dst;
+
+	if (migrate_vma(migrate_ctx, vma, start, end))
 		return VM_FAULT_SIGBUS;
 
 	if (dst[(addr - start) >> PAGE_SHIFT] & MIGRATE_PFN_ERROR)
diff --git a/mm/migrate.c b/mm/migrate.c
index 2497357..5f252d6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2100,27 +2100,17 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #endif /* CONFIG_NUMA */
 
 
-struct migrate_vma {
-	struct vm_area_struct	*vma;
-	unsigned long		*dst;
-	unsigned long		*src;
-	unsigned long		cpages;
-	unsigned long		npages;
-	unsigned long		start;
-	unsigned long		end;
-};
-
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
 				    struct mm_walk *walk)
 {
-	struct migrate_vma *migrate = walk->private;
+	struct migrate_dma_ctx *migrate_ctx = walk->private;
 	unsigned long addr;
 
 	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
-		migrate->cpages++;
-		migrate->dst[migrate->npages] = 0;
-		migrate->src[migrate->npages++] = 0;
+		migrate_ctx->cpages++;
+		migrate_ctx->dst[migrate_ctx->npages] = 0;
+		migrate_ctx->src[migrate_ctx->npages++] = 0;
 	}
 
 	return 0;
@@ -2131,7 +2121,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 				   unsigned long end,
 				   struct mm_walk *walk)
 {
-	struct migrate_vma *migrate = walk->private;
+	struct migrate_dma_ctx *migrate_ctx = walk->private;
 	struct mm_struct *mm = walk->vma->vm_mm;
 	unsigned long addr = start, unmapped = 0;
 	spinlock_t *ptl;
@@ -2155,7 +2145,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pfn = pte_pfn(pte);
 
 		if (pte_none(pte)) {
-			migrate->cpages++;
+			migrate_ctx->cpages++;
 			mpfn = pfn = 0;
 			goto next;
 		}
@@ -2178,7 +2168,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			if (is_write_device_entry(entry))
 				mpfn |= MIGRATE_PFN_WRITE;
 		} else {
-			page = vm_normal_page(migrate->vma, addr, pte);
+			page = vm_normal_page(walk->vma, addr, pte);
 			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
 			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 		}
@@ -2200,7 +2190,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		 * can't be dropped from it).
 		 */
 		get_page(page);
-		migrate->cpages++;
+		migrate_ctx->cpages++;
 
 		/*
 		 * Optimize for the common case where page is only mapped once
@@ -2231,8 +2221,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		}
 
 next:
-		migrate->dst[migrate->npages] = 0;
-		migrate->src[migrate->npages++] = mpfn;
+		migrate_ctx->dst[migrate_ctx->npages] = 0;
+		migrate_ctx->src[migrate_ctx->npages++] = mpfn;
 	}
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(ptep - 1, ptl);
@@ -2252,7 +2242,10 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
  * valid page, it updates the src array and takes a reference on the page, in
  * order to pin the page until we lock it and unmap it.
  */
-static void migrate_vma_collect(struct migrate_vma *migrate)
+static void migrate_vma_collect(struct migrate_dma_ctx *migrate_ctx,
+				struct vm_area_struct *vma,
+				unsigned long start,
+				unsigned long end)
 {
 	struct mm_walk mm_walk;
 
@@ -2261,30 +2254,24 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mm_walk.pte_hole = migrate_vma_collect_hole;
 	mm_walk.hugetlb_entry = NULL;
 	mm_walk.test_walk = NULL;
-	mm_walk.vma = migrate->vma;
-	mm_walk.mm = migrate->vma->vm_mm;
-	mm_walk.private = migrate;
-
-	mmu_notifier_invalidate_range_start(mm_walk.mm,
-					    migrate->start,
-					    migrate->end);
-	walk_page_range(migrate->start, migrate->end, &mm_walk);
-	mmu_notifier_invalidate_range_end(mm_walk.mm,
-					  migrate->start,
-					  migrate->end);
-
-	migrate->end = migrate->start + (migrate->npages << PAGE_SHIFT);
+	mm_walk.vma = vma;
+	mm_walk.mm = vma->vm_mm;
+	mm_walk.private = migrate_ctx;
+
+	mmu_notifier_invalidate_range_start(mm_walk.mm, start, end);
+	walk_page_range(start, end, &mm_walk);
+	mmu_notifier_invalidate_range_end(mm_walk.mm, start, end);
 }
 
 /*
- * migrate_vma_check_page() - check if page is pinned or not
+ * migrate_dma_check_page() - check if page is pinned or not
  * @page: struct page to check
  *
  * Pinned pages cannot be migrated. This is the same test as in
  * migrate_page_move_mapping(), except that here we allow migration of a
  * ZONE_DEVICE page.
  */
-static bool migrate_vma_check_page(struct page *page)
+static bool migrate_dma_check_page(struct page *page)
 {
 	/*
 	 * One extra ref because caller holds an extra reference, either from
@@ -2318,34 +2305,31 @@ static bool migrate_vma_check_page(struct page *page)
 }
 
 /*
- * migrate_vma_prepare() - lock pages and isolate them from the lru
- * @migrate: migrate struct containing all migration information
+ * migrate_dma_prepare() - lock pages and isolate them from the lru
+ * @migrate_ctx: migrate struct containing all migration information
  *
  * This locks pages that have been collected by migrate_vma_collect(). Once each
  * page is locked it is isolated from the lru (for non-device pages). Finally,
  * the ref taken by migrate_vma_collect() is dropped, as locked pages cannot be
  * migrated by concurrent kernel threads.
  */
-static void migrate_vma_prepare(struct migrate_vma *migrate)
+static unsigned long migrate_dma_prepare(struct migrate_dma_ctx *migrate_ctx)
 {
-	const unsigned long npages = migrate->npages;
-	const unsigned long start = migrate->start;
-	unsigned long addr, i, restore = 0;
+	const unsigned long npages = migrate_ctx->npages;
+	unsigned long i, restore = 0;
 	bool allow_drain = true;
 
 	lru_add_drain();
 
 	for (i = 0; i < npages; i++) {
-		struct page *page = migrate_pfn_to_page(migrate->src[i]);
-		bool remap = true;
+		struct page *page = migrate_pfn_to_page(migrate_ctx->src[i]);
 
 		if (!page)
 			continue;
 
-		if (!(migrate->src[i] & MIGRATE_PFN_LOCKED)) {
-			remap = false;
+		if (!(migrate_ctx->src[i] & MIGRATE_PFN_LOCKED)) {
 			lock_page(page);
-			migrate->src[i] |= MIGRATE_PFN_LOCKED;
+			migrate_ctx->src[i] |= MIGRATE_PFN_LOCKED;
 		}
 
 		/* ZONE_DEVICE pages are not on LRU */
@@ -2357,64 +2341,34 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
 			}
 
 			if (isolate_lru_page(page)) {
-				if (remap) {
-					migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
-					migrate->cpages--;
-					restore++;
-				} else {
-					migrate->src[i] = 0;
-					unlock_page(page);
-					migrate->cpages--;
-					put_page(page);
-				}
+				migrate_ctx->src[i] &= ~MIGRATE_PFN_MIGRATE;
+				migrate_ctx->cpages--;
+				restore++;
 				continue;
 			}
 
 			/* Drop the reference we took in collect */
+			migrate_ctx->src[i] |= MIGRATE_PFN_LRU;
 			put_page(page);
 		}
 
-		if (!migrate_vma_check_page(page)) {
-			if (remap) {
-				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
-				migrate->cpages--;
-				restore++;
-
-				if (!is_zone_device_page(page)) {
-					get_page(page);
-					putback_lru_page(page);
-				}
-			} else {
-				migrate->src[i] = 0;
-				unlock_page(page);
-				migrate->cpages--;
-
-				if (!is_zone_device_page(page))
-					putback_lru_page(page);
-				else
-					put_page(page);
-			}
+		/*
+		 * This is not the final check, it is an early check to avoid
+		 * unecessary work if the page is pined.
+		 */
+		if (!migrate_dma_check_page(page)) {
+			migrate_ctx->src[i] &= ~MIGRATE_PFN_MIGRATE;
+			migrate_ctx->cpages--;
+			restore++;
 		}
 	}
 
-	for (i = 0, addr = start; i < npages && restore; i++, addr += PAGE_SIZE) {
-		struct page *page = migrate_pfn_to_page(migrate->src[i]);
-
-		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
-			continue;
-
-		remove_migration_pte(page, migrate->vma, addr, page);
-
-		migrate->src[i] = 0;
-		unlock_page(page);
-		put_page(page);
-		restore--;
-	}
+	return restore;
 }
 
 /*
- * migrate_vma_unmap() - replace page mapping with special migration pte entry
- * @migrate: migrate struct containing all migration information
+ * migrate_dma_unmap() - replace page mapping with special migration pte entry
+ * @migrate_ctx: migrate struct containing migration context informations
  *
  * Replace page mapping (CPU page table pte) with a special migration pte entry
  * and check again if it has been pinned. Pinned pages are restored because we
@@ -2423,17 +2377,16 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
  * This is the last step before we call the device driver callback to allocate
  * destination memory and copy contents of original page over to new page.
  */
-static void migrate_vma_unmap(struct migrate_vma *migrate)
+static unsigned long migrate_dma_unmap(struct migrate_dma_ctx *migrate_ctx)
 {
 	int flags = TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
-	const unsigned long npages = migrate->npages;
-	const unsigned long start = migrate->start;
-	unsigned long addr, i, restore = 0;
+	const unsigned long npages = migrate_ctx->npages;
+	unsigned long i, restore = 0;
 
 	for (i = 0; i < npages; i++) {
-		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		struct page *page = migrate_pfn_to_page(migrate_ctx->src[i]);
 
-		if (!page || !(migrate->src[i] & MIGRATE_PFN_MIGRATE))
+		if (!page || !(migrate_ctx->src[i] & MIGRATE_PFN_MIGRATE))
 			continue;
 
 		if (page_mapped(page)) {
@@ -2442,41 +2395,24 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 				goto restore;
 		}
 
-		if (migrate_vma_check_page(page))
+		if (migrate_dma_check_page(page))
 			continue;
 
 restore:
-		migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
-		migrate->cpages--;
+		migrate_ctx->src[i] &= ~MIGRATE_PFN_MIGRATE;
+		migrate_ctx->cpages--;
 		restore++;
 	}
 
-	for (addr = start, i = 0; i < npages && restore; addr += PAGE_SIZE, i++) {
-		struct page *page = migrate_pfn_to_page(migrate->src[i]);
-
-		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
-			continue;
-
-		remove_migration_ptes(page, page, false);
-
-		migrate->src[i] = 0;
-		unlock_page(page);
-		restore--;
-
-		if (is_zone_device_page(page))
-			put_page(page);
-		else
-			putback_lru_page(page);
-	}
+	return restore;
 }
 
-static void migrate_vma_insert_page(struct migrate_vma *migrate,
+static void migrate_vma_insert_page(struct vm_area_struct *vma,
 				    unsigned long addr,
 				    struct page *page,
 				    unsigned long *src,
 				    unsigned long *dst)
 {
-	struct vm_area_struct *vma = migrate->vma;
 	struct mm_struct *mm = vma->vm_mm;
 	struct mem_cgroup *memcg;
 	spinlock_t *ptl;
@@ -2579,33 +2515,35 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
 }
 
 /*
- * migrate_vma_pages() - migrate meta-data from src page to dst page
- * @migrate: migrate struct containing all migration information
+ * migrate_dma_pages() - migrate meta-data from src page to dst page
+ * @migrate_ctx: migrate struct containing migration context informations
  *
  * This migrates struct page meta-data from source struct page to destination
  * struct page. This effectively finishes the migration from source page to the
  * destination page.
  */
-static void migrate_vma_pages(struct migrate_vma *migrate)
+static void migrate_dma_pages(struct migrate_dma_ctx *migrate_ctx,
+			      struct vm_area_struct *vma,
+			      unsigned long start,
+			      unsigned long end)
 {
-	const unsigned long npages = migrate->npages;
-	const unsigned long start = migrate->start;
+	const unsigned long npages = migrate_ctx->npages;
 	unsigned long addr, i;
 
-	for (i = 0, addr = start; i < npages; addr += PAGE_SIZE, i++) {
-		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
-		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+	for (i = 0, addr = start; i < npages; i++, addr += PAGE_SIZE) {
+		struct page *newpage = migrate_pfn_to_page(migrate_ctx->dst[i]);
+		struct page *page = migrate_pfn_to_page(migrate_ctx->src[i]);
 		struct address_space *mapping;
 		int r;
 
 		if (!newpage) {
-			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+			migrate_ctx->src[i] &= ~MIGRATE_PFN_MIGRATE;
 			continue;
-		} else if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE)) {
+		} else if (vma && !(migrate_ctx->src[i] & MIGRATE_PFN_MIGRATE)) {
 			if (!page)
-				migrate_vma_insert_page(migrate, addr, newpage,
-							&migrate->src[i],
-							&migrate->dst[i]);
+				migrate_vma_insert_page(vma, addr, newpage,
+							&migrate_ctx->src[i],
+							&migrate_ctx->dst[i]);
 			continue;
 		}
 
@@ -2618,7 +2556,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 				 * migrating to un-addressable device memory.
 				 */
 				if (mapping) {
-					migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+					migrate_ctx->src[i] &= ~MIGRATE_PFN_MIGRATE;
 					continue;
 				}
 			} else if (is_device_cache_coherent_page(newpage)) {
@@ -2632,19 +2570,19 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 				 * Other types of ZONE_DEVICE page are not
 				 * supported.
 				 */
-				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+				migrate_ctx->src[i] &= ~MIGRATE_PFN_MIGRATE;
 				continue;
 			}
 		}
 
 		r = migrate_page(mapping, newpage, page, MIGRATE_SYNC_NO_COPY);
 		if (r != MIGRATEPAGE_SUCCESS)
-			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+			migrate_ctx->src[i] &= ~MIGRATE_PFN_MIGRATE;
 	}
 }
 
 /*
- * migrate_vma_finalize() - restore CPU page table entry
+ * migrate_dma_finalize() - restore CPU page table entry
  * @migrate: migrate struct containing all migration information
  *
  * This replaces the special migration pte entry with either a mapping to the
@@ -2654,14 +2592,14 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
  * This also unlocks the pages and puts them back on the lru, or drops the extra
  * refcount, for device pages.
  */
-static void migrate_vma_finalize(struct migrate_vma *migrate)
+static void migrate_dma_finalize(struct migrate_dma_ctx *migrate_ctx)
 {
-	const unsigned long npages = migrate->npages;
+	const unsigned long npages = migrate_ctx->npages;
 	unsigned long i;
 
 	for (i = 0; i < npages; i++) {
-		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
-		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		struct page *newpage = migrate_pfn_to_page(migrate_ctx->dst[i]);
+		struct page *page = migrate_pfn_to_page(migrate_ctx->src[i]);
 
 		if (!page) {
 			if (newpage) {
@@ -2671,7 +2609,7 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 			continue;
 		}
 
-		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE) || !newpage) {
+		if (!(migrate_ctx->src[i] & MIGRATE_PFN_MIGRATE) || !newpage) {
 			if (newpage) {
 				unlock_page(newpage);
 				put_page(newpage);
@@ -2681,7 +2619,6 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 
 		remove_migration_ptes(page, newpage, false);
 		unlock_page(page);
-		migrate->cpages--;
 
 		if (is_zone_device_page(page))
 			put_page(page);
@@ -2698,16 +2635,42 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 	}
 }
 
+static void migrate_vma_restore(struct migrate_dma_ctx *migrate_ctx,
+				struct vm_area_struct *vma,
+				unsigned long restore,
+				unsigned long start,
+				unsigned long end)
+{
+	unsigned long addr = start, i = 0;
+
+	for (; i < migrate_ctx->npages && restore; addr += PAGE_SIZE, i++) {
+		bool lru = migrate_ctx->src[i] & MIGRATE_PFN_LRU;
+		struct page *page;
+
+		page = migrate_pfn_to_page(migrate_ctx->src[i]);
+		if (!page || (migrate_ctx->src[i] & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		remove_migration_ptes(page, page, false);
+
+		migrate_ctx->src[i] = 0;
+		unlock_page(page);
+		restore--;
+
+		if (!lru)
+			put_page(page);
+		else
+			putback_lru_page(page);
+	}
+}
+
 /*
  * migrate_vma() - migrate a range of memory inside vma
  *
- * @ops: migration callback for allocating destination memory and copying
+ * @migrate_ctx: migrate context structure
  * @vma: virtual memory area containing the range to be migrated
  * @start: start address of the range to migrate (inclusive)
  * @end: end address of the range to migrate (exclusive)
- * @src: array of hmm_pfn_t containing source pfns
- * @dst: array of hmm_pfn_t containing destination pfns
- * @private: pointer passed back to each of the callback
  * Returns: 0 on success, error code otherwise
  *
  * This function tries to migrate a range of memory virtual address range, using
@@ -2749,50 +2712,45 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
  * Both src and dst array must be big enough for (end - start) >> PAGE_SHIFT
  * unsigned long entries.
  */
-int migrate_vma(const struct migrate_vma_ops *ops,
+int migrate_vma(struct migrate_dma_ctx *migrate_ctx,
 		struct vm_area_struct *vma,
 		unsigned long start,
-		unsigned long end,
-		unsigned long *src,
-		unsigned long *dst,
-		void *private)
+		unsigned long end)
 {
-	struct migrate_vma migrate;
+	unsigned long npages, restore;
 
 	/* Sanity check the arguments */
 	start &= PAGE_MASK;
 	end &= PAGE_MASK;
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
 		return -EINVAL;
-	if (!vma || !ops || !src || !dst || start >= end)
+	if (!vma || !migrate_ctx || !migrate_ctx->src || !migrate_ctx->dst)
 		return -EINVAL;
-	if (start < vma->vm_start || start >= vma->vm_end)
+	if (start >= end || start < vma->vm_start || start >= vma->vm_end)
 		return -EINVAL;
 	if (end <= vma->vm_start || end > vma->vm_end)
 		return -EINVAL;
 
-	memset(src, 0, sizeof(*src) * ((end - start) >> PAGE_SHIFT));
-	migrate.src = src;
-	migrate.dst = dst;
-	migrate.start = start;
-	migrate.npages = 0;
-	migrate.cpages = 0;
-	migrate.end = end;
-	migrate.vma = vma;
+	migrate_ctx->npages = 0;
+	migrate_ctx->cpages = 0;
+	npages = (end - start) >> PAGE_SHIFT;
+	memset(migrate_ctx->src, 0, sizeof(*migrate_ctx->src) * npages);
 
 	/* Collect, and try to unmap source pages */
-	migrate_vma_collect(&migrate);
-	if (!migrate.cpages)
+	migrate_vma_collect(migrate_ctx, vma, start, end);
+	if (!migrate_ctx->cpages)
 		return 0;
 
 	/* Lock and isolate page */
-	migrate_vma_prepare(&migrate);
-	if (!migrate.cpages)
+	restore = migrate_dma_prepare(migrate_ctx);
+	migrate_vma_restore(migrate_ctx, vma, restore, start, end);
+	if (!migrate_ctx->cpages)
 		return 0;
 
 	/* Unmap pages */
-	migrate_vma_unmap(&migrate);
-	if (!migrate.cpages)
+	restore = migrate_dma_unmap(migrate_ctx);
+	migrate_vma_restore(migrate_ctx, vma, restore, start, end);
+	if (!migrate_ctx->cpages)
 		return 0;
 
 	/*
@@ -2803,16 +2761,76 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	 * Note that migration can fail in migrate_vma_struct_page() for each
 	 * individual page.
 	 */
-	ops->alloc_and_copy(vma, src, dst, start, end, private);
+	migrate_ctx->ops->alloc_and_copy(migrate_ctx);
 
 	/* This does the real migration of struct page */
-	migrate_vma_pages(&migrate);
+	migrate_dma_pages(migrate_ctx, vma, start, end);
 
-	ops->finalize_and_map(vma, src, dst, start, end, private);
+	migrate_ctx->ops->finalize_and_map(migrate_ctx);
 
 	/* Unlock and remap pages */
-	migrate_vma_finalize(&migrate);
+	migrate_dma_finalize(migrate_ctx);
 
 	return 0;
 }
 EXPORT_SYMBOL(migrate_vma);
+
+/*
+ * migrate_dma() - migrate an array of pages using a device DMA engine
+ *
+ * @migrate_ctx: migrate context structure
+ *
+ * The context structure must have its src fields pointing to an array of
+ * migrate pfn entry each corresponding to a valid page and each page being
+ * lock. The dst entry must by an array as big as src, it will be use during
+ * migration to store the destination pfn.
+ *
+ */
+int migrate_dma(struct migrate_dma_ctx *migrate_ctx)
+{
+	unsigned long i;
+
+	/* Sanity check the arguments */
+	if (!migrate_ctx->ops || !migrate_ctx->src || !migrate_ctx->dst)
+		return -EINVAL;
+
+	/* Below code should be hidden behind some DEBUG config */
+	for (i = 0; i < migrate_ctx->npages; ++i) {
+		const unsigned long mask = MIGRATE_PFN_VALID |
+					   MIGRATE_PFN_LOCKED;
+
+		if (!(migrate_ctx->src[i] & mask))
+			return -EINVAL;
+	}
+
+	/* Lock and isolate page */
+	migrate_dma_prepare(migrate_ctx);
+	if (!migrate_ctx->cpages)
+		return 0;
+
+	/* Unmap pages */
+	migrate_dma_unmap(migrate_ctx);
+	if (!migrate_ctx->cpages)
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
+	migrate_ctx->ops->alloc_and_copy(migrate_ctx);
+
+	/* This does the real migration of struct page */
+	migrate_dma_pages(migrate_ctx, NULL, 0, 0);
+
+	migrate_ctx->ops->finalize_and_map(migrate_ctx);
+
+	/* Unlock and remap pages */
+	migrate_dma_finalize(migrate_ctx);
+
+	return 0;
+}
+EXPORT_SYMBOL(migrate_dma);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
