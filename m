From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:54 +1000
Subject: [RFC/PATCH 12/12] Use mmu_gather for fs/proc/task_mmu.c
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807072000.AE97CDDE11@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This removes the use of flush_tlb_mm() from that proc file, using
an mmu_gather instead.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---


 fs/proc/task_mmu.c |   40 +++++++++++++++++++++++++---------------
 1 file changed, 25 insertions(+), 15 deletions(-)

Index: linux-work/fs/proc/task_mmu.c
===================================================================
--- linux-work.orig/fs/proc/task_mmu.c	2007-08-06 13:48:30.000000000 +1000
+++ linux-work/fs/proc/task_mmu.c	2007-08-07 17:01:41.000000000 +1000
@@ -9,7 +9,7 @@
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
-#include <asm/tlbflush.h>
+#include <asm/tlb.h>
 #include "internal.h"
 
 char *task_mem(struct mm_struct *mm, char *buffer)
@@ -124,11 +124,13 @@ struct mem_size_stats
 	unsigned long referenced;
 };
 
+typedef void (*pmd_action_t)(struct mmu_gather *tlb, struct vm_area_struct *,
+			     pmd_t *, unsigned long, unsigned long, void *);
 struct pmd_walker {
+	struct mmu_gather *tlb;
 	struct vm_area_struct *vma;
 	void *private;
-	void (*action)(struct vm_area_struct *, pmd_t *, unsigned long,
-		       unsigned long, void *);
+	pmd_action_t action;
 };
 
 static int show_map_internal(struct seq_file *m, void *v, struct mem_size_stats *mss)
@@ -218,7 +220,8 @@ static int show_map(struct seq_file *m, 
 	return show_map_internal(m, v, NULL);
 }
 
-static void smaps_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+static void smaps_pte_range(struct mmu_gather *tlb,
+			    struct vm_area_struct *vma, pmd_t *pmd,
 			    unsigned long addr, unsigned long end,
 			    void *private)
 {
@@ -258,7 +261,8 @@ static void smaps_pte_range(struct vm_ar
 	cond_resched();
 }
 
-static void clear_refs_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+static void clear_refs_pte_range(struct mmu_gather *tlb,
+				 struct vm_area_struct *vma, pmd_t *pmd,
 				 unsigned long addr, unsigned long end,
 				 void *private)
 {
@@ -279,6 +283,7 @@ static void clear_refs_pte_range(struct 
 		/* Clear accessed and referenced bits. */
 		ptep_test_and_clear_young(vma, addr, pte);
 		ClearPageReferenced(page);
+		tlb_remove_tlb_entry(tlb, pte, addr);
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
@@ -295,7 +300,8 @@ static inline void walk_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		walker->action(walker->vma, pmd, addr, next, walker->private);
+		walker->action(walker->tlb, walker->vma, pmd, addr, next,
+			       walker->private);
 	}
 }
 
@@ -323,11 +329,9 @@ static inline void walk_pud_range(struct
  * Recursively walk the page table for the memory area in a VMA, calling
  * a callback for every bottom-level (PTE) page table.
  */
-static inline void walk_page_range(struct vm_area_struct *vma,
-				   void (*action)(struct vm_area_struct *,
-						  pmd_t *, unsigned long,
-						  unsigned long, void *),
-				   void *private)
+static inline void walk_page_range(struct mmu_gather *tlb,
+				   struct vm_area_struct *vma,
+				   pmd_action_t	action, void *private)
 {
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
@@ -335,6 +339,7 @@ static inline void walk_page_range(struc
 		.vma		= vma,
 		.private	= private,
 		.action		= action,
+		.tlb		= tlb,
 	};
 	pgd_t *pgd;
 	unsigned long next;
@@ -355,19 +360,24 @@ static int show_smap(struct seq_file *m,
 
 	memset(&mss, 0, sizeof mss);
 	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-		walk_page_range(vma, smaps_pte_range, &mss);
+		walk_page_range(NULL, vma, smaps_pte_range, &mss);
 	return show_map_internal(m, v, &mss);
 }
 
 void clear_refs_smap(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	struct mmu_gather tlb;
+	unsigned long end_addr = 0;
 
 	down_read(&mm->mmap_sem);
+	tlb_gather_mmu(&tlb, mm);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
-		if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-			walk_page_range(vma, clear_refs_pte_range, NULL);
-	flush_tlb_mm(mm);
+		if (vma->vm_mm && !is_vm_hugetlb_page(vma)) {
+			end_addr = max(vma->vm_end, end_addr);
+			walk_page_range(&tlb, vma, clear_refs_pte_range, NULL);
+		}
+	tlb_finish_mmu(&tlb);
 	up_read(&mm->mmap_sem);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
