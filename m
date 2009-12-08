Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A570D6007B7
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:51 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [31/31] HWPOISON: Add a madvise() injector for soft page offlining
Message-Id: <20091208211647.9B032B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:47 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Process based injection is much easier to handle for test programs,
who can first bring a page into a specific state and then test.
So add a new MADV_SOFT_OFFLINE to soft offline a page, similar
to the existing hard offline injector.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/asm-generic/mman-common.h |    1 +
 mm/madvise.c                      |   15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

Index: linux/include/asm-generic/mman-common.h
===================================================================
--- linux.orig/include/asm-generic/mman-common.h
+++ linux/include/asm-generic/mman-common.h
@@ -35,6 +35,7 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 #define MADV_HWPOISON	100		/* poison a page for testing */
+#define MADV_SOFT_OFFLINE 101		/* soft offline page for testing */
 
 #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
Index: linux/mm/madvise.c
===================================================================
--- linux.orig/mm/madvise.c
+++ linux/mm/madvise.c
@@ -9,6 +9,7 @@
 #include <linux/pagemap.h>
 #include <linux/syscalls.h>
 #include <linux/mempolicy.h>
+#include <linux/page-isolation.h>
 #include <linux/hugetlb.h>
 #include <linux/sched.h>
 #include <linux/ksm.h>
@@ -222,7 +223,7 @@ static long madvise_remove(struct vm_are
 /*
  * Error injection support for memory error handling.
  */
-static int madvise_hwpoison(unsigned long start, unsigned long end)
+static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 {
 	int ret = 0;
 
@@ -233,6 +234,14 @@ static int madvise_hwpoison(unsigned lon
 		int ret = get_user_pages_fast(start, 1, 0, &p);
 		if (ret != 1)
 			return ret;
+		if (bhv == MADV_SOFT_OFFLINE) {
+			printk(KERN_INFO "Soft offlining page %lx at %lx\n",
+				page_to_pfn(p), start);
+			ret = soft_offline_page(p, MF_COUNT_INCREASED);
+			if (ret)
+				break;
+			continue;
+		}
 		printk(KERN_INFO "Injecting memory failure for page %lx at %lx\n",
 		       page_to_pfn(p), start);
 		/* Ignore return value for now */
@@ -333,8 +342,8 @@ SYSCALL_DEFINE3(madvise, unsigned long,
 	size_t len;
 
 #ifdef CONFIG_MEMORY_FAILURE
-	if (behavior == MADV_HWPOISON)
-		return madvise_hwpoison(start, start+len_in);
+	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
+		return madvise_hwpoison(behavior, start, start+len_in);
 #endif
 	if (!madvise_behavior_valid(behavior))
 		return error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
