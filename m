Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3A172600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:45 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [24/31] HWPOISON: add an interface to switch off/on all the page filters
Message-Id: <20091208211640.8767AB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:40 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: haicheng.li@linux.intel.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Haicheng Li <haicheng.li@linux.intel.com>

In some use cases, user doesn't need extra filtering. E.g. user program
can inject errors through madvise syscall to its own pages, however it
might not know what the page state exactly is or which inode the page
belongs to.

So introduce an one-off interface "corrupt-filter-enable".

Echo 0 to switch off page filters, and echo 1 to switch on the filters.
[AK: changed default to 0]

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/hwpoison-inject.c |    5 +++++
 mm/internal.h        |    1 +
 mm/memory-failure.c  |    5 +++++
 3 files changed, 11 insertions(+)

Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -92,6 +92,11 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
+	dentry = debugfs_create_u32("corrupt-filter-enable", 0600,
+				    hwpoison_dir, &hwpoison_filter_enable);
+	if (!dentry)
+		goto fail;
+
 	dentry = debugfs_create_u32("corrupt-filter-dev-major", 0600,
 				    hwpoison_dir, &hwpoison_filter_dev_major);
 	if (!dentry)
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -271,3 +271,4 @@ extern u32 hwpoison_filter_dev_minor;
 extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
 extern u64 hwpoison_filter_memcg;
+extern u32 hwpoison_filter_enable;
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -49,10 +49,12 @@ int sysctl_memory_failure_recovery __rea
 
 atomic_long_t mce_bad_pages __read_mostly = ATOMIC_LONG_INIT(0);
 
+u32 hwpoison_filter_enable = 0;
 u32 hwpoison_filter_dev_major = ~0U;
 u32 hwpoison_filter_dev_minor = ~0U;
 u64 hwpoison_filter_flags_mask;
 u64 hwpoison_filter_flags_value;
+EXPORT_SYMBOL_GPL(hwpoison_filter_enable);
 EXPORT_SYMBOL_GPL(hwpoison_filter_dev_major);
 EXPORT_SYMBOL_GPL(hwpoison_filter_dev_minor);
 EXPORT_SYMBOL_GPL(hwpoison_filter_flags_mask);
@@ -141,6 +143,9 @@ static int hwpoison_filter_task(struct p
 
 int hwpoison_filter(struct page *p)
 {
+	if (!hwpoison_filter_enable)
+		return 0;
+
 	if (hwpoison_filter_dev(p))
 		return -EINVAL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
