Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 989B88D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:05:58 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2F45gJl022052
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:05:42 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2F45lOE2306264
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:05:47 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2F45k5D025342
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:05:46 +1100
Date: Tue, 15 Mar 2011 14:35:47 +1030
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: [Resend] Cross Memory Attach v3 [PATCH]
Message-ID: <20110315143547.1b233cd4@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Hi Andrew,

I was wondering if you thought the cross memory attach patch is in
suitable shape to go into your tree with view of getting it into
mainline sometime in the not too distant future. The patch
is currently based on 2.6.37 but I can send you a version against 
mmotm.

Although we don't have a "second user" of the interface (though I've
had some nibbles from people who may be interested in using it for
intra process messaging which is not MPI). This interface is something
which hardware vendors are already doing for their custom drivers to
implement fast local communication. And so in addition to this being
useful for OpenMPI it would mean the driver maintainers don't have to
fix things up when the mm changes. 

Updates since you last saw the patch:

- Adds 32 bit compatibility version
- modifies [compat]_rw_copy_check_uvector to add extra parameter
  so it can optionally only check the iovec itself is valid and not what
  it points to. This allows these functions to be reused when checking
  iovecs passed to the syscall which refer to the remote process being
  copied to/from.
- Fixed consistency of return values from functions
- Use of min_t instead of min where appropriate
- Fixes mmap_sem locking bug
- Fixes potential deadlock when processes copy to/from each other
  simultaneously

And just as a reminder a general description of the patch with some
benchmarks:

The basic idea behind cross memory attach is to allow MPI programs doing
intra-node communication to do a single copy of the message rather than
a double copy of the message via shared memory.

The following patch attempts to achieve this by allowing a
destination process, given an address and size from a source process, to
copy memory directly from the source process into its own address space
via a system call. There is also a symmetrical ability to copy from 
the current process's address space into a destination process's
address space.

- Use of /proc/pid/mem has been considered, but there are issues with 
  using it:
  - Does not allow for specifying iovecs for both src and dest, assuming
    preadv or pwritev was implemented either the area read from or written 
    to would need to be contiguous. 
  - Currently mem_read allows only processes who are currently ptrace'ing
    the target and are still able to ptrace the target to read from the
    target. This check could possibly be moved to the open call, but its not
    clear exactly what race this restriction is stopping (reason  appears to
    have been lost)
  - Having to send the fd of /proc/self/mem via SCM_RIGHTS on unix domain
    socket is a bit ugly from a userspace point of view, especially when
    you may have hundreds if not (eventually) thousands of processes  that
    all need to do this with each other
  - Doesn't allow for some future use of the interface we would like to
  consider adding in the future (see below)
  - Interestingly reading from /proc/pid/mem currently actually
  involves two copies! (But this could be fixed pretty easily)

As mentioned previously use of vmsplice instead was considered, 
but has problems. Since you need the reader and writer working
co-operatively if the pipe is not drained then you block. Which requires some
wrapping to do non blocking on the send side or polling on the receive.
In all to all communication it requires ordering otherwise you can
deadlock. And in the example of many MPI tasks writing to one MPI task
vmsplice serialises the copying.

There are some cases of MPI collectives where even a single copy
interface does not get us the performance gain we could. For example in
an MPI_Reduce rather than copy the data from the source we would like
to instead use it directly in a mathops (say the reduce is doing a sum)
as this would save us doing a copy. We don't need to keep a copy of the data from the
source. I haven't implemented this, but I think this interface could in
the future do all this through the use of the flags - eg could specify the math
operation and type and the kernel rather than just copying the data
would apply the specified operation between the source and destination
and store it in the destination. 


HPCC results:
=============

MB/s			Num Processes	
Naturally Ordered	4	8	16	32
Base			1235	935	622	419
CMA			4741	3769	1977	703

			
MB/s			Num Processes	
Randomly Ordered	4	8	16	32
Base			1227	947	638	412
CMA			4666	3682	1978	710
				
MB/s			Num Processes	
Max Ping Pong		4	8	16	32
Base			2028	1938	1928	1882
CMA			7424	7510	7598	7708


NPB:
====
BT - 12% improvement
FT - 15% improvement
IS - 30% improvement
SP - 34% improvement

IMB:
===
		
Ping Pong - ~30% improvement
Ping Ping - ~120% improvement
SendRecv - ~100% improvement
Exchange - ~150% improvement
Gather(v) - ~20% improvement
Scatter(v) - ~20% improvement
AlltoAll(v) - 30-50% improvement

Regards,

Chris
-- 
cyeoh@au.ibm.com
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index aa0f1eb..06cde20 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -348,3 +348,5 @@ COMPAT_SYS_SPU(sendmsg)
 COMPAT_SYS_SPU(recvmsg)
 COMPAT_SYS_SPU(recvmmsg)
 SYSCALL_SPU(accept4)
+COMPAT_SYS(process_vm_readv)
+COMPAT_SYS(process_vm_writev)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index 6151937..9ce27ec 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -367,10 +367,12 @@
 #define __NR_recvmsg		342
 #define __NR_recvmmsg		343
 #define __NR_accept4		344
+#define __NR_process_vm_readv	345
+#define __NR_process_vm_writev	346
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		345
+#define __NR_syscalls		347
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index b766a5e..1446daa 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -346,10 +346,12 @@
 #define __NR_fanotify_init	338
 #define __NR_fanotify_mark	339
 #define __NR_prlimit64		340
+#define __NR_process_vm_readv	341
+#define __NR_process_vm_writev	342
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 341
+#define NR_syscalls 343
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index b35786d..f1ed82c 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -340,3 +340,5 @@ ENTRY(sys_call_table)
 	.long sys_fanotify_init
 	.long sys_fanotify_mark
 	.long sys_prlimit64		/* 340 */
+	.long sys_process_vm_readv
+	.long sys_process_vm_writev
diff --git a/fs/aio.c b/fs/aio.c
index 8c8f6c5..ddc4474 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1402,13 +1402,13 @@ static ssize_t aio_setup_vectored_rw(int type, struct kiocb *kiocb, bool compat)
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
index eb1740a..00a2699 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -576,7 +576,7 @@ out:
 ssize_t compat_rw_copy_check_uvector(int type,
 		const struct compat_iovec __user *uvector, unsigned long nr_segs,
 		unsigned long fast_segs, struct iovec *fast_pointer,
-		struct iovec **ret_pointer)
+		struct iovec **ret_pointer, int check_access)
 {
 	compat_ssize_t tot_len;
 	struct iovec *iov = *ret_pointer = fast_pointer;
@@ -625,7 +625,8 @@ ssize_t compat_rw_copy_check_uvector(int type,
 		}
 		if (len < 0)	/* size_t not fitting in compat_ssize_t .. */
 			goto out;
-		if (!access_ok(vrfy_dir(type), compat_ptr(buf), len)) {
+		if (check_access &&
+		    !access_ok(vrfy_dir(type), compat_ptr(buf), len)) {
 			ret = -EFAULT;
 			goto out;
 		}
@@ -1139,7 +1140,7 @@ static ssize_t compat_do_readv_writev(int type, struct file *file,
 		goto out;
 
 	tot_len = compat_rw_copy_check_uvector(type, uvector, nr_segs,
-					       UIO_FASTIOV, iovstack, &iov);
+					       UIO_FASTIOV, iovstack, &iov, 1);
 	if (tot_len == 0) {
 		ret = 0;
 		goto out;
diff --git a/fs/read_write.c b/fs/read_write.c
index 5d431ba..709dc59 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -580,7 +580,8 @@ ssize_t do_loop_readv_writev(struct file *filp, struct iovec *iov,
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 			      unsigned long nr_segs, unsigned long fast_segs,
 			      struct iovec *fast_pointer,
-			      struct iovec **ret_pointer)
+			      struct iovec **ret_pointer,
+			      int check_access)
 {
 	unsigned long seg;
 	ssize_t ret;
@@ -636,7 +637,8 @@ ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 			ret = -EINVAL;
 			goto out;
 		}
-		if (unlikely(!access_ok(vrfy_dir(type), buf, len))) {
+		if (check_access
+		    && unlikely(!access_ok(vrfy_dir(type), buf, len))) {
 			ret = -EFAULT;
 			goto out;
 		}
@@ -668,7 +670,7 @@ static ssize_t do_readv_writev(int type, struct file *file,
 	}
 
 	ret = rw_copy_check_uvector(type, uvector, nr_segs,
-			ARRAY_SIZE(iovstack), iovstack, &iov);
+				    ARRAY_SIZE(iovstack), iovstack, &iov, 1);
 	if (ret <= 0)
 		goto out;
 
diff --git a/include/linux/compat.h b/include/linux/compat.h
index 5778b55..07709bc 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -359,7 +359,8 @@ asmlinkage long compat_sys_openat(unsigned int dfd, const char __user *filename,
 extern ssize_t compat_rw_copy_check_uvector(int type,
 		const struct compat_iovec __user *uvector, unsigned long nr_segs,
 		unsigned long fast_segs, struct iovec *fast_pointer,
-		struct iovec **ret_pointer);
+		struct iovec **ret_pointer,
+		int check_access);
 
 extern void __user *compat_alloc_user_space(unsigned long len);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 090f0ea..6a92f7f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1578,9 +1578,10 @@ struct inode_operations {
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
index cacc27a..1b5d77d 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -832,5 +832,17 @@ asmlinkage long sys_mmap_pgoff(unsigned long addr, unsigned long len,
 			unsigned long prot, unsigned long flags,
 			unsigned long fd, unsigned long pgoff);
 asmlinkage long sys_old_mmap(struct mmap_arg_struct __user *arg);
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
 
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index 02e48aa..d9f4c6b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,12 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/syscalls.h>
+#include <linux/ptrace.h>
+
+#ifdef CONFIG_COMPAT
+#include <linux/compat.h>
+#endif
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3585,6 +3591,435 @@ void print_vma_addr(char *prefix, unsigned long ip)
 	up_read(&current->mm->mmap_sem);
 }
 
+/*
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
+ */
+static ssize_t process_vm_rw_pages(struct task_struct *task,
+				   struct mm_struct *mm,
+				   struct page **process_pages,
+				   unsigned long pa,
+				   unsigned long start_offset,
+				   unsigned long len,
+				   const struct iovec *lvec,
+				   unsigned long lvec_cnt,
+				   unsigned long *lvec_current,
+				   size_t *lvec_offset,
+				   int vm_write,
+				   unsigned int nr_pages_to_copy)
+{
+	int pages_pinned;
+	void *target_kaddr;
+	int pgs_copied = 0;
+	int j;
+	int ret;
+	ssize_t bytes_to_copy;
+	ssize_t bytes_copied = 0;
+	ssize_t rc = -EFAULT;
+
+	/* Get the pages we're interested in */
+	down_read(&mm->mmap_sem);
+	pages_pinned = get_user_pages(task, mm, pa,
+				      nr_pages_to_copy,
+				      vm_write, 0, process_pages, NULL);
+	up_read(&mm->mmap_sem);
+
+	if (pages_pinned != nr_pages_to_copy)
+		goto end;
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
+				      len - bytes_copied);
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
+			pgs_copied++;
+			goto end;
+		}
+		bytes_copied += bytes_to_copy;
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
+	rc = bytes_copied;
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
+/*
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
+ */
+static ssize_t process_vm_rw_single_vec(unsigned long addr,
+					unsigned long len,
+					const struct iovec *lvec,
+					unsigned long lvec_cnt,
+					unsigned long *lvec_current,
+					size_t *lvec_offset,
+					struct page **process_pages,
+					struct mm_struct *mm,
+					struct task_struct *task,
+					int vm_write)
+{
+	unsigned long pa = addr & PAGE_MASK;
+	unsigned long start_offset = addr - pa;
+	unsigned long nr_pages;
+	ssize_t bytes_copied = 0;
+	ssize_t rc;
+	unsigned long nr_pages_copied = 0;
+	unsigned long nr_pages_to_copy;
+	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
+		/ sizeof(struct pages *);
+
+
+	/* Work out address and page range required */
+	if (len == 0)
+		return 0;
+	nr_pages = (addr + len - 1) / PAGE_SIZE - addr / PAGE_SIZE + 1;
+
+
+	while ((nr_pages_copied < nr_pages) && (*lvec_current < lvec_cnt)) {
+		nr_pages_to_copy = min(nr_pages - nr_pages_copied,
+				       max_pages_per_loop);
+
+		rc = process_vm_rw_pages(task, mm, process_pages, pa,
+					 start_offset, len,
+					 lvec, lvec_cnt,
+					 lvec_current, lvec_offset,
+					 vm_write, nr_pages_to_copy);
+		start_offset = 0;
+
+		if (rc < 0)
+			return rc;
+		else {
+			bytes_copied += rc;
+			len -= rc;
+			nr_pages_copied += nr_pages_to_copy;
+			pa += nr_pages_to_copy * PAGE_SIZE;
+		}
+	}
+
+	rc = bytes_copied;
+	return rc;
+}
+
+static ssize_t process_vm_rw(pid_t pid, const struct iovec *lvec,
+			     unsigned long liovcnt,
+			     const struct iovec *rvec,
+			     unsigned long riovcnt,
+			     unsigned long flags, int vm_write)
+{
+	struct task_struct *task;
+	struct page **process_pages = NULL;
+	struct mm_struct *mm;
+	unsigned long i;
+	ssize_t rc;
+	ssize_t bytes_copied;
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
+	rc = 0;
+	for (i = 0; i < riovcnt && iov_l_curr_idx < liovcnt; i++) {
+		bytes_copied = process_vm_rw_single_vec(
+			(unsigned long)rvec[i].iov_base, rvec[i].iov_len,
+			lvec, liovcnt, &iov_l_curr_idx, &iov_l_curr_offset,
+			process_pages, mm, task, vm_write);
+		if (bytes_copied < 0) {
+			rc = bytes_copied;
+			goto put_mm;
+		} else {
+			rc += bytes_copied;
+		}
+	}
+
+put_mm:
+	mmput(mm);
+
+put_task_struct:
+	put_task_struct(task);
+
+
+free_proc_pages:
+	kfree(process_pages);
+	return rc;
+}
+
+static ssize_t process_vm_rw_check_iovecs(pid_t pid,
+					  const struct iovec __user *lvec,
+					  unsigned long liovcnt,
+					  const struct iovec __user *rvec,
+					  unsigned long riovcnt,
+					  unsigned long flags, int vm_write)
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
+	rc = process_vm_rw(pid, iov_l, liovcnt, iov_r, riovcnt, flags,
+			    vm_write);
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
+	return process_vm_rw_check_iovecs(pid, lvec, liovcnt, rvec, riovcnt,
+					  flags, 0);
+}
+
+SYSCALL_DEFINE6(process_vm_writev, pid_t, pid,
+		const struct iovec __user *, lvec,
+		unsigned long, liovcnt, const struct iovec __user *, rvec,
+		unsigned long, riovcnt,	unsigned long, flags)
+{
+	return process_vm_rw_check_iovecs(pid, lvec, liovcnt, rvec, riovcnt,
+					  flags, 1);
+}
+
+#ifdef CONFIG_COMPAT
+
+asmlinkage ssize_t
+compat_process_vm_rw_check_iovecs(compat_pid_t pid,
+				  const struct compat_iovec __user *lvec,
+				  unsigned long liovcnt,
+				  const struct compat_iovec __user *rvec,
+				  unsigned long riovcnt,
+				  unsigned long flags, int vm_write)
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
+	rc = process_vm_rw(pid, iov_l, liovcnt, iov_r, riovcnt, flags,
+			    vm_write);
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
+	return compat_process_vm_rw_check_iovecs(pid, lvec, liovcnt, rvec,
+						 riovcnt, flags, 0);
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
+	return compat_process_vm_rw_check_iovecs(pid, lvec, liovcnt, rvec,
+						 riovcnt, flags, 1);
+}
+
+#endif
+
 #ifdef CONFIG_PROVE_LOCKING
 void might_fault(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
