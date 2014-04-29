Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 230A76B003B
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 17:21:40 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kq14so829490pab.22
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:21:39 -0700 (PDT)
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
        by mx.google.com with ESMTPS id ke1si14280980pad.378.2014.04.29.14.21.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 14:21:39 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so823551pab.26
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:21:38 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 2/4] MADV_VOLATILE: Add MADV_VOLATILE/NONVOLATILE hooks and handle marking vmas
Date: Tue, 29 Apr 2014 14:21:21 -0700
Message-Id: <1398806483-19122-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This patch introduces MADV_VOLATILE/NONVOLATILE flags to madvise(),
which allows for specifying ranges of memory as volatile, and able
to be discarded by the system.

This initial patch simply adds flag handling to madvise, and the
vma handling, splitting and merging the vmas as needed, and marking
them with VM_VOLATILE.

No purging or discarding of volatile ranges is done at this point.

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
 include/linux/mm.h                     |   1 +
 include/linux/mvolatile.h              |   6 ++
 include/uapi/asm-generic/mman-common.h |   5 ++
 mm/Makefile                            |   2 +-
 mm/madvise.c                           |  14 ++++
 mm/mvolatile.c                         | 147 +++++++++++++++++++++++++++++++++
 6 files changed, 174 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/mvolatile.h
 create mode 100644 mm/mvolatile.c

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf9811e..ea8b687 100644
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
index 0000000..f53396b
--- /dev/null
+++ b/include/linux/mvolatile.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_MVOLATILE_H
+#define _LINUX_MVOLATILE_H
+
+int madvise_volatile(int bhv, unsigned long start, unsigned long end);
+
+#endif /* _LINUX_MVOLATILE_H */
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index ddc3b36..b74d61d 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -39,6 +39,7 @@
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
+
 #define MADV_HWPOISON	100		/* poison a page for testing */
 #define MADV_SOFT_OFFLINE 101		/* soft offline page for testing */
 
@@ -52,6 +53,10 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_DONTDUMP flag */
 
+#define MADV_VOLATILE	18		/* Mark pages as volatile */
+#define MADV_NONVOLATILE 19		/* Mark pages non-volatile, return 1
+					   if any pages were purged  */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/Makefile b/mm/Makefile
index b484452..9a3dc62 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -18,7 +18,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o balloon_compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   iov_iter.o $(mmu-y)
+			   mvolatile.o iov_iter.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb9..937c026 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -19,6 +19,7 @@
 #include <linux/blkdev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mvolatile.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -413,6 +414,8 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_VOLATILE:
+	case MADV_NONVOLATILE:
 		return 1;
 
 	default:
@@ -450,9 +453,14 @@ madvise_behavior_valid(int behavior)
  *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
  *		this area with pages of identical content from other such areas.
  *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
+ *  MADV_VOLATILE - Mark pages as volatile, allowing kernel to purge them under
+ *		pressure.
+ *  MADV_NONVOLATILE - Mark pages as non-volatile. Report if pages were purged.
  *
  * return values:
  *  zero    - success
+ *  1       - (MADV_NONVOLATILE only) some pages marked non-volatile were
+ *            purged.
  *  -EINVAL - start + len < 0, start is not page-aligned,
  *		"behavior" is not a valid value, or application
  *		is attempting to release locked or shared pages.
@@ -478,6 +486,12 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 #endif
 	if (!madvise_behavior_valid(behavior))
 		return error;
+	/*
+	 * MADV_VOLATILE/NONVOLATILE has subtle semantics that requrie
+	 * we don't use the generic per-vma manipulation below.
+	 */
+	if (behavior == MADV_VOLATILE || behavior == MADV_NONVOLATILE)
+		return madvise_volatile(behavior, start, start+len_in);
 
 	if (start & ~PAGE_MASK)
 		return error;
diff --git a/mm/mvolatile.c b/mm/mvolatile.c
new file mode 100644
index 0000000..edc5894
--- /dev/null
+++ b/mm/mvolatile.c
@@ -0,0 +1,147 @@
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
+#include <linux/mman.h>
+#include "internal.h"
+
+
+/**
+ * madvise_volatile - Marks or clears VMAs in the range (start-end) as VM_VOLATILE
+ * @mode: the mode of the volatile range (volatile or non-volatile)
+ * @start: starting address of the volatile range
+ * @end: ending address of the volatile range
+ *
+ * Iterates over the VMAs in the specified range, and marks or clears
+ * them as VM_VOLATILE, splitting or merging them as needed.
+ *
+ * Returns 0 on success
+ * Returns 1 if any pages being marked were purged (MADV_NONVOLATILE only)
+ * Returns error only if no bytes were modified.
+ */
+int madvise_volatile(int mode, unsigned long start, unsigned long end)
+{
+	struct vm_area_struct *vma, *prev;
+	struct mm_struct *mm = current->mm;
+	unsigned long orig_start = start;
+	int ret = 0;
+
+	/* Bit of sanity checking */
+	if ((mode != MADV_VOLATILE) && (mode != MADV_NONVOLATILE))
+		return -EINVAL;
+	if (start & ~PAGE_MASK)
+		return -EINVAL;
+	if (end & ~PAGE_MASK)
+		return -EINVAL;
+	if (end < start)
+		return -EINVAL;
+	if (start >= TASK_SIZE)
+		return -EINVAL;
+
+
+	down_write(&mm->mmap_sem);
+	/*
+	 * First, iterate ovver the VMAs and make sure
+	 * there are no holes or file vmas which would result
+	 * in -EINVAL.
+	 */
+	vma = find_vma(mm, start);
+	if (!vma) {
+		/* return ENOMEM if we're trying to mark unmapped pages */
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	while (vma) {
+		if (vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
+					VM_HUGETLB)) {
+			ret = -EINVAL;
+			goto out;
+		}
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
+		start = vma->vm_end;
+		if (start >= end)
+			break;
+		vma = vma->vm_next;
+	}
+
+	/*
+	 * Second, do VMA splitting. Note: If either of these
+	 * fail, we'll make no modifications to the vm_flags,
+	 * and will merge back together any unmodified split
+	 * vmas
+	 */
+	start = orig_start;
+	vma = find_vma(mm, start);
+	if (start != vma->vm_start)
+		ret = split_vma(mm, vma, start, 1);
+
+	vma = find_vma(mm, end-1);
+	/* only need to split if end addr is not at the beginning of the vma */
+	if (!ret && (end != vma->vm_end))
+		ret = split_vma(mm, vma, end, 0);
+
+	/*
+	 * Third, if splitting was successful modify vm_flags.
+	 * We also will do any vma merging that is needed at
+	 * this point.
+	 */
+	start = orig_start;
+	vma = find_vma_prev(mm, start, &prev);
+	if (vma && start > vma->vm_start)
+		prev = vma;
+
+	while (vma) {
+		unsigned long new_flags;
+		pgoff_t pgoff;
+
+		new_flags = vma->vm_flags;
+		if (!ret) {
+			if (mode == MADV_VOLATILE)
+				new_flags |= VM_VOLATILE;
+			else /* mode == MADV_NONVOLATILE */
+				new_flags &= ~VM_VOLATILE;
+		}
+		pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+		prev = vma_merge(mm, prev, start, vma->vm_end, new_flags,
+					vma->anon_vma, vma->vm_file, pgoff,
+					vma_policy(vma));
+		if (!prev)
+			prev = vma;
+		else
+			vma = prev;
+
+		vma->vm_flags = new_flags;
+
+		start = vma->vm_end;
+		if (start >= end)
+			break;
+		vma = vma->vm_next;
+	}
+out:
+	up_write(&mm->mmap_sem);
+
+	return ret;
+}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
