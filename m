Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C721D6B00A4
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:45 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj1so915444pad.17
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:45 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id uv6si3082252pbc.255.2014.11.05.06.50.43
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:44 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 09/19] thp: rename split_huge_page_pmd() to split_huge_pmd()
Date: Wed,  5 Nov 2014 16:49:44 +0200
Message-Id: <1415198994-15252-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to decouple splitting THP PMD from splitting underlying
compound page.

This patch renames split_huge_page_pmd*() functions to split_huge_pmd*()
to reflect the fact that it doesn't imply page splitting, only PMD.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/powerpc/mm/subpage-prot.c |  2 +-
 arch/s390/mm/pgtable.c         |  2 +-
 arch/x86/kernel/vm86_32.c      |  6 +++++-
 include/linux/huge_mm.h        |  8 ++------
 mm/huge_memory.c               | 33 +++++++++++++--------------------
 mm/memory.c                    |  2 +-
 mm/mempolicy.c                 |  2 +-
 mm/mprotect.c                  |  2 +-
 mm/mremap.c                    |  2 +-
 mm/pagewalk.c                  |  2 +-
 10 files changed, 27 insertions(+), 34 deletions(-)

diff --git a/arch/powerpc/mm/subpage-prot.c b/arch/powerpc/mm/subpage-prot.c
index fa9fb5b4c66c..d5543514c1df 100644
--- a/arch/powerpc/mm/subpage-prot.c
+++ b/arch/powerpc/mm/subpage-prot.c
@@ -135,7 +135,7 @@ static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
-	split_huge_page_pmd(vma, addr, pmd);
+	split_huge_pmd(vma, pmd, addr);
 	return 0;
 }
 
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index a43f4d33f376..a14585c0b4e3 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -1252,7 +1252,7 @@ static int thp_split_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 		struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
-	split_huge_page_pmd(vma, addr, pmd);
+	split_huge_pmd(vma, pmd, addr);
 	return 0;
 }
 
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index e8edcf52e069..883160599965 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -182,7 +182,11 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	if (pud_none_or_clear_bad(pud))
 		goto out;
 	pmd = pmd_offset(pud, 0xA0000);
-	split_huge_page_pmd_mm(mm, 0xA0000, pmd);
+
+	if (pmd_trans_huge(*pmd)) {
+		struct vm_area_struct *vma = find_vma(mm, 0xA0000);
+		split_huge_pmd(vma, pmd, 0xA0000);
+	}
 	if (pmd_none_or_clear_bad(pmd))
 		goto out;
 	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 63579cb8d3dc..e7fc53ddfe43 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -100,7 +100,7 @@ static inline int split_huge_page(struct page *page)
 }
 extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd);
-#define split_huge_page_pmd(__vma, __address, __pmd)			\
+#define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		if (unlikely(pmd_trans_huge(*____pmd)))			\
@@ -115,8 +115,6 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
 	} while (0)
-extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd);
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -176,11 +174,9 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
-#define split_huge_page_pmd(__vma, __address, __pmd)	\
-	do { } while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
-#define split_huge_page_pmd_mm(__mm, __address, __pmd)	\
+#define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index aa22350673a7..9411f2c93dd6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1137,13 +1137,13 @@ alloc:
 
 	if (unlikely(!new_page)) {
 		if (!page) {
-			split_huge_page_pmd(vma, address, pmd);
+			split_huge_pmd(vma, pmd, address);
 			ret |= VM_FAULT_FALLBACK;
 		} else {
 			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
 					pmd, orig_pmd, page, haddr);
 			if (ret & VM_FAULT_OOM) {
-				split_huge_page(page);
+				split_huge_pmd(vma, pmd, address);
 				ret |= VM_FAULT_FALLBACK;
 			}
 			put_user_huge_page(page);
@@ -1156,10 +1156,10 @@ alloc:
 					   GFP_TRANSHUGE, &memcg))) {
 		put_page(new_page);
 		if (page) {
-			split_huge_page(page);
+			split_huge_pmd(vma, pmd, address);
 			put_user_huge_page(page);
 		} else
-			split_huge_page_pmd(vma, address, pmd);
+			split_huge_pmd(vma, pmd, address);
 		ret |= VM_FAULT_FALLBACK;
 		count_vm_event(THP_FAULT_FALLBACK);
 		goto out;
@@ -1685,17 +1685,7 @@ again:
 		goto again;
 }
 
-void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd)
-{
-	struct vm_area_struct *vma;
-
-	vma = find_vma(mm, address);
-	BUG_ON(vma == NULL);
-	split_huge_page_pmd(vma, address, pmd);
-}
-
-static void split_huge_page_address(struct mm_struct *mm,
+static void split_huge_page_address(struct vm_area_struct *vma,
 				    unsigned long address)
 {
 	pgd_t *pgd;
@@ -1704,7 +1694,7 @@ static void split_huge_page_address(struct mm_struct *mm,
 
 	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
 
-	pgd = pgd_offset(mm, address);
+	pgd = pgd_offset(vma->vm_mm, address);
 	if (!pgd_present(*pgd))
 		return;
 
@@ -1715,11 +1705,14 @@ static void split_huge_page_address(struct mm_struct *mm,
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		return;
+
+	if (!pmd_trans_huge(*pmd))
+		return;
 	/*
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	split_huge_page_pmd_mm(mm, address, pmd);
+	__split_huge_page_pmd(vma, address, pmd);
 }
 static int __split_huge_page_splitting(struct page *page,
 				       struct vm_area_struct *vma,
@@ -2947,7 +2940,7 @@ void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (start & ~HPAGE_PMD_MASK &&
 	    (start & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (start & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_page_address(vma->vm_mm, start);
+		split_huge_page_address(vma, start);
 
 	/*
 	 * If the new end address isn't hpage aligned and it could
@@ -2957,7 +2950,7 @@ void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (end & ~HPAGE_PMD_MASK &&
 	    (end & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (end & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_page_address(vma->vm_mm, end);
+		split_huge_page_address(vma, end);
 
 	/*
 	 * If we're also updating the vma->vm_next->vm_start, if the new
@@ -2971,6 +2964,6 @@ void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 		if (nstart & ~HPAGE_PMD_MASK &&
 		    (nstart & HPAGE_PMD_MASK) >= next->vm_start &&
 		    (nstart & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= next->vm_end)
-			split_huge_page_address(next->vm_mm, nstart);
+			split_huge_page_address(next, nstart);
 	}
 }
diff --git a/mm/memory.c b/mm/memory.c
index 1b17a72dc93f..3f7a8bd768de 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1239,7 +1239,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 					BUG();
 				}
 #endif
-				split_huge_page_pmd(vma, addr, pmd);
+				split_huge_pmd(vma, pmd, addr);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
 			/* fall through */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d1ac73927003..a6396a0df018 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -501,7 +501,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	split_huge_page_pmd(vma, addr, pmd);
+	split_huge_pmd(vma, pmd, addr);
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557941f8..775a66a598dc 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -162,7 +162,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
-				split_huge_page_pmd(vma, addr, pmd);
+				split_huge_pmd(vma, pmd, addr);
 			else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
 						newprot, prot_numa);
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180e9f21..d2d1047e5dc3 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -209,7 +209,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 				need_flush = true;
 				continue;
 			} else if (!err) {
-				split_huge_page_pmd(vma, old_addr, old_pmd);
+				split_huge_pmd(vma, old_pmd, old_addr);
 			}
 			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 65fb68df3aa2..4d2386364561 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -58,7 +58,7 @@ again:
 		if (!walk->pte_entry)
 			continue;
 
-		split_huge_page_pmd_mm(walk->mm, addr, pmd);
+		split_huge_pmd(walk->vma, pmd, addr);
 		if (pmd_trans_unstable(pmd))
 			goto again;
 		err = walk_pte_range(pmd, addr, next, walk);
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
