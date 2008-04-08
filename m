Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 4 of 9] Move the tlb flushing into free_pgtables. The
	conversion of the locks
Message-Id: <2c2ed514f294dbbfc661.1207669447@duo.random>
In-Reply-To: <patchbomb.1207669443@duo.random>
Date: Tue, 08 Apr 2008 17:44:07 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1207666463 -7200
# Node ID 2c2ed514f294dbbfc66157f771bc900789ac6005
# Parent  33de2e17d0f5670515833bf8d3d2ea19e2a85b09
Move the tlb flushing into free_pgtables. The conversion of the locks
taken for reverse map scanning would require taking sleeping locks
in free_pgtables(). Moving the tlb flushing into free_pgtables allows
sleeping in parts of free_pgtables().

This means that we do a tlb_finish_mmu() before freeing the page tables.
Strictly speaking there may not be the need to do another tlb flush after
freeing the tables. But its the only way to free a series of page table
pages from the tlb list. And we do not want to call into the page allocator
for performance reasons. Aim9 numbers look okay after this patch.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -751,8 +751,8 @@
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
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -272,9 +272,11 @@
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
@@ -286,8 +288,10 @@
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
+			tlb = tlb_gather_mmu(vma->vm_mm, 0);
+			hugetlb_free_pgd_range(&tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
+			tlb_finish_mmu(tlb, addr, vma->vm_end);
 		} else {
 			/*
 			 * Optimization: gather nearby vmas into one call down
@@ -299,8 +303,10 @@
 				anon_vma_unlink(vma);
 				unlink_file_vma(vma);
 			}
-			free_pgd_range(tlb, addr, vma->vm_end,
+			tlb = tlb_gather_mmu(vma->vm_mm, 0);
+			free_pgd_range(&tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
+			tlb_finish_mmu(tlb, addr, vma->vm_end);
 		}
 		vma = next;
 	}
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1752,9 +1752,9 @@
 	mmu_notifier_invalidate_range_start(mm, start, end);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
+	tlb_finish_mmu(tlb, start, end);
+	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
-	tlb_finish_mmu(tlb, start, end);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
@@ -2051,8 +2051,8 @@
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
+	free_pgtables(vma, FIRST_USER_ADDRESS, 0);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
