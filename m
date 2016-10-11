Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7FAF6B0253
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:50:37 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fn2so27029878pad.7
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:37 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id w19si2741479pgc.263.2016.10.11.16.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 16:50:37 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id s8so9418491pfj.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:37 -0700 (PDT)
From: Ruchi Kandoi <kandoiruchi@google.com>
Subject: [RFC 1/6] fs: add installed and uninstalled file_operations
Date: Tue, 11 Oct 2016 16:50:05 -0700
Message-Id: <1476229810-26570-2-git-send-email-kandoiruchi@google.com>
In-Reply-To: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
References: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kandoiruchi@google.com, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

These optional file_operations notify a file implementation when it is
installed or uninstalled from a task's fd table.  This can be used for
accounting of file-backed shared resources like dma-buf.

This involves some changes to the __fd_install() and __close_fd() APIs
to actually pass along the responsible task_struct.  These are low-level
APIs with only two in-tree callers, both adjusted in this patch.

Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Ruchi Kandoi <kandoiruchi@google.com>
---
 drivers/android/binder.c |  4 ++--
 fs/file.c                | 38 +++++++++++++++++++++++++++++---------
 fs/open.c                |  2 +-
 include/linux/fdtable.h  |  4 ++--
 include/linux/fs.h       |  2 ++
 5 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index 562af94..0bb174e 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -398,7 +398,7 @@ static void task_fd_install(
 	struct binder_proc *proc, unsigned int fd, struct file *file)
 {
 	if (proc->files)
-		__fd_install(proc->files, fd, file);
+		__fd_install(proc->tsk, fd, file);
 }
 
 /*
@@ -411,7 +411,7 @@ static long task_close_fd(struct binder_proc *proc, unsigned int fd)
 	if (proc->files == NULL)
 		return -ESRCH;
 
-	retval = __close_fd(proc->files, fd);
+	retval = __close_fd(proc->tsk, fd);
 	/* can't restart close syscall because file table entry was cleared */
 	if (unlikely(retval == -ERESTARTSYS ||
 		     retval == -ERESTARTNOINTR ||
diff --git a/fs/file.c b/fs/file.c
index 69d6990..19c5fad 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -282,6 +282,24 @@ static unsigned int count_open_files(struct fdtable *fdt)
 	return i;
 }
 
+static inline void fdt_install(struct fdtable *fdt, int fd, struct file *file,
+		struct task_struct *task)
+{
+	if (file->f_op->installed)
+		file->f_op->installed(file, task);
+	rcu_assign_pointer(fdt->fd[fd], file);
+}
+
+static inline void fdt_uninstall(struct fdtable *fdt, int fd,
+		struct task_struct *task)
+{
+	struct file *old_file = fdt->fd[fd];
+
+	if (old_file->f_op->uninstalled)
+		old_file->f_op->uninstalled(old_file, task);
+	rcu_assign_pointer(fdt->fd[fd], NULL);
+}
+
 /*
  * Allocate a new files structure and copy contents from the
  * passed in files structure.
@@ -543,7 +561,7 @@ int __alloc_fd(struct files_struct *files,
 	/* Sanity check */
 	if (rcu_access_pointer(fdt->fd[fd]) != NULL) {
 		printk(KERN_WARNING "alloc_fd: slot %d not NULL!\n", fd);
-		rcu_assign_pointer(fdt->fd[fd], NULL);
+		fdt_uninstall(fdt, fd, current);
 	}
 #endif
 
@@ -601,10 +619,11 @@ EXPORT_SYMBOL(put_unused_fd);
  * fd_install() instead.
  */
 
-void __fd_install(struct files_struct *files, unsigned int fd,
+void __fd_install(struct task_struct *task, unsigned int fd,
 		struct file *file)
 {
 	struct fdtable *fdt;
+	struct files_struct *files = task->files;
 
 	might_sleep();
 	rcu_read_lock_sched();
@@ -618,13 +637,13 @@ void __fd_install(struct files_struct *files, unsigned int fd,
 	smp_rmb();
 	fdt = rcu_dereference_sched(files->fdt);
 	BUG_ON(fdt->fd[fd] != NULL);
-	rcu_assign_pointer(fdt->fd[fd], file);
+	fdt_install(fdt, fd, file, task);
 	rcu_read_unlock_sched();
 }
 
 void fd_install(unsigned int fd, struct file *file)
 {
-	__fd_install(current->files, fd, file);
+	__fd_install(current, fd, file);
 }
 
 EXPORT_SYMBOL(fd_install);
@@ -632,10 +651,11 @@ EXPORT_SYMBOL(fd_install);
 /*
  * The same warnings as for __alloc_fd()/__fd_install() apply here...
  */
-int __close_fd(struct files_struct *files, unsigned fd)
+int __close_fd(struct task_struct *task, unsigned fd)
 {
 	struct file *file;
 	struct fdtable *fdt;
+	struct files_struct *files = task->files;
 
 	spin_lock(&files->file_lock);
 	fdt = files_fdtable(files);
@@ -644,7 +664,7 @@ int __close_fd(struct files_struct *files, unsigned fd)
 	file = fdt->fd[fd];
 	if (!file)
 		goto out_unlock;
-	rcu_assign_pointer(fdt->fd[fd], NULL);
+	fdt_uninstall(fdt, fd, task);
 	__clear_close_on_exec(fd, fdt);
 	__put_unused_fd(files, fd);
 	spin_unlock(&files->file_lock);
@@ -679,7 +699,7 @@ void do_close_on_exec(struct files_struct *files)
 			file = fdt->fd[fd];
 			if (!file)
 				continue;
-			rcu_assign_pointer(fdt->fd[fd], NULL);
+			fdt_uninstall(fdt, fd, current);
 			__put_unused_fd(files, fd);
 			spin_unlock(&files->file_lock);
 			filp_close(file, files);
@@ -846,7 +866,7 @@ __releases(&files->file_lock)
 	if (!tofree && fd_is_open(fd, fdt))
 		goto Ebusy;
 	get_file(file);
-	rcu_assign_pointer(fdt->fd[fd], file);
+	fdt_install(fdt, fd, file, current);
 	__set_open_fd(fd, fdt);
 	if (flags & O_CLOEXEC)
 		__set_close_on_exec(fd, fdt);
@@ -870,7 +890,7 @@ int replace_fd(unsigned fd, struct file *file, unsigned flags)
 	struct files_struct *files = current->files;
 
 	if (!file)
-		return __close_fd(files, fd);
+		return __close_fd(current, fd);
 
 	if (fd >= rlimit(RLIMIT_NOFILE))
 		return -EBADF;
diff --git a/fs/open.c b/fs/open.c
index 8aeb08b..0f1db76 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -1120,7 +1120,7 @@ EXPORT_SYMBOL(filp_close);
  */
 SYSCALL_DEFINE1(close, unsigned int, fd)
 {
-	int retval = __close_fd(current->files, fd);
+	int retval = __close_fd(current, fd);
 
 	/* can't restart close syscall because file table entry was cleared */
 	if (unlikely(retval == -ERESTARTSYS ||
diff --git a/include/linux/fdtable.h b/include/linux/fdtable.h
index aca2a6a..a45fce3 100644
--- a/include/linux/fdtable.h
+++ b/include/linux/fdtable.h
@@ -113,9 +113,9 @@ int iterate_fd(struct files_struct *, unsigned,
 
 extern int __alloc_fd(struct files_struct *files,
 		      unsigned start, unsigned end, unsigned flags);
-extern void __fd_install(struct files_struct *files,
+extern void __fd_install(struct task_struct *task,
 		      unsigned int fd, struct file *file);
-extern int __close_fd(struct files_struct *files,
+extern int __close_fd(struct task_struct *task,
 		      unsigned int fd);
 
 extern struct kmem_cache *files_cachep;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c145219..d62bce8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1730,6 +1730,8 @@ struct file_operations {
 			u64);
 	ssize_t (*dedupe_file_range)(struct file *, u64, u64, struct file *,
 			u64);
+	void (*installed)(struct file *file, struct task_struct *task);
+	void (*uninstalled)(struct file *file, struct task_struct *task);
 };
 
 struct inode_operations {
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
