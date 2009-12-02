From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 15/24] HWPOISON: add fs/device filters
Date: Wed, 02 Dec 2009 11:12:46 +0800
Message-ID: <20091202043045.535248130@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B99ED6007BA
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-filter-fs.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Haicheng Li <haicheng.li@intel.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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

CC: Haicheng Li <haicheng.li@intel.com>
CC: Nick Piggin <npiggin@suse.de>
CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/hwpoison-inject.c |   11 +++++++++
 mm/internal.h        |    3 ++
 mm/memory-failure.c  |   48 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+)

--- linux-mm.orig/mm/memory-failure.c	2009-11-30 20:44:31.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-30 20:51:22.000000000 +0800
@@ -48,6 +48,47 @@ int sysctl_memory_failure_recovery __rea
 
 atomic_long_t mce_bad_pages __read_mostly = ATOMIC_LONG_INIT(0);
 
+u32 hwpoison_filter_dev_major = ~0U;
+u32 hwpoison_filter_dev_minor = ~0U;
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
+
 /*
  * Send all the processes who have the page mapped an ``action optional''
  * signal.
@@ -849,6 +890,13 @@ int __memory_failure(unsigned long pfn, 
 		action_result(&hpc, "unpoisoned", IGNORED);
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
 
--- linux-mm.orig/mm/hwpoison-inject.c	2009-11-30 20:30:55.000000000 +0800
+++ linux-mm/mm/hwpoison-inject.c	2009-11-30 20:44:41.000000000 +0800
@@ -3,6 +3,7 @@
 #include <linux/debugfs.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include "internal.h"
 
 static struct dentry *hwpoison_dir;
 
@@ -49,6 +50,16 @@ static int pfn_inject_init(void)
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
--- linux-mm.orig/mm/internal.h	2009-11-30 20:06:01.000000000 +0800
+++ linux-mm/mm/internal.h	2009-11-30 20:44:41.000000000 +0800
@@ -263,3 +263,6 @@ int __get_user_pages(struct task_struct 
 #define ZONE_RECLAIM_SOME	0
 #define ZONE_RECLAIM_SUCCESS	1
 #endif
+
+extern u32 hwpoison_filter_dev_major;
+extern u32 hwpoison_filter_dev_minor;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
