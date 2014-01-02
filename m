Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1166B0039
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:15 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so13823823pde.14
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:14 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gm1si15344151pac.100.2014.01.01.23.13.12
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:14 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 04/16] vrange: Add new vrange(2) system call
Date: Thu,  2 Jan 2014 16:12:12 +0900
Message-Id: <1388646744-15608-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch adds new system call sys_vrange.

NAME
	vrange - Mark or unmark range of memory as volatile

SYNOPSIS
	int vrange(unsigned_long start, size_t length, int mode,
			 int *purged);

DESCRIPTION
	Applications can use vrange(2) to advise the kernel how it should
	handle paging I/O in this VM area.  The idea is to help the kernel
	discard pages of vrange instead of reclaiming when memory pressure
	happens. It means kernel doesn't discard any pages of vrange if
	there is no memory pressure.

	mode:
	VRANGE_VOLATILE
		hint to kernel so VM can discard in vrange pages when
		memory pressure happens.
	VRANGE_NONVOLATILE
		hint to kernel so VM doesn't discard vrange pages
		any more.

	If user try to access purged memory without VRANGE_NOVOLATILE call,
	he can encounter SIGBUS if the page was discarded by kernel.

	purged: Pointer to an integer which will return 1 if
	mode == VRANGE_NONVOLATILE and any page in the affected range
	was purged. If purged returns zero during a mode ==
	VRANGE_NONVOLATILE call, it means all of the pages in the range
	are intact.

RETURN VALUE
	On success vrange returns the number of bytes marked or unmarked.
	Similar to write(), it may return fewer bytes then specified
	if it ran into a problem.

	If an error is returned, no changes were made.

ERRORS
	EINVAL This error can occur for the following reasons:
		* The value length is negative or not page size units.
		* addr is not page-aligned
		* mode not a valid value.

	ENOMEM Not enough memory

	EFAULT purged pointer is invalid

There were some comment about this interface.
Firstly, it was suggested by part of madvise(2) but there were some reason
to make it hard.

o Why is it hard to make it based on madvise(2) and vm_area_struct?

The madvise syscall logic is based on vma split/merging but vrange
syscall want to avoid it because it requires mmap_sem which is very
coarse-graind lock and it is critical for multi-threaded friendly
userspace allocator and vma split/merge could create lots of
vm_area_struct because we don't want to merge adjacent volatile
ranges so that we would support fine-grained purging without
propagating purging into another volatile ranges.
For exmaple, firefox folks want to make volatile range as page unit
so if we create vm_area_struct per PAGE_SIZE range,
memory footprint will be much bigger.

Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rob Clark <robdclark@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 arch/x86/syscalls/syscall_64.tbl       |    1 +
 include/linux/syscalls.h               |    2 +
 include/uapi/asm-generic/mman-common.h |    3 +
 kernel/sys_ni.c                        |    1 +
 mm/vrange.c                            |  164 ++++++++++++++++++++++++++++++++
 5 files changed, 171 insertions(+)

diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 38ae65dfd14f..dc332bdc3514 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -320,6 +320,7 @@
 311	64	process_vm_writev	sys_process_vm_writev
 312	common	kcmp			sys_kcmp
 313	common	finit_module		sys_finit_module
+314	common	vrange			sys_vrange
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 7fac04e7ff6e..2c56f954effe 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -847,4 +847,6 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
 asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
 			 unsigned long idx1, unsigned long idx2);
 asmlinkage long sys_finit_module(int fd, const char __user *uargs, int flags);
+asmlinkage long sys_vrange(unsigned long start, size_t len, int mode,
+		int __user *purged);
 #endif
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 4164529a94f9..9be120b3b33f 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -66,4 +66,7 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define VRANGE_VOLATILE		0	/* unpin pages so VM can discard them */
+#define VRANGE_NONVOLATILE	1	/* pin pages so VM can't discard them */
+
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 7078052284fd..f40070eff8a1 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -175,6 +175,7 @@ cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
 cond_syscall(compat_sys_move_pages);
 cond_syscall(compat_sys_migrate_pages);
+cond_syscall(sys_vrange);
 
 /* block-layer dependent */
 cond_syscall(sys_bdflush);
diff --git a/mm/vrange.c b/mm/vrange.c
index 444da8794dbf..9ed5610b2e54 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -4,6 +4,8 @@
 
 #include <linux/vrange.h>
 #include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/mman.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -230,3 +232,165 @@ fail:
 	vrange_root_cleanup(new);
 	return -ENOMEM;
 }
+
+static inline struct vrange_root *__vma_to_vroot(struct vm_area_struct *vma)
+{
+	struct vrange_root *vroot = NULL;
+
+	if (vma->vm_file && (vma->vm_flags & VM_SHARED))
+		vroot = &vma->vm_file->f_mapping->vroot;
+	else
+		vroot = &vma->vm_mm->vroot;
+	return vroot;
+}
+
+static inline unsigned long __vma_addr_to_index(struct vm_area_struct *vma,
+							unsigned long addr)
+{
+	if (vma->vm_file && (vma->vm_flags & VM_SHARED))
+		return (vma->vm_pgoff << PAGE_SHIFT) + addr - vma->vm_start;
+	return addr;
+}
+
+static ssize_t do_vrange(struct mm_struct *mm, unsigned long start_idx,
+				unsigned long end_idx, int mode, int *purged)
+{
+	struct vm_area_struct *vma;
+	unsigned long orig_start = start_idx;
+	ssize_t count = 0, ret = 0;
+
+	down_read(&mm->mmap_sem);
+
+	vma = find_vma(mm, start_idx);
+	for (;;) {
+		struct vrange_root *vroot;
+		unsigned long tmp, vstart_idx, vend_idx;
+
+		if (!vma)
+			goto out;
+
+		if (vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
+					VM_HUGETLB))
+			goto out;
+
+		/* make sure start is at the front of the current vma*/
+		if (start_idx < vma->vm_start) {
+			start_idx = vma->vm_start;
+			if (start_idx > end_idx)
+				goto out;
+		}
+
+		/* bound tmp to closer of vm_end & end */
+		tmp = vma->vm_end - 1;
+		if (end_idx < tmp)
+			tmp = end_idx;
+
+		vroot = __vma_to_vroot(vma);
+		vstart_idx = __vma_addr_to_index(vma, start_idx);
+		vend_idx = __vma_addr_to_index(vma, tmp);
+
+		/* mark or unmark */
+		if (mode == VRANGE_VOLATILE)
+			ret = vrange_add(vroot, vstart_idx, vend_idx);
+		else if (mode == VRANGE_NONVOLATILE)
+			ret = vrange_remove(vroot, vstart_idx, vend_idx,
+						purged);
+
+		if (ret)
+			goto out;
+
+		/* update count to distance covered so far*/
+		count = tmp - orig_start + 1;
+
+		/* move start up to the end of the vma*/
+		start_idx = vma->vm_end;
+		if (start_idx > end_idx)
+			goto out;
+		/* move to the next vma */
+		vma = vma->vm_next;
+	}
+out:
+	up_read(&mm->mmap_sem);
+
+	/* report bytes successfully marked, even if we're exiting on error */
+	if (count)
+		return count;
+
+	return ret;
+}
+
+/*
+ * The vrange(2) system call.
+ *
+ * Applications can use vrange() to advise the kernel how it should
+ * handle paging I/O in this VM area.  The idea is to help the kernel
+ * discard pages of vrange instead of swapping out when memory pressure
+ * happens. The information provided is advisory only, and can be safely
+ * disregarded by the kernel if system has enough free memory.
+ *
+ * mode values:
+ *  VRANGE_VOLATILE - hint to kernel so VM can discard vrange pages when
+ *		memory pressure happens.
+ *  VRANGE_NONVOLATILE - Removes any volatile hints previous specified in that
+ *		range.
+ *
+ * purged ptr:
+ *  Returns 1 if any page in the range being marked nonvolatile has been purged.
+ *
+ * Return values:
+ *  On success vrange returns the number of bytes marked or unmarked.
+ *  Similar to write(), it may return fewer bytes then specified if
+ *  it ran into a problem.
+ *
+ *  If an error is returned, no changes were made.
+ *
+ * Errors:
+ *  -EINVAL - start  len < 0, start is not page-aligned, start is greater
+ *		than TASK_SIZE or "mode" is not a valid value.
+ *  -ENOMEM - Short of free memory in system for successful system call.
+ *  -EFAULT - Purged pointer is invalid.
+ *  -ENOSUP - Feature not yet supported.
+ */
+SYSCALL_DEFINE4(vrange, unsigned long, start,
+		size_t, len, int, mode, int __user *, purged)
+{
+	unsigned long end;
+	struct mm_struct *mm = current->mm;
+	ssize_t ret = -EINVAL;
+	int p = 0;
+
+	if (start & ~PAGE_MASK)
+		goto out;
+
+	len &= PAGE_MASK;
+	if (!len)
+		goto out;
+
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	if (start >= TASK_SIZE)
+		goto out;
+
+	if (purged) {
+		/* Test pointer is valid before making any changes */
+		if (put_user(p, purged))
+			return -EFAULT;
+	}
+
+	ret = do_vrange(mm, start, end - 1, mode, &p);
+
+	if (purged) {
+		if (put_user(p, purged)) {
+			/*
+			 * This would be bad, since we've modified volatilty
+			 * and the change in purged state would be lost.
+			 */
+			BUG();
+		}
+	}
+
+out:
+	return ret;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
