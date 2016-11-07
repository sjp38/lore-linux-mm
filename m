Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD616B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 03:35:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n85so46431708pfi.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 00:35:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id dg2si25073825pad.16.2016.11.07.00.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 00:35:06 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA77x5fg017180
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 03:35:06 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26jc3f4j26-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:35:05 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Nov 2016 01:35:05 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm: THP page cache support for ppc64
Date: Mon,  7 Nov 2016 14:04:41 +0530
In-Reply-To: <20161107083441.21901-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161107083441.21901-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161107083441.21901-2-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Add arch specific callback in the generic THP page cache code that will
deposit and withdarw preallocated page table. Archs like ppc64 use
this preallocated table to store the hash pte slot information.

Testing:
kernel build of the patch series on tmpfs mounted with option huge=always

The related thp stat:
thp_fault_alloc 72939
thp_fault_fallback 60547
thp_collapse_alloc 603
thp_collapse_alloc_failed 0
thp_file_alloc 253763
thp_file_mapped 4251
thp_split_page 51518
thp_split_page_failed 1
thp_deferred_split_page 73566
thp_split_pmd 665
thp_zero_page_alloc 3
thp_zero_page_alloc_failed 0

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
NOTE: I decided not to hide the arch_needs_pgtable_deposit() check
in zap_deposited_table() because IMHO that hides the new code path
which makes following this special case confusing. 

 arch/powerpc/include/asm/book3s/64/pgtable.h | 10 +++++
 include/asm-generic/pgtable.h                |  3 ++
 mm/Kconfig                                   |  6 +--
 mm/huge_memory.c                             | 17 +++++++++
 mm/khugepaged.c                              | 21 ++++++++++-
 mm/memory.c                                  | 56 +++++++++++++++++++++++-----
 6 files changed, 96 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 9fd77f8794a0..9eed9d66d24f 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1020,6 +1020,16 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
 	 */
 	return true;
 }
+
+
+#define arch_needs_pgtable_deposit arch_needs_pgtable_deposit
+static inline bool arch_needs_pgtable_deposit(void)
+{
+	if (radix_enabled())
+		return false;
+	return true;
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif /* __ASSEMBLY__ */
 #endif /* _ASM_POWERPC_BOOK3S_64_PGTABLE_H_ */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 324990273ad2..e00e3b7cf6a8 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -653,6 +653,9 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 }
 #endif
 
+#ifndef arch_needs_pgtable_deposit
+#define arch_needs_pgtable_deposit() (false)
+#endif
 /*
  * This function is meant to be used by sites walking pagetables with
  * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
diff --git a/mm/Kconfig b/mm/Kconfig
index be0ee11fa0d9..0a279d399722 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -447,13 +447,9 @@ choice
 	  benefit.
 endchoice
 
-#
-# We don't deposit page tables on file THP mapping,
-# but Power makes use of them to address MMU quirk.
-#
 config	TRANSPARENT_HUGE_PAGECACHE
 	def_bool y
-	depends on TRANSPARENT_HUGEPAGE && !PPC
+	depends on TRANSPARENT_HUGEPAGE
 
 #
 # UP and nommu archs use km based percpu allocator
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1ac1b0ca63c4..00d2d8b8a00d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1377,6 +1377,15 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return ret;
 }
 
+static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
+{
+	pgtable_t pgtable;
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pte_free(mm, pgtable);
+	atomic_long_dec(&mm->nr_ptes);
+}
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
@@ -1416,6 +1425,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 		} else {
+			if (arch_needs_pgtable_deposit())
+				zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		}
 		spin_unlock(ptl);
@@ -1594,6 +1605,12 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (!vma_is_anonymous(vma)) {
 		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+		/*
+		 * We are going to unmap this huge page. So
+		 * just go ahead and zap it
+		 */
+		if (arch_needs_pgtable_deposit())
+			zap_deposited_table(mm, pmd);
 		if (vma_is_dax(vma))
 			return;
 		page = pmd_page(_pmd);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 728d7790dc2d..9fb7b275cb63 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1240,6 +1240,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 	struct vm_area_struct *vma;
 	unsigned long addr;
 	pmd_t *pmd, _pmd;
+	bool deposited = false;
 
 	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
@@ -1264,10 +1265,26 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
 			/* assume page table is clear */
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
+			/*
+			 * now deposit the pgtable for arch that need it
+			 * otherwise free it.
+			 */
+			if (arch_needs_pgtable_deposit()) {
+				/*
+				 * The deposit should be visibile only after
+				 * collapse is seen by others.
+				 */
+				smp_wmb();
+				pgtable_trans_huge_deposit(vma->vm_mm, pmd,
+							   pmd_pgtable(_pmd));
+				deposited = true;
+			}
 			spin_unlock(ptl);
 			up_write(&vma->vm_mm->mmap_sem);
-			atomic_long_dec(&vma->vm_mm->nr_ptes);
-			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
+			if (!deposited) {
+				atomic_long_dec(&vma->vm_mm->nr_ptes);
+				pte_free(vma->vm_mm, pmd_pgtable(_pmd));
+			}
 		}
 	}
 	i_mmap_unlock_write(mapping);
diff --git a/mm/memory.c b/mm/memory.c
index e18c57bdc75c..6659e8f439c9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2939,6 +2939,19 @@ static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
 	return true;
 }
 
+static void deposit_prealloc_pte(struct fault_env *fe)
+{
+	struct vm_area_struct *vma = fe->vma;
+
+	pgtable_trans_huge_deposit(vma->vm_mm, fe->pmd, fe->prealloc_pte);
+	/*
+	 * We are going to consume the prealloc table,
+	 * count that as nr_ptes.
+	 */
+	atomic_long_inc(&vma->vm_mm->nr_ptes);
+	fe->prealloc_pte = 0;
+}
+
 static int do_set_pmd(struct fault_env *fe, struct page *page)
 {
 	struct vm_area_struct *vma = fe->vma;
@@ -2953,6 +2966,13 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 	ret = VM_FAULT_FALLBACK;
 	page = compound_head(page);
 
+	/*
+	 * Archs like ppc64 need additonal space to store information
+	 * related to pte entry. Use the preallocated table for that.
+	 */
+	if (arch_needs_pgtable_deposit() && !fe->prealloc_pte)
+		fe->prealloc_pte = pte_alloc_one(vma->vm_mm, fe->address);
+
 	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
 	if (unlikely(!pmd_none(*fe->pmd)))
 		goto out;
@@ -2966,6 +2986,11 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 
 	add_mm_counter(vma->vm_mm, MM_FILEPAGES, HPAGE_PMD_NR);
 	page_add_file_rmap(page, true);
+	/*
+	 * deposit and withdraw with pmd lock held
+	 */
+	if (arch_needs_pgtable_deposit())
+		deposit_prealloc_pte(fe);
 
 	set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
 
@@ -2975,6 +3000,13 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 	ret = 0;
 	count_vm_event(THP_FILE_MAPPED);
 out:
+	/*
+	 * If we are going to fallback to pte mapping, do a
+	 * withdraw with pmd lock held.
+	 */
+	if (arch_needs_pgtable_deposit() && (ret == VM_FAULT_FALLBACK))
+		fe->prealloc_pte = pgtable_trans_huge_withdraw(vma->vm_mm,
+							       fe->pmd);
 	spin_unlock(fe->ptl);
 	return ret;
 }
@@ -3014,18 +3046,20 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 
 		ret = do_set_pmd(fe, page);
 		if (ret != VM_FAULT_FALLBACK)
-			return ret;
+			goto fault_handled;
 	}
 
 	if (!fe->pte) {
 		ret = pte_alloc_one_map(fe);
 		if (ret)
-			return ret;
+			goto fault_handled;
 	}
 
 	/* Re-check under ptl */
-	if (unlikely(!pte_none(*fe->pte)))
-		return VM_FAULT_NOPAGE;
+	if (unlikely(!pte_none(*fe->pte))) {
+		ret = VM_FAULT_NOPAGE;
+		goto fault_handled;
+	}
 
 	flush_icache_page(vma, page);
 	entry = mk_pte(page, vma->vm_page_prot);
@@ -3045,8 +3079,15 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 
 	/* no need to invalidate: a not-present page won't be cached */
 	update_mmu_cache(vma, fe->address, fe->pte);
+	ret = 0;
 
-	return 0;
+fault_handled:
+	/* preallocated pagetable is unused: free it */
+	if (fe->prealloc_pte) {
+		pte_free(fe->vma->vm_mm, fe->prealloc_pte);
+		fe->prealloc_pte = 0;
+	}
+	return ret;
 }
 
 static unsigned long fault_around_bytes __read_mostly =
@@ -3145,11 +3186,6 @@ static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
 
 	fe->vma->vm_ops->map_pages(fe, start_pgoff, end_pgoff);
 
-	/* preallocated pagetable is unused: free it */
-	if (fe->prealloc_pte) {
-		pte_free(fe->vma->vm_mm, fe->prealloc_pte);
-		fe->prealloc_pte = 0;
-	}
 	/* Huge page is mapped? Page fault is solved */
 	if (pmd_trans_huge(*fe->pmd)) {
 		ret = VM_FAULT_NOPAGE;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
