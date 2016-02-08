Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id D87A8830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:52 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id is5so144009362obc.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:52 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id en5si12786063oeb.70.2016.02.08.01.21.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:52 -0800 (PST)
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:51 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 491D719D8040
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:45 -0700 (MST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LkpE26411238
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:46 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LjWO007637
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:45 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 25/29] powerpc/mm: Hash linux abstraction for THP
Date: Mon,  8 Feb 2016 14:50:37 +0530
Message-Id: <1454923241-6681-26-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash-64k.h |  42 ++++---
 arch/powerpc/include/asm/book3s/64/hash.h     |  16 +++
 arch/powerpc/include/asm/book3s/64/pgtable.h  | 161 +++++++++++++++++++++-----
 arch/powerpc/mm/pgtable-hash64.c              |  62 +++++-----
 4 files changed, 207 insertions(+), 74 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 8008c9a89416..e697fc528c0a 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -190,11 +190,19 @@ static inline int hugepd_ok(hugepd_t hpd)
 #endif /* CONFIG_HUGETLB_PAGE */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-extern unsigned long pmd_hugepage_update(struct mm_struct *mm,
-					 unsigned long addr,
-					 pmd_t *pmdp,
-					 unsigned long clr,
-					 unsigned long set);
+
+extern pmd_t pfn_hlpmd(unsigned long pfn, pgprot_t pgprot);
+extern pmd_t mk_hlpmd(struct page *page, pgprot_t pgprot);
+extern pmd_t hlpmd_modify(pmd_t pmd, pgprot_t newprot);
+extern int hl_has_transparent_hugepage(void);
+extern void set_hlpmd_at(struct mm_struct *mm, unsigned long addr,
+			 pmd_t *pmdp, pmd_t pmd);
+
+extern unsigned long hlpmd_hugepage_update(struct mm_struct *mm,
+					   unsigned long addr,
+					   pmd_t *pmdp,
+					   unsigned long clr,
+					   unsigned long set);
 static inline char *get_hpte_slot_array(pmd_t *pmdp)
 {
 	/*
@@ -253,51 +261,55 @@ static inline void mark_hpte_slot_valid(unsigned char *hpte_slot_array,
  * that for explicit huge pages.
  *
  */
-static inline int pmd_trans_huge(pmd_t pmd)
+static inline int hlpmd_trans_huge(pmd_t pmd)
 {
 	return !!((pmd_val(pmd) & (H_PAGE_PTE | H_PAGE_THP_HUGE)) ==
 		  (H_PAGE_PTE | H_PAGE_THP_HUGE));
 }
 
-static inline int pmd_large(pmd_t pmd)
+static inline int hlpmd_large(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & H_PAGE_PTE);
 }
 
-static inline pmd_t pmd_mknotpresent(pmd_t pmd)
+static inline pmd_t hlpmd_mknotpresent(pmd_t pmd)
 {
 	return __pmd(pmd_val(pmd) & ~H_PAGE_PRESENT);
 }
 
-#define __HAVE_ARCH_PMD_SAME
-static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
+static inline pmd_t hlpmd_mkhuge(pmd_t pmd)
+{
+	return __pmd(pmd_val(pmd) | (H_PAGE_PTE | H_PAGE_THP_HUGE));
+}
+
+static inline int hlpmd_same(pmd_t pmd_a, pmd_t pmd_b)
 {
 	return (((pmd_val(pmd_a) ^ pmd_val(pmd_b)) & ~H_PAGE_HPTEFLAGS) == 0);
 }
 
-static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
+static inline int __hlpmdp_test_and_clear_young(struct mm_struct *mm,
 					      unsigned long addr, pmd_t *pmdp)
 {
 	unsigned long old;
 
 	if ((pmd_val(*pmdp) & (H_PAGE_ACCESSED | H_PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pmd_hugepage_update(mm, addr, pmdp, H_PAGE_ACCESSED, 0);
+	old = hlpmd_hugepage_update(mm, addr, pmdp, H_PAGE_ACCESSED, 0);
 	return ((old & H_PAGE_ACCESSED) != 0);
 }
 
-#define __HAVE_ARCH_PMDP_SET_WRPROTECT
-static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
+static inline void hlpmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pmd_t *pmdp)
 {
 
 	if ((pmd_val(*pmdp) & H_PAGE_RW) == 0)
 		return;
 
-	pmd_hugepage_update(mm, addr, pmdp, H_PAGE_RW, 0);
+	hlpmd_hugepage_update(mm, addr, pmdp, H_PAGE_RW, 0);
 }
 
 #endif /*  CONFIG_TRANSPARENT_HUGEPAGE */
+
 #endif	/* __ASSEMBLY__ */
 
 #endif /* _ASM_POWERPC_BOOK3S_64_HASH_64K_H */
diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 551daeee6870..5e66915f47ee 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -589,6 +589,22 @@ static inline void hpte_do_hugepage_flush(struct mm_struct *mm,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+extern int hlpmdp_set_access_flags(struct vm_area_struct *vma,
+				   unsigned long address, pmd_t *pmdp,
+				   pmd_t entry, int dirty);
+extern int hlpmdp_test_and_clear_young(struct vm_area_struct *vma,
+				       unsigned long address, pmd_t *pmdp);
+extern pmd_t hlpmdp_huge_get_and_clear(struct mm_struct *mm,
+				       unsigned long addr, pmd_t *pmdp);
+extern pmd_t hlpmdp_collapse_flush(struct vm_area_struct *vma,
+				   unsigned long address, pmd_t *pmdp);
+extern void hlpgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+					 pgtable_t pgtable);
+extern pgtable_t hlpgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
+extern void hlpmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+			      pmd_t *pmdp);
+extern void hlpmdp_huge_splitting_flush(struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmdp);
 extern int hlmap_kernel_page(unsigned long ea, unsigned long pa, int flags);
 extern void hlpgtable_cache_init(void);
 extern void __meminit hlvmemmap_create_mapping(unsigned long start,
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index dd5a2344342a..921784c0aa05 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -512,14 +512,98 @@ static inline void update_mmu_cache(struct vm_area_struct *vma, unsigned long ad
 struct page *realmode_pfn_to_page(unsigned long pfn);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
-extern pmd_t mk_pmd(struct page *page, pgprot_t pgprot);
-extern pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot);
-extern void set_pmd_at(struct mm_struct *mm, unsigned long addr,
-		       pmd_t *pmdp, pmd_t pmd);
-extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
-				 pmd_t *pmd);
-extern int has_transparent_hugepage(void);
+/*
+ *
+ * For core kernel code by design pmd_trans_huge is never run on any hugetlbfs
+ * page. The hugetlbfs page table walking and mangling paths are totally
+ * separated form the core VM paths and they're differentiated by
+ *  VM_HUGETLB being set on vm_flags well before any pmd_trans_huge could run.
+ *
+ * pmd_trans_huge() is defined as false at build time if
+ * CONFIG_TRANSPARENT_HUGEPAGE=n to optimize away code blocks at build
+ * time in such case.
+ *
+ * For ppc64 we need to differntiate from explicit hugepages from THP, because
+ * for THP we also track the subpage details at the pmd level. We don't do
+ * that for explicit huge pages.
+ *
+ */
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+	return hlpmd_trans_huge(pmd);
+}
+
+static inline pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
+{
+	return pfn_hlpmd(pfn, pgprot);
+}
+
+static inline pmd_t mk_pmd(struct page *page, pgprot_t pgprot)
+{
+	return mk_hlpmd(page, pgprot);
+}
+
+static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	return hlpmd_modify(pmd, newprot);
+}
+/*
+ * This is called at the end of handling a user page fault, when the
+ * fault has been handled by updating a HUGE PMD entry in the linux page tables.
+ * We use it to preload an HPTE into the hash table corresponding to
+ * the updated linux HUGE PMD entry.
+ */
+static inline void update_mmu_cache_pmd(struct vm_area_struct *vma,
+					unsigned long addr, pmd_t *pmd)
+{
+	return;
+}
+
+static inline int has_transparent_hugepage(void)
+{
+	return hl_has_transparent_hugepage();
+}
+
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t pmd)
+{
+	return set_hlpmd_at(mm, addr, pmdp, pmd);
+}
+
+static inline int pmd_large(pmd_t pmd)
+{
+	return hlpmd_large(pmd);
+}
+
+static inline pmd_t pmd_mknotpresent(pmd_t pmd)
+{
+	return hlpmd_mknotpresent(pmd);
+}
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	return hlpmd_mkhuge(pmd);
+}
+
+#define __HAVE_ARCH_PMD_SAME
+static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
+{
+	return hlpmd_same(pmd_a, pmd_b);
+}
+
+static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
+					      unsigned long addr, pmd_t *pmdp)
+{
+	return __hlpmdp_test_and_clear_young(mm, addr, pmdp);
+}
+
+#define __HAVE_ARCH_PMDP_SET_WRPROTECT
+static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
+				      pmd_t *pmdp)
+{
+	return hlpmdp_set_wrprotect(mm, addr, pmdp);
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 
@@ -564,41 +648,62 @@ static inline int pmd_protnone(pmd_t pmd)
 #define __HAVE_ARCH_PMD_WRITE
 #define pmd_write(pmd)		pte_write(pmd_pte(pmd))
 
-static inline pmd_t pmd_mkhuge(pmd_t pmd)
+#define __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
+static inline int pmdp_set_access_flags(struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmdp,
+					pmd_t entry, int dirty)
 {
-	return __pmd(pmd_val(pmd) | (H_PAGE_PTE | H_PAGE_THP_HUGE));
+	return hlpmdp_set_access_flags(vma, address, pmdp, entry, dirty);
 }
 
-#define __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
-extern int pmdp_set_access_flags(struct vm_area_struct *vma,
-				 unsigned long address, pmd_t *pmdp,
-				 pmd_t entry, int dirty);
-
 #define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
-extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
-				     unsigned long address, pmd_t *pmdp);
+static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+					    unsigned long address, pmd_t *pmdp)
+{
+	return hlpmdp_test_and_clear_young(vma, address, pmdp);
+}
+
 
 #define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
-extern pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
-				     unsigned long addr, pmd_t *pmdp);
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long addr, pmd_t *pmdp)
+{
+	return hlpmdp_huge_get_and_clear(mm, addr, pmdp);
+}
 
-extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
-				 unsigned long address, pmd_t *pmdp);
+static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmdp)
+{
+	return hlpmdp_collapse_flush(vma, address, pmdp);
+}
 #define pmdp_collapse_flush pmdp_collapse_flush
 
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
-extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
-				       pgtable_t pgtable);
+static inline void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+					      pgtable_t pgtable)
+{
+	return hlpgtable_trans_huge_deposit(mm, pmdp, pgtable);
+}
+
 #define __HAVE_ARCH_PGTABLE_WITHDRAW
-extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
+static inline pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
+{
+	return hlpgtable_trans_huge_withdraw(mm, pmdp);
+}
 
 #define __HAVE_ARCH_PMDP_INVALIDATE
-extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
-			    pmd_t *pmdp);
+static inline void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+				   pmd_t *pmdp)
+{
+	return hlpmdp_invalidate(vma, address, pmdp);
+}
 
 #define __HAVE_ARCH_PMDP_HUGE_SPLITTING_FLUSH
-extern void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
-				      unsigned long address, pmd_t *pmdp);
+static inline void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
+					     unsigned long address, pmd_t *pmdp)
+{
+	return hlpmdp_huge_splitting_flush(vma, address, pmdp);
+}
 
 #define pmd_move_must_withdraw pmd_move_must_withdraw
 struct spinlock;
diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
index 0a7c73779771..7d2ff85e62ea 100644
--- a/arch/powerpc/mm/pgtable-hash64.c
+++ b/arch/powerpc/mm/pgtable-hash64.c
@@ -258,17 +258,17 @@ void set_hlpte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
  * handled those two for us, we additionally deal with missing execute
  * permission here on some processors
  */
-int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp, pmd_t entry, int dirty)
+int hlpmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
+			    pmd_t *pmdp, pmd_t entry, int dirty)
 {
 	int changed;
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON(!pmd_trans_huge(*pmdp));
+	WARN_ON(!hlpmd_trans_huge(*pmdp));
 	assert_spin_locked(&vma->vm_mm->page_table_lock);
 #endif
-	changed = !pmd_same(*(pmdp), entry);
+	changed = !hlpmd_same(*(pmdp), entry);
 	if (changed) {
-		__ptep_set_access_flags(pmdp_ptep(pmdp), pmd_pte(entry));
+		__hlptep_set_access_flags(pmdp_ptep(pmdp), pmd_pte(entry));
 		/*
 		 * Since we are not supporting SW TLB systems, we don't
 		 * have any thing similar to flush_tlb_page_nohash()
@@ -277,7 +277,7 @@ int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
 	return changed;
 }
 
-unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
+unsigned long hlpmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 				  pmd_t *pmdp, unsigned long clr,
 				  unsigned long set)
 {
@@ -285,7 +285,7 @@ unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 	unsigned long old, tmp;
 
 #ifdef CONFIG_DEBUG_VM
-	WARN_ON(!pmd_trans_huge(*pmdp));
+	WARN_ON(!hlpmd_trans_huge(*pmdp));
 	assert_spin_locked(&mm->page_table_lock);
 #endif
 
@@ -311,13 +311,13 @@ unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 	return old;
 }
 
-pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
+pmd_t hlpmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
 			  pmd_t *pmdp)
 {
 	pmd_t pmd;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	VM_BUG_ON(pmd_trans_huge(*pmdp));
+	VM_BUG_ON(hlpmd_trans_huge(*pmdp));
 
 	pmd = *pmdp;
 	pmd_clear(pmdp);
@@ -358,17 +358,17 @@ pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
  * We should be more intelligent about this but for the moment we override
  * these functions and force a tlb flush unconditionally
  */
-int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+int hlpmdp_test_and_clear_young(struct vm_area_struct *vma,
 			      unsigned long address, pmd_t *pmdp)
 {
-	return __pmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
+	return __hlpmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
 }
 
 /*
  * We want to put the pgtable in pmd and use pgtable for tracking
  * the base page size hptes
  */
-void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+void hlpgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				pgtable_t pgtable)
 {
 	pgtable_t *pgtable_slot;
@@ -387,7 +387,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 	smp_wmb();
 }
 
-pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
+pgtable_t hlpgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
 	pgtable_t pgtable;
 	pgtable_t *pgtable_slot;
@@ -407,7 +407,7 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	return pgtable;
 }
 
-void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
+void hlpmdp_huge_splitting_flush(struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmdp)
 {
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
@@ -427,7 +427,7 @@ void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
 	 * the translation is still valid, because we will withdraw
 	 * pgtable_t after this.
 	 */
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, H_PAGE_USER, 0);
+	hlpmd_hugepage_update(vma->vm_mm, address, pmdp, H_PAGE_USER, 0);
 }
 
 
@@ -435,27 +435,27 @@ void pmdp_huge_splitting_flush(struct vm_area_struct *vma,
  * set a new huge pmd. We should not be called for updating
  * an existing pmd entry. That should go via pmd_hugepage_update.
  */
-void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+void set_hlpmd_at(struct mm_struct *mm, unsigned long addr,
 		pmd_t *pmdp, pmd_t pmd)
 {
 #ifdef CONFIG_DEBUG_VM
 	WARN_ON((pmd_val(*pmdp) & (H_PAGE_PRESENT | H_PAGE_USER)) ==
 		(H_PAGE_PRESENT | H_PAGE_USER));
 	assert_spin_locked(&mm->page_table_lock);
-	WARN_ON(!pmd_trans_huge(pmd));
+	WARN_ON(!hlpmd_trans_huge(pmd));
 #endif
 	trace_hugepage_set_pmd(addr, pmd_val(pmd));
-	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
+	return set_hlpte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
 }
 
 /*
  * We use this to invalidate a pmdp entry before switching from a
  * hugepte to regular pmd entry.
  */
-void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+void hlpmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
+	hlpmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
 	/*
 	 * This ensures that generic code that rely on IRQ disabling
 	 * to prevent a parallel THP split work as expected.
@@ -502,31 +502,31 @@ void hpte_do_hugepage_flush(struct mm_struct *mm, unsigned long addr,
 	return flush_hash_hugepage(vsid, addr, pmdp, psize, ssize, flags);
 }
 
-static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
+static pmd_t hlpmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
 {
 	return __pmd(pmd_val(pmd) | pgprot_val(pgprot));
 }
 
-pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
+pmd_t pfn_hlpmd(unsigned long pfn, pgprot_t pgprot)
 {
 	unsigned long pmdv;
 
 	pmdv = pfn << H_PTE_RPN_SHIFT;
-	return pmd_set_protbits(__pmd(pmdv), pgprot);
+	return hlpmd_set_protbits(__pmd(pmdv), pgprot);
 }
 
-pmd_t mk_pmd(struct page *page, pgprot_t pgprot)
+pmd_t mk_hlpmd(struct page *page, pgprot_t pgprot)
 {
-	return pfn_pmd(page_to_pfn(page), pgprot);
+	return pfn_hlpmd(page_to_pfn(page), pgprot);
 }
 
-pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+pmd_t hlpmd_modify(pmd_t pmd, pgprot_t newprot)
 {
 	unsigned long pmdv;
 
 	pmdv = pmd_val(pmd);
 	pmdv &= H_HPAGE_CHG_MASK;
-	return pmd_set_protbits(__pmd(pmdv), newprot);
+	return hlpmd_set_protbits(__pmd(pmdv), newprot);
 }
 
 /*
@@ -535,13 +535,13 @@ pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
  * We use it to preload an HPTE into the hash table corresponding to
  * the updated linux HUGE PMD entry.
  */
-void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
+void hlupdate_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 			  pmd_t *pmd)
 {
 	return;
 }
 
-pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+pmd_t hlpmdp_huge_get_and_clear(struct mm_struct *mm,
 			      unsigned long addr, pmd_t *pmdp)
 {
 	pmd_t old_pmd;
@@ -549,7 +549,7 @@ pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 	unsigned long old;
 	pgtable_t *pgtable_slot;
 
-	old = pmd_hugepage_update(mm, addr, pmdp, ~0UL, 0);
+	old = hlpmd_hugepage_update(mm, addr, pmdp, ~0UL, 0);
 	old_pmd = __pmd(old);
 	/*
 	 * We have pmd == none and we are holding page_table_lock.
@@ -577,7 +577,7 @@ pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 	return old_pmd;
 }
 
-int has_transparent_hugepage(void)
+int hl_has_transparent_hugepage(void)
 {
 
 	BUILD_BUG_ON_MSG((H_PMD_SHIFT - PAGE_SHIFT) >= MAX_ORDER,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
