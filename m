Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id l2RFbnNa299268
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 15:37:49 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2RFbne91642672
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 17:37:49 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2RFbnNd012407
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 17:37:49 +0200
Subject: Re: [RFC] [patch] mm: fix xip issue with /dev/zero
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0703011808440.13472@blonde.wat.veritas.com>
References: <1171628558.7328.16.camel@cotte.boeblingen.de.ibm.com>
	 <Pine.LNX.4.64.0702181855230.16343@blonde.wat.veritas.com>
	 <1172513050.5685.21.camel@cotte.boeblingen.de.ibm.com>
	 <Pine.LNX.4.64.0703011808440.13472@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Tue, 27 Mar 2007 17:37:48 +0200
Message-Id: <1175009868.8401.8.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Am Donnerstag, den 01.03.2007, 18:59 +0000 schrieb Hugh Dickins:
> Still not quite right, so I took your patch and reworked it below:
> if you agree with that version, please send it on to akpm.
Sorry for my late reply. The patch does'nt apply on -mm anymore, because
filemap_xip now uses fault instead of nopage. I modified your patch
again to fit on current -mm. Did I miss something? If no, I will send it
to Andrew. I've done some basic testing on it, all seems to work well.

This patch fixes the bug, that reading into xip mapping from /dev/zero
fills the user page table with ZERO_PAGE() entries. Later on, xip cannot
tell which pages have been ZERO_PAGE() filled by access to a sparse
mapping, and which ones origin from /dev/zero. It will unmap ZERO_PAGE
from all mappings when filling the sparse hole with data.
xip does now use its own zeroed page for its sparse mappings.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---

--- linux-2.6.21-rc5-mm2/mm/filemap_xip.c	2007-03-27 12:51:22.000000000 +0200
+++ linux-2.6.21-rc5-mm2+patch/mm/filemap_xip.c	2007-03-27 15:37:44.000000000 +0200
@@ -17,6 +17,29 @@
 #include "filemap.h"
 
 /*
+ * We do use our own empty page to avoid interference with other users
+ * of ZERO_PAGE(), such as /dev/zero
+ */
+static struct page *__xip_sparse_page;
+
+static struct page *xip_sparse_page(void)
+{
+	if (!__xip_sparse_page) {
+		unsigned long zeroes = get_zeroed_page(GFP_HIGHUSER);
+		if (zeroes) {
+			static DEFINE_SPINLOCK(xip_alloc_lock);
+			spin_lock(&xip_alloc_lock);
+			if (!__xip_sparse_page)
+				__xip_sparse_page = virt_to_page(zeroes);
+			else
+				free_page(zeroes);
+			spin_unlock(&xip_alloc_lock);
+		}
+	}
+	return __xip_sparse_page;
+}
+
+/*
  * This is a file read routine for execute in place files, and uses
  * the mapping->a_ops->get_xip_page() function for the actual low-level
  * stuff.
@@ -162,7 +185,7 @@
  * xip_write
  *
  * This function walks all vmas of the address_space and unmaps the
- * ZERO_PAGE when found at pgoff. Should it go in rmap.c?
+ * __xip_sparse_page when found at pgoff.
  */
 static void
 __xip_unmap (struct address_space * mapping,
@@ -177,13 +200,16 @@
 	spinlock_t *ptl;
 	struct page *page;
 
+	page = __xip_sparse_page;
+	if (!page)
+		return;
+
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-		page = ZERO_PAGE(0);
 		pte = page_check_address(page, mm, address, &ptl);
 		if (pte) {
 			/* Nuke the page table entry. */
@@ -245,8 +271,12 @@
 		/* unmap page at pgoff from all other vmas */
 		__xip_unmap(mapping, fdata->pgoff);
 	} else {
-		/* not shared and writable, use ZERO_PAGE() */
-		page = ZERO_PAGE(0);
+		/* not shared and writable, use xip_sparse_page() */
+		page = xip_sparse_page();
+		if (!page) {
+	                fdata->type = VM_FAULT_OOM;
+	                return NULL;
+		}
 	}
 
 out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
