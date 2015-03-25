Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3036B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 21:31:08 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so9999710wgd.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:31:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey12si2309900wid.87.2015.03.24.18.31.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 18:31:06 -0700 (PDT)
Message-ID: <1427247055.2412.23.camel@stgolabs.net>
Subject: [PATCH v2] prctl: avoid using mmap_sem for exe_file serialization
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 24 Mar 2015 18:30:55 -0700
In-Reply-To: <20150324190229.GC11834@redhat.com>
References: <20150320144715.24899.24547.stgit@buzz>
	 <1427134273.2412.12.camel@stgolabs.net> <20150323191055.GA10212@redhat.com>
	 <55119B3B.5020403@yandex-team.ru> <20150324181016.GA9678@redhat.com>
	 <CALYGNiP15BLtxMmMnpEu94jZBtce7tCtJnavrguqFr1d2XxH_A@mail.gmail.com>
	 <20150324190229.GC11834@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Oleg cleverly suggested using xchg() to set the new
mm->exe_file instead of calling set_mm_exe_file()
which requires some form of serialization -- mmap_sem
in this case. For archs that do not have atomic rmw
instructions we still fallback to a spinlock alternative,
so this should always be safe.  As such, we only need the
mmap_sem for looking up the backing vm_file, which can be
done sharing the lock. Naturally, this means we need to
manually deal with both the new and old file reference
counting, and we need not worry about the MMF_EXE_FILE_CHANGED
bits, which can probably be deleted in the future anyway.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
Changes from v1:
	- use rcu_dereference_raw()
	- comment lockless use in flush_old_exec()

 fs/exec.c     |  6 ++++++
 kernel/fork.c | 19 +++++++++++++------
 kernel/sys.c  | 43 ++++++++++++++++++++++++++-----------------
 3 files changed, 45 insertions(+), 23 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 314e8d8..02bfd98 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1082,7 +1082,13 @@ int flush_old_exec(struct linux_binprm * bprm)
 	if (retval)
 		goto out;
 
+	/*
+	 * Must be called _before_ exec_mmap() as bprm->mm is
+	 * not visible until then. This also enables the update
+	 * to be lockless.
+	 */
 	set_mm_exe_file(bprm->mm, bprm->file);
+
 	/*
 	 * Release all of the old mmap stuff
 	 */
diff --git a/kernel/fork.c b/kernel/fork.c
index 3847f34..347f69c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -688,15 +688,22 @@ EXPORT_SYMBOL_GPL(mmput);
  *
  * This changes mm's executale file (shown as symlink /proc/[pid]/exe).
  *
- * Main users are mmput(), sys_execve() and sys_prctl(PR_SET_MM_MAP/EXE_FILE).
- * Callers prevent concurrent invocations: in mmput() nobody alive left,
- * in execve task is single-threaded, prctl holds mmap_sem exclusively.
+ * Main users are mmput() and sys_execve(). Callers prevent concurrent
+ * invocations: in mmput() nobody alive left, in execve task is single
+ * threaded. sys_prctl(PR_SET_MM_MAP/EXE_FILE) also needs to set the
+ * mm->exe_file, but does so without using set_mm_exe_file() in order
+ * to do avoid the need for any locks.
  */
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
-	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
-			!atomic_read(&mm->mm_users) || current->in_execve ||
-			lockdep_is_held(&mm->mmap_sem));
+	struct file *old_exe_file;
+
+	/*
+	 * It is safe to dereference the exe_file without RCU as
+	 * this function is only called if nobody else can access
+	 * this mm -- see comment above for justification.
+	 */
+	old_exe_file = rcu_dereference_raw(mm->exe_file);
 
 	if (new_exe_file)
 		get_file(new_exe_file);
diff --git a/kernel/sys.c b/kernel/sys.c
index 3be3449..1da6b17 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1649,14 +1649,13 @@ SYSCALL_DEFINE1(umask, int, mask)
 	return mask;
 }
 
-static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
+static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 {
 	struct fd exe;
+	struct file *old_exe, *exe_file;
 	struct inode *inode;
 	int err;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
-
 	exe = fdget(fd);
 	if (!exe.file)
 		return -EBADF;
@@ -1680,15 +1679,22 @@ static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
 	/*
 	 * Forbid mm->exe_file change if old file still mapped.
 	 */
+	exe_file = get_mm_exe_file(mm);
 	err = -EBUSY;
 	if (mm->exe_file) {
 		struct vm_area_struct *vma;
 
-		for (vma = mm->mmap; vma; vma = vma->vm_next)
-			if (vma->vm_file &&
-			    path_equal(&vma->vm_file->f_path,
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (!vma->vm_file)
+				continue;
+			if (path_equal(&vma->vm_file->f_path,
 				       &mm->exe_file->f_path))
-				goto exit;
+				goto exit_err;
+		}
+
+		up_read(&mm->mmap_sem);
+		fput(exe_file);
 	}
 
 	/*
@@ -1702,10 +1708,18 @@ static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
 		goto exit;
 
 	err = 0;
-	set_mm_exe_file(mm, exe.file);	/* this grabs a reference to exe.file */
+	/* set the new file, lockless */
+	get_file(exe.file);
+	old_exe = xchg(&mm->exe_file, exe.file);
+	if (old_exe)
+		fput(old_exe);
 exit:
 	fdput(exe);
 	return err;
+exit_err:
+	up_read(&mm->mmap_sem);
+	fput(exe_file);
+	goto exit;
 }
 
 #ifdef CONFIG_CHECKPOINT_RESTORE
@@ -1840,10 +1854,9 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 		user_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
 	}
 
-	down_write(&mm->mmap_sem);
 	if (prctl_map.exe_fd != (u32)-1)
-		error = prctl_set_mm_exe_file_locked(mm, prctl_map.exe_fd);
-	downgrade_write(&mm->mmap_sem);
+		error = prctl_set_mm_exe_file(mm, prctl_map.exe_fd);
+	down_read(&mm->mmap_sem);
 	if (error)
 		goto out;
 
@@ -1909,12 +1922,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
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
