Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB376B01BC
	for <linux-mm@kvack.org>; Thu, 27 May 2010 20:32:22 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/8] hugetlb: move definition of is_vm_hugetlb_page() to hugepage_inline.h
Date: Fri, 28 May 2010 09:29:15 +0900
Message-Id: <1275006562-18946-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

is_vm_hugetlb_page() is a widely used inline function to insert hooks
into hugetlb code.
But we can't use it in pagemap.h because of circular dependency of
the header files. This patch removes this limitation.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h        |   11 +----------
 include/linux/hugetlb_inline.h |   22 ++++++++++++++++++++++
 include/linux/pagemap.h        |    1 +
 3 files changed, 24 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/hugetlb_inline.h

diff --git v2.6.34/include/linux/hugetlb.h v2.6.34/include/linux/hugetlb.h
index 78b4bc6..d47a7c4 100644
--- v2.6.34/include/linux/hugetlb.h
+++ v2.6.34/include/linux/hugetlb.h
@@ -2,6 +2,7 @@
 #define _LINUX_HUGETLB_H
 
 #include <linux/fs.h>
+#include <linux/hugetlb_inline.h>
 
 struct ctl_table;
 struct user_struct;
@@ -14,11 +15,6 @@ struct user_struct;
 
 int PageHuge(struct page *page);
 
-static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
-{
-	return vma->vm_flags & VM_HUGETLB;
-}
-
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
@@ -77,11 +73,6 @@ static inline int PageHuge(struct page *page)
 	return 0;
 }
 
-static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
-{
-	return 0;
-}
-
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
diff --git v2.6.34/include/linux/hugetlb_inline.h v2.6.34/include/linux/hugetlb_inline.h
new file mode 100644
index 0000000..cf00b6d
--- /dev/null
+++ v2.6.34/include/linux/hugetlb_inline.h
@@ -0,0 +1,22 @@
+#ifndef _LINUX_HUGETLB_INLINE_H
+#define _LINUX_HUGETLB_INLINE_H 1
+
+#ifdef CONFIG_HUGETLBFS
+
+#include <linux/mm.h>
+
+static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_HUGETLB;
+}
+
+#else
+
+static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
+{
+	return 0;
+}
+
+#endif
+
+#endif
diff --git v2.6.34/include/linux/pagemap.h v2.6.34/include/linux/pagemap.h
index 3c62ed4..b2bd2ba 100644
--- v2.6.34/include/linux/pagemap.h
+++ v2.6.34/include/linux/pagemap.h
@@ -13,6 +13,7 @@
 #include <linux/gfp.h>
 #include <linux/bitops.h>
 #include <linux/hardirq.h> /* for in_interrupt() */
+#include <linux/hugetlb_inline.h>
 
 /*
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
