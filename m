Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B3FD76B0007
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 11:18:47 -0500 (EST)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 1/2] mm: Allow arch code to control the user page table ceiling
Date: Mon, 18 Feb 2013 16:18:30 +0000
Message-Id: <1361204311-14127-2-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com>
References: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

From: Hugh Dickins <hughd@google.com>

On architectures where a pgd entry may be shared between user and kernel
(ARM+LPAE), freeing page tables needs a ceiling other than 0. This patch
introduces a generic USER_PGTABLES_CEILING that arch code can override.

Signed-off-by: Hugh Dickins <hughd@google.com>
[catalin.marinas@arm.com: commit log; shift_arg_pages(), asm-generic/pgtables.h changes]
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/exec.c                     |  4 ++--
 include/asm-generic/pgtable.h | 10 ++++++++++
 mm/mmap.c                     |  4 ++--
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 20df02c..547eaaa 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -613,7 +613,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 		 * when the old and new regions overlap clear from new_end.
 		 */
 		free_pgd_range(&tlb, new_end, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			vma->vm_next ? vma->vm_next->vm_start : USER_PGTABLES_CEILING);
 	} else {
 		/*
 		 * otherwise, clean from old_start; this is done to not touch
@@ -622,7 +622,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 		 * for the others its just a little faster.
 		 */
 		free_pgd_range(&tlb, old_start, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			vma->vm_next ? vma->vm_next->vm_start : USER_PGTABLES_CEILING);
 	}
 	tlb_finish_mmu(&tlb, new_end, old_end);
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 5cf680a..f50a87d 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -7,6 +7,16 @@
 #include <linux/mm_types.h>
 #include <linux/bug.h>
 
+/*
+ * On almost all architectures and configurations, 0 can be used as the
+ * upper ceiling to free_pgtables(): on many architectures it has the same
+ * effect as using TASK_SIZE.  However, there is one configuration which
+ * must impose a more careful limit, to avoid freeing kernel pgtables.
+ */
+#ifndef USER_PGTABLES_CEILING
+#define USER_PGTABLES_CEILING	0UL
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 extern int ptep_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pte_t *ptep,
diff --git a/mm/mmap.c b/mm/mmap.c
index d1e4124..e262710 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2262,7 +2262,7 @@ static void unmap_region(struct mm_struct *mm,
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end);
 	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
-				 next ? next->vm_start : 0);
+				 next ? next->vm_start : USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, start, end);
 }
 
@@ -2640,7 +2640,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
+	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
