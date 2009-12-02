From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 23/24] HWPOISON: add an interface to switch off/on all the page filters
Date: Wed, 02 Dec 2009 11:12:54 +0800
Message-ID: <20091202043046.644456847@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A74C6007B9
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-filter-enable.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Haicheng Li <haicheng.li@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

From: Haicheng Li <haicheng.li@linux.intel.com>

In some use cases, user doesn't need extra filtering. E.g. user program
can inject errors through madvise syscall to its own pages, however it
might not know what the page state exactly is or which inode the page
belongs to.

So introduce an one-off interface "corrupt-filter-enable".

Echo 0 to switch off page filters, and echo 1 to switch on the filters.
Its default value is 1, i.e. all page filters are in effect.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/hwpoison-inject.c |    5 +++++
 mm/internal.h        |    1 +
 mm/memory-failure.c  |    4 ++++
 3 files changed, 10 insertions(+)

--- linux-mm.orig/mm/hwpoison-inject.c	2009-12-01 09:56:18.000000000 +0800
+++ linux-mm/mm/hwpoison-inject.c	2009-12-01 09:56:21.000000000 +0800
@@ -75,6 +75,11 @@ static int pfn_inject_init(void)
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
--- linux-mm.orig/mm/internal.h	2009-12-01 09:56:18.000000000 +0800
+++ linux-mm/mm/internal.h	2009-12-01 09:56:21.000000000 +0800
@@ -271,3 +271,4 @@ extern u32 hwpoison_filter_dev_minor;
 extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
 extern u32 hwpoison_filter_memcg;
+extern u32 hwpoison_filter_enable;
--- linux-mm.orig/mm/memory-failure.c	2009-12-01 09:56:18.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-12-01 09:56:21.000000000 +0800
@@ -49,6 +49,7 @@ int sysctl_memory_failure_recovery __rea
 
 atomic_long_t mce_bad_pages __read_mostly = ATOMIC_LONG_INIT(0);
 
+u32 hwpoison_filter_enable = 1;
 u32 hwpoison_filter_dev_major = ~0U;
 u32 hwpoison_filter_dev_minor = ~0U;
 u64 hwpoison_filter_flags_mask;
@@ -119,6 +120,9 @@ static int hwpoison_filter_task(struct p
 
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
