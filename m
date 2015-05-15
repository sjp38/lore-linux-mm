Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3856B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 11:42:51 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so15215718pdf.3
        for <linux-mm@kvack.org>; Fri, 15 May 2015 08:42:50 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id pa5si276958pbc.69.2015.05.15.08.42.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 15 May 2015 08:42:50 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 May 2015 21:12:45 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id ADBC6394004E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:12:43 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4FFgh8k58523684
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:12:43 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4FFggSM019099
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:12:43 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V5 3/3] mm: Clarify that the function operates on hugepage pte
Date: Fri, 15 May 2015 21:12:30 +0530
Message-Id: <1431704550-19937-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1431704550-19937-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1431704550-19937-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We have confusing functions to clear pmd, pmd_clear_* and pmd_clear.
Add _huge_ to pmdp_clear functions so that we are clear that they
operate on hugepage pte.

We don't bother about other functions like pmdp_set_wrprotect,
pmdp_clear_flush_young, because they operate on PTE bits and hence
indicate they are operating on hugepage ptes

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/mips/include/asm/pgtable.h          |  8 ++++----
 arch/powerpc/include/asm/pgtable-ppc64.h |  6 +++---
 arch/powerpc/mm/pgtable_64.c             |  4 ++--
 arch/s390/include/asm/pgtable.h          | 24 ++++++++++++------------
 arch/sparc/include/asm/pgtable_64.h      |  8 ++++----
 arch/tile/include/asm/pgtable.h          |  8 ++++----
 arch/x86/include/asm/pgtable.h           |  4 ++--
 include/asm-generic/pgtable.h            | 24 ++++++++++++++----------
 include/linux/mmu_notifier.h             | 12 ++++++------
 mm/huge_memory.c                         | 16 ++++++++--------
 mm/migrate.c                             |  2 +-
 mm/pgtable-generic.c                     |  8 ++++----
 mm/rmap.c                                |  2 +-
 13 files changed, 65 insertions(+), 61 deletions(-)

diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index 819af9d057a8..9d8106758142 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -568,12 +568,12 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 }
 
 /*
- * The generic version pmdp_get_and_clear uses a version of pmd_clear() with a
+ * The generic version pmdp_huge_get_and_clear uses a version of pmd_clear() with a
  * different prototype.
  */
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
-				       unsigned long address, pmd_t *pmdp)
+#define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long address, pmd_t *pmdp)
 {
 	pmd_t old = *pmdp;
 
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 55f06a381dd7..c378988dc6cf 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -553,9 +553,9 @@ extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pmd_t *pmdp);
 
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-extern pmd_t pmdp_get_and_clear(struct mm_struct *mm,
-				unsigned long addr, pmd_t *pmdp);
+#define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
+extern pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+				     unsigned long addr, pmd_t *pmdp);
 
 #define __HAVE_ARCH_PMDP_SET_WRPROTECT
 static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index d37b9d1a1813..ad0f63628678 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -812,8 +812,8 @@ void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 	return;
 }
 
-pmd_t pmdp_get_and_clear(struct mm_struct *mm,
-			 unsigned long addr, pmd_t *pmdp)
+pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+			      unsigned long addr, pmd_t *pmdp)
 {
 	pmd_t old_pmd;
 	pgtable_t pgtable;
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 17627f73a032..414e7f6fd256 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1498,9 +1498,9 @@ static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 	return pmd_young(pmd);
 }
 
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
-				       unsigned long address, pmd_t *pmdp)
+#define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long address, pmd_t *pmdp)
 {
 	pmd_t pmd = *pmdp;
 
@@ -1509,10 +1509,10 @@ static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
 	return pmd;
 }
 
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR_FULL
-static inline pmd_t pmdp_get_and_clear_full(struct mm_struct *mm,
-					    unsigned long address,
-					    pmd_t *pmdp, int full)
+#define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR_FULL
+static inline pmd_t pmdp_huge_get_and_clear_full(struct mm_struct *mm,
+						 unsigned long address,
+						 pmd_t *pmdp, int full)
 {
 	pmd_t pmd = *pmdp;
 
@@ -1522,11 +1522,11 @@ static inline pmd_t pmdp_get_and_clear_full(struct mm_struct *mm,
 	return pmd;
 }
 
-#define __HAVE_ARCH_PMDP_CLEAR_FLUSH
-static inline pmd_t pmdp_clear_flush(struct vm_area_struct *vma,
-				     unsigned long address, pmd_t *pmdp)
+#define __HAVE_ARCH_PMDP_HUGE_CLEAR_FLUSH
+static inline pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
+					  unsigned long address, pmd_t *pmdp)
 {
-	return pmdp_get_and_clear(vma->vm_mm, address, pmdp);
+	return pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
 }
 
 #define __HAVE_ARCH_PMDP_INVALIDATE
@@ -1552,7 +1552,7 @@ static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 					unsigned long address,
 					pmd_t *pmdp)
 {
-	return pmdp_get_and_clear(vma->vm_mm, address, pmdp);
+	return pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
 }
 #define pmdp_collapse_flush pmdp_collapse_flush
 
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index dc165ebdf05a..2b72f651f393 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -845,10 +845,10 @@ static inline unsigned long pud_pfn(pud_t pud)
 void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
 		   pte_t *ptep, pte_t orig, int fullmm);
 
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
-				       unsigned long addr,
-				       pmd_t *pmdp)
+#define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long addr,
+					    pmd_t *pmdp)
 {
 	pmd_t pmd = *pmdp;
 	set_pmd_at(mm, addr, pmdp, __pmd(0UL));
diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 95a4f19d16c5..2b05ccbebed9 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -414,10 +414,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 }
 
 
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
-				       unsigned long address,
-				       pmd_t *pmdp)
+#define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long address,
+					    pmd_t *pmdp)
 {
 	return pte_pmd(ptep_get_and_clear(mm, address, pmdp_ptep(pmdp)));
 }
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index fe57e7a98839..25add5e44f0a 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -799,8 +799,8 @@ static inline int pmd_write(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_RW;
 }
 
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
+#define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pmd_t *pmdp)
 {
 	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 3d0273d4dad6..1ee1260d5386 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -96,11 +96,11 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 }
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_GET_AND_CLEAR
+#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
-				       unsigned long address,
-				       pmd_t *pmdp)
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long address,
+					    pmd_t *pmdp)
 {
 	pmd_t pmd = *pmdp;
 	pmd_clear(pmdp);
@@ -109,13 +109,13 @@ static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_GET_AND_CLEAR_FULL
+#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR_FULL
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline pmd_t pmdp_get_and_clear_full(struct mm_struct *mm,
+static inline pmd_t pmdp_huge_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long address, pmd_t *pmdp,
 					    int full)
 {
-	return pmdp_get_and_clear(mm, address, pmdp);
+	return pmdp_huge_get_and_clear(mm, address, pmdp);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
@@ -152,8 +152,8 @@ extern pte_t ptep_clear_flush(struct vm_area_struct *vma,
 			      pte_t *ptep);
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_CLEAR_FLUSH
-extern pmd_t pmdp_clear_flush(struct vm_area_struct *vma,
+#ifndef __HAVE_ARCH_PMDP_HUGE_CLEAR_FLUSH
+extern pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
 			      unsigned long address,
 			      pmd_t *pmdp);
 #endif
@@ -196,10 +196,14 @@ static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 					unsigned long address,
 					pmd_t *pmdp)
 {
+	/*
+	 * pmd and hugepage pte format are same. So we could
+	 * use the same function.
+	 */
 	pmd_t pmd;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	VM_BUG_ON(pmd_trans_huge(*pmdp));
-	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
+	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 95243d28a0ee..61cd67f4d788 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -324,25 +324,25 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	___pte;								\
 })
 
-#define pmdp_clear_flush_notify(__vma, __haddr, __pmd)			\
+#define pmdp_huge_clear_flush_notify(__vma, __haddr, __pmd)		\
 ({									\
 	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
 	struct mm_struct *___mm = (__vma)->vm_mm;			\
 	pmd_t ___pmd;							\
 									\
-	___pmd = pmdp_clear_flush(__vma, __haddr, __pmd);		\
+	___pmd = pmdp_huge_clear_flush(__vma, __haddr, __pmd);		\
 	mmu_notifier_invalidate_range(___mm, ___haddr,			\
 				      ___haddr + HPAGE_PMD_SIZE);	\
 									\
 	___pmd;								\
 })
 
-#define pmdp_get_and_clear_notify(__mm, __haddr, __pmd)			\
+#define pmdp_huge_get_and_clear_notify(__mm, __haddr, __pmd)		\
 ({									\
 	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
 	pmd_t ___pmd;							\
 									\
-	___pmd = pmdp_get_and_clear(__mm, __haddr, __pmd);		\
+	___pmd = pmdp_huge_get_and_clear(__mm, __haddr, __pmd);		\
 	mmu_notifier_invalidate_range(__mm, ___haddr,			\
 				      ___haddr + HPAGE_PMD_SIZE);	\
 									\
@@ -428,8 +428,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
 #define	ptep_clear_flush_notify ptep_clear_flush
-#define pmdp_clear_flush_notify pmdp_clear_flush
-#define pmdp_get_and_clear_notify pmdp_get_and_clear
+#define pmdp_huge_clear_flush_notify pmdp_huge_clear_flush
+#define pmdp_huge_get_and_clear_notify pmdp_huge_get_and_clear
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 88f695a4e38b..c19adcb2c324 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1031,7 +1031,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		goto out_free_pages;
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
@@ -1174,7 +1174,7 @@ alloc:
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		pmdp_clear_flush_notify(vma, haddr, pmd);
+		pmdp_huge_clear_flush_notify(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
@@ -1396,12 +1396,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pmd_t orig_pmd;
 		/*
 		 * For architectures like ppc64 we look at deposited pgtable
-		 * when calling pmdp_get_and_clear. So do the
+		 * when calling pmdp_huge_get_and_clear. So do the
 		 * pgtable_trans_huge_withdraw after finishing pmdp related
 		 * operations.
 		 */
-		orig_pmd = pmdp_get_and_clear_full(tlb->mm, addr, pmd,
-						   tlb->fullmm);
+		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
+							tlb->fullmm);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 		if (is_huge_zero_pmd(orig_pmd)) {
@@ -1459,7 +1459,7 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		new_ptl = pmd_lockptr(mm, new_pmd);
 		if (new_ptl != old_ptl)
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
-		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
+		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 
 		if (pmd_move_must_withdraw(new_ptl, old_ptl)) {
@@ -1505,7 +1505,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		}
 
 		if (!prot_numa || !pmd_protnone(*pmd)) {
-			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
+			entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
 			if (preserve_write)
 				entry = pmd_mkwrite(entry);
@@ -2865,7 +2865,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	pmd_t _pmd;
 	int i;
 
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
diff --git a/mm/migrate.c b/mm/migrate.c
index f53838fe3dfe..c37d5772767b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1796,7 +1796,7 @@ fail_putback:
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_anon_rmap(new_page, vma, mmun_start);
-	pmdp_clear_flush_notify(vma, mmun_start, pmd);
+	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
 	update_mmu_cache_pmd(vma, address, &entry);
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index dd9d04f17749..af063ad47d55 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -119,15 +119,15 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
 }
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_CLEAR_FLUSH
+#ifndef __HAVE_ARCH_PMDP_HUGE_CLEAR_FLUSH
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
-		       pmd_t *pmdp)
+pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
+			    pmd_t *pmdp)
 {
 	pmd_t pmd;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	VM_BUG_ON(!pmd_trans_huge(*pmdp));
-	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
+	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 24dd3f9fee27..6f94e4502c49 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -625,7 +625,7 @@ pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address)
 
 	pmd = pmd_offset(pud, address);
 	/*
-	 * Some THP functions use the sequence pmdp_clear_flush(), set_pmd_at()
+	 * Some THP functions use the sequence pmdp_huge_clear_flush(), set_pmd_at()
 	 * without holding anon_vma lock for write.  So when looking for a
 	 * genuine pmde (in which to find pte), test present and !THP together.
 	 */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
