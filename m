Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B9AE16B0085
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:27:59 -0400 (EDT)
Date: Tue, 02 Oct 2012 18:27:57 -0400 (EDT)
Message-Id: <20121002.182757.311213069815414833.davem@davemloft.net>
Subject: [PATCH 8/8] sparc64: Support transparent huge pages.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


This is relatively easy since PMD's now cover exactly 4MB of memory.

Our PMD entries are 32-bits each, so we use a special encoding.  The
lowest bit, PMD_ISHUGE, determines the interpreation.  This is
possible because sparc64's page tables are purely software entities so
we can use whatever encoding scheme we want.  We just have to make the
TLB miss assembler page table walkers aware of the layout.

set_pmd_at() works much like set_pte_at() but it has to operate in two
different regimes.  In the first regime, we are collapsing into a huge
page from a table of non-huge PTEs, so we have to queue up TLB flushes
based upon what mappings are valid in the PTE table.  In the second
regime we are going from huge-page to non-huge-page, and in that case
we need only queue up a single TLB flush to push out the huge page
mapping.

We still have 5 bits remaining in the huge PMD encoding so we can very
likely support any new pieces of THP state tracking that might get
added in the future.

With lots of help from Johannes Weiner.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/hugetlb.h        |    5 +-
 arch/sparc/include/asm/mmu_64.h         |    2 +-
 arch/sparc/include/asm/mmu_context_64.h |    2 +-
 arch/sparc/include/asm/page_64.h        |    7 +-
 arch/sparc/include/asm/pgalloc_64.h     |   27 ++++-
 arch/sparc/include/asm/pgtable_64.h     |  169 ++++++++++++++++++++++++++++--
 arch/sparc/include/asm/tsb.h            |   94 +++++++++++++++--
 arch/sparc/kernel/sun4v_tlb_miss.S      |    2 +-
 arch/sparc/kernel/tsb.S                 |    9 +-
 arch/sparc/mm/fault_64.c                |    4 +-
 arch/sparc/mm/hugetlbpage.c             |   50 ---------
 arch/sparc/mm/init_64.c                 |  170 +++++++++++++++++++++++++++++--
 arch/sparc/mm/tlb.c                     |   86 ++++++++++++----
 arch/sparc/mm/tsb.c                     |   14 +--
 mm/Kconfig                              |    2 +-
 15 files changed, 530 insertions(+), 113 deletions(-)

diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 1770610..cf42843 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -10,7 +10,10 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep);
 
-void hugetlb_prefault_arch_hook(struct mm_struct *mm);
+static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
+{
+	hugetlb_setup(mm);
+}
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
 					 unsigned long addr,
diff --git a/arch/sparc/include/asm/mmu_64.h b/arch/sparc/include/asm/mmu_64.h
index 0acfb46..61681af 100644
--- a/arch/sparc/include/asm/mmu_64.h
+++ b/arch/sparc/include/asm/mmu_64.h
@@ -89,7 +89,7 @@ struct tsb_config {
 
 #define MM_TSB_BASE	0
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 #define MM_TSB_HUGE	1
 #define MM_NUM_TSBS	2
 #else
diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index a97fd08..9191ca6 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -36,7 +36,7 @@ static inline void tsb_context_switch(struct mm_struct *mm)
 {
 	__tsb_context_switch(__pa(mm->pgd),
 			     &mm->context.tsb_block[0],
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 			     (mm->context.tsb_block[1].tsb ?
 			      &mm->context.tsb_block[1] :
 			      NULL)
diff --git a/arch/sparc/include/asm/page_64.h b/arch/sparc/include/asm/page_64.h
index fc2b229..3b03cf1 100644
--- a/arch/sparc/include/asm/page_64.h
+++ b/arch/sparc/include/asm/page_64.h
@@ -23,7 +23,7 @@
 
 #define HPAGE_SHIFT		22
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 #define HPAGE_SIZE		(_AC(1,UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1UL))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
@@ -32,6 +32,11 @@
 
 #ifndef __ASSEMBLY__
 
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
+struct mm_struct;
+extern void hugetlb_setup(struct mm_struct *mm);
+#endif
+
 #define WANT_PAGE_VIRTUAL
 
 extern void _clear_page(void *page);
diff --git a/arch/sparc/include/asm/pgalloc_64.h b/arch/sparc/include/asm/pgalloc_64.h
index 0ebca93..6a72d8f 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -45,8 +45,8 @@ extern pgtable_t pte_alloc_one(struct mm_struct *mm,
 extern void pte_free_kernel(struct mm_struct *mm, pte_t *pte);
 extern void pte_free(struct mm_struct *mm, pgtable_t ptepage);
 
-#define pmd_populate_kernel(MM, PMD, PTE)	pmd_set(PMD, PTE)
-#define pmd_populate(MM, PMD, PTE)		pmd_set(PMD, PTE)
+#define pmd_populate_kernel(MM, PMD, PTE)	pmd_set(MM, PMD, PTE)
+#define pmd_populate(MM, PMD, PTE)		pmd_set(MM, PMD, PTE)
 #define pmd_pgtable(PMD)			((pte_t *)__pmd_page(PMD))
 
 #define check_pgt_cache()	do { } while (0)
@@ -91,4 +91,27 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pte_t *pte,
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
 	pgtable_free_tlb(tlb, pmd, false)
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void pmd_huge_pte_insert(struct mm_struct *mm, pgtable_t pgtable)
+{
+	pte_t **ptep = (pte_t **) pgtable;
+
+	*ptep = mm->pmd_huge_pte;
+	mm->pmd_huge_pte = (pte_t *) ptep;
+}
+
+static inline pgtable_t pmd_huge_pte_remove(struct mm_struct *mm)
+{
+	pte_t *pte = mm->pmd_huge_pte;
+
+	if (pte) {
+		pte_t **ptep = (pte_t **) pte;
+
+		mm->pmd_huge_pte = *ptep;
+		*ptep = NULL;
+	}
+	return pte;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 #endif /* _SPARC64_PGALLOC_H */
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index e77f363..0586149 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -63,10 +63,31 @@
 #error Page table parameters do not cover virtual address space properly.
 #endif
 
+#if (PMD_SHIFT != HPAGE_SHIFT)
+#error PMD_SHIFT must equal HPAGE_SHIFT for transparent huge pages.
+#endif
+
 /* PMDs point to PTE tables which are 4K aligned.  */
 #define PMD_PADDR	_AC(0xfffffffe,UL)
 #define PMD_PADDR_SHIFT	_AC(11,UL)
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define PMD_ISHUGE	_AC(0x00000001,UL)
+
+/* This is the PMD layout when PMD_ISHUGE is set.  With 4MB huge
+ * pages, this frees up a bunch of bits in the layout that we can
+ * use for the protection settings and software metadata.
+ */
+#define PMD_HUGE_PADDR		_AC(0xfffff800,UL)
+#define PMD_HUGE_PROTBITS	_AC(0x000007ff,UL)
+#define PMD_HUGE_PRESENT	_AC(0x00000400,UL)
+#define PMD_HUGE_WRITE		_AC(0x00000200,UL)
+#define PMD_HUGE_DIRTY		_AC(0x00000100,UL)
+#define PMD_HUGE_ACCESSED	_AC(0x00000080,UL)
+#define PMD_HUGE_EXEC		_AC(0x00000040,UL)
+#define PMD_HUGE_SPLITTING	_AC(0x00000020,UL)
+#endif
+
 /* PGDs point to PMD tables which are 8K aligned.  */
 #define PGD_PADDR	_AC(0xfffffffc,UL)
 #define PGD_PADDR_SHIFT	_AC(11,UL)
@@ -240,6 +261,19 @@ static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 }
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot);
+#define mk_pmd(page, pgprot)	pfn_pmd(page_to_pfn(page), (pgprot))
+
+extern pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot);
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	/* Do nothing, mk_pmd() does this part.  */
+	return pmd;
+}
+#endif
+
 /* This one can be done with two shifts.  */
 static inline unsigned long pte_pfn(pte_t pte)
 {
@@ -608,19 +642,128 @@ static inline unsigned long pte_special(pte_t pte)
 	return pte_val(pte) & _PAGE_SPECIAL;
 }
 
-#define pmd_set(pmdp, ptep)	\
-	(pmd_val(*(pmdp)) = (__pa((unsigned long) (ptep)) >> PMD_PADDR_SHIFT))
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline int pmd_young(pmd_t pmd)
+{
+	return pmd_val(pmd) & PMD_HUGE_ACCESSED;
+}
+
+static inline int pmd_write(pmd_t pmd)
+{
+	return pmd_val(pmd) & PMD_HUGE_WRITE;
+}
+
+static inline unsigned long pmd_pfn(pmd_t pmd)
+{
+	unsigned long val = pmd_val(pmd) & PMD_HUGE_PADDR;
+
+	return val >> (PAGE_SHIFT - PMD_PADDR_SHIFT);
+}
+
+static inline int pmd_large(pmd_t pmd)
+{
+	return (pmd_val(pmd) & (PMD_ISHUGE | PMD_HUGE_PRESENT)) ==
+		(PMD_ISHUGE | PMD_HUGE_PRESENT);
+}
+
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return (pmd_val(pmd) & (PMD_ISHUGE|PMD_HUGE_SPLITTING)) ==
+		(PMD_ISHUGE|PMD_HUGE_SPLITTING);
+}
+
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+	return pmd_val(pmd) & PMD_ISHUGE;
+}
+
+#define has_transparent_hugepage() 1
+
+static inline pmd_t pmd_mkold(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~PMD_HUGE_ACCESSED;
+	return pmd;
+}
+
+static inline pmd_t pmd_wrprotect(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~PMD_HUGE_WRITE;
+	return pmd;
+}
+
+static inline pmd_t pmd_mkdirty(pmd_t pmd)
+{
+	pmd_val(pmd) |= PMD_HUGE_DIRTY;
+	return pmd;
+}
+
+static inline pmd_t pmd_mkyoung(pmd_t pmd)
+{
+	pmd_val(pmd) |= PMD_HUGE_ACCESSED;
+	return pmd;
+}
+
+static inline pmd_t pmd_mkwrite(pmd_t pmd)
+{
+	pmd_val(pmd) |= PMD_HUGE_WRITE;
+	return pmd;
+}
+
+static inline pmd_t pmd_mknotpresent(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~PMD_HUGE_PRESENT;
+	return pmd;
+}
+
+static inline pmd_t pmd_mksplitting(pmd_t pmd)
+{
+	pmd_val(pmd) |= PMD_HUGE_SPLITTING;
+	return pmd;
+}
+#endif
+
+static inline int pmd_present(pmd_t pmd)
+{
+	return pmd_val(pmd) != 0U;
+}
+
+#define pmd_none(pmd)			(!pmd_val(pmd))
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+		       pmd_t *pmdp, pmd_t pmd);
+#else
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t pmd)
+{
+	*pmdp = pmd;
+}
+#endif
+
+static inline void pmd_set(struct mm_struct *mm, pmd_t *pmdp, pte_t *ptep)
+{
+	unsigned long val = __pa((unsigned long) (ptep)) >> PMD_PADDR_SHIFT;
+
+	pmd_val(*pmdp) = val;
+}
+
 #define pud_set(pudp, pmdp)	\
 	(pud_val(*(pudp)) = (__pa((unsigned long) (pmdp)) >> PGD_PADDR_SHIFT))
-#define __pmd_page(pmd)		\
-	((unsigned long) __va((((unsigned long)pmd_val(pmd))<<PMD_PADDR_SHIFT)))
+static inline unsigned long __pmd_page(pmd_t pmd)
+{
+	unsigned long paddr = (unsigned long) pmd_val(pmd);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (pmd_val(pmd) & PMD_ISHUGE)
+		paddr &= PMD_HUGE_PADDR;
+#endif
+	paddr <<= PMD_PADDR_SHIFT;
+	return ((unsigned long) __va(paddr));
+}
 #define pmd_page(pmd) 			virt_to_page((void *)__pmd_page(pmd))
 #define pud_page_vaddr(pud)		\
 	((unsigned long) __va((((unsigned long)pud_val(pud))<<PGD_PADDR_SHIFT)))
 #define pud_page(pud) 			virt_to_page((void *)pud_page_vaddr(pud))
-#define pmd_none(pmd)			(!pmd_val(pmd))
 #define pmd_bad(pmd)			(0)
-#define pmd_present(pmd)		(pmd_val(pmd) != 0U)
 #define pmd_clear(pmdp)			(pmd_val(*(pmdp)) = 0U)
 #define pud_none(pud)			(!pud_val(pud))
 #define pud_bad(pud)			(0)
@@ -654,6 +797,16 @@ static inline unsigned long pte_special(pte_t pte)
 extern void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
 			  pte_t *ptep, pte_t orig, int fullmm);
 
+#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
+				       unsigned long addr,
+				       pmd_t *pmdp)
+{
+	pmd_t pmd = *pmdp;
+	set_pmd_at(mm, addr, pmdp, __pmd(0U));
+	return pmd;
+}
+
 static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,
 			     pte_t *ptep, pte_t pte, int fullmm)
 {
@@ -709,6 +862,10 @@ extern void mmu_info(struct seq_file *);
 
 struct vm_area_struct;
 extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t *);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
+				 pmd_t entry);
+#endif
 
 /* Encode and de-code a swap entry */
 #define __swp_type(entry)	(((entry).val >> PAGE_SHIFT) & 0xffUL)
diff --git a/arch/sparc/include/asm/tsb.h b/arch/sparc/include/asm/tsb.h
index ef8cd1a..b4c258d 100644
--- a/arch/sparc/include/asm/tsb.h
+++ b/arch/sparc/include/asm/tsb.h
@@ -157,10 +157,86 @@ extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
 	andn		REG2, 0x7, REG2; \
 	add		REG1, REG2, REG1;
 
-	/* Do a user page table walk in MMU globals.  Leaves physical PTE
-	 * pointer in REG1.  Jumps to FAIL_LABEL on early page table walk
-	 * termination.  Physical base of page tables is in PHYS_PGD which
-	 * will not be modified.
+	/* This macro exists only to make the PMD translator below easier
+	 * to read.  It hides the ELF section switch for the sun4v code
+	 * patching.
+	 */
+#define OR_PTE_BIT(REG, NAME)				\
+661:	or		REG, _PAGE_##NAME##_4U, REG;	\
+	.section	.sun4v_1insn_patch, "ax";	\
+	.word		661b;				\
+	or		REG, _PAGE_##NAME##_4V, REG;	\
+	.previous;
+
+	/* Load into REG the PTE value for VALID, CACHE, and SZHUGE.  */
+#define BUILD_PTE_VALID_SZHUGE_CACHE(REG)				   \
+661:	sethi		%uhi(_PAGE_VALID|_PAGE_SZHUGE_4U), REG;		   \
+	.section	.sun4v_1insn_patch, "ax";			   \
+	.word		661b;						   \
+	sethi		%uhi(_PAGE_VALID), REG;				   \
+	.previous;							   \
+	sllx		REG, 32, REG;					   \
+661:	or		REG, _PAGE_CP_4U|_PAGE_CV_4U, REG;		   \
+	.section	.sun4v_1insn_patch, "ax";			   \
+	.word		661b;						   \
+	or		REG, _PAGE_CP_4V|_PAGE_CV_4V|_PAGE_SZHUGE_4V, REG; \
+	.previous;
+
+	/* PMD has been loaded into REG1, interpret the value, seeing
+	 * if it is a HUGE PMD or a normal one.  If it is not valid
+	 * then jump to FAIL_LABEL.  If it is a HUGE PMD, and it
+	 * translates to a valid PTE, branch to PTE_LABEL.
+	 *
+	 * We translate the PMD by hand, one bit at a time,
+	 * constructing the huge PTE.
+	 *
+	 * So we construct the PTE in REG2 as follows:
+	 *
+	 * 1) Extract the PMD PFN from REG1 and place it into REG2.
+	 *
+	 * 2) Translate PMD protection bits in REG1 into REG2, one bit
+	 *    at a time using andcc tests on REG1 and OR's into REG2.
+	 *
+	 *    Only two bits to be concerned with here, EXEC and WRITE.
+	 *    Now REG1 is freed up and we can use it as a temporary.
+	 *
+	 * 3) Construct the VALID, CACHE, and page size PTE bits in
+	 *    REG1, OR with REG2 to form final PTE.
+	 */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define USER_PGTABLE_CHECK_PMD_HUGE(VADDR, REG1, REG2, FAIL_LABEL, PTE_LABEL) \
+	brz,pn		REG1, FAIL_LABEL;				      \
+	 andcc		REG1, PMD_ISHUGE, %g0;				      \
+	be,pt		%xcc, 700f;					      \
+	 and		REG1, PMD_HUGE_PRESENT|PMD_HUGE_ACCESSED, REG2;	      \
+	cmp		REG2, PMD_HUGE_PRESENT|PMD_HUGE_ACCESSED;	      \
+	bne,pn		%xcc, FAIL_LABEL;				      \
+	 andn		REG1, PMD_HUGE_PROTBITS, REG2;			      \
+	sllx		REG2, PMD_PADDR_SHIFT, REG2;			      \
+	/* REG2 now holds PFN << PAGE_SHIFT */				      \
+	andcc		REG1, PMD_HUGE_EXEC, %g0;			      \
+	bne,a,pt	%xcc, 1f;					      \
+	 OR_PTE_BIT(REG2, EXEC);					      \
+1:	andcc		REG1, PMD_HUGE_WRITE, %g0;			      \
+	bne,a,pt	%xcc, 1f;					      \
+	 OR_PTE_BIT(REG2, W);						      \
+	/* REG1 can now be clobbered, build final PTE */		      \
+1:	BUILD_PTE_VALID_SZHUGE_CACHE(REG1);				      \
+	ba,pt		%xcc, PTE_LABEL;				      \
+	 or		REG1, REG2, REG1;				      \
+700:
+#else
+#define USER_PGTABLE_CHECK_PMD_HUGE(VADDR, REG1, REG2, FAIL_LABEL, PTE_LABEL) \
+	brz,pn		REG1, FAIL_LABEL; \
+	 nop;
+#endif
+
+	/* Do a user page table walk in MMU globals.  Leaves final,
+	 * valid, PTE value in REG1.  Jumps to FAIL_LABEL on early
+	 * page table walk termination or if the PTE is not valid.
+	 *
+	 * Physical base of page tables is in PHYS_PGD which will not
+	 * be modified.
 	 *
 	 * VADDR will not be clobbered, but REG1 and REG2 will.
 	 */
@@ -175,12 +251,16 @@ extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
 	sllx		REG1, PGD_PADDR_SHIFT, REG1; \
 	andn		REG2, 0x3, REG2; \
 	lduwa		[REG1 + REG2] ASI_PHYS_USE_EC, REG1; \
-	brz,pn		REG1, FAIL_LABEL; \
-	 sllx		VADDR, 64 - PMD_SHIFT, REG2; \
+	USER_PGTABLE_CHECK_PMD_HUGE(VADDR, REG1, REG2, FAIL_LABEL, 800f) \
+	sllx		VADDR, 64 - PMD_SHIFT, REG2; \
 	srlx		REG2, 64 - (PAGE_SHIFT - 1), REG2; \
 	sllx		REG1, PMD_PADDR_SHIFT, REG1; \
 	andn		REG2, 0x7, REG2; \
-	add		REG1, REG2, REG1;
+	add		REG1, REG2, REG1; \
+	ldxa		[REG1] ASI_PHYS_USE_EC, REG1; \
+	brgez,pn	REG1, FAIL_LABEL; \
+	 nop; \
+800:
 
 /* Lookup a OBP mapping on VADDR in the prom_trans[] table at TL>0.
  * If no entry is found, FAIL_LABEL will be branched to.  On success
diff --git a/arch/sparc/kernel/sun4v_tlb_miss.S b/arch/sparc/kernel/sun4v_tlb_miss.S
index e1fbf8c..bde867f 100644
--- a/arch/sparc/kernel/sun4v_tlb_miss.S
+++ b/arch/sparc/kernel/sun4v_tlb_miss.S
@@ -176,7 +176,7 @@ sun4v_tsb_miss_common:
 
 	sub	%g2, TRAP_PER_CPU_FAULT_INFO, %g2
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	mov	SCRATCHPAD_UTSBREG2, %g5
 	ldxa	[%g5] ASI_SCRATCHPAD, %g5
 	cmp	%g5, -1
diff --git a/arch/sparc/kernel/tsb.S b/arch/sparc/kernel/tsb.S
index db15d12..d4bdc7a 100644
--- a/arch/sparc/kernel/tsb.S
+++ b/arch/sparc/kernel/tsb.S
@@ -49,7 +49,7 @@ tsb_miss_page_table_walk:
 	/* Before committing to a full page table walk,
 	 * check the huge page TSB.
 	 */
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 
 661:	ldx		[%g7 + TRAP_PER_CPU_TSB_HUGE], %g5
 	nop
@@ -110,12 +110,9 @@ tsb_miss_page_table_walk:
 tsb_miss_page_table_walk_sun4v_fastpath:
 	USER_PGTABLE_WALK_TL1(%g4, %g7, %g5, %g2, tsb_do_fault)
 
-	/* Load and check PTE.  */
-	ldxa		[%g5] ASI_PHYS_USE_EC, %g5
-	brgez,pn	%g5, tsb_do_fault
-	 nop
+	/* Valid PTE is now in %g5.  */
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 661:	sethi		%uhi(_PAGE_SZALL_4U), %g7
 	sllx		%g7, 32, %g7
 	.section	.sun4v_2insn_patch, "ax"
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 1fe0429..84b21ec 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -464,13 +464,13 @@ good_area:
 	up_read(&mm->mmap_sem);
 
 	mm_rss = get_mm_rss(mm);
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	mm_rss -= (mm->context.huge_pte_count * (HPAGE_SIZE / PAGE_SIZE));
 #endif
 	if (unlikely(mm_rss >
 		     mm->context.tsb_block[MM_TSB_BASE].tsb_rss_limit))
 		tsb_grow(mm, MM_TSB_BASE, mm_rss);
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	mm_rss = mm->context.huge_pte_count;
 	if (unlikely(mm_rss >
 		     mm->context.tsb_block[MM_TSB_HUGE].tsb_rss_limit))
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 07e1453..f76f83d 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -303,53 +303,3 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 {
 	return NULL;
 }
-
-static void context_reload(void *__data)
-{
-	struct mm_struct *mm = __data;
-
-	if (mm == current->mm)
-		load_secondary_context(mm);
-}
-
-void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-	struct tsb_config *tp = &mm->context.tsb_block[MM_TSB_HUGE];
-
-	if (likely(tp->tsb != NULL))
-		return;
-
-	tsb_grow(mm, MM_TSB_HUGE, 0);
-	tsb_context_switch(mm);
-	smp_tsb_sync(mm);
-
-	/* On UltraSPARC-III+ and later, configure the second half of
-	 * the Data-TLB for huge pages.
-	 */
-	if (tlb_type == cheetah_plus) {
-		unsigned long ctx;
-
-		spin_lock(&ctx_alloc_lock);
-		ctx = mm->context.sparc64_ctx_val;
-		ctx &= ~CTX_PGSZ_MASK;
-		ctx |= CTX_PGSZ_BASE << CTX_PGSZ0_SHIFT;
-		ctx |= CTX_PGSZ_HUGE << CTX_PGSZ1_SHIFT;
-
-		if (ctx != mm->context.sparc64_ctx_val) {
-			/* When changing the page size fields, we
-			 * must perform a context flush so that no
-			 * stale entries match.  This flush must
-			 * occur with the original context register
-			 * settings.
-			 */
-			do_flush_tlb_mm(mm);
-
-			/* Reload the context register of all processors
-			 * also executing in this address space.
-			 */
-			mm->context.sparc64_ctx_val = ctx;
-			on_each_cpu(context_reload, mm, 0);
-		}
-		spin_unlock(&ctx_alloc_lock);
-	}
-}
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index cd96c03..fee32cb 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -306,12 +306,24 @@ static void flush_dcache(unsigned long pfn)
 	}
 }
 
+/* mm->context.lock must be held */
+static void __update_mmu_tsb_insert(struct mm_struct *mm, unsigned long tsb_index,
+				    unsigned long tsb_hash_shift, unsigned long address,
+				    unsigned long tte)
+{
+	struct tsb *tsb = mm->context.tsb_block[tsb_index].tsb;
+	unsigned long tag;
+
+	tsb += ((address >> tsb_hash_shift) &
+		(mm->context.tsb_block[tsb_index].tsb_nentries - 1UL));
+	tag = (address >> 22UL);
+	tsb_insert(tsb, tag, tte);
+}
+
 void update_mmu_cache(struct vm_area_struct *vma, unsigned long address, pte_t *ptep)
 {
+	unsigned long tsb_index, tsb_hash_shift, flags;
 	struct mm_struct *mm;
-	struct tsb *tsb;
-	unsigned long tag, flags;
-	unsigned long tsb_index, tsb_hash_shift;
 	pte_t pte = *ptep;
 
 	if (tlb_type != hypervisor) {
@@ -328,7 +340,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address, pte_t *
 
 	spin_lock_irqsave(&mm->context.lock, flags);
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	if (mm->context.tsb_block[MM_TSB_HUGE].tsb != NULL) {
 		if ((tlb_type == hypervisor &&
 		     (pte_val(pte) & _PAGE_SZALL_4V) == _PAGE_SZHUGE_4V) ||
@@ -340,11 +352,8 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address, pte_t *
 	}
 #endif
 
-	tsb = mm->context.tsb_block[tsb_index].tsb;
-	tsb += ((address >> tsb_hash_shift) &
-		(mm->context.tsb_block[tsb_index].tsb_nentries - 1UL));
-	tag = (address >> 22UL);
-	tsb_insert(tsb, tag, pte_val(pte));
+	__update_mmu_tsb_insert(mm, tsb_index, tsb_hash_shift,
+				address, pte_val(pte));
 
 	spin_unlock_irqrestore(&mm->context.lock, flags);
 }
@@ -2572,3 +2581,146 @@ void pgtable_free(void *table, bool is_page)
 	else
 		kmem_cache_free(pgtable_cache, table);
 }
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot, bool for_modify)
+{
+	if (pgprot_val(pgprot) & _PAGE_VALID)
+		pmd_val(pmd) |= PMD_HUGE_PRESENT;
+	if (tlb_type == hypervisor) {
+		if (pgprot_val(pgprot) & _PAGE_WRITE_4V)
+			pmd_val(pmd) |= PMD_HUGE_WRITE;
+		if (pgprot_val(pgprot) & _PAGE_EXEC_4V)
+			pmd_val(pmd) |= PMD_HUGE_EXEC;
+
+		if (!for_modify) {
+			if (pgprot_val(pgprot) & _PAGE_ACCESSED_4V)
+				pmd_val(pmd) |= PMD_HUGE_ACCESSED;
+			if (pgprot_val(pgprot) & _PAGE_MODIFIED_4V)
+				pmd_val(pmd) |= PMD_HUGE_DIRTY;
+		}
+	} else {
+		if (pgprot_val(pgprot) & _PAGE_WRITE_4U)
+			pmd_val(pmd) |= PMD_HUGE_WRITE;
+		if (pgprot_val(pgprot) & _PAGE_EXEC_4U)
+			pmd_val(pmd) |= PMD_HUGE_EXEC;
+
+		if (!for_modify) {
+			if (pgprot_val(pgprot) & _PAGE_ACCESSED_4U)
+				pmd_val(pmd) |= PMD_HUGE_ACCESSED;
+			if (pgprot_val(pgprot) & _PAGE_MODIFIED_4U)
+				pmd_val(pmd) |= PMD_HUGE_DIRTY;
+		}
+	}
+
+	return pmd;
+}
+
+pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
+{
+	pmd_t pmd;
+
+	pmd_val(pmd) = (page_nr << ((PAGE_SHIFT - PMD_PADDR_SHIFT)));
+	pmd_val(pmd) |= PMD_ISHUGE;
+	pmd = pmd_set_protbits(pmd, pgprot, false);
+	return pmd;
+}
+
+pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	pmd_val(pmd) &= ~(PMD_HUGE_PRESENT |
+			  PMD_HUGE_WRITE |
+			  PMD_HUGE_EXEC);
+	pmd = pmd_set_protbits(pmd, newprot, true);
+	return pmd;
+}
+
+void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
+			  pmd_t entry)
+{
+	unsigned long pte, flags;
+	struct mm_struct *mm;
+
+	if (!pmd_large(entry) || !pmd_young(entry))
+		return;
+
+	pte = (pmd_val(entry) & ~PMD_HUGE_PROTBITS);
+	pte <<= PMD_PADDR_SHIFT;
+	pte |= _PAGE_VALID;
+	if (tlb_type == hypervisor) {
+		if (pmd_val(entry) & PMD_HUGE_EXEC)
+			pte |= _PAGE_EXEC_4V;
+		if (pmd_val(entry) & PMD_HUGE_WRITE)
+			pte |= _PAGE_W_4V;
+		pte |= _PAGE_CP_4V|_PAGE_CV_4V|_PAGE_SZHUGE_4V;
+	} else {
+		if (pmd_val(entry) & PMD_HUGE_EXEC)
+			pte |= _PAGE_EXEC_4U;
+		if (pmd_val(entry) & PMD_HUGE_WRITE)
+			pte |= _PAGE_W_4U;
+		pte |= _PAGE_CP_4U|_PAGE_CV_4U|_PAGE_SZHUGE_4U;
+	}
+
+	mm = vma->vm_mm;
+
+	spin_lock_irqsave(&mm->context.lock, flags);
+
+	if (mm->context.tsb_block[MM_TSB_HUGE].tsb != NULL)
+		__update_mmu_tsb_insert(mm, MM_TSB_HUGE, HPAGE_SHIFT,
+					addr, pte);
+
+	spin_unlock_irqrestore(&mm->context.lock, flags);
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
+static void context_reload(void *__data)
+{
+	struct mm_struct *mm = __data;
+
+	if (mm == current->mm)
+		load_secondary_context(mm);
+}
+
+void hugetlb_setup(struct mm_struct *mm)
+{
+	struct tsb_config *tp = &mm->context.tsb_block[MM_TSB_HUGE];
+
+	if (likely(tp->tsb != NULL))
+		return;
+
+	tsb_grow(mm, MM_TSB_HUGE, 0);
+	tsb_context_switch(mm);
+	smp_tsb_sync(mm);
+
+	/* On UltraSPARC-III+ and later, configure the second half of
+	 * the Data-TLB for huge pages.
+	 */
+	if (tlb_type == cheetah_plus) {
+		unsigned long ctx;
+
+		spin_lock(&ctx_alloc_lock);
+		ctx = mm->context.sparc64_ctx_val;
+		ctx &= ~CTX_PGSZ_MASK;
+		ctx |= CTX_PGSZ_BASE << CTX_PGSZ0_SHIFT;
+		ctx |= CTX_PGSZ_HUGE << CTX_PGSZ1_SHIFT;
+
+		if (ctx != mm->context.sparc64_ctx_val) {
+			/* When changing the page size fields, we
+			 * must perform a context flush so that no
+			 * stale entries match.  This flush must
+			 * occur with the original context register
+			 * settings.
+			 */
+			do_flush_tlb_mm(mm);
+
+			/* Reload the context register of all processors
+			 * also executing in this address space.
+			 */
+			mm->context.sparc64_ctx_val = ctx;
+			on_each_cpu(context_reload, mm, 0);
+		}
+		spin_unlock(&ctx_alloc_lock);
+	}
+}
+#endif
diff --git a/arch/sparc/mm/tlb.c b/arch/sparc/mm/tlb.c
index b1f279c..f8ff493 100644
--- a/arch/sparc/mm/tlb.c
+++ b/arch/sparc/mm/tlb.c
@@ -43,16 +43,37 @@ void flush_tlb_pending(void)
 	put_cpu_var(tlb_batch);
 }
 
-void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
-		   pte_t *ptep, pte_t orig, int fullmm)
+static void tlb_batch_add_one(struct mm_struct *mm, unsigned long vaddr,
+			      bool exec)
 {
 	struct tlb_batch *tb = &get_cpu_var(tlb_batch);
 	unsigned long nr;
 
 	vaddr &= PAGE_MASK;
-	if (pte_exec(orig))
+	if (exec)
 		vaddr |= 0x1UL;
 
+	nr = tb->tlb_nr;
+
+	if (unlikely(nr != 0 && mm != tb->mm)) {
+		flush_tlb_pending();
+		nr = 0;
+	}
+
+	if (nr == 0)
+		tb->mm = mm;
+
+	tb->vaddrs[nr] = vaddr;
+	tb->tlb_nr = ++nr;
+	if (nr >= TLB_BATCH_NR)
+		flush_tlb_pending();
+
+	put_cpu_var(tlb_batch);
+}
+
+void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
+		   pte_t *ptep, pte_t orig, int fullmm)
+{
 	if (tlb_type != hypervisor &&
 	    pte_dirty(orig)) {
 		unsigned long paddr, pfn = pte_pfn(orig);
@@ -77,26 +98,55 @@ void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
 	}
 
 no_cache_flush:
+	if (!fullmm)
+		tlb_batch_add_one(mm, vaddr, pte_exec(orig));
+}
 
-	if (fullmm) {
-		put_cpu_var(tlb_batch);
-		return;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static void tlb_batch_pmd_scan(struct mm_struct *mm, unsigned long vaddr,
+			       pmd_t pmd, bool exec)
+{
+	unsigned long end;
+	pte_t *pte;
+
+	pte = pte_offset_map(&pmd, vaddr);
+	end = vaddr + HPAGE_SIZE;
+	while (vaddr < end) {
+		if (pte_val(*pte) & _PAGE_VALID)
+			tlb_batch_add_one(mm, vaddr, exec);
+		pte++;
+		vaddr += PAGE_SIZE;
 	}
+	pte_unmap(pte);
+}
 
-	nr = tb->tlb_nr;
+void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+		pmd_t *pmdp, pmd_t pmd)
+{
+	pmd_t orig = *pmdp;
 
-	if (unlikely(nr != 0 && mm != tb->mm)) {
-		flush_tlb_pending();
-		nr = 0;
-	}
+	*pmdp = pmd;
 
-	if (nr == 0)
-		tb->mm = mm;
+	if (mm == &init_mm)
+		return;
 
-	tb->vaddrs[nr] = vaddr;
-	tb->tlb_nr = ++nr;
-	if (nr >= TLB_BATCH_NR)
-		flush_tlb_pending();
+	if ((pmd_val(pmd) ^ pmd_val(orig)) & PMD_ISHUGE) {
+		if (pmd_val(pmd) & PMD_ISHUGE)
+			mm->context.huge_pte_count++;
+		else
+			mm->context.huge_pte_count--;
+		if (mm->context.huge_pte_count == 1)
+			hugetlb_setup(mm);
+	}
 
-	put_cpu_var(tlb_batch);
+	if (!pmd_none(orig)) {
+		bool exec = ((pmd_val(orig) & PMD_HUGE_EXEC) != 0);
+
+		addr &= HPAGE_MASK;
+		if (pmd_val(orig) & PMD_ISHUGE)
+			tlb_batch_add_one(mm, addr, exec);
+		else
+			tlb_batch_pmd_scan(mm, addr, orig, exec);
+	}
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index 760621a..ac34fef 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -78,7 +78,7 @@ void flush_tsb_user(struct tlb_batch *tb)
 		base = __pa(base);
 	__flush_tsb_one(tb, PAGE_SHIFT, base, nentries);
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	if (mm->context.tsb_block[MM_TSB_HUGE].tsb) {
 		base = (unsigned long) mm->context.tsb_block[MM_TSB_HUGE].tsb;
 		nentries = mm->context.tsb_block[MM_TSB_HUGE].tsb_nentries;
@@ -100,7 +100,7 @@ void flush_tsb_user(struct tlb_batch *tb)
 #error Broken base page size setting...
 #endif
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 #define HV_PGSZ_IDX_HUGE	HV_PGSZ_IDX_4MB
 #define HV_PGSZ_MASK_HUGE	HV_PGSZ_MASK_4MB
 #endif
@@ -197,7 +197,7 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 		case MM_TSB_BASE:
 			hp->pgsz_idx = HV_PGSZ_IDX_BASE;
 			break;
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 		case MM_TSB_HUGE:
 			hp->pgsz_idx = HV_PGSZ_IDX_HUGE;
 			break;
@@ -212,7 +212,7 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 		case MM_TSB_BASE:
 			hp->pgsz_mask = HV_PGSZ_MASK_BASE;
 			break;
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 		case MM_TSB_HUGE:
 			hp->pgsz_mask = HV_PGSZ_MASK_HUGE;
 			break;
@@ -434,7 +434,7 @@ retry_tsb_alloc:
 
 int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 {
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	unsigned long huge_pte_count;
 #endif
 	unsigned int i;
@@ -443,7 +443,7 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 
 	mm->context.sparc64_ctx_val = 0UL;
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	/* We reset it to zero because the fork() page copying
 	 * will re-increment the counters as the parent PTEs are
 	 * copied into the child address space.
@@ -466,7 +466,7 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	tsb_grow(mm, MM_TSB_BASE, get_mm_rss(mm));
 
-#ifdef CONFIG_HUGETLB_PAGE
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	if (unlikely(huge_pte_count))
 		tsb_grow(mm, MM_TSB_HUGE, huge_pte_count);
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index d5c8019..4c94084 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -318,7 +318,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
-	depends on X86 && MMU
+	depends on (X86 || SPARC64) && MMU
 	select COMPACTION
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
