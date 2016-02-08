Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 42763830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:38 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id b35so112665883qge.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:38 -0800 (PST)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id r10si29614126qhc.128.2016.02.08.01.21.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:31 -0800 (PST)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 04:21:31 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 83CDC38C803B
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:29 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LTkb29622304
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:29 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LS5F012094
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:29 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 17/29] powerpc/mm: THP is only available on hash64 as of now
Date: Mon,  8 Feb 2016 14:50:29 +0530
Message-Id: <1454923241-6681-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/pgtable-hash64.c | 374 +++++++++++++++++++++++++++++++++++++++
 arch/powerpc/mm/pgtable_64.c     | 374 ---------------------------------------
 2 files changed, 374 insertions(+), 374 deletions(-)

diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
index 4813a3c2d457..8cfa297f2c64 100644
--- a/arch/powerpc/mm/pgtable-hash64.c
+++ b/arch/powerpc/mm/pgtable-hash64.c
@@ -21,6 +21,9 @@
 
 #include "mmu_decl.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/thp.h>
+
 #if H_PGTABLE_RANGE > USER_VSID_RANGE
 #warning Limited user VSID range means pagetable space is wasted
 #endif
@@ -245,3 +248,374 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 	/* Perform the setting of the PTE */
 	__set_pte_at(mm, addr, ptep, pte, 0);
 }
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
+/*
+ * This is called when relaxing access to a hugepage. It's also called in the page
+ * fault path when we don't hit any of the major fault cases, ie, a minor
+ * update of _PAGE_ACCESSED, _PAGE_DIRTY, etc... The generic code will have
+ * handled those two for us, we additionally deal with missing execute
+ * permission here on some processors
+ */
+int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp, pmd_t entry, int dirty)
+{
+	int changed;
+#ifdef CONFIG_DEBUG_VM
+	WARN_ON(!pmd_trans_huge(*pmdp));
+	assert_spin_locked(&vma->vm_mm->page_table_lock);
+#endif
+	changed = !pmd_same(*(pmdp), entry);
+	if (changed) {
+		__ptep_set_access_flags(pmdp_ptep(pmdp), pmd_pte(entry));
+		/*
+		 * Since we are not supporting SW TLB systems, we don't
+		 * have any thing similar to flush_tlb_page_nohash()
+		 */
+	}
+	return changed;
+}
+
+unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
+				  pmd_t *pmdp, unsigned long clr,
+				  unsigned long set)
+{
+
+	unsigned long old, tmp;
+
+#ifdef CONFIG_DEBUG_VM
+	WARN_ON(!pmd_trans_huge(*pmdp));
+	assert_spin_locked(&mm->page_table_lock);
+#endif
+
+#ifdef PTE_ATOMIC_UPDATES
+	__asm__ __volatile__(
+	"1:	ldarx	%0,0,%3\n\
+		andi.	%1,%0,%6\n\
+		bne-	1b \n\
+		andc	%1,%0,%4 \n\
+		or	%1,%1,%7\n\
+		stdcx.	%1,0,%3 \n\
+		bne-	1b"
+	: "=&r" (old), "=&r" (tmp), "=m" (*pmdp)
+	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (H_PAGE_BUSY), "r" (set)
+	: "cc" );
+#else
+	old = pmd_val(*pmdp);
+	*pmdp = __pmd((old & ~clr) | set);
+#endif
+	trace_hugepage_update(addr, old, clr, set);
+	if (old & H_PAGE_HASHPTE)
+		hpte_do_hugepage_flush(mm, addr, pmdp, old);
+	return old;
+}
+
+pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	pmd_t pmd;
+
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG_ON(pmd_trans_huge(*pmdp));
+
+	pmd = *pmdp;
+	pmd_clear(pmdp);
+	/*
+	 * Wait for all pending hash_page to finish. This is needed
+	 * in case of subpage collapse. When we collapse normal pages
+	 * to hugepage, we first clear the pmd, then invalidate all
+	 * the PTE entries. The assumption here is that any low level
+	 * page fault will see a none pmd and take the slow path that
+	 * will wait on mmap_sem. But we could very well be in a
+	 * hash_page with local ptep pointer value. Such a hash page
+	 * can result in adding new HPTE entries for normal subpages.
+	 * That means we could be modifying the page content as we
+	 * copy them to a huge page. So wait for parallel hash_page
+	 * to finish before invalidating HPTE entries. We can do this
+	 * by sending an IPI to all the cpus and executing a dummy
+	 * function there.
+	 */
+	kick_all_cpus_sync();
+	/*
+	 * Now invalidate the hpte entries in the range
+	 * covered by pmd. This make sure we take a
+	 * fault and will find the pmd as none, which will
+	 * result in a major fault which takes mmap_sem and
+	 * hence wait for collapse to complete. Without this
+	 * the __collapse_huge_page_copy can result in copying
+	 * the old content.
+	 */
+	flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
+	return pmd;
+}
+
+int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+			      unsigned long address, pmd_t *pmdp)
+{
+	return __pmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
+}
+
+/*
+ * We currently remove entries from the hashtable regardless of whether
+ * the entry was young or dirty. The generic routines only flush if the
+ * entry was young or dirty which is not good enough.
+ *
+ * We should be more intelligent about this but for the moment we override
+ * these functions and force a tlb flush unconditionally
+ */
+int pmdp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmdp)
+{
+	return __pmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
+}
+
+/*
+ * We want to put the pgtable in pmd and use pgtable for tracking
+ * the base page size hptes
+ */
+void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pgtable)
+{
+	pgtable_t *pgtable_slot;
+	assert_spin_locked(&mm->page_table_lock);
+	/*
+	 * we store the pgtable in the second half of PMD
+	 */
+	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
+	*pgtable_slot = pgtable;
+	/*
+	 * expose the deposited pgtable to other cpus.
+	 * before we set the hugepage PTE at pmd level
+	 * hash fault code looks at the deposted pgtable
+	 * to store hash index values.
+	 */
+	smp_wmb();
+}
+
+pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
+{
+	pgtable_t pgtable;
+	pgtable_t *pgtable_slot;
+
+	assert_spin_locked(&mm->page_table_lock);
+	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
+	pgtable = *pgtable_slot;
+	/*
+	 * Once we withdraw, mark the entry NULL.
+	 */
+	*pgtable_slot = NULL;
+	/*
+	 * We store HPTE information in the deposited PTE fragment.
+	 * zero out the content on withdraw.
+	 */
+	memset(pgtable, 0, H_PTE_FRAG_SIZE);
+	return pgtable;
+}
+
+void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
+			       unsigned long address, pmd_t *pmdp)
+{
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+
+#ifdef CONFIG_DEBUG_VM
+	BUG_ON(REGION_ID(address) != H_USER_REGION_ID);
+#endif
+	/*
+	 * We can't mark the pmd none here, because that will cause a race
+	 * against exit_mmap. We need to continue mark pmd TRANS HUGE, while
+	 * we spilt, but at the same time we wan't rest of the ppc64 code
+	 * not to insert hash pte on this, because we will be modifying
+	 * the deposited pgtable in the caller of this function. Hence
+	 * clear the _PAGE_USER so that we move the fault handling to
+	 * higher level function and that will serialize against ptl.
+	 * We need to flush existing hash pte entries here even though,
+	 * the translation is still valid, because we will withdraw
+	 * pgtable_t after this.
+	 */
+	pmd_hugepage_update(vma->vm_mm, address, pmdp, H_PAGE_USER, 0);
+}
+
+
+/*
+ * set a new huge pmd. We should not be called for updating
+ * an existing pmd entry. That should go via pmd_hugepage_update.
+ */
+void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+		pmd_t *pmdp, pmd_t pmd)
+{
+#ifdef CONFIG_DEBUG_VM
+	WARN_ON((pmd_val(*pmdp) & (H_PAGE_PRESENT | H_PAGE_USER)) ==
+		(H_PAGE_PRESENT | H_PAGE_USER));
+	assert_spin_locked(&mm->page_table_lock);
+	WARN_ON(!pmd_trans_huge(pmd));
+#endif
+	trace_hugepage_set_pmd(addr, pmd_val(pmd));
+	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
+}
+
+/*
+ * We use this to invalidate a pmdp entry before switching from a
+ * hugepte to regular pmd entry.
+ */
+void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+		     pmd_t *pmdp)
+{
+	pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
+	/*
+	 * This ensures that generic code that rely on IRQ disabling
+	 * to prevent a parallel THP split work as expected.
+	 */
+	kick_all_cpus_sync();
+}
+
+/*
+ * A linux hugepage PMD was changed and the corresponding hash table entries
+ * neesd to be flushed.
+ */
+void hpte_do_hugepage_flush(struct mm_struct *mm, unsigned long addr,
+			    pmd_t *pmdp, unsigned long old_pmd)
+{
+	int ssize;
+	unsigned int psize;
+	unsigned long vsid;
+	unsigned long flags = 0;
+	const struct cpumask *tmp;
+
+	/* get the base page size,vsid and segment size */
+#ifdef CONFIG_DEBUG_VM
+	psize = get_slice_psize(mm, addr);
+	BUG_ON(psize == MMU_PAGE_16M);
+#endif
+	if (old_pmd & H_PAGE_COMBO)
+		psize = MMU_PAGE_4K;
+	else
+		psize = MMU_PAGE_64K;
+
+	if (!is_kernel_addr(addr)) {
+		ssize = user_segment_size(addr);
+		vsid = get_vsid(mm->context.id, addr, ssize);
+		WARN_ON(vsid == 0);
+	} else {
+		vsid = get_kernel_vsid(addr, mmu_kernel_ssize);
+		ssize = mmu_kernel_ssize;
+	}
+
+	tmp = cpumask_of(smp_processor_id());
+	if (cpumask_equal(mm_cpumask(mm), tmp))
+		flags |= HPTE_LOCAL_UPDATE;
+
+	return flush_hash_hugepage(vsid, addr, pmdp, psize, ssize, flags);
+}
+
+static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
+{
+	return __pmd(pmd_val(pmd) | pgprot_val(pgprot));
+}
+
+pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
+{
+	unsigned long pmdv;
+
+	pmdv = pfn << H_PTE_RPN_SHIFT;
+	return pmd_set_protbits(__pmd(pmdv), pgprot);
+}
+
+pmd_t mk_pmd(struct page *page, pgprot_t pgprot)
+{
+	return pfn_pmd(page_to_pfn(page), pgprot);
+}
+
+pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	unsigned long pmdv;
+
+	pmdv = pmd_val(pmd);
+	pmdv &= H_HPAGE_CHG_MASK;
+	return pmd_set_protbits(__pmd(pmdv), newprot);
+}
+
+/*
+ * This is called at the end of handling a user page fault, when the
+ * fault has been handled by updating a HUGE PMD entry in the linux page tables.
+ * We use it to preload an HPTE into the hash table corresponding to
+ * the updated linux HUGE PMD entry.
+ */
+void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
+			  pmd_t *pmd)
+{
+	return;
+}
+
+pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+			      unsigned long addr, pmd_t *pmdp)
+{
+	pmd_t old_pmd;
+	pgtable_t pgtable;
+	unsigned long old;
+	pgtable_t *pgtable_slot;
+
+	old = pmd_hugepage_update(mm, addr, pmdp, ~0UL, 0);
+	old_pmd = __pmd(old);
+	/*
+	 * We have pmd == none and we are holding page_table_lock.
+	 * So we can safely go and clear the pgtable hash
+	 * index info.
+	 */
+	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
+	pgtable = *pgtable_slot;
+	/*
+	 * Let's zero out old valid and hash index details
+	 * hash fault look at them.
+	 */
+	memset(pgtable, 0, H_PTE_FRAG_SIZE);
+	/*
+	 * Serialize against find_linux_pte_or_hugepte which does lock-less
+	 * lookup in page tables with local interrupts disabled. For huge pages
+	 * it casts pmd_t to pte_t. Since format of pte_t is different from
+	 * pmd_t we want to prevent transit from pmd pointing to page table
+	 * to pmd pointing to huge page (and back) while interrupts are disabled.
+	 * We clear pmd to possibly replace it with page table pointer in
+	 * different code paths. So make sure we wait for the parallel
+	 * find_linux_pte_or_hugepage to finish.
+	 */
+	kick_all_cpus_sync();
+	return old_pmd;
+}
+
+int has_transparent_hugepage(void)
+{
+
+	BUILD_BUG_ON_MSG((H_PMD_SHIFT - PAGE_SHIFT) >= MAX_ORDER,
+		"hugepages can't be allocated by the buddy allocator");
+
+	BUILD_BUG_ON_MSG((H_PMD_SHIFT - PAGE_SHIFT) < 2,
+			 "We need more than 2 pages to do deferred thp split");
+
+	if (!mmu_has_feature(MMU_FTR_16M_PAGE))
+		return 0;
+	/*
+	 * We support THP only if PMD_SIZE is 16MB.
+	 */
+	if (mmu_psize_defs[MMU_PAGE_16M].shift != H_PMD_SHIFT)
+		return 0;
+	/*
+	 * We need to make sure that we support 16MB hugepage in a segement
+	 * with base page size 64K or 4K. We only enable THP with a PAGE_SIZE
+	 * of 64K.
+	 */
+	/*
+	 * If we have 64K HPTE, we will be using that by default
+	 */
+	if (mmu_psize_defs[MMU_PAGE_64K].shift &&
+	    (mmu_psize_defs[MMU_PAGE_64K].penc[MMU_PAGE_16M] == -1))
+		return 0;
+	/*
+	 * Ok we only have 4K HPTE
+	 */
+	if (mmu_psize_defs[MMU_PAGE_4K].penc[MMU_PAGE_16M] == -1)
+		return 0;
+
+	return 1;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 8d203f1b1162..99a44e1a9414 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -55,9 +55,6 @@
 
 #include "mmu_decl.h"
 
-#define CREATE_TRACE_POINTS
-#include <trace/events/thp.h>
-
 #ifdef CONFIG_PPC_STD_MMU_64
 #if TASK_SIZE_USER64 > (1UL << (ESID_BITS + SID_SHIFT))
 #error TASK_SIZE_USER64 exceeds user VSID range
@@ -445,374 +442,3 @@ void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
 }
 #endif
 #endif /* CONFIG_PPC_64K_PAGES */
-
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-
-/*
- * This is called when relaxing access to a hugepage. It's also called in the page
- * fault path when we don't hit any of the major fault cases, ie, a minor
- * update of _PAGE_ACCESSED, _PAGE_DIRTY, etc... The generic code will have
- * handled those two for us, we additionally deal with missing execute
- * permission here on some processors
- */
-int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp, pmd_t entry, int dirty)
-{
-	int changed;
-#ifdef CONFIG_DEBUG_VM
-	WARN_ON(!pmd_trans_huge(*pmdp));
-	assert_spin_locked(&vma->vm_mm->page_table_lock);
-#endif
-	changed = !pmd_same(*(pmdp), entry);
-	if (changed) {
-		__ptep_set_access_flags(pmdp_ptep(pmdp), pmd_pte(entry));
-		/*
-		 * Since we are not supporting SW TLB systems, we don't
-		 * have any thing similar to flush_tlb_page_nohash()
-		 */
-	}
-	return changed;
-}
-
-unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
-				  pmd_t *pmdp, unsigned long clr,
-				  unsigned long set)
-{
-
-	unsigned long old, tmp;
-
-#ifdef CONFIG_DEBUG_VM
-	WARN_ON(!pmd_trans_huge(*pmdp));
-	assert_spin_locked(&mm->page_table_lock);
-#endif
-
-#ifdef PTE_ATOMIC_UPDATES
-	__asm__ __volatile__(
-	"1:	ldarx	%0,0,%3\n\
-		andi.	%1,%0,%6\n\
-		bne-	1b \n\
-		andc	%1,%0,%4 \n\
-		or	%1,%1,%7\n\
-		stdcx.	%1,0,%3 \n\
-		bne-	1b"
-	: "=&r" (old), "=&r" (tmp), "=m" (*pmdp)
-	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (H_PAGE_BUSY), "r" (set)
-	: "cc" );
-#else
-	old = pmd_val(*pmdp);
-	*pmdp = __pmd((old & ~clr) | set);
-#endif
-	trace_hugepage_update(addr, old, clr, set);
-	if (old & H_PAGE_HASHPTE)
-		hpte_do_hugepage_flush(mm, addr, pmdp, old);
-	return old;
-}
-
-pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp)
-{
-	pmd_t pmd;
-
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	VM_BUG_ON(pmd_trans_huge(*pmdp));
-
-	pmd = *pmdp;
-	pmd_clear(pmdp);
-	/*
-	 * Wait for all pending hash_page to finish. This is needed
-	 * in case of subpage collapse. When we collapse normal pages
-	 * to hugepage, we first clear the pmd, then invalidate all
-	 * the PTE entries. The assumption here is that any low level
-	 * page fault will see a none pmd and take the slow path that
-	 * will wait on mmap_sem. But we could very well be in a
-	 * hash_page with local ptep pointer value. Such a hash page
-	 * can result in adding new HPTE entries for normal subpages.
-	 * That means we could be modifying the page content as we
-	 * copy them to a huge page. So wait for parallel hash_page
-	 * to finish before invalidating HPTE entries. We can do this
-	 * by sending an IPI to all the cpus and executing a dummy
-	 * function there.
-	 */
-	kick_all_cpus_sync();
-	/*
-	 * Now invalidate the hpte entries in the range
-	 * covered by pmd. This make sure we take a
-	 * fault and will find the pmd as none, which will
-	 * result in a major fault which takes mmap_sem and
-	 * hence wait for collapse to complete. Without this
-	 * the __collapse_huge_page_copy can result in copying
-	 * the old content.
-	 */
-	flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
-	return pmd;
-}
-
-int pmdp_test_and_clear_young(struct vm_area_struct *vma,
-			      unsigned long address, pmd_t *pmdp)
-{
-	return __pmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
-}
-
-/*
- * We currently remove entries from the hashtable regardless of whether
- * the entry was young or dirty. The generic routines only flush if the
- * entry was young or dirty which is not good enough.
- *
- * We should be more intelligent about this but for the moment we override
- * these functions and force a tlb flush unconditionally
- */
-int pmdp_clear_flush_young(struct vm_area_struct *vma,
-				  unsigned long address, pmd_t *pmdp)
-{
-	return __pmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
-}
-
-/*
- * We want to put the pgtable in pmd and use pgtable for tracking
- * the base page size hptes
- */
-void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
-				pgtable_t pgtable)
-{
-	pgtable_t *pgtable_slot;
-	assert_spin_locked(&mm->page_table_lock);
-	/*
-	 * we store the pgtable in the second half of PMD
-	 */
-	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
-	*pgtable_slot = pgtable;
-	/*
-	 * expose the deposited pgtable to other cpus.
-	 * before we set the hugepage PTE at pmd level
-	 * hash fault code looks at the deposted pgtable
-	 * to store hash index values.
-	 */
-	smp_wmb();
-}
-
-pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
-{
-	pgtable_t pgtable;
-	pgtable_t *pgtable_slot;
-
-	assert_spin_locked(&mm->page_table_lock);
-	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
-	pgtable = *pgtable_slot;
-	/*
-	 * Once we withdraw, mark the entry NULL.
-	 */
-	*pgtable_slot = NULL;
-	/*
-	 * We store HPTE information in the deposited PTE fragment.
-	 * zero out the content on withdraw.
-	 */
-	memset(pgtable, 0, H_PTE_FRAG_SIZE);
-	return pgtable;
-}
-
-void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
-			       unsigned long address, pmd_t *pmdp)
-{
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-
-#ifdef CONFIG_DEBUG_VM
-	BUG_ON(REGION_ID(address) != H_USER_REGION_ID);
-#endif
-	/*
-	 * We can't mark the pmd none here, because that will cause a race
-	 * against exit_mmap. We need to continue mark pmd TRANS HUGE, while
-	 * we spilt, but at the same time we wan't rest of the ppc64 code
-	 * not to insert hash pte on this, because we will be modifying
-	 * the deposited pgtable in the caller of this function. Hence
-	 * clear the _PAGE_USER so that we move the fault handling to
-	 * higher level function and that will serialize against ptl.
-	 * We need to flush existing hash pte entries here even though,
-	 * the translation is still valid, because we will withdraw
-	 * pgtable_t after this.
-	 */
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, H_PAGE_USER, 0);
-}
-
-
-/*
- * set a new huge pmd. We should not be called for updating
- * an existing pmd entry. That should go via pmd_hugepage_update.
- */
-void set_pmd_at(struct mm_struct *mm, unsigned long addr,
-		pmd_t *pmdp, pmd_t pmd)
-{
-#ifdef CONFIG_DEBUG_VM
-	WARN_ON((pmd_val(*pmdp) & (H_PAGE_PRESENT | H_PAGE_USER)) ==
-		(H_PAGE_PRESENT | H_PAGE_USER));
-	assert_spin_locked(&mm->page_table_lock);
-	WARN_ON(!pmd_trans_huge(pmd));
-#endif
-	trace_hugepage_set_pmd(addr, pmd_val(pmd));
-	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
-}
-
-/*
- * We use this to invalidate a pmdp entry before switching from a
- * hugepte to regular pmd entry.
- */
-void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
-		     pmd_t *pmdp)
-{
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
-	/*
-	 * This ensures that generic code that rely on IRQ disabling
-	 * to prevent a parallel THP split work as expected.
-	 */
-	kick_all_cpus_sync();
-}
-
-/*
- * A linux hugepage PMD was changed and the corresponding hash table entries
- * neesd to be flushed.
- */
-void hpte_do_hugepage_flush(struct mm_struct *mm, unsigned long addr,
-			    pmd_t *pmdp, unsigned long old_pmd)
-{
-	int ssize;
-	unsigned int psize;
-	unsigned long vsid;
-	unsigned long flags = 0;
-	const struct cpumask *tmp;
-
-	/* get the base page size,vsid and segment size */
-#ifdef CONFIG_DEBUG_VM
-	psize = get_slice_psize(mm, addr);
-	BUG_ON(psize == MMU_PAGE_16M);
-#endif
-	if (old_pmd & H_PAGE_COMBO)
-		psize = MMU_PAGE_4K;
-	else
-		psize = MMU_PAGE_64K;
-
-	if (!is_kernel_addr(addr)) {
-		ssize = user_segment_size(addr);
-		vsid = get_vsid(mm->context.id, addr, ssize);
-		WARN_ON(vsid == 0);
-	} else {
-		vsid = get_kernel_vsid(addr, mmu_kernel_ssize);
-		ssize = mmu_kernel_ssize;
-	}
-
-	tmp = cpumask_of(smp_processor_id());
-	if (cpumask_equal(mm_cpumask(mm), tmp))
-		flags |= HPTE_LOCAL_UPDATE;
-
-	return flush_hash_hugepage(vsid, addr, pmdp, psize, ssize, flags);
-}
-
-static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
-{
-	return __pmd(pmd_val(pmd) | pgprot_val(pgprot));
-}
-
-pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
-{
-	unsigned long pmdv;
-
-	pmdv = pfn << H_PTE_RPN_SHIFT;
-	return pmd_set_protbits(__pmd(pmdv), pgprot);
-}
-
-pmd_t mk_pmd(struct page *page, pgprot_t pgprot)
-{
-	return pfn_pmd(page_to_pfn(page), pgprot);
-}
-
-pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
-{
-	unsigned long pmdv;
-
-	pmdv = pmd_val(pmd);
-	pmdv &= H_HPAGE_CHG_MASK;
-	return pmd_set_protbits(__pmd(pmdv), newprot);
-}
-
-/*
- * This is called at the end of handling a user page fault, when the
- * fault has been handled by updating a HUGE PMD entry in the linux page tables.
- * We use it to preload an HPTE into the hash table corresponding to
- * the updated linux HUGE PMD entry.
- */
-void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
-			  pmd_t *pmd)
-{
-	return;
-}
-
-pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
-			      unsigned long addr, pmd_t *pmdp)
-{
-	pmd_t old_pmd;
-	pgtable_t pgtable;
-	unsigned long old;
-	pgtable_t *pgtable_slot;
-
-	old = pmd_hugepage_update(mm, addr, pmdp, ~0UL, 0);
-	old_pmd = __pmd(old);
-	/*
-	 * We have pmd == none and we are holding page_table_lock.
-	 * So we can safely go and clear the pgtable hash
-	 * index info.
-	 */
-	pgtable_slot = (pgtable_t *)pmdp + H_PTRS_PER_PMD;
-	pgtable = *pgtable_slot;
-	/*
-	 * Let's zero out old valid and hash index details
-	 * hash fault look at them.
-	 */
-	memset(pgtable, 0, H_PTE_FRAG_SIZE);
-	/*
-	 * Serialize against find_linux_pte_or_hugepte which does lock-less
-	 * lookup in page tables with local interrupts disabled. For huge pages
-	 * it casts pmd_t to pte_t. Since format of pte_t is different from
-	 * pmd_t we want to prevent transit from pmd pointing to page table
-	 * to pmd pointing to huge page (and back) while interrupts are disabled.
-	 * We clear pmd to possibly replace it with page table pointer in
-	 * different code paths. So make sure we wait for the parallel
-	 * find_linux_pte_or_hugepage to finish.
-	 */
-	kick_all_cpus_sync();
-	return old_pmd;
-}
-
-int has_transparent_hugepage(void)
-{
-
-	BUILD_BUG_ON_MSG((H_PMD_SHIFT - PAGE_SHIFT) >= MAX_ORDER,
-		"hugepages can't be allocated by the buddy allocator");
-
-	BUILD_BUG_ON_MSG((H_PMD_SHIFT - PAGE_SHIFT) < 2,
-			 "We need more than 2 pages to do deferred thp split");
-
-	if (!mmu_has_feature(MMU_FTR_16M_PAGE))
-		return 0;
-	/*
-	 * We support THP only if PMD_SIZE is 16MB.
-	 */
-	if (mmu_psize_defs[MMU_PAGE_16M].shift != H_PMD_SHIFT)
-		return 0;
-	/*
-	 * We need to make sure that we support 16MB hugepage in a segement
-	 * with base page size 64K or 4K. We only enable THP with a PAGE_SIZE
-	 * of 64K.
-	 */
-	/*
-	 * If we have 64K HPTE, we will be using that by default
-	 */
-	if (mmu_psize_defs[MMU_PAGE_64K].shift &&
-	    (mmu_psize_defs[MMU_PAGE_64K].penc[MMU_PAGE_16M] == -1))
-		return 0;
-	/*
-	 * Ok we only have 4K HPTE
-	 */
-	if (mmu_psize_defs[MMU_PAGE_4K].penc[MMU_PAGE_16M] == -1)
-		return 0;
-
-	return 1;
-}
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
