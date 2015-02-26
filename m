Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 442896B006E
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 14:37:13 -0500 (EST)
Received: by wghk14 with SMTP id k14so14163116wgh.4
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 11:37:12 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id u6si3468434wjq.13.2015.02.26.11.37.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 11:37:11 -0800 (PST)
Received: by wghl18 with SMTP id l18so14115135wgh.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 11:37:10 -0800 (PST)
From: Davidlohr Bueso <dave.bueso@gmail.com>
Message-ID: <1424979417.10344.14.camel@stgolabs.net>
Subject: [PATCH] mm: replace mmap_sem for mm->exe_file serialization
Date: Thu, 26 Feb 2015 11:36:57 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net

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
the mmap_sem (shared) in fork paths for the exe_file handling
(note that readers block when the rwsem is taken exclusively by
another thread).

Now that callers have been updated and standardized[1, 2] around
the get_mm_set_exe_file() interface, changing the locking scheme
is quite straightforward. The exception being the prctl calls
(ie PR_SET_MM_EXE_FILE). Because this caller actually _updates_
the mm->exe_file, we need to handle it in the same patch that changes
the locking rules. For this we need to reorganize prctl_set_mm_exe_file,
such that:

o mmap_sem is taken when actually needed.

o a new set_mm_exe_file_locked() function is introduced to be used by
  prctl. We now need to explicitly acquire the exe_file_lock as before
  it was implicit in holding the mmap_sem for write.

o a new __prctl_set_mm_exe_file() helper is created, which actually
  does the exe_file handling for the mm side -- needing the write
  lock for updating the mm->flags (*sigh*). In the future we could
  have a unique mm::exe_file_struct and keep track of MMF_EXE_FILE_CHANGED
  on our own.

mm: improve handling of mm->exe_file
[1] Part 1: https://lkml.org/lkml/2015/2/18/721
[2] Part 2: https://lkml.org/lkml/2015/2/25/679

Applies on top of linux-next (20150225).

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 fs/exec.c                |  6 ++++
 include/linux/mm.h       |  3 ++
 include/linux/mm_types.h |  1 +
 kernel/fork.c            | 25 ++++++++++---
 kernel/sys.c             | 92 ++++++++++++++++++++++++++++--------------------
 5 files changed, 84 insertions(+), 43 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index c7f9b73..a5fef83 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1078,7 +1078,13 @@ int flush_old_exec(struct linux_binprm * bprm)
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
index 47a9392..2a210b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1907,7 +1907,10 @@ static inline int check_data_rlimit(unsigned long rlim,
 extern int mm_take_all_locks(struct mm_struct *mm);
 extern void mm_drop_all_locks(struct mm_struct *mm);
 
+/* mm->exe_file handling */
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
+extern void set_mm_exe_file_locked(struct mm_struct *mm,
+				   struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
 
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03a..74e0b99 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -427,6 +427,7 @@ struct mm_struct {
 #endif
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
+	rwlock_t exe_file_lock;
 	struct file *exe_file;
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
diff --git a/kernel/fork.c b/kernel/fork.c
index cf65139..ca4499a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -565,6 +565,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
+	rwlock_init(&mm->exe_file_lock);
 	clear_tlb_flush_pending(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
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
 
@@ -687,19 +701,20 @@ struct file *get_mm_exe_file(struct mm_struct *mm)
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
 	return exe_file;
 }
 
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
index 667b2e6..2ab2d1c 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1646,14 +1646,59 @@ SYSCALL_DEFINE1(umask, int, mask)
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
@@ -1674,32 +1719,7 @@ static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
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
@@ -1837,10 +1857,10 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
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
 
@@ -1906,12 +1926,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
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
