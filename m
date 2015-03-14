Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF5A6B0096
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 18:39:49 -0400 (EDT)
Received: by obfv9 with SMTP id v9so12495462obf.2
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 15:39:49 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id t187si3065938oig.134.2015.03.14.15.39.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 15:39:48 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 1/4] mm: replace mmap_sem for mm->exe_file serialization
Date: Sat, 14 Mar 2015 15:39:23 -0700
Message-Id: <1426372766-3029-2-git-send-email-dave@stgolabs.net>
In-Reply-To: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, gorcunov@openvz.org, oleg@redhat.com, koct9i@gmail.com, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

We currently use the mmap_sem to serialize the mm exe_file.
This is atrocious and a clear example of the misuses this
lock has all over the place, making any significant changes
to the address space locking that much more complex and tedious.
This also has to do of how we used to check for the vma's vm_file
being VM_EXECUTABLE (much of which was replaced by 2dd8ad81e31).

This patch, therefore, removes the mmap_sem dependency and
introduces a specific lock for the exe_file (rwlock_t, as it is
read mostly and protects a trivial critical region). As mentioned,
the motivation is to cleanup mmap_sem (as opposed to exe_file
performance). A nice side effect of this is that we avoid taking
the mmap_sem (shared) in fork paths for the exe_file handling.

Now that callers have been updated and standardized[1, 2] around
the get_mm_set_exe_file() interface, changing the locking scheme
is quite straightforward. The exception being the prctl calls
(ie PR_SET_MM_EXE_FILE). Because this caller actually updates
the mm->exe_file, we need to handle it in the same patch that changes
the locking rules. For this we need to reorganize prctl_set_mm_exe_file,
such that:

o mmap_sem is taken when actually needed.

o a new set_mm_exe_file_locked() function is introduced to be used by
  prctl. We now need to explicitly acquire the exe_file_lock as before
  it was implicit in holding the mmap_sem for write.

o a new __prctl_set_mm_exe_file() helper is created, which actually
  does the exe_file handling for the mm side -- needing the write
  lock for updating the mm->flags.

mm: improve handling of mm->exe_file
[1] Part 1: https://lkml.org/lkml/2015/2/18/721
[2] Part 2: https://lkml.org/lkml/2015/2/25/679

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>
CC: Konstantin Khlebnikov <koct9i@gmail.com>
---
 fs/exec.c                |  6 ++++
 include/linux/mm.h       |  3 ++
 include/linux/mm_types.h |  1 +
 kernel/fork.c            | 26 +++++++++++---
 kernel/sys.c             | 92 ++++++++++++++++++++++++++++--------------------
 5 files changed, 85 insertions(+), 43 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 314e8d8..02bfd98 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1082,7 +1082,13 @@ int flush_old_exec(struct linux_binprm * bprm)
 	if (retval)
 		goto out;
 
+	/*
+	 * Must be called _before_ exec_mmap() as bprm->mm is
+	 * not visibile until then. This also enables the update
+	 * to be lockless.
+	 */
 	set_mm_exe_file(bprm->mm, bprm->file);
+
 	/*
 	 * Release all of the old mmap stuff
 	 */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6571dd78..0c0720d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1909,7 +1909,10 @@ static inline int check_data_rlimit(unsigned long rlim,
 extern int mm_take_all_locks(struct mm_struct *mm);
 extern void mm_drop_all_locks(struct mm_struct *mm);
 
+/* mm->exe_file handling */
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
+extern void set_mm_exe_file_locked(struct mm_struct *mm,
+				   struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
 
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 590630e..5951baf 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -429,6 +429,7 @@ struct mm_struct {
 #endif
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
+	rwlock_t exe_file_lock;
 	struct file *exe_file;
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
diff --git a/kernel/fork.c b/kernel/fork.c
index ab1a008..a573b18 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -566,6 +566,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
 	clear_tlb_flush_pending(mm);
+	rwlock_init(&mm->exe_file_lock);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
@@ -674,12 +675,25 @@ void mmput(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmput);
 
+void set_mm_exe_file_locked(struct mm_struct *mm, struct file *new_exe_file)
+{
+	if (new_exe_file)
+		get_file(new_exe_file);
+	if (mm->exe_file)
+		fput(mm->exe_file);
+
+	write_lock(&mm->exe_file_lock);
+	mm->exe_file = new_exe_file;
+	write_unlock(&mm->exe_file_lock);
+}
+
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	if (new_exe_file)
 		get_file(new_exe_file);
 	if (mm->exe_file)
 		fput(mm->exe_file);
+
 	mm->exe_file = new_exe_file;
 }
 
@@ -687,20 +701,22 @@ struct file *get_mm_exe_file(struct mm_struct *mm)
 {
 	struct file *exe_file;
 
-	/* We need mmap_sem to protect against races with removal of exe_file */
-	down_read(&mm->mmap_sem);
+	read_lock(&mm->exe_file_lock);
 	exe_file = mm->exe_file;
 	if (exe_file)
 		get_file(exe_file);
-	up_read(&mm->mmap_sem);
+	read_unlock(&mm->exe_file_lock);
+
 	return exe_file;
 }
 EXPORT_SYMBOL(get_mm_exe_file);
 
 static void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm)
 {
-	/* It's safe to write the exe_file pointer without exe_file_lock because
-	 * this is called during fork when the task is not yet in /proc */
+	/*
+	 * It's safe to write the exe_file without the
+	 * exe_file_lock as we are just setting up the new task.
+	 */
 	newmm->exe_file = get_mm_exe_file(oldmm);
 }
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 3be3449..a4d70f0 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1649,14 +1649,59 @@ SYSCALL_DEFINE1(umask, int, mask)
 	return mask;
 }
 
-static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
+static int __prctl_set_mm_exe_file(struct mm_struct *mm, struct fd exe)
+{
+	int err;
+	struct file *exe_file;
+
+	/*
+	 * Forbid mm->exe_file change if old file still mapped.
+	 */
+	exe_file = get_mm_exe_file(mm);
+	err = -EBUSY;
+	down_write(&mm->mmap_sem);
+	if (exe_file) {
+		struct vm_area_struct *vma;
+
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (!vma->vm_file)
+				continue;
+			if (path_equal(&vma->vm_file->f_path,
+				       &exe_file->f_path)) {
+				fput(exe_file);
+				goto exit_err;
+			}
+		}
+
+		fput(exe_file);
+	}
+
+	/*
+	 * The symlink can be changed only once, just to disallow arbitrary
+	 * transitions malicious software might bring in. This means one
+	 * could make a snapshot over all processes running and monitor
+	 * /proc/pid/exe changes to notice unusual activity if needed.
+	 */
+	err = -EPERM;
+	if (test_and_set_bit(MMF_EXE_FILE_CHANGED, &mm->flags))
+		goto exit_err;
+
+	up_write(&mm->mmap_sem);
+
+	/* this grabs a reference to exe.file */
+	set_mm_exe_file_locked(mm, exe.file);
+	return 0;
+exit_err:
+	up_write(&mm->mmap_sem);
+	return err;
+}
+
+static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 {
 	struct fd exe;
 	struct inode *inode;
 	int err;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
-
 	exe = fdget(fd);
 	if (!exe.file)
 		return -EBADF;
@@ -1677,32 +1722,7 @@ static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
 	if (err)
 		goto exit;
 
-	/*
-	 * Forbid mm->exe_file change if old file still mapped.
-	 */
-	err = -EBUSY;
-	if (mm->exe_file) {
-		struct vm_area_struct *vma;
-
-		for (vma = mm->mmap; vma; vma = vma->vm_next)
-			if (vma->vm_file &&
-			    path_equal(&vma->vm_file->f_path,
-				       &mm->exe_file->f_path))
-				goto exit;
-	}
-
-	/*
-	 * The symlink can be changed only once, just to disallow arbitrary
-	 * transitions malicious software might bring in. This means one
-	 * could make a snapshot over all processes running and monitor
-	 * /proc/pid/exe changes to notice unusual activity if needed.
-	 */
-	err = -EPERM;
-	if (test_and_set_bit(MMF_EXE_FILE_CHANGED, &mm->flags))
-		goto exit;
-
-	err = 0;
-	set_mm_exe_file(mm, exe.file);	/* this grabs a reference to exe.file */
+	err = __prctl_set_mm_exe_file(mm, exe);
 exit:
 	fdput(exe);
 	return err;
@@ -1840,10 +1860,10 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 		user_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
 	}
 
-	down_write(&mm->mmap_sem);
 	if (prctl_map.exe_fd != (u32)-1)
-		error = prctl_set_mm_exe_file_locked(mm, prctl_map.exe_fd);
-	downgrade_write(&mm->mmap_sem);
+		error = prctl_set_mm_exe_file(mm, prctl_map.exe_fd);
+
+	down_read(&mm->mmap_sem);
 	if (error)
 		goto out;
 
@@ -1909,12 +1929,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	if (!capable(CAP_SYS_RESOURCE))
 		return -EPERM;
 
-	if (opt == PR_SET_MM_EXE_FILE) {
-		down_write(&mm->mmap_sem);
-		error = prctl_set_mm_exe_file_locked(mm, (unsigned int)addr);
-		up_write(&mm->mmap_sem);
-		return error;
-	}
+	if (opt == PR_SET_MM_EXE_FILE)
+		return prctl_set_mm_exe_file(mm, (unsigned int)addr);
 
 	if (addr >= TASK_SIZE || addr < mmap_min_addr)
 		return -EINVAL;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
