Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 270E36B0036
	for <linux-mm@kvack.org>; Sat, 24 May 2014 09:59:31 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id gl10so4891416lab.39
        for <linux-mm@kvack.org>; Sat, 24 May 2014 06:59:30 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id t5si6225914lal.110.2014.05.24.06.59.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 May 2014 06:59:29 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id pv20so4946500lab.27
        for <linux-mm@kvack.org>; Sat, 24 May 2014 06:59:29 -0700 (PDT)
Subject: [PATCH] mm/process_vm_access: move into ipc/
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 24 May 2014 17:59:25 +0400
Message-ID: <20140524135925.32597.45754.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

"CROSS_MEMORY_ATTACH" and mm/process_vm_access.c seems misnamed and misplaced.
Actually it's a kind of IPC and it has no more relation to MM than sys_read().
This patch moves code into ipc/ and config option into init/Kconfig.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 init/Kconfig            |   10 +
 ipc/Makefile            |    1 
 ipc/process_vm_access.c |  383 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/Kconfig              |   10 -
 mm/Makefile             |    4 
 mm/process_vm_access.c  |  383 -----------------------------------------------
 6 files changed, 394 insertions(+), 397 deletions(-)
 create mode 100644 ipc/process_vm_access.c
 delete mode 100644 mm/process_vm_access.c

diff --git a/init/Kconfig b/init/Kconfig
index 9d3585b..d6ddb7a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -261,6 +261,16 @@ config POSIX_MQUEUE_SYSCTL
 	depends on SYSCTL
 	default y
 
+config CROSS_MEMORY_ATTACH
+	bool "Enable process_vm_readv/writev syscalls"
+	depends on MMU
+	default y
+	help
+	  Enabling this option adds the system calls process_vm_readv and
+	  process_vm_writev which allow a process with the correct privileges
+	  to directly read from or write to to another process's address space.
+	  See the man page for more details.
+
 config FHANDLE
 	bool "open by fhandle syscalls"
 	select EXPORTFS
diff --git a/ipc/Makefile b/ipc/Makefile
index 9075e17..6982d3e 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,4 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
+obj-$(CONFIG_CROSS_MEMORY_ATTACH) += process_vm_access.o
 
diff --git a/ipc/process_vm_access.c b/ipc/process_vm_access.c
new file mode 100644
index 0000000..65aacea
--- /dev/null
+++ b/ipc/process_vm_access.c
@@ -0,0 +1,383 @@
+/*
+ * linux/ipc/process_vm_access.c
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
+ * @pages: array of pointers to pages we want to copy
+ * @start_offset: offset in page to start copying from/to
+ * @len: number of bytes to copy
+ * @iter: where to copy to/from locally
+ * @vm_write: 0 means copy from, 1 means copy to
+ * Returns 0 on success, error code otherwise
+ */
+static int process_vm_rw_pages(struct page **pages,
+			       unsigned offset,
+			       size_t len,
+			       struct iov_iter *iter,
+			       int vm_write)
+{
+	/* Do the copy for each page */
+	while (len && iov_iter_count(iter)) {
+		struct page *page = *pages++;
+		size_t copy = PAGE_SIZE - offset;
+		size_t copied;
+
+		if (copy > len)
+			copy = len;
+
+		if (vm_write) {
+			if (copy > iov_iter_count(iter))
+				copy = iov_iter_count(iter);
+			copied = iov_iter_copy_from_user(page, iter,
+					offset, copy);
+			iov_iter_advance(iter, copied);
+			set_page_dirty_lock(page);
+		} else {
+			copied = copy_page_to_iter(page, offset, copy, iter);
+		}
+		len -= copied;
+		if (copied < copy && iov_iter_count(iter))
+			return -EFAULT;
+		offset = 0;
+	}
+	return 0;
+}
+
+/* Maximum number of pages kmalloc'd to hold struct page's during copy */
+#define PVM_MAX_KMALLOC_PAGES (PAGE_SIZE * 2)
+
+/**
+ * process_vm_rw_single_vec - read/write pages from task specified
+ * @addr: start memory address of target process
+ * @len: size of area to copy to/from
+ * @iter: where to copy to/from locally
+ * @process_pages: struct pages area that can store at least
+ *  nr_pages_to_copy struct page pointers
+ * @mm: mm for task
+ * @task: task to read/write from
+ * @vm_write: 0 means copy from, 1 means copy to
+ * Returns 0 on success or on failure error code
+ */
+static int process_vm_rw_single_vec(unsigned long addr,
+				    unsigned long len,
+				    struct iov_iter *iter,
+				    struct page **process_pages,
+				    struct mm_struct *mm,
+				    struct task_struct *task,
+				    int vm_write)
+{
+	unsigned long pa = addr & PAGE_MASK;
+	unsigned long start_offset = addr - pa;
+	unsigned long nr_pages;
+	ssize_t rc = 0;
+	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
+		/ sizeof(struct pages *);
+
+	/* Work out address and page range required */
+	if (len == 0)
+		return 0;
+	nr_pages = (addr + len - 1) / PAGE_SIZE - addr / PAGE_SIZE + 1;
+
+	while (!rc && nr_pages && iov_iter_count(iter)) {
+		int pages = min(nr_pages, max_pages_per_loop);
+		size_t bytes;
+
+		/* Get the pages we're interested in */
+		down_read(&mm->mmap_sem);
+		pages = get_user_pages(task, mm, pa, pages,
+				      vm_write, 0, process_pages, NULL);
+		up_read(&mm->mmap_sem);
+
+		if (pages <= 0)
+			return -EFAULT;
+
+		bytes = pages * PAGE_SIZE - start_offset;
+		if (bytes > len)
+			bytes = len;
+
+		rc = process_vm_rw_pages(process_pages,
+					 start_offset, bytes, iter,
+					 vm_write);
+		len -= bytes;
+		start_offset = 0;
+		nr_pages -= pages;
+		pa += pages * PAGE_SIZE;
+		while (pages)
+			put_page(process_pages[--pages]);
+	}
+
+	return rc;
+}
+
+/* Maximum number of entries for process pages array
+   which lives on stack */
+#define PVM_MAX_PP_ARRAY_COUNT 16
+
+/**
+ * process_vm_rw_core - core of reading/writing pages from task specified
+ * @pid: PID of process to read/write from/to
+ * @iter: where to copy to/from locally
+ * @rvec: iovec array specifying where to copy to/from in the other process
+ * @riovcnt: size of rvec array
+ * @flags: currently unused
+ * @vm_write: 0 if reading from other process, 1 if writing to other process
+ * Returns the number of bytes read/written or error code. May
+ *  return less bytes than expected if an error occurs during the copying
+ *  process.
+ */
+static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
+				  const struct iovec *rvec,
+				  unsigned long riovcnt,
+				  unsigned long flags, int vm_write)
+{
+	struct task_struct *task;
+	struct page *pp_stack[PVM_MAX_PP_ARRAY_COUNT];
+	struct page **process_pages = pp_stack;
+	struct mm_struct *mm;
+	unsigned long i;
+	ssize_t rc = 0;
+	unsigned long nr_pages = 0;
+	unsigned long nr_pages_iov;
+	ssize_t iov_len;
+	size_t total_len = iov_iter_count(iter);
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
+	if (nr_pages > PVM_MAX_PP_ARRAY_COUNT) {
+		/* For reliability don't try to kmalloc more than
+		   2 pages worth */
+		process_pages = kmalloc(min_t(size_t, PVM_MAX_KMALLOC_PAGES,
+					      sizeof(struct pages *)*nr_pages),
+					GFP_KERNEL);
+
+		if (!process_pages)
+			return -ENOMEM;
+	}
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
+	mm = mm_access(task, PTRACE_MODE_ATTACH);
+	if (!mm || IS_ERR(mm)) {
+		rc = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
+		/*
+		 * Explicitly map EACCES to EPERM as EPERM is a more a
+		 * appropriate error code for process_vw_readv/writev
+		 */
+		if (rc == -EACCES)
+			rc = -EPERM;
+		goto put_task_struct;
+	}
+
+	for (i = 0; i < riovcnt && iov_iter_count(iter) && !rc; i++)
+		rc = process_vm_rw_single_vec(
+			(unsigned long)rvec[i].iov_base, rvec[i].iov_len,
+			iter, process_pages, mm, task, vm_write);
+
+	/* copied = space before - space after */
+	total_len -= iov_iter_count(iter);
+
+	/* If we have managed to copy any data at all then
+	   we return the number of bytes copied. Otherwise
+	   we return the error code */
+	if (total_len)
+		rc = total_len;
+
+	mmput(mm);
+
+put_task_struct:
+	put_task_struct(task);
+
+free_proc_pages:
+	if (process_pages != pp_stack)
+		kfree(process_pages);
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
+	struct iov_iter iter;
+	ssize_t rc;
+
+	if (flags != 0)
+		return -EINVAL;
+
+	/* Check iovecs */
+	if (vm_write)
+		rc = rw_copy_check_uvector(WRITE, lvec, liovcnt, UIO_FASTIOV,
+					   iovstack_l, &iov_l);
+	else
+		rc = rw_copy_check_uvector(READ, lvec, liovcnt, UIO_FASTIOV,
+					   iovstack_l, &iov_l);
+	if (rc <= 0)
+		goto free_iovecs;
+
+	iov_iter_init(&iter, iov_l, liovcnt, rc, 0);
+
+	rc = rw_copy_check_uvector(CHECK_IOVEC_ONLY, rvec, riovcnt, UIO_FASTIOV,
+				   iovstack_r, &iov_r);
+	if (rc <= 0)
+		goto free_iovecs;
+
+	rc = process_vm_rw_core(pid, &iter, iov_r, riovcnt, flags, vm_write);
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
+static ssize_t
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
+	struct iov_iter iter;
+	ssize_t rc = -EFAULT;
+
+	if (flags != 0)
+		return -EINVAL;
+
+	if (vm_write)
+		rc = compat_rw_copy_check_uvector(WRITE, lvec, liovcnt,
+						  UIO_FASTIOV, iovstack_l,
+						  &iov_l);
+	else
+		rc = compat_rw_copy_check_uvector(READ, lvec, liovcnt,
+						  UIO_FASTIOV, iovstack_l,
+						  &iov_l);
+	if (rc <= 0)
+		goto free_iovecs;
+	iov_iter_init(&iter, iov_l, liovcnt, rc, 0);
+	rc = compat_rw_copy_check_uvector(CHECK_IOVEC_ONLY, rvec, riovcnt,
+					  UIO_FASTIOV, iovstack_r,
+					  &iov_r);
+	if (rc <= 0)
+		goto free_iovecs;
+
+	rc = process_vm_rw_core(pid, &iter, iov_r, riovcnt, flags, vm_write);
+
+free_iovecs:
+	if (iov_r != iovstack_r)
+		kfree(iov_r);
+	if (iov_l != iovstack_l)
+		kfree(iov_l);
+	return rc;
+}
+
+COMPAT_SYSCALL_DEFINE6(process_vm_readv, compat_pid_t, pid,
+		       const struct compat_iovec __user *, lvec,
+		       compat_ulong_t, liovcnt,
+		       const struct compat_iovec __user *, rvec,
+		       compat_ulong_t, riovcnt,
+		       compat_ulong_t, flags)
+{
+	return compat_process_vm_rw(pid, lvec, liovcnt, rvec,
+				    riovcnt, flags, 0);
+}
+
+COMPAT_SYSCALL_DEFINE6(process_vm_writev, compat_pid_t, pid,
+		       const struct compat_iovec __user *, lvec,
+		       compat_ulong_t, liovcnt,
+		       const struct compat_iovec __user *, rvec,
+		       compat_ulong_t, riovcnt,
+		       compat_ulong_t, flags)
+{
+	return compat_process_vm_rw(pid, lvec, liovcnt, rvec,
+				    riovcnt, flags, 1);
+}
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 1b5a95f..2ec35d7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -430,16 +430,6 @@ choice
 	  benefit.
 endchoice
 
-config CROSS_MEMORY_ATTACH
-	bool "Cross Memory Support"
-	depends on MMU
-	default y
-	help
-	  Enabling this option adds the system calls process_vm_readv and
-	  process_vm_writev which allow a process with the correct privileges
-	  to directly read from or write to to another process's address space.
-	  See the man page for more details.
-
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/Makefile b/mm/Makefile
index b484452..d624084 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -7,10 +7,6 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
 			   vmalloc.o pagewalk.o pgtable-generic.o
 
-ifdef CONFIG_CROSS_MEMORY_ATTACH
-mmu-$(CONFIG_MMU)	+= process_vm_access.o
-endif
-
 obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
deleted file mode 100644
index 8505c92..0000000
--- a/mm/process_vm_access.c
+++ /dev/null
@@ -1,383 +0,0 @@
-/*
- * linux/mm/process_vm_access.c
- *
- * Copyright (C) 2010-2011 Christopher Yeoh <cyeoh@au1.ibm.com>, IBM Corp.
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/mm.h>
-#include <linux/uio.h>
-#include <linux/sched.h>
-#include <linux/highmem.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/syscalls.h>
-
-#ifdef CONFIG_COMPAT
-#include <linux/compat.h>
-#endif
-
-/**
- * process_vm_rw_pages - read/write pages from task specified
- * @pages: array of pointers to pages we want to copy
- * @start_offset: offset in page to start copying from/to
- * @len: number of bytes to copy
- * @iter: where to copy to/from locally
- * @vm_write: 0 means copy from, 1 means copy to
- * Returns 0 on success, error code otherwise
- */
-static int process_vm_rw_pages(struct page **pages,
-			       unsigned offset,
-			       size_t len,
-			       struct iov_iter *iter,
-			       int vm_write)
-{
-	/* Do the copy for each page */
-	while (len && iov_iter_count(iter)) {
-		struct page *page = *pages++;
-		size_t copy = PAGE_SIZE - offset;
-		size_t copied;
-
-		if (copy > len)
-			copy = len;
-
-		if (vm_write) {
-			if (copy > iov_iter_count(iter))
-				copy = iov_iter_count(iter);
-			copied = iov_iter_copy_from_user(page, iter,
-					offset, copy);
-			iov_iter_advance(iter, copied);
-			set_page_dirty_lock(page);
-		} else {
-			copied = copy_page_to_iter(page, offset, copy, iter);
-		}
-		len -= copied;
-		if (copied < copy && iov_iter_count(iter))
-			return -EFAULT;
-		offset = 0;
-	}
-	return 0;
-}
-
-/* Maximum number of pages kmalloc'd to hold struct page's during copy */
-#define PVM_MAX_KMALLOC_PAGES (PAGE_SIZE * 2)
-
-/**
- * process_vm_rw_single_vec - read/write pages from task specified
- * @addr: start memory address of target process
- * @len: size of area to copy to/from
- * @iter: where to copy to/from locally
- * @process_pages: struct pages area that can store at least
- *  nr_pages_to_copy struct page pointers
- * @mm: mm for task
- * @task: task to read/write from
- * @vm_write: 0 means copy from, 1 means copy to
- * Returns 0 on success or on failure error code
- */
-static int process_vm_rw_single_vec(unsigned long addr,
-				    unsigned long len,
-				    struct iov_iter *iter,
-				    struct page **process_pages,
-				    struct mm_struct *mm,
-				    struct task_struct *task,
-				    int vm_write)
-{
-	unsigned long pa = addr & PAGE_MASK;
-	unsigned long start_offset = addr - pa;
-	unsigned long nr_pages;
-	ssize_t rc = 0;
-	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
-		/ sizeof(struct pages *);
-
-	/* Work out address and page range required */
-	if (len == 0)
-		return 0;
-	nr_pages = (addr + len - 1) / PAGE_SIZE - addr / PAGE_SIZE + 1;
-
-	while (!rc && nr_pages && iov_iter_count(iter)) {
-		int pages = min(nr_pages, max_pages_per_loop);
-		size_t bytes;
-
-		/* Get the pages we're interested in */
-		down_read(&mm->mmap_sem);
-		pages = get_user_pages(task, mm, pa, pages,
-				      vm_write, 0, process_pages, NULL);
-		up_read(&mm->mmap_sem);
-
-		if (pages <= 0)
-			return -EFAULT;
-
-		bytes = pages * PAGE_SIZE - start_offset;
-		if (bytes > len)
-			bytes = len;
-
-		rc = process_vm_rw_pages(process_pages,
-					 start_offset, bytes, iter,
-					 vm_write);
-		len -= bytes;
-		start_offset = 0;
-		nr_pages -= pages;
-		pa += pages * PAGE_SIZE;
-		while (pages)
-			put_page(process_pages[--pages]);
-	}
-
-	return rc;
-}
-
-/* Maximum number of entries for process pages array
-   which lives on stack */
-#define PVM_MAX_PP_ARRAY_COUNT 16
-
-/**
- * process_vm_rw_core - core of reading/writing pages from task specified
- * @pid: PID of process to read/write from/to
- * @iter: where to copy to/from locally
- * @rvec: iovec array specifying where to copy to/from in the other process
- * @riovcnt: size of rvec array
- * @flags: currently unused
- * @vm_write: 0 if reading from other process, 1 if writing to other process
- * Returns the number of bytes read/written or error code. May
- *  return less bytes than expected if an error occurs during the copying
- *  process.
- */
-static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
-				  const struct iovec *rvec,
-				  unsigned long riovcnt,
-				  unsigned long flags, int vm_write)
-{
-	struct task_struct *task;
-	struct page *pp_stack[PVM_MAX_PP_ARRAY_COUNT];
-	struct page **process_pages = pp_stack;
-	struct mm_struct *mm;
-	unsigned long i;
-	ssize_t rc = 0;
-	unsigned long nr_pages = 0;
-	unsigned long nr_pages_iov;
-	ssize_t iov_len;
-	size_t total_len = iov_iter_count(iter);
-
-	/*
-	 * Work out how many pages of struct pages we're going to need
-	 * when eventually calling get_user_pages
-	 */
-	for (i = 0; i < riovcnt; i++) {
-		iov_len = rvec[i].iov_len;
-		if (iov_len > 0) {
-			nr_pages_iov = ((unsigned long)rvec[i].iov_base
-					+ iov_len)
-				/ PAGE_SIZE - (unsigned long)rvec[i].iov_base
-				/ PAGE_SIZE + 1;
-			nr_pages = max(nr_pages, nr_pages_iov);
-		}
-	}
-
-	if (nr_pages == 0)
-		return 0;
-
-	if (nr_pages > PVM_MAX_PP_ARRAY_COUNT) {
-		/* For reliability don't try to kmalloc more than
-		   2 pages worth */
-		process_pages = kmalloc(min_t(size_t, PVM_MAX_KMALLOC_PAGES,
-					      sizeof(struct pages *)*nr_pages),
-					GFP_KERNEL);
-
-		if (!process_pages)
-			return -ENOMEM;
-	}
-
-	/* Get process information */
-	rcu_read_lock();
-	task = find_task_by_vpid(pid);
-	if (task)
-		get_task_struct(task);
-	rcu_read_unlock();
-	if (!task) {
-		rc = -ESRCH;
-		goto free_proc_pages;
-	}
-
-	mm = mm_access(task, PTRACE_MODE_ATTACH);
-	if (!mm || IS_ERR(mm)) {
-		rc = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
-		/*
-		 * Explicitly map EACCES to EPERM as EPERM is a more a
-		 * appropriate error code for process_vw_readv/writev
-		 */
-		if (rc == -EACCES)
-			rc = -EPERM;
-		goto put_task_struct;
-	}
-
-	for (i = 0; i < riovcnt && iov_iter_count(iter) && !rc; i++)
-		rc = process_vm_rw_single_vec(
-			(unsigned long)rvec[i].iov_base, rvec[i].iov_len,
-			iter, process_pages, mm, task, vm_write);
-
-	/* copied = space before - space after */
-	total_len -= iov_iter_count(iter);
-
-	/* If we have managed to copy any data at all then
-	   we return the number of bytes copied. Otherwise
-	   we return the error code */
-	if (total_len)
-		rc = total_len;
-
-	mmput(mm);
-
-put_task_struct:
-	put_task_struct(task);
-
-free_proc_pages:
-	if (process_pages != pp_stack)
-		kfree(process_pages);
-	return rc;
-}
-
-/**
- * process_vm_rw - check iovecs before calling core routine
- * @pid: PID of process to read/write from/to
- * @lvec: iovec array specifying where to copy to/from locally
- * @liovcnt: size of lvec array
- * @rvec: iovec array specifying where to copy to/from in the other process
- * @riovcnt: size of rvec array
- * @flags: currently unused
- * @vm_write: 0 if reading from other process, 1 if writing to other process
- * Returns the number of bytes read/written or error code. May
- *  return less bytes than expected if an error occurs during the copying
- *  process.
- */
-static ssize_t process_vm_rw(pid_t pid,
-			     const struct iovec __user *lvec,
-			     unsigned long liovcnt,
-			     const struct iovec __user *rvec,
-			     unsigned long riovcnt,
-			     unsigned long flags, int vm_write)
-{
-	struct iovec iovstack_l[UIO_FASTIOV];
-	struct iovec iovstack_r[UIO_FASTIOV];
-	struct iovec *iov_l = iovstack_l;
-	struct iovec *iov_r = iovstack_r;
-	struct iov_iter iter;
-	ssize_t rc;
-
-	if (flags != 0)
-		return -EINVAL;
-
-	/* Check iovecs */
-	if (vm_write)
-		rc = rw_copy_check_uvector(WRITE, lvec, liovcnt, UIO_FASTIOV,
-					   iovstack_l, &iov_l);
-	else
-		rc = rw_copy_check_uvector(READ, lvec, liovcnt, UIO_FASTIOV,
-					   iovstack_l, &iov_l);
-	if (rc <= 0)
-		goto free_iovecs;
-
-	iov_iter_init(&iter, iov_l, liovcnt, rc, 0);
-
-	rc = rw_copy_check_uvector(CHECK_IOVEC_ONLY, rvec, riovcnt, UIO_FASTIOV,
-				   iovstack_r, &iov_r);
-	if (rc <= 0)
-		goto free_iovecs;
-
-	rc = process_vm_rw_core(pid, &iter, iov_r, riovcnt, flags, vm_write);
-
-free_iovecs:
-	if (iov_r != iovstack_r)
-		kfree(iov_r);
-	if (iov_l != iovstack_l)
-		kfree(iov_l);
-
-	return rc;
-}
-
-SYSCALL_DEFINE6(process_vm_readv, pid_t, pid, const struct iovec __user *, lvec,
-		unsigned long, liovcnt, const struct iovec __user *, rvec,
-		unsigned long, riovcnt,	unsigned long, flags)
-{
-	return process_vm_rw(pid, lvec, liovcnt, rvec, riovcnt, flags, 0);
-}
-
-SYSCALL_DEFINE6(process_vm_writev, pid_t, pid,
-		const struct iovec __user *, lvec,
-		unsigned long, liovcnt, const struct iovec __user *, rvec,
-		unsigned long, riovcnt,	unsigned long, flags)
-{
-	return process_vm_rw(pid, lvec, liovcnt, rvec, riovcnt, flags, 1);
-}
-
-#ifdef CONFIG_COMPAT
-
-static ssize_t
-compat_process_vm_rw(compat_pid_t pid,
-		     const struct compat_iovec __user *lvec,
-		     unsigned long liovcnt,
-		     const struct compat_iovec __user *rvec,
-		     unsigned long riovcnt,
-		     unsigned long flags, int vm_write)
-{
-	struct iovec iovstack_l[UIO_FASTIOV];
-	struct iovec iovstack_r[UIO_FASTIOV];
-	struct iovec *iov_l = iovstack_l;
-	struct iovec *iov_r = iovstack_r;
-	struct iov_iter iter;
-	ssize_t rc = -EFAULT;
-
-	if (flags != 0)
-		return -EINVAL;
-
-	if (vm_write)
-		rc = compat_rw_copy_check_uvector(WRITE, lvec, liovcnt,
-						  UIO_FASTIOV, iovstack_l,
-						  &iov_l);
-	else
-		rc = compat_rw_copy_check_uvector(READ, lvec, liovcnt,
-						  UIO_FASTIOV, iovstack_l,
-						  &iov_l);
-	if (rc <= 0)
-		goto free_iovecs;
-	iov_iter_init(&iter, iov_l, liovcnt, rc, 0);
-	rc = compat_rw_copy_check_uvector(CHECK_IOVEC_ONLY, rvec, riovcnt,
-					  UIO_FASTIOV, iovstack_r,
-					  &iov_r);
-	if (rc <= 0)
-		goto free_iovecs;
-
-	rc = process_vm_rw_core(pid, &iter, iov_r, riovcnt, flags, vm_write);
-
-free_iovecs:
-	if (iov_r != iovstack_r)
-		kfree(iov_r);
-	if (iov_l != iovstack_l)
-		kfree(iov_l);
-	return rc;
-}
-
-COMPAT_SYSCALL_DEFINE6(process_vm_readv, compat_pid_t, pid,
-		       const struct compat_iovec __user *, lvec,
-		       compat_ulong_t, liovcnt,
-		       const struct compat_iovec __user *, rvec,
-		       compat_ulong_t, riovcnt,
-		       compat_ulong_t, flags)
-{
-	return compat_process_vm_rw(pid, lvec, liovcnt, rvec,
-				    riovcnt, flags, 0);
-}
-
-COMPAT_SYSCALL_DEFINE6(process_vm_writev, compat_pid_t, pid,
-		       const struct compat_iovec __user *, lvec,
-		       compat_ulong_t, liovcnt,
-		       const struct compat_iovec __user *, rvec,
-		       compat_ulong_t, riovcnt,
-		       compat_ulong_t, flags)
-{
-	return compat_process_vm_rw(pid, lvec, liovcnt, rvec,
-				    riovcnt, flags, 1);
-}
-
-#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
