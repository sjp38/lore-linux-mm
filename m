From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] [patch 2/9] Move tlb flushing into free_pgtables
Date: Tue, 01 Apr 2008 13:55:33 -0700
Message-ID: <20080401205636.048829606@sgi.com>
References: <20080401205531.986291575@sgi.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline; filename=move_tlb_flush
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Hugh Dickins <hugh@veritas.com>
Cc: steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-Id: linux-mm.kvack.org

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

---
 include/linux/mm.h |    4 ++--
 mm/memory.c        |   14 ++++++++++----
 mm/mmap.c          |    6 +++---
 3 files changed, 15 insertions(+), 9 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2008-03-19 13:30:51.460856986 -0700
+++ linux-2.6/include/linux/mm.h	2008-03-19 13:31:20.809377398 -0700
@@ -751,8 +751,8 @@ int walk_page_range(const struct mm_stru
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
--- linux-2.6.orig/mm/memory.c	2008-03-19 13:29:06.007351495 -0700
+++ linux-2.6/mm/memory.c	2008-03-19 13:46:31.352774359 -0700
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
@@ -285,8 +287,10 @@ void free_pgtables(struct mmu_gather **t
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
@@ -298,8 +302,10 @@ void free_pgtables(struct mmu_gather **t
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
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-03-19 13:29:48.659889667 -0700
+++ linux-2.6/mm/mmap.c	2008-03-19 13:30:36.296604891 -0700
@@ -1750,9 +1750,9 @@ static void unmap_region(struct mm_struc
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
-				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	free_pgtables(vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
+				 next? next->vm_start: 0);
 	emm_notify(mm, emm_invalidate_end, start, end);
 }
 
@@ -2049,8 +2049,8 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
+	free_pgtables(vma, FIRST_USER_ADDRESS, 0);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,

-- 
