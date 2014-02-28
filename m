Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 638846B0072
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 07:50:38 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so718512pad.13
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 04:50:38 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id m9si1933497pab.264.2014.02.28.04.50.37
        for <linux-mm@kvack.org>;
        Fri, 28 Feb 2014 04:50:37 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: add debugfs tunable for fault_around_order
Date: Fri, 28 Feb 2014 14:50:33 +0200
Message-Id: <1393591833-24950-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's allow people to tweak faultaround in runtime.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 61 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3f17a60e817f..e2d54e818c5b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -60,6 +60,7 @@
 #include <linux/migrate.h>
 #include <linux/string.h>
 #include <linux/dma-debug.h>
+#include <linux/debugfs.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3344,8 +3345,63 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 }
 
 #define FAULT_AROUND_ORDER 4
-#define FAULT_AROUND_PAGES (1UL << FAULT_AROUND_ORDER)
-#define FAULT_AROUND_MASK ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1)
+
+#ifdef CONFIG_DEBUG_FS
+static unsigned int fault_around_order = FAULT_AROUND_ORDER;
+
+static int fault_around_order_get(void *data, u64 *val)
+{
+	*val = fault_around_order;
+	return 0;
+}
+
+static int fault_around_order_set(void *data, u64 val)
+{
+	BUILD_BUG_ON((1UL << FAULT_AROUND_ORDER) > PTRS_PER_PTE);
+	if (1UL << val > PTRS_PER_PTE)
+		return -EINVAL;
+	fault_around_order = val;
+	return 0;
+}
+DEFINE_SIMPLE_ATTRIBUTE(fault_around_order_fops,
+		fault_around_order_get, fault_around_order_set, "%llu\n");
+
+static int __init fault_around_debugfs(void)
+{
+	void *ret;
+
+	ret = debugfs_create_file("fault_around_order",	0644, NULL, NULL,
+			&fault_around_order_fops);
+	if (!ret)
+		pr_warning("Failed to create fault_around_order in debugfs");
+	return 0;
+}
+late_initcall(fault_around_debugfs);
+
+static inline unsigned long fault_around_pages(void)
+{
+	return 1UL << fault_around_order;
+}
+
+static inline unsigned long fault_around_mask(void)
+{
+	return ~((1UL << (PAGE_SHIFT + fault_around_order)) - 1);
+}
+#else
+static inline unsigned long fault_around_pages(void)
+{
+	unsigned long nr_pages;
+
+	nr_pages = 1UL << FAULT_AROUND_ORDER;
+	BUILD_BUG_ON(nr_pages > PTRS_PER_PTE);
+	return nr_pages;
+}
+
+static inline unsigned long fault_around_mask(void)
+{
+	return ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1);
+}
+#endif
 
 static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte_t *pte, pgoff_t pgoff, unsigned int flags)
@@ -3355,21 +3411,19 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 	struct vm_fault vmf;
 	int off;
 
-	BUILD_BUG_ON(FAULT_AROUND_PAGES > PTRS_PER_PTE);
-
-	start_addr = max(address & FAULT_AROUND_MASK, vma->vm_start);
+	start_addr = max(address & fault_around_mask(), vma->vm_start);
 	off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
 	pte -= off;
 	pgoff -= off;
 
 	/*
 	 *  max_pgoff is either end of page table or end of vma
-	 *  or FAULT_AROUND_PAGES from pgoff, depending what is neast.
+	 *  or fault_around_pages() from pgoff, depending what is neast.
 	 */
 	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
 		PTRS_PER_PTE - 1;
 	max_pgoff = min3(max_pgoff, vma_pages(vma) + vma->vm_pgoff - 1,
-			pgoff + FAULT_AROUND_PAGES - 1);
+			pgoff + fault_around_pages() - 1);
 
 	/* Check if it makes any sense to call ->map_pages */
 	while (!pte_none(*pte)) {
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
