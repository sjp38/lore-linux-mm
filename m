From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:48 +1100
Message-Id: <20070113024648.29682.63031.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 13/29] Finish abstracting tear down
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 13
 * Adjust hugetlb.h to refer to free_pt_range
 * Put optimization code in free_pgtables into a macro in
 pt_default.h, since it is implementation dependent.  Call 
 free_pt_range from interface in free_pgtables.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/hugetlb.h |    2 +-
 mm/memory.c             |   12 +++---------
 mm/pt-default.c         |    2 +-
 3 files changed, 5 insertions(+), 11 deletions(-)
Index: linux-2.6.20-rc4/mm/memory.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/memory.c	2007-01-11 13:11:54.675868000 +1100
+++ linux-2.6.20-rc4/mm/memory.c	2007-01-11 13:12:14.767868000 +1100
@@ -112,16 +112,10 @@
 				floor, next? next->vm_start: ceiling);
 		} else {
 			/*
-			 * Optimization: gather nearby vmas into one call down
+			 * Optimization: gather nearby vmas into one call down for default page table
 			 */
-			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
-			       && !is_vm_hugetlb_page(next)) {
-				vma = next;
-				next = vma->vm_next;
-				anon_vma_unlink(vma);
-				unlink_file_vma(vma);
-			}
-			free_pgd_range(tlb, addr, vma->vm_end,
+			vma_optimization;
+			free_pt_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		}
 		vma = next;
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:11:54.671868000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:12:14.771868000 +1100
@@ -226,7 +226,7 @@
  *
  * Must be called with pagetable lock held.
  */
-void free_pgd_range(struct mmu_gather **tlb,
+void free_pt_range(struct mmu_gather **tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
 {
Index: linux-2.6.20-rc4/include/linux/hugetlb.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/hugetlb.h	2007-01-11 13:00:53.680752000 +1100
+++ linux-2.6.20-rc4/include/linux/hugetlb.h	2007-01-11 13:12:14.775868000 +1100
@@ -49,7 +49,7 @@
 #endif
 
 #ifndef ARCH_HAS_HUGETLB_FREE_PGD_RANGE
-#define hugetlb_free_pgd_range	free_pgd_range
+#define hugetlb_free_pgd_range	free_pt_range
 #else
 void hugetlb_free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
