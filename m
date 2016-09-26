Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 879646B02AA
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:11 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 16so306761091qtn.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:11 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id y190si14783497qke.276.2016.09.26.08.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:10 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 06/12] mm: soft-dirty: keep soft-dirty bits over thp migration
Date: Mon, 26 Sep 2016 11:22:28 -0400
Message-Id: <20160926152234.14809-7-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Soft dirty bit is designed to keep tracked over page migration, so this patch
makes it done for thp migration too.

This patch changes the bit for _PAGE_SWP_SOFT_DIRTY bit, because it's necessary
for thp migration (i.e. both of _PAGE_PSE and _PAGE_PRESENT is used to detect
pmd migration entry.) When soft-dirty was introduced, bit 6 was used for
nonlinear file mapping, but now that feature is replaced with emulation, so
we can relocate _PAGE_SWP_SOFT_DIRTY to bit 6.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/include/asm/pgtable.h       | 17 +++++++++++++++++
 arch/x86/include/asm/pgtable_types.h |  8 ++++----
 include/asm-generic/pgtable.h        | 34 +++++++++++++++++++++++++++++++++-
 include/linux/swapops.h              |  2 ++
 mm/huge_memory.c                     | 33 +++++++++++++++++++++++++++++++--
 5 files changed, 87 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5ff861f..4304776 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -959,6 +959,23 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_SWP_SOFT_DIRTY);
+}
+
+static inline int pmd_swp_soft_dirty(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_SWP_SOFT_DIRTY;
+}
+
+static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_SWP_SOFT_DIRTY);
+}
+#endif
 #endif
 
 #define PKRU_AD_BIT 0x1
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index f1218f5..a38e387 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -98,14 +98,14 @@
  * Tracking soft dirty bit when a page goes to a swap is tricky.
  * We need a bit which can be stored in pte _and_ not conflict
  * with swap entry format. On x86 bits 6 and 7 are *not* involved
- * into swap entry computation, but bit 6 is used for nonlinear
- * file mapping, so we borrow bit 7 for soft dirty tracking.
+ * into swap entry computation, but bit 7 is used for thp migration,
+ * so we borrow bit 6 for soft dirty tracking.
  *
  * Please note that this bit must be treated as swap dirty page
- * mark if and only if the PTE has present bit clear!
+ * mark if and only if the PTE/PMD has present bit clear!
  */
 #ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
+#define _PAGE_SWP_SOFT_DIRTY	_PAGE_DIRTY
 #else
 #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index d4458b6..fdc4793 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -489,7 +489,24 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
 #define arch_start_context_switch(prev)	do {} while (0)
 #endif
 
-#ifndef CONFIG_HAVE_ARCH_SOFT_DIRTY
+#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
+#ifndef CONFIG_ARCH_ENABLE_THP_MIGRATION
+static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
+{
+	return pmd;
+}
+
+static inline int pmd_swp_soft_dirty(pmd_t pmd)
+{
+	return 0;
+}
+
+static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
+{
+	return pmd;
+}
+#endif
+#else /* !CONFIG_HAVE_ARCH_SOFT_DIRTY */
 static inline int pte_soft_dirty(pte_t pte)
 {
 	return 0;
@@ -534,6 +551,21 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 {
 	return pte;
 }
+
+static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
+{
+	return pmd;
+}
+
+static inline int pmd_swp_soft_dirty(pmd_t pmd)
+{
+	return 0;
+}
+
+static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
+{
+	return pmd;
+}
 #endif
 
 #ifndef __HAVE_PFNMAP_TRACKING
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index b402a2c..18f3744 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -176,6 +176,8 @@ static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
 {
 	swp_entry_t arch_entry;
 
+	if (pmd_swp_soft_dirty(pmd))
+		pmd = pmd_swp_clear_soft_dirty(pmd);
 	arch_entry = __pmd_to_swp_entry(pmd);
 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f4fcfc7..1e1758b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -793,6 +793,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		if (is_write_migration_entry(entry)) {
 			make_migration_entry_read(&entry);
 			pmd = swp_entry_to_pmd(entry);
+			if (pmd_swp_soft_dirty(pmd))
+				pmd = pmd_swp_mksoft_dirty(pmd);
 			set_pmd_at(src_mm, addr, src_pmd, pmd);
 		}
 		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
@@ -1413,6 +1415,17 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return 1;
 }
 
+static pmd_t move_soft_dirty_pmd(pmd_t pmd)
+{
+#ifdef CONFIG_MEM_SOFT_DIRTY
+	if (unlikely(is_pmd_migration_entry(pmd)))
+		pmd = pmd_mksoft_dirty(pmd);
+	else if (pmd_present(pmd))
+		pmd = pmd_swp_mksoft_dirty(pmd);
+#endif
+	return pmd;
+}
+
 bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
 		  pmd_t *old_pmd, pmd_t *new_pmd)
@@ -1453,7 +1466,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
 		}
-		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
+		pmd = move_soft_dirty_pmd(pmd);
+		set_pmd_at(mm, new_addr, new_pmd, pmd);
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
 		spin_unlock(old_ptl);
@@ -1492,6 +1506,17 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		}
 
 		if (is_pmd_migration_entry(*pmd)) {
+			swp_entry_t entry = pmd_to_swp_entry(*pmd);
+
+			if (is_write_migration_entry(entry)) {
+				pmd_t newpmd;
+
+				make_migration_entry_read(&entry);
+				newpmd = swp_entry_to_pmd(entry);
+				if (pmd_swp_soft_dirty(newpmd))
+					newpmd = pmd_swp_mksoft_dirty(newpmd);
+				set_pmd_at(mm, addr, pmd, newpmd);
+			}
 			spin_unlock(ptl);
 			return ret;
 		}
@@ -2329,6 +2354,8 @@ int set_pmd_migration_entry(struct page *page, struct mm_struct *mm,
 	entry = make_migration_entry(page, pmd_write(pmdval));
 	pmdswp = swp_entry_to_pmd(entry);
 	pmdswp = pmd_mkhuge(pmdswp);
+	if (pmd_soft_dirty(pmdval))
+		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
 	set_pmd_at(mm, addr, pmd, pmdswp);
 	page_remove_rmap(page, true);
 	put_page(page);
@@ -2368,7 +2395,9 @@ int remove_migration_pmd(struct page *new, struct vm_area_struct *vma,
 	if (migration_entry_to_page(entry) != old)
 		goto unlock_ptl;
 	get_page(new);
-	pmde = mk_huge_pmd(new, vma->vm_page_prot);
+	pmde = pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
+	if (pmd_swp_soft_dirty(pmde))
+		pmde = pmd_mksoft_dirty(pmde);
 	if (is_write_migration_entry(entry))
 		pmde = maybe_pmd_mkwrite(pmde, vma);
 	flush_cache_range(vma, mmun_start, mmun_end);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
