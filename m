Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 360AC6B0261
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:32:32 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so58131393pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:32 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id g80si33483475pfb.21.2016.11.07.15.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:31 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id y68so17348296pfb.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:31 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 08/12] mm: soft-dirty: keep soft-dirty bits over thp migration
Date: Tue,  8 Nov 2016 08:31:53 +0900
Message-Id: <1478561517-4317-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Soft dirty bit is designed to keep tracked over page migration. This patch
makes it work in the same manner for thp migration too.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1 -> v2:
- separate diff moving _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 6
- clear_soft_dirty_pmd can handle migration entry
---
 arch/x86/include/asm/pgtable.h | 17 +++++++++++++++++
 fs/proc/task_mmu.c             | 17 +++++++++++------
 include/asm-generic/pgtable.h  | 34 +++++++++++++++++++++++++++++++++-
 include/linux/swapops.h        |  2 ++
 mm/huge_memory.c               | 25 +++++++++++++++++++++++--
 5 files changed, 86 insertions(+), 9 deletions(-)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable.h
index 437feb4..ceec210 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable.h
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable.h
@@ -948,6 +948,23 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
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
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/fs/proc/task_mmu.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/fs/proc/task_mmu.c
index c1f9cf4..85745b9 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/fs/proc/task_mmu.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/fs/proc/task_mmu.c
@@ -900,12 +900,17 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
-	pmd_t pmd = pmdp_huge_get_and_clear(vma->vm_mm, addr, pmdp);
-
-	pmd = pmd_wrprotect(pmd);
-	pmd = pmd_clear_soft_dirty(pmd);
-
-	set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
+	pmd_t pmd = *pmdp;
+
+	if (pmd_present(pmd)) {
+		pmd = pmdp_huge_get_and_clear(vma->vm_mm, addr, pmdp);
+		pmd = pmd_wrprotect(pmd);
+		pmd = pmd_clear_soft_dirty(pmd);
+		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
+	} else if (is_migration_entry(pmd_to_swp_entry(pmd))) {
+		pmd = pmd_swp_clear_soft_dirty(pmd);
+		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
+	}
 }
 #else
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/asm-generic/pgtable.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/asm-generic/pgtable.h
index c4f8fd2..f50e8b4 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/include/asm-generic/pgtable.h
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/asm-generic/pgtable.h
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
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/swapops.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/swapops.h
index b6b22a2..db8a858 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/swapops.h
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/swapops.h
@@ -176,6 +176,8 @@ static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
 {
 	swp_entry_t arch_entry;
 
+	if (pmd_swp_soft_dirty(pmd))
+		pmd = pmd_swp_clear_soft_dirty(pmd);
 	arch_entry = __pmd_to_swp_entry(pmd);
 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
 }
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
index 4e9090c..bd9c23e 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
@@ -832,6 +832,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		if (is_write_migration_entry(entry)) {
 			make_migration_entry_read(&entry);
 			pmd = swp_entry_to_pmd(entry);
+			if (pmd_swp_soft_dirty(pmd))
+				pmd = pmd_swp_mksoft_dirty(pmd);
 			set_pmd_at(src_mm, addr, src_pmd, pmd);
 		}
 		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
@@ -1470,6 +1472,17 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
@@ -1510,7 +1523,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
 		}
-		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
+		pmd = move_soft_dirty_pmd(pmd);
+		set_pmd_at(mm, new_addr, new_pmd, pmd);
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
 		spin_unlock(old_ptl);
@@ -1556,6 +1570,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 				make_migration_entry_read(&entry);
 				newpmd = swp_entry_to_pmd(entry);
+				if (pmd_swp_soft_dirty(newpmd))
+					newpmd = pmd_swp_mksoft_dirty(newpmd);
 				set_pmd_at(mm, addr, pmd, newpmd);
 			}
 			goto unlock;
@@ -2408,7 +2424,8 @@ void set_pmd_migration_entry(struct page *page, struct vm_area_struct *vma,
 			set_page_dirty(page);
 		entry = make_migration_entry(page, pmd_write(pmdval));
 		pmdswp = swp_entry_to_pmd(entry);
-		pmdswp = pmd_mkhuge(pmdswp);
+		if (pmd_soft_dirty(pmdval))
+			pmdswp = pmd_swp_mksoft_dirty(pmdswp);
 		set_pmd_at(mm, addr, pmd, pmdswp);
 		page_remove_rmap(page, true);
 		put_page(page);
@@ -2434,6 +2451,8 @@ void set_pmd_migration_entry(struct page *page, struct vm_area_struct *vma,
 				set_page_dirty(tmp);
 			entry = make_migration_entry(tmp, pte_write(pteval));
 			swp_pte = swp_entry_to_pte(entry);
+			if (pte_soft_dirty(pteval))
+				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, address, pte, swp_pte);
 			page_remove_rmap(tmp, false);
 			put_page(tmp);
@@ -2466,6 +2485,8 @@ int remove_migration_pmd(struct page *new, pmd_t *pmd,
 				goto unlock_ptl;
 			get_page(new);
 			pmde = pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
+			if (pmd_swp_soft_dirty(*pmd))
+				pmde = pmd_mksoft_dirty(pmde);
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
