Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 558886B006E
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:34:57 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so4878076lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:34:56 -0700 (PDT)
Subject: [PATCH v3 08/10] mm: kill vma flag VM_EXECUTABLE and
 mm->num_exe_file_vmas
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:34:52 +0400
Message-ID: <20120731103452.20182.11699.stgit@zurg>
In-Reply-To: <20120731102546.20182.8450.stgit@zurg>
References: <20120731102546.20182.8450.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

Currently the kernel sets mm->exe_file during sys_execve() and then tracks
number of vmas with VM_EXECUTABLE flag in mm->num_exe_file_vmas, as soon as
this counter drops to zero kernel resets mm->exe_file to NULL. Plus it resets
mm->exe_file at last mmput() when mm->mm_users drops to zero.

VMA with VM_EXECUTABLE flag appears after mapping file with flag MAP_EXECUTABLE,
such vmas can appears only at sys_execve() or after vma splitting, because
sys_mmap ignores this flag. Usually binfmt module sets mm->exe_file and mmaps
executable vmas with this file, they hold mm->exe_file while task is running.

comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
where all this stuff was introduced:

> The kernel implements readlink of /proc/pid/exe by getting the file from
> the first executable VMA.  Then the path to the file is reconstructed and
> reported as the result.
>
> Because of the VMA walk the code is slightly different on nommu systems.
> This patch avoids separate /proc/pid/exe code on nommu systems.  Instead of
> walking the VMAs to find the first executable file-backed VMA we store a
> reference to the exec'd file in the mm_struct.
>
> That reference would prevent the filesystem holding the executable file
> from being unmounted even after unmapping the VMAs.  So we track the number
> of VM_EXECUTABLE VMAs and drop the new reference when the last one is
> unmapped.  This avoids pinning the mounted filesystem.

exe_file's vma accouning is hooked into every file mmap/unmmap and vma
split/merge just to fix some hypothetical pinning fs from umounting by mm,
which already unmapped all its executable files, but still alive.

Seems like currently nobody depends on this behaviour.
We can try to remove this logic and keep mm->exe_file until final mmput().

mm->exe_file is still protected with mm->mmap_sem, because we want to change it
via new sys_prctl(PR_SET_MM_EXE_FILE). Also via this syscall task can change
its mm->exe_file and unpin mountpoint explicitly.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Matt Helsley <matthltc@us.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
---
 include/linux/mm.h       |    4 ----
 include/linux/mm_types.h |    1 -
 include/linux/mman.h     |    1 -
 kernel/fork.c            |   21 ---------------------
 mm/mmap.c                |   22 +++-------------------
 mm/nommu.c               |   11 +----------
 6 files changed, 4 insertions(+), 56 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6eb4406..ee2676e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -87,7 +87,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
-#define VM_EXECUTABLE	0x00001000
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
@@ -1366,9 +1365,6 @@ extern void exit_mmap(struct mm_struct *);
 extern int mm_take_all_locks(struct mm_struct *mm);
 extern void mm_drop_all_locks(struct mm_struct *mm);
 
-/* From fs/proc/base.c. callers must _not_ hold the mm's exe_file_lock */
-extern void added_exe_file_vma(struct mm_struct *mm);
-extern void removed_exe_file_vma(struct mm_struct *mm);
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 074eb98..bbd221f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -385,7 +385,6 @@ struct mm_struct {
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
 	struct file *exe_file;
-	unsigned long num_exe_file_vmas;
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 8b74e9b..77cec2f 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -86,7 +86,6 @@ calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
-	       _calc_vm_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE) |
 	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
 }
 #endif /* __KERNEL__ */
diff --git a/kernel/fork.c b/kernel/fork.c
index bd5c4c5..8fb89bf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -625,26 +625,6 @@ void mmput(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmput);
 
-/*
- * We added or removed a vma mapping the executable. The vmas are only mapped
- * during exec and are not mapped with the mmap system call.
- * Callers must hold down_write() on the mm's mmap_sem for these
- */
-void added_exe_file_vma(struct mm_struct *mm)
-{
-	mm->num_exe_file_vmas++;
-}
-
-void removed_exe_file_vma(struct mm_struct *mm)
-{
-	mm->num_exe_file_vmas--;
-	if ((mm->num_exe_file_vmas == 0) && mm->exe_file) {
-		fput(mm->exe_file);
-		mm->exe_file = NULL;
-	}
-
-}
-
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	if (new_exe_file)
@@ -652,7 +632,6 @@ void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 	if (mm->exe_file)
 		fput(mm->exe_file);
 	mm->exe_file = new_exe_file;
-	mm->num_exe_file_vmas = 0;
 }
 
 struct file *get_mm_exe_file(struct mm_struct *mm)
diff --git a/mm/mmap.c b/mm/mmap.c
index 56231b7..c9c0e7f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -231,11 +231,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file) {
+	if (vma->vm_file)
 		fput(vma->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
-			removed_exe_file_vma(vma->vm_mm);
-	}
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
@@ -636,8 +633,6 @@ again:			remove_next = 1 + (end > next->vm_end);
 		if (file) {
 			uprobe_munmap(next, next->vm_start, next->vm_end);
 			fput(file);
-			if (next->vm_flags & VM_EXECUTABLE)
-				removed_exe_file_vma(mm);
 		}
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
@@ -1303,8 +1298,6 @@ munmap_back:
 		error = file->f_op->mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
-		if (vm_flags & VM_EXECUTABLE)
-			added_exe_file_vma(mm);
 
 		/* Can addr have changed??
 		 *
@@ -1990,11 +1983,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	if (anon_vma_clone(new, vma))
 		goto out_free_mpol;
 
-	if (new->vm_file) {
+	if (new->vm_file)
 		get_file(new->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
-			added_exe_file_vma(mm);
-	}
 
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
@@ -2012,11 +2002,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	/* Clean everything up if vma_adjust failed. */
 	if (new->vm_ops && new->vm_ops->close)
 		new->vm_ops->close(new);
-	if (new->vm_file) {
-		if (vma->vm_flags & VM_EXECUTABLE)
-			removed_exe_file_vma(mm);
+	if (new->vm_file)
 		fput(new->vm_file);
-	}
 	unlink_anon_vmas(new);
  out_free_mpol:
 	mpol_put(pol);
@@ -2419,9 +2406,6 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 
 				if (uprobe_mmap(new_vma))
 					goto out_free_mempol;
-
-				if (vma->vm_flags & VM_EXECUTABLE)
-					added_exe_file_vma(mm);
 			}
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
diff --git a/mm/nommu.c b/mm/nommu.c
index 686d200..5583325 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -789,11 +789,8 @@ static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 	kenter("%p", vma);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file) {
+	if (vma->vm_file)
 		fput(vma->vm_file);
-		if (vma->vm_flags & VM_EXECUTABLE)
-			removed_exe_file_vma(mm);
-	}
 	put_nommu_region(vma->vm_region);
 	kmem_cache_free(vm_area_cachep, vma);
 }
@@ -1286,10 +1283,6 @@ unsigned long do_mmap_pgoff(struct file *file,
 		get_file(file);
 		vma->vm_file = file;
 		get_file(file);
-		if (vm_flags & VM_EXECUTABLE) {
-			added_exe_file_vma(current->mm);
-			vma->vm_mm = current->mm;
-		}
 	}
 
 	down_write(&nommu_region_sem);
@@ -1442,8 +1435,6 @@ error:
 	kmem_cache_free(vm_region_jar, region);
 	if (vma->vm_file)
 		fput(vma->vm_file);
-	if (vma->vm_flags & VM_EXECUTABLE)
-		removed_exe_file_vma(vma->vm_mm);
 	kmem_cache_free(vm_area_cachep, vma);
 	kleave(" = %d", ret);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
