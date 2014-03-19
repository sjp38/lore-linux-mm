Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 72EDA6B0174
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 15:07:59 -0400 (EDT)
Received: by mail-bk0-f50.google.com with SMTP id w10so656437bkz.37
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:58 -0700 (PDT)
Received: from mail-bk0-x232.google.com (mail-bk0-x232.google.com [2a00:1450:4008:c01::232])
        by mx.google.com with ESMTPS id cm8si10029973bkc.75.2014.03.19.12.07.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 12:07:56 -0700 (PDT)
Received: by mail-bk0-f50.google.com with SMTP id w10so634845bkz.9
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:56 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH 3/6] shm: add memfd_create() syscall
Date: Wed, 19 Mar 2014 20:06:48 +0100
Message-Id: <1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, David Herrmann <dh.herrmann@gmail.com>

memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
that you can pass to mmap(). It explicitly allows sealing and
avoids any connection to user-visible mount-points. Thus, it's not
subject to quotas on mounted file-systems, but can be used like
malloc()'ed memory, but with a file-descriptor to it.

memfd_create() does not create a front-FD, but instead returns the raw
shmem file, so calls like ftruncate() can be used. Also calls like fstat()
will return proper information and mark the file as regular file. Sealing
is explicitly supported on memfds.

Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
subject to quotas and alike.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 arch/x86/syscalls/syscall_32.tbl |  1 +
 arch/x86/syscalls/syscall_64.tbl |  1 +
 include/linux/syscalls.h         |  1 +
 include/uapi/linux/memfd.h       |  9 ++++++
 kernel/sys_ni.c                  |  1 +
 mm/shmem.c                       | 67 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 80 insertions(+)
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
index a12bddc..e9d56a8 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -322,6 +322,7 @@
 313	common	finit_module		sys_finit_module
 314	common	sched_setattr		sys_sched_setattr
 315	common	sched_getattr		sys_sched_getattr
+316	common	memfd_create		sys_memfd_create
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a747a77..124b838 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -791,6 +791,7 @@ asmlinkage long sys_timerfd_settime(int ufd, int flags,
 asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
 asmlinkage long sys_eventfd2(unsigned int count, int flags);
+asmlinkage long sys_memfd_create(const char *uname_ptr, u64 size, u64 flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
 asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
diff --git a/include/uapi/linux/memfd.h b/include/uapi/linux/memfd.h
new file mode 100644
index 0000000..d74cc89
--- /dev/null
+++ b/include/uapi/linux/memfd.h
@@ -0,0 +1,9 @@
+#ifndef _UAPI_LINUX_MEMFD_H
+#define _UAPI_LINUX_MEMFD_H
+
+#include <linux/types.h>
+
+/* flags for memfd_create(2) */
+#define MFD_CLOEXEC		0x0001
+
+#endif /* _UAPI_LINUX_MEMFD_H */
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 7078052..53e05af 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -193,6 +193,7 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+cond_syscall(sys_memfd_create);
 
 /* performance counters: */
 cond_syscall(sys_perf_event_open);
diff --git a/mm/shmem.c b/mm/shmem.c
index 44d7f3b..48feb42 100644
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
@@ -3039,6 +3041,71 @@ out4:
 	return error;
 }
 
+/* maximum length of memfd names */
+#define MFD_MAX_NAMELEN 256
+
+SYSCALL_DEFINE3(memfd_create,
+		const char*, uname,
+		u64, size,
+		u64, flags)
+{
+	struct file *shm;
+	char *name;
+	int fd, r;
+	long len;
+
+	if (flags & ~(u64)MFD_CLOEXEC)
+		return -EINVAL;
+	if ((u64)(loff_t)size != size || (loff_t)size < 0)
+		return -EINVAL;
+
+	/* length includes terminating zero */
+	len = strnlen_user(uname, MFD_MAX_NAMELEN);
+	if (len <= 0)
+		return -EFAULT;
+	else if (len > MFD_MAX_NAMELEN)
+		return -EINVAL;
+
+	name = kmalloc(len + 6, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	strcpy(name, "memfd:");
+	if (copy_from_user(&name[6], uname, len)) {
+		r = -EFAULT;
+		goto err_name;
+	}
+
+	/* terminating-zero may have changed after strnlen_user() returned */
+	if (name[len + 6 - 1]) {
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
+	shm->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
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
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
