Message-Id: <20080626003832.789231631@sgi.com>
References: <20080626003632.049547282@sgi.com>
Date: Wed, 25 Jun 2008 17:36:33 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 1/5] Move tlb handling into free_pgtables()
Content-Disposition: inline; filename=move_tlb_flushing_into_free_pgtables
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: apw@shadowen.org, Hugh Dickins <hugh@veritas.com>, holt@sgi.com, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Move the tlb_gather/tlb_finish call into the free_pgtables() function so
that tlb_gather/finish is done for each vma separately.
This may add a number of tlb flushes depending on the
number of vmas that survive the coalescing scan.

The first pointer argument to free_pgtables() can then be dropped.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |    4 ++--
 mm/memory.c        |   13 +++++++++----
 mm/mmap.c          |    6 +++---
 3 files changed, 14 insertions(+), 9 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2008-06-09 20:20:58.770505275 -0700
+++ linux-2.6/include/linux/mm.h	2008-06-09 20:22:59.845841566 -0700
@@ -772,8 +772,8 @@ int walk_page_range(const struct mm_stru
 		    void *private);
 void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
-		unsigned long floor, unsigned long ceiling);
+void free_pgtables(struct vm_area_struct *start_vma, unsigned long floor,
+						unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-06-09 20:20:58.806841642 -0700
+++ linux-2.6/mm/memory.c	2008-06-09 20:22:59.845841566 -0700
@@ -271,9 +271,11 @@ void free_pgd_range(struct mmu_gather **
 	} while (pgd++, addr = next, addr != end);
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
-		unsigned long floor, unsigned long ceiling)
+void free_pgtables(struct vm_area_struct *vma, unsigned long floor,
+							unsigned long ceiling)
 {
+	struct mmu_gather *tlb;
+
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long addr = vma->vm_start;
@@ -285,7 +287,8 @@ void free_pgtables(struct mmu_gather **t
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
+			tlb = tlb_gather_mmu(vma->vm_mm, 0);
+			hugetlb_free_pgd_range(&tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		} else {
 			/*
@@ -298,9 +301,11 @@ void free_pgtables(struct mmu_gather **t
 				anon_vma_unlink(vma);
 				unlink_file_vma(vma);
 			}
-			free_pgd_range(tlb, addr, vma->vm_end,
+			tlb = tlb_gather_mmu(vma->vm_mm, 0);
+			free_pgd_range(&tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		}
+		tlb_finish_mmu(tlb, addr, vma->vm_end);
 		vma = next;
 	}
 }
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-06-09 20:20:58.821591534 -0700
+++ linux-2.6/mm/mmap.c	2008-06-09 20:22:59.845841566 -0700
@@ -1762,9 +1762,9 @@ static void unmap_region(struct mm_struc
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
-				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
+				 next? next->vm_start: 0);
 }
 
 /*
@@ -2062,8 +2062,8 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
+	free_pgtables(vma, FIRST_USER_ADDRESS, 0);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
