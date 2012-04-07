Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 284856B007E
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 15:01:38 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so3469210bkw.14
        for <linux-mm@kvack.org>; Sat, 07 Apr 2012 12:01:37 -0700 (PDT)
Subject: [PATCH v2 09/10] mm: kill mm->num_exe_file_vmas and keep mm->exe_file
 until final mmput()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 07 Apr 2012 23:01:33 +0400
Message-ID: <20120407190133.9726.26191.stgit@zurg>
In-Reply-To: <20120407185546.9726.62260.stgit@zurg>
References: <20120407185546.9726.62260.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Matt Helsley <matthltc@us.ibm.com>, Oleg Nesterov <oleg@redhat.com>

exe_file's vma accouning is hooked into every file mmap/unmmap and vma
split/merge just to fix some hypothetical pinning fs from umounting by mm,
which already unmapped all its executable files, but still alive.

Seems like currently nobody depends on this behaviour.
We can try to remove this logic and keep mm->exe_file until final mmput().

mm->exe_file is still protected with mm->mmap_sem, because we want to change it
via new sys_prctl(PR_SET_MM_EXE_FILE) in future. Also via this syscall task can
change its mm->exe_file and unpin mountpoint explicitly.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Matt Helsley <matthltc@us.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
---
 include/linux/mm.h       |    3 ---
 include/linux/mm_types.h |    1 -
 kernel/fork.c            |   21 ---------------------
 mm/mmap.c                |   27 +++++----------------------
 mm/nommu.c               |   14 ++------------
 5 files changed, 7 insertions(+), 59 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8e82b79..3a4d721 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1373,9 +1373,6 @@ extern void exit_mmap(struct mm_struct *);
 extern int mm_take_all_locks(struct mm_struct *mm);
 extern void mm_drop_all_locks(struct mm_struct *mm);
 
-/* From fs/proc/base.c. callers must _not_ hold the mm's exe_file_lock */
-extern void added_exe_file_vma(struct mm_struct *mm);
-extern void removed_exe_file_vma(struct mm_struct *mm);
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..b480c06 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -378,7 +378,6 @@ struct mm_struct {
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
 	struct file *exe_file;
-	unsigned long num_exe_file_vmas;
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 2e060c8..54662ed 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -587,26 +587,6 @@ void mmput(struct mm_struct *mm)
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
@@ -614,7 +594,6 @@ void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 	if (mm->exe_file)
 		fput(mm->exe_file);
 	mm->exe_file = new_exe_file;
-	mm->num_exe_file_vmas = 0;
 }
 
 struct file *get_mm_exe_file(struct mm_struct *mm)
diff --git a/mm/mmap.c b/mm/mmap.c
index bc67ed7..2647bb7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -230,11 +230,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file) {
+	if (vma->vm_file)
 		fput(vma->vm_file);
-		if (vma->vm_file == vma->vm_mm->exe_file)
-			removed_exe_file_vma(vma->vm_mm);
-	}
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
@@ -616,11 +613,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		mutex_unlock(&mapping->i_mmap_mutex);
 
 	if (remove_next) {
-		if (file) {
+		if (file)
 			fput(file);
-			if (file == mm->exe_file)
-				removed_exe_file_vma(mm);
-		}
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
 		mm->map_count--;
@@ -1293,8 +1287,6 @@ munmap_back:
 		error = file->f_op->mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
-		if (file == mm->exe_file)
-			added_exe_file_vma(mm);
 
 		/* Can addr have changed??
 		 *
@@ -1969,11 +1961,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	if (anon_vma_clone(new, vma))
 		goto out_free_mpol;
 
-	if (new->vm_file) {
+	if (new->vm_file)
 		get_file(new->vm_file);
-		if (new->vm_file == mm->exe_file)
-			added_exe_file_vma(mm);
-	}
 
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
@@ -1991,11 +1980,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	/* Clean everything up if vma_adjust failed. */
 	if (new->vm_ops && new->vm_ops->close)
 		new->vm_ops->close(new);
-	if (new->vm_file) {
-		if (new->vm_file == mm->exe_file)
-			removed_exe_file_vma(mm);
+	if (new->vm_file)
 		fput(new->vm_file);
-	}
 	unlink_anon_vmas(new);
  out_free_mpol:
 	mpol_put(pol);
@@ -2377,11 +2363,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
 			new_vma->vm_pgoff = pgoff;
-			if (new_vma->vm_file) {
+			if (new_vma->vm_file)
 				get_file(new_vma->vm_file);
-				if (new_vma->vm_file == mm->exe_file)
-					added_exe_file_vma(mm);
-			}
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
 			vma_link(mm, new_vma, prev, rb_link, rb_parent);
diff --git a/mm/nommu.c b/mm/nommu.c
index db8da78..d617d5c 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -789,11 +789,8 @@ static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 	kenter("%p", vma);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file) {
+	if (vma->vm_file)
 		fput(vma->vm_file);
-		if (vma->vm_file == mm->exe_file)
-			removed_exe_file_vma(mm);
-	}
 	put_nommu_region(vma->vm_region);
 	kmem_cache_free(vm_area_cachep, vma);
 }
@@ -1287,10 +1284,6 @@ unsigned long do_mmap_pgoff(struct file *file,
 		get_file(file);
 		vma->vm_file = file;
 		get_file(file);
-		if (file == current->mm->exe_file) {
-			added_exe_file_vma(current->mm);
-			vma->vm_mm = current->mm;
-		}
 	}
 
 	down_write(&nommu_region_sem);
@@ -1441,11 +1434,8 @@ error:
 	if (region->vm_file)
 		fput(region->vm_file);
 	kmem_cache_free(vm_region_jar, region);
-	if (vma->vm_file) {
+	if (vma->vm_file)
 		fput(vma->vm_file);
-		if (vma->vm_file == vma->vm_mm->exe_file)
-			removed_exe_file_vma(vma->vm_mm);
-	}
 	kmem_cache_free(vm_area_cachep, vma);
 	kleave(" = %d", ret);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
