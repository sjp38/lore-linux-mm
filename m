Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 50B666B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 06:39:43 -0500 (EST)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] mm: Limit pgd range freeing to mm->task_size
Date: Wed, 13 Feb 2013 11:39:29 +0000
Message-Id: <1360755569-27282-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Russell King <linux@arm.linux.org.uk>

ARM processors with LPAE enabled use 3 levels of page tables, with an
entry in the top level (pgd) covering 1GB of virtual space. Because of
the branch relocation limitations on ARM, the loadable modules are
mapped 16MB below PAGE_OFFSET, making the corresponding 1GB pgd shared
between kernel modules and user space.

Since free_pgtables() is called with ceiling == 0, free_pgd_range() (and
subsequently called functions) also frees the page table
shared between user space and kernel modules (which is normally handled
by the ARM-specific pgd_free() function).

This patch changes the ceiling argument to mm->task_size for the
free_pgtables() and free_pgd_range() function calls. We cannot use
TASK_SIZE since this macro may not be a run-time constant on 64-bit
systems supporting compat applications.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>
---

Hi Andrew,

I posted this patch a couple of times in the past. The latest
incarnation (using mm->task_size instead of TASK_SIZE) is a result of
discussions I had with Andrea and benh at the last KS.

Do you have any comments on it? It fixes a problem on ARM (32-bit) with
LPAE.

Thanks.

 fs/exec.c | 4 ++--
 mm/mmap.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 20df02c..04c1534 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -613,7 +613,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 		 * when the old and new regions overlap clear from new_end.
 		 */
 		free_pgd_range(&tlb, new_end, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			vma->vm_next ? vma->vm_next->vm_start : mm->task_size);
 	} else {
 		/*
 		 * otherwise, clean from old_start; this is done to not touch
@@ -622,7 +622,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 		 * for the others its just a little faster.
 		 */
 		free_pgd_range(&tlb, old_start, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			vma->vm_next ? vma->vm_next->vm_start : mm->task_size);
 	}
 	tlb_finish_mmu(&tlb, new_end, old_end);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 35730ee..e15d294 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2262,7 +2262,7 @@ static void unmap_region(struct mm_struct *mm,
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end);
 	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
-				 next ? next->vm_start : 0);
+				 next ? next->vm_start : mm->task_size);
 	tlb_finish_mmu(&tlb, start, end);
 }
 
@@ -2640,7 +2640,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
+	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, mm->task_size);
 	tlb_finish_mmu(&tlb, 0, -1);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
