Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 86DD86B0073
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 08:57:58 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x12so6588378wgg.19
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:57:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si9346135wjy.35.2014.11.21.05.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 05:57:54 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/10] mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
Date: Fri, 21 Nov 2014 13:57:41 +0000
Message-Id: <1416578268-19597-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1416578268-19597-1-git-send-email-mgorman@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

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
 arch/powerpc/mm/pgtable.c           | 11 ++++++++---
 arch/powerpc/mm/pgtable_64.c        |  3 ++-
 arch/x86/mm/gup.c                   |  4 ++--
 include/uapi/linux/mempolicy.h      |  2 +-
 mm/gup.c                            | 10 +++++-----
 mm/huge_memory.c                    | 16 +++++++--------
 mm/memory.c                         |  4 ++--
 mm/mprotect.c                       | 39 ++++++++++---------------------------
 mm/pgtable-generic.c                |  2 +-
 11 files changed, 40 insertions(+), 58 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_rm_mmu.c b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
index 084ad54..3e6ad3f 100644
--- a/arch/powerpc/kvm/book3s_hv_rm_mmu.c
+++ b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
@@ -235,7 +235,7 @@ long kvmppc_do_h_enter(struct kvm *kvm, unsigned long flags,
 		pte_size = psize;
 		pte = lookup_linux_pte_and_update(pgdir, hva, writing,
 						  &pte_size);
-		if (pte_present(pte) && !pte_numa(pte)) {
+		if (pte_present(pte) && !pte_protnone(pte)) {
 			if (writing && !pte_write(pte))
 				/* make the actual HPTE be read-only */
 				ptel = hpte_make_readonly(ptel);
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index eb79907..b434153 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -398,8 +398,6 @@ good_area:
 		 * processors use the same I/D cache coherency mechanism
 		 * as embedded.
 		 */
-		if (error_code & DSISR_PROTFAULT)
-			goto bad_area;
 #endif /* CONFIG_PPC_STD_MMU */
 
 		/*
@@ -423,9 +421,6 @@ good_area:
 		flags |= FAULT_FLAG_WRITE;
 	/* a read */
 	} else {
-		/* protection fault */
-		if (error_code & 0x08000000)
-			goto bad_area;
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)))
 			goto bad_area;
 	}
diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index c90e602..83dfcb5 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -172,9 +172,14 @@ static pte_t set_access_flags_filter(pte_t pte, struct vm_area_struct *vma,
 void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 		pte_t pte)
 {
-#ifdef CONFIG_DEBUG_VM
-	WARN_ON(pte_val(*ptep) & _PAGE_PRESENT);
-#endif
+	/*
+	 * When handling numa faults, we already have the pte marked
+	 * _PAGE_PRESENT, but we can be sure that it is not in hpte.
+	 * Hence we can use set_pte_at for them.
+	 */
+	VM_WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
+		(_PAGE_PRESENT | _PAGE_USER));
+
 	/* Note: mm->context.id might not yet have been assigned as
 	 * this context might not have been activated yet when this
 	 * is called.
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 87ff0c1..435ebf7 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -718,7 +718,8 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
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
index 207d9aef..f32e12c 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -84,7 +84,7 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		struct page *page;
 
 		/* Similar to the PMD case, NUMA hinting must take slow path */
-		if (pte_numa(pte)) {
+		if (pte_protnone(pte)) {
 			pte_unmap(ptep);
 			return 0;
 		}
@@ -178,7 +178,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			 * slowpath for accounting purposes and so that they
 			 * can be serialised against THP migration.
 			 */
-			if (pmd_numa(pmd))
+			if (pmd_protnone(pmd))
 				return 0;
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
 				return 0;
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 0d11c3d..9cd8b21 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -67,7 +67,7 @@ enum mpol_rebind_step {
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
 #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
 #define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
-#define MPOL_F_MORON	(1 << 4) /* Migrate On pte_numa Reference On Node */
+#define MPOL_F_MORON	(1 << 4) /* Migrate On protnone Reference On Node */
 
 
 #endif /* _UAPI_LINUX_MEMPOLICY_H */
diff --git a/mm/gup.c b/mm/gup.c
index 0ca1df9..e5dab89 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -64,7 +64,7 @@ retry:
 		migration_entry_wait(mm, pmd, address);
 		goto retry;
 	}
-	if ((flags & FOLL_NUMA) && pte_numa(pte))
+	if ((flags & FOLL_NUMA) && pte_protnone(pte))
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte)) {
 		pte_unmap_unlock(ptep, ptl);
@@ -193,7 +193,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		}
 		return page;
 	}
-	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_trans_huge(*pmd)) {
 		if (flags & FOLL_SPLIT) {
@@ -740,10 +740,10 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		/*
 		 * Similar to the PMD case below, NUMA hinting must take slow
-		 * path
+		 * path using the pte_protnone check.
 		 */
 		if (!pte_present(pte) || pte_special(pte) ||
-			pte_numa(pte) || (write && !pte_write(pte)))
+			pte_protnone(pte) || (write && !pte_write(pte)))
 			goto pte_unmap;
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
@@ -938,7 +938,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			 * slowpath for accounting purposes and so that they
 			 * can be serialised against THP migration.
 			 */
-			if (pmd_numa(pmd))
+			if (pmd_protnone(pmd))
 				return 0;
 
 			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a2cd021..f81fddf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1222,7 +1222,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		return ERR_PTR(-EFAULT);
 
 	/* Full NUMA hinting faults to serialise migration in fault paths */
-	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		goto out;
 
 	page = pmd_page(*pmd);
@@ -1353,7 +1353,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
-	 * and pmd_numa cleared.
+	 * and access rights restored.
 	 */
 	spin_unlock(ptl);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
@@ -1368,7 +1368,7 @@ clear_pmdnuma:
 	BUG_ON(!PageLocked(page));
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
-	VM_BUG_ON(pmd_numa(*pmdp));
+	VM_BUG_ON(pmd_protnone(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
 	unlock_page(page);
 out_unlock:
@@ -1514,7 +1514,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		ret = 1;
 		if (!prot_numa) {
 			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
-			if (pmd_numa(entry))
+			if (pmd_protnone(entry))
 				entry = pmd_mknonnuma(entry);
 			entry = pmd_modify(entry, newprot);
 			ret = HPAGE_PMD_NR;
@@ -1530,7 +1530,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			 * local vs remote hits on the zero page.
 			 */
 			if (!is_huge_zero_page(page) &&
-			    !pmd_numa(*pmd)) {
+			    !pmd_protnone(*pmd)) {
 				pmdp_set_numa(mm, addr, pmd);
 				ret = HPAGE_PMD_NR;
 			}
@@ -1798,9 +1798,9 @@ static int __split_huge_page_map(struct page *page,
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
index ae923f5..eaa46f1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3214,7 +3214,7 @@ static int handle_pte_fault(struct mm_struct *mm,
 					pte, pmd, flags, entry);
 	}
 
-	if (pte_numa(entry))
+	if (pte_protnone(entry))
 		return do_numa_page(mm, vma, address, entry, pte, pmd);
 
 	ptl = pte_lockptr(mm, pmd);
@@ -3292,7 +3292,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			if (pmd_trans_splitting(orig_pmd))
 				return 0;
 
-			if (pmd_numa(orig_pmd))
+			if (pmd_protnone(orig_pmd))
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
index dfb79e0..4b8ad76 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -193,7 +193,7 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
 	pmd_t entry = *pmdp;
-	if (pmd_numa(entry))
+	if (pmd_protnone(entry))
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
