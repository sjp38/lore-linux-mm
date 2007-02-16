Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id l1GCMdCl110292
	for <linux-mm@kvack.org>; Fri, 16 Feb 2007 12:22:39 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1GCMdi61146986
	for <linux-mm@kvack.org>; Fri, 16 Feb 2007 13:22:39 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1GCMdRU012516
	for <linux-mm@kvack.org>; Fri, 16 Feb 2007 13:22:39 +0100
Subject: [patch] mm: fix xip issue with /dev/zero
From: Carsten Otte <cotte@de.ibm.com>
Content-Type: text/plain
Date: Fri, 16 Feb 2007 13:22:38 +0100
Message-Id: <1171628558.7328.16.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, LinusTorvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This patch removes usage of ZERO_PAGE for xip. We use our own zeroed
page for mapping sparse holes to userland now. That gets us rid of
dependencies with other users of ZERO_PAGE, such as /dev/zero. Thanks to
Hugh for reporting this issue. I tested this briefly and it seems to
work fine, please apply.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>

---
diff -ruN linux-2.6/mm/filemap_xip.c linux-2.6+fix/mm/filemap_xip.c
--- linux-2.6/mm/filemap_xip.c	2007-02-02 13:02:58.000000000 +0100
+++ linux-2.6+fix/mm/filemap_xip.c	2007-02-15 15:18:51.000000000 +0100
@@ -17,6 +17,30 @@
 #include "filemap.h"
 
 /*
+ * We do use our own empty page to avoid interference with other users
+ * of ZERO_PAGE(), such as /dev/zero
+ */
+static struct page * __xip_sparse_page = NULL;
+static spinlock_t   xip_alloc_lock = SPIN_LOCK_UNLOCKED;
+
+static inline struct page *
+xip_sparse_page(void)
+{
+	unsigned long tmp;
+
+	if (!__xip_sparse_page) {
+		tmp = get_zeroed_page(GFP_KERNEL);
+		spin_lock(&xip_alloc_lock);
+		if (!__xip_sparse_page)
+			__xip_sparse_page = virt_to_page(tmp);
+		else
+			free_page (tmp);;
+		spin_unlock(&xip_alloc_lock);
+	}
+	return __xip_sparse_page;
+}
+
+/*
  * This is a file read routine for execute in place files, and uses
  * the mapping->a_ops->get_xip_page() function for the actual low-level
  * stuff.
@@ -68,7 +92,7 @@
 		if (unlikely(IS_ERR(page))) {
 			if (PTR_ERR(page) == -ENODATA) {
 				/* sparse */
-				page = ZERO_PAGE(0);
+				page = xip_sparse_page();
 			} else {
 				desc->error = PTR_ERR(page);
 				goto out;
@@ -162,7 +186,7 @@
  * xip_write
  *
  * This function walks all vmas of the address_space and unmaps the
- * ZERO_PAGE when found at pgoff. Should it go in rmap.c?
+ * xip_sparse_page() when found at pgoff.
  */
 static void
 __xip_unmap (struct address_space * mapping,
@@ -183,7 +207,7 @@
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-		page = ZERO_PAGE(0);
+		page = xip_sparse_page();
 		pte = page_check_address(page, mm, address, &ptl);
 		if (pte) {
 			/* Nuke the page table entry. */
@@ -245,8 +269,8 @@
 		/* unmap page at pgoff from all other vmas */
 		__xip_unmap(mapping, pgoff);
 	} else {
-		/* not shared and writable, use ZERO_PAGE() */
-		page = ZERO_PAGE(0);
+		/* not shared and writable, use xip_sparse_page() */
+		page = xip_sparse_page();
 	}
 
 out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
