Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 627E1600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:38 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [18/31] HWPOISON: limit hwpoison injector to known page types
Message-Id: <20091208211634.76A09B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:34 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, haicheng.li@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

__memory_failure()'s workflow is

	set PG_hwpoison
	//...
	unset PG_hwpoison if didn't pass hwpoison filter

That could kill unrelated process if it happens to page fault on the
page with the (temporary) PG_hwpoison. The race should be big enough to
appear in stress tests.

Fix it by grabbing the page and checking filter at inject time.  This
also avoids the very noisy "Injecting memory failure..." messages.

- we don't touch madvise() based injection, because the filters are
  generally not necessary for it.
- if we want to apply the filters to h/w aided injection, we'd better to
  rearrange the logic in __memory_failure() instead of this patch.

AK: fix documentation, use drain all, cleanups

CC: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/vm/hwpoison.txt |    3 ++-
 mm/hwpoison-inject.c          |   41 +++++++++++++++++++++++++++++++++++++++--
 mm/internal.h                 |    2 ++
 3 files changed, 43 insertions(+), 3 deletions(-)

Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -3,16 +3,53 @@
 #include <linux/debugfs.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/pagemap.h>
 #include "internal.h"
 
 static struct dentry *hwpoison_dir;
 
 static int hwpoison_inject(void *data, u64 val)
 {
+	unsigned long pfn = val;
+	struct page *p;
+	int err;
+
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
-	printk(KERN_INFO "Injecting memory failure at pfn %Lx\n", val);
-	return __memory_failure(val, 18, 0);
+
+	if (!pfn_valid(pfn))
+		return -ENXIO;
+
+	p = pfn_to_page(pfn);
+	/*
+	 * This implies unable to support free buddy pages.
+	 */
+	if (!get_page_unless_zero(p))
+		return 0;
+
+	if (!PageLRU(p))
+		shake_page(p);
+	/*
+	 * This implies unable to support non-LRU pages.
+	 */
+	if (!PageLRU(p))
+		return 0;
+
+	/*
+	 * do a racy check with elevated page count, to make sure PG_hwpoison
+	 * will only be set for the targeted owner (or on a free page).
+	 * We temporarily take page lock for try_get_mem_cgroup_from_page().
+	 * __memory_failure() will redo the check reliably inside page lock.
+	 */
+	lock_page(p);
+	err = hwpoison_filter(p);
+	unlock_page(p);
+	if (err)
+		return 0;
+
+	printk(KERN_INFO "Injecting memory failure at pfn %lx\n", pfn);
+	return __memory_failure(pfn, 18, MF_COUNT_INCREASED);
 }
 
 static int hwpoison_unpoison(void *data, u64 val)
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -264,5 +264,7 @@ int __get_user_pages(struct task_struct
 #define ZONE_RECLAIM_SUCCESS	1
 #endif
 
+extern int hwpoison_filter(struct page *p);
+
 extern u32 hwpoison_filter_dev_major;
 extern u32 hwpoison_filter_dev_minor;
Index: linux/Documentation/vm/hwpoison.txt
===================================================================
--- linux.orig/Documentation/vm/hwpoison.txt
+++ linux/Documentation/vm/hwpoison.txt
@@ -103,7 +103,8 @@ hwpoison-inject module through debugfs
 
 corrupt-pfn
 
-Inject hwpoison fault at PFN echoed into this file.
+Inject hwpoison fault at PFN echoed into this file. This does
+some early filtering to avoid corrupted unintended pages in test suites.
 
 unpoison-pfn
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
