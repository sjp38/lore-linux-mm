Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E95C36B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 14:44:59 -0500 (EST)
Received: by wmec201 with SMTP id c201so98433222wme.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 11:44:59 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v2si6235181wje.143.2015.11.09.11.44.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 11:44:58 -0800 (PST)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tA9JgpR9010756
	for <linux-mm@kvack.org>; Mon, 9 Nov 2015 11:44:57 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 1y1t425mwy-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Nov 2015 11:44:57 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 59cd37dc871a11e58fd124be0593f280-103f5230 for <linux-mm@kvack.org>;	Mon, 09
 Nov 2015 11:44:55 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V2] mm: add a new vector based madvise syscall
Date: Mon, 9 Nov 2015 11:44:54 -0800
Message-ID: <c25b90749f9212359a085125f6403f4c148dfde0.1447098139.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org, je@fb.com, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>

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

Current implementation only supports MADV_DONTNEED. Should be trival to
support MADV_FREE if necessary later.

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
 6 files changed, 188 insertions(+), 46 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index f17705e..8a63800 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -383,3 +383,4 @@
 374	i386	userfaultfd		sys_userfaultfd
 375	i386	membarrier		sys_membarrier
 376	i386	mlock2			sys_mlock2
+377	i386	madvisev		sys_madvisev
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 314a90b..a0b5618 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -332,6 +332,7 @@
 323	common	userfaultfd		sys_userfaultfd
 324	common	membarrier		sys_membarrier
 325	common	mlock2			sys_mlock2
+326	common	madvisev		sys_madvisev
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a156b82..9ebf15e 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -889,4 +889,7 @@ asmlinkage long sys_membarrier(int cmd, int flags);
 
 asmlinkage long sys_mlock2(unsigned long start, size_t len, int flags);
 
+asmlinkage long sys_madvisev(const struct iovec __user *uvector,
+		unsigned long nr_segs, int behavior);
+
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 1324b02..a7cdb9a 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -715,9 +715,11 @@ __SYSCALL(__NR_userfaultfd, sys_userfaultfd)
 __SYSCALL(__NR_membarrier, sys_membarrier)
 #define __NR_mlock2 284
 __SYSCALL(__NR_mlock2, sys_mlock2)
+#define __NR_madvisev 285
+__SYSCALL(__NR_madvisev, sys_madvisev)
 
 #undef __NR_syscalls
-#define __NR_syscalls 285
+#define __NR_syscalls 286
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 0623787..45404c5 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -197,6 +197,7 @@ cond_syscall(sys_munlockall);
 cond_syscall(sys_mlock2);
 cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
+cond_syscall(sys_madvisev);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
 cond_syscall(compat_sys_move_pages);
diff --git a/mm/madvise.c b/mm/madvise.c
index c889fcb..765350c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -20,6 +20,9 @@
 #include <linux/backing-dev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/uio.h>
+#include <linux/sort.h>
+#include <asm/tlb.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -372,7 +375,8 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+		unsigned long start, unsigned long end, int behavior,
+		void *data)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
@@ -415,6 +419,62 @@ madvise_behavior_valid(int behavior)
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
@@ -459,8 +519,7 @@ madvise_behavior_valid(int behavior)
  */
 SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 {
-	unsigned long end, tmp;
-	struct vm_area_struct *vma, *prev;
+	unsigned long end;
 	int unmapped_error = 0;
 	int error = -EINVAL;
 	int write;
@@ -496,51 +555,13 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
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
-
-		/* Here vma->vm_start <= start < (end|vma->vm_end) */
-		tmp = vma->vm_end;
-		if (end < tmp)
-			tmp = end;
 
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
@@ -549,3 +570,116 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 
 	return error;
 }
+
+static int iov_cmp_func(const void *a, const void *b)
+{
+	const struct iovec *iova = a;
+	const struct iovec *iovb = b;
+	unsigned long addr_a = (unsigned long)iova->iov_base;
+	unsigned long addr_b = (unsigned long)iovb->iov_base;
+
+	if (addr_a > addr_b)
+		return 1;
+	if (addr_a < addr_b)
+		return -1;
+	return 0;
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
+	unmap_vmas(tlb, vma, start, end);
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
+	if (behavior != MADV_DONTNEED)
+		return -EINVAL;
+
+	error = rw_copy_check_uvector(CHECK_IOVEC_ONLY, uvector, nr_segs,
+			UIO_FASTIOV, iovstack, &iov);
+	if (error <= 0)
+		goto out;
+	/* Make sure address in ascend order */
+	sort(iov, nr_segs, sizeof(struct iovec), iov_cmp_func, NULL);
+
+	for (i = 0; i < nr_segs; i++) {
+		start = (unsigned long)iov[i].iov_base;
+		/* Make sure iovs don't overlap */
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
