Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 286A06B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 16:56:45 -0400 (EDT)
Date: Wed, 8 Jul 2009 22:07:25 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: KSM: current madvise rollup
In-Reply-To: <4A4B317F.4050100@redhat.com>
Message-ID: <Pine.LNX.4.64.0907082035400.10356@sister.anvils>
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
 <4A49E051.1080400@redhat.com> <Pine.LNX.4.64.0906301518370.967@sister.anvils>
 <4A4A5C56.5000109@redhat.com> <Pine.LNX.4.64.0907010057320.4255@sister.anvils>
 <4A4B317F.4050100@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Izik,

Sorry, I've not yet replied to your response of 1 July, nor shall I
right now.  Instead, more urgent to send you my current KSM rollup,
against 2.6.31-rc2, with which I'm now pretty happy - to the extent
that I've put my signoff to it below.

Though of course it's actually your and Andrea's and Chris's work,
just played around with by me; I don't know what the order of
signoffs should be in the end.

What it mainly lacks is a Documentation file, and more statistics in
sysfs: though we can already see how much is being merged, we don't
see any comparison against how much isn't.

But if you still like the patch below, let's advance to splitting
it up and getting it into mmotm: I have some opinions on the splitup,
I'll make some suggestions on that tomorrow.

You asked for a full diff against -rc2, but may want some explanation
of differences from what I sent before.  The main changes are:-

A reliable PageKsm(), not dependent on the nature of the vma it's in:
it's like PageAnon, but with NULL anon_vma - needs a couple of slight
adjustments outside ksm.c.

Consequently, no reason to go on prohibiting KSM on private anonymous
pages COWed from template file pages in file-backed vmas.

Most of what get_user_pages did for us was unhelpful: now rely on
find_vma and follow_page and handle_mm_fault directly, which allow
us to check VM_MERGEABLE and PageKsm ourselves where needed.

Which eliminates the separate is_present_pte checks, and spares us
from wasting rmap_items on absent ptes.

Which then drew attention to the hyperactive allocation and freeing
of tree_items, "slabinfo -AD" showing huge activity there, even when
idling.  It's not much of a problem really, but might cause concern.

And revealed that really those tree_items were a waste of space, can
be packed within the rmap_items that pointed to them, while still
keeping to the nice cache-friendly 64-byte or 32-byte rmap_item.
(If another field needed later, can make rmap_list singly linked.)

mremap move issue sorted, in simplest COW-breaking way.  My previous
code to unmerge according to rmap_item->stable was racy/buggy for
two reasons: ignore rmap_items there now, just scan the ptes.

ksmd used to be running at higher priority: now nice 0.

Moved mm_slot hash functions together; made hash table smaller
now it's used less frequently than it was in your design.

More cleanup, making similar things more alike.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 arch/alpha/include/asm/mman.h     |    3 
 arch/mips/include/asm/mman.h      |    3 
 arch/parisc/include/asm/mman.h    |    3 
 arch/xtensa/include/asm/mman.h    |    3 
 fs/proc/page.c                    |    5 
 include/asm-generic/mman-common.h |    3 
 include/linux/ksm.h               |   79 +
 include/linux/mm.h                |    1 
 include/linux/mmu_notifier.h      |   34 
 include/linux/rmap.h              |    6 
 include/linux/sched.h             |    7 
 kernel/fork.c                     |    8 
 mm/Kconfig                        |   11 
 mm/Makefile                       |    1 
 mm/ksm.c                          | 1542 ++++++++++++++++++++++++++++
 mm/madvise.c                      |   53 
 mm/memory.c                       |   14 
 mm/mmap.c                         |    6 
 mm/mmu_notifier.c                 |   20 
 mm/mremap.c                       |   12 
 mm/rmap.c                         |   21 
 21 files changed, 1774 insertions(+), 61 deletions(-)

--- 2.6.31-rc2/arch/alpha/include/asm/mman.h	2008-10-09 23:13:53.000000000 +0100
+++ madv_ksm/arch/alpha/include/asm/mman.h	2009-07-05 00:51:29.000000000 +0100
@@ -48,6 +48,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc2/arch/mips/include/asm/mman.h	2008-12-24 23:26:37.000000000 +0000
+++ madv_ksm/arch/mips/include/asm/mman.h	2009-07-05 00:51:29.000000000 +0100
@@ -71,6 +71,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc2/arch/parisc/include/asm/mman.h	2008-12-24 23:26:37.000000000 +0000
+++ madv_ksm/arch/parisc/include/asm/mman.h	2009-07-05 00:51:29.000000000 +0100
@@ -54,6 +54,9 @@
 #define MADV_16M_PAGES  24              /* Use 16 Megabyte pages */
 #define MADV_64M_PAGES  26              /* Use 64 Megabyte pages */
 
+#define MADV_MERGEABLE   65		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 66		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
--- 2.6.31-rc2/arch/xtensa/include/asm/mman.h	2009-03-23 23:12:14.000000000 +0000
+++ madv_ksm/arch/xtensa/include/asm/mman.h	2009-07-05 00:51:29.000000000 +0100
@@ -78,6 +78,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc2/fs/proc/page.c	2009-06-25 05:18:07.000000000 +0100
+++ madv_ksm/fs/proc/page.c	2009-07-07 21:58:29.000000000 +0100
@@ -2,6 +2,7 @@
 #include <linux/compiler.h>
 #include <linux/fs.h>
 #include <linux/init.h>
+#include <linux/ksm.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/proc_fs.h>
@@ -95,6 +96,8 @@ static const struct file_operations proc
 #define KPF_UNEVICTABLE		18
 #define KPF_NOPAGE		20
 
+#define KPF_KSM			21
+
 /* kernel hacking assistances
  * WARNING: subject to change, never rely on them!
  */
@@ -137,6 +140,8 @@ static u64 get_uflags(struct page *page)
 		u |= 1 << KPF_MMAP;
 	if (PageAnon(page))
 		u |= 1 << KPF_ANON;
+	if (PageKsm(page))
+		u |= 1 << KPF_KSM;
 
 	/*
 	 * compound pages: export both head/tail info
--- 2.6.31-rc2/include/asm-generic/mman-common.h	2009-06-25 05:18:08.000000000 +0100
+++ madv_ksm/include/asm-generic/mman-common.h	2009-07-05 00:51:29.000000000 +0100
@@ -35,6 +35,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc2/include/linux/ksm.h	1970-01-01 01:00:00.000000000 +0100
+++ madv_ksm/include/linux/ksm.h	2009-07-08 16:49:33.000000000 +0100
@@ -0,0 +1,79 @@
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
+#include <linux/vmstat.h>
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
+
+/*
+ * A KSM page is one of those write-protected "shared pages" or "merged pages"
+ * which KSM maps into multiple mms, wherever identical anonymous page content
+ * is found in VM_MERGEABLE vmas.  It's a PageAnon page, with NULL anon_vma.
+ */
+static inline int PageKsm(struct page *page)
+{
+	return ((unsigned long)page->mapping == PAGE_MAPPING_ANON);
+}
+
+/*
+ * But we have to avoid the checking which page_add_anon_rmap() performs.
+ */
+static inline void page_add_ksm_rmap(struct page *page)
+{
+	if (atomic_inc_and_test(&page->_mapcount)) {
+		page->mapping = (void *) PAGE_MAPPING_ANON;
+		__inc_zone_page_state(page, NR_ANON_PAGES);
+	}
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
+
+static inline int PageKsm(struct page *page)
+{
+	return 0;
+}
+
+/* No stub required for page_add_ksm_rmap(page) */
+#endif /* !CONFIG_KSM */
+
+#endif
--- 2.6.31-rc2/include/linux/mm.h	2009-07-04 21:26:08.000000000 +0100
+++ madv_ksm/include/linux/mm.h	2009-07-05 00:51:29.000000000 +0100
@@ -105,6 +105,7 @@ extern unsigned int kobjsize(const void
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
+#define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
--- 2.6.31-rc2/include/linux/mmu_notifier.h	2008-10-09 23:13:53.000000000 +0100
+++ madv_ksm/include/linux/mmu_notifier.h	2009-07-05 00:51:29.000000000 +0100
@@ -62,6 +62,15 @@ struct mmu_notifier_ops {
 				 unsigned long address);
 
 	/*
+	 * change_pte is called in cases that pte mapping to page is changed:
+	 * for example, when ksm remaps pte to point to a new shared page.
+	 */
+	void (*change_pte)(struct mmu_notifier *mn,
+			   struct mm_struct *mm,
+			   unsigned long address,
+			   pte_t pte);
+
+	/*
 	 * Before this is invoked any secondary MMU is still ok to
 	 * read/write to the page previously pointed to by the Linux
 	 * pte because the page hasn't been freed yet and it won't be
@@ -154,6 +163,8 @@ extern void __mmu_notifier_mm_destroy(st
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
+extern void __mmu_notifier_change_pte(struct mm_struct *mm,
+				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
@@ -175,6 +186,13 @@ static inline int mmu_notifier_clear_flu
 	return 0;
 }
 
+static inline void mmu_notifier_change_pte(struct mm_struct *mm,
+					   unsigned long address, pte_t pte)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_change_pte(mm, address, pte);
+}
+
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
@@ -236,6 +254,16 @@ static inline void mmu_notifier_mm_destr
 	__young;							\
 })
 
+#define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
+({									\
+	struct mm_struct *___mm = __mm;					\
+	unsigned long ___address = __address;				\
+	pte_t ___pte = __pte;						\
+									\
+	set_pte_at(___mm, ___address, __ptep, ___pte);			\
+	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
+})
+
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -248,6 +276,11 @@ static inline int mmu_notifier_clear_flu
 	return 0;
 }
 
+static inline void mmu_notifier_change_pte(struct mm_struct *mm,
+					   unsigned long address, pte_t pte)
+{
+}
+
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
@@ -273,6 +306,7 @@ static inline void mmu_notifier_mm_destr
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define ptep_clear_flush_notify ptep_clear_flush
+#define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
 
--- 2.6.31-rc2/include/linux/rmap.h	2009-06-25 05:18:09.000000000 +0100
+++ madv_ksm/include/linux/rmap.h	2009-07-05 00:56:00.000000000 +0100
@@ -71,14 +71,10 @@ void page_add_new_anon_rmap(struct page
 void page_add_file_rmap(struct page *);
 void page_remove_rmap(struct page *);
 
-#ifdef CONFIG_DEBUG_VM
-void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address);
-#else
-static inline void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address)
+static inline void page_dup_rmap(struct page *page)
 {
 	atomic_inc(&page->_mapcount);
 }
-#endif
 
 /*
  * Called from mm/vmscan.c to handle paging out
--- 2.6.31-rc2/include/linux/sched.h	2009-07-04 21:26:08.000000000 +0100
+++ madv_ksm/include/linux/sched.h	2009-07-05 00:51:29.000000000 +0100
@@ -431,7 +431,9 @@ extern int get_dumpable(struct mm_struct
 /* dumpable bits */
 #define MMF_DUMPABLE      0  /* core dump is permitted */
 #define MMF_DUMP_SECURELY 1  /* core file is readable only by root */
+
 #define MMF_DUMPABLE_BITS 2
+#define MMF_DUMPABLE_MASK ((1 << MMF_DUMPABLE_BITS) - 1)
 
 /* coredump filter bits */
 #define MMF_DUMP_ANON_PRIVATE	2
@@ -441,6 +443,7 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMP_ELF_HEADERS	6
 #define MMF_DUMP_HUGETLB_PRIVATE 7
 #define MMF_DUMP_HUGETLB_SHARED  8
+
 #define MMF_DUMP_FILTER_SHIFT	MMF_DUMPABLE_BITS
 #define MMF_DUMP_FILTER_BITS	7
 #define MMF_DUMP_FILTER_MASK \
@@ -454,6 +457,10 @@ extern int get_dumpable(struct mm_struct
 #else
 # define MMF_DUMP_MASK_DEFAULT_ELF	0
 #endif
+					/* leave room for more dump flags */
+#define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
+
+#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
 struct sighand_struct {
 	atomic_t		count;
--- 2.6.31-rc2/kernel/fork.c	2009-06-25 05:18:09.000000000 +0100
+++ madv_ksm/kernel/fork.c	2009-07-05 00:51:29.000000000 +0100
@@ -50,6 +50,7 @@
 #include <linux/ftrace.h>
 #include <linux/profile.h>
 #include <linux/rmap.h>
+#include <linux/ksm.h>
 #include <linux/acct.h>
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
@@ -290,6 +291,9 @@ static int dup_mmap(struct mm_struct *mm
 	rb_link = &mm->mm_rb.rb_node;
 	rb_parent = NULL;
 	pprev = &mm->mmap;
+	retval = ksm_fork(mm, oldmm);
+	if (retval)
+		goto out;
 
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
@@ -426,7 +430,8 @@ static struct mm_struct * mm_init(struct
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
-	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
+	mm->flags = (current->mm) ?
+		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
 	set_mm_counter(mm, file_rss, 0);
@@ -487,6 +492,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		exit_aio(mm);
+		ksm_exit(mm);
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {
--- 2.6.31-rc2/mm/Kconfig	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/Kconfig	2009-07-05 00:51:29.000000000 +0100
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
--- 2.6.31-rc2/mm/Makefile	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/Makefile	2009-07-05 00:51:29.000000000 +0100
@@ -25,6 +25,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += spars
 obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_acl.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
--- 2.6.31-rc2/mm/ksm.c	1970-01-01 01:00:00.000000000 +0100
+++ madv_ksm/mm/ksm.c	2009-07-08 16:49:33.000000000 +0100
@@ -0,0 +1,1542 @@
+/*
+ * Memory merging support.
+ *
+ * This code enables dynamic sharing of identical pages found in different
+ * memory areas, even if they are not shared by fork()
+ *
+ * Copyright (C) 2008 Red Hat, Inc.
+ * Authors:
+ *	Izik Eidus
+ *	Andrea Arcangeli
+ *	Chris Wright
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+
+#include <linux/errno.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/mman.h>
+#include <linux/sched.h>
+#include <linux/rwsem.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/spinlock.h>
+#include <linux/jhash.h>
+#include <linux/delay.h>
+#include <linux/kthread.h>
+#include <linux/wait.h>
+#include <linux/slab.h>
+#include <linux/rbtree.h>
+#include <linux/mmu_notifier.h>
+#include <linux/ksm.h>
+
+#include <asm/tlbflush.h>
+
+/*
+ * A few notes about the KSM scanning process,
+ * to make it easier to understand the data structures below:
+ *
+ * In order to reduce excessive scanning, KSM sorts the memory pages by their
+ * contents into a data structure that holds pointers to the pages' locations.
+ *
+ * Since the contents of the pages may change at any moment, KSM cannot just
+ * insert the pages into a normal sorted tree and expect it to find anything.
+ * Therefore KSM uses two data structures - the stable and the unstable tree.
+ *
+ * The stable tree holds pointers to all the merged pages (ksm pages), sorted
+ * by their contents.  Because each such page is write-protected, searching on
+ * this tree is fully assured to be working (except when pages are unmapped),
+ * and therefore this tree is called the stable tree.
+ *
+ * In addition to the stable tree, KSM uses a second data structure called the
+ * unstable tree: this tree holds pointers to pages which have been found to
+ * be "unchanged for a period of time".  The unstable tree sorts these pages
+ * by their contents, but since they are not write-protected, KSM cannot rely
+ * upon the unstable tree to work correctly - the unstable tree is liable to
+ * be corrupted as its contents are modified, and so it is called unstable.
+ *
+ * KSM solves this problem by several techniques:
+ *
+ * 1) The unstable tree is flushed every time KSM completes scanning all
+ *    memory areas, and then the tree is rebuilt again from the beginning.
+ * 2) KSM will only insert into the unstable tree, pages whose hash value
+ *    has not changed since the previous scan of all memory areas.
+ * 3) The unstable tree is a RedBlack Tree - so its balancing is based on the
+ *    colors of the nodes and not on their contents, assuring that even when
+ *    the tree gets "corrupted" it won't get out of balance, so scanning time
+ *    remains the same (also, searching and inserting nodes in an rbtree uses
+ *    the same algorithm, so we have no overhead when we flush and rebuild).
+ * 4) KSM never flushes the stable tree, which means that even if it were to
+ *    take 10 attempts to find a page in the unstable tree, once it is found,
+ *    it is secured in the stable tree.  (When we scan a new page, we first
+ *    compare it against the stable tree, and then against the unstable tree.)
+ */
+
+/**
+ * struct mm_slot - ksm information per mm that is being scanned
+ * @link: link to the mm_slots hash list
+ * @mm_list: link into the mm_slots list, rooted in ksm_mm_head
+ * @rmap_list: head for this mm_slot's list of rmap_items
+ * @mm: the mm that this information is valid for
+ */
+struct mm_slot {
+	struct hlist_node link;
+	struct list_head mm_list;
+	struct list_head rmap_list;
+	struct mm_struct *mm;
+};
+
+/**
+ * struct ksm_scan - cursor for scanning
+ * @mm_slot: the current mm_slot we are scanning
+ * @address: the next address inside that to be scanned
+ * @rmap_item: the current rmap that we are scanning inside the rmap_list
+ * @seqnr: count of completed full scans (needed when removing unstable node)
+ *
+ * There is only the one ksm_scan instance of this cursor structure.
+ */
+struct ksm_scan {
+	struct mm_slot *mm_slot;
+	unsigned long address;
+	struct rmap_item *rmap_item;
+	unsigned long seqnr;
+};
+
+/**
+ * struct rmap_item - reverse mapping item for virtual addresses
+ * @link: link into mm_slot's rmap_list (rmap_list is per mm)
+ * @mm: the memory structure this rmap_item is pointing into
+ * @address: the virtual address this rmap_item tracks (+ flags in low bits)
+ * @oldchecksum: previous checksum of the page at that virtual address
+ * @node: rb_node of this rmap_item in either unstable or stable tree
+ * @next: next rmap_item hanging off the same node of the stable tree
+ * @prev: previous rmap_item hanging off the same node of the stable tree
+ */
+struct rmap_item {
+	struct list_head link;
+	struct mm_struct *mm;
+	unsigned long address;		/* + low bits used for flags below */
+	union {
+		unsigned int oldchecksum;		/* when unstable */
+		struct rmap_item *next;			/* when stable */
+	};
+	union {
+		struct rb_node node;			/* when tree node */
+		struct rmap_item *prev;			/* in stable list */
+	};
+};
+
+#define SEQNR_MASK	0x0ff	/* low bits of unstable tree seqnr */
+#define NODE_FLAG	0x100	/* is a node of unstable or stable tree */
+#define STABLE_FLAG	0x200	/* is a node or list item of stable tree */
+
+/* The stable and unstable tree heads */
+static struct rb_root root_stable_tree = RB_ROOT;
+static struct rb_root root_unstable_tree = RB_ROOT;
+
+#define MM_SLOTS_HASH_HEADS 1024
+static struct hlist_head *mm_slots_hash;
+
+static struct mm_slot ksm_mm_head = {
+	.mm_list = LIST_HEAD_INIT(ksm_mm_head.mm_list),
+};
+static struct ksm_scan ksm_scan = {
+	.mm_slot = &ksm_mm_head,
+};
+
+static struct kmem_cache *rmap_item_cache;
+static struct kmem_cache *mm_slot_cache;
+
+/* The number of nodes in the stable tree */
+static unsigned long ksm_kernel_pages_allocated;
+
+/* The number of page slots sharing those nodes */
+static unsigned long ksm_pages_shared;
+
+/* Limit on the number of unswappable pages used */
+static unsigned long ksm_max_kernel_pages;
+
+/* Number of pages ksmd should scan in one batch */
+static unsigned int ksm_thread_pages_to_scan;
+
+/* Milliseconds ksmd should sleep between batches */
+static unsigned int ksm_thread_sleep_millisecs;
+
+#define KSM_RUN_STOP	0
+#define KSM_RUN_MERGE	1
+#define KSM_RUN_UNMERGE	2
+static unsigned int ksm_run;
+
+static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
+static DEFINE_MUTEX(ksm_thread_mutex);
+static DEFINE_SPINLOCK(ksm_mmlist_lock);
+
+#define KSM_KMEM_CACHE(__struct, __flags) kmem_cache_create("ksm_"#__struct,\
+		sizeof(struct __struct), __alignof__(struct __struct),\
+		(__flags), NULL)
+
+static int __init ksm_slab_init(void)
+{
+	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
+	if (!rmap_item_cache)
+		goto out;
+
+	mm_slot_cache = KSM_KMEM_CACHE(mm_slot, 0);
+	if (!mm_slot_cache)
+		goto out_free;
+
+	return 0;
+
+out_free:
+	kmem_cache_destroy(rmap_item_cache);
+out:
+	return -ENOMEM;
+}
+
+static void __init ksm_slab_free(void)
+{
+	kmem_cache_destroy(mm_slot_cache);
+	kmem_cache_destroy(rmap_item_cache);
+	mm_slot_cache = NULL;
+}
+
+static inline struct rmap_item *alloc_rmap_item(void)
+{
+	return kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
+}
+
+static inline void free_rmap_item(struct rmap_item *rmap_item)
+{
+	rmap_item->mm = NULL;	/* debug safety */
+	kmem_cache_free(rmap_item_cache, rmap_item);
+}
+
+static inline struct mm_slot *alloc_mm_slot(void)
+{
+	if (!mm_slot_cache)	/* initialization failed */
+		return NULL;
+	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
+}
+
+static inline void free_mm_slot(struct mm_slot *mm_slot)
+{
+	kmem_cache_free(mm_slot_cache, mm_slot);
+}
+
+static int __init mm_slots_hash_init(void)
+{
+	mm_slots_hash = kzalloc(MM_SLOTS_HASH_HEADS * sizeof(struct hlist_head),
+				GFP_KERNEL);
+	if (!mm_slots_hash)
+		return -ENOMEM;
+	return 0;
+}
+
+static void __init mm_slots_hash_free(void)
+{
+	kfree(mm_slots_hash);
+}
+
+static struct mm_slot *get_mm_slot(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+	struct hlist_head *bucket;
+	struct hlist_node *node;
+
+	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
+				% MM_SLOTS_HASH_HEADS];
+	hlist_for_each_entry(mm_slot, node, bucket, link) {
+		if (mm == mm_slot->mm)
+			return mm_slot;
+	}
+	return NULL;
+}
+
+static void insert_to_mm_slots_hash(struct mm_struct *mm,
+				    struct mm_slot *mm_slot)
+{
+	struct hlist_head *bucket;
+
+	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
+				% MM_SLOTS_HASH_HEADS];
+	mm_slot->mm = mm;
+	INIT_LIST_HEAD(&mm_slot->rmap_list);
+	hlist_add_head(&mm_slot->link, bucket);
+}
+
+static inline int in_stable_tree(struct rmap_item *rmap_item)
+{
+	return rmap_item->address & STABLE_FLAG;
+}
+
+/*
+ * We use break_ksm to break COW on a ksm page: it's a stripped down
+ *
+ *	if (get_user_pages(current, mm, addr, 1, 1, 1, &page, NULL) == 1)
+ *		put_page(page);
+ *
+ * but taking great care only to touch a ksm page, in a VM_MERGEABLE vma,
+ * in case the application has unmapped and remapped mm,addr meanwhile.
+ * Could a ksm page appear anywhere else?  Actually yes, in a VM_PFNMAP
+ * mmap of /dev/mem or /dev/kmem, where we would not want to touch it.
+ */
+static void break_ksm(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct page *page;
+	int ret;
+
+	do {
+		cond_resched();
+		page = follow_page(vma, addr, FOLL_GET);
+		if (!page)
+			break;
+		if (PageKsm(page))
+			ret = handle_mm_fault(vma->vm_mm, vma, addr,
+							FAULT_FLAG_WRITE);
+		else
+			ret = VM_FAULT_WRITE;
+		put_page(page);
+	} while (!(ret & (VM_FAULT_WRITE | VM_FAULT_SIGBUS)));
+
+	/* Which leaves us looping there if VM_FAULT_OOM: hmmm... */
+}
+
+static void __break_cow(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma;
+
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr)
+		return;
+	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
+		return;
+	break_ksm(vma, addr);
+}
+
+static void break_cow(struct mm_struct *mm, unsigned long addr)
+{
+	down_read(&mm->mmap_sem);
+	__break_cow(mm, addr);
+	up_read(&mm->mmap_sem);
+}
+
+static struct page *get_mergeable_page(struct rmap_item *rmap_item)
+{
+	struct mm_struct *mm = rmap_item->mm;
+	unsigned long addr = rmap_item->address;
+	struct vm_area_struct *vma;
+	struct page *page;
+
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr)
+		goto out;
+	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
+		goto out;
+
+	page = follow_page(vma, addr, FOLL_GET);
+	if (!page)
+		goto out;
+	if (PageAnon(page)) {
+		flush_anon_page(vma, page, addr);
+		flush_dcache_page(page);
+	} else {
+		put_page(page);
+out:		page = NULL;
+	}
+	up_read(&mm->mmap_sem);
+	return page;
+}
+
+/*
+ * get_ksm_page: checks if the page at the virtual address in rmap_item
+ * is still PageKsm, in which case we can trust the content of the page,
+ * and it returns the gotten page; but NULL if the page has been zapped.
+ */
+static struct page *get_ksm_page(struct rmap_item *rmap_item)
+{
+	struct page *page;
+
+	page = get_mergeable_page(rmap_item);
+	if (page && !PageKsm(page)) {
+		put_page(page);
+		page = NULL;
+	}
+	return page;
+}
+
+/*
+ * Removing rmap_item from stable or unstable tree.
+ * This function will clean the information from the stable/unstable tree.
+ */
+static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
+{
+	if (in_stable_tree(rmap_item)) {
+		struct rmap_item *next_item = rmap_item->next;
+
+		if (rmap_item->address & NODE_FLAG) {
+			if (next_item) {
+				rb_replace_node(&rmap_item->node,
+						&next_item->node,
+						&root_stable_tree);
+				next_item->address |= NODE_FLAG;
+			} else {
+				rb_erase(&rmap_item->node, &root_stable_tree);
+				ksm_kernel_pages_allocated--;
+			}
+		} else {
+			struct rmap_item *prev_item = rmap_item->prev;
+
+			BUG_ON(prev_item->next != rmap_item);
+			prev_item->next = next_item;
+			if (next_item) {
+				BUG_ON(next_item->prev != rmap_item);
+				next_item->prev = rmap_item->prev;
+			}
+		}
+
+		rmap_item->next = NULL;
+		ksm_pages_shared--;
+
+	} else if (rmap_item->address & NODE_FLAG) {
+		unsigned char age;
+		/*
+		 * ksm_thread can and must skip the rb_erase, because
+		 * root_unstable_tree was already reset to RB_ROOT.
+		 * But __ksm_exit has to be careful: do the rb_erase
+		 * if it's interrupting a scan, and this rmap_item was
+		 * inserted by this scan rather than left from before.
+		 *
+		 * Because of the case in which remove_mm_from_lists
+		 * increments seqnr before removing rmaps, unstable_nr
+		 * may even be 2 behind seqnr, but should never be
+		 * further behind.  Yes, I did have trouble with this!
+		 */
+		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
+		BUG_ON(age > 2);
+		if (!age)
+			rb_erase(&rmap_item->node, &root_unstable_tree);
+	}
+
+	rmap_item->address &= PAGE_MASK;
+
+	cond_resched();		/* we're called from many long loops */
+}
+
+static void remove_all_slot_rmap_items(struct mm_slot *mm_slot)
+{
+	struct rmap_item *rmap_item, *node;
+
+	list_for_each_entry_safe(rmap_item, node, &mm_slot->rmap_list, link) {
+		remove_rmap_item_from_tree(rmap_item);
+		list_del(&rmap_item->link);
+		free_rmap_item(rmap_item);
+	}
+}
+
+static void remove_trailing_rmap_items(struct mm_slot *mm_slot,
+				       struct list_head *cur)
+{
+	struct rmap_item *rmap_item;
+
+	while (cur != &mm_slot->rmap_list) {
+		rmap_item = list_entry(cur, struct rmap_item, link);
+		cur = cur->next;
+		remove_rmap_item_from_tree(rmap_item);
+		list_del(&rmap_item->link);
+		free_rmap_item(rmap_item);
+	}
+}
+
+/*
+ * Though it's very tempting to unmerge in_stable_tree(rmap_item)s rather
+ * than check every pte of a given vma, the locking doesn't quite work for
+ * that - an rmap_item is assigned to the stable tree after inserting ksm
+ * page and upping mmap_sem.  Nor does it fit with the way we skip dup'ing
+ * rmap_items from parent to child at fork time (so as not to waste time
+ * if exit comes before the next scan reaches it).
+ */
+static void unmerge_ksm_pages(struct vm_area_struct *vma,
+			      unsigned long start, unsigned long end)
+{
+	unsigned long addr;
+
+	for (addr = start; addr < end; addr += PAGE_SIZE)
+		break_ksm(vma, addr);
+}
+
+static void unmerge_and_remove_all_rmap_items(void)
+{
+	struct mm_slot *mm_slot;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+
+	list_for_each_entry(mm_slot, &ksm_mm_head.mm_list, mm_list) {
+		mm = mm_slot->mm;
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
+				continue;
+			unmerge_ksm_pages(vma, vma->vm_start, vma->vm_end);
+		}
+		remove_all_slot_rmap_items(mm_slot);
+		up_read(&mm->mmap_sem);
+	}
+
+	spin_lock(&ksm_mmlist_lock);
+	if (ksm_scan.mm_slot != &ksm_mm_head) {
+		ksm_scan.mm_slot = &ksm_mm_head;
+		ksm_scan.seqnr++;
+	}
+	spin_unlock(&ksm_mmlist_lock);
+}
+
+static void remove_mm_from_lists(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+
+	spin_lock(&ksm_mmlist_lock);
+	mm_slot = get_mm_slot(mm);
+
+	/*
+	 * This mm_slot is always at the scanning cursor when we're
+	 * called from scan_get_next_rmap_item; but it's a special
+	 * case when we're called from __ksm_exit.
+	 */
+	if (ksm_scan.mm_slot == mm_slot) {
+		ksm_scan.mm_slot = list_entry(
+			mm_slot->mm_list.next, struct mm_slot, mm_list);
+		ksm_scan.address = 0;
+		ksm_scan.rmap_item = list_entry(
+			&ksm_scan.mm_slot->rmap_list, struct rmap_item, link);
+		if (ksm_scan.mm_slot == &ksm_mm_head)
+			ksm_scan.seqnr++;
+	}
+
+	hlist_del(&mm_slot->link);
+	list_del(&mm_slot->mm_list);
+	spin_unlock(&ksm_mmlist_lock);
+
+	remove_all_slot_rmap_items(mm_slot);
+	free_mm_slot(mm_slot);
+	clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+}
+
+static u32 calc_checksum(struct page *page)
+{
+	u32 checksum;
+	void *addr = kmap_atomic(page, KM_USER0);
+	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	kunmap_atomic(addr, KM_USER0);
+	return checksum;
+}
+
+static int memcmp_pages(struct page *page1, struct page *page2)
+{
+	char *addr1, *addr2;
+	int ret;
+
+	addr1 = kmap_atomic(page1, KM_USER0);
+	addr2 = kmap_atomic(page2, KM_USER1);
+	ret = memcmp(addr1, addr2, PAGE_SIZE);
+	kunmap_atomic(addr2, KM_USER1);
+	kunmap_atomic(addr1, KM_USER0);
+	return ret;
+}
+
+static inline int pages_identical(struct page *page1, struct page *page2)
+{
+	return !memcmp_pages(page1, page2);
+}
+
+static int write_protect_page(struct vm_area_struct *vma, struct page *page,
+			      pte_t *orig_pte)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long addr;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	int swapped;
+	int err = -EFAULT;
+
+	addr = page_address_in_vma(page, vma);
+	if (addr == -EFAULT)
+		goto out;
+
+	ptep = page_check_address(page, mm, addr, &ptl, 0);
+	if (!ptep)
+		goto out;
+
+	if (pte_write(*ptep)) {
+		pte_t entry;
+
+		swapped = PageSwapCache(page);
+		flush_cache_page(vma, addr, page_to_pfn(page));
+		/*
+		 * Ok this is tricky, when get_user_pages_fast() run it doesnt
+		 * take any lock, therefore the check that we are going to make
+		 * with the pagecount against the mapcount is racey and
+		 * O_DIRECT can happen right after the check.
+		 * So we clear the pte and flush the tlb before the check
+		 * this assure us that no O_DIRECT can happen after the check
+		 * or in the middle of the check.
+		 */
+		entry = ptep_clear_flush(vma, addr, ptep);
+		/*
+		 * Check that no O_DIRECT or similar I/O is in progress on the
+		 * page
+		 */
+		if ((page_mapcount(page) + 2 + swapped) != page_count(page)) {
+			set_pte_at_notify(mm, addr, ptep, entry);
+			goto out_unlock;
+		}
+		entry = pte_wrprotect(entry);
+		set_pte_at_notify(mm, addr, ptep, entry);
+	}
+	*orig_pte = *ptep;
+	err = 0;
+
+out_unlock:
+	pte_unmap_unlock(ptep, ptl);
+out:
+	return err;
+}
+
+/**
+ * replace_page - replace page in vma by new ksm page
+ * @vma:      vma that holds the pte pointing to oldpage
+ * @oldpage:  the page we are replacing by newpage
+ * @newpage:  the ksm page we replace oldpage by
+ * @orig_pte: the original value of the pte
+ *
+ * Returns 0 on success, -EFAULT on failure.
+ */
+static int replace_page(struct vm_area_struct *vma, struct page *oldpage,
+			struct page *newpage, pte_t orig_pte)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	unsigned long addr;
+	pgprot_t prot;
+	int err = -EFAULT;
+
+	prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
+
+	addr = page_address_in_vma(oldpage, vma);
+	if (addr == -EFAULT)
+		goto out;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd))
+		goto out;
+
+	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	if (!pte_same(*ptep, orig_pte)) {
+		pte_unmap_unlock(ptep, ptl);
+		goto out;
+	}
+
+	get_page(newpage);
+	page_add_ksm_rmap(newpage);
+
+	flush_cache_page(vma, addr, pte_pfn(*ptep));
+	ptep_clear_flush(vma, addr, ptep);
+	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, prot));
+
+	page_remove_rmap(oldpage);
+	put_page(oldpage);
+
+	pte_unmap_unlock(ptep, ptl);
+	err = 0;
+out:
+	return err;
+}
+
+/*
+ * try_to_merge_one_page - take two pages and merge them into one
+ * @vma: the vma that hold the pte pointing into oldpage
+ * @oldpage: the page that we want to replace with newpage
+ * @newpage: the page that we want to map instead of oldpage
+ *
+ * Note:
+ * oldpage should be a PageAnon page, while newpage should be a PageKsm page,
+ * or a newly allocated kernel page which page_add_ksm_rmap will make PageKsm.
+ *
+ * This function returns 0 if the pages were merged, -EFAULT otherwise.
+ */
+static int try_to_merge_one_page(struct vm_area_struct *vma,
+				 struct page *oldpage,
+				 struct page *newpage)
+{
+	pte_t orig_pte = __pte(0);
+	int err = -EFAULT;
+
+	if (!(vma->vm_flags & VM_MERGEABLE))
+		goto out;
+
+	if (!PageAnon(oldpage))
+		goto out;
+
+	get_page(newpage);
+	get_page(oldpage);
+
+	/*
+	 * We need the page lock to read a stable PageSwapCache in
+	 * write_protect_page().  We use trylock_page() instead of
+	 * lock_page() because we don't want to wait here - we
+	 * prefer to continue scanning and merging different pages,
+	 * then come back to this page when it is unlocked.
+	 */
+	if (!trylock_page(oldpage))
+		goto out_putpage;
+	/*
+	 * If this anonymous page is mapped only here, its pte may need
+	 * to be write-protected.  If it's mapped elsewhere, all of its
+	 * ptes are necessarily already write-protected.  But in either
+	 * case, we need to lock and check page_count is not raised.
+	 */
+	if (write_protect_page(vma, oldpage, &orig_pte)) {
+		unlock_page(oldpage);
+		goto out_putpage;
+	}
+	unlock_page(oldpage);
+
+	if (pages_identical(oldpage, newpage))
+		err = replace_page(vma, oldpage, newpage, orig_pte);
+
+out_putpage:
+	put_page(oldpage);
+	put_page(newpage);
+out:
+	return err;
+}
+
+/*
+ * try_to_merge_two_pages - take two identical pages and prepare them
+ * to be merged into one page.
+ *
+ * This function returns 0 if we successfully mapped two identical pages
+ * into one page, -EFAULT otherwise.
+ *
+ * Note that this function allocates a new kernel page: if one of the pages
+ * is already a ksm page, try_to_merge_with_ksm_page should be used.
+ */
+static int try_to_merge_two_pages(struct mm_struct *mm1, unsigned long addr1,
+				  struct page *page1, struct mm_struct *mm2,
+				  unsigned long addr2, struct page *page2)
+{
+	struct vm_area_struct *vma;
+	struct page *kpage;
+	int err = -EFAULT;
+
+	/*
+	 * The number of nodes in the stable tree
+	 * is the number of kernel pages that we hold.
+	 */
+	if (ksm_max_kernel_pages &&
+	    ksm_max_kernel_pages <= ksm_kernel_pages_allocated)
+		return err;
+
+	kpage = alloc_page(GFP_HIGHUSER);
+	if (!kpage)
+		return err;
+
+	down_read(&mm1->mmap_sem);
+	vma = find_vma(mm1, addr1);
+	if (!vma || vma->vm_start > addr1) {
+		put_page(kpage);
+		up_read(&mm1->mmap_sem);
+		return err;
+	}
+
+	copy_user_highpage(kpage, page1, addr1, vma);
+	err = try_to_merge_one_page(vma, page1, kpage);
+	up_read(&mm1->mmap_sem);
+
+	if (!err) {
+		down_read(&mm2->mmap_sem);
+		vma = find_vma(mm2, addr2);
+		if (!vma || vma->vm_start > addr2) {
+			put_page(kpage);
+			up_read(&mm2->mmap_sem);
+			break_cow(mm1, addr1);
+			return -EFAULT;
+		}
+
+		err = try_to_merge_one_page(vma, page2, kpage);
+		up_read(&mm2->mmap_sem);
+
+		/*
+		 * If the second try_to_merge_one_page failed, we have a
+		 * ksm page with just one pte pointing to it, so break it.
+		 */
+		if (err)
+			break_cow(mm1, addr1);
+		else
+			ksm_pages_shared += 2;
+	}
+
+	put_page(kpage);
+	return err;
+}
+
+/*
+ * try_to_merge_with_ksm_page - like try_to_merge_two_pages,
+ * but no new kernel page is allocated: kpage must already be a ksm page.
+ */
+static int try_to_merge_with_ksm_page(struct mm_struct *mm1,
+				      unsigned long addr1,
+				      struct page *page1,
+				      struct page *kpage)
+{
+	struct vm_area_struct *vma;
+	int err = -EFAULT;
+
+	down_read(&mm1->mmap_sem);
+	vma = find_vma(mm1, addr1);
+	if (!vma || vma->vm_start > addr1) {
+		up_read(&mm1->mmap_sem);
+		return err;
+	}
+
+	err = try_to_merge_one_page(vma, page1, kpage);
+	up_read(&mm1->mmap_sem);
+
+	if (!err)
+		ksm_pages_shared++;
+
+	return err;
+}
+
+/*
+ * stable_tree_search - search page inside the stable tree
+ * @page: the page that we are searching identical pages to.
+ * @page2: pointer into identical page that we are holding inside the stable
+ *	   tree that we have found.
+ * @rmap_item: the reverse mapping item
+ *
+ * This function checks if there is a page inside the stable tree
+ * with identical content to the page that we are scanning right now.
+ *
+ * This function return rmap_item pointer to the identical item if found,
+ * NULL otherwise.
+ */
+static struct rmap_item *stable_tree_search(struct page *page,
+					    struct page **page2,
+					    struct rmap_item *rmap_item)
+{
+	struct rb_node *node = root_stable_tree.rb_node;
+
+	while (node) {
+		struct rmap_item *tree_rmap_item, *next_rmap_item;
+		int ret;
+
+		tree_rmap_item = rb_entry(node, struct rmap_item, node);
+		while (tree_rmap_item) {
+			BUG_ON(!in_stable_tree(tree_rmap_item));
+			cond_resched();
+			page2[0] = get_ksm_page(tree_rmap_item);
+			if (page2[0])
+				break;
+			next_rmap_item = tree_rmap_item->next;
+			remove_rmap_item_from_tree(tree_rmap_item);
+			tree_rmap_item = next_rmap_item;
+		}
+		if (!tree_rmap_item)
+			return NULL;
+
+		/*
+		 * We can trust the value of the memcmp as we know the pages
+		 * are write protected.
+		 */
+		ret = memcmp_pages(page, page2[0]);
+
+		if (ret < 0) {
+			put_page(page2[0]);
+			node = node->rb_left;
+		} else if (ret > 0) {
+			put_page(page2[0]);
+			node = node->rb_right;
+		} else {
+			return tree_rmap_item;
+		}
+	}
+
+	return NULL;
+}
+
+/*
+ * stable_tree_insert - insert rmap_item pointing to new ksm page
+ * into the stable tree.
+ *
+ * @page: the page that we are searching identical page to inside the stable
+ *	  tree.
+ * @rmap_item: pointer to the reverse mapping item.
+ *
+ * This function returns rmap_item if success, NULL otherwise.
+ */
+static struct rmap_item *stable_tree_insert(struct page *page,
+					    struct rmap_item *rmap_item)
+{
+	struct rb_node **new = &root_stable_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct page *page2[1];
+
+	while (*new) {
+		struct rmap_item *tree_rmap_item, *next_rmap_item;
+		int ret;
+
+		tree_rmap_item = rb_entry(*new, struct rmap_item, node);
+		while (tree_rmap_item) {
+			BUG_ON(!in_stable_tree(tree_rmap_item));
+			cond_resched();
+			page2[0] = get_ksm_page(tree_rmap_item);
+			if (page2[0])
+				break;
+			next_rmap_item = tree_rmap_item->next;
+			remove_rmap_item_from_tree(tree_rmap_item);
+			tree_rmap_item = next_rmap_item;
+		}
+		if (!tree_rmap_item)
+			return NULL;
+
+		ret = memcmp_pages(page, page2[0]);
+
+		parent = *new;
+		if (ret < 0) {
+			put_page(page2[0]);
+			new = &parent->rb_left;
+		} else if (ret > 0) {
+			put_page(page2[0]);
+			new = &parent->rb_right;
+		} else {
+			/*
+			 * It is not a bug when we come here (the fact that
+			 * we didn't find the page inside the stable tree):
+			 * because when we searched for the page inside the
+			 * stable tree it was still not write-protected,
+			 * so therefore it could have changed later.
+			 */
+			return NULL;
+		}
+	}
+
+	ksm_kernel_pages_allocated++;
+
+	rmap_item->address |= NODE_FLAG | STABLE_FLAG;
+	rmap_item->next = NULL;
+	rb_link_node(&rmap_item->node, parent, new);
+	rb_insert_color(&rmap_item->node, &root_stable_tree);
+
+	return rmap_item;
+}
+
+/*
+ * unstable_tree_search_insert - search and insert items into the unstable tree.
+ *
+ * @page: the page that we are going to search for identical page or to insert
+ *	  into the unstable tree
+ * @page2: pointer into identical page that was found inside the unstable tree
+ * @rmap_item: the reverse mapping item of page
+ *
+ * This function searches for a page in the unstable tree identical to the
+ * page currently being scanned; and if no identical page is found in the
+ * tree, we insert rmap_item as a new object into the unstable tree.
+ *
+ * This function returns pointer to rmap_item found to be identical
+ * to the currently scanned page, NULL otherwise.
+ *
+ * This function does both searching and inserting, because they share
+ * the same walking algorithm in an rbtree.
+ */
+static struct rmap_item *unstable_tree_search_insert(struct page *page,
+						struct page **page2,
+						struct rmap_item *rmap_item)
+{
+	struct rb_node **new = &root_unstable_tree.rb_node;
+	struct rb_node *parent = NULL;
+
+	while (*new) {
+		struct rmap_item *tree_rmap_item;
+		int ret;
+
+		tree_rmap_item = rb_entry(*new, struct rmap_item, node);
+		page2[0] = get_mergeable_page(tree_rmap_item);
+		if (!page2[0])
+			return NULL;
+
+		/*
+		 * Don't substitute an unswappable ksm page
+		 * just for one good swappable forked page.
+		 */
+		if (page == page2[0]) {
+			put_page(page2[0]);
+			return NULL;
+		}
+
+		ret = memcmp_pages(page, page2[0]);
+
+		parent = *new;
+		if (ret < 0) {
+			put_page(page2[0]);
+			new = &parent->rb_left;
+		} else if (ret > 0) {
+			put_page(page2[0]);
+			new = &parent->rb_right;
+		} else {
+			return tree_rmap_item;
+		}
+	}
+
+	rmap_item->address |= NODE_FLAG;
+	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
+	rb_link_node(&rmap_item->node, parent, new);
+	rb_insert_color(&rmap_item->node, &root_unstable_tree);
+
+	return NULL;
+}
+
+/*
+ * stable_tree_append - add another rmap_item to the linked list of
+ * rmap_items hanging off a given node of the stable tree, all sharing
+ * the same ksm page.
+ */
+static void stable_tree_append(struct rmap_item *rmap_item,
+			       struct rmap_item *tree_rmap_item)
+{
+	rmap_item->next = tree_rmap_item->next;
+	rmap_item->prev = tree_rmap_item;
+
+	if (tree_rmap_item->next)
+		tree_rmap_item->next->prev = rmap_item;
+
+	tree_rmap_item->next = rmap_item;
+	rmap_item->address |= STABLE_FLAG;
+}
+
+/*
+ * cmp_and_merge_page - take a page computes its hash value and check if there
+ * is similar hash value to different page,
+ * in case we find that there is similar hash to different page we call to
+ * try_to_merge_two_pages().
+ *
+ * @page: the page that we are searching identical page to.
+ * @rmap_item: the reverse mapping into the virtual address of this page
+ */
+static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
+{
+	struct page *page2[1];
+	struct rmap_item *tree_rmap_item;
+	unsigned int checksum;
+	int err;
+
+	if (in_stable_tree(rmap_item))
+		remove_rmap_item_from_tree(rmap_item);
+
+	/* We first start with searching the page inside the stable tree */
+	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
+	if (tree_rmap_item) {
+		if (page == page2[0]) {			/* forked */
+			ksm_pages_shared++;
+			err = 0;
+		} else
+			err = try_to_merge_with_ksm_page(rmap_item->mm,
+							 rmap_item->address,
+							 page, page2[0]);
+		put_page(page2[0]);
+
+		if (!err) {
+			/*
+			 * The page was successfully merged:
+			 * add its rmap_item to the stable tree.
+			 */
+			stable_tree_append(rmap_item, tree_rmap_item);
+		}
+		return;
+	}
+
+	/*
+	 * A ksm page might have got here by fork, but its other
+	 * references have already been removed from the stable tree.
+	 */
+	if (PageKsm(page))
+		break_cow(rmap_item->mm, rmap_item->address);
+
+	/*
+	 * In case the hash value of the page was changed from the last time we
+	 * have calculated it, this page to be changed frequely, therefore we
+	 * don't want to insert it to the unstable tree, and we don't want to
+	 * waste our time to search if there is something identical to it there.
+	 */
+	checksum = calc_checksum(page);
+	if (rmap_item->oldchecksum != checksum) {
+		rmap_item->oldchecksum = checksum;
+		return;
+	}
+
+	tree_rmap_item = unstable_tree_search_insert(page, page2, rmap_item);
+	if (tree_rmap_item) {
+		err = try_to_merge_two_pages(rmap_item->mm,
+					     rmap_item->address, page,
+					     tree_rmap_item->mm,
+					     tree_rmap_item->address, page2[0]);
+		/*
+		 * As soon as we merge this page, we want to remove the
+		 * rmap_item of the page we have merged with from the unstable
+		 * tree, and insert it instead as new node in the stable tree.
+		 */
+		if (!err) {
+			rb_erase(&tree_rmap_item->node, &root_unstable_tree);
+			tree_rmap_item->address &= ~NODE_FLAG;
+			/*
+			 * If we fail to insert the page into the stable tree,
+			 * we will have 2 virtual addresses that are pointing
+			 * to a ksm page left outside the stable tree,
+			 * in which case we need to break_cow on both.
+			 */
+			if (stable_tree_insert(page2[0], tree_rmap_item))
+				stable_tree_append(rmap_item, tree_rmap_item);
+			else {
+				break_cow(tree_rmap_item->mm,
+						tree_rmap_item->address);
+				break_cow(rmap_item->mm, rmap_item->address);
+				ksm_pages_shared -= 2;
+			}
+		}
+
+		put_page(page2[0]);
+	}
+}
+
+static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
+					    struct list_head *cur,
+					    unsigned long addr)
+{
+	struct rmap_item *rmap_item;
+
+	while (cur != &mm_slot->rmap_list) {
+		rmap_item = list_entry(cur, struct rmap_item, link);
+		if ((rmap_item->address & PAGE_MASK) == addr) {
+			if (!in_stable_tree(rmap_item))
+				remove_rmap_item_from_tree(rmap_item);
+			return rmap_item;
+		}
+		if (rmap_item->address > addr)
+			break;
+		cur = cur->next;
+		remove_rmap_item_from_tree(rmap_item);
+		list_del(&rmap_item->link);
+		free_rmap_item(rmap_item);
+	}
+
+	rmap_item = alloc_rmap_item();
+	if (rmap_item) {
+		/* It has already been zeroed */
+		rmap_item->mm = mm_slot->mm;
+		rmap_item->address = addr;
+		list_add_tail(&rmap_item->link, cur);
+	}
+	return rmap_item;
+}
+
+static struct rmap_item *scan_get_next_rmap_item(struct page **page)
+{
+	struct mm_struct *mm;
+	struct mm_slot *slot;
+	struct vm_area_struct *vma;
+	struct rmap_item *rmap_item;
+
+	if (list_empty(&ksm_mm_head.mm_list))
+		return NULL;
+
+	slot = ksm_scan.mm_slot;
+	if (slot == &ksm_mm_head) {
+		root_unstable_tree = RB_ROOT;
+
+		spin_lock(&ksm_mmlist_lock);
+		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
+		ksm_scan.mm_slot = slot;
+		spin_unlock(&ksm_mmlist_lock);
+next_mm:
+		ksm_scan.address = 0;
+		ksm_scan.rmap_item = list_entry(&slot->rmap_list,
+						struct rmap_item, link);
+	}
+
+	mm = slot->mm;
+	down_read(&mm->mmap_sem);
+	for (vma = find_vma(mm, ksm_scan.address); vma; vma = vma->vm_next) {
+		if (!(vma->vm_flags & VM_MERGEABLE))
+			continue;
+		if (ksm_scan.address < vma->vm_start)
+			ksm_scan.address = vma->vm_start;
+		if (!vma->anon_vma)
+			ksm_scan.address = vma->vm_end;
+
+		while (ksm_scan.address < vma->vm_end) {
+			*page = follow_page(vma, ksm_scan.address, FOLL_GET);
+			if (*page && PageAnon(*page)) {
+				flush_anon_page(vma, *page, ksm_scan.address);
+				flush_dcache_page(*page);
+				rmap_item = get_next_rmap_item(slot,
+					ksm_scan.rmap_item->link.next,
+					ksm_scan.address);
+				if (rmap_item) {
+					ksm_scan.rmap_item = rmap_item;
+					ksm_scan.address += PAGE_SIZE;
+				} else
+					put_page(*page);
+				up_read(&mm->mmap_sem);
+				return rmap_item;
+			}
+			if (*page)
+				put_page(*page);
+			ksm_scan.address += PAGE_SIZE;
+			cond_resched();
+		}
+	}
+
+	if (!ksm_scan.address) {
+		/*
+		 * We've completed a full scan of all vmas, holding mmap_sem
+		 * throughout, and found no VM_MERGEABLE: so do the same as
+		 * __ksm_exit does to remove this mm from all our lists now.
+		 */
+		remove_mm_from_lists(mm);
+		up_read(&mm->mmap_sem);
+		slot = ksm_scan.mm_slot;
+		if (slot != &ksm_mm_head)
+			goto next_mm;
+		return NULL;
+	}
+
+	/*
+	 * Nuke all the rmap_items that are above this current rmap:
+	 * because there were no VM_MERGEABLE vmas with such addresses.
+	 */
+	remove_trailing_rmap_items(slot, ksm_scan.rmap_item->link.next);
+	up_read(&mm->mmap_sem);
+
+	spin_lock(&ksm_mmlist_lock);
+	slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
+	ksm_scan.mm_slot = slot;
+	spin_unlock(&ksm_mmlist_lock);
+
+	/* Repeat until we've completed scanning the whole list */
+	if (slot != &ksm_mm_head)
+		goto next_mm;
+
+	/*
+	 * Bump seqnr here rather than at top, so that __ksm_exit
+	 * can skip rb_erase on unstable tree until we run again.
+	 */
+	ksm_scan.seqnr++;
+	return NULL;
+}
+
+/**
+ * ksm_do_scan  - the ksm scanner main worker function.
+ * @scan_npages - number of pages we want to scan before we return.
+ */
+static void ksm_do_scan(unsigned int scan_npages)
+{
+	struct rmap_item *rmap_item;
+	struct page *page;
+
+	while (scan_npages--) {
+		cond_resched();
+		rmap_item = scan_get_next_rmap_item(&page);
+		if (!rmap_item)
+			return;
+		if (!PageKsm(page) || !in_stable_tree(rmap_item))
+			cmp_and_merge_page(page, rmap_item);
+		put_page(page);
+	}
+}
+
+static int ksm_scan_thread(void *nothing)
+{
+	set_user_nice(current, 0);
+
+	while (!kthread_should_stop()) {
+		if (ksm_run & KSM_RUN_MERGE) {
+			mutex_lock(&ksm_thread_mutex);
+			ksm_do_scan(ksm_thread_pages_to_scan);
+			mutex_unlock(&ksm_thread_mutex);
+			schedule_timeout_interruptible(
+				msecs_to_jiffies(ksm_thread_sleep_millisecs));
+		} else {
+			wait_event_interruptible(ksm_thread_wait,
+					(ksm_run & KSM_RUN_MERGE) ||
+					kthread_should_stop());
+		}
+	}
+	return 0;
+}
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
+		if (vma->anon_vma)
+			unmerge_ksm_pages(vma, start, end);
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
+	struct mm_slot *mm_slot = alloc_mm_slot();
+	if (!mm_slot)
+		return -ENOMEM;
+
+	spin_lock(&ksm_mmlist_lock);
+	insert_to_mm_slots_hash(mm, mm_slot);
+	/*
+	 * Insert just behind the scanning cursor, to let the area settle
+	 * down a little; when fork is followed by immediate exec, we don't
+	 * want ksmd to waste time setting up and tearing down an rmap_list.
+	 */
+	list_add_tail(&mm_slot->mm_list, &ksm_scan.mm_slot->mm_list);
+	spin_unlock(&ksm_mmlist_lock);
+
+	set_bit(MMF_VM_MERGEABLE, &mm->flags);
+	return 0;
+}
+
+void __ksm_exit(struct mm_struct *mm)
+{
+	/*
+	 * This process is exiting: doesn't hold and doesn't need mmap_sem;
+	 * but we do need to exclude ksmd and other exiters while we modify
+	 * the various lists and trees.
+	 */
+	mutex_lock(&ksm_thread_mutex);
+	remove_mm_from_lists(mm);
+	mutex_unlock(&ksm_thread_mutex);
+}
+
+#define KSM_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+#define KSM_ATTR(_name) \
+	static struct kobj_attribute _name##_attr = \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static ssize_t sleep_millisecs_show(struct kobject *kobj,
+				    struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_thread_sleep_millisecs);
+}
+
+static ssize_t sleep_millisecs_store(struct kobject *kobj,
+				     struct kobj_attribute *attr,
+				     const char *buf, size_t count)
+{
+	unsigned long msecs;
+	int err;
+
+	err = strict_strtoul(buf, 10, &msecs);
+	if (err || msecs > UINT_MAX)
+		return -EINVAL;
+
+	ksm_thread_sleep_millisecs = msecs;
+
+	return count;
+}
+KSM_ATTR(sleep_millisecs);
+
+static ssize_t pages_to_scan_show(struct kobject *kobj,
+				  struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_thread_pages_to_scan);
+}
+
+static ssize_t pages_to_scan_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	unsigned long nr_pages;
+
+	err = strict_strtoul(buf, 10, &nr_pages);
+	if (err || nr_pages > UINT_MAX)
+		return -EINVAL;
+
+	ksm_thread_pages_to_scan = nr_pages;
+
+	return count;
+}
+KSM_ATTR(pages_to_scan);
+
+static ssize_t run_show(struct kobject *kobj, struct kobj_attribute *attr,
+			char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_run);
+}
+
+static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
+			 const char *buf, size_t count)
+{
+	int err;
+	unsigned long flags;
+
+	err = strict_strtoul(buf, 10, &flags);
+	if (err || flags > UINT_MAX)
+		return -EINVAL;
+	if (flags > KSM_RUN_UNMERGE)
+		return -EINVAL;
+
+	/*
+	 * KSM_RUN_MERGE sets ksmd running, and 0 stops it running.
+	 * KSM_RUN_UNMERGE stops it running and unmerges all rmap_items,
+	 * breaking COW to free the kernel_pages_allocated (but leaves
+	 * mm_slots on the list for when ksmd may be set running again).
+	 */
+
+	mutex_lock(&ksm_thread_mutex);
+	if (ksm_run != flags) {
+		ksm_run = flags;
+		if (flags & KSM_RUN_UNMERGE)
+			unmerge_and_remove_all_rmap_items();
+	}
+	mutex_unlock(&ksm_thread_mutex);
+
+	if (flags & KSM_RUN_MERGE)
+		wake_up_interruptible(&ksm_thread_wait);
+
+	return count;
+}
+KSM_ATTR(run);
+
+static ssize_t pages_shared_show(struct kobject *kobj,
+				 struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n",
+			ksm_pages_shared - ksm_kernel_pages_allocated);
+}
+KSM_ATTR_RO(pages_shared);
+
+static ssize_t kernel_pages_allocated_show(struct kobject *kobj,
+					   struct kobj_attribute *attr,
+					   char *buf)
+{
+	return sprintf(buf, "%lu\n", ksm_kernel_pages_allocated);
+}
+KSM_ATTR_RO(kernel_pages_allocated);
+
+static ssize_t max_kernel_pages_store(struct kobject *kobj,
+				      struct kobj_attribute *attr,
+				      const char *buf, size_t count)
+{
+	int err;
+	unsigned long nr_pages;
+
+	err = strict_strtoul(buf, 10, &nr_pages);
+	if (err)
+		return -EINVAL;
+
+	ksm_max_kernel_pages = nr_pages;
+
+	return count;
+}
+
+static ssize_t max_kernel_pages_show(struct kobject *kobj,
+				     struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", ksm_max_kernel_pages);
+}
+KSM_ATTR(max_kernel_pages);
+
+static struct attribute *ksm_attrs[] = {
+	&sleep_millisecs_attr.attr,
+	&pages_to_scan_attr.attr,
+	&run_attr.attr,
+	&pages_shared_attr.attr,
+	&kernel_pages_allocated_attr.attr,
+	&max_kernel_pages_attr.attr,
+	NULL,
+};
+
+static struct attribute_group ksm_attr_group = {
+	.attrs = ksm_attrs,
+	.name = "ksm",
+};
+
+static int __init ksm_init(void)
+{
+	struct task_struct *ksm_thread;
+	int err;
+
+	err = ksm_slab_init();
+	if (err)
+		goto out;
+
+	err = mm_slots_hash_init();
+	if (err)
+		goto out_free1;
+
+	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
+	if (IS_ERR(ksm_thread)) {
+		printk(KERN_ERR "ksm: creating kthread failed\n");
+		err = PTR_ERR(ksm_thread);
+		goto out_free2;
+	}
+
+	err = sysfs_create_group(mm_kobj, &ksm_attr_group);
+	if (err) {
+		printk(KERN_ERR "ksm: register sysfs failed\n");
+		goto out_free3;
+	}
+
+	return 0;
+
+out_free3:
+	kthread_stop(ksm_thread);
+out_free2:
+	mm_slots_hash_free();
+out_free1:
+	ksm_slab_free();
+out:
+	return err;
+}
+module_init(ksm_init)
--- 2.6.31-rc2/mm/madvise.c	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/madvise.c	2009-07-05 00:51:29.000000000 +0100
@@ -11,6 +11,7 @@
 #include <linux/mempolicy.h>
 #include <linux/hugetlb.h>
 #include <linux/sched.h>
+#include <linux/ksm.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -41,7 +42,7 @@ static long madvise_behavior(struct vm_a
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
 	pgoff_t pgoff;
-	int new_flags = vma->vm_flags;
+	unsigned long new_flags = vma->vm_flags;
 
 	switch (behavior) {
 	case MADV_NORMAL:
@@ -57,8 +58,18 @@ static long madvise_behavior(struct vm_a
 		new_flags |= VM_DONTCOPY;
 		break;
 	case MADV_DOFORK:
+		if (vma->vm_flags & VM_IO) {
+			error = -EINVAL;
+			goto out;
+		}
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
@@ -211,37 +222,16 @@ static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
 {
-	long error;
-
 	switch (behavior) {
-	case MADV_DOFORK:
-		if (vma->vm_flags & VM_IO) {
-			error = -EINVAL;
-			break;
-		}
-	case MADV_DONTFORK:
-	case MADV_NORMAL:
-	case MADV_SEQUENTIAL:
-	case MADV_RANDOM:
-		error = madvise_behavior(vma, prev, start, end, behavior);
-		break;
 	case MADV_REMOVE:
-		error = madvise_remove(vma, prev, start, end);
-		break;
-
+		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
-		error = madvise_willneed(vma, prev, start, end);
-		break;
-
+		return madvise_willneed(vma, prev, start, end);
 	case MADV_DONTNEED:
-		error = madvise_dontneed(vma, prev, start, end);
-		break;
-
+		return madvise_dontneed(vma, prev, start, end);
 	default:
-		BUG();
-		break;
+		return madvise_behavior(vma, prev, start, end, behavior);
 	}
-	return error;
 }
 
 static int
@@ -256,12 +246,17 @@ madvise_behavior_valid(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+#ifdef CONFIG_KSM
+	case MADV_MERGEABLE:
+	case MADV_UNMERGEABLE:
+#endif
 		return 1;
 
 	default:
 		return 0;
 	}
 }
+
 /*
  * The madvise(2) system call.
  *
@@ -286,6 +281,12 @@ madvise_behavior_valid(int behavior)
  *		so the kernel can free resources associated with it.
  *  MADV_REMOVE - the application wants to free up the given range of
  *		pages and associated backing store.
+ *  MADV_DONTFORK - omit this area from child's address space when forking:
+ *		typically, to avoid COWing pages pinned by get_user_pages().
+ *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
+ *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
+ *		this area with pages of identical content from other such areas.
+ *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
  *
  * return values:
  *  zero    - success
--- 2.6.31-rc2/mm/memory.c	2009-07-04 21:26:08.000000000 +0100
+++ madv_ksm/mm/memory.c	2009-07-05 00:56:00.000000000 +0100
@@ -45,6 +45,7 @@
 #include <linux/swap.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/delayacct.h>
@@ -595,7 +596,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page, vma, addr);
+		page_dup_rmap(page);
 		rss[!!PageAnon(page)]++;
 	}
 
@@ -1972,7 +1973,7 @@ static int do_wp_page(struct mm_struct *
 	 * Take out anonymous pages first, anonymous shared vmas are
 	 * not dirty accountable.
 	 */
-	if (PageAnon(old_page)) {
+	if (PageAnon(old_page) && !PageKsm(old_page)) {
 		if (!trylock_page(old_page)) {
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
@@ -2113,9 +2114,14 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, address, page_table);
+		ptep_clear_flush(vma, address, page_table);
 		page_add_new_anon_rmap(new_page, vma, address);
-		set_pte_at(mm, address, page_table, entry);
+		/*
+		 * We call the notify macro here because, when using secondary
+		 * mmu page tables (such as kvm shadow page tables), we want the
+		 * new page to be mapped directly into the secondary page table.
+		 */
+		set_pte_at_notify(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		if (old_page) {
 			/*
--- 2.6.31-rc2/mm/mmap.c	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/mmap.c	2009-07-05 00:56:00.000000000 +0100
@@ -659,9 +659,6 @@ again:			remove_next = 1 + (end > next->
 	validate_mm(mm);
 }
 
-/* Flags that can be inherited from an existing mapping when merging */
-#define VM_MERGEABLE_FLAGS (VM_CAN_NONLINEAR)
-
 /*
  * If the vma has a ->close operation then the driver probably needs to release
  * per-vma resources, so we don't attempt to merge those.
@@ -669,7 +666,8 @@ again:			remove_next = 1 + (end > next->
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 			struct file *file, unsigned long vm_flags)
 {
-	if ((vma->vm_flags ^ vm_flags) & ~VM_MERGEABLE_FLAGS)
+	/* VM_CAN_NONLINEAR may get set later by f_op->mmap() */
+	if ((vma->vm_flags ^ vm_flags) & ~VM_CAN_NONLINEAR)
 		return 0;
 	if (vma->vm_file != file)
 		return 0;
--- 2.6.31-rc2/mm/mmu_notifier.c	2008-10-09 23:13:53.000000000 +0100
+++ madv_ksm/mm/mmu_notifier.c	2009-07-05 00:51:29.000000000 +0100
@@ -99,6 +99,26 @@ int __mmu_notifier_clear_flush_young(str
 	return young;
 }
 
+void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
+			       pte_t pte)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->change_pte)
+			mn->ops->change_pte(mn, mm, address, pte);
+		/*
+		 * Some drivers don't have change_pte,
+		 * so we must call invalidate_page in that case.
+		 */
+		else if (mn->ops->invalidate_page)
+			mn->ops->invalidate_page(mn, mm, address);
+	}
+	rcu_read_unlock();
+}
+
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
--- 2.6.31-rc2/mm/mremap.c	2009-03-23 23:12:14.000000000 +0000
+++ madv_ksm/mm/mremap.c	2009-07-07 21:58:29.000000000 +0100
@@ -11,6 +11,7 @@
 #include <linux/hugetlb.h>
 #include <linux/slab.h>
 #include <linux/shm.h>
+#include <linux/ksm.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/capability.h>
@@ -182,6 +183,17 @@ static unsigned long move_vma(struct vm_
 	if (mm->map_count >= sysctl_max_map_count - 3)
 		return -ENOMEM;
 
+	/*
+	 * Advise KSM to break any KSM pages in the area to be moved:
+	 * it would be confusing if they were to turn up at the new
+	 * location, where they happen to coincide with different KSM
+	 * pages recently unmapped.  But leave vma->vm_flags as it was,
+	 * so KSM can come around to merge on vma and new_vma afterwards.
+	 */
+	if (ksm_madvise(vma, old_addr, old_addr + old_len,
+						MADV_UNMERGEABLE, &vm_flags))
+		return -ENOMEM;
+
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
 	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff);
 	if (!new_vma)
--- 2.6.31-rc2/mm/rmap.c	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/rmap.c	2009-07-05 00:56:00.000000000 +0100
@@ -709,27 +709,6 @@ void page_add_file_rmap(struct page *pag
 	}
 }
 
-#ifdef CONFIG_DEBUG_VM
-/**
- * page_dup_rmap - duplicate pte mapping to a page
- * @page:	the page to add the mapping to
- * @vma:	the vm area being duplicated
- * @address:	the user virtual address mapped
- *
- * For copy_page_range only: minimal extract from page_add_file_rmap /
- * page_add_anon_rmap, avoiding unnecessary tests (already checked) so it's
- * quicker.
- *
- * The caller needs to hold the pte lock.
- */
-void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address)
-{
-	if (PageAnon(page))
-		__page_check_anon_rmap(page, vma, address);
-	atomic_inc(&page->_mapcount);
-}
-#endif
-
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
