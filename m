Date: Wed, 23 Jan 2008 20:00:08 -0600
From: Robin Holt <holt@sgi.com>
Subject: Enhance mmu notifiers to accomplish a lockless implementation
	(incomplete).
Message-ID: <20080124020007.GL26420@sgi.com>
References: <20080113162418.GE8736@v2.random> <20080116124256.44033d48@bree.surriel.com> <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080122200858.GB15848@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>, clameter@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Expand the mmu_notifiers to allow for lockless callers.  To accomplish
this, the function receiving notifications needs to implement an rmap
equivalent.  The notification function is also responsible for tracking
page dirty state.

With this patch, I am getting fairly close to not needing the
invalidate_page mmu_notifier.  The combination of invalidate_range
and this export_notifier covers all the paths I can see so far except
__xip_unmap and do_wp_page.  __xip_unmap is not so much of a concern,
but I would like to handle it as well.

The one that really concerns me is do_wp_page.  I am having difficulty
figuring out a way to handle this without holding locks.

For either of these callers of ptep_clear_flush, I welcome suggestions
on methods to call a notifier without holding any non-sleepable locks.

I am traveling tomorrow but should be able to get back to this tomorrow
evening or early Friday.  This has not even been compiled yet.  Just
marking it up for now.

Thank you for your attention,
Robin Holt



Index: mmu_notifiers/include/linux/export_notifier.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mmu_notifiers/include/linux/export_notifier.h	2008-01-23 19:46:05.000000000 -0600
@@ -0,0 +1,48 @@
+#ifndef _LINUX_EXPORT_NOTIFIER_H
+#define _LINUX_EXPORT_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/mm_types.h>
+
+struct export_notifier {
+	struct hlist_node list;
+	const struct export_notifier_ops *ops;
+};
+
+struct export_notifier_ops {
+	/*
+	 * Called with the page lock held after ptes are modified or removed.
+	 *
+	 * Must clear PageExported()
+	 */
+	void (*invalidate_page)(struct export_notifier *em, struct page *page);
+};
+
+#ifdef CONFIG_EXPORT_NOTIFIER
+
+extern void export_notifier_register(struct export_notifier *em);
+extern void export_notifier_unregister(struct export_notifier *em);
+
+extern struct hlist_head export_notifier_list;
+
+#define export_notifier(function, args...)					\
+	do {									\
+		struct export_notifier *__em;					\
+										\
+		rcu_read_lock();						\
+		hlist_for_each_entry_rcu(__em, &export_notifier_list, list)	\
+			if (__em->ops->function)				\
+				__em->ops->function(__em, args);		\
+		rcu_read_unlock();						\
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
Index: mmu_notifiers/include/linux/page-flags.h
===================================================================
--- mmu_notifiers.orig/include/linux/page-flags.h	2008-01-23 19:44:40.000000000 -0600
+++ mmu_notifiers/include/linux/page-flags.h	2008-01-23 19:46:05.000000000 -0600
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
Index: mmu_notifiers/mm/Kconfig
===================================================================
--- mmu_notifiers.orig/mm/Kconfig	2008-01-23 19:44:39.000000000 -0600
+++ mmu_notifiers/mm/Kconfig	2008-01-23 19:46:06.000000000 -0600
@@ -197,3 +197,8 @@ config VIRT_TO_BUS
 config MMU_NOTIFIER
 	def_bool y
 	bool "MMU notifier, for paging KVM/RDMA"
+
+config EXPORT_NOTIFIER
+	def_bool y
+	depends on 64BIT
+	bool "Export Notifier for notifying subsystems about changes to page mappings"
Index: mmu_notifiers/mm/Makefile
===================================================================
--- mmu_notifiers.orig/mm/Makefile	2008-01-23 19:44:39.000000000 -0600
+++ mmu_notifiers/mm/Makefile	2008-01-23 19:46:06.000000000 -0600
@@ -31,4 +31,4 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
-
+obj-$(CONFIG_EXPORT_NOTIFIER) += export_notifier.o
Index: mmu_notifiers/mm/export_notifier.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mmu_notifiers/mm/export_notifier.c	2008-01-23 19:46:06.000000000 -0600
@@ -0,0 +1,20 @@
+#include <linux/export_notifier.h>
+
+HLIST_HEAD(export_notifier_list);
+DEFINE_SPINLOCK(export_notifier_list_lock);
+
+void export_notifier_register(struct export_notifier *en)
+{
+	spin_lock(&export_notifier_list_lock);
+	hlist_add_head_rcu(&en->list, &export_notifier_list);
+	spin_unlock(&export_notifier_list_lock);
+}
+
+void export_notifier_unregister(struct export_notifier *en)
+{
+	spin_lock(&export_notifier_list_lock);
+	hlist_del_rcu(&en->list);
+	spin_unlock(&export_notifier_list_lock);
+}
+
+
Index: mmu_notifiers/mm/rmap.c
===================================================================
--- mmu_notifiers.orig/mm/rmap.c	2008-01-23 19:44:39.000000000 -0600
+++ mmu_notifiers/mm/rmap.c	2008-01-23 19:46:06.000000000 -0600
@@ -49,6 +49,7 @@
 #include <linux/rcupdate.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/export_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -473,6 +474,8 @@ int page_mkclean(struct page *page)
 		struct address_space *mapping = page_mapping(page);
 		if (mapping) {
 			ret = page_mkclean_file(mapping, page);
+			if (unlikely(PageExported(page)))
+				export_notifier(invalidate_page, page);
 			if (page_test_dirty(page)) {
 				page_clear_dirty(page);
 				ret = 1;
@@ -971,6 +974,9 @@ int try_to_unmap(struct page *page, int 
 	else
 		ret = try_to_unmap_file(page, migration);
 
+	if (unlikely(PageExported(page)))
+		export_notifier(invalidate_page, page);
+
 	if (!page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
Index: mmu_notifiers/mm/fremap.c
===================================================================
--- mmu_notifiers.orig/mm/fremap.c	2008-01-23 19:44:39.000000000 -0600
+++ mmu_notifiers/mm/fremap.c	2008-01-23 19:46:06.000000000 -0600
@@ -211,6 +211,7 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mmu_notifier(invalidate_range, mm, start, start + size);
 	err = populate_range(mm, vma, start, size, pgoff);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
