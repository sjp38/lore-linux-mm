Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 18A7F6B0238
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 14:41:58 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 37 of 41] add x86 32bit support
Message-Id: <39fc47b5e889a9720bfd.1269887870@v2.random>
In-Reply-To: <patchbomb.1269887833@v2.random>
References: <patchbomb.1269887833@v2.random>
Date: Mon, 29 Mar 2010 20:37:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Johannes Weiner <hannes@cmpxchg.org>

Add support for transparent hugepages to x86 32bit.

Share the same VM_ bitflag for VM_MAPPED_COPY. mm/nommu.c will never support
transparent hugepages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -46,6 +46,15 @@ static inline pte_t native_ptep_get_and_
 #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
 #endif
 
+#ifdef CONFIG_SMP
+static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
+{
+	return __pmd(xchg((pmdval_t *)xp, 0));
+}
+#else
+#define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
+#endif
+
 /*
  * Bits _PAGE_BIT_PRESENT, _PAGE_BIT_FILE and _PAGE_BIT_PROTNONE are taken,
  * split up the 29 bits of offset into this range:
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -104,6 +104,29 @@ static inline pte_t native_ptep_get_and_
 #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
 #endif
 
+#ifdef CONFIG_SMP
+union split_pmd {
+	struct {
+		u32 pmd_low;
+		u32 pmd_high;
+	};
+	pmd_t pmd;
+};
+static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
+{
+	union split_pmd res, *orig = (union split_pmd *)pmdp;
+
+	/* xchg acts as a barrier before setting of the high bits */
+	res.pmd_low = xchg(&orig->pmd_low, 0);
+	res.pmd_high = orig->pmd_high;
+	orig->pmd_high = 0;
+
+	return res.pmd;
+}
+#else
+#define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
+#endif
+
 /*
  * Bits 0, 6 and 7 are taken in the low part of the pte,
  * put the 32 bits of offset into the high part.
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -95,6 +95,11 @@ static inline int pte_young(pte_t pte)
 	return pte_flags(pte) & _PAGE_ACCESSED;
 }
 
+static inline int pmd_young(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_ACCESSED;
+}
+
 static inline int pte_write(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_RW;
@@ -143,6 +148,18 @@ static inline int pmd_large(pmd_t pte)
 		(_PAGE_PSE | _PAGE_PRESENT);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return pmd_val(pmd) & _PAGE_SPLITTING;
+}
+
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+	return pmd_val(pmd) & _PAGE_PSE;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
 {
 	pteval_t v = native_pte_val(pte);
@@ -217,6 +234,55 @@ static inline pte_t pte_mkspecial(pte_t 
 	return pte_set_flags(pte, _PAGE_SPECIAL);
 }
 
+static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return __pmd(v | set);
+}
+
+static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return __pmd(v & ~clear);
+}
+
+static inline pmd_t pmd_mkold(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
+}
+
+static inline pmd_t pmd_wrprotect(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_RW);
+}
+
+static inline pmd_t pmd_mkdirty(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_DIRTY);
+}
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_PSE);
+}
+
+static inline pmd_t pmd_mkyoung(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_ACCESSED);
+}
+
+static inline pmd_t pmd_mkwrite(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_RW);
+}
+
+static inline pmd_t pmd_mknotpresent(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_PRESENT);
+}
+
 /*
  * Mask out unsupported bits in a present pgprot.  Non-present pgprots
  * can use those bits for other purposes, so leave them be.
@@ -525,6 +591,14 @@ static inline pte_t native_local_ptep_ge
 	return res;
 }
 
+static inline pmd_t native_local_pmdp_get_and_clear(pmd_t *pmdp)
+{
+	pmd_t res = *pmdp;
+
+	native_pmd_clear(pmdp);
+	return res;
+}
+
 static inline void native_set_pte_at(struct mm_struct *mm, unsigned long addr,
 				     pte_t *ptep , pte_t pte)
 {
@@ -612,6 +686,49 @@ static inline void ptep_set_wrprotect(st
 	pte_update(mm, addr, ptep);
 }
 
+#define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
+
+#define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
+extern int pmdp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp,
+				 pmd_t entry, int dirty);
+
+#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
+extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+				     unsigned long addr, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
+extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmdp);
+
+
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+extern void pmdp_splitting_flush(struct vm_area_struct *vma,
+				 unsigned long addr, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMD_WRITE
+static inline int pmd_write(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_RW;
+}
+
+#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
+				       pmd_t *pmdp)
+{
+	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
+	pmd_update(mm, addr, pmdp);
+	return pmd;
+}
+
+#define __HAVE_ARCH_PMDP_SET_WRPROTECT
+static inline void pmdp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long addr, pmd_t *pmdp)
+{
+	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
+	pmd_update(mm, addr, pmdp);
+}
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -182,115 +182,6 @@ extern void cleanup_highmap(void);
 
 #define __HAVE_ARCH_PTE_SAME
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return pmd_val(pmd) & _PAGE_SPLITTING;
-}
-
-static inline int pmd_trans_huge(pmd_t pmd)
-{
-	return pmd_val(pmd) & _PAGE_PSE;
-}
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-
-#define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
-
-#define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
-extern int pmdp_set_access_flags(struct vm_area_struct *vma,
-				 unsigned long address, pmd_t *pmdp,
-				 pmd_t entry, int dirty);
-
-#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
-extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
-				     unsigned long addr, pmd_t *pmdp);
-
-#define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
-extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
-				  unsigned long address, pmd_t *pmdp);
-
-
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-				 unsigned long addr, pmd_t *pmdp);
-
-#define __HAVE_ARCH_PMD_WRITE
-static inline int pmd_write(pmd_t pmd)
-{
-	return pmd_flags(pmd) & _PAGE_RW;
-}
-
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
-				       pmd_t *pmdp)
-{
-	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
-	pmd_update(mm, addr, pmdp);
-	return pmd;
-}
-
-#define __HAVE_ARCH_PMDP_SET_WRPROTECT
-static inline void pmdp_set_wrprotect(struct mm_struct *mm,
-				      unsigned long addr, pmd_t *pmdp)
-{
-	clear_bit(_PAGE_BIT_RW, (unsigned long *)&pmdp->pmd);
-	pmd_update(mm, addr, pmdp);
-}
-
-static inline int pmd_young(pmd_t pmd)
-{
-	return pmd_flags(pmd) & _PAGE_ACCESSED;
-}
-
-static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
-{
-	pmdval_t v = native_pmd_val(pmd);
-
-	return native_make_pmd(v | set);
-}
-
-static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
-{
-	pmdval_t v = native_pmd_val(pmd);
-
-	return native_make_pmd(v & ~clear);
-}
-
-static inline pmd_t pmd_mkold(pmd_t pmd)
-{
-	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
-}
-
-static inline pmd_t pmd_wrprotect(pmd_t pmd)
-{
-	return pmd_clear_flags(pmd, _PAGE_RW);
-}
-
-static inline pmd_t pmd_mkdirty(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_DIRTY);
-}
-
-static inline pmd_t pmd_mkhuge(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_PSE);
-}
-
-static inline pmd_t pmd_mkyoung(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_ACCESSED);
-}
-
-static inline pmd_t pmd_mkwrite(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_RW);
-}
-
-static inline pmd_t pmd_mknotpresent(pmd_t pmd)
-{
-	return pmd_clear_flags(pmd, _PAGE_PRESENT);
-}
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_X86_PGTABLE_64_H */
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -351,7 +351,7 @@ int pmdp_test_and_clear_young(struct vm_
 
 	if (pmd_young(*pmdp))
 		ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,
-					 (unsigned long *) &pmdp->pmd);
+					 (unsigned long *)pmdp);
 
 	if (ret)
 		pmd_update(vma->vm_mm, addr, pmdp);
@@ -393,7 +393,7 @@ void pmdp_splitting_flush(struct vm_area
 	int set;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	set = !test_and_set_bit(_PAGE_BIT_SPLITTING,
-				(unsigned long *)&pmdp->pmd);
+				(unsigned long *)pmdp);
 	if (set) {
 		pmd_update(vma->vm_mm, address, pmdp);
 		/* need tlb flush only to serialize against gup-fast */
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -98,7 +98,11 @@ extern unsigned int kobjsize(const void 
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
+#ifndef CONFIG_TRANSPARENT_HUGEPAGE
 #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
+#else
+#define VM_HUGEPAGE	0x01000000	/* MADV_HUGEPAGE marked this vma */
+#endif
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
 
@@ -107,9 +111,6 @@ extern unsigned int kobjsize(const void 
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
-#if BITS_PER_LONG > 32
-#define VM_HUGEPAGE	0x100000000UL	/* MADV_HUGEPAGE marked this vma */
-#endif
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -290,7 +290,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage support" if EMBEDDED
-	depends on X86_64
+	depends on X86
 	default y
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
