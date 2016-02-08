Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id CD482830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:46 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wb13so146221258obb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:46 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id i5si14645517obh.19.2016.02.08.01.21.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:40 -0800 (PST)
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:40 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id ECEE21FF0041
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:45 -0700 (MST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LZQJ31850572
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:35 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LYEO012539
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:35 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 20/29] powerpc/mm: Hash linux abstraction for page table accessors
Date: Mon,  8 Feb 2016 14:50:32 +0530
Message-Id: <1454923241-6681-21-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will later make the generic functions do conditial radix or hash
page table access. This patch doesn't do hugepage api update yet.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash.h    | 133 +++++++-------
 arch/powerpc/include/asm/book3s/64/pgtable.h | 251 ++++++++++++++++++++++++++-
 arch/powerpc/mm/hash_utils_64.c              |   6 +-
 3 files changed, 324 insertions(+), 66 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 890c81014dc7..d80c4c7fa6c1 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -221,18 +221,18 @@
 #define H_PUD_BAD_BITS		(H_PMD_TABLE_SIZE-1)
 
 #ifndef __ASSEMBLY__
-#define	pmd_bad(pmd)		(!is_kernel_addr(pmd_val(pmd)) \
+#define	hlpmd_bad(pmd)		(!is_kernel_addr(pmd_val(pmd))		\
 				 || (pmd_val(pmd) & H_PMD_BAD_BITS))
-#define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~H_PMD_MASKED_BITS)
+#define hlpmd_page_vaddr(pmd)	(pmd_val(pmd) & ~H_PMD_MASKED_BITS)
 
-#define	pud_bad(pud)		(!is_kernel_addr(pud_val(pud)) \
+#define	hlpud_bad(pud)		(!is_kernel_addr(pud_val(pud))		\
 				 || (pud_val(pud) & H_PUD_BAD_BITS))
-#define pud_page_vaddr(pud)	(pud_val(pud) & ~H_PUD_MASKED_BITS)
+#define hlpud_page_vaddr(pud)	(pud_val(pud) & ~H_PUD_MASKED_BITS)
 
-#define pgd_index(address) (((address) >> (H_PGDIR_SHIFT)) & (H_PTRS_PER_PGD - 1))
-#define pud_index(address) (((address) >> (H_PUD_SHIFT)) & (H_PTRS_PER_PUD - 1))
-#define pmd_index(address) (((address) >> (H_PMD_SHIFT)) & (H_PTRS_PER_PMD - 1))
-#define pte_index(address) (((address) >> (PAGE_SHIFT)) & (H_PTRS_PER_PTE - 1))
+#define hlpgd_index(address) (((address) >> (H_PGDIR_SHIFT)) & (H_PTRS_PER_PGD - 1))
+#define hlpud_index(address) (((address) >> (H_PUD_SHIFT)) & (H_PTRS_PER_PUD - 1))
+#define hlpmd_index(address) (((address) >> (H_PMD_SHIFT)) & (H_PTRS_PER_PMD - 1))
+#define hlpte_index(address) (((address) >> (PAGE_SHIFT)) & (H_PTRS_PER_PTE - 1))
 
 /* Encode and de-code a swap entry */
 #define MAX_SWAPFILES_CHECK() do { \
@@ -290,11 +290,11 @@ extern void hpte_need_flush(struct mm_struct *mm, unsigned long addr,
 			    pte_t *ptep, unsigned long pte, int huge);
 extern unsigned long htab_convert_pte_flags(unsigned long pteflags);
 /* Atomic PTE updates */
-static inline unsigned long pte_update(struct mm_struct *mm,
-				       unsigned long addr,
-				       pte_t *ptep, unsigned long clr,
-				       unsigned long set,
-				       int huge)
+static inline unsigned long hlpte_update(struct mm_struct *mm,
+					 unsigned long addr,
+					 pte_t *ptep, unsigned long clr,
+					 unsigned long set,
+					 int huge)
 {
 	unsigned long old, tmp;
 
@@ -327,42 +327,41 @@ static inline unsigned long pte_update(struct mm_struct *mm,
  * We should be more intelligent about this but for the moment we override
  * these functions and force a tlb flush unconditionally
  */
-static inline int __ptep_test_and_clear_young(struct mm_struct *mm,
+static inline int __hlptep_test_and_clear_young(struct mm_struct *mm,
 					      unsigned long addr, pte_t *ptep)
 {
 	unsigned long old;
 
 	if ((pte_val(*ptep) & (H_PAGE_ACCESSED | H_PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pte_update(mm, addr, ptep, H_PAGE_ACCESSED, 0, 0);
+	old = hlpte_update(mm, addr, ptep, H_PAGE_ACCESSED, 0, 0);
 	return (old & H_PAGE_ACCESSED) != 0;
 }
 
-#define __HAVE_ARCH_PTEP_SET_WRPROTECT
-static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
+static inline void hlptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pte_t *ptep)
 {
 
 	if ((pte_val(*ptep) & H_PAGE_RW) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, H_PAGE_RW, 0, 0);
+	hlpte_update(mm, addr, ptep, H_PAGE_RW, 0, 0);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_hlptep_set_wrprotect(struct mm_struct *mm,
 					   unsigned long addr, pte_t *ptep)
 {
 	if ((pte_val(*ptep) & H_PAGE_RW) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, H_PAGE_RW, 0, 1);
+	hlpte_update(mm, addr, ptep, H_PAGE_RW, 0, 1);
 }
 
 
 /* Set the dirty and/or accessed bits atomically in a linux PTE, this
  * function doesn't need to flush the hash entry
  */
-static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
+static inline void __hlptep_set_access_flags(pte_t *ptep, pte_t entry)
 {
 	unsigned long bits = pte_val(entry) &
 		(H_PAGE_DIRTY | H_PAGE_ACCESSED | H_PAGE_RW | H_PAGE_EXEC |
@@ -382,23 +381,46 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 	:"cc");
 }
 
-static inline int pgd_bad(pgd_t pgd)
+static inline int hlpgd_bad(pgd_t pgd)
 {
 	return (pgd_val(pgd) == 0);
 }
 
 #define __HAVE_ARCH_PTE_SAME
-#define pte_same(A,B)	(((pte_val(A) ^ pte_val(B)) & ~H_PAGE_HPTEFLAGS) == 0)
-#define pgd_page_vaddr(pgd)	(pgd_val(pgd) & ~H_PGD_MASKED_BITS)
+#define hlpte_same(A, B)	(((pte_val(A) ^ pte_val(B)) & ~H_PAGE_HPTEFLAGS) == 0)
+#define hlpgd_page_vaddr(pgd)	(pgd_val(pgd) & ~H_PGD_MASKED_BITS)
 
 
 /* Generic accessors to PTE bits */
-static inline int pte_write(pte_t pte)		{ return !!(pte_val(pte) & H_PAGE_RW);}
-static inline int pte_dirty(pte_t pte)		{ return !!(pte_val(pte) & H_PAGE_DIRTY); }
-static inline int pte_young(pte_t pte)		{ return !!(pte_val(pte) & H_PAGE_ACCESSED); }
-static inline int pte_special(pte_t pte)	{ return !!(pte_val(pte) & H_PAGE_SPECIAL); }
-static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~H_PTE_NONE_MASK) == 0; }
-static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & H_PAGE_PROT_BITS); }
+static inline int hlpte_write(pte_t pte)
+{
+	return !!(pte_val(pte) & H_PAGE_RW);
+}
+
+static inline int hlpte_dirty(pte_t pte)
+{
+	return !!(pte_val(pte) & H_PAGE_DIRTY);
+}
+
+static inline int hlpte_young(pte_t pte)
+{
+	return !!(pte_val(pte) & H_PAGE_ACCESSED);
+}
+
+static inline int hlpte_special(pte_t pte)
+{
+	return !!(pte_val(pte) & H_PAGE_SPECIAL);
+}
+
+static inline int hlpte_none(pte_t pte)
+{
+	return (pte_val(pte) & ~H_PTE_NONE_MASK) == 0;
+}
+
+static inline pgprot_t hlpte_pgprot(pte_t pte)
+{
+	return __pgprot(pte_val(pte) & H_PAGE_PROT_BITS);
+}
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline bool pte_soft_dirty(pte_t pte)
@@ -422,14 +444,14 @@ static inline pte_t pte_clear_soft_dirty(pte_t pte)
  * comment in include/asm-generic/pgtable.h . On powerpc, this will only
  * work for user pages and always return true for kernel pages.
  */
-static inline int pte_protnone(pte_t pte)
+static inline int hlpte_protnone(pte_t pte)
 {
 	return (pte_val(pte) &
 		(H_PAGE_PRESENT | H_PAGE_USER)) == H_PAGE_PRESENT;
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
-static inline int pte_present(pte_t pte)
+static inline int hlpte_present(pte_t pte)
 {
 	return pte_val(pte) & H_PAGE_PRESENT;
 }
@@ -440,59 +462,59 @@ static inline int pte_present(pte_t pte)
  * Even if PTEs can be unsigned long long, a PFN is always an unsigned
  * long for now.
  */
-static inline pte_t pfn_pte(unsigned long pfn, pgprot_t pgprot)
+static inline pte_t pfn_hlpte(unsigned long pfn, pgprot_t pgprot)
 {
 	return __pte(((pte_basic_t)(pfn) << H_PTE_RPN_SHIFT) |
 		     pgprot_val(pgprot));
 }
 
-static inline unsigned long pte_pfn(pte_t pte)
+static inline unsigned long hlpte_pfn(pte_t pte)
 {
 	return pte_val(pte) >> H_PTE_RPN_SHIFT;
 }
 
 /* Generic modifiers for PTE bits */
-static inline pte_t pte_wrprotect(pte_t pte)
+static inline pte_t hlpte_wrprotect(pte_t pte)
 {
 	return __pte(pte_val(pte) & ~H_PAGE_RW);
 }
 
-static inline pte_t pte_mkclean(pte_t pte)
+static inline pte_t hlpte_mkclean(pte_t pte)
 {
 	return __pte(pte_val(pte) & ~H_PAGE_DIRTY);
 }
 
-static inline pte_t pte_mkold(pte_t pte)
+static inline pte_t hlpte_mkold(pte_t pte)
 {
 	return __pte(pte_val(pte) & ~H_PAGE_ACCESSED);
 }
 
-static inline pte_t pte_mkwrite(pte_t pte)
+static inline pte_t hlpte_mkwrite(pte_t pte)
 {
 	return __pte(pte_val(pte) | H_PAGE_RW);
 }
 
-static inline pte_t pte_mkdirty(pte_t pte)
+static inline pte_t hlpte_mkdirty(pte_t pte)
 {
 	return __pte(pte_val(pte) | H_PAGE_DIRTY | H_PAGE_SOFT_DIRTY);
 }
 
-static inline pte_t pte_mkyoung(pte_t pte)
+static inline pte_t hlpte_mkyoung(pte_t pte)
 {
 	return __pte(pte_val(pte) | H_PAGE_ACCESSED);
 }
 
-static inline pte_t pte_mkspecial(pte_t pte)
+static inline pte_t hlpte_mkspecial(pte_t pte)
 {
 	return __pte(pte_val(pte) | H_PAGE_SPECIAL);
 }
 
-static inline pte_t pte_mkhuge(pte_t pte)
+static inline pte_t hlpte_mkhuge(pte_t pte)
 {
 	return pte;
 }
 
-static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
+static inline pte_t hlpte_modify(pte_t pte, pgprot_t newprot)
 {
 	return __pte((pte_val(pte) & H_PAGE_CHG_MASK) | pgprot_val(newprot));
 }
@@ -502,7 +524,7 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
  * an horrible mess that I'm not going to try to clean up now but
  * I'm keeping it in one place rather than spread around
  */
-static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,
+static inline void __set_hlpte_at(struct mm_struct *mm, unsigned long addr,
 				pte_t *ptep, pte_t pte, int percpu)
 {
 	/*
@@ -519,48 +541,41 @@ static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,
 #define H_PAGE_CACHE_CTL	(H_PAGE_COHERENT | H_PAGE_GUARDED | H_PAGE_NO_CACHE | \
 				 H_PAGE_WRITETHRU)
 
-#define pgprot_noncached pgprot_noncached
-static inline pgprot_t pgprot_noncached(pgprot_t prot)
+static inline pgprot_t hlpgprot_noncached(pgprot_t prot)
 {
 	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
 			H_PAGE_NO_CACHE | H_PAGE_GUARDED);
 }
 
-#define pgprot_noncached_wc pgprot_noncached_wc
-static inline pgprot_t pgprot_noncached_wc(pgprot_t prot)
+static inline pgprot_t hlpgprot_noncached_wc(pgprot_t prot)
 {
 	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
 			H_PAGE_NO_CACHE);
 }
 
-#define pgprot_cached pgprot_cached
-static inline pgprot_t pgprot_cached(pgprot_t prot)
+static inline pgprot_t hlpgprot_cached(pgprot_t prot)
 {
 	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
 			H_PAGE_COHERENT);
 }
 
-#define pgprot_cached_wthru pgprot_cached_wthru
-static inline pgprot_t pgprot_cached_wthru(pgprot_t prot)
+static inline pgprot_t hlpgprot_cached_wthru(pgprot_t prot)
 {
 	return __pgprot((pgprot_val(prot) & ~H_PAGE_CACHE_CTL) |
 			H_PAGE_COHERENT | H_PAGE_WRITETHRU);
 }
 
-#define pgprot_cached_noncoherent pgprot_cached_noncoherent
-static inline pgprot_t pgprot_cached_noncoherent(pgprot_t prot)
+static inline pgprot_t hlpgprot_cached_noncoherent(pgprot_t prot)
 {
 	return __pgprot(pgprot_val(prot) & ~H_PAGE_CACHE_CTL);
 }
 
-#define pgprot_writecombine pgprot_writecombine
-static inline pgprot_t pgprot_writecombine(pgprot_t prot)
+static inline pgprot_t hlpgprot_writecombine(pgprot_t prot)
 {
-	return pgprot_noncached_wc(prot);
+	return hlpgprot_noncached_wc(prot);
 }
 
-extern pgprot_t vm_get_page_prot(unsigned long vm_flags);
-#define vm_get_page_prot vm_get_page_prot
+extern pgprot_t hlvm_get_page_prot(unsigned long vm_flags);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern void hpte_do_hugepage_flush(struct mm_struct *mm, unsigned long addr,
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 27829e3889fc..658a09b320f0 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -138,7 +138,7 @@ static inline int ptep_test_and_clear_young(struct vm_area_struct *vma,
 					    unsigned long address,
 					    pte_t *ptep)
 {
-	return  __ptep_test_and_clear_young(vma->vm_mm, address, ptep);
+	return  __hlptep_test_and_clear_young(vma->vm_mm, address, ptep);
 }
 
 #define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
@@ -147,7 +147,7 @@ static inline int ptep_clear_flush_young(struct vm_area_struct *vma,
 {
 	int young;
 
-	young = __ptep_test_and_clear_young(vma->vm_mm, address, ptep);
+	young = __hlptep_test_and_clear_young(vma->vm_mm, address, ptep);
 	if (young)
 		flush_tlb_page(vma, address);
 	return young;
@@ -157,7 +157,7 @@ static inline int ptep_clear_flush_young(struct vm_area_struct *vma,
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
 {
-	unsigned long old = pte_update(mm, addr, ptep, ~0UL, 0, 0);
+	unsigned long old = hlpte_update(mm, addr, ptep, ~0UL, 0, 0);
 
 	return __pte(old);
 }
@@ -165,7 +165,159 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 static inline void pte_clear(struct mm_struct *mm, unsigned long addr,
 			     pte_t *ptep)
 {
-	pte_update(mm, addr, ptep, ~0UL, 0, 0);
+	hlpte_update(mm, addr, ptep, ~0UL, 0, 0);
+}
+
+static inline int pte_index(unsigned long addr)
+{
+	return hlpte_index(addr);
+}
+
+static inline unsigned long pte_update(struct mm_struct *mm,
+				       unsigned long addr,
+				       pte_t *ptep, unsigned long clr,
+				       unsigned long set,
+				       int huge)
+{
+	return hlpte_update(mm, addr, ptep, clr, set, huge);
+}
+
+static inline int __ptep_test_and_clear_young(struct mm_struct *mm,
+					      unsigned long addr, pte_t *ptep)
+{
+	return __hlptep_test_and_clear_young(mm, addr, ptep);
+
+}
+
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
+				      pte_t *ptep)
+{
+	return hlptep_set_wrprotect(mm, addr, ptep);
+}
+
+static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+					   unsigned long addr, pte_t *ptep)
+{
+	return huge_hlptep_set_wrprotect(mm, addr, ptep);
+}
+
+
+/* Set the dirty and/or accessed bits atomically in a linux PTE, this
+ * function doesn't need to flush the hash entry
+ */
+static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
+{
+	return __hlptep_set_access_flags(ptep, entry);
+}
+
+#define __HAVE_ARCH_PTE_SAME
+static inline int pte_same(pte_t pte_a, pte_t pte_b)
+{
+	return hlpte_same(pte_a, pte_b);
+}
+
+static inline int pte_write(pte_t pte)
+{
+	return hlpte_write(pte);
+}
+
+static inline int pte_dirty(pte_t pte)
+{
+	return hlpte_dirty(pte);
+}
+
+static inline int pte_young(pte_t pte)
+{
+	return hlpte_young(pte);
+}
+
+static inline int pte_special(pte_t pte)
+{
+	return hlpte_special(pte);
+}
+
+static inline int pte_none(pte_t pte)
+{
+	return hlpte_none(pte);
+}
+
+static inline pgprot_t pte_pgprot(pte_t pte)
+{
+	return hlpte_pgprot(pte);
+}
+
+static inline pte_t pfn_pte(unsigned long pfn, pgprot_t pgprot)
+{
+	return pfn_hlpte(pfn, pgprot);
+}
+
+static inline unsigned long pte_pfn(pte_t pte)
+{
+	return hlpte_pfn(pte);
+}
+
+static inline pte_t pte_wrprotect(pte_t pte)
+{
+	return hlpte_wrprotect(pte);
+}
+
+static inline pte_t pte_mkclean(pte_t pte)
+{
+	return hlpte_mkclean(pte);
+}
+
+static inline pte_t pte_mkold(pte_t pte)
+{
+	return hlpte_mkold(pte);
+}
+
+static inline pte_t pte_mkwrite(pte_t pte)
+{
+	return hlpte_mkwrite(pte);
+}
+
+static inline pte_t pte_mkdirty(pte_t pte)
+{
+	return hlpte_mkdirty(pte);
+}
+
+static inline pte_t pte_mkyoung(pte_t pte)
+{
+	return hlpte_mkyoung(pte);
+}
+
+static inline pte_t pte_mkspecial(pte_t pte)
+{
+	return hlpte_mkspecial(pte);
+}
+
+static inline pte_t pte_mkhuge(pte_t pte)
+{
+	return hlpte_mkhuge(pte);
+}
+
+static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
+{
+	return hlpte_modify(pte, newprot);
+}
+
+static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,
+				pte_t *ptep, pte_t pte, int percpu)
+{
+	return __set_hlpte_at(mm, addr, ptep, pte, percpu);
+}
+
+#ifdef CONFIG_NUMA_BALANCING
+static inline int pte_protnone(pte_t pte)
+{
+	return hlpte_protnone(pte);
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
+static inline int pte_present(pte_t pte)
+{
+	return hlpte_present(pte);
 }
 
 static inline void pmd_set(pmd_t *pmdp, unsigned long val)
@@ -178,6 +330,22 @@ static inline void pmd_clear(pmd_t *pmdp)
 	*pmdp = __pmd(0);
 }
 
+static inline int pmd_bad(pmd_t pmd)
+{
+	return hlpmd_bad(pmd);
+}
+
+static inline unsigned long pmd_page_vaddr(pmd_t pmd)
+{
+	return hlpmd_page_vaddr(pmd);
+}
+
+static inline int pmd_index(unsigned long addr)
+{
+	return hlpmd_index(addr);
+}
+
+
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define	pmd_present(pmd)	(!pmd_none(pmd))
 
@@ -205,6 +373,22 @@ static inline pud_t pte_pud(pte_t pte)
 {
 	return __pud(pte_val(pte));
 }
+
+static inline int pud_bad(pud_t pud)
+{
+	return hlpud_bad(pud);
+}
+
+static inline unsigned long pud_page_vaddr(pud_t pud)
+{
+	return hlpud_page_vaddr(pud);
+}
+
+static inline int pud_index(unsigned long addr)
+{
+	return hlpud_index(addr);
+}
+
 #define pud_write(pud)		pte_write(pud_pte(pud))
 #define pgd_write(pgd)		pte_write(pgd_pte(pgd))
 static inline void pgd_set(pgd_t *pgdp, unsigned long val)
@@ -230,6 +414,21 @@ static inline pgd_t pte_pgd(pte_t pte)
 	return __pgd(pte_val(pte));
 }
 
+static inline int pgd_bad(pgd_t pgd)
+{
+	return hlpgd_bad(pgd);
+}
+
+static inline unsigned long pgd_page_vaddr(pgd_t pgd)
+{
+	return hlpgd_page_vaddr(pgd);
+}
+
+static inline int pgd_index(unsigned long addr)
+{
+	return hlpgd_index(addr);
+}
+
 extern struct page *pgd_page(pgd_t pgd);
 
 /*
@@ -368,5 +567,49 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
 	 */
 	return true;
 }
+
+#define pgprot_noncached pgprot_noncached
+static inline pgprot_t pgprot_noncached(pgprot_t prot)
+{
+	return hlpgprot_noncached(prot);
+}
+
+#define pgprot_noncached_wc pgprot_noncached_wc
+static inline pgprot_t pgprot_noncached_wc(pgprot_t prot)
+{
+	return hlpgprot_noncached_wc(prot);
+}
+
+#define pgprot_cached pgprot_cached
+static inline pgprot_t pgprot_cached(pgprot_t prot)
+{
+	return hlpgprot_cached(prot);
+}
+
+#define pgprot_cached_wthru pgprot_cached_wthru
+static inline pgprot_t pgprot_cached_wthru(pgprot_t prot)
+{
+	return hlpgprot_cached_wthru(prot);
+}
+
+#define pgprot_cached_noncoherent pgprot_cached_noncoherent
+static inline pgprot_t pgprot_cached_noncoherent(pgprot_t prot)
+{
+	return hlpgprot_cached_noncoherent(prot);
+}
+
+#define pgprot_writecombine pgprot_writecombine
+static inline pgprot_t pgprot_writecombine(pgprot_t prot)
+{
+	return hlpgprot_writecombine(prot);
+}
+
+/* We want to override core implementation of this for book3s 64 */
+#define vm_get_page_prot vm_get_page_prot
+static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
+{
+	return hlvm_get_page_prot(vm_flags);
+}
+
 #endif /* __ASSEMBLY__ */
 #endif /* _ASM_POWERPC_BOOK3S_64_PGTABLE_H_ */
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index d5fcd96d9b63..aec47cf45db2 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -860,7 +860,7 @@ unsigned int hash_page_do_lazy_icache(unsigned int pp, pte_t pte, int trap)
 {
 	struct page *page;
 
-	if (!pfn_valid(pte_pfn(pte)))
+	if (!pfn_valid(hlpte_pfn(pte)))
 		return pp;
 
 	page = pte_page(pte);
@@ -1602,7 +1602,7 @@ static pgprot_t hash_protection_map[16] = {
 	__HS010, __HS011, __HS100, __HS101, __HS110, __HS111
 };
 
-pgprot_t vm_get_page_prot(unsigned long vm_flags)
+pgprot_t hlvm_get_page_prot(unsigned long vm_flags)
 {
 	pgprot_t prot_soa = __pgprot(0);
 
@@ -1613,4 +1613,4 @@ pgprot_t vm_get_page_prot(unsigned long vm_flags)
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
 			pgprot_val(prot_soa));
 }
-EXPORT_SYMBOL(vm_get_page_prot);
+EXPORT_SYMBOL(hlvm_get_page_prot);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
