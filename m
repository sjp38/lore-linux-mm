Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24BEC6B02A6
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g67so96026855qkd.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:08 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 123si14791833qkl.267.2016.09.26.08.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:07 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 03/12] mm: thp: add helpers related to thp/pmd migration
Date: Mon, 26 Sep 2016 11:22:25 -0400
Message-Id: <20160926152234.14809-4-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch prepares thp migration's core code. These code will be open when
unmap_and_move() stops unconditionally splitting thp and get_new_page() starts
to allocate destination thps.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/include/asm/pgtable.h    | 11 ++++++
 arch/x86/include/asm/pgtable_64.h |  2 +
 include/linux/swapops.h           | 62 +++++++++++++++++++++++++++++++
 mm/huge_memory.c                  | 77 +++++++++++++++++++++++++++++++++++++++
 mm/migrate.c                      | 23 ++++++++++++
 5 files changed, 175 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 437feb4..5ff861f 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -530,6 +530,17 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
 }
 
+/*
+ * Unlike pmd_present(), __pmd_present() checks only _PAGE_PRESENT bit.
+ * Combined with is_migration_entry(), this routine is used to detect pmd
+ * migration entries. To make it work fine, callers should make sure that
+ * pmd_trans_huge() returns true beforehand.
+ */
+static inline int __pmd_present(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_PRESENT;
+}
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * These work without NUMA balancing but the kernel does not care. See the
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 1cc82ec..3a1b48e 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -167,7 +167,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 					 ((type) << (SWP_TYPE_FIRST_BIT)) \
 					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
+#define __pmd_to_swp_entry(pte)		((swp_entry_t) { pmd_val((pmd)) })
 #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
+#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd = (x).val })
 
 extern int kern_addr_valid(unsigned long addr);
 extern void cleanup_highmap(void);
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 5c3a5f3..b402a2c 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -163,6 +163,68 @@ static inline int is_write_migration_entry(swp_entry_t entry)
 
 #endif
 
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+extern int set_pmd_migration_entry(struct page *page,
+		struct mm_struct *mm, unsigned long address);
+
+extern int remove_migration_pmd(struct page *new,
+		struct vm_area_struct *vma, unsigned long addr, void *old);
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
+	return !__pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd));
+}
+#else
+static inline int set_pmd_migration_entry(struct page *page,
+				struct mm_struct *mm, unsigned long address)
+{
+	return 0;
+}
+
+static inline int remove_migration_pmd(struct page *new,
+		struct vm_area_struct *vma, unsigned long addr, void *old)
+{
+	return 0;
+}
+
+static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t *p) { }
+
+static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
+{
+	return swp_entry(0, 0);
+}
+
+static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
+{
+	pmd_t pmd = {};
+
+	return pmd;
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
index a6abd76..0cd39ef 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2252,3 +2252,80 @@ static int __init split_huge_pages_debugfs(void)
 }
 late_initcall(split_huge_pages_debugfs);
 #endif
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+int set_pmd_migration_entry(struct page *page, struct mm_struct *mm,
+				unsigned long addr)
+{
+	pte_t *pte;
+	pmd_t *pmd;
+	pmd_t pmdval;
+	pmd_t pmdswp;
+	swp_entry_t entry;
+	spinlock_t *ptl;
+
+	mmu_notifier_invalidate_range_start(mm, addr, addr + HPAGE_PMD_SIZE);
+	if (!page_check_address_transhuge(page, mm, addr, &pmd, &pte, &ptl))
+		goto out;
+	if (pte)
+		goto out;
+	pmdval = pmdp_huge_get_and_clear(mm, addr, pmd);
+	entry = make_migration_entry(page, pmd_write(pmdval));
+	pmdswp = swp_entry_to_pmd(entry);
+	pmdswp = pmd_mkhuge(pmdswp);
+	set_pmd_at(mm, addr, pmd, pmdswp);
+	page_remove_rmap(page, true);
+	put_page(page);
+	spin_unlock(ptl);
+out:
+	mmu_notifier_invalidate_range_end(mm, addr, addr + HPAGE_PMD_SIZE);
+	return SWAP_AGAIN;
+}
+
+int remove_migration_pmd(struct page *new, struct vm_area_struct *vma,
+			unsigned long addr, void *old)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pmd_t pmde;
+	swp_entry_t entry;
+	unsigned long mmun_start = addr & HPAGE_PMD_MASK;
+	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		goto out;
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		goto out;
+	pmd = pmd_offset(pud, addr);
+	if (!pmd)
+		goto out;
+	ptl = pmd_lock(mm, pmd);
+	pmde = *pmd;
+	if (!is_pmd_migration_entry(pmde))
+		goto unlock_ptl;
+	entry = pmd_to_swp_entry(pmde);
+	if (migration_entry_to_page(entry) != old)
+		goto unlock_ptl;
+	get_page(new);
+	pmde = mk_huge_pmd(new, vma->vm_page_prot);
+	if (is_write_migration_entry(entry))
+		pmde = maybe_pmd_mkwrite(pmde, vma);
+	flush_cache_range(vma, mmun_start, mmun_end);
+	page_add_anon_rmap(new, vma, mmun_start, true);
+	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
+	set_pmd_at(mm, mmun_start, pmd, pmde);
+	flush_tlb_range(vma, mmun_start, mmun_end);
+	if (vma->vm_flags & VM_LOCKED)
+		mlock_vma_page(new);
+	update_mmu_cache_pmd(vma, addr, pmd);
+unlock_ptl:
+	spin_unlock(ptl);
+out:
+	return SWAP_AGAIN;
+}
+#endif
diff --git a/mm/migrate.c b/mm/migrate.c
index f7ee04a..95613e7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -207,6 +207,8 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		if (!ptep)
 			goto out;
 		ptl = huge_pte_lockptr(hstate_vma(vma), mm, ptep);
+	} else if (PageTransHuge(new)) {
+		return remove_migration_pmd(new, vma, addr, old);
 	} else {
 		pmd = mm_find_pmd(mm, addr);
 		if (!pmd)
@@ -344,6 +346,27 @@ void migration_entry_wait_huge(struct vm_area_struct *vma,
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
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
