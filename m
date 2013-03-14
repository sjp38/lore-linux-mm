Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id BB6206B009F
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:51:16 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 14 Mar 2013 17:48:37 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D29261B08067
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 17:51:11 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2EHp2VL51773580
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 17:51:02 GMT
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EHpAXo029850
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 11:51:11 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH v2] mm/hugetlb: add more arch-defined huge_pte functions
Date: Thu, 14 Mar 2013 18:51:03 +0100
Message-Id: <1363283463-50880-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

Commit abf09bed3c "s390/mm: implement software dirty bits" introduced
another difference in the pte layout vs. the pmd layout on s390,
thoroughly breaking the s390 support for hugetlbfs. This requires
replacing some more pte_xxx functions in mm/hugetlbfs.c with a
huge_pte_xxx version.

This patch introduces those huge_pte_xxx functions and their
generic implementation in asm-generic/hugetlb.h, which will now be
included on all architectures supporting hugetlbfs apart from s390.
This change will be a no-op for those architectures.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 arch/ia64/include/asm/hugetlb.h    |  1 +
 arch/mips/include/asm/hugetlb.h    |  1 +
 arch/powerpc/include/asm/hugetlb.h |  1 +
 arch/s390/include/asm/hugetlb.h    | 56 +++++++++++++++++++++-
 arch/s390/include/asm/pgtable.h    | 95 ++++++++++++++++----------------------
 arch/s390/mm/hugetlbpage.c         |  2 +-
 arch/sh/include/asm/hugetlb.h      |  1 +
 arch/sparc/include/asm/hugetlb.h   |  1 +
 arch/tile/include/asm/hugetlb.h    |  1 +
 arch/x86/include/asm/hugetlb.h     |  1 +
 include/asm-generic/hugetlb.h      | 40 ++++++++++++++++
 mm/hugetlb.c                       | 23 ++++-----
 12 files changed, 155 insertions(+), 68 deletions(-)
 create mode 100644 include/asm-generic/hugetlb.h

diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index 94eaa5b..aa91005 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -2,6 +2,7 @@
 #define _ASM_IA64_HUGETLB_H
 
 #include <asm/page.h>
+#include <asm-generic/hugetlb.h>
 
 
 void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index ef99db9..fe0d15d 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -10,6 +10,7 @@
 #define __ASM_HUGETLB_H
 
 #include <asm/page.h>
+#include <asm-generic/hugetlb.h>
 
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 62e11a3..4fcbd6b 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -3,6 +3,7 @@
 
 #ifdef CONFIG_HUGETLB_PAGE
 #include <asm/page.h>
+#include <asm-generic/hugetlb.h>
 
 extern struct kmem_cache *hugepte_cache;
 
diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 593753e..bd90359 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -114,7 +114,7 @@ static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 #define huge_ptep_set_wrprotect(__mm, __addr, __ptep)			\
 ({									\
 	pte_t __pte = huge_ptep_get(__ptep);				\
-	if (pte_write(__pte)) {						\
+	if (huge_pte_write(__pte)) {					\
 		huge_ptep_invalidate(__mm, __addr, __ptep);		\
 		set_huge_pte_at(__mm, __addr, __ptep,			\
 				huge_pte_wrprotect(__pte));		\
@@ -127,4 +127,58 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 	huge_ptep_invalidate(vma->vm_mm, address, ptep);
 }
 
+static inline pte_t mk_huge_pte(struct page *page, pgprot_t pgprot)
+{
+	pte_t pte;
+	pmd_t pmd;
+
+	pmd = mk_pmd_phys(page_to_phys(page), pgprot);
+	pte_val(pte) = pmd_val(pmd);
+	return pte;
+}
+
+static inline int huge_pte_write(pte_t pte)
+{
+	pmd_t pmd;
+
+	pmd_val(pmd) = pte_val(pte);
+	return pmd_write(pmd);
+}
+
+static inline int huge_pte_dirty(pte_t pte)
+{
+	/* No dirty bit in the segment table entry. */
+	return 0;
+}
+
+static inline pte_t huge_pte_mkwrite(pte_t pte)
+{
+	pmd_t pmd;
+
+	pmd_val(pmd) = pte_val(pte);
+	pte_val(pte) = pmd_val(pmd_mkwrite(pmd));
+	return pte;
+}
+
+static inline pte_t huge_pte_mkdirty(pte_t pte)
+{
+	/* No dirty bit in the segment table entry. */
+	return pte;
+}
+
+static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
+{
+	pmd_t pmd;
+
+	pmd_val(pmd) = pte_val(pte);
+	pte_val(pte) = pmd_val(pmd_modify(pmd, newprot));
+	return pte;
+}
+
+static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+				  pte_t *ptep)
+{
+	pmd_clear((pmd_t *) ptep);
+}
+
 #endif /* _ASM_S390_HUGETLB_H */
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 75b8750..7c9a145 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -419,6 +419,13 @@ extern unsigned long MODULES_END;
 #define __S110	PAGE_RW
 #define __S111	PAGE_RW
 
+/*
+ * Segment entry (large page) protection definitions.
+ */
+#define SEGMENT_NONE	__pgprot(_HPAGE_TYPE_NONE)
+#define SEGMENT_RO	__pgprot(_HPAGE_TYPE_RO)
+#define SEGMENT_RW	__pgprot(_HPAGE_TYPE_RW)
+
 static inline int mm_exclusive(struct mm_struct *mm)
 {
 	return likely(mm == current->active_mm &&
@@ -909,26 +916,6 @@ static inline pte_t pte_mkspecial(pte_t pte)
 #ifdef CONFIG_HUGETLB_PAGE
 static inline pte_t pte_mkhuge(pte_t pte)
 {
-	/*
-	 * PROT_NONE needs to be remapped from the pte type to the ste type.
-	 * The HW invalid bit is also different for pte and ste. The pte
-	 * invalid bit happens to be the same as the ste _SEGMENT_ENTRY_LARGE
-	 * bit, so we don't have to clear it.
-	 */
-	if (pte_val(pte) & _PAGE_INVALID) {
-		if (pte_val(pte) & _PAGE_SWT)
-			pte_val(pte) |= _HPAGE_TYPE_NONE;
-		pte_val(pte) |= _SEGMENT_ENTRY_INV;
-	}
-	/*
-	 * Clear SW pte bits, there are no SW bits in a segment table entry.
-	 */
-	pte_val(pte) &= ~(_PAGE_SWT | _PAGE_SWX | _PAGE_SWC |
-			  _PAGE_SWR | _PAGE_SWW);
-	/*
-	 * Also set the change-override bit because we don't need dirty bit
-	 * tracking for hugetlbfs pages.
-	 */
 	pte_val(pte) |= (_SEGMENT_ENTRY_LARGE | _SEGMENT_ENTRY_CO);
 	return pte;
 }
@@ -1273,31 +1260,7 @@ static inline void __pmd_idte(unsigned long address, pmd_t *pmdp)
 	}
 }
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-
-#define SEGMENT_NONE	__pgprot(_HPAGE_TYPE_NONE)
-#define SEGMENT_RO	__pgprot(_HPAGE_TYPE_RO)
-#define SEGMENT_RW	__pgprot(_HPAGE_TYPE_RW)
-
-#define __HAVE_ARCH_PGTABLE_DEPOSIT
-extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable);
-
-#define __HAVE_ARCH_PGTABLE_WITHDRAW
-extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm);
-
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return pmd_val(pmd) & _SEGMENT_ENTRY_SPLIT;
-}
-
-static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
-			      pmd_t *pmdp, pmd_t entry)
-{
-	if (!(pmd_val(entry) & _SEGMENT_ENTRY_INV) && MACHINE_HAS_EDAT1)
-		pmd_val(entry) |= _SEGMENT_ENTRY_CO;
-	*pmdp = entry;
-}
-
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLB_PAGE)
 static inline unsigned long massage_pgprot_pmd(pgprot_t pgprot)
 {
 	/*
@@ -1318,10 +1281,11 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 	return pmd;
 }
 
-static inline pmd_t pmd_mkhuge(pmd_t pmd)
+static inline pmd_t mk_pmd_phys(unsigned long physpage, pgprot_t pgprot)
 {
-	pmd_val(pmd) |= _SEGMENT_ENTRY_LARGE;
-	return pmd;
+	pmd_t __pmd;
+	pmd_val(__pmd) = physpage + massage_pgprot_pmd(pgprot);
+	return __pmd;
 }
 
 static inline pmd_t pmd_mkwrite(pmd_t pmd)
@@ -1331,6 +1295,34 @@ static inline pmd_t pmd_mkwrite(pmd_t pmd)
 		pmd_val(pmd) &= ~_SEGMENT_ENTRY_RO;
 	return pmd;
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLB_PAGE */
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
+#define __HAVE_ARCH_PGTABLE_DEPOSIT
+extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable);
+
+#define __HAVE_ARCH_PGTABLE_WITHDRAW
+extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm);
+
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return pmd_val(pmd) & _SEGMENT_ENTRY_SPLIT;
+}
+
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t entry)
+{
+	if (!(pmd_val(entry) & _SEGMENT_ENTRY_INV) && MACHINE_HAS_EDAT1)
+		pmd_val(entry) |= _SEGMENT_ENTRY_CO;
+	*pmdp = entry;
+}
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	pmd_val(pmd) |= _SEGMENT_ENTRY_LARGE;
+	return pmd;
+}
 
 static inline pmd_t pmd_wrprotect(pmd_t pmd)
 {
@@ -1427,13 +1419,6 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 	}
 }
 
-static inline pmd_t mk_pmd_phys(unsigned long physpage, pgprot_t pgprot)
-{
-	pmd_t __pmd;
-	pmd_val(__pmd) = physpage + massage_pgprot_pmd(pgprot);
-	return __pmd;
-}
-
 #define pfn_pmd(pfn, pgprot)	mk_pmd_phys(__pa((pfn) << PAGE_SHIFT), (pgprot))
 #define mk_pmd(page, pgprot)	pfn_pmd(page_to_pfn(page), (pgprot))
 
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 532525e..121089d 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -39,7 +39,7 @@ int arch_prepare_hugepage(struct page *page)
 	if (!ptep)
 		return -ENOMEM;
 
-	pte = mk_pte(page, PAGE_RW);
+	pte_val(pte) = addr;
 	for (i = 0; i < PTRS_PER_PTE; i++) {
 		set_pte_at(&init_mm, addr + i * PAGE_SIZE, ptep + i, pte);
 		pte_val(pte) += PAGE_SIZE;
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index b3808c7..699255d 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -3,6 +3,7 @@
 
 #include <asm/cacheflush.h>
 #include <asm/page.h>
+#include <asm-generic/hugetlb.h>
 
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 7eb57d2..e4cab46 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -2,6 +2,7 @@
 #define _ASM_SPARC64_HUGETLB_H
 
 #include <asm/page.h>
+#include <asm-generic/hugetlb.h>
 
 
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
index 0f885af..3257733 100644
--- a/arch/tile/include/asm/hugetlb.h
+++ b/arch/tile/include/asm/hugetlb.h
@@ -16,6 +16,7 @@
 #define _ASM_TILE_HUGETLB_H
 
 #include <asm/page.h>
+#include <asm-generic/hugetlb.h>
 
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index bdd35db..a809121 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -2,6 +2,7 @@
 #define _ASM_X86_HUGETLB_H
 
 #include <asm/page.h>
+#include <asm-generic/hugetlb.h>
 
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
new file mode 100644
index 0000000..d06079c
--- /dev/null
+++ b/include/asm-generic/hugetlb.h
@@ -0,0 +1,40 @@
+#ifndef _ASM_GENERIC_HUGETLB_H
+#define _ASM_GENERIC_HUGETLB_H
+
+static inline pte_t mk_huge_pte(struct page *page, pgprot_t pgprot)
+{
+	return mk_pte(page, pgprot);
+}
+
+static inline int huge_pte_write(pte_t pte)
+{
+	return pte_write(pte);
+}
+
+static inline int huge_pte_dirty(pte_t pte)
+{
+	return pte_dirty(pte);
+}
+
+static inline pte_t huge_pte_mkwrite(pte_t pte)
+{
+	return pte_mkwrite(pte);
+}
+
+static inline pte_t huge_pte_mkdirty(pte_t pte)
+{
+	return pte_mkdirty(pte);
+}
+
+static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
+{
+	return pte_modify(pte, newprot);
+}
+
+static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+				  pte_t *ptep)
+{
+	pte_clear(mm, addr, ptep);
+}
+
+#endif /* _ASM_GENERIC_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c65a8a5..43425ad 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2243,10 +2243,11 @@ static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
 	pte_t entry;
 
 	if (writable) {
-		entry =
-		    pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
+		entry = huge_pte_mkwrite(huge_pte_mkdirty(mk_huge_pte(page,
+					 vma->vm_page_prot)));
 	} else {
-		entry = huge_pte_wrprotect(mk_pte(page, vma->vm_page_prot));
+		entry = huge_pte_wrprotect(mk_huge_pte(page,
+					   vma->vm_page_prot));
 	}
 	entry = pte_mkyoung(entry);
 	entry = pte_mkhuge(entry);
@@ -2260,7 +2261,7 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
 {
 	pte_t entry;
 
-	entry = pte_mkwrite(pte_mkdirty(huge_ptep_get(ptep)));
+	entry = huge_pte_mkwrite(huge_pte_mkdirty(huge_ptep_get(ptep)));
 	if (huge_ptep_set_access_flags(vma, address, ptep, entry, 1))
 		update_mmu_cache(vma, address, ptep);
 }
@@ -2375,7 +2376,7 @@ again:
 		 * HWPoisoned hugepage is already unmapped and dropped reference
 		 */
 		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
-			pte_clear(mm, address, ptep);
+			huge_pte_clear(mm, address, ptep);
 			continue;
 		}
 
@@ -2399,7 +2400,7 @@ again:
 
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		tlb_remove_tlb_entry(tlb, ptep, address);
-		if (pte_dirty(pte))
+		if (huge_pte_dirty(pte))
 			set_page_dirty(page);
 
 		page_remove_rmap(page);
@@ -2852,7 +2853,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * page now as it is used to determine if a reservation has been
 	 * consumed.
 	 */
-	if ((flags & FAULT_FLAG_WRITE) && !pte_write(entry)) {
+	if ((flags & FAULT_FLAG_WRITE) && !huge_pte_write(entry)) {
 		if (vma_needs_reservation(h, vma, address) < 0) {
 			ret = VM_FAULT_OOM;
 			goto out_mutex;
@@ -2882,12 +2883,12 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 
 	if (flags & FAULT_FLAG_WRITE) {
-		if (!pte_write(entry)) {
+		if (!huge_pte_write(entry)) {
 			ret = hugetlb_cow(mm, vma, address, ptep, entry,
 							pagecache_page);
 			goto out_page_table_lock;
 		}
-		entry = pte_mkdirty(entry);
+		entry = huge_pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
 	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
@@ -2958,7 +2959,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		if (absent ||
-		    ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
+		    ((flags & FOLL_WRITE) && !huge_pte_write(huge_ptep_get(pte)))) {
 			int ret;
 
 			spin_unlock(&mm->page_table_lock);
@@ -3028,7 +3029,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		}
 		if (!huge_pte_none(huge_ptep_get(ptep))) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
-			pte = pte_mkhuge(pte_modify(pte, newprot));
+			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
 			pte = arch_make_huge_pte(pte, vma, NULL, 0);
 			set_huge_pte_at(mm, address, ptep, pte);
 			pages++;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
