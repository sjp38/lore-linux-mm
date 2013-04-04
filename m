Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0A0666B0074
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:27 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:25:22 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 3FE78394002D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:28:23 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wHKV8388930
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:17 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wIwc026854
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:18 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 17/25] powerpc/THP: Implement transparent hugepages for ppc64
Date: Thu,  4 Apr 2013 11:27:55 +0530
Message-Id: <1365055083-31956-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We now have pmd entries covering to 16MB range. To implement THP on powerpc,
we double the size of PMD. The second half is used to deposit the pgtable (PTE page).
We also use the depoisted PTE page for tracking the HPTE information. The information
include [ secondary group | 3 bit hidx | valid ]. We use one byte per each HPTE entry.
With 16MB hugepage and 64K HPTE we need 256 entries and with 4K HPTE we need
4096 entries. Both will fit in a 4K PTE page.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/page.h              |    2 +-
 arch/powerpc/include/asm/pgtable-ppc64-64k.h |    3 +-
 arch/powerpc/include/asm/pgtable-ppc64.h     |    2 +-
 arch/powerpc/include/asm/pgtable.h           |  240 ++++++++++++++++++++
 arch/powerpc/mm/pgtable.c                    |  314 ++++++++++++++++++++++++++
 arch/powerpc/mm/pgtable_64.c                 |   13 ++
 arch/powerpc/platforms/Kconfig.cputype       |    1 +
 7 files changed, 572 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index 38e7ff6..b927447 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -40,7 +40,7 @@
 #ifdef CONFIG_HUGETLB_PAGE
 extern unsigned int HPAGE_SHIFT;
 #else
-#define HPAGE_SHIFT PAGE_SHIFT
+#define HPAGE_SHIFT PMD_SHIFT
 #endif
 #define HPAGE_SIZE		((1UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
diff --git a/arch/powerpc/include/asm/pgtable-ppc64-64k.h b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
index 3c529b4..5c5541a 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64-64k.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
@@ -33,7 +33,8 @@
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
 /* Bits to mask out from a PMD to get to the PTE page */
-#define PMD_MASKED_BITS		0x1ff
+/* PMDs point to PTE table fragments which are 4K aligned.  */
+#define PMD_MASKED_BITS		0xfff
 /* Bits to mask out from a PGD/PUD to get to the PMD page */
 #define PUD_MASKED_BITS		0x1ff
 
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 0182c20..c0747c7 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -150,7 +150,7 @@
 #define	pmd_present(pmd)	(pmd_val(pmd) != 0)
 #define	pmd_clear(pmdp)		(pmd_val(*(pmdp)) = 0)
 #define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~PMD_MASKED_BITS)
-#define pmd_page(pmd)		virt_to_page(pmd_page_vaddr(pmd))
+extern struct page *pmd_page(pmd_t pmd);
 
 #define pud_set(pudp, pudval)	(pud_val(*(pudp)) = (pudval))
 #define pud_none(pud)		(!pud_val(pud))
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 4b52726..9fbe2a7 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -23,7 +23,247 @@ struct mm_struct;
  */
 #define PTE_PAGE_HIDX_OFFSET (PTRS_PER_PTE * 8)
 
+/* A large part matches with pte bits */
+#define PMD_HUGE_PRESENT	0x001 /* software: pte contains a translation */
+#define PMD_HUGE_USER		0x002 /* matches one of the PP bits */
+#define PMD_HUGE_FILE		0x002 /* (!present only) software: pte holds file offset */
+#define PMD_HUGE_EXEC		0x004 /* No execute on POWER4 and newer (we invert) */
+#define PMD_HUGE_SPLITTING	0x008
+#define PMD_HUGE_SAO		0x010 /* strong Access order */
+#define PMD_HUGE_HASHPTE	0x020
+#define PMD_ISHUGE		0x040
+#define PMD_HUGE_DIRTY		0x080 /* C: page changed */
+#define PMD_HUGE_ACCESSED	0x100 /* R: page referenced */
+#define PMD_HUGE_RW		0x200 /* software: user write access allowed */
+#define PMD_HUGE_BUSY		0x800 /* software: PTE & hash are busy */
+#define PMD_HUGE_HPTEFLAGS	(PMD_HUGE_BUSY | PMD_HUGE_HASHPTE)
+/*
+ * We keep both the pmd and pte rpn shift same, eventhough we use only
+ * lower 12 bits for hugepage flags at pmd level
+ */
+#define PMD_HUGE_RPN_SHIFT	PTE_RPN_SHIFT
+#define HUGE_PAGE_SIZE		(ASM_CONST(1) << 24)
+#define HUGE_PAGE_MASK		(~(HUGE_PAGE_SIZE - 1))
+
 #ifndef __ASSEMBLY__
+extern void hpte_need_hugepage_flush(struct mm_struct *mm, unsigned long addr,
+				     pmd_t *pmdp);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
+extern pmd_t mk_pmd(struct page *page, pgprot_t pgprot);
+extern pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot);
+extern void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+		       pmd_t *pmdp, pmd_t pmd);
+extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
+				 pmd_t *pmd);
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
+/* We will enable it in the last patch */
+#define has_transparent_hugepage() 0
+#else
+#define pmd_large(pmd)		0
+#define has_transparent_hugepage() 0
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
+static inline unsigned long pmd_pfn(pmd_t pmd)
+{
+	/*
+	 * Only called for hugepage pmd
+	 */
+	return pmd_val(pmd) >> PMD_HUGE_RPN_SHIFT;
+}
+
+static inline int pmd_young(pmd_t pmd)
+{
+	return pmd_val(pmd) & PMD_HUGE_ACCESSED;
+}
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	/* Do nothing, mk_pmd() does this part.  */
+	return pmd;
+}
+
+#define __HAVE_ARCH_PMD_WRITE
+static inline int pmd_write(pmd_t pmd)
+{
+	return pmd_val(pmd) & PMD_HUGE_RW;
+}
+
+static inline pmd_t pmd_mkold(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~PMD_HUGE_ACCESSED;
+	return pmd;
+}
+
+static inline pmd_t pmd_wrprotect(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~PMD_HUGE_RW;
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
+	pmd_val(pmd) |= PMD_HUGE_RW;
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
+
+/*
+ * Set the dirty and/or accessed bits atomically in a linux hugepage PMD, this
+ * function doesn't need to flush the hash entry
+ */
+static inline void __pmdp_set_access_flags(pmd_t *pmdp, pmd_t entry)
+{
+	unsigned long bits = pmd_val(entry) & (PMD_HUGE_DIRTY |
+					       PMD_HUGE_ACCESSED |
+					       PMD_HUGE_RW | PMD_HUGE_EXEC);
+#ifdef PTE_ATOMIC_UPDATES
+	unsigned long old, tmp;
+
+	__asm__ __volatile__(
+	"1:	ldarx	%0,0,%4\n\
+		andi.	%1,%0,%6\n\
+		bne-	1b \n\
+		or	%0,%3,%0\n\
+		stdcx.	%0,0,%4\n\
+		bne-	1b"
+	:"=&r" (old), "=&r" (tmp), "=m" (*pmdp)
+	:"r" (bits), "r" (pmdp), "m" (*pmdp), "i" (PMD_HUGE_BUSY)
+	:"cc");
+#else
+	unsigned long old = pmd_val(*pmdp);
+	*pmdp = __pmd(old | bits);
+#endif
+}
+
+#define __HAVE_ARCH_PMD_SAME
+static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
+{
+	return (((pmd_val(pmd_a) ^ pmd_val(pmd_b)) & ~PMD_HUGE_HPTEFLAGS) == 0);
+}
+
+#define __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
+extern int pmdp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp,
+				 pmd_t entry, int dirty);
+
+static inline unsigned long pmd_hugepage_update(struct mm_struct *mm,
+						unsigned long addr,
+						pmd_t *pmdp, unsigned long clr)
+{
+#ifdef PTE_ATOMIC_UPDATES
+	unsigned long old, tmp;
+
+	__asm__ __volatile__(
+	"1:	ldarx	%0,0,%3\n\
+		andi.	%1,%0,%6\n\
+		bne-	1b \n\
+		andc	%1,%0,%4 \n\
+		stdcx.	%1,0,%3 \n\
+		bne-	1b"
+	: "=&r" (old), "=&r" (tmp), "=m" (*pmdp)
+	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (PMD_HUGE_BUSY)
+	: "cc" );
+#else
+	unsigned long old = pmd_val(*pmdp);
+	*pmdp = __pmd(old & ~clr);
+#endif
+
+#ifdef CONFIG_PPC_STD_MMU_64
+	if (old & PMD_HUGE_HASHPTE)
+		hpte_need_hugepage_flush(mm, addr, pmdp);
+#endif
+	return old;
+}
+
+static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
+					      unsigned long addr, pmd_t *pmdp)
+{
+	unsigned long old;
+
+	if ((pmd_val(*pmdp) & (PMD_HUGE_ACCESSED | PMD_HUGE_HASHPTE)) == 0)
+		return 0;
+	old = pmd_hugepage_update(mm, addr, pmdp, PMD_HUGE_ACCESSED);
+	return ((old & PMD_HUGE_ACCESSED) != 0);
+}
+
+#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
+extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+				     unsigned long address, pmd_t *pmdp);
+#define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
+extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
+				       unsigned long addr, pmd_t *pmdp)
+{
+	unsigned long old = pmd_hugepage_update(mm, addr, pmdp, ~0UL);
+	return __pmd(old);
+}
+
+#define __HAVE_ARCH_PMDP_SET_WRPROTECT
+static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
+				      pmd_t *pmdp)
+{
+
+	if ((pmd_val(*pmdp) & PMD_HUGE_RW) == 0)
+		return;
+
+	pmd_hugepage_update(mm, addr, pmdp, PMD_HUGE_RW);
+}
+
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+extern void pmdp_splitting_flush(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PGTABLE_DEPOSIT
+extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				       pgtable_t pgtable);
+#define __HAVE_ARCH_PGTABLE_WITHDRAW
+extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMDP_INVALIDATE
+extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+			    pmd_t *pmdp);
 
 #include <asm/tlbflush.h>
 
diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index 214130a..9f33780 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -31,6 +31,7 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/tlb.h>
+#include <asm/machdep.h>
 
 #include "mmu_decl.h"
 
@@ -240,3 +241,316 @@ void assert_pte_locked(struct mm_struct *mm, unsigned long addr)
 }
 #endif /* CONFIG_DEBUG_VM */
 
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static pmd_t set_hugepage_access_flags_filter(pmd_t pmd,
+					      struct vm_area_struct *vma,
+					      int dirty)
+{
+	return pmd;
+}
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
+	entry = set_hugepage_access_flags_filter(entry, vma, dirty);
+	changed = !pmd_same(*(pmdp), entry);
+	if (changed) {
+		__pmdp_set_access_flags(pmdp, entry);
+		/*
+		 * Since we are not supporting SW TLB systems, we don't
+		 * have any thing similar to flush_tlb_page_nohash()
+		 */
+	}
+	return changed;
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
+ * We mark the pmd splitting and invalidate all the hpte
+ * entries for this hugepage.
+ */
+void pmdp_splitting_flush(struct vm_area_struct *vma,
+			  unsigned long address, pmd_t *pmdp)
+{
+	unsigned long old, tmp;
+
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+#ifdef PTE_ATOMIC_UPDATES
+
+	__asm__ __volatile__(
+	"1:	ldarx	%0,0,%3\n\
+		andi.	%1,%0,%6\n\
+		bne-	1b \n\
+		ori	%1,%0,%4 \n\
+		stdcx.	%1,0,%3 \n\
+		bne-	1b"
+	: "=&r" (old), "=&r" (tmp), "=m" (*pmdp)
+	: "r" (pmdp), "i" (PMD_HUGE_SPLITTING), "m" (*pmdp), "i" (PMD_HUGE_BUSY)
+	: "cc" );
+#else
+	old = pmd_val(*pmdp);
+	*pmdp = __pmd(old | PMD_HUGE_SPLITTING);
+#endif
+	/*
+	 * If we didn't had the splitting flag set, go and flush the
+	 * HPTE entries and serialize against gup fast.
+	 */
+	if (!(old & PMD_HUGE_SPLITTING)) {
+#ifdef CONFIG_PPC_STD_MMU_64
+		/* We need to flush the hpte */
+		if (old & PMD_HUGE_HASHPTE)
+			hpte_need_hugepage_flush(vma->vm_mm, address, pmdp);
+#endif
+		/* need tlb flush only to serialize against gup-fast */
+		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	}
+}
+
+/*
+ * We want to put the pgtable in pmd and use pgtable for tracking
+ * the base page size hptes
+ */
+void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pgtable)
+{
+	unsigned long *pgtable_slot;
+	assert_spin_locked(&mm->page_table_lock);
+	/*
+	 * we store the pgtable in the second half of PMD
+	 */
+	pgtable_slot = pmdp + PTRS_PER_PMD;
+	*pgtable_slot = (unsigned long)pgtable;
+}
+
+#define PTE_FRAG_SIZE (2 * PTRS_PER_PTE * sizeof(pte_t))
+pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
+{
+	pgtable_t pgtable;
+	unsigned long *pgtable_slot;
+
+	assert_spin_locked(&mm->page_table_lock);
+	pgtable_slot = pmdp + PTRS_PER_PMD;
+	pgtable = (pgtable_t) *pgtable_slot;
+	/*
+	 * We store HPTE information in the deposited PTE fragment.
+	 * zero out the content on withdraw.
+	 */
+	memset(pgtable, 0, PTE_FRAG_SIZE);
+	return pgtable;
+}
+
+/*
+ * Since we are looking at latest ppc64, we don't need to worry about
+ * i/d cache coherency on exec fault
+ */
+static pmd_t set_pmd_filter(pmd_t pmd, unsigned long addr)
+{
+	pmd = __pmd(pmd_val(pmd) & ~PMD_HUGE_HPTEFLAGS);
+	return pmd;
+}
+
+/*
+ * We can make it less convoluted than __set_pte_at, because
+ * we can ignore lot of hardware here, because this is only for
+ * MPSS
+ */
+static inline void __set_pmd_at(struct mm_struct *mm, unsigned long addr,
+				pmd_t *pmdp, pmd_t pmd, int percpu)
+{
+	/*
+	 * There is nothing in hash page table now, so nothing to
+	 * invalidate, set_pte_at is used for adding new entry.
+	 * For updating we should use update_hugepage_pmd()
+	 */
+	*pmdp = pmd;
+}
+
+/*
+ * set a new huge pmd. We should not be called for updating
+ * an existing pmd entry. That should go via pmd_hugepage_update.
+ */
+void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+		pmd_t *pmdp, pmd_t pmd)
+{
+	/*
+	 * Note: mm->context.id might not yet have been assigned as
+	 * this context might not have been activated yet when this
+	 * is called.
+	 */
+	pmd = set_pmd_filter(pmd, addr);
+
+	__set_pmd_at(mm, addr, pmdp, pmd, 0);
+
+}
+
+void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+		     pmd_t *pmdp)
+{
+	pmd_hugepage_update(vma->vm_mm, address, pmdp, PMD_HUGE_PRESENT);
+	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+}
+
+/*
+ * A linux hugepage PMD was changed and the corresponding hash table entry
+ * neesd to be flushed.
+ *
+ * The linux hugepage PMD now include the pmd entries followed by the address
+ * to the stashed pgtable_t. The stashed pgtable_t contains the hpte bits.
+ * [ secondary group | 3 bit hidx | valid ]. We use one byte per each HPTE entry.
+ * With 16MB hugepage and 64K HPTE we need 256 entries and with 4K HPTE we need
+ * 4096 entries. Both will fit in a 4K pgtable_t.
+ */
+void hpte_need_hugepage_flush(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp)
+{
+	int ssize, i;
+	unsigned long s_addr;
+	unsigned int psize, valid;
+	unsigned char *hpte_slot_array;
+	unsigned long hidx, vpn, vsid, hash, shift, slot;
+
+	/*
+	 * Flush all the hptes mapping this hugepage
+	 */
+	s_addr = addr & HUGE_PAGE_MASK;
+	/*
+	 * The hpte hindex are stored in the pgtable whose address is in the
+	 * second half of the PMD
+	 */
+	hpte_slot_array = *(char **)(pmdp + PTRS_PER_PMD);
+
+	/* get the base page size */
+	psize = get_slice_psize(mm, s_addr);
+	shift = mmu_psize_defs[psize].shift;
+
+	for (i = 0; i < HUGE_PAGE_SIZE/(1ul << shift); i++) {
+		/*
+		 * 8 bits per each hpte entries
+		 * 000| [ secondary group (one bit) | hidx (3 bits) | valid bit]
+		 */
+		valid = hpte_slot_array[i] & 0x1;
+		if (!valid)
+			continue;
+		hidx =  hpte_slot_array[i]  >> 1;
+
+		/* get the vpn */
+		addr = s_addr + (i * (1ul << shift));
+		if (!is_kernel_addr(addr)) {
+			ssize = user_segment_size(addr);
+			vsid = get_vsid(mm->context.id, addr, ssize);
+			WARN_ON(vsid == 0);
+		} else {
+			vsid = get_kernel_vsid(addr, mmu_kernel_ssize);
+			ssize = mmu_kernel_ssize;
+		}
+
+		vpn = hpt_vpn(addr, vsid, ssize);
+		hash = hpt_hash(vpn, shift, ssize);
+		if (hidx & _PTEIDX_SECONDARY)
+			hash = ~hash;
+
+		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
+		slot += hidx & _PTEIDX_GROUP_IX;
+		ppc_md.hpte_invalidate(slot, vpn, psize, ssize, 0);
+	}
+}
+
+static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
+{
+	unsigned long pmd_prot = 0;
+	unsigned long prot = pgprot_val(pgprot);
+
+	if (prot & _PAGE_PRESENT)
+		pmd_prot |= PMD_HUGE_PRESENT;
+	if (prot & _PAGE_USER)
+		pmd_prot |= PMD_HUGE_USER;
+	if (prot & _PAGE_FILE)
+		pmd_prot |= PMD_HUGE_FILE;
+	if (prot & _PAGE_EXEC)
+		pmd_prot |= PMD_HUGE_EXEC;
+	/*
+	 * _PAGE_COHERENT should always be set
+	 */
+	VM_BUG_ON(!(prot & _PAGE_COHERENT));
+
+	if (prot & _PAGE_SAO)
+		pmd_prot |= PMD_HUGE_SAO;
+	if (prot & _PAGE_DIRTY)
+		pmd_prot |= PMD_HUGE_DIRTY;
+	if (prot & _PAGE_ACCESSED)
+		pmd_prot |= PMD_HUGE_ACCESSED;
+	if (prot & _PAGE_RW)
+		pmd_prot |= PMD_HUGE_RW;
+
+	pmd_val(pmd) |= pmd_prot;
+	return pmd;
+}
+
+pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
+{
+	pmd_t pmd;
+
+	pmd_val(pmd) = pfn << PMD_HUGE_RPN_SHIFT;
+	pmd_val(pmd) |= PMD_ISHUGE;
+	pmd = pmd_set_protbits(pmd, pgprot);
+	return pmd;
+}
+
+pmd_t mk_pmd(struct page *page, pgprot_t pgprot)
+{
+	return pfn_pmd(page_to_pfn(page), pgprot);
+}
+
+pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	/* FIXME!! why are this bits cleared ? */
+	pmd_val(pmd) &= ~(PMD_HUGE_PRESENT |
+			  PMD_HUGE_RW |
+			  PMD_HUGE_EXEC);
+	pmd = pmd_set_protbits(pmd, newprot);
+	return pmd;
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
+	/* FIXME!!
+	 * Will be done in a later patch
+	 */
+}
+
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index e79840b..6fc3488 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -338,6 +338,19 @@ EXPORT_SYMBOL(iounmap);
 EXPORT_SYMBOL(__iounmap);
 EXPORT_SYMBOL(__iounmap_at);
 
+/*
+ * For hugepage we have pfn in the pmd, we use PMD_HUGE_RPN_SHIFT bits for flags
+ * For PTE page, we have a PTE_FRAG_SIZE (4K) aligned virtual address.
+ */
+struct page *pmd_page(pmd_t pmd)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (pmd_val(pmd) & PMD_ISHUGE)
+		return pfn_to_page(pmd_pfn(pmd));
+#endif
+	return virt_to_page(pmd_page_vaddr(pmd));
+}
+
 #ifdef CONFIG_PPC_64K_PAGES
 /*
  * we support 16 fragments per PTE page. This is limited by how many
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 72afd28..90ee19b 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -71,6 +71,7 @@ config PPC_BOOK3S_64
 	select PPC_FPU
 	select PPC_HAVE_PMU_SUPPORT
 	select SYS_SUPPORTS_HUGETLBFS
+	select HAVE_ARCH_TRANSPARENT_HUGEPAGE if PPC_64K_PAGES
 
 config PPC_BOOK3E_64
 	bool "Embedded processors"
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
