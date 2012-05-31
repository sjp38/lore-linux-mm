Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id EA8846B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 02:40:19 -0400 (EDT)
Received: by dakp5 with SMTP id p5so1030826dak.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 23:40:19 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] mm: account the total_vm in the vm_stat_account()
Date: Thu, 31 May 2012 14:44:15 -0400
Message-Id: <1338489855-3119-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>

The vm_stat_account() accounts the shared_vm, stack_vm and
reserved_vm now. But we can also account the total_vm in
the vm_stat_account() which makes the code tidy.

Even for mprotect_fixup(), we can get the right result in the end.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 arch/ia64/kernel/perfmon.c |    1 -
 include/linux/mm.h         |    1 +
 kernel/fork.c              |    4 +---
 mm/mmap.c                  |    5 ++---
 mm/mremap.c                |    2 --
 5 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index f00ba02..926028b 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2359,7 +2359,6 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	 */
 	insert_vm_struct(mm, vma);
 
-	mm->total_vm  += size >> PAGE_SHIFT;
 	vm_stat_account(vma->vm_mm, vma->vm_flags, vma->vm_file,
 							vma_pages(vma));
 	up_write(&task->mm->mmap_sem);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8437e93..5332c75 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1555,6 +1555,7 @@ void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
 static inline void vm_stat_account(struct mm_struct *mm,
 			unsigned long flags, struct file *file, long pages)
 {
+	mm->total_vm += pages;
 }
 #endif /* CONFIG_PROC_FS */
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 3decf6d..537b3a2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -377,10 +377,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		struct file *file;
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
-			long pages = vma_pages(mpnt);
-			mm->total_vm -= pages;
 			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
-								-pages);
+							-vma_pages(mpnt));
 			continue;
 		}
 		charge = 0;
diff --git a/mm/mmap.c b/mm/mmap.c
index ca5ee7b..41aa294 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -943,6 +943,8 @@ void vm_stat_account(struct mm_struct *mm, unsigned long flags,
 	const unsigned long stack_flags
 		= VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
 
+	mm->total_vm += pages;
+
 	if (file) {
 		mm->shared_vm += pages;
 		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
@@ -1382,7 +1384,6 @@ munmap_back:
 out:
 	perf_event_mmap(vma);
 
-	mm->total_vm += len >> PAGE_SHIFT;
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if (!mlock_vma_pages_range(vma, addr, addr + len))
@@ -1740,7 +1741,6 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		return -ENOMEM;
 
 	/* Ok, everything looks good - let it rip */
-	mm->total_vm += grow;
 	if (vma->vm_flags & VM_LOCKED)
 		mm->locked_vm += grow;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, grow);
@@ -1922,7 +1922,6 @@ static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
 
 		if (vma->vm_flags & VM_ACCOUNT)
 			nr_accounted += nrpages;
-		mm->total_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
 		vma = remove_vma(vma);
 	} while (vma);
diff --git a/mm/mremap.c b/mm/mremap.c
index db8d983..7bfb289 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -260,7 +260,6 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	 * If this were a serious issue, we'd add a flag to do_munmap().
 	 */
 	hiwater_vm = mm->hiwater_vm;
-	mm->total_vm += new_len >> PAGE_SHIFT;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, new_len>>PAGE_SHIFT);
 
 	if (do_munmap(mm, old_addr, old_len) < 0) {
@@ -499,7 +498,6 @@ unsigned long do_mremap(unsigned long addr,
 				goto out;
 			}
 
-			mm->total_vm += pages;
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
