Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l1QI4AP7127770
	for <linux-mm@kvack.org>; Mon, 26 Feb 2007 18:04:10 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1QI4Av72129978
	for <linux-mm@kvack.org>; Mon, 26 Feb 2007 19:04:10 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1QI4AGp030997
	for <linux-mm@kvack.org>; Mon, 26 Feb 2007 19:04:10 +0100
Subject: [RFC] [patch] mm: fix xip issue with /dev/zero
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0702181855230.16343@blonde.wat.veritas.com>
References: <1171628558.7328.16.camel@cotte.boeblingen.de.ibm.com>
	 <Pine.LNX.4.64.0702181855230.16343@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Mon, 26 Feb 2007 19:04:10 +0100
Message-Id: <1172513050.5685.21.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Thanks for your review feedback Hugh, I do appreciate it. Here comes my
second attempt:

This patch fixes the bug, that reading into xip mapping from /dev/zero
fills the user page table with ZERO_PAGE() entries. Later on, xip cannot
tell which pages have been ZERO_PAGE() filled by access to a sparse
mapping, and which ones origin from /dev/zero. It will unmap ZERO_PAGE
from all mappings when filling the sparse hole with data.
xip does now use its own zeroed page for its sparse mappings.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>

---
diff -pruN linux-2.6/mm/filemap_xip.c linux-2.6+fix/mm/filemap_xip.c
--- linux-2.6/mm/filemap_xip.c	2007-02-26 13:46:28.000000000 +0100
+++ linux-2.6+fix/mm/filemap_xip.c	2007-02-26 18:45:15.000000000 +0100
@@ -17,6 +17,31 @@
 #include "filemap.h"
 
 /*
+ * We do use our own empty page to avoid interference with other users
+ * of ZERO_PAGE(), such as /dev/zero
+ */
+static struct page *__xip_sparse_page = NULL;
+static DEFINE_SPINLOCK(xip_alloc_lock);
+
+static struct page *xip_sparse_page(void)
+{
+	unsigned long tmp;
+
+	if (!__xip_sparse_page) {
+		tmp = get_zeroed_page(GFP_ATOMIC);
+		if (!tmp)
+			return NULL;
+		spin_lock(&xip_alloc_lock);
+		if (!__xip_sparse_page)
+			__xip_sparse_page = virt_to_page(tmp);
+		else
+			free_page (tmp);
+		spin_unlock(&xip_alloc_lock);
+	}
+	return __xip_sparse_page;
+}
+
+/*
  * This is a file read routine for execute in place files, and uses
  * the mapping->a_ops->get_xip_page() function for the actual low-level
  * stuff.
@@ -63,12 +88,18 @@ do_xip_mapping_read(struct address_space
 
 		page = mapping->a_ops->get_xip_page(mapping,
 			index*(PAGE_SIZE/512), 0);
-		if (!page)
+		if (!page) {
+			desc->error = -EIO;
 			goto no_xip_page;
+		}
 		if (unlikely(IS_ERR(page))) {
 			if (PTR_ERR(page) == -ENODATA) {
 				/* sparse */
-				page = ZERO_PAGE(0);
+				page = xip_sparse_page();
+				if (!page) {
+					desc->error = -ENOMEM;
+					goto no_xip_page;
+				}
 			} else {
 				desc->error = PTR_ERR(page);
 				goto out;
@@ -102,7 +133,6 @@ do_xip_mapping_read(struct address_space
 
 no_xip_page:
 		/* Did not get the page. Report it */
-		desc->error = -EIO;
 		goto out;
 	}
 
@@ -162,7 +192,7 @@ EXPORT_SYMBOL_GPL(xip_file_sendfile);
  * xip_write
  *
  * This function walks all vmas of the address_space and unmaps the
- * ZERO_PAGE when found at pgoff. Should it go in rmap.c?
+ * xip_sparse_page() when found at pgoff.
  */
 static void
 __xip_unmap (struct address_space * mapping,
@@ -183,7 +213,11 @@ __xip_unmap (struct address_space * mapp
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-		page = ZERO_PAGE(0);
+		page = xip_sparse_page();
+		if (!page)
+			/* cannot allocate xip page, is not mapped anywhere */
+			goto out_unlock;
+
 		pte = page_check_address(page, mm, address, &ptl);
 		if (pte) {
 			/* Nuke the page table entry. */
@@ -196,6 +230,7 @@ __xip_unmap (struct address_space * mapp
 			page_cache_release(page);
 		}
 	}
+out_unlock:
 	spin_unlock(&mapping->i_mmap_lock);
 }
 
@@ -245,12 +280,13 @@ xip_file_nopage(struct vm_area_struct * 
 		/* unmap page at pgoff from all other vmas */
 		__xip_unmap(mapping, pgoff);
 	} else {
-		/* not shared and writable, use ZERO_PAGE() */
-		page = ZERO_PAGE(0);
+		/* not shared and writable, use xip_sparse_page() */
+		page = xip_sparse_page();
 	}
 
 out:
-	page_cache_get(page);
+	if (page)
+		page_cache_get(page);
 	return page;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
