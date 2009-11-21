Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C7FC860021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 05:00:44 -0500 (EST)
Received: by gxk24 with SMTP id 24so9323384gxk.6
        for <linux-mm@kvack.org>; Mon, 28 Dec 2009 02:00:43 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 1/3 -mmotm-2009-12-10-17-19] Move functions related to zero page
Date: Sat, 21 Nov 2009 12:24:18 +0900
Message-Id: <ceeec51bdc2be64416e05ca16da52a126b598e17.1258773030.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch moves is_zero_pfn and my_zero_pfn to mm.h
for other use case.

This patch has no side effect and helps following patches.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/mm.h |   15 +++++++++++++++
 mm/memory.c        |   14 --------------
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index be7f851..71bacd1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -751,6 +751,21 @@ struct zap_details {
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
+#ifndef is_zero_pfn
+extern unsigned long zero_pfn;
+static inline int is_zero_pfn(unsigned long pfn)
+{
+	return pfn == zero_pfn;
+}
+#endif
+
+#ifndef my_zero_pfn
+static inline unsigned long my_zero_pfn(unsigned long addr)
+{
+	return zero_pfn;
+}
+#endif
+
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		pte_t pte);
 
diff --git a/mm/memory.c b/mm/memory.c
index 09e4b1b..3743fb5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -457,20 +457,6 @@ static inline int is_cow_mapping(unsigned int flags)
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 }
 
-#ifndef is_zero_pfn
-static inline int is_zero_pfn(unsigned long pfn)
-{
-	return pfn == zero_pfn;
-}
-#endif
-
-#ifndef my_zero_pfn
-static inline unsigned long my_zero_pfn(unsigned long addr)
-{
-	return zero_pfn;
-}
-#endif
-
 /*
  * vm_normal_page -- This function gets the "struct page" associated with a pte.
  *
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
