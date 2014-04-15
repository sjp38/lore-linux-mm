Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 43B436B0039
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:38:58 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so9891942pbb.39
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:38:57 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id cq4si5525059pbc.356.2014.04.15.11.38.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 11:38:57 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so9989340pad.29
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:38:57 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v2 2/3] shm: add memfd_create() syscall
Date: Tue, 15 Apr 2014 20:38:37 +0200
Message-Id: <1397587118-1214-3-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, David Herrmann <dh.herrmann@gmail.com>

memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
that you can pass to mmap(). It can support sealing and avoids any
connection to user-visible mount-points. Thus, it's not subject to quotas
on mounted file-systems, but can be used like malloc()'ed memory, but
with a file-descriptor to it.

memfd_create() does not create a front-FD, but instead returns the raw
shmem file, so calls like ftruncate() can be used. Also calls like fstat()
will return proper information and mark the file as regular file. If you
want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
support (like on all other regular files).

Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
subject to quotas and alike.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 arch/x86/syscalls/syscall_32.tbl |  1 +
 arch/x86/syscalls/syscall_64.tbl |  1 +
 include/linux/syscalls.h         |  1 +
 include/uapi/linux/memfd.h       | 10 ++++++
 kernel/sys_ni.c                  |  1 +
 mm/shmem.c                       | 74 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 88 insertions(+)
 create mode 100644 include/uapi/linux/memfd.h

diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index 96bc506..c943b8a 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -359,3 +359,4 @@
 350	i386	finit_module		sys_finit_module
 351	i386	sched_setattr		sys_sched_setattr
 352	i386	sched_getattr		sys_sched_getattr
+353	i386	memfd_create		sys_memfd_create
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 04376ac..dfcfd6f 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -323,6 +323,7 @@
 314	common	sched_setattr		sys_sched_setattr
 315	common	sched_getattr		sys_sched_getattr
 316	common	renameat2		sys_renameat2
+317	common	memfd_create		sys_memfd_create
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a4a0588..133b705 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -802,6 +802,7 @@ asmlinkage long sys_timerfd_settime(int ufd, int flags,
 asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
 asmlinkage long sys_eventfd2(unsigned int count, int flags);
+asmlinkage long sys_memfd_create(const char *uname_ptr, u64 size, u64 flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
 asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
diff --git a/include/uapi/linux/memfd.h b/include/uapi/linux/memfd.h
new file mode 100644
index 0000000..c4a6db0
--- /dev/null
+++ b/include/uapi/linux/memfd.h
@@ -0,0 +1,10 @@
+#ifndef _UAPI_LINUX_MEMFD_H
+#define _UAPI_LINUX_MEMFD_H
+
+#include <linux/types.h>
+
+/* flags for memfd_create(2) (u64) */
+#define MFD_CLOEXEC		0x0001ULL
+#define MFD_ALLOW_SEALING	0x0002ULL
+
+#endif /* _UAPI_LINUX_MEMFD_H */
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index bc8d1b7..f96c329 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -195,6 +195,7 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+cond_syscall(sys_memfd_create);
 
 /* performance counters: */
 cond_syscall(sys_perf_event_open);
diff --git a/mm/shmem.c b/mm/shmem.c
index 175a5b8..203cc4e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -66,7 +66,9 @@ static struct vfsmount *shm_mnt;
 #include <linux/highmem.h>
 #include <linux/seq_file.h>
 #include <linux/magic.h>
+#include <linux/syscalls.h>
 #include <linux/fcntl.h>
+#include <uapi/linux/memfd.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -2919,6 +2921,78 @@ out4:
 	return error;
 }
 
+#define MFD_NAME_PREFIX "memfd:"
+#define MFD_NAME_PREFIX_LEN (sizeof(MFD_NAME_PREFIX) - 1)
+#define MFD_NAME_MAX_LEN (NAME_MAX - MFD_NAME_PREFIX_LEN)
+
+#define MFD_ALL_FLAGS (MFD_CLOEXEC | MFD_ALLOW_SEALING)
+
+SYSCALL_DEFINE3(memfd_create,
+		const char*, uname,
+		u64, size,
+		u64, flags)
+{
+	struct shmem_inode_info *info;
+	struct file *shm;
+	char *name;
+	int fd, r;
+	long len;
+
+	if (flags & ~(u64)MFD_ALL_FLAGS)
+		return -EINVAL;
+	if ((u64)(loff_t)size != size || (loff_t)size < 0)
+		return -EINVAL;
+
+	/* length includes terminating zero */
+	len = strnlen_user(uname, MFD_NAME_MAX_LEN);
+	if (len <= 0)
+		return -EFAULT;
+	else if (len > MFD_NAME_MAX_LEN)
+		return -EINVAL;
+
+	name = kmalloc(len + MFD_NAME_PREFIX_LEN, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	strcpy(name, MFD_NAME_PREFIX);
+	if (copy_from_user(&name[MFD_NAME_PREFIX_LEN], uname, len)) {
+		r = -EFAULT;
+		goto err_name;
+	}
+
+	/* terminating-zero may have changed after strnlen_user() returned */
+	if (name[len + MFD_NAME_PREFIX_LEN - 1]) {
+		r = -EFAULT;
+		goto err_name;
+	}
+
+	fd = get_unused_fd_flags((flags & MFD_CLOEXEC) ? O_CLOEXEC : 0);
+	if (fd < 0) {
+		r = fd;
+		goto err_name;
+	}
+
+	shm = shmem_file_setup(name, size, 0);
+	if (IS_ERR(shm)) {
+		r = PTR_ERR(shm);
+		goto err_fd;
+	}
+	info = SHMEM_I(file_inode(shm));
+	shm->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
+	if (flags & MFD_ALLOW_SEALING)
+		info->seals |= SHMEM_ALLOW_SEALING;
+
+	fd_install(fd, shm);
+	kfree(name);
+	return fd;
+
+err_fd:
+	put_unused_fd(fd);
+err_name:
+	kfree(name);
+	return r;
+}
+
 #else /* !CONFIG_SHMEM */
 
 /*
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
