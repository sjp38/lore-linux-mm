Date: Wed, 7 Feb 2007 09:53:25 +1100
From: David Chinner <dgc@sgi.com>
Subject: [RFC] Implement ->page_mkwrite for XFS
Message-ID: <20070206225325.GP33919298@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Folks,

I'm not sure of the exact locking rules and constraints for
->page_mkwrite(), so I thought I better fish around for comments.

With XFS, we need to hook pages being dirtied by mmap writes so that
we can attach buffers of the correct state tothe pages.  This means
that when we write them back, the correct thing happens.

For example, if you mmap an unwritten extent (preallocated),
currently your data will get written to disk but the extent will not
get converted to a written extent. IOWs, you lose the data because
when you read it back it will seen as unwritten and treated as a
hole.

AFAICT, it is safe to lock the page during ->page_mkwrite and that
it is safe to issue I/O (e.g. metadata reads) to determine the
current state of the file.  I am also assuming that, at this point,
we are not allowed to change the file size and so we have to be
careful in ->page_mkwrite we don't do that. What else have I missed
here?

IOWs, I've basically treated ->page_mkwrite() as wrapper for
block_prepare_write/block_commit_write because they do all the
buffer mapping and state manipulation I think is necessary.  Is it
safe to call these functions, or are there some other constraints we
have to work under here?

Patch below. Comments?

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group


---
 fs/xfs/linux-2.6/xfs_file.c |   34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

Index: 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_file.c
===================================================================
--- 2.6.x-xfs-new.orig/fs/xfs/linux-2.6/xfs_file.c	2007-01-16 10:54:15.000000000 +1100
+++ 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_file.c	2007-02-07 09:49:00.508017483 +1100
@@ -446,6 +446,38 @@ xfs_file_open_exec(
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
+	struct inode	*inode = vma->vm_file->f_path.dentry->d_inode;
+	unsigned long	end;
+	int		ret = 0;
+
+	end = page->index + 1;
+	end <<= PAGE_CACHE_SHIFT;
+	if (end > i_size_read(inode))
+		end = i_size_read(inode) & ~PAGE_CACHE_MASK;
+	else
+		end = PAGE_CACHE_SIZE;
+
+	lock_page(page);
+	ret = block_prepare_write(page, 0, end, xfs_get_blocks);
+	if (!ret)
+		ret = block_commit_write(page, 0, end);
+	unlock_page(page);
+
+	return ret;
+}
+
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
@@ -503,12 +535,14 @@ const struct file_operations xfs_dir_fil
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
