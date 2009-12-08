Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5B052600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:17:04 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [20/31] HWPOISON: add page flags filter
Message-Id: <20091208211636.7C2E8B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:36 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, npiggin@suse.defengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

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
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/vm/hwpoison.txt |   10 ++++++++++
 mm/hwpoison-inject.c          |   10 ++++++++++
 mm/internal.h                 |    2 ++
 mm/memory-failure.c           |   20 ++++++++++++++++++++
 4 files changed, 42 insertions(+)

Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -102,6 +102,16 @@ static int pfn_inject_init(void)
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
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -268,3 +268,5 @@ extern int hwpoison_filter(struct page *
 
 extern u32 hwpoison_filter_dev_major;
 extern u32 hwpoison_filter_dev_minor;
+extern u64 hwpoison_filter_flags_mask;
+extern u64 hwpoison_filter_flags_value;
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -34,6 +34,7 @@
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/page-flags.h>
+#include <linux/kernel-page-flags.h>
 #include <linux/sched.h>
 #include <linux/ksm.h>
 #include <linux/rmap.h>
@@ -50,8 +51,12 @@ atomic_long_t mce_bad_pages __read_mostl
 
 u32 hwpoison_filter_dev_major = ~0U;
 u32 hwpoison_filter_dev_minor = ~0U;
+u64 hwpoison_filter_flags_mask;
+u64 hwpoison_filter_flags_value;
 EXPORT_SYMBOL_GPL(hwpoison_filter_dev_major);
 EXPORT_SYMBOL_GPL(hwpoison_filter_dev_minor);
+EXPORT_SYMBOL_GPL(hwpoison_filter_flags_mask);
+EXPORT_SYMBOL_GPL(hwpoison_filter_flags_value);
 
 static int hwpoison_filter_dev(struct page *p)
 {
@@ -83,11 +88,26 @@ static int hwpoison_filter_dev(struct pa
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
 EXPORT_SYMBOL_GPL(hwpoison_filter);
Index: linux/Documentation/vm/hwpoison.txt
===================================================================
--- linux.orig/Documentation/vm/hwpoison.txt
+++ linux/Documentation/vm/hwpoison.txt
@@ -123,6 +123,16 @@ Only handle memory failures to pages ass
 by block device major/minor.  -1U is the wildcard value.
 This should be only used for testing with artificial injection.
 
+
+corrupt-filter-flags-mask
+corrupt-filter-flags-value
+
+When specified, only poison pages if ((page_flags & mask) == value).
+This allows stress testing of many kinds of pages. The page_flags
+are the same as in /proc/kpageflags. The flag bits are defined in
+include/linux/kernel-page-flags.h and documented in
+Documentation/vm/pagemap.txt
+
 Architecture specific MCE injector
 
 x86 has mce-inject, mce-test

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
