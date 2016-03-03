Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0CD6B0259
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:23 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id w128so10377013pfb.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:23 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id n21si1766057pfi.104.2016.03.02.23.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:22 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id 124so10269807pfg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:22 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 06/11] mm: soft-dirty: keep soft-dirty bits over thp migration
Date: Thu,  3 Mar 2016 16:41:53 +0900
Message-Id: <1456990918-30906-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

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

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable.h
index 0df9afe..e3da9fe 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable.h
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable.h
@@ -920,6 +920,23 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
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
 
 #include <asm-generic/pgtable.h>
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable_types.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable_types.h
index 4432ab7..a5d5e43 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable_types.h
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable_types.h
@@ -71,14 +71,14 @@
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
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/include/asm-generic/pgtable.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/asm-generic/pgtable.h
index 9401f48..1b0d610 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/include/asm-generic/pgtable.h
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/asm-generic/pgtable.h
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
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/swapops.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/swapops.h
index b402a2c..18f3744 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/swapops.h
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/swapops.h
@@ -176,6 +176,8 @@ static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
 {
 	swp_entry_t arch_entry;
 
+	if (pmd_swp_soft_dirty(pmd))
+		pmd = pmd_swp_clear_soft_dirty(pmd);
 	arch_entry = __pmd_to_swp_entry(pmd);
 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
 }
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/huge_memory.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/huge_memory.c
index 7120036..a3f98ea 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/huge_memory.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/huge_memory.c
@@ -1113,6 +1113,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		if (is_write_migration_entry(entry)) {
 			make_migration_entry_read(&entry);
 			pmd = swp_entry_to_pmd(entry);
+			if (pmd_swp_soft_dirty(pmd))
+				pmd = pmd_swp_mksoft_dirty(pmd);
 			set_pmd_at(src_mm, addr, src_pmd, pmd);
 		}
 		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
@@ -1733,6 +1735,17 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
 bool move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		  unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
@@ -1776,7 +1789,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
 		}
-		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
+		pmd = move_soft_dirty_pmd(pmd);
+		set_pmd_at(mm, new_addr, new_pmd, pmd);
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
 		spin_unlock(old_ptl);
@@ -1815,6 +1829,17 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
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
@@ -3730,6 +3755,8 @@ int set_pmd_migration_entry(struct page *page, struct mm_struct *mm,
 	entry = make_migration_entry(page, pmd_write(pmdval));
 	pmdswp = swp_entry_to_pmd(entry);
 	pmdswp = pmd_mkhuge(pmdswp);
+	if (pmd_soft_dirty(pmdval))
+		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
 	set_pmd_at(mm, addr, pmd, pmdswp);
 	page_remove_rmap(page, true);
 	page_cache_release(page);
@@ -3770,7 +3797,9 @@ int remove_migration_pmd(struct page *new, struct vm_area_struct *vma,
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
