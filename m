Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 317916B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 19:50:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b6so963005pff.18
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 16:50:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y1sor840260pgq.242.2017.10.25.16.50.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Oct 2017 16:50:29 -0700 (PDT)
From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH 1/3] [v2] vm: add a syscall to map a process memory into a pipe
Date: Wed, 25 Oct 2017 16:50:01 -0700
Message-Id: <20171025235003.24262-1-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Andrei Vagin <avagin@openvz.org>, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>

It is a hybrid of process_vm_readv() and vmsplice().

vmsplice can map memory from a current address space into a pipe.
process_vm_readv can read memory of another process.

A new system call can map memory of another process into a pipe.

ssize_t process_vmsplice(pid_t pid, int fd, const struct iovec *iov,
                        unsigned long nr_segs, unsigned int flags)

All arguments are identical with vmsplice except pid which specifies a
target process.

Currently if we want to dump a process memory to a file or to a socket,
we can use process_vm_readv() + write(), but it works slow, because data
are copied into a temporary user-space buffer.

A second way is to use vmsplice() + splice(). It is more effective,
because data are not copied into a temporary buffer, but here is another
problem. vmsplice works with the currect address space, so it can be
used only if we inject our code into a target process.

The second way suffers from a few other issues:
* a process has to be stopped to run a parasite code
* a number of pipes is limited, so it may be impossible to dump all
  memory in one iteration, and we have to stop process and inject our
  code a few times.
* pages in pipes are unreclaimable, so it isn't good to hold a lot of
  memory in pipes.

The introduced syscall allows to use a second way without injecting any
code into a target process.

My experiments shows that process_vmsplice() + splice() works two time
faster than process_vm_readv() + write().

It is particularly useful on a pre-dump stage. On this stage we enable a
memory tracker, and then we are dumping  a process memory while a
process continues work. On the first iteration we are dumping all
memory, and then we are dumpung only modified memory from a previous
iteration.  After a few pre-dump operations, a process is stopped and
dumped finally. The pre-dump operations allow to significantly decrease
a process downtime, when a process is migrated to another host.

v2: move this syscall under CONFIG_CROSS_MEMORY_ATTACH
    give correct flags to get_user_pages_remote()

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Josh Triplett <josh@joshtriplett.org>
Cc: Jann Horn <jannh@google.com>
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 fs/splice.c                       | 223 ++++++++++++++++++++++++++++++++++++++
 include/linux/compat.h            |   3 +
 include/linux/syscalls.h          |   4 +
 include/uapi/asm-generic/unistd.h |   5 +-
 kernel/sys_ni.c                   |   2 +
 5 files changed, 236 insertions(+), 1 deletion(-)

diff --git a/fs/splice.c b/fs/splice.c
index f3084cce0ea6..4bf37207feb9 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -34,6 +34,7 @@
 #include <linux/socket.h>
 #include <linux/compat.h>
 #include <linux/sched/signal.h>
+#include <linux/sched/mm.h>
 
 #include "internal.h"
 
@@ -1358,6 +1359,228 @@ SYSCALL_DEFINE4(vmsplice, int, fd, const struct iovec __user *, iov,
 	return error;
 }
 
+#ifdef CONFIG_CROSS_MEMORY_ATTACH
+/*
+ * Map pages from a specified task into a pipe
+ */
+static int remote_single_vec_to_pipe(struct task_struct *task,
+			struct mm_struct *mm,
+			const struct iovec *rvec,
+			struct pipe_inode_info *pipe,
+			unsigned int flags,
+			size_t *total)
+{
+	struct pipe_buffer buf = {
+		.ops = &user_page_pipe_buf_ops,
+		.flags = flags
+	};
+	unsigned long addr = (unsigned long) rvec->iov_base;
+	unsigned long pa = addr & PAGE_MASK;
+	unsigned long start_offset = addr - pa;
+	unsigned long nr_pages;
+	ssize_t len = rvec->iov_len;
+	struct page *process_pages[16];
+	bool failed = false;
+	int ret = 0;
+
+	nr_pages = (addr + len - 1) / PAGE_SIZE - addr / PAGE_SIZE + 1;
+	while (nr_pages) {
+		long pages = min(nr_pages, 16UL);
+		int locked = 1, n;
+		ssize_t copied;
+
+		/*
+		 * Get the pages we're interested in.  We must
+		 * access remotely because task/mm might not
+		 * current/current->mm
+		 */
+		down_read(&mm->mmap_sem);
+		pages = get_user_pages_remote(task, mm, pa, pages, 0,
+					      process_pages, NULL, &locked);
+		if (locked)
+			up_read(&mm->mmap_sem);
+		if (pages <= 0) {
+			failed = true;
+			ret = -EFAULT;
+			break;
+		}
+
+		copied = pages * PAGE_SIZE - start_offset;
+		if (copied > len)
+			copied = len;
+		len -= copied;
+
+		for (n = 0; copied; n++, start_offset = 0) {
+			int size = min_t(int, copied, PAGE_SIZE - start_offset);
+
+			if (!failed) {
+				buf.page = process_pages[n];
+				buf.offset = start_offset;
+				buf.len = size;
+				ret = add_to_pipe(pipe, &buf);
+				if (unlikely(ret < 0))
+					failed = true;
+				else
+					*total += ret;
+			} else {
+				put_page(process_pages[n]);
+			}
+			copied -= size;
+		}
+		if (failed)
+			break;
+		start_offset = 0;
+		nr_pages -= pages;
+		pa += pages * PAGE_SIZE;
+	}
+	return ret < 0 ? ret : 0;
+}
+
+static ssize_t remote_iovec_to_pipe(struct task_struct *task,
+			struct mm_struct *mm,
+			const struct iovec *rvec,
+			unsigned long riovcnt,
+			struct pipe_inode_info *pipe,
+			unsigned int flags)
+{
+	size_t total = 0;
+	int ret = 0, i;
+
+	for (i = 0; i < riovcnt; i++) {
+		/* Work out address and page range required */
+		if (rvec[i].iov_len == 0)
+			continue;
+
+		ret = remote_single_vec_to_pipe(
+				task, mm, &rvec[i], pipe, flags, &total);
+		if (ret < 0)
+			break;
+	}
+	return total ? total : ret;
+}
+
+static long process_vmsplice_to_pipe(struct task_struct *task,
+				struct mm_struct *mm, struct file *file,
+				const struct iovec __user *uiov,
+				unsigned long nr_segs, unsigned int flags)
+{
+	struct pipe_inode_info *pipe;
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov = iovstack;
+	unsigned int buf_flag = 0;
+	long ret;
+
+	if (flags & SPLICE_F_GIFT)
+		buf_flag = PIPE_BUF_FLAG_GIFT;
+
+	pipe = get_pipe_info(file);
+	if (!pipe)
+		return -EBADF;
+
+	ret = rw_copy_check_uvector(CHECK_IOVEC_ONLY, uiov, nr_segs,
+					UIO_FASTIOV, iovstack, &iov);
+	if (ret < 0)
+		return ret;
+
+	pipe_lock(pipe);
+	ret = wait_for_space(pipe, flags);
+	if (!ret)
+		ret = remote_iovec_to_pipe(task, mm, iov,
+						nr_segs, pipe, buf_flag);
+	pipe_unlock(pipe);
+	if (ret > 0)
+		wakeup_pipe_readers(pipe);
+
+	if (iov != iovstack)
+		kfree(iov);
+	return ret;
+}
+
+/* process_vmsplice splices a process address range into a pipe. */
+SYSCALL_DEFINE5(process_vmsplice, int, pid, int, fd,
+		const struct iovec __user *, iov,
+		unsigned long, nr_segs, unsigned int, flags)
+{
+	struct task_struct *task;
+	struct mm_struct *mm;
+	struct fd f;
+	long ret;
+
+	if (unlikely(flags & ~SPLICE_F_ALL))
+		return -EINVAL;
+	if (unlikely(nr_segs > UIO_MAXIOV))
+		return -EINVAL;
+	else if (unlikely(!nr_segs))
+		return 0;
+
+	f = fdget(fd);
+	if (!f.file)
+		return -EBADF;
+
+	/* Get process information */
+	rcu_read_lock();
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	rcu_read_unlock();
+	if (!task) {
+		ret = -ESRCH;
+		goto out_fput;
+	}
+
+	mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS);
+	if (!mm || IS_ERR(mm)) {
+		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
+		/*
+		 * Explicitly map EACCES to EPERM as EPERM is a more a
+		 * appropriate error code for process_vw_readv/writev
+		 */
+		if (ret == -EACCES)
+			ret = -EPERM;
+		goto put_task_struct;
+	}
+
+	ret = -EBADF;
+	if (f.file->f_mode & FMODE_WRITE)
+		ret = process_vmsplice_to_pipe(task, mm, f.file,
+						iov, nr_segs, flags);
+	mmput(mm);
+
+put_task_struct:
+	put_task_struct(task);
+
+out_fput:
+	fdput(f);
+
+	return ret;
+}
+
+#ifdef CONFIG_COMPAT
+COMPAT_SYSCALL_DEFINE5(process_vmsplice, pid_t, pid, int, fd,
+			const struct compat_iovec __user *, iov32,
+			unsigned int, nr_segs, unsigned int, flags)
+{
+	struct iovec __user *iov;
+	unsigned int i;
+
+	if (nr_segs > UIO_MAXIOV)
+		return -EINVAL;
+
+	iov = compat_alloc_user_space(nr_segs * sizeof(struct iovec));
+	for (i = 0; i < nr_segs; i++) {
+		struct compat_iovec v;
+
+		if (get_user(v.iov_base, &iov32[i].iov_base) ||
+		    get_user(v.iov_len, &iov32[i].iov_len) ||
+		    put_user(compat_ptr(v.iov_base), &iov[i].iov_base) ||
+		    put_user(v.iov_len, &iov[i].iov_len))
+			return -EFAULT;
+	}
+	return sys_process_vmsplice(pid, fd, iov, nr_segs, flags);
+}
+#endif
+#endif /* CONFIG_CROSS_MEMORY_ATTACH */
+
 #ifdef CONFIG_COMPAT
 COMPAT_SYSCALL_DEFINE4(vmsplice, int, fd, const struct compat_iovec __user *, iov32,
 		    unsigned int, nr_segs, unsigned int, flags)
diff --git a/include/linux/compat.h b/include/linux/compat.h
index a5619de3437d..32ce71b9193e 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -553,6 +553,9 @@ asmlinkage long compat_sys_getdents(unsigned int fd,
 				    unsigned int count);
 asmlinkage long compat_sys_vmsplice(int fd, const struct compat_iovec __user *,
 				    unsigned int nr_segs, unsigned int flags);
+asmlinkage long compat_sys_process_vmsplice(pid_t pid, int fd,
+				    const struct compat_iovec __user *,
+				    unsigned int nr_segs, unsigned int flags);
 asmlinkage long compat_sys_open(const char __user *filename, int flags,
 				umode_t mode);
 asmlinkage long compat_sys_openat(int dfd, const char __user *filename,
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a78186d826d7..4ba93336bf05 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -941,4 +941,8 @@ asmlinkage long sys_pkey_free(int pkey);
 asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
 
+asmlinkage long sys_process_vmsplice(pid_t pid,
+			int fd, const struct iovec __user *iov,
+			unsigned long nr_segs, unsigned int flags);
+
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 061185a5eb51..d18019df995d 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -731,9 +731,12 @@ __SYSCALL(__NR_pkey_alloc,    sys_pkey_alloc)
 __SYSCALL(__NR_pkey_free,     sys_pkey_free)
 #define __NR_statx 291
 __SYSCALL(__NR_statx,     sys_statx)
+#define __NR_process_vmsplice 292
+__SC_COMP(__NR_process_vmsplice, sys_process_vmsplice,
+	  compat_sys_process_vmsplice)
 
 #undef __NR_syscalls
-#define __NR_syscalls 292
+#define __NR_syscalls 293
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 8acef8576ce9..eca82cba796b 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -157,8 +157,10 @@ cond_syscall(sys_sysfs);
 cond_syscall(sys_syslog);
 cond_syscall(sys_process_vm_readv);
 cond_syscall(sys_process_vm_writev);
+cond_syscall(sys_process_vmsplice);
 cond_syscall(compat_sys_process_vm_readv);
 cond_syscall(compat_sys_process_vm_writev);
+cond_syscall(compat_sys_process_vmsplice);
 cond_syscall(sys_uselib);
 cond_syscall(sys_fadvise64);
 cond_syscall(sys_fadvise64_64);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
