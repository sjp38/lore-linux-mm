Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1F51D60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:18:11 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [17/31] HWPOISON: add fs/device filters
Message-Id: <20091208211633.71135B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:33 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, haicheng.li@intel.com, npiggin@suse.defengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Filesystem data/metadata present the most tricky-to-isolate pages.
It requires careful code review and stress testing to get them right.

The fs/device filter helps to target the stress tests to some specific
filesystem pages. The filter condition is block device's major/minor
numbers:
        - corrupt-filter-dev-major
        - corrupt-filter-dev-minor
When specified (non -1), only page cache pages that belong to that
device will be poisoned.

The filters are checked reliably on the locked and refcounted page.

Haicheng: clear PG_hwpoison and drop bad page count if filter not OK
AK: Add documentation

CC: Haicheng Li <haicheng.li@intel.com>
CC: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/vm/hwpoison.txt |    7 +++++
 mm/hwpoison-inject.c          |   11 +++++++++
 mm/internal.h                 |    3 ++
 mm/memory-failure.c           |   51 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 72 insertions(+)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -48,6 +48,50 @@ int sysctl_memory_failure_recovery __rea
 
 atomic_long_t mce_bad_pages __read_mostly = ATOMIC_LONG_INIT(0);
 
+u32 hwpoison_filter_dev_major = ~0U;
+u32 hwpoison_filter_dev_minor = ~0U;
+EXPORT_SYMBOL_GPL(hwpoison_filter_dev_major);
+EXPORT_SYMBOL_GPL(hwpoison_filter_dev_minor);
+
+static int hwpoison_filter_dev(struct page *p)
+{
+	struct address_space *mapping;
+	dev_t dev;
+
+	if (hwpoison_filter_dev_major == ~0U &&
+	    hwpoison_filter_dev_minor == ~0U)
+		return 0;
+
+	/*
+	 * page_mapping() does not accept slab page
+	 */
+	if (PageSlab(p))
+		return -EINVAL;
+
+	mapping = page_mapping(p);
+	if (mapping == NULL || mapping->host == NULL)
+		return -EINVAL;
+
+	dev = mapping->host->i_sb->s_dev;
+	if (hwpoison_filter_dev_major != ~0U &&
+	    hwpoison_filter_dev_major != MAJOR(dev))
+		return -EINVAL;
+	if (hwpoison_filter_dev_minor != ~0U &&
+	    hwpoison_filter_dev_minor != MINOR(dev))
+		return -EINVAL;
+
+	return 0;
+}
+
+int hwpoison_filter(struct page *p)
+{
+	if (hwpoison_filter_dev(p))
+		return -EINVAL;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(hwpoison_filter);
+
 /*
  * Send all the processes who have the page mapped an ``action optional''
  * signal.
@@ -845,6 +889,13 @@ int __memory_failure(unsigned long pfn,
 		res = 0;
 		goto out;
 	}
+	if (hwpoison_filter(p)) {
+		if (TestClearPageHWPoison(p))
+			atomic_long_dec(&mce_bad_pages);
+		unlock_page(p);
+		put_page(p);
+		return 0;
+	}
 
 	wait_on_page_writeback(p);
 
Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -3,6 +3,7 @@
 #include <linux/debugfs.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include "internal.h"
 
 static struct dentry *hwpoison_dir;
 
@@ -54,6 +55,16 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
+	dentry = debugfs_create_u32("corrupt-filter-dev-major", 0600,
+				    hwpoison_dir, &hwpoison_filter_dev_major);
+	if (!dentry)
+		goto fail;
+
+	dentry = debugfs_create_u32("corrupt-filter-dev-minor", 0600,
+				    hwpoison_dir, &hwpoison_filter_dev_minor);
+	if (!dentry)
+		goto fail;
+
 	return 0;
 fail:
 	pfn_inject_exit();
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -263,3 +263,6 @@ int __get_user_pages(struct task_struct
 #define ZONE_RECLAIM_SOME	0
 #define ZONE_RECLAIM_SUCCESS	1
 #endif
+
+extern u32 hwpoison_filter_dev_major;
+extern u32 hwpoison_filter_dev_minor;
Index: linux/Documentation/vm/hwpoison.txt
===================================================================
--- linux.orig/Documentation/vm/hwpoison.txt
+++ linux/Documentation/vm/hwpoison.txt
@@ -115,6 +115,13 @@ memory failures.
 Note these injection interfaces are not stable and might change between
 kernel versions
 
+corrupt-filter-dev-major
+corrupt-filter-dev-minor
+
+Only handle memory failures to pages associated with the file system defined
+by block device major/minor.  -1U is the wildcard value.
+This should be only used for testing with artificial injection.
+
 Architecture specific MCE injector
 
 x86 has mce-inject, mce-test

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
