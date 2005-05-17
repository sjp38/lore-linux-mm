Message-Id: <200505172228.j4HMSkg28528@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Tue, 17 May 2005 15:28:46 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <E4BA51C8E4E9634993418831223F0A49291F06E1@scsmsx401.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Wolfgang Wander' <wwc@rentec.com>, 'Andrew Morton' <akpm@osdl.org>
Cc: mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch tries to solve address space fragmentation issue brought
up by Wolfgang where fragmentation is so severe that application
would fail on 2.6 kernel.  Looking a bit deep into the issue, we
found that a lot of fragmentation were caused by suboptimal algorithm
in the munmap code path.  For example, as people pointed out that
when a series of munmap occurs, the free_area_cache would point to
last vma that was freed, ignoring its surrounding and not performing
any coalescing at all, thus artificially create more holes in the
virtual address space than necessary.  However, all the information
needed to perform coalescing are actually already there.  This patch
put that data in use so we will prevent artificial fragmentation.

This patch covers both bottom-up and top-down topology.  For bottom-up
topology, free_area_cache points to prev->vm_end. And for top-down,
free_area_cache points to next->vm_start.  The results are very promising,
it passes the test case that Wolfgang posted and I have tested it on a
variety of x86, x86_64, ia64 machines.

Please note, this patch completely obsoletes previous patch that
Wolfgang posted and should completely retain the performance benefit
of free_area_cache and at the same time preserving fragmentation to
minimum.

Andrew, please consider for -mm testing.  Thanks.

- Ken Chen


 mmap.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- linux-2.6.11/mm/mmap.c.orig	2005-05-17 15:05:02.487937407 -0700
+++ linux-2.6.11/mm/mmap.c	2005-05-17 15:05:13.292624775 -0700
@@ -1208,9 +1208,10 @@ void arch_unmap_area(struct vm_area_stru
 	/*
 	 * Is this a new hole at the lowest possible address?
 	 */
-	if (area->vm_start >= TASK_UNMAPPED_BASE &&
-			area->vm_start < area->vm_mm->free_area_cache)
-		area->vm_mm->free_area_cache = area->vm_start;
+	unsigned long addr = (unsigned long) area->vm_private_data;
+
+	if (addr >= TASK_UNMAPPED_BASE && addr < area->vm_mm->free_area_cache)
+		area->vm_mm->free_area_cache = addr;
 }
 
 /*
@@ -1290,8 +1291,10 @@ void arch_unmap_area_topdown(struct vm_a
 	/*
 	 * Is this a new hole at the highest possible address?
 	 */
-	if (area->vm_end > area->vm_mm->free_area_cache)
-		area->vm_mm->free_area_cache = area->vm_end;
+	unsigned long addr = (unsigned long) area->vm_private_data;
+
+	if (addr > area->vm_mm->free_area_cache)
+		area->vm_mm->free_area_cache = addr;
 
 	/* dont allow allocations above current base */
 	if (area->vm_mm->free_area_cache > area->vm_mm->mmap_base)
@@ -1656,6 +1659,11 @@ detach_vmas_to_be_unmapped(struct mm_str
 	} while (vma && vma->vm_start < end);
 	*insertion_point = vma;
 	tail_vma->vm_next = NULL;
+	if (mm->unmap_area == arch_unmap_area)
+		tail_vma->vm_private_data = (void*) prev->vm_end;
+	else
+		tail_vma->vm_private_data = vma ?
+			(void*) vma->vm_start : (void*) mm->mmap_base;
 	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
