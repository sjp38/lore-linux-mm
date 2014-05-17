Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4B19E6B0035
	for <linux-mm@kvack.org>; Fri, 16 May 2014 20:33:14 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so3250521pbb.22
        for <linux-mm@kvack.org>; Fri, 16 May 2014 17:33:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id i4si1872476pat.200.2014.05.16.17.33.12
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 17:33:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH] mm: unified interface to handle page table entries on different levels?
Date: Sat, 17 May 2014 03:33:05 +0300
Message-Id: <1400286785-26639-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave@sr71.net, willy@linux.intel.com, riel@redhat.com, mgorman@suse.de, aarcange@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Linux VM was built with fixed page size in mind. We have rich API to
deal with page table entries, but it focused mostly on one level of page
tables -- PTE.

As huge pages was added we duplicated routines on demand for other page
tables level (PMD, PUD). With separate APIs it's hard to harmonize huge
pages support code with rest of VM.

Can we do better than that?

Below is my attempt to play with the problem. I've took one function --
page_referenced_one() -- which looks ugly because of different APIs for
PTE/PMD and convert it to use vpte_t. vpte_t is union for pte_t, pmd_t
and pud_t.

Basically, the idea is instead of having different helpers to handle
PTE/PMD/PUD, we have one, which take pair of vpte_t + pglevel.

Should we try this way? Any suggestions?
---
 arch/x86/include/asm/pgtable.h       |  4 ++
 arch/x86/include/asm/pgtable_types.h |  2 +
 arch/x86/mm/pgtable.c                | 13 +++++++
 include/asm-generic/pgtable-vpte.h   | 34 +++++++++++++++++
 include/asm-generic/pgtable.h        | 15 ++++++++
 include/linux/mm.h                   | 15 ++++++++
 include/linux/mmu_notifier.h         |  8 ++--
 include/linux/rmap.h                 | 13 +++++++
 mm/rmap.c                            | 72 +++++++++++++-----------------------
 9 files changed, 127 insertions(+), 49 deletions(-)
 create mode 100644 include/asm-generic/pgtable-vpte.h

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index b459ddf27d64..407bfe97e22e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -816,6 +816,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 	pmd_update(mm, addr, pmdp);
 }
 
+#define vptep_clear_flush_young vptep_clear_flush_young
+extern int vptep_clear_flush_young(struct vm_area_struct *vma,
+		unsigned long address, vpte_t *vptep, enum ptlevel ptlvl);
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index eb3d44945133..eefc835b7437 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -296,6 +296,8 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 }
 #endif
 
+#include <asm-generic/pgtable-vpte.h>
+
 static inline pudval_t pud_flags(pud_t pud)
 {
 	return native_pud_val(pud) & PTE_FLAGS_MASK;
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index c96314abd144..92a97257a442 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -438,6 +438,19 @@ void pmdp_splitting_flush(struct vm_area_struct *vma,
 }
 #endif
 
+int vptep_clear_flush_young(struct vm_area_struct *vma,
+		unsigned long address, vpte_t *vptep, enum ptlevel ptlvl)
+{
+	int young;
+
+	/* _PAGE_BIT_ACCESSED is in the same place in PTE/PMD/PUD */
+	young = ptep_test_and_clear_young(vma, address, &vptep->pte);
+	if (young)
+		flush_tlb_range(vma, address,
+				address + vpte_size(*vptep, ptlvl));
+
+	return young;
+}
 /**
  * reserve_top_address - reserves a hole in the top of kernel address space
  * @reserve - size of hole to reserve
diff --git a/include/asm-generic/pgtable-vpte.h b/include/asm-generic/pgtable-vpte.h
new file mode 100644
index 000000000000..96e52b5e39ca
--- /dev/null
+++ b/include/asm-generic/pgtable-vpte.h
@@ -0,0 +1,34 @@
+#ifndef _ASM_GENERIC_PGTABLE_VPTE_H
+#define _ASM_GENERIC_PGTABLE_VPTE_H
+
+typedef union {
+	pte_t pte;
+	pmd_t pmd;
+	pud_t pud;
+} vpte_t;
+
+enum ptlevel {
+	PTE,
+	PMD,
+	PUD,
+};
+
+static inline unsigned long vpte_size(vpte_t vptep, enum ptlevel ptlvl)
+{
+	switch (ptlvl) {
+	case PTE:
+		return PAGE_SIZE;
+#ifdef PMD_SIZE
+	case PMD:
+		return PMD_SIZE;
+#endif
+#ifdef PUD_SIZE
+	case PUD:
+		return PUD_SIZE;
+#endif
+	default:
+		return 0; /* XXX */
+	}
+}
+
+#endif
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index a8015a7a55bb..1cfc9ba67078 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -79,6 +79,21 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pmd_t *pmdp);
 #endif
 
+#ifndef vptep_clear_flush_young
+static inline int vptep_clear_flush_young(struct vm_area_struct *vma,
+		unsigned long address, vpte_t *vptep, enum ptlevel ptlvl)
+{
+	switch (ptlvl) {
+	case PTE:
+		return ptep_clear_flush_young(vma, address, &vptep->pte);
+	case PMD:
+		return pmdp_clear_flush_young(vma, address, &vptep->pmd);
+	default:
+		BUG();
+	};
+}
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long address,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d6777060449f..cac04827d93e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1559,6 +1559,21 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 	return ptl;
 }
 
+static inline void vpte_unmap_unlock(vpte_t *vpte, enum ptlevel ptlvl,
+		spinlock_t *ptl)
+{
+	switch (ptlvl) {
+	case PTE:
+		pte_unmap_unlock(&vpte->pte, ptl);
+		break;
+	case PMD:
+		spin_unlock(ptl);
+		break;
+	default:
+		BUG();
+	}
+}
+
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca87452528..927c00ea3c73 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -257,12 +257,14 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	__young;							\
 })
 
-#define pmdp_clear_flush_young_notify(__vma, __address, __pmdp)		\
+#define vptep_clear_flush_young_notify(__vma, __address,		\
+		__vptep, __ptlvl)					\
 ({									\
 	int __young;							\
 	struct vm_area_struct *___vma = __vma;				\
 	unsigned long ___address = __address;				\
-	__young = pmdp_clear_flush_young(___vma, ___address, __pmdp);	\
+	__young = vptep_clear_flush_young(___vma, ___address,		\
+			__vptep, __ptlvl);				\
 	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
 						  ___address);		\
 	__young;							\
@@ -335,7 +337,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 }
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
-#define pmdp_clear_flush_young_notify pmdp_clear_flush_young
+#define vptep_clear_flush_young_notify vptep_clear_flush_young
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b66c2110cb1f..71f2156ac632 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -209,6 +209,19 @@ static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
 	return ptep;
 }
 
+
+static inline vpte_t *page_check_address_vpte(struct page *page,
+		struct mm_struct *mm, unsigned long address,
+		spinlock_t **ptlp, int sync)
+{
+	if (PageTransHuge(page))
+		return (vpte_t *) page_check_address_pmd(page, mm, address,
+				PAGE_CHECK_ADDRESS_PMD_FLAG, ptlp);
+	else
+		return (vpte_t *) page_check_address(page, mm, address,
+				ptlp, sync);
+}
+
 /*
  * Used by swapoff to help locate where page is expected in vma.
  */
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e77396d1a..0101a1a72bb0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -676,59 +676,39 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int referenced = 0;
 	struct page_referenced_arg *pra = arg;
+	vpte_t *vpte;
+	enum ptlevel ptlvl = PTE;
 
-	if (unlikely(PageTransHuge(page))) {
-		pmd_t *pmd;
+	ptlvl = unlikely(PageTransHuge(page)) ? PMD : PTE;
 
-		/*
-		 * rmap might return false positives; we must filter
-		 * these out using page_check_address_pmd().
-		 */
-		pmd = page_check_address_pmd(page, mm, address,
-					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
-		if (!pmd)
-			return SWAP_AGAIN;
-
-		if (vma->vm_flags & VM_LOCKED) {
-			spin_unlock(ptl);
-			pra->vm_flags |= VM_LOCKED;
-			return SWAP_FAIL; /* To break the loop */
-		}
+	/*
+	 * rmap might return false positives; we must filter these out using
+	 * page_check_address_vpte().
+	 */
+	vpte = page_check_address_vpte(page, mm, address, &ptl, 0);
+	if (!vpte)
+		return SWAP_AGAIN;
+
+	if (vma->vm_flags & VM_LOCKED) {
+		vpte_unmap_unlock(vpte, ptlvl, ptl);
+		pra->vm_flags |= VM_LOCKED;
+		return SWAP_FAIL; /* To break the loop */
+	}
 
-		/* go ahead even if the pmd is pmd_trans_splitting() */
-		if (pmdp_clear_flush_young_notify(vma, address, pmd))
-			referenced++;
-		spin_unlock(ptl);
-	} else {
-		pte_t *pte;
 
+	/* go ahead even if the pmd is pmd_trans_splitting() */
+	if (vptep_clear_flush_young_notify(vma, address, vpte, ptlvl)) {
 		/*
-		 * rmap might return false positives; we must filter
-		 * these out using page_check_address().
+		 * Don't treat a reference through a sequentially read
+		 * mapping as such.  If the page has been used in
+		 * another mapping, we will catch it; if this other
+		 * mapping is already gone, the unmap path will have
+		 * set PG_referenced or activated the page.
 		 */
-		pte = page_check_address(page, mm, address, &ptl, 0);
-		if (!pte)
-			return SWAP_AGAIN;
-
-		if (vma->vm_flags & VM_LOCKED) {
-			pte_unmap_unlock(pte, ptl);
-			pra->vm_flags |= VM_LOCKED;
-			return SWAP_FAIL; /* To break the loop */
-		}
-
-		if (ptep_clear_flush_young_notify(vma, address, pte)) {
-			/*
-			 * Don't treat a reference through a sequentially read
-			 * mapping as such.  If the page has been used in
-			 * another mapping, we will catch it; if this other
-			 * mapping is already gone, the unmap path will have
-			 * set PG_referenced or activated the page.
-			 */
-			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
-				referenced++;
-		}
-		pte_unmap_unlock(pte, ptl);
+		if (likely(!(vma->vm_flags & VM_SEQ_READ)))
+			referenced++;
 	}
+	vpte_unmap_unlock(vpte, ptlvl, ptl);
 
 	if (referenced) {
 		pra->referenced++;
-- 
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
