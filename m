Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B850E6B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 10:49:23 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p6REikwt031529
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 00:44:46 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6REmbWY1073344
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 00:48:37 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6REnGPH006841
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 00:49:16 +1000
Date: Thu, 28 Jul 2011 00:19:04 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [PATCH] Cross Memory Attach v4 (patch updated)
Message-ID: <20110728001904.7aa78e88@lilo>
In-Reply-To: <20110726215554.f87b403e.rdunlap@xenotime.net>
References: <20110727125342.5637308d@lilo>
 <20110726215554.f87b403e.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, linux-arch@vger.kernel.org

On Tue, 26 Jul 2011 21:55:54 -0700
Randy Dunlap <rdunlap@xenotime.net> wrote:

> On Wed, 27 Jul 2011 12:53:42 +0930 Christopher Yeoh wrote:
> 
> > Hi Andrew,
> > 
> > Here's an updated version of the Cross Memory Attach patch. Changes
> > since the v3:
> > 
> > - Adds x86_64 specific wire up
> > - Changes behaviour so process_vm_readv and process_vm_writev return
> >   the number of bytes successfully read or written even if an error
> >   occurs
> > - Adds more kernel doc interface comments 
> > - rename of some internal functions (process_vm_rw_check_iovecs, 
> >   process_vm_rw) so they make more sense. 
> > 
> > Still need to do benchmarking to see if the optimisation for small
> > copies using a local on-stack array in process_vm_rw_core is worth
> > it. 
> 
> It's nice to include a diffstat so that people can get a quick patch
> summary and see what files are touched.
> 

Thanks. Updated patch below. Only changes are:
- Adds licence message
- Fixed kernel-doc comment format

Signed-off-by: Chris Yeoh <cyeoh@au1.ibm.com>
---
 arch/powerpc/include/asm/systbl.h  |    2 
 arch/powerpc/include/asm/unistd.h  |    4 
 arch/x86/ia32/ia32entry.S          |    2 
 arch/x86/include/asm/unistd_32.h   |    4 
 arch/x86/include/asm/unistd_64.h   |    4 
 arch/x86/kernel/syscall_table_32.S |    2 
 fs/aio.c                           |    4 
 fs/compat.c                        |    7 
 fs/read_write.c                    |    8 
 include/linux/compat.h             |    3 
 include/linux/fs.h                 |    7 
 include/linux/syscalls.h           |   13 
 kernel/sys_ni.c                    |    4 
 mm/Makefile                        |    3 
 mm/process_vm_access.c             |  487 +++++++++++++++++++++++++++++++++++++
 security/keys/compat.c             |    2 
 security/keys/keyctl.c             |    2 
 17 files changed, 541 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index f6736b7..525db4b 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -354,3 +354,5 @@ COMPAT_SYS_SPU(clock_adjtime)
 SYSCALL_SPU(syncfs)
 COMPAT_SYS_SPU(sendmmsg)
 SYSCALL_SPU(setns)
+COMPAT_SYS(process_vm_readv)
+COMPAT_SYS(process_vm_writev)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index b8b3f59..d3d1b5e 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -373,10 +373,12 @@
 #define __NR_syncfs		348
 #define __NR_sendmmsg		349
 #define __NR_setns		350
+#define __NR_process_vm_readv	351
+#define __NR_process_vm_writev	352
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		351
+#define __NR_syscalls		353
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index c1870dd..cde849f 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -850,4 +850,6 @@ ia32_sys_call_table:
 	.quad sys_syncfs
 	.quad compat_sys_sendmmsg	/* 345 */
 	.quad sys_setns
+	.quad compat_sys_process_vm_readv
+	.quad compat_sys_process_vm_writev
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 593485b..599c77d 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -352,10 +352,12 @@
 #define __NR_syncfs             344
 #define __NR_sendmmsg		345
 #define __NR_setns		346
+#define __NR_process_vm_readv	347
+#define __NR_process_vm_writev	348
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 347
+#define NR_syscalls 349
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 705bf13..1f1d1ef 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -681,6 +681,10 @@ __SYSCALL(__NR_syncfs, sys_syncfs)
 __SYSCALL(__NR_sendmmsg, sys_sendmmsg)
 #define __NR_setns				308
 __SYSCALL(__NR_setns, sys_setns)
+#define __NR_process_vm_readv			309
+__SYSCALL(__NR_process_vm_readv, sys_process_vm_readv)
+#define __NR_process_vm_writev			310
+__SYSCALL(__NR_process_vm_writev, sys_process_vm_writev)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index fbb0a04..ca0fe4d 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -346,3 +346,5 @@ ENTRY(sys_call_table)
 	.long sys_syncfs
 	.long sys_sendmmsg		/* 345 */
 	.long sys_setns
+	.long sys_process_vm_readv
+	.long sys_process_vm_writev
diff --git a/fs/aio.c b/fs/aio.c
index e29ec48..632b235 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1387,13 +1387,13 @@ static ssize_t aio_setup_vectored_rw(int type, struct kiocb *kiocb, bool compat)
 		ret = compat_rw_copy_check_uvector(type,
 				(struct compat_iovec __user *)kiocb->ki_buf,
 				kiocb->ki_nbytes, 1, &kiocb->ki_inline_vec,
-				&kiocb->ki_iovec);
+				&kiocb->ki_iovec, 1);
 	else
 #endif
 		ret = rw_copy_check_uvector(type,
 				(struct iovec __user *)kiocb->ki_buf,
 				kiocb->ki_nbytes, 1, &kiocb->ki_inline_vec,
-				&kiocb->ki_iovec);
+				&kiocb->ki_iovec, 1);
 	if (ret < 0)
 		goto out;
 
diff --git a/fs/compat.c b/fs/compat.c
index 0ea0083..ec53ccc 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -550,7 +550,7 @@ out:
 ssize_t compat_rw_copy_check_uvector(int type,
 		const struct compat_iovec __user *uvector, unsigned long nr_segs,
 		unsigned long fast_segs, struct iovec *fast_pointer,
-		struct iovec **ret_pointer)
+		struct iovec **ret_pointer, int check_access)
 {
 	compat_ssize_t tot_len;
 	struct iovec *iov = *ret_pointer = fast_pointer;
@@ -597,7 +597,8 @@ ssize_t compat_rw_copy_check_uvector(int type,
 		}
 		if (len < 0)	/* size_t not fitting in compat_ssize_t .. */
 			goto out;
-		if (!access_ok(vrfy_dir(type), compat_ptr(buf), len)) {
+		if (check_access &&
+		    !access_ok(vrfy_dir(type), compat_ptr(buf), len)) {
 			ret = -EFAULT;
 			goto out;
 		}
@@ -1111,7 +1112,7 @@ static ssize_t compat_do_readv_writev(int type, struct file *file,
 		goto out;
 
 	tot_len = compat_rw_copy_check_uvector(type, uvector, nr_segs,
-					       UIO_FASTIOV, iovstack, &iov);
+					       UIO_FASTIOV, iovstack, &iov, 1);
 	if (tot_len == 0) {
 		ret = 0;
 		goto out;
diff --git a/fs/read_write.c b/fs/read_write.c
index 5520f8a..b905826 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -575,7 +575,8 @@ ssize_t do_loop_readv_writev(struct file *filp, struct iovec *iov,
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 			      unsigned long nr_segs, unsigned long fast_segs,
 			      struct iovec *fast_pointer,
-			      struct iovec **ret_pointer)
+			      struct iovec **ret_pointer,
+			      int check_access)
 {
 	unsigned long seg;
 	ssize_t ret;
@@ -631,7 +632,8 @@ ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 			ret = -EINVAL;
 			goto out;
 		}
-		if (unlikely(!access_ok(vrfy_dir(type), buf, len))) {
+		if (check_access
+		    && unlikely(!access_ok(vrfy_dir(type), buf, len))) {
 			ret = -EFAULT;
 			goto out;
 		}
@@ -663,7 +665,7 @@ static ssize_t do_readv_writev(int type, struct file *file,
 	}
 
 	ret = rw_copy_check_uvector(type, uvector, nr_segs,
-			ARRAY_SIZE(iovstack), iovstack, &iov);
+				    ARRAY_SIZE(iovstack), iovstack, &iov, 1);
 	if (ret <= 0)
 		goto out;
 
diff --git a/include/linux/compat.h b/include/linux/compat.h
index 846bb17..1cc917a 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -557,7 +557,8 @@ extern ssize_t compat_rw_copy_check_uvector(int type,
 		const struct compat_iovec __user *uvector,
 		unsigned long nr_segs,
 		unsigned long fast_segs, struct iovec *fast_pointer,
-		struct iovec **ret_pointer);
+		struct iovec **ret_pointer,
+		int check_access);
 
 extern void __user *compat_alloc_user_space(unsigned long len);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b5b9792..d97ffab 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1608,9 +1608,10 @@ struct inode_operations {
 struct seq_file;
 
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
-				unsigned long nr_segs, unsigned long fast_segs,
-				struct iovec *fast_pointer,
-				struct iovec **ret_pointer);
+			      unsigned long nr_segs, unsigned long fast_segs,
+			      struct iovec *fast_pointer,
+			      struct iovec **ret_pointer,
+			      int check_access);
 
 extern ssize_t vfs_read(struct file *, char __user *, size_t, loff_t *);
 extern ssize_t vfs_write(struct file *, const char __user *, size_t, loff_t *);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 8c03b98..0dc0809 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -847,4 +847,17 @@ asmlinkage long sys_open_by_handle_at(int mountdirfd,
 				      struct file_handle __user *handle,
 				      int flags);
 asmlinkage long sys_setns(int fd, int nstype);
+asmlinkage long sys_process_vm_readv(pid_t pid,
+				     const struct iovec __user *lvec,
+				     unsigned long liovcnt,
+				     const struct iovec __user *rvec,
+				     unsigned long riovcnt,
+				     unsigned long flags);
+asmlinkage long sys_process_vm_writev(pid_t pid,
+				      const struct iovec __user *lvec,
+				      unsigned long liovcnt,
+				      const struct iovec __user *rvec,
+				      unsigned long riovcnt,
+				      unsigned long flags);
+
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 62cbc88..7a34e9f 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -146,6 +146,10 @@ cond_syscall(sys_io_submit);
 cond_syscall(sys_io_cancel);
 cond_syscall(sys_io_getevents);
 cond_syscall(sys_syslog);
+cond_syscall(sys_process_vm_readv);
+cond_syscall(sys_process_vm_writev);
+cond_syscall(compat_sys_process_vm_readv);
+cond_syscall(compat_sys_process_vm_writev);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
diff --git a/mm/Makefile b/mm/Makefile
index 836e416..50ec00e 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -5,7 +5,8 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   vmalloc.o pagewalk.o pgtable-generic.o \
+			   process_vm_access.o
 
 obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o \
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
new file mode 100644
index 0000000..5ac8abc
--- /dev/null
+++ b/mm/process_vm_access.c
@@ -0,0 +1,487 @@
+/*
+ * linux/mm/process_vm_access.c
+ *
+ * Copyright (C) 2010-2011 Christopher Yeoh <cyeoh@au1.ibm.com>, IBM Corp.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/mm.h>
+#include <linux/uio.h>
+#include <linux/sched.h>
+#include <linux/highmem.h>
+#include <linux/ptrace.h>
+#include <linux/slab.h>
+#include <linux/syscalls.h>
+
+#ifdef CONFIG_COMPAT
+#include <linux/compat.h>
+#endif
+
+/**
+ * process_vm_rw_pages - read/write pages from task specified
+ * @task: task to read/write from
+ * @mm: mm for task
+ * @process_pages: struct pages area that can store at least
+ *  nr_pages_to_copy struct page pointers
+ * @pa: address of page in task to start copying from/to
+ * @start_offset: offset in page to start copying from/to
+ * @len: number of bytes to copy
+ * @lvec: iovec array specifying where to copy to/from
+ * @lvec_cnt: number of elements in iovec array
+ * @lvec_current: index in iovec array we are up to
+ * @lvec_offset: offset in bytes from current iovec iov_base we are up to
+ * @vm_write: 0 means copy from, 1 means copy to
+ * @nr_pages_to_copy: number of pages to copy
+ * @bytes_copied: returns number of bytes successfully copied
+ * Returns 0 on success, error code otherwise
+ */
+static int process_vm_rw_pages(struct task_struct *task,
+			       struct mm_struct *mm,
+			       struct page **process_pages,
+			       unsigned long pa,
+			       unsigned long start_offset,
+			       unsigned long len,
+			       const struct iovec *lvec,
+			       unsigned long lvec_cnt,
+			       unsigned long *lvec_current,
+			       size_t *lvec_offset,
+			       int vm_write,
+			       unsigned int nr_pages_to_copy,
+			       ssize_t *bytes_copied)
+{
+	int pages_pinned;
+	void *target_kaddr;
+	int pgs_copied = 0;
+	int j;
+	int ret;
+	ssize_t bytes_to_copy;
+	ssize_t rc = 0;
+
+	*bytes_copied = 0;
+
+	/* Get the pages we're interested in */
+	down_read(&mm->mmap_sem);
+	pages_pinned = get_user_pages(task, mm, pa,
+				      nr_pages_to_copy,
+				      vm_write, 0, process_pages, NULL);
+	up_read(&mm->mmap_sem);
+
+	if (pages_pinned != nr_pages_to_copy) {
+		rc = -EFAULT;
+		goto end;
+	}
+
+	/* Do the copy for each page */
+	for (pgs_copied = 0;
+	     (pgs_copied < nr_pages_to_copy) && (*lvec_current < lvec_cnt);
+	     pgs_copied++) {
+		/* Make sure we have a non zero length iovec */
+		while (*lvec_current < lvec_cnt
+		       && lvec[*lvec_current].iov_len == 0)
+			(*lvec_current)++;
+		if (*lvec_current == lvec_cnt)
+			break;
+
+		/*
+		 * Will copy smallest of:
+		 * - bytes remaining in page
+		 * - bytes remaining in destination iovec
+		 */
+		bytes_to_copy = min_t(ssize_t, PAGE_SIZE - start_offset,
+				      len - *bytes_copied);
+		bytes_to_copy = min_t(ssize_t, bytes_to_copy,
+				      lvec[*lvec_current].iov_len
+				      - *lvec_offset);
+
+		target_kaddr = kmap(process_pages[pgs_copied]) + start_offset;
+
+		if (vm_write)
+			ret = copy_from_user(target_kaddr,
+					     lvec[*lvec_current].iov_base
+					     + *lvec_offset,
+					     bytes_to_copy);
+		else
+			ret = copy_to_user(lvec[*lvec_current].iov_base
+					   + *lvec_offset,
+					   target_kaddr, bytes_to_copy);
+		kunmap(process_pages[pgs_copied]);
+		if (ret) {
+			*bytes_copied += bytes_to_copy - ret;
+			pgs_copied++;
+			rc = -EFAULT;
+			goto end;
+		}
+		*bytes_copied += bytes_to_copy;
+		*lvec_offset += bytes_to_copy;
+		if (*lvec_offset == lvec[*lvec_current].iov_len) {
+			/*
+			 * Need to copy remaining part of page into the
+			 * next iovec if there are any bytes left in page
+			 */
+			(*lvec_current)++;
+			*lvec_offset = 0;
+			start_offset = (start_offset + bytes_to_copy)
+				% PAGE_SIZE;
+			if (start_offset)
+				pgs_copied--;
+		} else {
+			start_offset = 0;
+		}
+	}
+
+end:
+	if (vm_write) {
+		for (j = 0; j < pages_pinned; j++) {
+			if (j < pgs_copied)
+				set_page_dirty_lock(process_pages[j]);
+			put_page(process_pages[j]);
+		}
+	} else {
+		for (j = 0; j < pages_pinned; j++)
+			put_page(process_pages[j]);
+	}
+
+	return rc;
+}
+
+/* Maximum number of pages kmalloc'd to hold struct page's during copy */
+#define PVM_MAX_KMALLOC_PAGES (PAGE_SIZE * 2)
+
+/**
+ * process_vm_rw_single_vec - read/write pages from task specified
+ * @addr: start memory address of target process
+ * @len: size of area to copy to/from
+ * @lvec: iovec array specifying where to copy to/from locally
+ * @lvec_cnt: number of elements in iovec array
+ * @lvec_current: index in iovec array we are up to
+ * @lvec_offset: offset in bytes from current iovec iov_base we are up to
+ * @process_pages: struct pages area that can store at least
+ *  nr_pages_to_copy struct page pointers
+ * @mm: mm for task
+ * @task: task to read/write from
+ * @vm_write: 0 means copy from, 1 means copy to
+ * @bytes_copied: returns number of bytes successfully copied
+ * Returns 0 on success or on failure error code
+ */
+static int process_vm_rw_single_vec(unsigned long addr,
+				    unsigned long len,
+				    const struct iovec *lvec,
+				    unsigned long lvec_cnt,
+				    unsigned long *lvec_current,
+				    size_t *lvec_offset,
+				    struct page **process_pages,
+				    struct mm_struct *mm,
+				    struct task_struct *task,
+				    int vm_write,
+				    ssize_t *bytes_copied)
+{
+	unsigned long pa = addr & PAGE_MASK;
+	unsigned long start_offset = addr - pa;
+	unsigned long nr_pages;
+	ssize_t bytes_copied_loop;
+	ssize_t rc = 0;
+	unsigned long nr_pages_copied = 0;
+	unsigned long nr_pages_to_copy;
+	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
+		/ sizeof(struct pages *);
+
+	*bytes_copied = 0;
+
+	/* Work out address and page range required */
+	if (len == 0)
+		return 0;
+	nr_pages = (addr + len - 1) / PAGE_SIZE - addr / PAGE_SIZE + 1;
+
+	while ((nr_pages_copied < nr_pages) && (*lvec_current < lvec_cnt)) {
+		nr_pages_to_copy = min(nr_pages - nr_pages_copied,
+				       max_pages_per_loop);
+
+		rc = process_vm_rw_pages(task, mm, process_pages, pa,
+					 start_offset, len,
+					 lvec, lvec_cnt,
+					 lvec_current, lvec_offset,
+					 vm_write, nr_pages_to_copy,
+					 &bytes_copied_loop);
+		start_offset = 0;
+		*bytes_copied += bytes_copied_loop;
+
+		if (rc < 0) {
+			return rc;
+		} else {
+			len -= bytes_copied_loop;
+			nr_pages_copied += nr_pages_to_copy;
+			pa += nr_pages_to_copy * PAGE_SIZE;
+		}
+	}
+
+	return rc;
+}
+
+/**
+ * process_vm_rw_core - core of reading/writing pages from task specified
+ * @pid: PID of process to read/write from/to
+ * @lvec: iovec array specifying where to copy to/from locally
+ * @liovcnt: size of lvec array
+ * @rvec: iovec array specifying where to copy to/from in the other process
+ * @riovcnt: size of rvec array
+ * @flags: currently unused
+ * @vm_write: 0 if reading from other process, 1 if writing to other process
+ * Returns the number of bytes read/written or error code. May
+ *  return less bytes than expected if an error occurs during the copying
+ *  process.
+ */
+static ssize_t process_vm_rw_core(pid_t pid, const struct iovec *lvec,
+				  unsigned long liovcnt,
+				  const struct iovec *rvec,
+				  unsigned long riovcnt,
+				  unsigned long flags, int vm_write)
+{
+	struct task_struct *task;
+	struct page **process_pages = NULL;
+	struct mm_struct *mm;
+	unsigned long i;
+	ssize_t rc = 0;
+	ssize_t bytes_copied_loop;
+	ssize_t bytes_copied = 0;
+	unsigned long nr_pages = 0;
+	unsigned long nr_pages_iov;
+	unsigned long iov_l_curr_idx = 0;
+	size_t iov_l_curr_offset = 0;
+	ssize_t iov_len;
+
+	/*
+	 * Work out how many pages of struct pages we're going to need
+	 * when eventually calling get_user_pages
+	 */
+	for (i = 0; i < riovcnt; i++) {
+		iov_len = rvec[i].iov_len;
+		if (iov_len > 0) {
+			nr_pages_iov = ((unsigned long)rvec[i].iov_base
+					+ iov_len)
+				/ PAGE_SIZE - (unsigned long)rvec[i].iov_base
+				/ PAGE_SIZE + 1;
+			nr_pages = max(nr_pages, nr_pages_iov);
+		}
+	}
+
+	if (nr_pages == 0)
+		return 0;
+
+	/* For reliability don't try to kmalloc more than 2 pages worth */
+	process_pages = kmalloc(min_t(size_t, PVM_MAX_KMALLOC_PAGES,
+				      sizeof(struct pages *)*nr_pages),
+				GFP_KERNEL);
+
+	if (!process_pages)
+		return -ENOMEM;
+
+	/* Get process information */
+	rcu_read_lock();
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	rcu_read_unlock();
+	if (!task) {
+		rc = -ESRCH;
+		goto free_proc_pages;
+	}
+
+	task_lock(task);
+	if (__ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
+		task_unlock(task);
+		rc = -EPERM;
+		goto put_task_struct;
+	}
+	mm = task->mm;
+
+	if (!mm || (task->flags & PF_KTHREAD)) {
+		task_unlock(task);
+		rc = -EINVAL;
+		goto put_task_struct;
+	}
+
+	atomic_inc(&mm->mm_users);
+	task_unlock(task);
+
+	for (i = 0; i < riovcnt && iov_l_curr_idx < liovcnt; i++) {
+		rc = process_vm_rw_single_vec(
+			(unsigned long)rvec[i].iov_base, rvec[i].iov_len,
+			lvec, liovcnt, &iov_l_curr_idx, &iov_l_curr_offset,
+			process_pages, mm, task, vm_write, &bytes_copied_loop);
+		bytes_copied += bytes_copied_loop;
+		if (rc != 0) {
+			/* If we have managed to copy any data at all then
+			   we return the number of bytes copied. Otherwise
+			   we return the error code */
+			if (bytes_copied)
+				rc = bytes_copied;
+			goto put_mm;
+		}
+	}
+
+	rc = bytes_copied;
+put_mm:
+	mmput(mm);
+
+put_task_struct:
+	put_task_struct(task);
+
+free_proc_pages:
+	kfree(process_pages);
+	return rc;
+}
+
+/**
+ * process_vm_rw - check iovecs before calling core routine
+ * @pid: PID of process to read/write from/to
+ * @lvec: iovec array specifying where to copy to/from locally
+ * @liovcnt: size of lvec array
+ * @rvec: iovec array specifying where to copy to/from in the other process
+ * @riovcnt: size of rvec array
+ * @flags: currently unused
+ * @vm_write: 0 if reading from other process, 1 if writing to other process
+ * Returns the number of bytes read/written or error code. May
+ *  return less bytes than expected if an error occurs during the copying
+ *  process.
+ */
+static ssize_t process_vm_rw(pid_t pid,
+			     const struct iovec __user *lvec,
+			     unsigned long liovcnt,
+			     const struct iovec __user *rvec,
+			     unsigned long riovcnt,
+			     unsigned long flags, int vm_write)
+{
+	struct iovec iovstack_l[UIO_FASTIOV];
+	struct iovec iovstack_r[UIO_FASTIOV];
+	struct iovec *iov_l = iovstack_l;
+	struct iovec *iov_r = iovstack_r;
+	ssize_t rc;
+
+	if (flags != 0)
+		return -EINVAL;
+
+	/* Check iovecs */
+	if (vm_write)
+		rc = rw_copy_check_uvector(WRITE, lvec, liovcnt, UIO_FASTIOV,
+					   iovstack_l, &iov_l, 1);
+	else
+		rc = rw_copy_check_uvector(READ, lvec, liovcnt, UIO_FASTIOV,
+					   iovstack_l, &iov_l, 1);
+	if (rc <= 0)
+		goto free_iovecs;
+
+	rc = rw_copy_check_uvector(READ, rvec, riovcnt, UIO_FASTIOV,
+				   iovstack_r, &iov_r, 0);
+	if (rc <= 0)
+		goto free_iovecs;
+
+	rc = process_vm_rw_core(pid, iov_l, liovcnt, iov_r, riovcnt, flags,
+				vm_write);
+
+free_iovecs:
+	if (iov_r != iovstack_r)
+		kfree(iov_r);
+	if (iov_l != iovstack_l)
+		kfree(iov_l);
+
+	return rc;
+}
+
+SYSCALL_DEFINE6(process_vm_readv, pid_t, pid, const struct iovec __user *, lvec,
+		unsigned long, liovcnt, const struct iovec __user *, rvec,
+		unsigned long, riovcnt,	unsigned long, flags)
+{
+	return process_vm_rw(pid, lvec, liovcnt, rvec, riovcnt, flags, 0);
+}
+
+SYSCALL_DEFINE6(process_vm_writev, pid_t, pid,
+		const struct iovec __user *, lvec,
+		unsigned long, liovcnt, const struct iovec __user *, rvec,
+		unsigned long, riovcnt,	unsigned long, flags)
+{
+	return process_vm_rw(pid, lvec, liovcnt, rvec, riovcnt, flags, 1);
+}
+
+#ifdef CONFIG_COMPAT
+
+asmlinkage ssize_t
+compat_process_vm_rw(compat_pid_t pid,
+		     const struct compat_iovec __user *lvec,
+		     unsigned long liovcnt,
+		     const struct compat_iovec __user *rvec,
+		     unsigned long riovcnt,
+		     unsigned long flags, int vm_write)
+{
+	struct iovec iovstack_l[UIO_FASTIOV];
+	struct iovec iovstack_r[UIO_FASTIOV];
+	struct iovec *iov_l = iovstack_l;
+	struct iovec *iov_r = iovstack_r;
+	ssize_t rc = -EFAULT;
+
+	if (flags != 0)
+		return -EINVAL;
+
+	if (!access_ok(VERIFY_READ, lvec, liovcnt * sizeof(*lvec)))
+		goto out;
+
+	if (!access_ok(VERIFY_READ, rvec, riovcnt * sizeof(*rvec)))
+		goto out;
+
+	if (vm_write)
+		rc = compat_rw_copy_check_uvector(WRITE, lvec, liovcnt,
+						  UIO_FASTIOV, iovstack_l,
+						  &iov_l, 1);
+	else
+		rc = compat_rw_copy_check_uvector(READ, lvec, liovcnt,
+						  UIO_FASTIOV, iovstack_l,
+						  &iov_l, 1);
+	if (rc <= 0)
+		goto free_iovecs;
+	rc = compat_rw_copy_check_uvector(READ, rvec, riovcnt,
+					  UIO_FASTIOV, iovstack_r,
+					  &iov_r, 0);
+	if (rc <= 0)
+		goto free_iovecs;
+
+	rc = process_vm_rw_core(pid, iov_l, liovcnt, iov_r, riovcnt, flags,
+			   vm_write);
+
+free_iovecs:
+	if (iov_r != iovstack_r)
+		kfree(iov_r);
+	if (iov_l != iovstack_l)
+		kfree(iov_l);
+
+out:
+	return rc;
+}
+
+asmlinkage ssize_t
+compat_sys_process_vm_readv(compat_pid_t pid,
+			    const struct compat_iovec __user *lvec,
+			    unsigned long liovcnt,
+			    const struct compat_iovec __user *rvec,
+			    unsigned long riovcnt,
+			    unsigned long flags)
+{
+	return compat_process_vm_rw(pid, lvec, liovcnt, rvec,
+				    riovcnt, flags, 0);
+}
+
+asmlinkage ssize_t
+compat_sys_process_vm_writev(compat_pid_t pid,
+			     const struct compat_iovec __user *lvec,
+			     unsigned long liovcnt,
+			     const struct compat_iovec __user *rvec,
+			     unsigned long riovcnt,
+			     unsigned long flags)
+{
+	return compat_process_vm_rw(pid, lvec, liovcnt, rvec,
+				    riovcnt, flags, 1);
+}
+
+#endif
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 338b510..4c48e13 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -38,7 +38,7 @@ long compat_keyctl_instantiate_key_iov(
 
 	ret = compat_rw_copy_check_uvector(WRITE, _payload_iov, ioc,
 					   ARRAY_SIZE(iovstack),
-					   iovstack, &iov);
+					   iovstack, &iov, 1);
 	if (ret < 0)
 		return ret;
 	if (ret == 0)
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index eca5191..0b3f5d7 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -1065,7 +1065,7 @@ long keyctl_instantiate_key_iov(key_serial_t id,
 		goto no_payload;
 
 	ret = rw_copy_check_uvector(WRITE, _payload_iov, ioc,
-				    ARRAY_SIZE(iovstack), iovstack, &iov);
+				    ARRAY_SIZE(iovstack), iovstack, &iov, 1);
 	if (ret < 0)
 		return ret;
 	if (ret == 0)
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
