Date: Wed, 19 Mar 2008 14:27:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] 4/4 i_mmap_lock spinlock2rwsem (#v9 was 1/4)
In-Reply-To: <20080307155244.GF24114@v2.random>
Message-ID: <Pine.LNX.4.64.0803191425530.1999@schroedinger.engr.sgi.com>
References: <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random>
 <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
 <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
 <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
 <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random>
 <20080307155244.GF24114@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

You need this patch to address the issues (that I already mentioned when I 
sent the patch to you). New EMM notifier patch with sleeping coming soon.

From: Christoph Lameter <clameter@sgi.com>
Subject: Move tlb flushing into free_pgtables

Move the tlb flushing into free_pgtables. The conversion of the locks
taken for reverse map scanning would require taking sleeping locks
in free_pgtables. Moving the tlb flushing into free_pgtables allows
sleeping in part of free_pgtables().

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
