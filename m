Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1526E6B03A4
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 16:48:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 7so16803174qtp.8
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 13:48:00 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 57si3538339qtr.65.2017.04.20.13.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 13:47:59 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v5 07/11] mm: soft-dirty: keep soft-dirty bits over thp migration
Date: Thu, 20 Apr 2017 16:47:48 -0400
Message-Id: <20170420204752.79703-8-zi.yan@sent.com>
In-Reply-To: <20170420204752.79703-1-zi.yan@sent.com>
References: <20170420204752.79703-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Soft dirty bit is designed to keep tracked over page migration. This patch
makes it work in the same manner for thp migration too.

---
ChangeLog v1 -> v2:
- separate diff moving _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1
- clear_soft_dirty_pmd can handle migration entry

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog v1 -> v5:
- read soft dirty bit from correct place (*src_pmd) in copy_huge_pmd()
- add missing soft dirty bit transfer in change_huge_pmd()

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/x86/include/asm/pgtable.h | 17 +++++++++++++++++
 fs/proc/task_mmu.c             | 27 ++++++++++++++++-----------
 include/asm-generic/pgtable.h  | 34 +++++++++++++++++++++++++++++++++-
 include/linux/swapops.h        |  2 ++
 mm/huge_memory.c               | 27 ++++++++++++++++++++++++---
 5 files changed, 92 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 998081ae84f2..3447fd7ddb10 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1104,6 +1104,23 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
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
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 57489dcd71c4..34913dede836 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -908,17 +908,22 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 {
 	pmd_t pmd = *pmdp;
 
-	/* See comment in change_huge_pmd() */
-	pmdp_invalidate(vma, addr, pmdp);
-	if (pmd_dirty(*pmdp))
-		pmd = pmd_mkdirty(pmd);
-	if (pmd_young(*pmdp))
-		pmd = pmd_mkyoung(pmd);
-
-	pmd = pmd_wrprotect(pmd);
-	pmd = pmd_clear_soft_dirty(pmd);
-
-	set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
+	if (pmd_present(pmd)) {
+		/* See comment in change_huge_pmd() */
+		pmdp_invalidate(vma, addr, pmdp);
+		if (pmd_dirty(*pmdp))
+			pmd = pmd_mkdirty(pmd);
+		if (pmd_young(*pmdp))
+			pmd = pmd_mkyoung(pmd);
+
+		pmd = pmd_wrprotect(pmd);
+		pmd = pmd_clear_soft_dirty(pmd);
+
+		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
+	} else if (is_migration_entry(pmd_to_swp_entry(pmd))) {
+		pmd = pmd_swp_clear_soft_dirty(pmd);
+		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
+	}
 }
 #else
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 23bf18116df4..5cd865ceb2cd 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -593,7 +593,24 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
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
@@ -638,6 +655,21 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
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
index c543c6f25e8f..c2f2efa45f3a 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -179,6 +179,8 @@ static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
 {
 	swp_entry_t arch_entry;
 
+	if (pmd_swp_soft_dirty(pmd))
+		pmd = pmd_swp_clear_soft_dirty(pmd);
 	arch_entry = __pmd_to_swp_entry(pmd);
 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3479e9caf2fa..cba64d0dc523 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -921,6 +921,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		if (is_write_migration_entry(entry)) {
 			make_migration_entry_read(&entry);
 			pmd = swp_entry_to_pmd(entry);
+			if (pmd_swp_soft_dirty(*src_pmd))
+				pmd = pmd_swp_mksoft_dirty(pmd);
 			set_pmd_at(src_mm, addr, src_pmd, pmd);
 		}
 		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
@@ -1706,6 +1708,17 @@ static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
 }
 #endif
 
+static pmd_t move_soft_dirty_pmd(pmd_t pmd)
+{
+#ifdef CONFIG_MEM_SOFT_DIRTY
+	if (unlikely(is_pmd_migration_entry(pmd)))
+		pmd = pmd_swp_mksoft_dirty(pmd);
+	else if (pmd_present(pmd))
+		pmd = pmd_mksoft_dirty(pmd);
+#endif
+	return pmd;
+}
+
 bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
 		  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
@@ -1748,7 +1761,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
 		}
-		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
+		pmd = move_soft_dirty_pmd(pmd);
+		set_pmd_at(mm, new_addr, new_pmd, pmd);
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
 		if (force_flush)
@@ -1793,6 +1807,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 			make_migration_entry_read(&entry);
 			newpmd = swp_entry_to_pmd(entry);
+			if (pmd_swp_soft_dirty(*pmd))
+				newpmd = pmd_swp_mksoft_dirty(newpmd);
 			set_pmd_at(mm, addr, pmd, newpmd);
 		}
 		goto unlock;
@@ -2743,6 +2759,7 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	unsigned long address = pvmw->address;
 	pmd_t pmdval;
 	swp_entry_t entry;
+	pmd_t pmdswp;
 
 	if (!(pvmw->pmd && !pvmw->pte))
 		return;
@@ -2755,8 +2772,10 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	if (pmd_dirty(pmdval))
 		set_page_dirty(page);
 	entry = make_migration_entry(page, pmd_write(pmdval));
-	pmdval = swp_entry_to_pmd(entry);
-	set_pmd_at(mm, address, pvmw->pmd, pmdval);
+	pmdswp = swp_entry_to_pmd(entry);
+	if (pmd_soft_dirty(pmdval))
+		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
+	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
 	page_remove_rmap(page, true);
 	put_page(page);
 
@@ -2780,6 +2799,8 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
 	entry = pmd_to_swp_entry(*pvmw->pmd);
 	get_page(new);
 	pmde = pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
+	if (pmd_swp_soft_dirty(*pvmw->pmd))
+		pmde = pmd_mksoft_dirty(pmde);
 	if (is_write_migration_entry(entry))
 		pmde = maybe_pmd_mkwrite(pmde, vma);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
