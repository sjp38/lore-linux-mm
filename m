From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 1/6] mmu_notifier: Core code
Date: Tue, 29 Jan 2008 18:29:10 -0800
Message-ID: <20080130022944.236370194@sgi.com>
References: <20080130022909.677301714@sgi.com>
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
Cc: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
List-Id: linux-mm.kvack.org

Core code for mmu notifiers.

Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Signed-off-by: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>

---
 include/linux/list.h         |   14 ++
 include/linux/mm_types.h     |    6 +
 include/linux/mmu_notifier.h |  210 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/page-flags.h   |   10 ++
 kernel/fork.c                |    2 
 mm/Kconfig                   |    4 
 mm/Makefile                  |    1 
 mm/mmap.c                    |    2 
 mm/mmu_notifier.c            |  101 ++++++++++++++++++++
 9 files changed, 350 insertions(+)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2008-01-29 16:56:33.000000000 -0800
+++ linux-2.6/include/linux/mm_types.h	2008-01-29 16:56:36.000000000 -0800
@@ -153,6 +153,10 @@ struct vm_area_struct {
 #endif
 };
 
+struct mmu_notifier_head {
+	struct hlist_head head;
+};
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -219,6 +223,8 @@ struct mm_struct {
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
+++ linux-2.6/include/linux/mmu_notifier.h	2008-01-29 16:56:36.000000000 -0800
@@ -0,0 +1,210 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+/*
+ * MMU motifier
+ *
+ * Notifier functions for hardware and software that establishes external
+ * references to pages of a Linux system. The notifier calls ensure that
+ * the external mappings are removed when the Linux VM removes memory ranges
+ * or individual pages from a process.
+ *
+ * These fall into two classes
+ *
+ * 1. mmu_notifier
+ *
+ * 	These are callbacks registered with an mm_struct. If mappings are
+ * 	removed from an address space then callbacks are performed.
+ * 	Spinlocks must be held in order to the walk reverse maps and the
+ * 	notifications are performed while the spinlock is held.
+ *
+ *
+ * 2. mmu_rmap_notifier
+ *
+ *	Callbacks for subsystems that provide their own rmaps. These
+ *	need to walk their own rmaps for a page. The invalidate_page
+ *	callback is outside of locks so that we are not in a strictly
+ *	atomic context (but we may be in a PF_MEMALLOC context if the
+ *	notifier is called from reclaim code) and are able to sleep.
+ *	Rmap notifiers need an extra page bit and are only available
+ *	on 64 bit platforms. It is up to the subsystem to mark pags
+ *	as PageExternalRmap as needed to trigger the callbacks. Pages
+ *	must be marked dirty if dirty bits are set in the external
+ *	pte.
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
+	 * Note: The mmu_notifier structure must be released with
+	 * call_rcu() since other processors are only guaranteed to
+	 * see the changes after a quiescent period.
+	 */
+	void (*release)(struct mmu_notifier *mn,
+			struct mm_struct *mm);
+
+	int (*age_page)(struct mmu_notifier *mn,
+			struct mm_struct *mm,
+			unsigned long address);
+
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+
+	/*
+	 * lock indicates that the function is called under spinlock.
+	 */
+	void (*invalidate_range)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end,
+				 int lock);
+};
+
+struct mmu_rmap_notifier_ops;
+
+struct mmu_rmap_notifier {
+	struct hlist_node hlist;
+	const struct mmu_rmap_notifier_ops *ops;
+};
+
+struct mmu_rmap_notifier_ops {
+	/*
+	 * Called with the page lock held after ptes are modified or removed
+	 * so that a subsystem with its own rmap's can remove remote ptes
+	 * mapping a page.
+	 */
+	void (*invalidate_page)(struct mmu_rmap_notifier *mrn,
+						struct page *page);
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
+extern void __mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+/* Will acquire mmap_sem for write*/
+extern void mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+/*
+ * Will acquire mmap_sem for write.
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
+extern void mmu_rmap_notifier_register(struct mmu_rmap_notifier *mrn);
+extern void mmu_rmap_notifier_unregister(struct mmu_rmap_notifier *mrn);
+
+extern struct hlist_head mmu_rmap_notifier_list;
+
+#define mmu_rmap_notifier(function, args...)				\
+	do {								\
+		struct mmu_rmap_notifier *__mrn;			\
+		struct hlist_node *__n;					\
+									\
+		rcu_read_lock();					\
+		hlist_for_each_entry_rcu(__mrn, __n,			\
+				&mmu_rmap_notifier_list, 		\
+						hlist)			\
+			if (__mrn->ops->function)			\
+				__mrn->ops->function(__mrn, args);	\
+		rcu_read_unlock();					\
+	} while (0);
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
+#define mmu_rmap_notifier(function, args...)				\
+	do {								\
+		if (0) {						\
+			struct mmu_rmap_notifier *__mrn;		\
+									\
+			__mrn = (struct mmu_rmap_notifier *)(0x00ff);	\
+			__mrn->ops->function(__mrn, args);		\
+		}							\
+	} while (0);
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
+static inline void mmu_rmap_notifier_register(struct mmu_rmap_notifier *mrn)
+									{}
+static inline void mmu_rmap_notifier_unregister(struct mmu_rmap_notifier *mrn)
+									{}
+
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif /* _LINUX_MMU_NOTIFIER_H */
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-01-29 16:56:33.000000000 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-01-29 16:56:36.000000000 -0800
@@ -105,6 +105,7 @@
  * 64 bit  |           FIELDS             | ??????         FLAGS         |
  *         63                            32                              0
  */
+#define PG_external_rmap	30	/* Page has external rmap */
 #define PG_uncached		31	/* Page has been mapped as uncached */
 #endif
 
@@ -260,6 +261,15 @@ static inline void __ClearPageTail(struc
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#if defined(CONFIG_MMU_NOTIFIER) && defined(CONFIG_64BIT)
+#define PageExternalRmap(page)	test_bit(PG_external_rmap, &(page)->flags)
+#define SetPageExternalRmap(page) set_bit(PG_external_rmap, &(page)->flags)
+#define ClearPageExternalRmap(page) clear_bit(PG_external_rmap, \
+							&(page)->flags)
+#else
+#define PageExternalRmap(page)	0
+#endif
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2008-01-29 16:56:33.000000000 -0800
+++ linux-2.6/mm/Kconfig	2008-01-29 16:56:36.000000000 -0800
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
--- linux-2.6.orig/mm/Makefile	2008-01-29 16:56:33.000000000 -0800
+++ linux-2.6/mm/Makefile	2008-01-29 16:56:36.000000000 -0800
@@ -30,4 +30,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/mmu_notifier.c	2008-01-29 16:57:26.000000000 -0800
@@ -0,0 +1,101 @@
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
+#include <linux/mmu_notifier.h>
+#include <linux/module.h>
+
+void mmu_notifier_release(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n, *t;
+
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		rcu_read_lock();
+		hlist_for_each_entry_safe_rcu(mn, n, t,
+					  &mm->mmu_notifier.head, hlist) {
+			hlist_del_rcu(&mn->hlist);
+			if (mn->ops->release)
+				mn->ops->release(mn, mm);
+		}
+		rcu_read_unlock();
+		synchronize_rcu();
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
+ */
+void __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
+}
+EXPORT_SYMBOL_GPL(__mmu_notifier_register);
+
+void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	down_write(&mm->mmap_sem);
+	__mmu_notifier_register(mn, mm);
+	up_write(&mm->mmap_sem);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	down_write(&mm->mmap_sem);
+	hlist_del_rcu(&mn->hlist);
+	up_write(&mm->mmap_sem);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
+
+static DEFINE_SPINLOCK(mmu_notifier_list_lock);
+HLIST_HEAD(mmu_rmap_notifier_list);
+
+void mmu_rmap_notifier_register(struct mmu_rmap_notifier *mrn)
+{
+	spin_lock(&mmu_notifier_list_lock);
+	hlist_add_head_rcu(&mrn->hlist, &mmu_rmap_notifier_list);
+	spin_unlock(&mmu_notifier_list_lock);
+}
+EXPORT_SYMBOL(mmu_rmap_notifier_register);
+
+void mmu_rmap_notifier_unregister(struct mmu_rmap_notifier *mrn)
+{
+	spin_lock(&mmu_notifier_list_lock);
+	hlist_del_rcu(&mrn->hlist);
+	spin_unlock(&mmu_notifier_list_lock);
+}
+EXPORT_SYMBOL(mmu_rmap_notifier_unregister);
+
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2008-01-29 16:56:33.000000000 -0800
+++ linux-2.6/kernel/fork.c	2008-01-29 16:56:36.000000000 -0800
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
--- linux-2.6.orig/mm/mmap.c	2008-01-29 16:56:33.000000000 -0800
+++ linux-2.6/mm/mmap.c	2008-01-29 16:56:36.000000000 -0800
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2043,6 +2044,7 @@ void exit_mmap(struct mm_struct *mm)
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
+	mmu_notifier_release(mm);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
Index: linux-2.6/include/linux/list.h
===================================================================
--- linux-2.6.orig/include/linux/list.h	2008-01-29 16:56:33.000000000 -0800
+++ linux-2.6/include/linux/list.h	2008-01-29 16:56:36.000000000 -0800
@@ -991,6 +991,20 @@ static inline void hlist_add_after_rcu(s
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
 	     pos = pos->next)
 
+/**
+ * hlist_for_each_entry_safe_rcu	- iterate over list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @n:		temporary pointer
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_safe_rcu(tpos, pos, n, head, member)	 \
+	for (pos = (head)->first;					 \
+	     rcu_dereference(pos) && ({ n = pos->next; 1;}) &&		 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = n)
+
 #else
 #warning "don't include kernel headers in userspace"
 #endif /* __KERNEL__ */

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
