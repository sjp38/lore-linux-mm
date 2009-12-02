From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 16/24] HWPOISON: limit hwpoison injector to known page types
Date: Wed, 02 Dec 2009 11:12:47 +0800
Message-ID: <20091202043045.711553780@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7973C6007B8
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-filter-limit-scope.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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

CC: Haicheng Li <haicheng.li@intel.com>
CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/hwpoison-inject.c |   27 ++++++++++++++++++++++++++-
 mm/internal.h        |    2 ++
 2 files changed, 28 insertions(+), 1 deletion(-)

--- linux-mm.orig/mm/hwpoison-inject.c	2009-11-30 20:44:41.000000000 +0800
+++ linux-mm/mm/hwpoison-inject.c	2009-11-30 20:58:20.000000000 +0800
@@ -3,16 +3,41 @@
 #include <linux/debugfs.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
 #include "internal.h"
 
 static struct dentry *hwpoison_dir;
 
 static int hwpoison_inject(void *data, u64 val)
 {
+	unsigned long pfn = val;
+	struct page *p;
+
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
+
+	if (!pfn_valid(pfn))
+		return -ENXIO;
+
+	/*
+	 * This implies unable to support free buddy pages.
+	 */
+	p = pfn_to_page(pfn);
+	if (!get_page_unless_zero(p))
+		return 0;
+
+	if (!PageLRU(p))
+		lru_add_drain_all();
+	/*
+	 * do a racy check with elevated page count, to make sure PG_hwpoison
+	 * will only be set for the targeted owner (or on a free page).
+	 * __memory_failure() will redo the check reliably inside page lock.
+	 */
+	if (hwpoison_filter(p))
+		return 0;
+
 	printk(KERN_INFO "Injecting memory failure at pfn %Lx\n", val);
-	return __memory_failure(val, 18, 0);
+	return __memory_failure(val, 18, 1);
 }
 
 static int hwpoison_forget(void *data, u64 val)
--- linux-mm.orig/mm/internal.h	2009-11-30 20:44:41.000000000 +0800
+++ linux-mm/mm/internal.h	2009-11-30 20:52:11.000000000 +0800
@@ -264,5 +264,7 @@ int __get_user_pages(struct task_struct 
 #define ZONE_RECLAIM_SUCCESS	1
 #endif
 
+extern int hwpoison_filter(struct page *p);
+
 extern u32 hwpoison_filter_dev_major;
 extern u32 hwpoison_filter_dev_minor;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
