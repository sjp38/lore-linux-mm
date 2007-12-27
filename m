Message-Id: <20071227053400.975702729@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:32:52 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 06/18] Use page_cache_xxx in mm/filemap_xip.c
Content-Disposition: inline; filename=0007-Use-page_cache_xxx-in-mm-filemap_xip.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/filemap_xip.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/filemap_xip.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

Index: linux-2.6.24-rc6-mm1/mm/filemap_xip.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/filemap_xip.c	2007-12-26 20:06:34.799489470 -0800
+++ linux-2.6.24-rc6-mm1/mm/filemap_xip.c	2007-12-26 20:06:58.159627986 -0800
@@ -61,24 +61,24 @@ do_xip_mapping_read(struct address_space
 
 	BUG_ON(!mapping->a_ops->get_xip_page);
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	index = page_cache_index(mapping, *ppos);
+	offset = page_cache_offset(mapping, *ppos);
 
 	isize = i_size_read(inode);
 	if (!isize)
 		goto out;
 
-	end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+	end_index = page_cache_index(mapping, isize - 1);
 	for (;;) {
 		struct page *page;
 		unsigned long nr, ret;
 
 		/* nr is the maximum number of bytes to copy from this page */
-		nr = PAGE_CACHE_SIZE;
+		nr = page_cache_size(mapping);
 		if (index >= end_index) {
 			if (index > end_index)
 				goto out;
-			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			nr = page_cache_next(mapping, isize);
 			if (nr <= offset) {
 				goto out;
 			}
@@ -117,8 +117,8 @@ do_xip_mapping_read(struct address_space
 		 */
 		ret = actor(desc, page, offset, nr);
 		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		index += page_cache_index(mapping, offset);
+		offset = page_cache_offset(mapping, offset);
 
 		if (ret == nr && desc->count)
 			continue;
@@ -131,7 +131,7 @@ no_xip_page:
 	}
 
 out:
-	*ppos = ((loff_t) index << PAGE_CACHE_SHIFT) + offset;
+	*ppos = page_cache_pos(mapping, index, offset);
 	if (filp)
 		file_accessed(filp);
 }
@@ -220,7 +220,7 @@ static int xip_file_fault(struct vm_area
 
 	/* XXX: are VM_FAULT_ codes OK? */
 
-	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	size = page_cache_next(mapping, i_size_read(inode));
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 
@@ -290,9 +290,9 @@ __xip_file_write(struct file *filp, cons
 		size_t copied;
 		char *kaddr;
 
-		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
-		index = pos >> PAGE_CACHE_SHIFT;
-		bytes = PAGE_CACHE_SIZE - offset;
+		offset = page_cache_offset(mapping, pos); /* Within page */
+		index = page_cache_index(mapping, pos);
+		bytes = page_cache_size(mapping) - offset;
 		if (bytes > count)
 			bytes = count;
 
@@ -403,8 +403,8 @@ EXPORT_SYMBOL_GPL(xip_file_write);
 int
 xip_truncate_page(struct address_space *mapping, loff_t from)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = page_cache_index(mapping, from);
+	unsigned offset = page_cache_offset(mapping, from);
 	unsigned blocksize;
 	unsigned length;
 	struct page *page;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
