Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3A15F6B0081
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:19:59 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so4775565wiw.9
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:19:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df6si6597295wib.106.2014.11.20.02.19.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:19:58 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/10] mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
Date: Thu, 20 Nov 2014 10:19:43 +0000
Message-Id: <1416478790-27522-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1416478790-27522-1-git-send-email-mgorman@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

Convert existing users of pte_numa and friends to the new helper. Note
that the kernel is broken after this patch is applied until the other
page table modifiers are also altered. This patch layout is to make
review easier.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/kvm/book3s_hv_rm_mmu.c |  2 +-
 arch/powerpc/mm/fault.c             |  5 -----
 arch/powerpc/mm/gup.c               |  4 ++--
 arch/powerpc/mm/pgtable.c           |  8 +++++++-
 arch/powerpc/mm/pgtable_64.c        |  3 ++-
 arch/x86/mm/gup.c                   |  4 ++--
 include/uapi/linux/mempolicy.h      |  2 +-
 mm/gup.c                            |  8 ++++----
 mm/huge_memory.c                    | 16 +++++++--------
 mm/memory.c                         |  4 ++--
 mm/mprotect.c                       | 39 ++++++++++---------------------------
 mm/pgtable-generic.c                |  2 +-
 12 files changed, 40 insertions(+), 57 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_rm_mmu.c b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
index 084ad54..bbd8499 100644
--- a/arch/powerpc/kvm/book3s_hv_rm_mmu.c
+++ b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
@@ -235,7 +235,7 @@ long kvmppc_do_h_enter(struct kvm *kvm, unsigned long flags,
 		pte_size = psize;
 		pte = lookup_linux_pte_and_update(pgdir, hva, writing,
 						  &pte_size);
-		if (pte_present(pte) && !pte_numa(pte)) {
+		if (pte_present(pte) && !pte_protnone_numa(pte)) {
 			if (writing && !pte_write(pte))
 				/* make the actual HPTE be read-only */
 				ptel = hpte_make_readonly(ptel);
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 08d659a..5007497 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -405,8 +405,6 @@ good_area:
 		 * processors use the same I/D cache coherency mechanism
 		 * as embedded.
 		 */
-		if (error_code & DSISR_PROTFAULT)
-			goto bad_area;
 #endif /* CONFIG_PPC_STD_MMU */
 
 		/*
@@ -430,9 +428,6 @@ good_area:
 		flags |= FAULT_FLAG_WRITE;
 	/* a read */
 	} else {
-		/* protection fault */
-		if (error_code & 0x08000000)
-			goto bad_area;
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)))
 			goto bad_area;
 	}
diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
index d874668..d870d93 100644
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -39,7 +39,7 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		/*
 		 * Similar to the PMD case, NUMA hinting must take slow path
 		 */
-		if (pte_numa(pte))
+		if (pte_protnone_numa(pte))
 			return 0;
 
 		if ((pte_val(pte) & mask) != result)
@@ -85,7 +85,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			 * slowpath for accounting purposes and so that they
 			 * can be serialised against THP migration.
 			 */
-			if (pmd_numa(pmd))
+			if (pmd_protnone_numa(pmd))
 				return 0;
 
 			if (!gup_hugepte((pte_t *)pmdp, PMD_SIZE, addr, next,
diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index c90e602..b5d58d3 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -173,7 +173,13 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 		pte_t pte)
 {
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON(pte_val(*ptep) & _PAGE_PRESENT);
+	/*
+	 * When handling numa faults, we already have the pte marked
+	 * _PAGE_PRESENT, but we can be sure that it is not in hpte.
+	 * Hence we can use set_pte_at for them.
+	 */
+	WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
+		(_PAGE_PRESENT | _PAGE_USER));
 #endif
 	/* Note: mm->context.id might not yet have been assigned as
 	 * this context might not have been activated yet when this
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index c8d709a..c721c5e 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -710,7 +710,8 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 		pmd_t *pmdp, pmd_t pmd)
 {
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON(pmd_val(*pmdp) & _PAGE_PRESENT);
+	WARN_ON((pmd_val(*pmdp) & (_PAGE_PRESENT | _PAGE_USER)) ==
+		(_PAGE_PRESENT | _PAGE_USER));
 	assert_spin_locked(&mm->page_table_lock);
 	WARN_ON(!pmd_trans_huge(pmd));
 #endif
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 207d9aef..47ce479 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -84,7 +84,7 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		struct page *page;
 
 		/* Similar to the PMD case, NUMA hinting must take slow path */
-		if (pte_numa(pte)) {
+		if (pte_protnone_numa(pte)) {
 			pte_unmap(ptep);
 			return 0;
 		}
@@ -178,7 +178,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			 * slowpath for accounting purposes and so that they
 			 * can be serialised against THP migration.
 			 */
-			if (pmd_numa(pmd))
+			if (pmd_protnone_numa(pmd))
 				return 0;
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
 				return 0;
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 0d11c3d..e52379b 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -67,7 +67,7 @@ enum mpol_rebind_step {
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
 #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
 #define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
-#define MPOL_F_MORON	(1 << 4) /* Migrate On pte_numa Reference On Node */
+#define MPOL_F_MORON	(1 << 4) /* Migrate On pte_protnone_numa Reference On Node */
 
 
 #endif /* _UAPI_LINUX_MEMPOLICY_H */
diff --git a/mm/gup.c b/mm/gup.c
index cd62c8c..aec34cb 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -64,7 +64,7 @@ retry:
 		migration_entry_wait(mm, pmd, address);
 		goto retry;
 	}
-	if ((flags & FOLL_NUMA) && pte_numa(pte))
+	if ((flags & FOLL_NUMA) && pte_protnone_numa(pte))
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte)) {
 		pte_unmap_unlock(ptep, ptl);
@@ -193,7 +193,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		}
 		return page;
 	}
-	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+	if ((flags & FOLL_NUMA) && pmd_protnone_numa(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_trans_huge(*pmd)) {
 		if (flags & FOLL_SPLIT) {
@@ -743,7 +743,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		 * path
 		 */
 		if (!pte_present(pte) || pte_special(pte) ||
-			pte_numa(pte) || (write && !pte_write(pte)))
+			pte_protnone_numa(pte) || (write && !pte_write(pte)))
 			goto pte_unmap;
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
@@ -895,7 +895,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			 * slowpath for accounting purposes and so that they
 			 * can be serialised against THP migration.
 			 */
-			if (pmd_numa(pmd))
+			if (pmd_protnone_numa(pmd))
 				return 0;
 
 			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 38fa6cc..ec0b424 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1223,7 +1223,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		return ERR_PTR(-EFAULT);
 
 	/* Full NUMA hinting faults to serialise migration in fault paths */
-	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+	if ((flags & FOLL_NUMA) && pmd_protnone_numa(*pmd))
 		goto out;
 
 	page = pmd_page(*pmd);
@@ -1354,7 +1354,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
-	 * and pmd_numa cleared.
+	 * and access rights restored.
 	 */
 	spin_unlock(ptl);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
@@ -1369,7 +1369,7 @@ clear_pmdnuma:
 	BUG_ON(!PageLocked(page));
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
-	VM_BUG_ON(pmd_numa(*pmdp));
+	VM_BUG_ON(pmd_protnone_numa(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
 	unlock_page(page);
 out_unlock:
@@ -1514,7 +1514,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		ret = 1;
 		if (!prot_numa) {
 			entry = pmdp_get_and_clear(mm, addr, pmd);
-			if (pmd_numa(entry))
+			if (pmd_protnone_numa(entry))
 				entry = pmd_mknonnuma(entry);
 			entry = pmd_modify(entry, newprot);
 			ret = HPAGE_PMD_NR;
@@ -1530,7 +1530,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			 * local vs remote hits on the zero page.
 			 */
 			if (!is_huge_zero_page(page) &&
-			    !pmd_numa(*pmd)) {
+			    !pmd_protnone_numa(*pmd)) {
 				pmdp_set_numa(mm, addr, pmd);
 				ret = HPAGE_PMD_NR;
 			}
@@ -1797,9 +1797,9 @@ static int __split_huge_page_map(struct page *page,
 			pte_t *pte, entry;
 			BUG_ON(PageCompound(page+i));
 			/*
-			 * Note that pmd_numa is not transferred deliberately
-			 * to avoid any possibility that pte_numa leaks to
-			 * a PROT_NONE VMA by accident.
+			 * Note that NUMA hinting access restrictions are not
+			 * transferred to avoid any possibility of altering
+			 * permissions across VMAs.
 			 */
 			entry = mk_pte(page + i, vma->vm_page_prot);
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
diff --git a/mm/memory.c b/mm/memory.c
index 3e50383..96ceb0a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3220,7 +3220,7 @@ static int handle_pte_fault(struct mm_struct *mm,
 					pte, pmd, flags, entry);
 	}
 
-	if (pte_numa(entry))
+	if (pte_protnone_numa(entry))
 		return do_numa_page(mm, vma, address, entry, pte, pmd);
 
 	ptl = pte_lockptr(mm, pmd);
@@ -3298,7 +3298,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			if (pmd_trans_splitting(orig_pmd))
 				return 0;
 
-			if (pmd_numa(orig_pmd))
+			if (pmd_protnone_numa(orig_pmd))
 				return do_huge_pmd_numa_page(mm, vma, address,
 							     orig_pmd, pmd);
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ace9345..e93ddac 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -75,36 +75,17 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
 			pte_t ptent;
-			bool updated = false;
-
-			if (!prot_numa) {
-				ptent = ptep_modify_prot_start(mm, addr, pte);
-				if (pte_numa(ptent))
-					ptent = pte_mknonnuma(ptent);
-				ptent = pte_modify(ptent, newprot);
-				/*
-				 * Avoid taking write faults for pages we
-				 * know to be dirty.
-				 */
-				if (dirty_accountable && pte_dirty(ptent) &&
-				    (pte_soft_dirty(ptent) ||
-				     !(vma->vm_flags & VM_SOFTDIRTY)))
-					ptent = pte_mkwrite(ptent);
-				ptep_modify_prot_commit(mm, addr, pte, ptent);
-				updated = true;
-			} else {
-				struct page *page;
-
-				page = vm_normal_page(vma, addr, oldpte);
-				if (page && !PageKsm(page)) {
-					if (!pte_numa(oldpte)) {
-						ptep_set_numa(mm, addr, pte);
-						updated = true;
-					}
-				}
+			ptent = ptep_modify_prot_start(mm, addr, pte);
+			ptent = pte_modify(ptent, newprot);
+
+			/* Avoid taking write faults for known dirty pages */
+			if (dirty_accountable && pte_dirty(ptent) &&
+					(pte_soft_dirty(ptent) ||
+					 !(vma->vm_flags & VM_SOFTDIRTY))) {
+				ptent = pte_mkwrite(ptent);
 			}
-			if (updated)
-				pages++;
+			ptep_modify_prot_commit(mm, addr, pte, ptent);
+			pages++;
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index dfb79e0..a2d8587 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -193,7 +193,7 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
 	pmd_t entry = *pmdp;
-	if (pmd_numa(entry))
+	if (pmd_protnone_numa(entry))
 		entry = pmd_mknonnuma(entry);
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
