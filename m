Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 7D16B6B0073
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 05:08:41 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 6/9] thp: add address parameter to split_huge_page_pmd()
Date: Thu,  9 Aug 2012 12:08:17 +0300
Message-Id: <1344503300-9507-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's required to implement huge zero pmd splitting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt |    4 ++--
 arch/x86/kernel/vm86_32.c      |    2 +-
 fs/proc/task_mmu.c             |    2 +-
 include/linux/huge_mm.h        |   10 ++++++----
 mm/huge_memory.c               |    5 +++--
 mm/memory.c                    |    4 ++--
 mm/mempolicy.c                 |    2 +-
 mm/mprotect.c                  |    2 +-
 mm/mremap.c                    |    3 ++-
 mm/pagewalk.c                  |    2 +-
 10 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index f734bb2..b1fe2ca 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -276,7 +276,7 @@ unaffected. libhugetlbfs will also work fine as usual.
 == Graceful fallback ==
 
 Code walking pagetables but unware about huge pmds can simply call
-split_huge_page_pmd(mm, pmd) where the pmd is the one returned by
+split_huge_page_pmd(mm, pmd, addr) where the pmd is the one returned by
 pmd_offset. It's trivial to make the code transparent hugepage aware
 by just grepping for "pmd_offset" and adding split_huge_page_pmd where
 missing after pmd_offset returns the pmd. Thanks to the graceful
@@ -299,7 +299,7 @@ diff --git a/mm/mremap.c b/mm/mremap.c
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
-+	split_huge_page_pmd(mm, pmd);
++	split_huge_page_pmd(mm, pmd, addr);
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 255f58a..719ba0c 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -180,7 +180,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	if (pud_none_or_clear_bad(pud))
 		goto out;
 	pmd = pmd_offset(pud, 0xA0000);
-	split_huge_page_pmd(mm, pmd);
+	split_huge_page_pmd(mm, pmd, 0xA0000);
 	if (pmd_none_or_clear_bad(pmd))
 		goto out;
 	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4540b8f..27c1827 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -597,7 +597,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	struct page *page;
 
-	split_huge_page_pmd(walk->mm, pmd);
+	split_huge_page_pmd(walk->mm, pmd, addr);
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4c59b11..ce91199 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -92,12 +92,14 @@ extern int handle_pte_fault(struct mm_struct *mm,
 			    struct vm_area_struct *vma, unsigned long address,
 			    pte_t *pte, pmd_t *pmd, unsigned int flags);
 extern int split_huge_page(struct page *page);
-extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
-#define split_huge_page_pmd(__mm, __pmd)				\
+extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd,
+		unsigned long address);
+#define split_huge_page_pmd(__mm, __pmd, __address)			\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		if (unlikely(pmd_trans_huge(*____pmd)))			\
-			__split_huge_page_pmd(__mm, ____pmd);		\
+			__split_huge_page_pmd(__mm, ____pmd,		\
+					__address);			\
 	}  while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
@@ -174,7 +176,7 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
-#define split_huge_page_pmd(__mm, __pmd)	\
+#define split_huge_page_pmd(__mm, __pmd, __address)	\
 	do { } while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4001f1a..c8948d6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2503,7 +2503,8 @@ static int khugepaged(void *none)
 	return 0;
 }
 
-void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
+void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd,
+		unsigned long address)
 {
 	struct page *page;
 
@@ -2547,7 +2548,7 @@ static void split_huge_page_address(struct mm_struct *mm,
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	split_huge_page_pmd(mm, pmd);
+	split_huge_page_pmd(mm, pmd, address);
 }
 
 void __vma_adjust_trans_huge(struct vm_area_struct *vma,
diff --git a/mm/memory.c b/mm/memory.c
index c281847..e202392 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1227,7 +1227,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 					BUG();
 				}
 #endif
-				split_huge_page_pmd(vma->vm_mm, pmd);
+				split_huge_page_pmd(vma->vm_mm, pmd, addr);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
 			/* fall through */
@@ -1493,7 +1493,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 	}
 	if (pmd_trans_huge(*pmd)) {
 		if (flags & FOLL_SPLIT) {
-			split_huge_page_pmd(mm, pmd);
+			split_huge_page_pmd(mm, pmd, address);
 			goto split_fallthrough;
 		}
 		spin_lock(&mm->page_table_lock);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1d771e4..44c818d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -511,7 +511,7 @@ static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		split_huge_page_pmd(vma->vm_mm, pmd);
+		split_huge_page_pmd(vma->vm_mm, pmd, addr);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
 		if (check_pte_range(vma, pmd, addr, next, nodes,
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a409926..e85e29d 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -90,7 +90,7 @@ static inline void change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
-				split_huge_page_pmd(vma->vm_mm, pmd);
+				split_huge_page_pmd(vma->vm_mm, pmd, addr);
 			else if (change_huge_pmd(vma, pmd, addr, newprot))
 				continue;
 			/* fall through */
diff --git a/mm/mremap.c b/mm/mremap.c
index 21fed20..790df47 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -156,7 +156,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 				need_flush = true;
 				continue;
 			} else if (!err) {
-				split_huge_page_pmd(vma->vm_mm, old_pmd);
+				split_huge_page_pmd(vma->vm_mm, old_pmd,
+						old_addr);
 			}
 			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 6c118d0..7e92ebd 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -58,7 +58,7 @@ again:
 		if (!walk->pte_entry)
 			continue;
 
-		split_huge_page_pmd(walk->mm, pmd);
+		split_huge_page_pmd(walk->mm, pmd, addr);
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
