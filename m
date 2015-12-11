Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 818E76B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:03:42 -0500 (EST)
Received: by padhk6 with SMTP id hk6so15177430pad.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 16:03:42 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e64si1237710pfd.15.2015.12.10.16.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 16:03:41 -0800 (PST)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBB004w3003652
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 16:03:40 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1yqfyt11f7-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 16:03:40 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 a13ff9ae9f9a11e5a5cd24be05956610-9d5f6210 for <linux-mm@kvack.org>;	Thu, 10
 Dec 2015 16:03:38 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V4][for-next]mm: add a new vector based madvise syscall
Date: Thu, 10 Dec 2015 16:03:37 -0800
Message-ID: <d01698140a51cf9b2ce233c7574c2ece9f6fa241.1449791762.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Arnd Bergmann <arnd@arndb.de>

In jemalloc, a free(3) doesn't immediately free the memory to OS even
the memory is page aligned/size, and hope the memory can be reused soon.
Later the virtual address becomes fragmented, and more and more free
memory are aggregated. If the free memory size is large, jemalloc uses
madvise(DONT_NEED) to actually free the memory back to OS.

The madvise has significantly overhead paritcularly because of TLB
flush. jemalloc does madvise for several virtual address space ranges
one time. Instead of calling madvise for each of the ranges, we
introduce a new syscall to purge memory for several ranges one time. In
this way, we can merge several TLB flush for the ranges to one big TLB
flush. This also reduce mmap_sem locking and kernel/userspace switching.

I'm running a simple memory allocation benchmark. 32 threads do random
malloc/free/realloc. Corresponding jemalloc patch to utilize this API is
attached.
Without patch:
real    0m18.923s
user    1m11.819s
sys     7m44.626s
each cpu gets around 3000K/s TLB flush interrupt. Perf shows TLB flush
is hotest functions. mmap_sem read locking (because of page fault) is
also heavy.

with patch:
real    0m15.026s
user    0m48.548s
sys     6m41.153s
each cpu gets around 140k/s TLB flush interrupt. TLB flush isn't hot at
all. mmap_sem read locking (still because of page fault) becomes the
sole hot spot.

Another test malloc a bunch of memory in 48 threads, then all threads
free the memory. I measure the time of the memory free.
Without patch: 34.332s
With patch:    17.429s

MADV_FREE does the same TLB flush as MADV_NEED, this also applies to
MADV_FREE. Other madvise type can have small benefits too, like reduce
syscalls/mmap_sem locking.

V3->V4:
- Support all MADV_* (Andi Kleen)
- Add compat syscall (Arnd Bergmann)

V2->V3:
- Delete iov sort (Andrew Morton)
- Support MADV_FREE

V1->V2:
- make madvisev() acts exactly like madvise(). The only difference is
  madvisev() returns error if a range's start equals to start + size.
  Returning 0 (like madvise) is improper here since there are other ranges.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   2 +
 include/linux/compat.h                 |   3 +
 include/linux/syscalls.h               |   3 +
 include/uapi/asm-generic/unistd.h      |   4 +-
 kernel/sys_ni.c                        |   2 +
 mm/madvise.c                           | 281 +++++++++++++++++++++++++++------
 7 files changed, 251 insertions(+), 45 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index cb713df..f65e418 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -384,3 +384,4 @@
 375	i386	membarrier		sys_membarrier
 376	i386	mlock2			sys_mlock2
 377	i386	copy_file_range		sys_copy_file_range
+378	i386	madvisev		sys_madvisev			compat_sys_madvisev
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index dc1040a..158eef4 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -333,6 +333,7 @@
 324	common	membarrier		sys_membarrier
 325	common	mlock2			sys_mlock2
 326	common	copy_file_range		sys_copy_file_range
+327	64	madvisev		sys_madvisev
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
@@ -372,3 +373,4 @@
 543	x32	io_setup		compat_sys_io_setup
 544	x32	io_submit		compat_sys_io_submit
 545	x32	execveat		stub_x32_execveat
+546	x32	madvisev		compat_sys_madvisev
diff --git a/include/linux/compat.h b/include/linux/compat.h
index a76c917..a11ddab 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -689,6 +689,9 @@ asmlinkage long compat_sys_sendfile64(int out_fd, int in_fd,
 asmlinkage long compat_sys_sigaltstack(const compat_stack_t __user *uss_ptr,
 				       compat_stack_t __user *uoss_ptr);
 
+asmlinkage long compat_sys_madvisev(const struct compat_iovec __user *uvector,
+		compat_ulong_t nr_segs, compat_int_t behavior);
+
 #ifdef __ARCH_WANT_SYS_SIGPENDING
 asmlinkage long compat_sys_sigpending(compat_old_sigset_t __user *set);
 #endif
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 185815c..8df6763 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -892,4 +892,7 @@ asmlinkage long sys_copy_file_range(int fd_in, loff_t __user *off_in,
 
 asmlinkage long sys_mlock2(unsigned long start, size_t len, int flags);
 
+asmlinkage long sys_madvisev(const struct iovec __user *uvector,
+		unsigned long nr_segs, int behavior);
+
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 2622b33..23cac4e 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -717,9 +717,11 @@ __SYSCALL(__NR_membarrier, sys_membarrier)
 __SYSCALL(__NR_mlock2, sys_mlock2)
 #define __NR_copy_file_range 285
 __SYSCALL(__NR_copy_file_range, sys_copy_file_range)
+#define __NR_madvisev 286
+__SC_COMP(__NR_madvisev, sys_madvisev, compat_sys_madvisev)
 
 #undef __NR_syscalls
-#define __NR_syscalls 286
+#define __NR_syscalls 287
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 2c5e3a8..8b87f39 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -198,6 +198,8 @@ cond_syscall(sys_munlockall);
 cond_syscall(sys_mlock2);
 cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
+cond_syscall(sys_madvisev);
+cond_syscall(compat_sys_madvisev);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
 cond_syscall(compat_sys_move_pages);
diff --git a/mm/madvise.c b/mm/madvise.c
index f56825b..8d79774 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -21,7 +21,10 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
-
+#include <linux/uio.h>
+#ifdef CONFIG_COMPAT
+#include <linux/compat.h>
+#endif
 #include <asm/tlb.h>
 
 /*
@@ -564,7 +567,8 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+		unsigned long start, unsigned long end, int behavior,
+		void *data)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
@@ -616,6 +620,62 @@ madvise_behavior_valid(int behavior)
 	}
 }
 
+typedef long (*madvise_iterate_fn)(struct vm_area_struct *vma,
+	struct vm_area_struct **prev, unsigned long start,
+	unsigned long end, int behavior, void *data);
+static int madvise_iterate_vma(unsigned long start, unsigned long end,
+	int *unmapped_error, int behavior, madvise_iterate_fn fn, void *data)
+{
+	struct vm_area_struct *vma, *prev;
+	unsigned long tmp;
+	int error = 0;
+
+	/*
+	 * If the interval [start,end) covers some unmapped address
+	 * ranges, just ignore them, but return -ENOMEM at the end.
+	 * - different from the way of handling in mlock etc.
+	 */
+	vma = find_vma_prev(current->mm, start, &prev);
+	if (vma && start > vma->vm_start)
+		prev = vma;
+
+	for (;;) {
+		/* Still start < end. */
+		error = -ENOMEM;
+		if (!vma)
+			break;
+
+		/* Here start < (end|vma->vm_end). */
+		if (start < vma->vm_start) {
+			*unmapped_error = -ENOMEM;
+			start = vma->vm_start;
+			if (start >= end)
+				break;
+		}
+
+		/* Here vma->vm_start <= start < (end|vma->vm_end) */
+		tmp = vma->vm_end;
+		if (end < tmp)
+			tmp = end;
+
+		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
+		error = fn(vma, &prev, start, tmp, behavior, data);
+		if (error)
+			break;
+		start = tmp;
+		if (prev && start < prev->vm_end)
+			start = prev->vm_end;
+		if (start >= end)
+			break;
+		if (prev)
+			vma = prev->vm_next;
+		else	/* madvise_remove dropped mmap_sem */
+			vma = find_vma(current->mm, start);
+	}
+
+	return error;
+}
+
 /*
  * The madvise(2) system call.
  *
@@ -660,8 +720,7 @@ madvise_behavior_valid(int behavior)
  */
 SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 {
-	unsigned long end, tmp;
-	struct vm_area_struct *vma, *prev;
+	unsigned long end;
 	int unmapped_error = 0;
 	int error = -EINVAL;
 	int write;
@@ -697,56 +756,190 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	else
 		down_read(&current->mm->mmap_sem);
 
-	/*
-	 * If the interval [start,end) covers some unmapped address
-	 * ranges, just ignore them, but return -ENOMEM at the end.
-	 * - different from the way of handling in mlock etc.
-	 */
-	vma = find_vma_prev(current->mm, start, &prev);
-	if (vma && start > vma->vm_start)
-		prev = vma;
-
 	blk_start_plug(&plug);
-	for (;;) {
-		/* Still start < end. */
-		error = -ENOMEM;
-		if (!vma)
-			goto out;
 
-		/* Here start < (end|vma->vm_end). */
-		if (start < vma->vm_start) {
-			unmapped_error = -ENOMEM;
-			start = vma->vm_start;
-			if (start >= end)
-				goto out;
+	error = madvise_iterate_vma(start, end, &unmapped_error,
+			behavior, madvise_vma, NULL);
+	if (error == 0 && unmapped_error != 0)
+		error = unmapped_error;
+
+	blk_finish_plug(&plug);
+	if (write)
+		up_write(&current->mm->mmap_sem);
+	else
+		up_read(&current->mm->mmap_sem);
+
+	return error;
+}
+
+static long
+madvisev_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
+		unsigned long start, unsigned long end, int behavior,
+		void *data)
+{
+	struct mmu_gather *tlb = data;
+	*prev = vma;
+	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+		return -EINVAL;
+
+	switch (behavior) {
+	case MADV_FREE:
+		/*
+		 * XXX: In this implementation, MADV_FREE works like
+		 * MADV_DONTNEED on swapless system or full swap.
+		 */
+		if (get_nr_swap_pages() > 0) {
+			/* MADV_FREE works for only anon vma at the moment */
+			if (!vma_is_anonymous(vma))
+				return -EINVAL;
+			madvise_free_page_range(tlb, vma, start, end);
+			break;
 		}
+		/* passthrough */
+	case MADV_DONTNEED:
+		unmap_vmas(tlb, vma, start, end);
+		break;
+	}
+	return 0;
+}
 
-		/* Here vma->vm_start <= start < (end|vma->vm_end) */
-		tmp = vma->vm_end;
-		if (end < tmp)
-			tmp = end;
+static int do_madvisev(struct iovec *iov, unsigned long nr_segs, int behavior)
+{
+	unsigned long start, end = 0;
+	int unmapped_error = 0;
+	size_t len;
+	struct mmu_gather tlb;
+	int error = 0;
+	int i;
+	int write;
+	struct blk_plug plug;
 
-		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
-		if (error)
-			goto out;
-		start = tmp;
-		if (prev && start < prev->vm_end)
-			start = prev->vm_end;
-		error = unmapped_error;
-		if (start >= end)
-			goto out;
-		if (prev)
-			vma = prev->vm_next;
-		else	/* madvise_remove dropped mmap_sem */
-			vma = find_vma(current->mm, start);
+#ifdef CONFIG_MEMORY_FAILURE
+	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE) {
+		for (i = 0; i < nr_segs; i++) {
+			start = (unsigned long)iov[i].iov_base;
+			len = iov[i].iov_len;
+			error = madvise_hwpoison(behavior, start, start + len);
+			if (error)
+				return error;
+		}
+		return 0;
 	}
-out:
-	blk_finish_plug(&plug);
+#endif
+
+	if (!madvise_behavior_valid(behavior))
+		return -EINVAL;
+
+	for (i = 0; i < nr_segs; i++) {
+		start = (unsigned long)iov[i].iov_base;
+		/* Make sure iovs don't overlap and sorted */
+		if (start & ~PAGE_MASK || start < end)
+			return -EINVAL;
+		len = ((iov[i].iov_len + ~PAGE_MASK) & PAGE_MASK);
+
+		/*
+		 * Check to see whether len was rounded up from small -ve to
+		 * zero
+		 */
+		if (iov[i].iov_len && !len)
+			return -EINVAL;
+
+		end = start + len;
+
+		/*
+		 * end == start returns error (different against madvise).
+		 * return 0 is improper as there are other iovs
+		 */
+		if (end <= start)
+			return -EINVAL;
+
+		iov[i].iov_len = len;
+	}
+
+	write = madvise_need_mmap_write(behavior);
+	if (write)
+		down_write(&current->mm->mmap_sem);
+	else
+		down_read(&current->mm->mmap_sem);
+
+	if (behavior == MADV_DONTNEED || behavior == MADV_FREE) {
+		lru_add_drain();
+		tlb_gather_mmu(&tlb, current->mm,
+			(unsigned long)iov[0].iov_base, end);
+		update_hiwater_rss(current->mm);
+		for (i = 0; i < nr_segs; i++) {
+			start = (unsigned long)iov[i].iov_base;
+			len = iov[i].iov_len;
+
+			error = madvise_iterate_vma(start, start + len,
+				&unmapped_error, behavior, madvisev_vma, &tlb);
+			if (error)
+				break;
+		}
+		tlb_finish_mmu(&tlb, (unsigned long)iov[0].iov_base, end);
+	} else {
+		blk_start_plug(&plug);
+		for (i = 0; i < nr_segs; i++) {
+			start = (unsigned long)iov[i].iov_base;
+			len = iov[i].iov_len;
+
+			error = madvise_iterate_vma(start, start + len,
+				&unmapped_error, behavior, madvise_vma, NULL);
+			if (error)
+				break;
+		}
+		blk_finish_plug(&plug);
+	}
+	if (error == 0 && unmapped_error != 0)
+		error = unmapped_error;
+
 	if (write)
 		up_write(&current->mm->mmap_sem);
 	else
 		up_read(&current->mm->mmap_sem);
+	return error;
+}
+
+/*
+ * The vector madvise(). Like madvise except running for a vector of virtual
+ * address ranges
+ */
+SYSCALL_DEFINE3(madvisev, const struct iovec __user *, uvector,
+	unsigned long, nr_segs, int, behavior)
+{
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov = NULL;
+	int error;
+
+	error = rw_copy_check_uvector(CHECK_IOVEC_ONLY, uvector, nr_segs,
+			UIO_FASTIOV, iovstack, &iov);
+	if (error <= 0)
+		return error;
+
+	error = do_madvisev(iov, nr_segs, behavior);
 
+	if (iov != iovstack)
+		kfree(iov);
 	return error;
 }
+
+#ifdef CONFIG_COMPAT
+COMPAT_SYSCALL_DEFINE3(madvisev, const struct compat_iovec __user *, uvector,
+	compat_ulong_t, nr_segs, compat_int_t, behavior)
+{
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov = NULL;
+	int error;
+
+	error = compat_rw_copy_check_uvector(CHECK_IOVEC_ONLY, uvector, nr_segs,
+			UIO_FASTIOV, iovstack, &iov);
+	if (error <= 0)
+		return error;
+
+	error = do_madvisev(iov, nr_segs, behavior);
+
+	if (iov != iovstack)
+		kfree(iov);
+	return error;
+}
+#endif
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
