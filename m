Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1D16B027B
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:03:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so75704542wmg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:03:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n198si38441377wmd.76.2016.09.22.09.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 09:03:01 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8MFwqkt139061
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:02:57 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25m5ud5h6a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:02:57 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 22 Sep 2016 10:02:56 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH] powerpc/mm: THP page cache support
Date: Thu, 22 Sep 2016 21:32:40 +0530
Message-Id: <1474560160-7327-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Update arch hook in the generic THP page cache code, that will
deposit and withdarw preallocated page table. Archs like ppc64 use
this preallocated table to store the hash pte slot information.

This is an RFC patch and I am sharing this early to get feedback on the
approach taken. I have used stress-ng mmap-file operation and that
resulted in some thp_file_mmap as show below.

[/mnt/stress]$ grep thp_file /proc/vmstat
thp_file_alloc 25403
thp_file_mapped 16967
[/mnt/stress]$

I did observe wrong nr_ptes count once. I need to recreate the problem
again.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |  3 ++
 include/asm-generic/pgtable.h                |  8 +++-
 mm/Kconfig                                   |  6 +--
 mm/huge_memory.c                             | 19 +++++++++-
 mm/khugepaged.c                              | 21 ++++++++++-
 mm/memory.c                                  | 56 +++++++++++++++++++++++-----
 6 files changed, 93 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 263bf39ced40..1f45b06ce78e 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1017,6 +1017,9 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
 	 */
 	return true;
 }
+
+#define arch_needs_pgtable_deposit() (true)
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif /* __ASSEMBLY__ */
 #endif /* _ASM_POWERPC_BOOK3S_64_PGTABLE_H_ */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index d4458b6dbfb4..0d1e400e82a2 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -660,11 +660,17 @@ static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
 	/*
 	 * With split pmd lock we also need to move preallocated
 	 * PTE page table if new_pmd is on different PMD page table.
+	 *
+	 * We also don't deposit and withdraw tables for file pages.
 	 */
-	return new_pmd_ptl != old_pmd_ptl;
+	return (new_pmd_ptl != old_pmd_ptl) && vma_is_anonymous(vma);
 }
 #endif
 
+#ifndef arch_needs_pgtable_deposit
+#define arch_needs_pgtable_deposit() (false)
+#endif
+
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
index a6abd76baa72..37176f455d16 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1320,6 +1320,14 @@ out_unlocked:
 	return ret;
 }
 
+void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
+{
+	pgtable_t pgtable;
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pte_free(mm, pgtable);
+	atomic_long_dec(&mm->nr_ptes);
+}
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
@@ -1359,6 +1367,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 		} else {
+			if (arch_needs_pgtable_deposit())
+				zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		}
 		spin_unlock(ptl);
@@ -1401,8 +1411,7 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 
-		if (pmd_move_must_withdraw(new_ptl, old_ptl) &&
-				vma_is_anonymous(vma)) {
+		if (pmd_move_must_withdraw(new_ptl, old_ptl)) {
 			pgtable_t pgtable;
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
@@ -1525,6 +1534,12 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (!vma_is_anonymous(vma)) {
 		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+		/*
+		 * We are going to unmap this huge page. So
+		 * just go ahead and zap it
+		 */
+		if (arch_needs_pgtable_deposit())
+			zap_deposited_table(mm, pmd);
 		if (is_huge_zero_pmd(_pmd))
 			put_huge_zero_page();
 		if (vma_is_dax(vma))
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
index 83be99d9d8a1..670152f42aa1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2935,6 +2935,19 @@ static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
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
@@ -2949,6 +2962,13 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
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
@@ -2962,6 +2982,11 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 
 	add_mm_counter(vma->vm_mm, MM_FILEPAGES, HPAGE_PMD_NR);
 	page_add_file_rmap(page, true);
+	/*
+	 * deposit and withdraw with pmd lock held
+	 */
+	if (arch_needs_pgtable_deposit())
+		deposit_prealloc_pte(fe);
 
 	set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
 
@@ -2971,6 +2996,13 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 	ret = 0;
 	count_vm_event(THP_FILE_MAPPED);
 out:
+	/*
+	 * If we are going to fallback to pte mapping, do a
+	 * withdraw with pmd lock held.
+	 */
+	if (arch_needs_pgtable_deposit() && (ret == VM_FAULT_FALLBACK ))
+		fe->prealloc_pte = pgtable_trans_huge_withdraw(vma->vm_mm,
+							       fe->pmd);
 	spin_unlock(fe->ptl);
 	return ret;
 }
@@ -3010,18 +3042,20 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 
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
@@ -3041,8 +3075,15 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 
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
@@ -3141,11 +3182,6 @@ static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
 
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
