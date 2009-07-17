Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 02DC66B005C
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 13:27:19 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 04/10] ksm: the mm interface to ksm
Date: Fri, 17 Jul 2009 20:30:44 +0300
Message-Id: <1247851850-4298-5-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-4-git-send-email-ieidus@redhat.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ieidus@redhat.com, Michael Kerrisk <mtk.manpages@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh.dickins@tiscali.co.uk>

This patch presents the mm interface to a dummy version of ksm.c,
for better scrutiny of that interface: the real ksm.c follows later.

When CONFIG_KSM is not set, madvise(2) reject MADV_MERGEABLE and
MADV_UNMERGEABLE with EINVAL, since that seems more helpful than
pretending that they can be serviced.  But when CONFIG_KSM=y, accept
them even if KSM is not currently running, and even on areas which KSM
will not touch (e.g. hugetlb or shared file or special driver mappings).

Like other madvices, report ENOMEM despite success if any area in the
range is unmapped, and use EAGAIN to report out of memory.

Define vma flag VM_MERGEABLE to identify an area on which KSM may try
merging pages: leave it to ksm_madvise() to decide whether to set it.
Define mm flag MMF_VM_MERGEABLE to identify an mm which might contain
VM_MERGEABLE areas, to minimize callouts when forking or exiting.

Based upon earlier patches by Chris Wright and Izik Eidus.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Chris Wright <chrisw@redhat.com>
Signed-off-by: Izik Eidus <ieidus@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
---
 include/linux/ksm.h   |   50 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h    |    1 +
 include/linux/sched.h |    7 ++++++
 kernel/fork.c         |    8 ++++++-
 mm/Kconfig            |   11 +++++++++
 mm/Makefile           |    1 +
 mm/ksm.c              |   56 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/madvise.c          |   14 ++++++++++++
 8 files changed, 147 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/ksm.h
 create mode 100644 mm/ksm.c

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
new file mode 100644
index 0000000..eb2a448
--- /dev/null
+++ b/include/linux/ksm.h
@@ -0,0 +1,50 @@
+#ifndef __LINUX_KSM_H
+#define __LINUX_KSM_H
+/*
+ * Memory merging support.
+ *
+ * This code enables dynamic sharing of identical pages found in different
+ * memory areas, even if they are not shared by fork().
+ */
+
+#include <linux/bitops.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+
+#ifdef CONFIG_KSM
+int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, int advice, unsigned long *vm_flags);
+int __ksm_enter(struct mm_struct *mm);
+void __ksm_exit(struct mm_struct *mm);
+
+static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
+{
+	if (test_bit(MMF_VM_MERGEABLE, &oldmm->flags))
+		return __ksm_enter(mm);
+	return 0;
+}
+
+static inline void ksm_exit(struct mm_struct *mm)
+{
+	if (test_bit(MMF_VM_MERGEABLE, &mm->flags))
+		__ksm_exit(mm);
+}
+#else  /* !CONFIG_KSM */
+
+static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, int advice, unsigned long *vm_flags)
+{
+	return 0;
+}
+
+static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
+{
+	return 0;
+}
+
+static inline void ksm_exit(struct mm_struct *mm)
+{
+}
+#endif /* !CONFIG_KSM */
+
+#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ba3a7cb..fefc98a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -105,6 +105,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
+#define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 16a982e..8ed6395 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -431,7 +431,9 @@ extern int get_dumpable(struct mm_struct *mm);
 /* dumpable bits */
 #define MMF_DUMPABLE      0  /* core dump is permitted */
 #define MMF_DUMP_SECURELY 1  /* core file is readable only by root */
+
 #define MMF_DUMPABLE_BITS 2
+#define MMF_DUMPABLE_MASK ((1 << MMF_DUMPABLE_BITS) - 1)
 
 /* coredump filter bits */
 #define MMF_DUMP_ANON_PRIVATE	2
@@ -441,6 +443,7 @@ extern int get_dumpable(struct mm_struct *mm);
 #define MMF_DUMP_ELF_HEADERS	6
 #define MMF_DUMP_HUGETLB_PRIVATE 7
 #define MMF_DUMP_HUGETLB_SHARED  8
+
 #define MMF_DUMP_FILTER_SHIFT	MMF_DUMPABLE_BITS
 #define MMF_DUMP_FILTER_BITS	7
 #define MMF_DUMP_FILTER_MASK \
@@ -454,6 +457,10 @@ extern int get_dumpable(struct mm_struct *mm);
 #else
 # define MMF_DUMP_MASK_DEFAULT_ELF	0
 #endif
+					/* leave room for more dump flags */
+#define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
+
+#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
 struct sighand_struct {
 	atomic_t		count;
diff --git a/kernel/fork.c b/kernel/fork.c
index bd29592..ac312a4 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -49,6 +49,7 @@
 #include <linux/ftrace.h>
 #include <linux/profile.h>
 #include <linux/rmap.h>
+#include <linux/ksm.h>
 #include <linux/acct.h>
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
@@ -289,6 +290,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	rb_link = &mm->mm_rb.rb_node;
 	rb_parent = NULL;
 	pprev = &mm->mmap;
+	retval = ksm_fork(mm, oldmm);
+	if (retval)
+		goto out;
 
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
@@ -425,7 +429,8 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
-	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
+	mm->flags = (current->mm) ?
+		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
 	set_mm_counter(mm, file_rss, 0);
@@ -486,6 +491,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		exit_aio(mm);
+		ksm_exit(mm);
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {
diff --git a/mm/Kconfig b/mm/Kconfig
index c948d4c..d7c44d4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -214,6 +214,17 @@ config HAVE_MLOCKED_PAGE_BIT
 config MMU_NOTIFIER
 	bool
 
+config KSM
+	bool "Enable KSM for page merging"
+	depends on MMU
+	help
+	  Enable Kernel Samepage Merging: KSM periodically scans those areas
+	  of an application's address space that an app has advised may be
+	  mergeable.  When it finds pages of identical content, it replaces
+	  the many instances by a single resident page with that content, so
+	  saving memory until one or another app needs to modify the content.
+	  Recommended for use with KVM, or with other duplicative applications.
+
 config DEFAULT_MMAP_MIN_ADDR
         int "Low address space to protect from user allocation"
         default 4096
diff --git a/mm/Makefile b/mm/Makefile
index 5e0bd64..73ad7d5 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -25,6 +25,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_acl.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
diff --git a/mm/ksm.c b/mm/ksm.c
new file mode 100644
index 0000000..8b76008
--- /dev/null
+++ b/mm/ksm.c
@@ -0,0 +1,56 @@
+/*
+ * Initial dummy version just to illustrate KSM's interface to other files.
+ */
+
+#include <linux/errno.h>
+#include <linux/mman.h>
+#include <linux/ksm.h>
+
+int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, int advice, unsigned long *vm_flags)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	switch (advice) {
+	case MADV_MERGEABLE:
+		/*
+		 * Be somewhat over-protective for now!
+		 */
+		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
+				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
+				 VM_RESERVED  | VM_HUGETLB | VM_INSERTPAGE |
+				 VM_MIXEDMAP  | VM_SAO))
+			return 0;		/* just ignore the advice */
+
+		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags))
+			if (__ksm_enter(mm) < 0)
+				return -EAGAIN;
+
+		*vm_flags |= VM_MERGEABLE;
+		break;
+
+	case MADV_UNMERGEABLE:
+		if (!(*vm_flags & VM_MERGEABLE))
+			return 0;		/* just ignore the advice */
+
+		/* Unmerge any merged pages here */
+
+		*vm_flags &= ~VM_MERGEABLE;
+		break;
+	}
+
+	return 0;
+}
+
+int __ksm_enter(struct mm_struct *mm)
+{
+	/* Allocate a structure to track mm and link it into KSM's list */
+	set_bit(MMF_VM_MERGEABLE, &mm->flags);
+	return 0;
+}
+
+void __ksm_exit(struct mm_struct *mm)
+{
+	/* Unlink and free all KSM's structures which track this mm */
+	clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+}
diff --git a/mm/madvise.c b/mm/madvise.c
index 66c3126..d9ae206 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -11,6 +11,7 @@
 #include <linux/mempolicy.h>
 #include <linux/hugetlb.h>
 #include <linux/sched.h>
+#include <linux/ksm.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -63,6 +64,12 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		}
 		new_flags &= ~VM_DONTCOPY;
 		break;
+	case MADV_MERGEABLE:
+	case MADV_UNMERGEABLE:
+		error = ksm_madvise(vma, start, end, behavior, &new_flags);
+		if (error)
+			goto out;
+		break;
 	}
 
 	if (new_flags == vma->vm_flags) {
@@ -239,6 +246,10 @@ madvise_behavior_valid(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+#ifdef CONFIG_KSM
+	case MADV_MERGEABLE:
+	case MADV_UNMERGEABLE:
+#endif
 		return 1;
 
 	default:
@@ -273,6 +284,9 @@ madvise_behavior_valid(int behavior)
  *  MADV_DONTFORK - omit this area from child's address space when forking:
  *		typically, to avoid COWing pages pinned by get_user_pages().
  *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
+ *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
+ *		this area with pages of identical content from other such areas.
+ *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
  *
  * return values:
  *  zero    - success
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
