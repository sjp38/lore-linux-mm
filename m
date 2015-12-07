Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id ECB9A6B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 18:54:15 -0500 (EST)
Received: by wmec201 with SMTP id c201so189482491wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 15:54:15 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x130si26852793wmx.46.2015.12.07.15.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 15:54:14 -0800 (PST)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tB7Npljj013391
	for <linux-mm@kvack.org>; Mon, 7 Dec 2015 15:54:12 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1ykvfgtnca-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Dec 2015 15:54:12 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 ce81c0b49d3d11e590630002c95209d8-ea6e1210 for <linux-mm@kvack.org>;	Mon, 07
 Dec 2015 15:54:09 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V3][for-next] mm: add a new vector based madvise syscall
Date: Mon, 7 Dec 2015 15:54:07 -0800
Message-ID: <7c6ce0f1fe29fc22faf72134f4e2674da8d3d149.1449532062.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>

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
MADV_FREE.

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
Signed-off-by: Shaohua Li <shli@fb.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 include/linux/syscalls.h               |   3 +
 include/uapi/asm-generic/unistd.h      |   4 +-
 kernel/sys_ni.c                        |   1 +
 mm/madvise.c                           | 224 ++++++++++++++++++++++++++-------
 6 files changed, 187 insertions(+), 47 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index cb713df..57ed580 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -384,3 +384,4 @@
 375	i386	membarrier		sys_membarrier
 376	i386	mlock2			sys_mlock2
 377	i386	copy_file_range		sys_copy_file_range
+378	i386	madvisev		sys_madvisev
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index dc1040a..08466c7 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -333,6 +333,7 @@
 324	common	membarrier		sys_membarrier
 325	common	mlock2			sys_mlock2
 326	common	copy_file_range		sys_copy_file_range
+327	common	madvisev		sys_madvisev
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
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
index 2622b33..3bfb9a4 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -717,9 +717,11 @@ __SYSCALL(__NR_membarrier, sys_membarrier)
 __SYSCALL(__NR_mlock2, sys_mlock2)
 #define __NR_copy_file_range 285
 __SYSCALL(__NR_copy_file_range, sys_copy_file_range)
+#define __NR_madvisev 286
+__SYSCALL(__NR_madvisev, sys_madvisev)
 
 #undef __NR_syscalls
-#define __NR_syscalls 286
+#define __NR_syscalls 287
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 2c5e3a8..4092660 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -198,6 +198,7 @@ cond_syscall(sys_munlockall);
 cond_syscall(sys_mlock2);
 cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
+cond_syscall(sys_madvisev);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
 cond_syscall(compat_sys_move_pages);
diff --git a/mm/madvise.c b/mm/madvise.c
index f56825b..9e6b94fd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -21,7 +21,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
-
+#include <linux/uio.h>
 #include <asm/tlb.h>
 
 /*
@@ -564,7 +564,8 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+		unsigned long start, unsigned long end, int behavior,
+		void *data)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
@@ -616,6 +617,62 @@ madvise_behavior_valid(int behavior)
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
@@ -660,8 +717,7 @@ madvise_behavior_valid(int behavior)
  */
 SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 {
-	unsigned long end, tmp;
-	struct vm_area_struct *vma, *prev;
+	unsigned long end;
 	int unmapped_error = 0;
 	int error = -EINVAL;
 	int write;
@@ -697,51 +753,13 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
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
-
-		/* Here start < (end|vma->vm_end). */
-		if (start < vma->vm_start) {
-			unmapped_error = -ENOMEM;
-			start = vma->vm_start;
-			if (start >= end)
-				goto out;
-		}
 
-		/* Here vma->vm_start <= start < (end|vma->vm_end) */
-		tmp = vma->vm_end;
-		if (end < tmp)
-			tmp = end;
-
-		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
-		if (error)
-			goto out;
-		start = tmp;
-		if (prev && start < prev->vm_end)
-			start = prev->vm_end;
+	error = madvise_iterate_vma(start, end, &unmapped_error,
+			behavior, madvise_vma, NULL);
+	if (error == 0 && unmapped_error != 0)
 		error = unmapped_error;
-		if (start >= end)
-			goto out;
-		if (prev)
-			vma = prev->vm_next;
-		else	/* madvise_remove dropped mmap_sem */
-			vma = find_vma(current->mm, start);
-	}
-out:
+
 	blk_finish_plug(&plug);
 	if (write)
 		up_write(&current->mm->mmap_sem);
@@ -750,3 +768,117 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 
 	return error;
 }
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
+		}
+		/* passthrough */
+	case MADV_DONTNEED:
+		unmap_vmas(tlb, vma, start, end);
+		break;
+	}
+	return 0;
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
+	unsigned long start, end = 0;
+	int unmapped_error = 0;
+	size_t len;
+	struct mmu_gather tlb;
+	int error;
+	int i;
+
+	if (behavior != MADV_DONTNEED && behavior != MADV_FREE)
+		return -EINVAL;
+
+	error = rw_copy_check_uvector(CHECK_IOVEC_ONLY, uvector, nr_segs,
+			UIO_FASTIOV, iovstack, &iov);
+	if (error <= 0)
+		goto out;
+
+	for (i = 0; i < nr_segs; i++) {
+		start = (unsigned long)iov[i].iov_base;
+		/* Make sure iovs don't overlap and sorted */
+		if (start & ~PAGE_MASK || start < end) {
+			error = -EINVAL;
+			goto out;
+		}
+		len = ((iov[i].iov_len + ~PAGE_MASK) & PAGE_MASK);
+
+		/*
+		 * Check to see whether len was rounded up from small -ve to
+		 * zero
+		 */
+		if (iov[i].iov_len && !len) {
+			error = -EINVAL;
+			goto out;
+		}
+
+		end = start + len;
+
+		/*
+		 * end == start returns error (different against madvise).
+		 * return 0 is improper as there are other iovs
+		 */
+		if (end <= start) {
+			error = -EINVAL;
+			goto out;
+		}
+
+		iov[i].iov_len = len;
+	}
+
+	down_read(&current->mm->mmap_sem);
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, current->mm, (unsigned long)iov[0].iov_base,
+		end);
+	update_hiwater_rss(current->mm);
+	for (i = 0; i < nr_segs; i++) {
+		start = (unsigned long)iov[i].iov_base;
+		len = iov[i].iov_len;
+
+		error = madvise_iterate_vma(start, start + len,
+			&unmapped_error, behavior, madvisev_vma, &tlb);
+		if (error)
+			break;
+	}
+	tlb_finish_mmu(&tlb, (unsigned long)iov[0].iov_base, end);
+
+	if (error == 0 && unmapped_error != 0)
+		error = unmapped_error;
+
+	up_read(&current->mm->mmap_sem);
+out:
+	if (iov != iovstack)
+		kfree(iov);
+	return error;
+}
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
