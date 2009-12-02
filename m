From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 18/24] HWPOISON: add page flags filter
Date: Wed, 02 Dec 2009 11:12:49 +0800
Message-ID: <20091202043045.991390038@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4137560079C
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-filter-pgflags.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

When specified, only poison pages if ((page_flags & mask) == value).

-       corrupt-filter-flags-mask
-       corrupt-filter-flags-value

This allows stress testing of many kinds of pages.

Strictly speaking, the buddy pages requires taking zone lock, to avoid
setting PG_hwpoison on a "was buddy but now allocated to someone" page.
However we can just do nothing because we set PG_locked in the beginning,
this prevents the page allocator from allocating it to someone. (It will
BUG() on the unexpected PG_locked, which is fine for hwpoison testing.)

CC: Nick Piggin <npiggin@suse.de>
CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/hwpoison-inject.c |   10 ++++++++++
 mm/internal.h        |    2 ++
 mm/memory-failure.c  |   18 ++++++++++++++++++
 3 files changed, 30 insertions(+)

--- linux-mm.orig/mm/hwpoison-inject.c	2009-12-01 09:56:00.000000000 +0800
+++ linux-mm/mm/hwpoison-inject.c	2009-12-01 09:56:06.000000000 +0800
@@ -85,6 +85,16 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
+	dentry = debugfs_create_u64("corrupt-filter-flags-mask", 0600,
+				    hwpoison_dir, &hwpoison_filter_flags_mask);
+	if (!dentry)
+		goto fail;
+
+	dentry = debugfs_create_u64("corrupt-filter-flags-value", 0600,
+				    hwpoison_dir, &hwpoison_filter_flags_value);
+	if (!dentry)
+		goto fail;
+
 	return 0;
 fail:
 	pfn_inject_exit();
--- linux-mm.orig/mm/internal.h	2009-12-01 09:56:00.000000000 +0800
+++ linux-mm/mm/internal.h	2009-12-01 09:56:06.000000000 +0800
@@ -268,3 +268,5 @@ extern int hwpoison_filter(struct page *
 
 extern u32 hwpoison_filter_dev_major;
 extern u32 hwpoison_filter_dev_minor;
+extern u64 hwpoison_filter_flags_mask;
+extern u64 hwpoison_filter_flags_value;
--- linux-mm.orig/mm/memory-failure.c	2009-11-30 20:51:22.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-12-01 09:56:06.000000000 +0800
@@ -34,6 +34,7 @@
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/page-flags.h>
+#include <linux/kernel-page-flags.h>
 #include <linux/sched.h>
 #include <linux/ksm.h>
 #include <linux/rmap.h>
@@ -50,6 +51,8 @@ atomic_long_t mce_bad_pages __read_mostl
 
 u32 hwpoison_filter_dev_major = ~0U;
 u32 hwpoison_filter_dev_minor = ~0U;
+u64 hwpoison_filter_flags_mask;
+u64 hwpoison_filter_flags_value;
 
 static int hwpoison_filter_dev(struct page *p)
 {
@@ -81,11 +84,26 @@ static int hwpoison_filter_dev(struct pa
 	return 0;
 }
 
+static int hwpoison_filter_flags(struct page *p)
+{
+	if (!hwpoison_filter_flags_mask)
+		return 0;
+
+	if ((stable_page_flags(p) & hwpoison_filter_flags_mask) ==
+				    hwpoison_filter_flags_value)
+		return 0;
+	else
+		return -EINVAL;
+}
+
 int hwpoison_filter(struct page *p)
 {
 	if (hwpoison_filter_dev(p))
 		return -EINVAL;
 
+	if (hwpoison_filter_flags(p))
+		return -EINVAL;
+
 	return 0;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
