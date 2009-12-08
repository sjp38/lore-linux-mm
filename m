Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE9560021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:18:30 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [19/31] mm: export stable page flags
Message-Id: <20091208211635.7965AB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:35 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, mpm@selenic.com, npiggin@suse.de, cl@linux-foundation.org, andi@firstfloor.orgfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Rename get_uflags() to stable_page_flags() and make it a global function
for use in the hwpoison page flags filter, which need to compare user
page flags with the value provided by user space.

Also move KPF_* to kernel-page-flags.h for use by user space tools.

CC: Matt Mackall <mpm@selenic.com>
CC: Nick Piggin <npiggin@suse.de>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 fs/proc/page.c                    |   45 ++-----------------------------------
 include/linux/kernel-page-flags.h |   46 ++++++++++++++++++++++++++++++++++++++
 include/linux/page-flags.h        |    2 +
 3 files changed, 51 insertions(+), 42 deletions(-)

Index: linux/fs/proc/page.c
===================================================================
--- linux.orig/fs/proc/page.c
+++ linux/fs/proc/page.c
@@ -8,6 +8,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
+#include <linux/kernel-page-flags.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
@@ -71,52 +72,12 @@ static const struct file_operations proc
  * physical page flags.
  */
 
-/* These macros are used to decouple internal flags from exported ones */
-
-#define KPF_LOCKED		0
-#define KPF_ERROR		1
-#define KPF_REFERENCED		2
-#define KPF_UPTODATE		3
-#define KPF_DIRTY		4
-#define KPF_LRU			5
-#define KPF_ACTIVE		6
-#define KPF_SLAB		7
-#define KPF_WRITEBACK		8
-#define KPF_RECLAIM		9
-#define KPF_BUDDY		10
-
-/* 11-20: new additions in 2.6.31 */
-#define KPF_MMAP		11
-#define KPF_ANON		12
-#define KPF_SWAPCACHE		13
-#define KPF_SWAPBACKED		14
-#define KPF_COMPOUND_HEAD	15
-#define KPF_COMPOUND_TAIL	16
-#define KPF_HUGE		17
-#define KPF_UNEVICTABLE		18
-#define KPF_HWPOISON		19
-#define KPF_NOPAGE		20
-
-#define KPF_KSM			21
-
-/* kernel hacking assistances
- * WARNING: subject to change, never rely on them!
- */
-#define KPF_RESERVED		32
-#define KPF_MLOCKED		33
-#define KPF_MAPPEDTODISK	34
-#define KPF_PRIVATE		35
-#define KPF_PRIVATE_2		36
-#define KPF_OWNER_PRIVATE	37
-#define KPF_ARCH		38
-#define KPF_UNCACHED		39
-
 static inline u64 kpf_copy_bit(u64 kflags, int ubit, int kbit)
 {
 	return ((kflags >> kbit) & 1) << ubit;
 }
 
-static u64 get_uflags(struct page *page)
+u64 stable_page_flags(struct page *page)
 {
 	u64 k;
 	u64 u;
@@ -219,7 +180,7 @@ static ssize_t kpageflags_read(struct fi
 		else
 			ppage = NULL;
 
-		if (put_user(get_uflags(ppage), out)) {
+		if (put_user(stable_page_flags(ppage), out)) {
 			ret = -EFAULT;
 			break;
 		}
Index: linux/include/linux/page-flags.h
===================================================================
--- linux.orig/include/linux/page-flags.h
+++ linux/include/linux/page-flags.h
@@ -284,6 +284,8 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+u64 stable_page_flags(struct page *page);
+
 static inline int PageUptodate(struct page *page)
 {
 	int ret = test_bit(PG_uptodate, &(page)->flags);
Index: linux/include/linux/kernel-page-flags.h
===================================================================
--- /dev/null
+++ linux/include/linux/kernel-page-flags.h
@@ -0,0 +1,46 @@
+#ifndef LINUX_KERNEL_PAGE_FLAGS_H
+#define LINUX_KERNEL_PAGE_FLAGS_H
+
+/*
+ * Stable page flag bits exported to user space
+ */
+
+#define KPF_LOCKED		0
+#define KPF_ERROR		1
+#define KPF_REFERENCED		2
+#define KPF_UPTODATE		3
+#define KPF_DIRTY		4
+#define KPF_LRU			5
+#define KPF_ACTIVE		6
+#define KPF_SLAB		7
+#define KPF_WRITEBACK		8
+#define KPF_RECLAIM		9
+#define KPF_BUDDY		10
+
+/* 11-20: new additions in 2.6.31 */
+#define KPF_MMAP		11
+#define KPF_ANON		12
+#define KPF_SWAPCACHE		13
+#define KPF_SWAPBACKED		14
+#define KPF_COMPOUND_HEAD	15
+#define KPF_COMPOUND_TAIL	16
+#define KPF_HUGE		17
+#define KPF_UNEVICTABLE		18
+#define KPF_HWPOISON		19
+#define KPF_NOPAGE		20
+
+#define KPF_KSM			21
+
+/* kernel hacking assistances
+ * WARNING: subject to change, never rely on them!
+ */
+#define KPF_RESERVED		32
+#define KPF_MLOCKED		33
+#define KPF_MAPPEDTODISK	34
+#define KPF_PRIVATE		35
+#define KPF_PRIVATE_2		36
+#define KPF_OWNER_PRIVATE	37
+#define KPF_ARCH		38
+#define KPF_UNCACHED		39
+
+#endif /* LINUX_KERNEL_PAGE_FLAGS_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
