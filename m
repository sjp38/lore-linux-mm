From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 1/4] mmu_notifier: Core code
Date: Thu, 31 Jan 2008 21:04:40 -0800
Message-ID: <20080201050623.112641539@sgi.com>
References: <20080201050439.009441434@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=mmu_core
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
List-Id: linux-mm.kvack.org

Notifier functions for hardware and software that establishes external
references to pages of a Linux system. The notifier calls ensure that
external mappings are removed when the Linux VM removes memory ranges
or individual pages from a process.

This first portion is fitting for external mmu's that do not have their
own rmap or need the ability to sleep before removing individual pages.

Two categories of external mmus are possible:

1. KVM style external mmus that have their own page table.
   These are capable of tracking pages in their page tables and
   can therefore increase the refcount on pages. An increased
   refcount guarantees page existence regardless of the vms unmapping
   actions until the logic in the notifier call decides to drop a page.

2. GRU style external mmus that rely on the Linux page table for TLB lookups.
   These cannot track pages that are externally references.
   TLB entries can only be evicted as necessary.


Callbacks are registered with an mm_struct from a device drivers using
mmu_notifier_register. When the VM removes pages (or restricts
permissions on pages) then callbacks are triggered

The VM holds spinlocks in order to walk reverse maps in rmap.c. The single
page callback invalidate_page() is therefore always run with
spinlocks held (which limits what can be done in the callbacks).

The invalidate_range_start/end callbacks can be run in atomic as well as
sleepable contexts. A flag is passed to indicate an atomic context.
The notifier may decide to defer actions if the context is atomic.

Pages must be marked dirty if dirty bits are found to be set in
the external ptes.

Requirements on synchronization within the driver:

     Multiple invalidate_range_begin/ends may be nested or called
     concurrently. That is legit. However, no new external references
     may be established as long as any invalidate_xxx is running or as long
     as any invalidate_range_begin() and has not been completed through a
     corresponding call to invalidate_range_end().

     Locking within the notifier callbacks needs to serialize events
     correspondingly. One simple implementation would be the use of a spinlock
     that needs to be acquired for access to the page table or tlb managed by
     the driver. A rw lock could be used to allow multiplel concurrent invalidates
     to run but then the driver needs to have additional internal synchronization
     for access to hardware resources.

     If all invalidate_xx notifier calls take the driver lock then it is possible
     to run follow_page() under the same lock. The lock can then guarantee
     that no page is removed and provides an additional existence guarantee
     of the page independent of the page count.

     invalidate_range_begin() must clear all references in the range
     and stop the establishment of new references.

     invalidate_range_end() reenables the establishment of references.
     The atomic paramater passed to invalidatge_range_xx indicates that the function
     is called in an atomic context. We can sleep if atomic == 0.

Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Signed-off-by: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>

---
 include/linux/mm_types.h     |    8 +
 include/linux/mmu_notifier.h |  179 +++++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c                |    2 
 mm/Kconfig                   |    4 
 mm/Makefile                  |    1 
 mm/mmap.c                    |    2 
 mm/mmu_notifier.c            |   76 ++++++++++++++++++
 7 files changed, 272 insertions(+)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2008-01-31 19:55:46.000000000 -0800
+++ linux-2.6/include/linux/mm_types.h	2008-01-31 19:59:51.000000000 -0800
@@ -153,6 +153,12 @@ struct vm_area_struct {
 #endif
 };
 
+struct mmu_notifier_head {
+#ifdef CONFIG_MMU_NOTIFIER
+	struct hlist_head head;
+#endif
+};
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -219,6 +225,8 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+
+	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mmu_notifier.h	2008-01-31 20:56:03.000000000 -0800
@@ -0,0 +1,179 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+/*
+ * MMU motifier
+ *
+ * Notifier functions for hardware and software that establishes external
+ * references to pages of a Linux system. The notifier calls ensure that
+ * external mappings are removed when the Linux VM removes memory ranges
+ * or individual pages from a process.
+ *
+ * These fall into two classes:
+ *
+ * 1. mmu_notifier
+ *
+ * 	These are callbacks registered with an mm_struct. If pages are
+ * 	removed from an address space then callbacks are performed.
+ *
+ * 	Spinlocks must be held in order to walk reverse maps. The
+ * 	invalidate_page() callbacks are performed with spinlocks are held.
+ *
+ * 	The invalidate_range_start/end callbacks can be performed in contexts
+ * 	where sleeping is allowed or in atomic contexts. A flag is passed
+ * 	to indicate an atomic context.
+ *
+ *	Pages must be marked dirty if dirty bits are found to be set in
+ *	the external ptes.
+ */
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/rcupdate.h>
+#include <linux/mm_types.h>
+
+struct mmu_notifier_ops;
+
+struct mmu_notifier {
+	struct hlist_node hlist;
+	const struct mmu_notifier_ops *ops;
+};
+
+struct mmu_notifier_ops {
+	/*
+	 * The release notifier is called when no other execution threads
+	 * are left. Synchronization is not necessary.
+	 */
+	void (*release)(struct mmu_notifier *mn,
+			struct mm_struct *mm);
+
+	/*
+	 * age_page is called from contexts where the pte_lock is held
+	 */
+	int (*age_page)(struct mmu_notifier *mn,
+			struct mm_struct *mm,
+			unsigned long address);
+
+	/* invalidate_page is called from contexts where the pte_lock is held */
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+
+	/*
+	 * invalidate_range_begin() and invalidate_range_end() must paired.
+	 *
+	 * Multiple invalidate_range_begin/ends may be nested or called
+	 * concurrently. That is legit. However, no new external references
+	 * may be established as long as any invalidate_xxx is running or
+	 * any invalidate_range_begin() and has not been completed through a
+	 * corresponding call to invalidate_range_end().
+	 *
+	 * Locking within the notifier needs to serialize events correspondingly.
+	 *
+	 * If all invalidate_xx notifier calls take a driver lock then it is possible
+	 * to run follow_page() under the same lock. The lock can then guarantee
+	 * that no page is removed and provides an additional existence guarantee
+	 * of the page.
+	 *
+	 * invalidate_range_begin() must clear all references in the range
+	 * and stop the establishment of new references.
+	 *
+	 * invalidate_range_end() reenables the establishment of references.
+	 *
+	 * atomic indicates that the function is called in an atomic context.
+	 * We can sleep if atomic == 0.
+	 */
+	void (*invalidate_range_begin)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end,
+				 int atomic);
+
+	void (*invalidate_range_end)(struct mmu_notifier *mn,
+				 unsigned long stat, unsigned long end,
+				 struct mm_struct *mm, int atomic);
+};
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+/*
+ * Must hold the mmap_sem for write.
+ *
+ * RCU is used to traverse the list. A quiescent period needs to pass
+ * before the notifier is guaranteed to be visible to all threads
+ */
+extern void mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+
+/*
+ * Must hold mmap_sem for write.
+ *
+ * A quiescent period needs to pass before the mmu_notifier structure
+ * can be released. mmu_notifier_release() will wait for a quiescent period
+ * after calling the ->release callback. So it is safe to call
+ * mmu_notifier_unregister from the ->release function.
+ */
+extern void mmu_notifier_unregister(struct mmu_notifier *mn,
+				    struct mm_struct *mm);
+
+
+extern void mmu_notifier_release(struct mm_struct *mm);
+extern int mmu_notifier_age_page(struct mm_struct *mm,
+				 unsigned long address);
+
+static inline void mmu_notifier_head_init(struct mmu_notifier_head *mnh)
+{
+	INIT_HLIST_HEAD(&mnh->head);
+}
+
+#define mmu_notifier(function, mm, args...)				\
+	do {								\
+		struct mmu_notifier *__mn;				\
+		struct hlist_node *__n;					\
+									\
+		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
+			rcu_read_lock();				\
+			hlist_for_each_entry_rcu(__mn, __n,		\
+					     &(mm)->mmu_notifier.head,	\
+					     hlist)			\
+				if (__mn->ops->function)		\
+					__mn->ops->function(__mn,	\
+							    mm,		\
+							    args);	\
+			rcu_read_unlock();				\
+		}							\
+	} while (0)
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+/*
+ * Notifiers that use the parameters that they were passed so that the
+ * compiler does not complain about unused variables but does proper
+ * parameter checks even if !CONFIG_MMU_NOTIFIER.
+ * Macros generate no code.
+ */
+#define mmu_notifier(function, mm, args...)				\
+	do {								\
+		if (0) {						\
+			struct mmu_notifier *__mn;			\
+									\
+			__mn = (struct mmu_notifier *)(0x00ff);		\
+			__mn->ops->function(__mn, mm, args);		\
+		};							\
+	} while (0)
+
+static inline void mmu_notifier_register(struct mmu_notifier *mn,
+						struct mm_struct *mm) {}
+static inline void mmu_notifier_unregister(struct mmu_notifier *mn,
+						struct mm_struct *mm) {}
+static inline void mmu_notifier_release(struct mm_struct *mm) {}
+static inline int mmu_notifier_age_page(struct mm_struct *mm,
+				unsigned long address)
+{
+	return 0;
+}
+
+static inline void mmu_notifier_head_init(struct mmu_notifier_head *mmh) {}
+
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif /* _LINUX_MMU_NOTIFIER_H */
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2008-01-31 19:55:46.000000000 -0800
+++ linux-2.6/mm/Kconfig	2008-01-31 19:59:51.000000000 -0800
@@ -193,3 +193,7 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config MMU_NOTIFIER
+	def_bool y
+	bool "MMU notifier, for paging KVM/RDMA"
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2008-01-31 19:55:46.000000000 -0800
+++ linux-2.6/mm/Makefile	2008-01-31 19:59:51.000000000 -0800
@@ -30,4 +30,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/mmu_notifier.c	2008-01-31 20:56:03.000000000 -0800
@@ -0,0 +1,76 @@
+/*
+ *  linux/mm/mmu_notifier.c
+ *
+ *  Copyright (C) 2008  Qumranet, Inc.
+ *  Copyright (C) 2008  SGI
+ *  		Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/mmu_notifier.h>
+
+/*
+ * No synchronization. This function can only be called when only a single
+ * process remains that performs teardown.
+ */
+void mmu_notifier_release(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n, *t;
+
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		hlist_for_each_entry_safe(mn, n, t,
+					  &mm->mmu_notifier.head, hlist) {
+			hlist_del_init(&mn->hlist);
+			if (mn->ops->release)
+				mn->ops->release(mn, mm);
+		}
+	}
+}
+
+/*
+ * If no young bitflag is supported by the hardware, ->age_page can
+ * unmap the address and return 1 or 0 depending if the mapping previously
+ * existed or not.
+ */
+int mmu_notifier_age_page(struct mm_struct *mm, unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int young = 0;
+
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(mn, n,
+					  &mm->mmu_notifier.head, hlist) {
+			if (mn->ops->age_page)
+				young |= mn->ops->age_page(mn, mm, address);
+		}
+		rcu_read_unlock();
+	}
+
+	return young;
+}
+
+/*
+ * Note that all notifiers use RCU. The updates are only guaranteed to be
+ * visible to other processes after a RCU quiescent period!
+ *
+ * Must hold mmap_sem writably when calling registration functions.
+ */
+void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
+}
+EXPORT_SYMBOL_GPL(__mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	hlist_del_rcu(&mn->hlist);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
+
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2008-01-31 19:55:46.000000000 -0800
+++ linux-2.6/kernel/fork.c	2008-01-31 19:59:51.000000000 -0800
@@ -52,6 +52,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -360,6 +361,7 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_head_init(&mm->mmu_notifier);
 		return mm;
 	}
 	free_mm(mm);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-01-31 19:55:46.000000000 -0800
+++ linux-2.6/mm/mmap.c	2008-01-31 20:56:03.000000000 -0800
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2033,6 +2034,7 @@ void exit_mmap(struct mm_struct *mm)
 	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
+	mmu_notifier_release(mm);
 	arch_exit_mmap(mm);
 
 	lru_add_drain();

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
