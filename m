Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 771216B005A
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 16:15:57 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so5865522pbc.9
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:15:57 -0700 (PDT)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
        by mx.google.com with ESMTPS id ha5si4854755pbc.172.2014.04.11.13.15.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 13:15:56 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so5830898pad.16
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:15:56 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 2/4] mvolatile: Add mvolatile syscall and handle splitting/merging and marking vmas
Date: Fri, 11 Apr 2014 13:15:38 -0700
Message-Id: <1397247340-3365-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1397247340-3365-1-git-send-email-john.stultz@linaro.org>
References: <1397247340-3365-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This patch introduces the mvolatile() syscall, which allows for specifying
ranges of memory as volatile, and able to be discarded by the system.

This initial patch simply adds the syscall, and the vma handling,
splitting and merging the vmas as needed, and marking them with
VM_VOLATILE.

No purging or discarding of volatile ranges is done at this point.

Example man page:

NAME
	mvolatile - Mark or unmark range of memory as volatile

SYNOPSIS
	ssize_t mvolatile(unsigned_long start, size_t length,
			 unsigned_long mode, unsigned_long flags,
			 int *purged);

DESCRIPTION
	Applications can use mvolatile(2) to advise kernel that pages of
	anonymous mapping in the given VM area can be reclaimed without
	swapping (or can no longer be reclaimed without swapping).
	The idea is that application can help kernel with page reclaim
	under memory pressure by specifying data it can easily regenerate
	and thus kernel can discard the data if needed.

	mode:
	MVOLATILE_VOLATILE
		Informs the kernel that the VM can discard in pages in
		the specified range when under memory pressure.
	MVOLATILE_NONVOLATILE
		Informs the kernel that the VM can no longer discard pages
		in this range.

	flags: Currently no flags are supported.

	purged: Pointer to an integer which will return 1 if
	mode == MVOLATILE_NONVOLATILE and any page in the affected range
	was purged. If purged returns zero during a mode ==
	MVOLATILE_NONVOLATILE call, it means all of the pages in the range
	are intact.

	If a process accesses volatile memory which has been purged, and
	was not set as non volatile via a MVOLATILE_NONVOLATILE call, it
	will recieve a SIGBUS.

RETURN VALUE
	On success mvolatile returns the number of bytes marked or unmarked.

	Similar to write(), it may return fewer bytes then specified
	if it ran into a problem.

	When using MVOLATILE_NONVOLATILE, if the return value is smaller
	than the specified length, then the value returned in the purged
	pointer only reflects the purged state of the successfully marked
	non-volatile pages.

	If an error is returned, no changes were made.

ERRORS
	EINVAL This error can occur for the following reasons:
		* The value length is negative or not page size units.
		* addr is not page-aligned
		* mode not a valid value.
		* flags is not a valid value.

	ENOMEM Not enough memory

	ENOMEM Addresses in the specified range are not currently mapped,
	       or are outside the address space of the process.

	EFAULT Purged pointer is invalid

This a simplified implementation which reuses some of the logic
from Minchan's earlier efforts. So credit to Minchan for his work.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Keith Packard <keithp@keithp.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 arch/x86/syscalls/syscall_64.tbl |   1 +
 include/linux/mm.h               |   1 +
 include/linux/mvolatile.h        |   8 ++
 include/uapi/linux/mvolatile.h   |   7 ++
 mm/Makefile                      |   2 +-
 mm/mvolatile.c                   | 195 +++++++++++++++++++++++++++++++++++++++
 6 files changed, 213 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/mvolatile.h
 create mode 100644 include/uapi/linux/mvolatile.h
 create mode 100644 mm/mvolatile.c

diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index a12bddc..6fa2087 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -322,6 +322,7 @@
 313	common	finit_module		sys_finit_module
 314	common	sched_setattr		sys_sched_setattr
 315	common	sched_getattr		sys_sched_getattr
+316	common	mvolatile		sys_mvolatile
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1b7414..a1f11da 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -117,6 +117,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
 					/* Used by sys_madvise() */
+#define VM_VOLATILE	0x00001000	/* VMA is volatile */
 #define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
 #define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
 
diff --git a/include/linux/mvolatile.h b/include/linux/mvolatile.h
new file mode 100644
index 0000000..973bb3b
--- /dev/null
+++ b/include/linux/mvolatile.h
@@ -0,0 +1,8 @@
+#ifndef _LINUX_MVOLATILE_H
+#define _LINUX_MVOLATILE_H
+
+#include <uapi/linux/mvolatile.h>
+
+#define MVOLATILE_VALID_FLAGS (0) /* Don't yet support any flags */
+
+#endif /* _LINUX_MVOLATILE_H */
diff --git a/include/uapi/linux/mvolatile.h b/include/uapi/linux/mvolatile.h
new file mode 100644
index 0000000..1e92f3f
--- /dev/null
+++ b/include/uapi/linux/mvolatile.h
@@ -0,0 +1,7 @@
+#ifndef _UAPI_LINUX_MVOLATILE_H
+#define _UAPI_LINUX_MVOLATILE_H
+
+#define MVOLATILE_NONVOLATILE 0
+#define MVOLATILE_VOLATILE 1
+
+#endif /* _UAPI_LINUX_MVOLATILE_H */
diff --git a/mm/Makefile b/mm/Makefile
index 310c90a..76a3444 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o balloon_compaction.o \
+			   compaction.o balloon_compaction.o mvolatile.o \
 			   interval_tree.o list_lru.o $(mmu-y)
 
 obj-y += init-mm.o
diff --git a/mm/mvolatile.c b/mm/mvolatile.c
new file mode 100644
index 0000000..d4d2eed
--- /dev/null
+++ b/mm/mvolatile.c
@@ -0,0 +1,195 @@
+/*
+ * mm/mvolatile.c
+ *
+ * Copyright (C) 2014, LG Electronics, Minchan Kim <minchan@kernel.org>
+ * Copyright (C) 2014 Linaro Ltd., John Stultz <john.stultz@linaro.org>
+ */
+#include <linux/syscalls.h>
+#include <linux/mvolatile.h>
+#include <linux/mm_inline.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/hugetlb.h>
+#include <linux/mmu_notifier.h>
+#include <linux/mm_inline.h>
+#include "internal.h"
+
+
+/**
+ * do_mvolatile - Marks or clears VMAs in the range (start-end) as VM_VOLATILE
+ * @mm: mm_struct we're working on
+ * @start: starting address of the volatile range
+ * @end: ending address of the volatile range
+ * @mode: the mode of the volatile range (volatile or non-volatile)
+ * @flags: any additonal flags arguments (ignored for now, as there are none)
+ * @purged: pointer to integer value that is set to 1 if any pages in a range
+ * being set non-volatile have been purged.
+ *
+ * Core logic of sys_volatile. Iterates over the VMAs in the specified
+ * range, and marks or clears them as VM_VOLATILE, splitting or merging them
+ * as needed.
+ *
+ * Returns the number of bytes successfully modified.
+ *
+ * Returns error only if no bytes were modified.
+ */
+static ssize_t do_mvolatile(struct mm_struct *mm, unsigned long start,
+				unsigned long end, unsigned long mode,
+				unsigned long flags, int *purged)
+{
+	struct vm_area_struct *vma, *prev;
+	unsigned long orig_start = start;
+	ssize_t count = 0, ret = 0;
+
+	down_write(&mm->mmap_sem);
+
+	vma = find_vma_prev(mm, start, &prev);
+	if (vma && start > vma->vm_start)
+		prev = vma;
+
+	for (;;) {
+		unsigned long new_flags;
+		pgoff_t pgoff;
+		unsigned long tmp;
+
+		if (!vma)
+			goto out;
+
+		if (vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
+					VM_HUGETLB))
+			goto out;
+
+		/* We don't support volatility on files for now */
+		if (vma->vm_file) {
+			ret = -EINVAL;
+			goto out;
+		}
+
+		/* return ENOMEM if we're trying to mark unmapped pages */
+		if (start < vma->vm_start) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		new_flags = vma->vm_flags;
+
+		tmp = vma->vm_end;
+		if (end < tmp)
+			tmp = end;
+
+		switch (mode) {
+		case MVOLATILE_VOLATILE:
+			new_flags |= VM_VOLATILE;
+			break;
+		case MVOLATILE_NONVOLATILE:
+			new_flags &= ~VM_VOLATILE;
+		}
+
+		pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+		prev = vma_merge(mm, prev, start, tmp, new_flags,
+					vma->anon_vma, vma->vm_file, pgoff,
+					vma_policy(vma));
+		if (prev)
+			goto success;
+
+		if (start != vma->vm_start) {
+			ret = split_vma(mm, vma, start, 1);
+			if (ret)
+				goto out;
+		}
+
+		if (tmp != vma->vm_end) {
+			ret = split_vma(mm, vma, tmp, 0);
+			if (ret)
+				goto out;
+		}
+
+		prev = vma;
+success:
+		vma->vm_flags = new_flags;
+
+		/* update count to distance covered so far*/
+		count = tmp - orig_start;
+
+		start = tmp;
+		if (start < prev->vm_end)
+			start = prev->vm_end;
+		if (start >= end)
+			goto out;
+		vma = prev->vm_next;
+	}
+out:
+	up_write(&mm->mmap_sem);
+
+	/* report bytes successfully marked, even if we're exiting on error */
+	if (count)
+		return count;
+
+	return ret;
+}
+
+
+/**
+ * sys_mvolatile - Marks specified range as volatile or non-volatile.
+ * @start: starting address of the range
+ * @len: size of the range being requested
+ * @mode: the mode of the range (volatile or non-volatile)
+ * @flags: any additonal flags arguments (ignored for now, as there are none)
+ * @purged: pointer to integer value that is set to 1 if any pages in a range
+ * being set non-volatile have been purged.
+ *
+ * Validates the syscall inputs and calls do_mvolatile(), then copies the
+ * purged flag back out to userspace.
+ *
+ * Returns the number of bytes successfully modified.
+ * Returns error only if no bytes were modified.
+ */
+SYSCALL_DEFINE5(mvolatile, unsigned long, start, size_t, len,
+				unsigned long, mode, unsigned long, flags,
+				int __user *, purged)
+{
+	unsigned long end;
+	struct mm_struct *mm = current->mm;
+	ssize_t ret = -EINVAL;
+	int p = 0;
+
+	if (flags & ~MVOLATILE_VALID_FLAGS)
+		goto out;
+
+	if (start & ~PAGE_MASK)
+		goto out;
+
+	if (len & ~PAGE_MASK)
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
+	ret = do_mvolatile(mm, start, end, mode, flags, &p);
+
+	if (purged) {
+		if (put_user(p, purged)) {
+			/*
+			 * This would be bad, since we've modified volatilty
+			 * and the change in purged state would be lost.
+			 * But the application is doing something dumb here,
+			 * so just return EFAULT and be ok with losing the
+			 * state.
+			 */
+			return -EFAULT;
+		}
+	}
+
+out:
+	return ret;
+}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
