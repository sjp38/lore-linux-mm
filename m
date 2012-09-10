Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D26206B007D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 09:13:25 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v2 06/10] thp: change split_huge_page_pmd() interface
Date: Mon, 10 Sep 2012 16:13:29 +0300
Message-Id: <1347282813-21935-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Pass vma instead of mm and add address parameter.

In most cases we already have vma on the stack. We provides
split_huge_page_pmd_mm() for few cases when we have mm, but not vma.

This change is preparation to huge zero pmd splitting implementation.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt |    4 ++--
 arch/x86/kernel/vm86_32.c      |    2 +-
 fs/proc/task_mmu.c             |    2 +-
 include/linux/huge_mm.h        |   14 ++++++++++----
 mm/huge_memory.c               |   24 +++++++++++++++++++-----
 mm/memory.c                    |    4 ++--
 mm/mempolicy.c                 |    2 +-
 mm/mprotect.c                  |    2 +-
 mm/mremap.c                    |    2 +-
 mm/pagewalk.c                  |    2 +-
 10 files changed, 39 insertions(+), 19 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index f734bb2..677a599 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -276,7 +276,7 @@ unaffected. libhugetlbfs will also work fine as usual.
 == Graceful fallback ==
 
 Code walking pagetables but unware about huge pmds can simply call
-split_huge_page_pmd(mm, pmd) where the pmd is the one returned by
+split_huge_page_pmd(vma, pmd, addr) where the pmd is the one returned by
 pmd_offset. It's trivial to make the code transparent hugepage aware
 by just grepping for "pmd_offset" and adding split_huge_page_pmd where
 missing after pmd_offset returns the pmd. Thanks to the graceful
@@ -299,7 +299,7 @@ diff --git a/mm/mremap.c b/mm/mremap.c
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
-+	split_huge_page_pmd(mm, pmd);
++	split_huge_page_pmd(vma, pmd, addr);
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 54abcc0..22840bb 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -182,7 +182,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	if (pud_none_or_clear_bad(pud))
 		goto out;
 	pmd = pmd_offset(pud, 0xA0000);
-	split_huge_page_pmd(mm, pmd);
+	split_huge_page_pmd_mm(mm, 0xA0000, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		goto out;
 	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4540b8f..766d5d7 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -597,7 +597,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	struct page *page;
 
-	split_huge_page_pmd(walk->mm, pmd);
+	split_huge_page_pmd(vma, addr, pmd);
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4c59b11..c68e073 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -92,12 +92,14 @@ extern int handle_pte_fault(struct mm_struct *mm,
 			    struct vm_area_struct *vma, unsigned long address,
 			    pte_t *pte, pmd_t *pmd, unsigned int flags);
 extern int split_huge_page(struct page *page);
-extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
-#define split_huge_page_pmd(__mm, __pmd)				\
+extern void __split_huge_page_pmd(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd);
+#define split_huge_page_pmd(__vma, __address, __pmd)			\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		if (unlikely(pmd_trans_huge(*____pmd)))			\
-			__split_huge_page_pmd(__mm, ____pmd);		\
+			__split_huge_page_pmd(__vma, __address,		\
+					____pmd);			\
 	}  while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
@@ -107,6 +109,8 @@ extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
 	} while (0)
+extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
+		pmd_t *pmd);
 #if HPAGE_PMD_ORDER > MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -174,10 +178,12 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
-#define split_huge_page_pmd(__mm, __pmd)	\
+#define split_huge_page_pmd(__vma, __address, __pmd)	\
 	do { } while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
+#define split_huge_page_pmd_mm(__mm, __address, __pmd)	\
+	do { } while (0)
 #define compound_trans_head(page) compound_head(page)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4001f1a..48ecc46 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2503,19 +2503,23 @@ static int khugepaged(void *none)
 	return 0;
 }
 
-void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
+void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd)
 {
 	struct page *page;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 
-	spin_lock(&mm->page_table_lock);
+	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
+
+	spin_lock(&vma->vm_mm->page_table_lock);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(&vma->vm_mm->page_table_lock);
 		return;
 	}
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 
 	split_huge_page(page);
 
@@ -2523,6 +2527,16 @@ void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
 	BUG_ON(pmd_trans_huge(*pmd));
 }
 
+void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
+		pmd_t *pmd)
+{
+	struct vm_area_struct *vma;
+
+	vma = find_vma(mm, address);
+	BUG_ON(vma == NULL);
+	split_huge_page_pmd(vma, address, pmd);
+}
+
 static void split_huge_page_address(struct mm_struct *mm,
 				    unsigned long address)
 {
@@ -2547,7 +2561,7 @@ static void split_huge_page_address(struct mm_struct *mm,
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	split_huge_page_pmd(mm, pmd);
+	split_huge_page_pmd_mm(mm, address, pmd);
 }
 
 void __vma_adjust_trans_huge(struct vm_area_struct *vma,
diff --git a/mm/memory.c b/mm/memory.c
index dbd92ba..312c21d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1236,7 +1236,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 					BUG();
 				}
 #endif
-				split_huge_page_pmd(vma->vm_mm, pmd);
+				split_huge_page_pmd(vma, addr, pmd);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
 			/* fall through */
@@ -1505,7 +1505,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 	}
 	if (pmd_trans_huge(*pmd)) {
 		if (flags & FOLL_SPLIT) {
-			split_huge_page_pmd(mm, pmd);
+			split_huge_page_pmd(vma, address, pmd);
 			goto split_fallthrough;
 		}
 		spin_lock(&mm->page_table_lock);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4ada3be..55ac3b6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -511,7 +511,7 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		split_huge_page_pmd(vma->vm_mm, pmd);
+		split_huge_page_pmd(vma, addr, pmd);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
 		if (check_pte_range(vma, pmd, addr, next, nodes,
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a409926..e8c3938 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -90,7 +90,7 @@ static inline void change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
-				split_huge_page_pmd(vma->vm_mm, pmd);
+				split_huge_page_pmd(vma, addr, pmd);
 			else if (change_huge_pmd(vma, pmd, addr, newprot))
 				continue;
 			/* fall through */
diff --git a/mm/mremap.c b/mm/mremap.c
index cc06d0e..292ec46 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -156,7 +156,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 				need_flush = true;
 				continue;
 			} else if (!err) {
-				split_huge_page_pmd(vma->vm_mm, old_pmd);
+				split_huge_page_pmd(vma, old_addr, old_pmd);
 			}
 			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 6c118d0..35aa294 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -58,7 +58,7 @@ again:
 		if (!walk->pte_entry)
 			continue;
 
-		split_huge_page_pmd(walk->mm, pmd);
+		split_huge_page_pmd_mm(walk->mm, addr, pmd);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			goto again;
 		err = walk_pte_range(pmd, addr, next, walk);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
