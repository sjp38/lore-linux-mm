Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8990B6B026A
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:35 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id g49so71814440qta.0
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:35 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id i85si23313013qkh.194.2017.02.05.08.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:34 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 08/14] mm: thp: enable thp migration in generic path
Date: Sun,  5 Feb 2017 11:12:46 -0500
Message-Id: <20170205161252.85004-9-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch adds thp migration's core code, including conversions
between a PMD entry and a swap entry, setting PMD migration entry,
removing PMD migration entry, and waiting on PMD migration entries.

This patch makes it possible to support thp migration.
If you fail to allocate a destination page as a thp, you just split
the source thp as we do now, and then enter the normal page migration.
If you succeed to allocate destination thp, you enter thp migration.
Subsequent patches actually enable thp migration for each caller of
page migration by allowing its get_new_page() callback to
allocate thps.

ChangeLog v1 -> v2:
- support pte-mapped thp, doubly-mapped thp

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog v2 -> v3:
- use page_vma_mapped_walk()

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/x86/include/asm/pgtable_64.h |   2 +
 include/linux/swapops.h           |  70 +++++++++++++++++-
 mm/huge_memory.c                  | 151 ++++++++++++++++++++++++++++++++++----
 mm/migrate.c                      |  29 +++++++-
 mm/page_vma_mapped.c              |  13 +++-
 mm/pgtable-generic.c              |   3 +-
 mm/rmap.c                         |  14 +++-
 7 files changed, 259 insertions(+), 23 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 768eccc85553..0277f7755f3a 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -182,7 +182,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 					 ((type) << (SWP_TYPE_FIRST_BIT)) \
 					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
+#define __pmd_to_swp_entry(pmd)		((swp_entry_t) { pmd_val((pmd)) })
 #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
+#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd = (x).val })
 
 extern int kern_addr_valid(unsigned long addr);
 extern void cleanup_highmap(void);
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 5c3a5f3e7eec..6625bea13869 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -103,7 +103,8 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
 #ifdef CONFIG_MIGRATION
 static inline swp_entry_t make_migration_entry(struct page *page, int write)
 {
-	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageLocked(compound_head(page)));
+
 	return swp_entry(write ? SWP_MIGRATION_WRITE : SWP_MIGRATION_READ,
 			page_to_pfn(page));
 }
@@ -126,7 +127,7 @@ static inline struct page *migration_entry_to_page(swp_entry_t entry)
 	 * Any use of migration entries may only occur while the
 	 * corresponding page is locked
 	 */
-	BUG_ON(!PageLocked(p));
+	BUG_ON(!PageLocked(compound_head(p)));
 	return p;
 }
 
@@ -163,6 +164,71 @@ static inline int is_write_migration_entry(swp_entry_t entry)
 
 #endif
 
+struct page_vma_mapped_walk;
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+extern void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
+		struct page *page);
+
+extern void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
+		struct page *new);
+
+extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd);
+
+static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
+{
+	swp_entry_t arch_entry;
+
+	arch_entry = __pmd_to_swp_entry(pmd);
+	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
+}
+
+static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
+{
+	swp_entry_t arch_entry;
+
+	arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
+	return __swp_entry_to_pmd(arch_entry);
+}
+
+static inline int is_pmd_migration_entry(pmd_t pmd)
+{
+	return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd));
+}
+#else
+static inline void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
+		struct page *page)
+{
+	BUILD_BUG();
+}
+
+static inline void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
+		struct page *new)
+{
+	BUILD_BUG();
+	return 0;
+}
+
+static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t *p) { }
+
+static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
+{
+	BUILD_BUG();
+	return swp_entry(0, 0);
+}
+
+static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
+{
+	BUILD_BUG();
+	return (pmd_t){ 0 };
+}
+
+static inline int is_pmd_migration_entry(pmd_t pmd)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_MEMORY_FAILURE
 
 extern atomic_long_t num_poisoned_pages __read_mostly;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6893c47428b6..fd54bbdc16cf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1613,20 +1613,51 @@ int __zap_huge_pmd_locked(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else {
-		struct page *page = pmd_page(orig_pmd);
-		page_remove_rmap(page, true);
-		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-		VM_BUG_ON_PAGE(!PageHead(page), page);
-		if (PageAnon(page)) {
-			pgtable_t pgtable;
-			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
-			pte_free(tlb->mm, pgtable);
-			atomic_long_dec(&tlb->mm->nr_ptes);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+		struct page *page;
+		int migration = 0;
+
+		if (!is_pmd_migration_entry(orig_pmd)) {
+			page = pmd_page(orig_pmd);
+			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+			VM_BUG_ON_PAGE(!PageHead(page), page);
+			page_remove_rmap(page, true);
+			if (PageAnon(page)) {
+				pgtable_t pgtable;
+
+				pgtable = pgtable_trans_huge_withdraw(tlb->mm,
+								      pmd);
+				pte_free(tlb->mm, pgtable);
+				atomic_long_dec(&tlb->mm->nr_ptes);
+				add_mm_counter(tlb->mm, MM_ANONPAGES,
+					       -HPAGE_PMD_NR);
+			} else {
+				if (arch_needs_pgtable_deposit())
+					zap_deposited_table(tlb->mm, pmd);
+				add_mm_counter(tlb->mm, MM_FILEPAGES,
+					       -HPAGE_PMD_NR);
+			}
 		} else {
-			if (arch_needs_pgtable_deposit())
-				zap_deposited_table(tlb->mm, pmd);
-			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+			swp_entry_t entry;
+
+			entry = pmd_to_swp_entry(orig_pmd);
+			page = pfn_to_page(swp_offset(entry));
+			if (PageAnon(page)) {
+				pgtable_t pgtable;
+
+				pgtable = pgtable_trans_huge_withdraw(tlb->mm,
+								      pmd);
+				pte_free(tlb->mm, pgtable);
+				atomic_long_dec(&tlb->mm->nr_ptes);
+				add_mm_counter(tlb->mm, MM_ANONPAGES,
+					       -HPAGE_PMD_NR);
+			} else {
+				if (arch_needs_pgtable_deposit())
+					zap_deposited_table(tlb->mm, pmd);
+				add_mm_counter(tlb->mm, MM_FILEPAGES,
+					       -HPAGE_PMD_NR);
+			}
+			free_swap_and_cache(entry); /* waring in failure? */
+			migration = 1;
 		}
 		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
 	}
@@ -2634,3 +2665,97 @@ static int __init split_huge_pages_debugfs(void)
 }
 late_initcall(split_huge_pages_debugfs);
 #endif
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
+		struct page *page)
+{
+	struct vm_area_struct *vma = pvmw->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long address = pvmw->address;
+	pmd_t pmdval;
+	swp_entry_t entry;
+
+	if (pvmw->pmd && !pvmw->pte) {
+		pmd_t pmdswp;
+
+		mmu_notifier_invalidate_range_start(mm, address,
+				address + HPAGE_PMD_SIZE);
+
+		flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
+		pmdval = pmdp_huge_clear_flush(vma, address, pvmw->pmd);
+		if (pmd_dirty(pmdval))
+			set_page_dirty(page);
+		entry = make_migration_entry(page, pmd_write(pmdval));
+		pmdswp = swp_entry_to_pmd(entry);
+		set_pmd_at(mm, address, pvmw->pmd, pmdswp);
+		page_remove_rmap(page, true);
+		put_page(page);
+
+		mmu_notifier_invalidate_range_end(mm, address,
+				address + HPAGE_PMD_SIZE);
+	} else { /* pte-mapped thp */
+		pte_t pteval;
+		struct page *subpage = page - page_to_pfn(page) + pte_pfn(*pvmw->pte);
+		pte_t swp_pte;
+
+		pteval = ptep_clear_flush(vma, address, pvmw->pte);
+		if (pte_dirty(pteval))
+			set_page_dirty(subpage);
+		entry = make_migration_entry(subpage, pte_write(pteval));
+		swp_pte = swp_entry_to_pte(entry);
+		set_pte_at(mm, address, pvmw->pte, swp_pte);
+		page_remove_rmap(subpage, false);
+		put_page(subpage);
+	}
+}
+
+void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
+{
+	struct vm_area_struct *vma = pvmw->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long address = pvmw->address;
+	swp_entry_t entry;
+
+	/* PMD-mapped THP  */
+	if (pvmw->pmd && !pvmw->pte) {
+		unsigned long mmun_start = address & HPAGE_PMD_MASK;
+		unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
+		pmd_t pmde;
+
+		entry = pmd_to_swp_entry(*pvmw->pmd);
+		get_page(new);
+		pmde = pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
+		if (is_write_migration_entry(entry))
+			pmde = maybe_pmd_mkwrite(pmde, vma);
+
+		flush_cache_range(vma, mmun_start, mmun_end);
+		page_add_anon_rmap(new, vma, mmun_start, true);
+		pmdp_huge_clear_flush_notify(vma, mmun_start, pvmw->pmd);
+		set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
+		flush_tlb_range(vma, mmun_start, mmun_end);
+		if (vma->vm_flags & VM_LOCKED)
+			mlock_vma_page(new);
+		update_mmu_cache_pmd(vma, address, pvmw->pmd);
+
+	} else { /* pte-mapped thp */
+		pte_t pte;
+		pte_t *ptep = pvmw->pte;
+
+		entry = pte_to_swp_entry(*pvmw->pte);
+		get_page(new);
+		pte = pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
+		if (pte_swp_soft_dirty(*pvmw->pte))
+			pte = pte_mksoft_dirty(pte);
+		if (is_write_migration_entry(entry))
+			pte = maybe_mkwrite(pte, vma);
+		flush_dcache_page(new);
+		set_pte_at(mm, address, ptep, pte);
+		if (PageAnon(new))
+			page_add_anon_rmap(new, vma, address, false);
+		else
+			page_add_file_rmap(new, false);
+		update_mmu_cache(vma, address, ptep);
+	}
+}
+#endif
diff --git a/mm/migrate.c b/mm/migrate.c
index 95e8580dc902..84181a3668c6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -214,6 +214,12 @@ static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		new = page - pvmw.page->index +
 			linear_page_index(vma, pvmw.address);
 
+		/* PMD-mapped THP migration entry */
+		if (!PageHuge(page) && PageTransCompound(page)) {
+			remove_migration_pmd(&pvmw, new);
+			continue;
+		}
+
 		get_page(new);
 		pte = pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
 		if (pte_swp_soft_dirty(*pvmw.pte))
@@ -327,6 +333,27 @@ void migration_entry_wait_huge(struct vm_area_struct *vma,
 	__migration_entry_wait(mm, pte, ptl);
 }
 
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
+{
+	spinlock_t *ptl;
+	struct page *page;
+
+	ptl = pmd_lock(mm, pmd);
+	if (!is_pmd_migration_entry(*pmd))
+		goto unlock;
+	page = migration_entry_to_page(pmd_to_swp_entry(*pmd));
+	if (!get_page_unless_zero(page))
+		goto unlock;
+	spin_unlock(ptl);
+	wait_on_page_locked(page);
+	put_page(page);
+	return;
+unlock:
+	spin_unlock(ptl);
+}
+#endif
+
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
 static bool buffer_migrate_lock_buffers(struct buffer_head *head,
@@ -1085,7 +1112,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		goto out;
 	}
 
-	if (unlikely(PageTransHuge(page))) {
+	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
 		lock_page(page);
 		rc = split_huge_page(page);
 		unlock_page(page);
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index a23001a22c15..0ed3aee62d50 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -137,16 +137,23 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	if (!pud_present(*pud))
 		return false;
 	pvmw->pmd = pmd_offset(pud, pvmw->address);
-	if (pmd_trans_huge(*pvmw->pmd)) {
+	if (pmd_trans_huge(*pvmw->pmd) || is_pmd_migration_entry(*pvmw->pmd)) {
 		pvmw->ptl = pmd_lock(mm, pvmw->pmd);
-		if (!pmd_present(*pvmw->pmd))
-			return not_found(pvmw);
 		if (likely(pmd_trans_huge(*pvmw->pmd))) {
 			if (pvmw->flags & PVMW_MIGRATION)
 				return not_found(pvmw);
 			if (pmd_page(*pvmw->pmd) != page)
 				return not_found(pvmw);
 			return true;
+		} else if (!pmd_present(*pvmw->pmd)) {
+			if (unlikely(is_migration_entry(pmd_to_swp_entry(*pvmw->pmd)))) {
+				swp_entry_t entry = pmd_to_swp_entry(*pvmw->pmd);
+
+				if (migration_entry_to_page(entry) != page)
+					return not_found(pvmw);
+				return true;
+			}
+			return not_found(pvmw);
 		} else {
 			/* THP pmd was split under us: handle on pte level */
 			spin_unlock(pvmw->ptl);
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 4ed5908c65b0..9d550a8a0c71 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -118,7 +118,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
 {
 	pmd_t pmd;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
+	VM_BUG_ON(pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
+		  !pmd_devmap(*pmdp));
 	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
 	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
diff --git a/mm/rmap.c b/mm/rmap.c
index 16789b936e3a..b33216668fa4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1304,6 +1304,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	struct rmap_private *rp = arg;
 	enum ttu_flags flags = rp->flags;
 
+
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		return SWAP_AGAIN;
@@ -1314,12 +1315,19 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	while (page_vma_mapped_walk(&pvmw)) {
+		/* THP migration */
+		if (flags & TTU_MIGRATION) {
+			if (!PageHuge(page) && PageTransCompound(page)) {
+				set_pmd_migration_entry(&pvmw, page);
+				continue;
+			}
+		}
+		/* Unexpected PMD-mapped THP */
+		VM_BUG_ON_PAGE(!pvmw.pte, page);
+
 		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
 		address = pvmw.address;
 
-		/* Unexpected PMD-mapped THP? */
-		VM_BUG_ON_PAGE(!pvmw.pte, page);
-
 		/*
 		 * If the page is mlock()d, we cannot swap it out.
 		 * If it's recently referenced (perhaps page_referenced
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
