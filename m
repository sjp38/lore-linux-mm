Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D2E036B005A
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 10:14:08 -0400 (EDT)
Date: Mon, 29 Jun 2009 15:14:04 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: KSM: current madvise rollup
Message-ID: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Izik,

Thanks a lot for giving me some space.  As I proposed in private mail
last week, here is my current rollup of the madvise version of KSM.

The patch is against 2.6.31-rc1, but the work is based upon your
"RFC - ksm api change into madvise" from 14 May: omitting for now
your 4/4 to apply KSM to other processes, but including Andrea's
two rmap_item fixes from 3 June.

This is not a patch to go into any tree yet: it needs to be split
up and reviewed and argued over and parts reverted etc.  But it is
good for some testing, and it is good for you to take a look at,
diff against what you have and say, perhaps: right, please split
this up into this and this and this kind of change, so we can
examine it more closely; or, perhaps, you won't like my direction
at all and want a fresh start.

The changes outside of mm/ksm.c shouldn't cause much controversy.
Perhaps we'll want to send in the arch mman.h additions, and the
madvise interface, and your mmu_notifier mods, along with a dummy
mm/ksm.c, quite early; while we continue to discuss what's in ksm.c.

It'll be hard for you not to get irritated by all my trivial cleanups
there, sorry.  I find it best when I'm working to let myself do such
tidying up, then only at the end go back over to decide whether it's
justified or not.  And my correction of typos in comments etc. is
fairly random: sometimes I've just corrected one word, sometimes
I've rewritten a comment, but lots I've not read through yet.

A lot of the change came about because I couldn't run the loads
I wanted, they'd OOM because of the way KSM had a hold on any mm it
was advised of (so the mm couldn't exit and free up its pages until
KSM got there).  I know you were dissatisfied with that too, but
perhaps you've solved it differently by now.

I've plenty more to do: still haven't really focussed in on mremap
move, and races when the vma we expect to be VM_MERGEABLE is actually
something else by the time we get mmap_sem for get_user_pages.  But I
don't think there's any show-stopper there, just a little tightening
needed.  The rollup below is a good staging post, I think, and much
better than the /dev/ksm version that used to be in mmotm.

Though I haven't even begun to worry about how KSM interacts with
page migration and mem cgroups and Andi & Wu's HWPOISONous pages.

Hugh
---

 arch/alpha/include/asm/mman.h     |    3 
 arch/mips/include/asm/mman.h      |    3 
 arch/parisc/include/asm/mman.h    |    3 
 arch/xtensa/include/asm/mman.h    |    3 
 include/asm-generic/mman-common.h |    3 
 include/linux/ksm.h               |   50 
 include/linux/mm.h                |    1 
 include/linux/mmu_notifier.h      |   34 
 include/linux/sched.h             |    7 
 kernel/fork.c                     |    8 
 mm/Kconfig                        |   11 
 mm/Makefile                       |    1 
 mm/ksm.c                          | 1675 ++++++++++++++++++++++++++++
 mm/madvise.c                      |   53 
 mm/memory.c                       |    9 
 mm/mmap.c                         |    6 
 mm/mmu_notifier.c                 |   20 
 17 files changed, 1857 insertions(+), 33 deletions(-)

--- 2.6.31-rc1/arch/alpha/include/asm/mman.h	2008-10-09 23:13:53.000000000 +0100
+++ madv_ksm/arch/alpha/include/asm/mman.h	2009-06-29 14:10:53.000000000 +0100
@@ -48,6 +48,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc1/arch/mips/include/asm/mman.h	2008-12-24 23:26:37.000000000 +0000
+++ madv_ksm/arch/mips/include/asm/mman.h	2009-06-29 14:10:54.000000000 +0100
@@ -71,6 +71,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc1/arch/parisc/include/asm/mman.h	2008-12-24 23:26:37.000000000 +0000
+++ madv_ksm/arch/parisc/include/asm/mman.h	2009-06-29 14:10:54.000000000 +0100
@@ -54,6 +54,9 @@
 #define MADV_16M_PAGES  24              /* Use 16 Megabyte pages */
 #define MADV_64M_PAGES  26              /* Use 64 Megabyte pages */
 
+#define MADV_MERGEABLE   65		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 66		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
--- 2.6.31-rc1/arch/xtensa/include/asm/mman.h	2009-03-23 23:12:14.000000000 +0000
+++ madv_ksm/arch/xtensa/include/asm/mman.h	2009-06-29 14:10:54.000000000 +0100
@@ -78,6 +78,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc1/include/asm-generic/mman-common.h	2009-06-25 05:18:08.000000000 +0100
+++ madv_ksm/include/asm-generic/mman-common.h	2009-06-29 14:10:54.000000000 +0100
@@ -35,6 +35,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- 2.6.31-rc1/include/linux/ksm.h	1970-01-01 01:00:00.000000000 +0100
+++ madv_ksm/include/linux/ksm.h	2009-06-29 14:10:54.000000000 +0100
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
+#include <linux/mm_types.h>
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
--- 2.6.31-rc1/include/linux/mm.h	2009-06-25 05:18:08.000000000 +0100
+++ madv_ksm/include/linux/mm.h	2009-06-29 14:10:54.000000000 +0100
@@ -105,6 +105,7 @@ extern unsigned int kobjsize(const void
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
+#define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
--- 2.6.31-rc1/include/linux/mmu_notifier.h	2008-10-09 23:13:53.000000000 +0100
+++ madv_ksm/include/linux/mmu_notifier.h	2009-06-29 14:10:54.000000000 +0100
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
 
--- 2.6.31-rc1/include/linux/sched.h	2009-06-25 05:18:09.000000000 +0100
+++ madv_ksm/include/linux/sched.h	2009-06-29 14:10:54.000000000 +0100
@@ -419,7 +419,9 @@ extern int get_dumpable(struct mm_struct
 /* dumpable bits */
 #define MMF_DUMPABLE      0  /* core dump is permitted */
 #define MMF_DUMP_SECURELY 1  /* core file is readable only by root */
+
 #define MMF_DUMPABLE_BITS 2
+#define MMF_DUMPABLE_MASK ((1 << MMF_DUMPABLE_BITS) - 1)
 
 /* coredump filter bits */
 #define MMF_DUMP_ANON_PRIVATE	2
@@ -429,6 +431,7 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMP_ELF_HEADERS	6
 #define MMF_DUMP_HUGETLB_PRIVATE 7
 #define MMF_DUMP_HUGETLB_SHARED  8
+
 #define MMF_DUMP_FILTER_SHIFT	MMF_DUMPABLE_BITS
 #define MMF_DUMP_FILTER_BITS	7
 #define MMF_DUMP_FILTER_MASK \
@@ -442,6 +445,10 @@ extern int get_dumpable(struct mm_struct
 #else
 # define MMF_DUMP_MASK_DEFAULT_ELF	0
 #endif
+					/* leave room for more dump flags */
+#define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
+
+#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
 struct sighand_struct {
 	atomic_t		count;
--- 2.6.31-rc1/kernel/fork.c	2009-06-25 05:18:09.000000000 +0100
+++ madv_ksm/kernel/fork.c	2009-06-29 14:10:54.000000000 +0100
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
--- 2.6.31-rc1/mm/Kconfig	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/Kconfig	2009-06-29 14:10:54.000000000 +0100
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
--- 2.6.31-rc1/mm/Makefile	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/Makefile	2009-06-29 14:10:54.000000000 +0100
@@ -25,6 +25,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += spars
 obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_acl.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
--- 2.6.31-rc1/mm/ksm.c	1970-01-01 01:00:00.000000000 +0100
+++ madv_ksm/mm/ksm.c	2009-06-29 14:10:54.000000000 +0100
@@ -0,0 +1,1675 @@
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
+#include <linux/hugetlb.h>
+#include <linux/rmap.h>
+#include <linux/spinlock.h>
+#include <linux/jhash.h>
+#include <linux/delay.h>
+#include <linux/kthread.h>
+#include <linux/wait.h>
+#include <linux/random.h>
+#include <linux/slab.h>
+#include <linux/rbtree.h>
+#include <linux/mmu_notifier.h>
+#include <linux/ksm.h>
+
+#include <asm/tlbflush.h>
+
+/*
+ * A few notes about the ksm scanning process,
+ * to make it easier to understand the data structures below:
+ *
+ * In order to reduce excessive scanning, ksm sorts the memory pages by their
+ * contents into a data structure that hold pointers to the pages.
+ *
+ * Since the contents of the pages may change at any moment, ksm cannot just
+ * insert the pages into a normal sorted tree and expect it to find anything.
+ *
+ * For this purpose ksm use two data structures - stable and unstable trees.
+ * The stable tree holds pointers to all the merged pages (Ksm Pages), sorted
+ * by their contents.  Because each such page has to be write-protected,
+ * searching on this tree is fully assured to be working, and therefore this
+ * tree is called the stable tree.
+ *
+ * In addition to the stable tree, ksm uses another data structure called the
+ * unstable tree: this tree holds pointers to pages that have been found to
+ * be "unchanged for a period of time".  The unstable tree sorts these pages
+ * by their contents; but since they are not write-protected, ksm cannot rely
+ * upon the unstable tree to be guaranteed to work.
+ *
+ * For the reason that the unstable tree would become corrupted when some of
+ * the page inside itself would change, the tree is called unstable.
+ * Ksm solve this problem by two ways:
+ * 1) the unstable tree get flushed every time ksm finish to scan the whole
+ *    memory, and then the tree is rebuild from the begining.
+ * 2) Ksm will only insert into the unstable tree, pages that their hash value
+ *    was not changed during the whole progress of one circuler scanning of the
+ *    memory.
+ * 3) The unstable tree is RedBlack Tree - meaning its balancing is based on
+ *    the colors of the nodes and not their content, this assure that even when
+ *    the tree get "corrupted" we wont get out of balance and the timing of
+ *    scanning is the same, another issue is that searching and inserting nodes
+ *    into rbtree is the same algorithm, therefore we have no overhead when we
+ *    flush the tree and rebuild it.
+ * 4) Ksm never flush the stable tree, this mean that even if it would take 10
+ *    times to find page inside the unstable tree, as soon as we would find it,
+ *    it will be secured inside the stable tree,
+ *    (When we scan new page, we first compare it against the stable tree, and
+ *     then against the unstable tree)
+ */
+
+/**
+ * struct mm_slot - ksm information per mm that is being scanned
+ * @link: link to the mm_slots hash list
+ * @rmap_list: head for the rmap_list list
+ * @mm_list: link into the mm_slots list, rooted in ksm_mm_head
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
+ * @seqnr: count of completed scans, for unstable_nr (and for stats)
+ *
+ * ksm uses it to know what are the next pages it need to scan
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
+ * @link: link into rmap_list (rmap_list is per mm)
+ * @mm: the memory strcture the rmap_item is pointing to.
+ * @address: the virtual address the rmap_item is pointing to.
+ * @oldchecksum: old checksum result for the page belong the virtual address
+ * @unstable_nr: tracks seqnr while in unstable tree, to help when removing
+ * @stable_tree: when 1 rmap_item is used for stable_tree, 0 unstable tree
+ * @tree_item: pointer into the stable/unstable tree that hold the virtual
+ *             address that the rmap_item is pointing to.
+ * @next: the next rmap item inside the stable/unstable tree that have that is
+ *        found inside the same tree node.
+ */
+struct rmap_item {
+	struct list_head link;
+	struct mm_struct *mm;
+	unsigned long address;
+	unsigned int oldchecksum;
+	unsigned char stable_tree;
+	unsigned char unstable_nr;
+	struct tree_item *tree_item;
+	struct rmap_item *next;
+	struct rmap_item *prev;
+};
+
+/*
+ * tree_item - object of the stable and unstable trees
+ */
+struct tree_item {
+	struct rb_node node;
+	struct rmap_item *rmap_item;
+};
+
+/* The stable and unstable tree heads */
+static struct rb_root root_stable_tree = RB_ROOT;
+static struct rb_root root_unstable_tree = RB_ROOT;
+
+static unsigned int nmm_slots_hash = 4096;
+static struct hlist_head *mm_slots_hash;
+
+static struct mm_slot ksm_mm_head = {
+	.mm_list = LIST_HEAD_INIT(ksm_mm_head.mm_list),
+};
+static struct ksm_scan ksm_scan = {
+	.mm_slot = &ksm_mm_head,
+};
+
+static struct kmem_cache *tree_item_cache;
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
+	int ret = -ENOMEM;
+
+	tree_item_cache = KSM_KMEM_CACHE(tree_item, 0);
+	if (!tree_item_cache)
+		goto out;
+
+	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
+	if (!rmap_item_cache)
+		goto out_free;
+
+	mm_slot_cache = KSM_KMEM_CACHE(mm_slot, 0);
+	if (!mm_slot_cache)
+		goto out_free1;
+
+	return 0;
+
+out_free1:
+	kmem_cache_destroy(rmap_item_cache);
+out_free:
+	kmem_cache_destroy(tree_item_cache);
+out:
+	return ret;
+}
+
+static void __init ksm_slab_free(void)
+{
+	kmem_cache_destroy(mm_slot_cache);
+	kmem_cache_destroy(rmap_item_cache);
+	kmem_cache_destroy(tree_item_cache);
+	mm_slot_cache = NULL;
+}
+
+static inline struct tree_item *alloc_tree_item(void)
+{
+	return kmem_cache_zalloc(tree_item_cache, GFP_KERNEL);
+}
+
+static void free_tree_item(struct tree_item *tree_item)
+{
+	kmem_cache_free(tree_item_cache, tree_item);
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
+static int is_present_pte(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	int present = 0;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud) || pud_huge(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd) || pmd_huge(*pmd))
+		goto out;
+
+	ptep = pte_offset_map(pmd, addr);
+	present = pte_present(*ptep);
+	pte_unmap(ptep);
+out:
+	return present;
+}
+
+/*
+ * PageKsm - these pages are the write-protected pages that ksm maps into
+ * multiple vmas: the "shared pages" or "merged pages".  All user ptes
+ * pointing to them are write-protected, so their data content cannot
+ * be changed; nor can they be swapped out (at present).
+ */
+static inline int PageKsm(struct page *page)
+{
+	/*
+	 * When ksm creates a new shared page, it uses an ordinary kernel page
+	 * allocated with alloc_page(): therefore this page is not PageAnon,
+	 * nor is it mapped from any file.  So long as we only apply this test
+	 * to VM_MERGEABLE areas, the check below is good to distinguish a ksm
+	 * page from an anonymous page or file page in that area.
+	 */
+	return page->mapping == NULL;
+}
+
+static inline void __break_cow(struct mm_struct *mm, unsigned long addr)
+{
+	struct page *page[1];
+
+	if (get_user_pages(current, mm, addr, 1, 1, 1, page, NULL) == 1)
+		put_page(page[0]);
+}
+
+static void break_cow(struct mm_struct *mm, unsigned long addr)
+{
+	down_read(&mm->mmap_sem);
+	__break_cow(mm, addr);
+	up_read(&mm->mmap_sem);
+}
+
+/*
+ * Removing rmap_item from stable or unstable tree.
+ * This function will clean the information from the stable/unstable tree
+ * and will free the tree_item if needed.
+ */
+static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
+{
+	struct tree_item *tree_item = rmap_item->tree_item;
+
+	if (rmap_item->stable_tree) {
+		ksm_pages_shared--;
+		if (rmap_item->prev) {
+			BUG_ON(rmap_item->prev->next != rmap_item);
+			rmap_item->prev->next = rmap_item->next;
+		}
+		if (rmap_item->next) {
+			BUG_ON(rmap_item->next->prev != rmap_item);
+			rmap_item->next->prev = rmap_item->prev;
+		}
+	}
+
+	if (tree_item) {
+		if (rmap_item->stable_tree) {
+			if (!rmap_item->next && !rmap_item->prev) {
+				rb_erase(&tree_item->node, &root_stable_tree);
+				free_tree_item(tree_item);
+				ksm_kernel_pages_allocated--;
+			} else if (!rmap_item->prev) {
+				BUG_ON(tree_item->rmap_item != rmap_item);
+				tree_item->rmap_item = rmap_item->next;
+			} else
+				BUG_ON(tree_item->rmap_item == rmap_item);
+		} else {
+			unsigned char age;
+			/*
+			 * ksm_thread can and must skip the rb_erase, because
+			 * root_unstable_tree was already reset to RB_ROOT.
+			 * But __ksm_exit has to be careful: do the rb_erase
+			 * if it's interrupting a scan, and this rmap_item was
+			 * inserted by this scan rather than left from before.
+			 *
+			 * Because of the case in which remove_mm_from_lists
+			 * increments seqnr before removing rmaps, unstable_nr
+			 * may even be 2 behind seqnr, but should never be
+			 * further behind.  Yes, I did have trouble with this!
+			 */
+			age = ksm_scan.seqnr - rmap_item->unstable_nr;
+			BUG_ON(age > 2);
+			if (!age)
+				rb_erase(&tree_item->node, &root_unstable_tree);
+			free_tree_item(tree_item);
+		}
+	}
+
+	rmap_item->stable_tree = 0;
+	rmap_item->tree_item = NULL;
+	rmap_item->next = NULL;
+	rmap_item->prev = NULL;
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
+static void unmerge_slot_rmap_items(struct mm_slot *mm_slot,
+				    unsigned long start, unsigned long end)
+{
+	struct rmap_item *rmap_item;
+
+	list_for_each_entry(rmap_item, &mm_slot->rmap_list, link) {
+		if (rmap_item->address < start)
+			continue;
+		if (rmap_item->address >= end)
+			break;
+		if (rmap_item->stable_tree)
+			__break_cow(mm_slot->mm, rmap_item->address);
+		/*
+		 * madvise's down_write of mmap_sem is enough to protect
+		 * us from those who list_del with down_read of mmap_sem;
+		 * but we cannot safely remove_rmap_item_from_tree without
+		 * ksm_thread_mutex, and we cannot acquire that whilst we
+		 * hold mmap_sem: so leave the cleanup to ksmd's next pass.
+		 */
+	}
+}
+
+static void unmerge_and_remove_all_rmap_items(void)
+{
+	struct mm_slot *mm_slot;
+	struct rmap_item *rmap_item, *node;
+
+	list_for_each_entry(mm_slot, &ksm_mm_head.mm_list, mm_list) {
+		down_read(&mm_slot->mm->mmap_sem);
+		list_for_each_entry_safe(rmap_item, node,
+						&mm_slot->rmap_list, link) {
+			if (rmap_item->stable_tree)
+				__break_cow(mm_slot->mm, rmap_item->address);
+			remove_rmap_item_from_tree(rmap_item);
+			list_del(&rmap_item->link);
+			free_rmap_item(rmap_item);
+		}
+		up_read(&mm_slot->mm->mmap_sem);
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
+static int __init mm_slots_hash_init(void)
+{
+	mm_slots_hash = kzalloc(nmm_slots_hash * sizeof(struct hlist_head),
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
+/*
+ * pages_identical: return 1 if identical, otherwise 0.
+ */
+static inline int pages_identical(struct page *page1, struct page *page2)
+{
+	return !memcmp_pages(page1, page2);
+}
+
+static int write_protect_page(struct page *page,
+				     struct vm_area_struct *vma,
+				     pte_t *orig_pte)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long addr;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	int swapped;
+	int ret = -EFAULT;
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
+	ret = 0;
+
+out_unlock:
+	pte_unmap_unlock(ptep, ptl);
+out:
+	return ret;
+}
+
+/**
+ * replace_page - replace page in vma with new page
+ * @vma:      vma that hold the pte oldpage is pointed by.
+ * @oldpage:  the page we are replacing with newpage
+ * @newpage:  the page we replace oldpage with
+ * @orig_pte: the original value of the pte
+ * @prot: page protection bits
+ *
+ * Returns 0 on success, -EFAULT on failure.
+ *
+ * Note: @newpage must not be an anonymous page because replace_page() does
+ * not change the mapping of @newpage to have the same values as @oldpage.
+ * @newpage can be mapped in several vmas at different offsets (page->index).
+ */
+static int replace_page(struct vm_area_struct *vma, struct page *oldpage,
+		 struct page *newpage, pte_t orig_pte, pgprot_t prot)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	unsigned long addr;
+	int ret = -EFAULT;
+
+	BUG_ON(PageAnon(newpage));
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
+	ret = 0;
+	get_page(newpage);
+	page_add_file_rmap(newpage);
+
+	flush_cache_page(vma, addr, pte_pfn(*ptep));
+	ptep_clear_flush(vma, addr, ptep);
+	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, prot));
+
+	page_remove_rmap(oldpage);
+	if (PageAnon(oldpage)) {
+		dec_mm_counter(mm, anon_rss);
+		inc_mm_counter(mm, file_rss);
+	}
+	put_page(oldpage);
+
+	pte_unmap_unlock(ptep, ptl);
+out:
+	return ret;
+}
+
+/*
+ * try_to_merge_one_page - take two pages and merge them into one
+ * @mm: mm_struct that hold vma pointing into oldpage
+ * @vma: the vma that hold the pte pointing into oldpage
+ * @oldpage: the page that we want to replace with newpage
+ * @newpage: the page that we want to map instead of oldpage
+ * @newprot: the new permission of the pte inside vma
+ * note:
+ * oldpage should be anon page while newpage should be file mapped page
+ *
+ * this function returns 0 if the pages were merged, -EFAULT otherwise.
+ */
+static int try_to_merge_one_page(struct mm_struct *mm,
+				 struct vm_area_struct *vma,
+				 struct page *oldpage,
+				 struct page *newpage,
+				 pgprot_t newprot)
+{
+	int ret = -EFAULT;
+	pte_t orig_pte = __pte(0);
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
+	if (write_protect_page(oldpage, vma, &orig_pte)) {
+		unlock_page(oldpage);
+		goto out_putpage;
+	}
+	unlock_page(oldpage);
+
+	if (pages_identical(oldpage, newpage))
+		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);
+
+out_putpage:
+	put_page(oldpage);
+	put_page(newpage);
+out:
+	return ret;
+}
+
+/*
+ * try_to_merge_two_pages_alloc - take two identical pages and prepare them
+ * to be merged into one page.
+ *
+ * this function returns 0 if we successfully mapped two identical pages
+ * into one page, -EFAULT otherwise.
+ * (note this function will allocate a new kernel page, if one of the pages
+ * is already shared page (KsmPage), then try_to_merge_two_pages_noalloc()
+ * should be called.)
+ */
+static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
+					struct page *page1,
+					struct mm_struct *mm2,
+					struct page *page2,
+					unsigned long addr1,
+					unsigned long addr2)
+{
+	struct vm_area_struct *vma;
+	pgprot_t prot;
+	struct page *kpage;
+	int ret = -EFAULT;
+
+	/*
+	 * The number of nodes in the stable tree
+	 * is the number of kernel pages that we hold.
+	 */
+	if (ksm_max_kernel_pages &&
+	    ksm_max_kernel_pages <= ksm_kernel_pages_allocated)
+		return ret;
+
+	kpage = alloc_page(GFP_HIGHUSER);
+	if (!kpage)
+		return ret;
+
+	down_read(&mm1->mmap_sem);
+	vma = find_vma(mm1, addr1);
+	if (!vma || vma->vm_start > addr1) {
+		put_page(kpage);
+		up_read(&mm1->mmap_sem);
+		return ret;
+	}
+
+	prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
+
+	copy_user_highpage(kpage, page1, addr1, vma);
+	ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot);
+	up_read(&mm1->mmap_sem);
+
+	if (!ret) {
+		down_read(&mm2->mmap_sem);
+		vma = find_vma(mm2, addr2);
+		if (!vma || vma->vm_start > addr2) {
+			put_page(kpage);
+			up_read(&mm2->mmap_sem);
+			break_cow(mm1, addr1);
+			return -EFAULT;
+		}
+
+		prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
+
+		ret = try_to_merge_one_page(mm2, vma, page2, kpage,
+					    prot);
+		up_read(&mm2->mmap_sem);
+		/*
+		 * If the second try_to_merge_one_page call was failed,
+		 * we are in situation where we have Ksm page that have
+		 * just one pte pointing to it, in this case we break
+		 * it.
+		 */
+		if (ret)
+			break_cow(mm1, addr1);
+		else
+			ksm_pages_shared += 2;
+	}
+
+	put_page(kpage);
+	return ret;
+}
+
+/*
+ * try_to_merge_two_pages_noalloc - the same astry_to_merge_two_pages_alloc,
+ * but no new kernel page is allocated (page2 should be KsmPage)
+ */
+static int try_to_merge_two_pages_noalloc(struct mm_struct *mm1,
+					  struct page *page1,
+					  struct page *page2,
+					  unsigned long addr1)
+{
+	struct vm_area_struct *vma;
+	pgprot_t prot;
+	int ret = -EFAULT;
+
+	/*
+	 * If page2 is shared, we can just make the pte of mm1(page1) point to
+	 * page2.
+	 */
+	BUG_ON(!PageKsm(page2));
+	down_read(&mm1->mmap_sem);
+	vma = find_vma(mm1, addr1);
+	if (!vma || vma->vm_start > addr1) {
+		up_read(&mm1->mmap_sem);
+		return ret;
+	}
+
+	prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
+
+	ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
+	up_read(&mm1->mmap_sem);
+	if (!ret)
+		ksm_pages_shared++;
+
+	return ret;
+}
+
+/*
+ * is_zapped_item - check if the page belong to the rmap_item was zapped.
+ *
+ * This function would check if the page that the virtual address inside
+ * rmap_item is poiting to is still KsmPage, and therefore we can trust the
+ * content of this page.
+ * Since that this function call already to get_user_pages it return the
+ * pointer to the page as an optimization.
+ */
+static int is_zapped_item(struct rmap_item *rmap_item,
+			  struct page **page)
+{
+	struct vm_area_struct *vma;
+	int ret = 0;
+
+	cond_resched();
+	down_read(&rmap_item->mm->mmap_sem);
+	if (is_present_pte(rmap_item->mm, rmap_item->address)) {
+		vma = find_vma(rmap_item->mm, rmap_item->address);
+		if (vma && (vma->vm_flags & VM_MERGEABLE)) {
+			ret = get_user_pages(current, rmap_item->mm,
+					     rmap_item->address,
+					     1, 0, 0, page, NULL);
+		}
+	}
+	up_read(&rmap_item->mm->mmap_sem);
+
+	if (ret != 1)
+		return 1;
+
+	if (unlikely(!PageKsm(page[0]))) {
+		put_page(page[0]);
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * stable_tree_search - search page inside the stable tree
+ * @page: the page that we are searching identical pages to.
+ * @page2: pointer into identical page that we are holding inside the stable
+ *	   tree that we have found.
+ * @rmap_item: the reverse mapping item
+ *
+ * this function check if there is a page inside the stable tree
+ * with identical content to the page that we are scanning right now.
+ *
+ * this function return rmap_item pointer to the identical item if found, NULL
+ * otherwise.
+ */
+static struct rmap_item *stable_tree_search(struct page *page,
+					    struct page **page2,
+					    struct rmap_item *rmap_item)
+{
+	struct rb_node *node = root_stable_tree.rb_node;
+	struct tree_item *tree_item;
+	struct rmap_item *found_rmap_item, *next_rmap_item;
+
+	while (node) {
+		int ret;
+
+		tree_item = rb_entry(node, struct tree_item, node);
+		found_rmap_item = tree_item->rmap_item;
+		while (found_rmap_item) {
+			BUG_ON(!found_rmap_item->stable_tree);
+			BUG_ON(!found_rmap_item->tree_item);
+			if (!rmap_item ||
+			     !(found_rmap_item->mm == rmap_item->mm &&
+			      found_rmap_item->address == rmap_item->address)) {
+				if (!is_zapped_item(found_rmap_item, page2))
+					break;
+				next_rmap_item = found_rmap_item->next;
+				remove_rmap_item_from_tree(found_rmap_item);
+				found_rmap_item = next_rmap_item;
+			} else
+				found_rmap_item = found_rmap_item->next;
+		}
+		if (!found_rmap_item)
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
+			return found_rmap_item;
+		}
+	}
+
+	return NULL;
+}
+
+/*
+ * stable_tree_insert - insert into the stable tree, new rmap_item that is
+ * pointing into a new KsmPage.
+ *
+ * @page: the page that we are searching identical page to inside the stable
+ *	  tree.
+ * @new_tree_item: the new tree item we are going to link into the stable tree.
+ * @rmap_item: pointer into the reverse mapping item.
+ *
+ * this function return 0 if success, -EFAULT otherwise.
+ */
+static int stable_tree_insert(struct page *page,
+			      struct tree_item *new_tree_item,
+			      struct rmap_item *rmap_item)
+{
+	struct rb_node **new = &root_stable_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct tree_item *tree_item;
+	struct page *page2[1];
+
+	while (*new) {
+		int ret;
+		struct rmap_item *insert_rmap_item, *next_rmap_item;
+
+		tree_item = rb_entry(*new, struct tree_item, node);
+		insert_rmap_item = tree_item->rmap_item;
+		while (insert_rmap_item) {
+			BUG_ON(!insert_rmap_item->stable_tree);
+			BUG_ON(!insert_rmap_item->tree_item);
+			if (!(insert_rmap_item->mm == rmap_item->mm &&
+			     insert_rmap_item->address == rmap_item->address)) {
+				if (!is_zapped_item(insert_rmap_item, page2))
+					break;
+				next_rmap_item = insert_rmap_item->next;
+				remove_rmap_item_from_tree(insert_rmap_item);
+				insert_rmap_item = next_rmap_item;
+			} else
+				insert_rmap_item = insert_rmap_item->next;
+		}
+		if (!insert_rmap_item)
+			return -EFAULT;
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
+			 * It isn't a bug when we are here (the fact that
+			 * we didn't find the page inside the stable tree),
+			 * because when we searched for the page inside the
+			 * stable tree it was still not write-protected,
+			 * and therefore it could have changed later.
+			 */
+			return -EFAULT;
+		}
+	}
+
+	ksm_kernel_pages_allocated++;
+	rmap_item->stable_tree = 1;
+	rmap_item->tree_item = new_tree_item;
+	rb_link_node(&new_tree_item->node, parent, new);
+	rb_insert_color(&new_tree_item->node, &root_stable_tree);
+
+	return 0;
+}
+
+/*
+ * unstable_tree_search_insert - search and insert items into the unstable tree.
+ *
+ * @page: the page that we are going to search for identical page or to insert
+ *	  into the unstable tree
+ * @page2: pointer into identical page that was found inside the unstable tree
+ * @page_rmap_item: the reverse mapping item of page
+ *
+ * this function search if identical page to the page that we
+ * are scanning right now is found inside the unstable tree, and in case no page
+ * with identical content is exist inside the unstable tree, we insert
+ * page_rmap_item as a new object into the unstable tree.
+ *
+ * this function return pointer to rmap_item pointer of item that is found to
+ * be identical to the page that we are scanning right now, NULL otherwise.
+ *
+ * (this function do both searching and inserting, because the fact that
+ *  searching and inserting share the same walking algorithem in rbtrees)
+ */
+static struct rmap_item *unstable_tree_search_insert(struct page *page,
+					struct page **page2,
+					struct rmap_item *page_rmap_item)
+{
+	struct rb_node **new = &root_unstable_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct tree_item *tree_item;
+	struct tree_item *new_tree_item;
+	struct rmap_item *rmap_item;
+
+	while (*new) {
+		int ret;
+
+		tree_item = rb_entry(*new, struct tree_item, node);
+		rmap_item = tree_item->rmap_item;
+
+		down_read(&rmap_item->mm->mmap_sem);
+		/*
+		 * We don't want to swap in pages
+		 */
+		if (!is_present_pte(rmap_item->mm, rmap_item->address)) {
+			up_read(&rmap_item->mm->mmap_sem);
+			return NULL;
+		}
+
+		ret = get_user_pages(current, rmap_item->mm, rmap_item->address,
+				     1, 0, 0, page2, NULL);
+		up_read(&rmap_item->mm->mmap_sem);
+		if (ret != 1)
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
+			return rmap_item;
+		}
+	}
+
+	if (!page_rmap_item)
+		return NULL;
+
+	new_tree_item = alloc_tree_item();
+	if (!new_tree_item)
+		return NULL;
+
+	page_rmap_item->unstable_nr = ksm_scan.seqnr;	/* truncated */
+	page_rmap_item->tree_item = new_tree_item;
+	new_tree_item->rmap_item = page_rmap_item;
+	rb_link_node(&new_tree_item->node, parent, new);
+	rb_insert_color(&new_tree_item->node, &root_unstable_tree);
+
+	return NULL;
+}
+
+/*
+ * insert_to_stable_tree_list - insert another rmap_item into the linked list
+ * rmap_items of a given node inside the stable tree.
+ */
+static void insert_to_stable_tree_list(struct rmap_item *rmap_item,
+				       struct rmap_item *tree_rmap_item)
+{
+	rmap_item->next = tree_rmap_item->next;
+	rmap_item->prev = tree_rmap_item;
+
+	if (tree_rmap_item->next)
+		tree_rmap_item->next->prev = rmap_item;
+
+	tree_rmap_item->next = rmap_item;
+
+	rmap_item->stable_tree = 1;
+	rmap_item->tree_item = tree_rmap_item->tree_item;
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
+	int ret;
+
+	if (rmap_item->stable_tree)
+		remove_rmap_item_from_tree(rmap_item);
+
+	/* We first start with searching the page inside the stable tree */
+	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
+	if (tree_rmap_item) {
+		BUG_ON(!tree_rmap_item->tree_item);
+
+		if (page == page2[0]) {		/* forked */
+			ksm_pages_shared++;
+			ret = 0;
+		} else
+			ret = try_to_merge_two_pages_noalloc(rmap_item->mm,
+							    page, page2[0],
+							    rmap_item->address);
+		put_page(page2[0]);
+
+		if (!ret) {
+			/*
+			 * The page was successfully merged, let's insert its
+			 * rmap_item into the stable tree.
+			 */
+			insert_to_stable_tree_list(rmap_item, tree_rmap_item);
+		}
+		return;
+	}
+
+	/*
+	 * A ksm page might have got here by fork or by mremap move, but
+	 * its other references have already been removed from the tree.
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
+		struct tree_item *tree_item;
+		struct mm_struct *tree_mm;
+		unsigned long tree_addr;
+
+		tree_item = tree_rmap_item->tree_item;
+		tree_mm = tree_rmap_item->mm;
+		tree_addr = tree_rmap_item->address;
+
+		ret = try_to_merge_two_pages_alloc(rmap_item->mm, page, tree_mm,
+						   page2[0], rmap_item->address,
+						   tree_addr);
+		/*
+		 * As soon as we successfully merge this page, we want to remove
+		 * the rmap_item object of the page that we have merged with
+		 * from the unstable_tree and instead insert it as a new stable
+		 * tree node.
+		 */
+		if (!ret) {
+			rb_erase(&tree_item->node, &root_unstable_tree);
+			/*
+			 * If we fail to insert the page into the stable tree,
+			 * we will have 2 virtual addresses that are pointing
+			 * to a KsmPage left outside the stable tree,
+			 * in which case we need to break_cow on both.
+			 */
+			if (stable_tree_insert(page2[0], tree_item,
+					       tree_rmap_item) == 0) {
+				insert_to_stable_tree_list(rmap_item,
+							   tree_rmap_item);
+			} else {
+				free_tree_item(tree_item);
+				tree_rmap_item->tree_item = NULL;
+				break_cow(tree_mm, tree_addr);
+				break_cow(rmap_item->mm, rmap_item->address);
+				ksm_pages_shared -= 2;
+			}
+		}
+
+		put_page(page2[0]);
+	}
+}
+
+static struct mm_slot *get_mm_slot(struct mm_struct *mm)
+{
+	struct mm_slot *mm_slot;
+	struct hlist_head *bucket;
+	struct hlist_node *node;
+
+	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
+				% nmm_slots_hash];
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
+				% nmm_slots_hash];
+	mm_slot->mm = mm;
+	INIT_LIST_HEAD(&mm_slot->rmap_list);
+	hlist_add_head(&mm_slot->link, bucket);
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
+	 * called from scan_get_next_rmap_item; but that's a special
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
+/*
+ * update_rmap_list - nuke every rmap_item above the current rmap_item.
+ */
+static void update_rmap_list(struct list_head *head, struct list_head *cur)
+{
+	struct rmap_item *rmap_item;
+
+	cur = cur->next;
+	while (cur != head) {
+		rmap_item = list_entry(cur, struct rmap_item, link);
+		cur = cur->next;
+		remove_rmap_item_from_tree(rmap_item);
+		list_del(&rmap_item->link);
+		free_rmap_item(rmap_item);
+	}
+}
+
+static struct rmap_item *get_next_rmap_item(unsigned long addr,
+					    struct mm_struct *mm,
+					    struct list_head *head,
+					    struct list_head *cur)
+{
+	struct rmap_item *rmap_item;
+
+	cur = cur->next;
+	while (cur != head) {
+		rmap_item = list_entry(cur, struct rmap_item, link);
+		if (rmap_item->address == addr) {
+			if (!rmap_item->stable_tree)
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
+		rmap_item->mm = mm;
+		rmap_item->address = addr;
+		list_add_tail(&rmap_item->link, cur);
+	}
+	return rmap_item;
+}
+
+static struct rmap_item *scan_get_next_rmap_item(void)
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
+	vma = find_vma(mm, ksm_scan.address);
+	while (vma && !(vma->vm_flags & VM_MERGEABLE))
+		vma = vma->vm_next;
+
+	if (vma) {
+		if (ksm_scan.address < vma->vm_start)
+			ksm_scan.address = vma->vm_start;
+		rmap_item = get_next_rmap_item(ksm_scan.address, mm,
+				&slot->rmap_list, &ksm_scan.rmap_item->link);
+		up_read(&mm->mmap_sem);
+
+		if (rmap_item) {
+			ksm_scan.rmap_item = rmap_item;
+			ksm_scan.address += PAGE_SIZE;	/* ready for next */
+		}
+		return rmap_item;
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
+	update_rmap_list(&slot->rmap_list, &ksm_scan.rmap_item->link);
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
+ * @ksm_scan    - the scanner.
+ * @scan_npages - number of pages we want to scan before we return.
+ */
+static void ksm_do_scan(unsigned int scan_npages)
+{
+	struct page *page[1];
+	struct mm_struct *mm;
+	struct rmap_item *rmap_item;
+	unsigned long addr;
+	int val;
+
+	while (scan_npages--) {
+		cond_resched();
+
+		rmap_item = scan_get_next_rmap_item();
+		if (!rmap_item)
+			return;
+
+		mm = rmap_item->mm;
+		addr = rmap_item->address;
+
+		/*
+		 * If page is not present, don't waste time faulting it in.
+		 */
+		down_read(&mm->mmap_sem);
+		if (is_present_pte(mm, addr)) {
+			val = get_user_pages(current, mm, addr, 1, 0, 0, page,
+					     NULL);
+			up_read(&mm->mmap_sem);
+			if (val == 1) {
+				if (!PageKsm(page[0]) ||
+				    !rmap_item->stable_tree)
+					cmp_and_merge_page(page[0], rmap_item);
+				put_page(page[0]);
+			}
+		} else {
+			up_read(&mm->mmap_sem);
+		}
+	}
+}
+
+static int ksm_scan_thread(void *nothing)
+{
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
+	struct mm_slot *mm_slot;
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
+		if (vma->vm_file || vma->vm_ops)
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
+		spin_lock(&ksm_mmlist_lock);
+		mm_slot = get_mm_slot(mm);
+		spin_unlock(&ksm_mmlist_lock);
+
+		unmerge_slot_rmap_items(mm_slot, start, end);
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
+	ksm_run = flags;
+	if (flags & KSM_RUN_UNMERGE)
+		unmerge_and_remove_all_rmap_items();
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
+	int ret;
+
+	ret = ksm_slab_init();
+	if (ret)
+		goto out;
+
+	ret = mm_slots_hash_init();
+	if (ret)
+		goto out_free1;
+
+	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
+	if (IS_ERR(ksm_thread)) {
+		printk(KERN_ERR "ksm: creating kthread failed\n");
+		ret = PTR_ERR(ksm_thread);
+		goto out_free2;
+	}
+
+	ret = sysfs_create_group(mm_kobj, &ksm_attr_group);
+	if (ret) {
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
+	return ret;
+}
+module_init(ksm_init)
--- 2.6.31-rc1/mm/madvise.c	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/madvise.c	2009-06-29 14:10:54.000000000 +0100
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
--- 2.6.31-rc1/mm/memory.c	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/memory.c	2009-06-29 14:10:54.000000000 +0100
@@ -2115,9 +2115,14 @@ gotten:
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
--- 2.6.31-rc1/mm/mmap.c	2009-06-25 05:18:10.000000000 +0100
+++ madv_ksm/mm/mmap.c	2009-06-29 14:10:54.000000000 +0100
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
--- 2.6.31-rc1/mm/mmu_notifier.c	2008-10-09 23:13:53.000000000 +0100
+++ madv_ksm/mm/mmu_notifier.c	2009-06-29 14:10:54.000000000 +0100
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
