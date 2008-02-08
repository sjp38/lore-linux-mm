From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 1/6] mmu_notifier: Core code
Date: Fri, 08 Feb 2008 14:06:17 -0800
Message-ID: <20080208220655.776450775@sgi.com>
References: <20080208220616.089936205@sgi.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
List-Id: linux-mm.kvack.org

MMU notifiers are used for hardware and software that establishes
external references to pages managed by the Linux kernel. These are
page table entriews or tlb entries or something else that allows
hardware (such as DMA engines, scatter gather devices, networking,
sharing of address spaces across operating system boundaries) and
software (Virtualization solutions such as KVM, Xen etc) to
access memory managed by the Linux kernel.

The MMU notifier will notify the device driver that subscribes to such
a notifier that the VM is going to do something with the memory
mapped by that device. The device must then drop references for the
indicated memory area. The references may be reestablished later.

The notification scheme is much better than the current scheme of
avoiding the danger of the VM removing pages that are externally
mapped. We currently mlock pages used for RDMA, XPmem etc in memory.

Mlock causes problems with reclaim and may lead to OOM if too many
pages are pinned in memory. It is also incorrect in terms what the POSIX
specificies for what role mlock should play. Mlock does *not* pin pages in
memory. Mlock just means do not allow the page to be moved to swap.

Linux can move pages in memory (for example through the page migration
mechanism). These pages can be moved even if they are mlocked(!!!!).
The current approach of page pinning in use by RDMA etc is conceptually
broken but there are currently no other easy solutions.

The solution here allows us to finally fix this issue by requiring
such devices to subscribe to a notification chain that will allow
them to work without pinning.

This patch: Core portion

Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Signed-off-by: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>

---
 Documentation/mmu_notifier/README |   99 +++++++++++++++++++++
 include/linux/mm_types.h          |    7 +
 include/linux/mmu_notifier.h      |  175 ++++++++++++++++++++++++++++++++++++++
 kernel/fork.c                     |    2 
 mm/Kconfig                        |    4 
 mm/Makefile                       |    1 
 mm/mmap.c                         |    2 
 mm/mmu_notifier.c                 |   76 ++++++++++++++++
 8 files changed, 366 insertions(+)

Index: linux-2.6/Documentation/mmu_notifier/README
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/mmu_notifier/README	2008-02-08 12:30:47.000000000 -0800
@@ -0,0 +1,99 @@
+Linux MMU Notifiers
+-------------------
+
+MMU notifiers are used for hardware and software that establishes
+external references to pages managed by the Linux kernel. These are
+page table entriews or tlb entries or something else that allows
+hardware (such as DMA engines, scatter gather devices, networking,
+sharing of address spaces across operating system boundaries) and
+software (Virtualization solutions such as KVM, Xen etc) to
+access memory managed by the Linux kernel.
+
+The MMU notifier will notify the device driver that subscribes to such
+a notifier that the VM is going to do something with the memory
+mapped by that device. The device must then drop references for the
+indicated memory area. The references may be reestablished later.
+
+The notification scheme is much better than the current scheme of
+dealing with the danger of the VM removing pages.
+We currently mlock pages used for RDMA, XPmem etc in memory.
+
+Mlock causes problems with reclaim and may lead to OOM if too many
+pages are pinned in memory. It is also incorrect in terms of the POSIX
+specification of the role of mlock. Mlock does *not* pin pages in
+memory. It just does not allow the page to be moved to swap.
+
+Linux can move pages in memory (for example through the page migration
+mechanism). These pages can be moved even if they are mlocked(!!!!).
+So the current approach in use by RDMA etc etc is conceptually broken
+but there are currently no other easy solutions.
+
+The solution here allows us to finally fix this issue by requiring
+such devices to subscribe to a notification chain that will allow
+them to work without pinning.
+
+The notifier chains provide two callback mechanisms. The
+first one is required for any device that establishes external mappings.
+The second (rmap) mechanism is required if a device needs to be
+able to sleep when invalidating references. Sleeping may be necessary
+if we are mapping across a network or to different Linux instances
+in the same address space.
+
+mmu_notifier mechanism (for KVM/GRU etc)
+----------------------------------------
+Callbacks are registered with an mm_struct from a device driver using
+mmu_notifier_register(). When the VM removes pages (or changes
+permissions on pages etc) then callbacks are triggered.
+
+The invalidation function for a single page (*invalidate_page)
+is called with spinlocks (in particular the pte lock) held. This allow
+for an easy implementation of external ptes that are on the local system.
+
+The invalidation mechanism for a range (*invalidate_range_begin/end*) is
+called most of the time without any locks held. It is only called with
+locks held for file backed mappings that are truncated. A flag indicates
+in which mode we are. A driver can use that mechanism to f.e.
+delay the freeing of the pages during truncate until no locks are held.
+
+Pages must be marked dirty if dirty bits are found to be set in
+the external ptes during unmap.
+
+The *release* method is called when a Linux process exits. It is run before
+the pages and mappings of a process are torn down and gives the device driver
+a chance to zap all the external mappings in one go.
+
+An example for a code that can be used to build a notifier mechanism into
+a device driver can be found in the file
+Documentation/mmu_notifier/skeleton.c
+
+mmu_rmap_notifier mechanism (XPMEM etc)
+---------------------------------------
+The mmu_rmap_notifier allows the device driver to implement their own rmap
+and allows the device driver to sleep during page eviction. This is necessary
+for complex drivers that f.e. allow the sharing of memory between processes
+running on different Linux instances (typically over a network or in a
+partitioned NUMA system).
+
+The mmu_rmap_notifier adds another invalidate_page() callout that is called
+*before* the Linux rmaps are walked. At that point only the page lock is
+held. The invalidate_page() function must walk the driver rmaps and evict
+all the references to the page.
+
+There is no process information available before the rmaps are consulted.
+The notifier mechanism can therefore not be attached to an mm_struct. Instead
+it is a global callback list. Having to perform a callback for each and every
+page that is reclaimed would be inefficient. Therefore we add an additional
+page flag: PageRmapExternal(). Only pages that are marked with this bit can
+be exported and the rmap callbacks will only be performed for pages marked
+that way.
+
+The required additional Page flag is only availabe in 64 bit mode and
+therefore the mmu_rmap_notifier portion is not available on 32 bit platforms.
+
+An example of code to build a mmu_notifier mechanism with rmap capabilty
+can be found in Documentation/mmu_notifier/skeleton_rmap.c
+
+February 9, 2008,
+	Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org
+
+Index: linux-2.6/include/linux/mm_types.h
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2008-02-08 12:28:06.000000000 -0800
+++ linux-2.6/include/linux/mm_types.h	2008-02-08 12:30:47.000000000 -0800
@@ -159,6 +159,12 @@ struct vm_area_struct {
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
@@ -228,6 +234,7 @@ struct mm_struct {
 #ifdef CONFIG_CGROUP_MEM_CONT
 	struct mem_cgroup *mem_cgroup;
 #endif
+	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/mmu_notifier.h	2008-02-08 12:35:14.000000000 -0800
@@ -0,0 +1,175 @@
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
+ * 	invalidate_page() callbacks are performed with spinlocks held.
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
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end,
+				 int atomic);
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
--- linux-2.6.orig/mm/Kconfig	2008-02-08 12:28:06.000000000 -0800
+++ linux-2.6/mm/Kconfig	2008-02-08 12:30:47.000000000 -0800
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
--- linux-2.6.orig/mm/Makefile	2008-02-08 12:28:06.000000000 -0800
+++ linux-2.6/mm/Makefile	2008-02-08 12:30:47.000000000 -0800
@@ -33,4 +33,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_CONT) += memcontrol.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/mmu_notifier.c	2008-02-08 12:44:24.000000000 -0800
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
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	hlist_del_rcu(&mn->hlist);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
+
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2008-02-08 12:28:06.000000000 -0800
+++ linux-2.6/kernel/fork.c	2008-02-08 12:30:47.000000000 -0800
@@ -53,6 +53,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -362,6 +363,7 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_head_init(&mm->mmu_notifier);
 		return mm;
 	}
 
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-02-08 12:28:06.000000000 -0800
+++ linux-2.6/mm/mmap.c	2008-02-08 12:43:59.000000000 -0800
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2037,6 +2038,7 @@ void exit_mmap(struct mm_struct *mm)
 	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
+	mmu_notifier_release(mm);
 	arch_exit_mmap(mm);
 
 	lru_add_drain();`

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
