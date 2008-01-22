Date: Tue, 22 Jan 2008 12:34:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
In-Reply-To: <20080122200858.GB15848@v2.random>
Message-ID: <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
References: <20080113162418.GE8736@v2.random> <20080116124256.44033d48@bree.surriel.com>
 <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random>
 <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random>
 <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com>
 <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Andrea Arcangeli wrote:

> This last update avoids the need to refresh the young bit in the linux
> pte through follow_page and it allows tracking the accessed bits set
> by the hardware in the sptes without requiring vmexits in certain
> implementations.

The problem that I have with this is still that there is no way to sleep 
while running the notifier. We need to invalidate mappings on a remote 
instance of linux. This means sending out a message and waiting for reply 
before the local page is unmapped. So I reworked Andrea's early patch and 
came up with this one:


Export notifiers: Callbacks for external references to VM pages

This patch provides callbacks for external subsystems (such as DMA engines,
RDMA, XPMEM) that allow these subsystems to know when the VM is unmapping
pages. It is loosely based on Andrea's mmu_ops patch #2.

A subsystem can export pages by

1. Marking a series of pages using SetPageExported()

This means callbacks will occur if these pages are individually unmapped.

2. Marking a mm_struct with MMF_EXPORTED

This results in callbacks when the process exits or when ranges in the
mm structs are removed. Pages marked with PageExported() must at least
have one mm that has MMF_EXPORTED set. The subsystem can determine that
no pages are exported anymore through the release callbacks and then
terminate operations.

Callbacks in general are made early before any spinlocks are taken. This
means it is possible to communicate with another instance of Linux that
may have cross mapped the page using f.e. PFN_MAP and only proceed to
unmap the page after confirmation has been received that the remote
side has removed the pte.

This also allows the user of the export notifier to utilize its
own reverse maps to find external ptes that need to be cleaned.
(There is nothing that prohibits the use of the anon/inode
rmaps either. The exporter may drop the locks and rescan
the list in its own scanning of the lists if needed).

Issues with mmu_ops #2

- Notifiers are called *after* we tore down ptes. At that point pages
  may already have been freed and reused. This means that there can
  still be uses of the page by the user of mmu_ops after the OS has
  dropped its mapping. IMHO the foreign entity needs to drop its
  mappings first. That also ensures that the entities operated
  upon continue to exist.

- anon_vma/inode and pte locks are held during callbacks.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/export_notifier.h |   80 ++++++++++++++++++++++++++++++++++++++++
 include/linux/page-flags.h      |    9 ++++
 include/linux/sched.h           |    1 
 mm/Kconfig                      |    6 +++
 mm/Makefile                     |    1 
 mm/export_notifier.c            |   15 +++++++
 mm/hugetlb.c                    |    3 +
 mm/memory.c                     |   10 +++++
 mm/mmap.c                       |    7 +++
 mm/mprotect.c                   |    4 ++
 mm/rmap.c                       |   10 +++++
 11 files changed, 146 insertions(+)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-01-18 12:13:10.195895516 -0800
+++ linux-2.6/mm/memory.c	2008-01-18 13:41:11.650547393 -0800
@@ -59,6 +59,7 @@
 
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/export_notifier.h>
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
@@ -1349,6 +1350,9 @@ int remap_pfn_range(struct vm_area_struc
 
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 
+	if (mm->flags & MMF_EXPORTED)
+		export_notifier(invalidate_process_range, mm, addr, end);
+
 	BUG_ON(addr >= end);
 	pfn -= addr >> PAGE_SHIFT;
 	pgd = pgd_offset(mm, addr);
@@ -1447,6 +1451,10 @@ int apply_to_page_range(struct mm_struct
 	int err;
 
 	BUG_ON(addr >= end);
+
+	if (mm->flags & MMF_EXPORTED)
+		export_notifier(invalidate_process_range, mm, addr, end);
+
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1878,6 +1886,8 @@ void unmap_mapping_range(struct address_
 		details.last_index = ULONG_MAX;
 	details.i_mmap_lock = &mapping->i_mmap_lock;
 
+	export_notifier(invalidate_mapping_range, mapping, holebegin, holelen);
+
 	spin_lock(&mapping->i_mmap_lock);
 
 	/* Protect against endless unmapping loops */
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c	2007-11-09 14:48:48.394445680 -0800
+++ linux-2.6/mm/mprotect.c	2008-01-18 14:34:39.241295334 -0800
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/export_notifier.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -269,6 +270,9 @@ sys_mprotect(unsigned long start, size_t
 	if (start > vma->vm_start)
 		prev = vma;
 
+	if (current->mm->flags & MMF_EXPORTED)
+		export_notifier(invalidate_process_range, current->mm, start, end);
+
 	for (nstart = start ; ; ) {
 		unsigned long newflags;
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-01-07 14:21:02.072452263 -0800
+++ linux-2.6/mm/rmap.c	2008-01-18 13:41:11.670547733 -0800
@@ -49,6 +49,7 @@
 #include <linux/rcupdate.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/export_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -356,6 +357,9 @@ static int page_referenced_file(struct p
 	 */
 	BUG_ON(!PageLocked(page));
 
+	if (unlikely(PageExported(page)))
+		export_notifier(determine_references, page, &referenced);
+
 	spin_lock(&mapping->i_mmap_lock);
 
 	/*
@@ -469,6 +473,9 @@ int page_mkclean(struct page *page)
 
 	BUG_ON(!PageLocked(page));
 
+	if (unlikely(PageExported(page)))
+		export_notifier(invalidate_page, page);
+
 	if (page_mapped(page)) {
 		struct address_space *mapping = page_mapping(page);
 		if (mapping) {
@@ -966,6 +973,9 @@ int try_to_unmap(struct page *page, int 
 
 	BUG_ON(!PageLocked(page));
 
+	if (unlikely(PageExported(page)))
+		export_notifier(invalidate_page, page);
+
 	if (PageAnon(page))
 		ret = try_to_unmap_anon(page, migration);
 	else
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2008-01-07 14:21:02.044451642 -0800
+++ linux-2.6/mm/Kconfig	2008-01-18 13:41:11.682547939 -0800
@@ -193,3 +193,9 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config EXPORT_NOTIFIER
+	def_bool y
+	depends on 64BIT
+	bool "Export Notifier for notifying subsystems about changes to page mappings"
+
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2007-11-27 17:29:40.152962721 -0800
+++ linux-2.6/mm/Makefile	2008-01-18 13:41:11.686548010 -0800
@@ -30,4 +30,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_EXPORT_NOTIFIER) += export_notifier.o
 
Index: linux-2.6/mm/export_notifier.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/export_notifier.c	2008-01-18 14:05:28.551481181 -0800
@@ -0,0 +1,15 @@
+#include <linux/export_notifier.h>
+
+LIST_HEAD(export_notifier_list);
+
+void export_notifier_register(struct export_notifier *em)
+{
+	list_add(&em->list, &export_notifier_list);
+}
+
+void export_notifier_unregister(struct export_notifier *em)
+{
+	list_del(&em->list);
+}
+
+
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-01-14 12:55:46.667413772 -0800
+++ linux-2.6/mm/hugetlb.c	2008-01-18 13:41:11.722548622 -0800
@@ -776,6 +776,9 @@ void unmap_hugepage_range(struct vm_area
 	 * do nothing in this case.
 	 */
 	if (vma->vm_file) {
+		if (vma->vm_vm->flags & MMF_EXPORTED)
+			export_notifier(invalidate_process_range, start, end);
+
 		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 		__unmap_hugepage_range(vma, start, end);
 		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-01-07 14:21:02.060451804 -0800
+++ linux-2.6/mm/mmap.c	2008-01-18 13:41:11.730548760 -0800
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/export_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1739,6 +1740,9 @@ static void unmap_region(struct mm_struc
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
+	if (mm->flags & MMF_EXPORTED)
+		export_notifier(invalidate_process_range, mm, start, end);
+
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
@@ -2044,6 +2048,9 @@ void exit_mmap(struct mm_struct *mm)
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
+	if (mm->flags & MMF_EXPORTED)
+		export_notifier(release, mm);
+
 	/*
 	 * Walk the list again, actually closing and freeing it,
 	 * with preemption enabled, without holding any MM locks.
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2007-11-08 13:50:46.427607787 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-01-18 13:41:11.742548966 -0800
@@ -105,6 +105,7 @@
  * 64 bit  |           FIELDS             | ??????         FLAGS         |
  *         63                            32                              0
  */
+#define PG_exported		30	/* Page is referenced by something not in the rmaps */
 #define PG_uncached		31	/* Page has been mapped as uncached */
 #endif
 
@@ -260,6 +261,14 @@ static inline void __ClearPageTail(struc
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#ifdef CONFIG_EXPORT_NOTIFIER
+#define PageExported(page)	test_bit(PG_exported, &(page)->flags)
+#define SetPageExported(page)	set_bit(PG_exported, &(page)->flags)
+#define ClearPageExported(page)	clear_bit(PG_exported, &(page)->flags)
+#else
+#define PageExported(page)	0
+#endif
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h	2008-01-14 12:55:46.591413423 -0800
+++ linux-2.6/include/linux/sched.h	2008-01-18 13:41:11.754549168 -0800
@@ -372,6 +372,7 @@ extern int get_dumpable(struct mm_struct
 	(((1 << MMF_DUMP_FILTER_BITS) - 1) << MMF_DUMP_FILTER_SHIFT)
 #define MMF_DUMP_FILTER_DEFAULT \
 	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
+#define MMF_EXPORTED		7	/* mm struct has externally referenced pages */
 
 struct sighand_struct {
 	atomic_t		count;
Index: linux-2.6/include/linux/export_notifier.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/export_notifier.h	2008-01-18 14:31:59.654580722 -0800
@@ -0,0 +1,80 @@
+#ifndef _LINUX_EXPORT_NOTIFIER_H
+#define _LINUX_EXPORT_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/mm_types.h>
+
+struct export_notifier {
+	struct list_head list;
+	const struct export_notifier_ops *ops;
+};
+
+struct address_space;
+
+struct export_notifier_ops {
+	/*
+	 * Called when exiting a process to release all resources
+	 */
+	void (*release)(struct export_notifier *em, struct mm_struct *mm);
+
+	/*
+	 * Called with the page lock held before ptes are modified or removed.
+	 *
+	 * Must clear PageExported()
+	 */
+	void (*invalidate_page)(struct export_notifier *em, struct page *page);
+
+	/*
+	 * Called with mmap_sem held before a range of ptes is modified or removed.
+	 *
+	 * Must clear all PageExported for all pages in the range
+	 */
+	void (*invalidate_process_range)(struct export_notifier *em,
+		struct mm_struct *mm,
+		unsigned long start, unsigned long end);
+
+	/*
+	 * Called before the pages in mapping are removed.
+	 *
+	 * Must clear all PageExported for all pages in the range that
+	 * are owned by the subsystem.
+	 */
+	void (*invalidate_mapping_range)(struct export_notifier *em,
+		struct address_space *mapping,
+		unsigned long start, unsigned long end);
+
+	/*
+	 * Determine the external references held to a page and
+	 * increment the int pointed to by that amount.
+	 */
+	void (*determine_references)(struct export_notifier *em,
+		struct page *page, int *references);
+};
+
+#ifdef CONFIG_EXPORT_NOTIFIER
+
+extern void export_notifier_register(struct export_notifier *em);
+extern void export_notifier_unregister(struct export_notifier *em);
+extern void export_notifier_release(struct export_notifier *em);
+
+extern struct list_head export_notifier_list;
+
+#define export_notifier(function, args...)				\
+	do {								\
+		struct export_notifier *__em;				\
+									\
+		list_for_each_entry(__em, &export_notifier_list, list)	\
+			if (__em->ops->function)			\
+				__em->ops->function(__em, args);	\
+	} while (0);
+
+#else
+
+#define export_notifier(function, args...)
+
+static inline void export_notifier_register(struct export_notifier *em) {}
+static inline void export_notifier_unregister(struct export_notifier *em) {}
+
+#endif
+
+#endif /* _LINUX_EXPORT_NOTIFIER_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
