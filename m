Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5389003CA
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:21:25 -0400 (EDT)
Received: by iggf3 with SMTP id f3so82576644igg.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:21:25 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id s8si6154168igd.59.2015.07.20.07.21.22
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 09/36] thp: rename split_huge_page_pmd() to split_huge_pmd()
Date: Mon, 20 Jul 2015 17:20:42 +0300
Message-Id: <1437402069-105900-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to decouple splitting THP PMD from splitting underlying
compound page.

This patch renames split_huge_page_pmd*() functions to split_huge_pmd*()
to reflect the fact that it doesn't imply page splitting, only PMD.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/powerpc/mm/subpage-prot.c |  2 +-
 arch/x86/kernel/vm86_32.c      |  6 +++++-
 include/linux/huge_mm.h        |  8 ++------
 mm/gup.c                       |  2 +-
 mm/huge_memory.c               | 32 +++++++++++---------------------
 mm/madvise.c                   |  2 +-
 mm/memory.c                    |  2 +-
 mm/mempolicy.c                 |  2 +-
 mm/mprotect.c                  |  2 +-
 mm/mremap.c                    |  2 +-
 mm/pagewalk.c                  |  2 +-
 11 files changed, 26 insertions(+), 36 deletions(-)

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
 
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index fc9db6ef2a95..bf85db746b2c 100644
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
index cff4e4bc7fab..f825694a23ee 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -106,7 +106,7 @@ static inline int split_huge_page(struct page *page)
 }
 extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd);
-#define split_huge_page_pmd(__vma, __address, __pmd)			\
+#define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		if (unlikely(pmd_trans_huge(*____pmd)))			\
@@ -121,8 +121,6 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
 	} while (0)
-extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd);
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -190,11 +188,9 @@ static inline int split_huge_page(struct page *page)
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
diff --git a/mm/gup.c b/mm/gup.c
index b8bba5589be6..b2f9790e5a98 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -252,7 +252,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		if (is_huge_zero_page(page)) {
 			spin_unlock(ptl);
 			ret = 0;
-			split_huge_page_pmd(vma, address, pmd);
+			split_huge_pmd(vma, pmd, address);
 		} else {
 			get_page(page);
 			spin_unlock(ptl);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bef7b3595fbe..c93828c16716 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1204,13 +1204,13 @@ alloc:
 
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
@@ -1223,10 +1223,10 @@ alloc:
 					&memcg, true))) {
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
@@ -3062,17 +3062,7 @@ again:
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
+static void split_huge_pmd_address(struct vm_area_struct *vma,
 				    unsigned long address)
 {
 	pgd_t *pgd;
@@ -3081,7 +3071,7 @@ static void split_huge_page_address(struct mm_struct *mm,
 
 	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
 
-	pgd = pgd_offset(mm, address);
+	pgd = pgd_offset(vma->vm_mm, address);
 	if (!pgd_present(*pgd))
 		return;
 
@@ -3090,13 +3080,13 @@ static void split_huge_page_address(struct mm_struct *mm,
 		return;
 
 	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
+	if (!pmd_present(*pmd) || !pmd_trans_huge(*pmd))
 		return;
 	/*
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	split_huge_page_pmd_mm(mm, address, pmd);
+	__split_huge_page_pmd(vma, address, pmd);
 }
 
 void vma_adjust_trans_huge(struct vm_area_struct *vma,
@@ -3112,7 +3102,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (start & ~HPAGE_PMD_MASK &&
 	    (start & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (start & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_page_address(vma->vm_mm, start);
+		split_huge_pmd_address(vma, start);
 
 	/*
 	 * If the new end address isn't hpage aligned and it could
@@ -3122,7 +3112,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (end & ~HPAGE_PMD_MASK &&
 	    (end & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (end & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_page_address(vma->vm_mm, end);
+		split_huge_pmd_address(vma, end);
 
 	/*
 	 * If we're also updating the vma->vm_next->vm_start, if the new
@@ -3136,6 +3126,6 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 		if (nstart & ~HPAGE_PMD_MASK &&
 		    (nstart & HPAGE_PMD_MASK) >= next->vm_start &&
 		    (nstart & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= next->vm_end)
-			split_huge_page_address(next->vm_mm, nstart);
+			split_huge_pmd_address(next, nstart);
 	}
 }
diff --git a/mm/madvise.c b/mm/madvise.c
index 67d5fe74ffdf..0588facc4381 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -283,7 +283,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
 		if (next - addr != HPAGE_PMD_SIZE)
-			split_huge_page_pmd(vma, addr, pmd);
+			split_huge_pmd(vma, pmd, addr);
 		else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
 			goto next;
 		/* fall through */
diff --git a/mm/memory.c b/mm/memory.c
index 720b3bebf1f9..e830477d40b7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1204,7 +1204,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 					BUG();
 				}
 #endif
-				split_huge_page_pmd(vma, addr, pmd);
+				split_huge_pmd(vma, pmd, addr);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
 			/* fall through */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a7f1e0d1d6b8..b6122c0f613d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -493,7 +493,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	split_huge_page_pmd(vma, addr, pmd);
+	split_huge_pmd(vma, pmd, addr);
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ef5be8eaab00..9c1445dc8a4c 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -160,7 +160,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
-				split_huge_page_pmd(vma, addr, pmd);
+				split_huge_pmd(vma, pmd, addr);
 			else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
 						newprot, prot_numa);
diff --git a/mm/mremap.c b/mm/mremap.c
index 5a71cce8c6ea..9cf393ac6e43 100644
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
index 29f2f8b853ae..207244489a68 100644
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
