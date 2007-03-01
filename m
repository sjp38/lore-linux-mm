Date: Thu, 1 Mar 2007 18:59:57 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] [patch] mm: fix xip issue with /dev/zero
In-Reply-To: <1172513050.5685.21.camel@cotte.boeblingen.de.ibm.com>
Message-ID: <Pine.LNX.4.64.0703011808440.13472@blonde.wat.veritas.com>
References: <1171628558.7328.16.camel@cotte.boeblingen.de.ibm.com>
 <Pine.LNX.4.64.0702181855230.16343@blonde.wat.veritas.com>
 <1172513050.5685.21.camel@cotte.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Feb 2007, Carsten Otte wrote:

> Thanks for your review feedback Hugh, I do appreciate it. Here comes my
> second attempt:

Still not quite right, so I took your patch and reworked it below:
if you agree with that version, please send it on to akpm.

Things I didn't like about yours: I think you misunderstood me on
__xip_unmap, my point was that it's silly for that to be allocating
at all; if you can avoid GFP_ATOMIC you should, GFP_HIGHUSER is the
most appropriate in this case; xip_file_nopage ought to distinguish
the new NOPAGE_OOM case from its existing NULLs, which I therefore
changed to NOPAGE_SIGBUSs (filemap_nopage was made clearer that way
in 2.6.19); and in doing this, I've realized that there's no need
to change do_xip_mapping_read, its use of the ZERO_PAGE is safe
(so very likely we'll never allocate a __xip_sparse_page at all).

But I hesitated over my !page test at the start of __xip_unmap:
doesn't the "page = __xip_sparse_page" need an smp_rmb() before
it, to serialize against something setting __xip_sparse_page
concurrently?  Then realized there's an underlying raciness
there, and that's the least of it: __xip_unmap has nothing to
guard against a racing task (whose get_xip_page said -ENODATA
a moment earlier) inserting __xip_sparse_page into a vma of the
file just after __xip_unmap has checked it.

Well, fixing that would be another patch entirely, and not one
I want to think about at present: it's not obvious to me what
the appropriate locking should be, and it's probably not even
fixable within xip_file_nopage: that's a price we pay for
trying to play special zero/sparse page tricks here.



This patch fixes the bug, that reading into xip mapping from /dev/zero
fills the user page table with ZERO_PAGE() entries. Later on, xip cannot
tell which pages have been ZERO_PAGE() filled by access to a sparse
mapping, and which ones origin from /dev/zero. It will unmap ZERO_PAGE
from all mappings when filling the sparse hole with data.
xip does now use its own zeroed page for its sparse mappings.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/filemap_xip.c |   48 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 11 deletions(-)

--- 2.6.21-rc2/mm/filemap_xip.c	2007-02-04 18:44:54.000000000 +0000
+++ linux/mm/filemap_xip.c	2007-03-01 18:25:48.000000000 +0000
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
@@ -162,7 +185,7 @@ EXPORT_SYMBOL_GPL(xip_file_sendfile);
  * xip_write
  *
  * This function walks all vmas of the address_space and unmaps the
- * ZERO_PAGE when found at pgoff. Should it go in rmap.c?
+ * __xip_sparse_page when found at pgoff.
  */
 static void
 __xip_unmap (struct address_space * mapping,
@@ -177,13 +200,16 @@ __xip_unmap (struct address_space * mapp
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
@@ -222,16 +248,14 @@ xip_file_nopage(struct vm_area_struct * 
 		+ area->vm_pgoff;
 
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (pgoff >= size) {
-		return NULL;
-	}
+	if (pgoff >= size)
+		return NOPAGE_SIGBUS;
 
 	page = mapping->a_ops->get_xip_page(mapping, pgoff*(PAGE_SIZE/512), 0);
-	if (!IS_ERR(page)) {
+	if (!IS_ERR(page))
 		goto out;
-	}
 	if (PTR_ERR(page) != -ENODATA)
-		return NULL;
+		return NOPAGE_SIGBUS;
 
 	/* sparse block */
 	if ((area->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
@@ -241,12 +265,14 @@ xip_file_nopage(struct vm_area_struct * 
 		page = mapping->a_ops->get_xip_page (mapping,
 			pgoff*(PAGE_SIZE/512), 1);
 		if (IS_ERR(page))
-			return NULL;
+			return NOPAGE_SIGBUS;
 		/* unmap page at pgoff from all other vmas */
 		__xip_unmap(mapping, pgoff);
 	} else {
-		/* not shared and writable, use ZERO_PAGE() */
-		page = ZERO_PAGE(0);
+		/* not shared and writable, use xip_sparse_page() */
+		page = xip_sparse_page();
+		if (!page)
+			return NOPAGE_OOM;
 	}
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
