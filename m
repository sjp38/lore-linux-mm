Date: Wed, 7 Feb 2007 23:52:14 +1100
From: David Chinner <dgc@sgi.com>
Subject: [PATCH 1 of 2] Implement XFS ->page_mkwrite() callout
Message-ID: <20070207125214.GL44411608@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use the generic block_page_mkrite() to implement the XFS
->page_mkwrite() callout.

Signed-Off-By: Dave Chinner <dgc@sgi.com>


---
 fs/xfs/linux-2.6/xfs_file.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

Index: 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_file.c
===================================================================
--- 2.6.x-xfs-new.orig/fs/xfs/linux-2.6/xfs_file.c	2007-02-07 23:00:10.000000000 +1100
+++ 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_file.c	2007-02-07 23:15:20.170880823 +1100
@@ -446,6 +446,20 @@ xfs_file_open_exec(
 }
 #endif /* HAVE_FOP_OPEN_EXEC */
 
+/*
+ * mmap()d file has taken write protection fault and is being made
+ * writable. We can set the page state up correctly for a writable
+ * page, which means we can do correct delalloc accounting (ENOSPC
+ * checking!) and unwritten extent mapping.
+ */
+STATIC int
+xfs_vm_page_mkwrite(
+	struct vm_area_struct	*vma,
+	struct page		*page)
+{
+	return block_page_mkwrite(vma, page, xfs_get_blocks);
+}
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
@@ -503,12 +517,14 @@ const struct file_operations xfs_dir_fil
 static struct vm_operations_struct xfs_file_vm_ops = {
 	.nopage		= filemap_nopage,
 	.populate	= filemap_populate,
+	.page_mkwrite	= xfs_vm_page_mkwrite,
 };
 
 #ifdef HAVE_DMAPI
 static struct vm_operations_struct xfs_dmapi_file_vm_ops = {
 	.nopage		= xfs_vm_nopage,
 	.populate	= filemap_populate,
+	.page_mkwrite	= xfs_vm_page_mkwrite,
 #ifdef HAVE_VMOP_MPROTECT
 	.mprotect	= xfs_vm_mprotect,
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
