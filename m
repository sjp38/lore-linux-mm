Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 508E9600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:51 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [30/31] HWPOISON: Add soft page offline support
Message-Id: <20091208211646.982BDB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:46 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This is a simpler, gentler variant of memory_failure() for soft page 
offlining controlled from user space.  It doesn't kill anything, just
tries to invalidate and if that doesn't work migrate the
page away. 

This is useful for predictive failure analysis, where a page has 
a high rate of corrected errors, but hasn't gone bad yet. Instead 
it can be offlined early and avoided.

The offlining is controlled from sysfs, including a new generic
entry point for hard page offlining for symmetry too.

We use the page isolate facility to prevent re-allocation
race. Normally this is only used by memory hotplug. To avoid
races with memory allocation I am using lock_system_sleep().
This avoids the situation where memory hotplug is about
to isolate a page range and then hwpoison undoes that work.
This is a big hammer currently, but the simplest solution
currently.

When the page is not free or LRU we try to free pages
from slab and other caches. The slab freeing is currently
quite dumb and does not try to focus on the specific slab
cache which might own the page. This could be potentially
improved later.

OPEN: nfs migration hangs (broken low level migration op)

Thanks to Fengguang Wu and Haicheng Li for some fixes.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/ABI/testing/sysfs-memory-page-offline |   44 ++++
 drivers/base/memory.c                               |   61 ++++++
 include/linux/mm.h                                  |    3 
 mm/hwpoison-inject.c                                |    2 
 mm/memory-failure.c                                 |  194 +++++++++++++++++++-
 5 files changed, 297 insertions(+), 7 deletions(-)

Index: linux/drivers/base/memory.c
===================================================================
--- linux.orig/drivers/base/memory.c
+++ linux/drivers/base/memory.c
@@ -341,6 +341,64 @@ static inline int memory_probe_init(void
 }
 #endif
 
+#ifdef CONFIG_MEMORY_FAILURE
+/*
+ * Support for offlining pages of memory
+ */
+
+/* Soft offline a page */
+static ssize_t
+store_soft_offline_page(struct class *class, const char *buf, size_t count)
+{
+	int ret;
+	u64 pfn;
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	if (strict_strtoull(buf, 0, &pfn) < 0)
+		return -EINVAL;
+	pfn >>= PAGE_SHIFT;
+	if (!pfn_valid(pfn))
+		return -ENXIO;
+	ret = soft_offline_page(pfn_to_page(pfn), 0);
+	return ret == 0 ? count : ret;
+}
+
+/* Forcibly offline a page, including killing processes. */
+static ssize_t
+store_hard_offline_page(struct class *class, const char *buf, size_t count)
+{
+	int ret;
+	u64 pfn;
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	if (strict_strtoull(buf, 0, &pfn) < 0)
+		return -EINVAL;
+	pfn >>= PAGE_SHIFT;
+	ret = __memory_failure(pfn, 0, 0);
+	return ret ? ret : count;
+}
+
+static CLASS_ATTR(soft_offline_page, 0644, NULL, store_soft_offline_page);
+static CLASS_ATTR(hard_offline_page, 0644, NULL, store_hard_offline_page);
+
+static __init int memory_fail_init(void)
+{
+	int err;
+
+	err = sysfs_create_file(&memory_sysdev_class.kset.kobj,
+				&class_attr_soft_offline_page.attr);
+	if (!err)
+		err = sysfs_create_file(&memory_sysdev_class.kset.kobj,
+				&class_attr_hard_offline_page.attr);
+	return err;
+}
+#else
+static inline int memory_fail_init(void)
+{
+	return 0;
+}
+#endif
+
 /*
  * Note that phys_device is optional.  It is here to allow for
  * differentiation between which *physical* devices each
@@ -473,6 +531,9 @@ int __init memory_dev_init(void)
 	err = memory_probe_init();
 	if (!ret)
 		ret = err;
+	err = memory_fail_init();
+	if (!ret)
+		ret = err;
 	err = block_size_init();
 	if (!ret)
 		ret = err;
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -41,6 +41,9 @@
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 #include <linux/backing-dev.h>
+#include <linux/migrate.h>
+#include <linux/page-isolation.h>
+#include <linux/suspend.h>
 #include "internal.h"
 
 int sysctl_memory_failure_early_kill __read_mostly = 0;
@@ -197,7 +200,7 @@ static int kill_proc_ao(struct task_stru
  * When a unknown page type is encountered drain as many buffers as possible
  * in the hope to turn the page into a LRU or free page, which we can handle.
  */
-void shake_page(struct page *p)
+void shake_page(struct page *p, int access)
 {
 	if (!PageSlab(p)) {
 		lru_add_drain_all();
@@ -207,11 +210,19 @@ void shake_page(struct page *p)
 		if (PageLRU(p) || is_free_buddy_page(p))
 			return;
 	}
+
 	/*
-	 * Could call shrink_slab here (which would also
-	 * shrink other caches). Unfortunately that might
-	 * also access the corrupted page, which could be fatal.
+	 * Only all shrink_slab here (which would also
+	 * shrink other caches) if access is not potentially fatal.
 	 */
+	if (access) {
+		int nr;
+		do {
+			nr = shrink_slab(1000, GFP_KERNEL, 1000);
+			if (page_count(p) == 0)
+				break;
+		} while (nr > 10);
+	}
 }
 EXPORT_SYMBOL_GPL(shake_page);
 
@@ -947,7 +958,7 @@ int __memory_failure(unsigned long pfn,
 	 * walked by the page reclaim code, however that's not a big loss.
 	 */
 	if (!PageLRU(p))
-		shake_page(p);
+		shake_page(p, 0);
 	if (!PageLRU(p)) {
 		/*
 		 * shake_page could have turned it free.
@@ -1097,3 +1108,176 @@ int unpoison_memory(unsigned long pfn)
 	return 0;
 }
 EXPORT_SYMBOL(unpoison_memory);
+
+static struct page *new_page(struct page *p, unsigned long private, int **x)
+{
+	return alloc_pages(GFP_HIGHUSER_MOVABLE, 0);
+}
+
+/*
+ * Safely get reference count of an arbitrary page.
+ * Returns 0 for a free page, -EIO for a zero refcount page
+ * that is not free, and 1 for any other page type.
+ * For 1 the page is returned with increased page count, otherwise not.
+ */
+static int get_any_page(struct page *p, unsigned long pfn, int flags)
+{
+	int ret;
+
+	if (flags & MF_COUNT_INCREASED)
+		return 1;
+
+	/*
+	 * The lock_system_sleep prevents a race with memory hotplug,
+	 * because the isolation assumes there's only a single user.
+	 * This is a big hammer, a better would be nicer.
+	 */
+	lock_system_sleep();
+
+	/*
+	 * Isolate the page, so that it doesn't get reallocated if it
+	 * was free.
+	 */
+	set_migratetype_isolate(p);
+	if (!get_page_unless_zero(compound_head(p))) {
+		if (is_free_buddy_page(p)) {
+			pr_debug("get_any_page: %#lx free buddy page\n", pfn);
+			/* Set hwpoison bit while page is still isolated */
+			SetPageHWPoison(p);
+			ret = 0;
+		} else {
+			pr_debug("get_any_page: %#lx: unknown zero refcount page type %lx\n",
+				pfn, p->flags);
+			ret = -EIO;
+		}
+	} else {
+		/* Not a free page */
+		ret = 1;
+	}
+	unset_migratetype_isolate(p);
+	unlock_system_sleep();
+	return ret;
+}
+
+/**
+ * soft_offline_page - Soft offline a page.
+ * @page: page to offline
+ * @flags: flags. Same as memory_failure().
+ *
+ * Returns 0 on success, otherwise negated errno.
+ *
+ * Soft offline a page, by migration or invalidation,
+ * without killing anything. This is for the case when
+ * a page is not corrupted yet (so it's still valid to access),
+ * but has had a number of corrected errors and is better taken
+ * out.
+ *
+ * The actual policy on when to do that is maintained by
+ * user space.
+ *
+ * This should never impact any application or cause data loss,
+ * however it might take some time.
+ *
+ * This is not a 100% solution for all memory, but tries to be
+ * ``good enough'' for the majority of memory.
+ */
+int soft_offline_page(struct page *page, int flags)
+{
+	int ret;
+	unsigned long pfn = page_to_pfn(page);
+
+	ret = get_any_page(page, pfn, flags);
+	if (ret < 0)
+		return ret;
+	if (ret == 0)
+		goto done;
+
+	/*
+	 * Page cache page we can handle?
+	 */
+	if (!PageLRU(page)) {
+		/*
+		 * Try to free it.
+		 */
+		put_page(page);
+		shake_page(page, 1);
+
+		/*
+		 * Did it turn free?
+		 */
+		ret = get_any_page(page, pfn, flags);
+		if (ret < 0)
+			return ret;
+		if (ret == 0)
+			goto done;
+	}
+	if (!PageLRU(page)) {
+		pr_debug("soft_offline: %#lx: unknown non LRU page type %lx\n",
+				pfn, page->flags);
+		return -EIO;
+	}
+
+	lock_page(page);
+	wait_on_page_writeback(page);
+
+	/*
+	 * Synchronized using the page lock with memory_failure()
+	 */
+	if (PageHWPoison(page)) {
+		unlock_page(page);
+		put_page(page);
+		pr_debug("soft offline: %#lx page already poisoned\n", pfn);
+		return -EBUSY;
+	}
+
+	/*
+	 * Try to invalidate first. This should work for
+	 * non dirty unmapped page cache pages.
+	 */
+	ret = invalidate_inode_page(page);
+	unlock_page(page);
+
+	/*
+	 * Drop count because page migration doesn't like raised
+	 * counts. The page could get re-allocated, but if it becomes
+	 * LRU the isolation will just fail.
+	 * RED-PEN would be better to keep it isolated here, but we
+	 * would need to fix isolation locking first.
+	 */
+	put_page(page);
+	if (ret == 1) {
+		ret = 0;
+		pr_debug("soft_offline: %#lx: invalidated\n", pfn);
+		goto done;
+	}
+
+	/*
+	 * Simple invalidation didn't work.
+	 * Try to migrate to a new page instead. migrate.c
+	 * handles a large number of cases for us.
+	 */
+	ret = isolate_lru_page(page);
+	if (!ret) {
+		LIST_HEAD(pagelist);
+
+		list_add(&page->lru, &pagelist);
+		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL);
+		if (ret) {
+			pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
+				pfn, ret, page->flags);
+			if (ret > 0)
+				ret = -EIO;
+		}
+	} else {
+		pr_debug("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
+				pfn, ret, page_count(page), page->flags);
+	}
+	if (ret)
+		return ret;
+
+done:
+	atomic_long_add(1, &mce_bad_pages);
+	SetPageHWPoison(page);
+	/* keep elevated page count for bad page */
+	return ret;
+}
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -1324,8 +1324,9 @@ extern int __memory_failure(unsigned lon
 extern int unpoison_memory(unsigned long pfn);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
-extern void shake_page(struct page *p);
+extern void shake_page(struct page *p, int access);
 extern atomic_long_t mce_bad_pages;
+extern int soft_offline_page(struct page *page, int flags);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
Index: linux/Documentation/ABI/testing/sysfs-memory-page-offline
===================================================================
--- /dev/null
+++ linux/Documentation/ABI/testing/sysfs-memory-page-offline
@@ -0,0 +1,44 @@
+What:		/sys/devices/system/memory/soft_offline_page
+Date:		Sep 2009
+KernelVersion:	2.6.33
+Contact:	andi@firstfloor.org
+Description:
+		Soft-offline the memory page containing the physical address
+		written into this file. Input is a hex number specifying the
+		physical address of the page. The kernel will then attempt
+		to soft-offline it, by moving the contents elsewhere or
+		dropping it if possible. The kernel will then be placed
+		on the bad page list and never be reused.
+
+		The offlining is done in kernel specific granuality.
+		Normally it's the base page size of the kernel, but
+		this might change.
+
+		The page must be still accessible, not poisoned. The
+		kernel will never kill anything for this, but rather
+		fail the offline.  Return value is the size of the
+		number, or a error when the offlining failed.  Reading
+		the file is not allowed.
+
+What:		/sys/devices/system/memory/hard_offline_page
+Date:		Sep 2009
+KernelVersion:	2.6.33
+Contact:	andi@firstfloor.org
+Description:
+		Hard-offline the memory page containing the physical
+		address written into this file. Input is a hex number
+		specifying the physical address of the page. The
+		kernel will then attempt to hard-offline the page, by
+		trying to drop the page or killing any owner or
+		triggering IO errors if needed.  Note this may kill
+		any processes owning the page. The kernel will avoid
+		to access this page assuming it's poisoned by the
+		hardware.
+
+		The offlining is done in kernel specific granuality.
+		Normally it's the base page size of the kernel, but
+		this might change.
+
+		Return value is the size of the number, or a error when
+		the offlining failed.
+		Reading the file is not allowed.
Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -29,7 +29,7 @@ static int hwpoison_inject(void *data, u
 		return 0;
 
 	if (!PageLRU(p))
-		shake_page(p);
+		shake_page(p, 0);
 	/*
 	 * This implies unable to support non-LRU pages.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
