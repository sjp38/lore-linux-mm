Message-Id: <20080204170526.922820156@szeredi.hu>
References: <20080204170409.991123259@szeredi.hu>
Date: Mon, 04 Feb 2008 18:04:11 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 1/3] vfs: introduce perform_write in a_ops
Content-Disposition: inline; filename=perform_write.patch
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Introduce a new perform_write() address space operation.

This is a single-call, bulk version of write_begin/write_end
operations.  It is only used in the buffered write path (write_begin
must still be implemented), and not for in-kernel writes to pagecache.

For some filesystems, using this can provide significant speedups.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/include/linux/fs.h
===================================================================
--- linux.orig/include/linux/fs.h	2008-02-04 15:24:03.000000000 +0100
+++ linux/include/linux/fs.h	2008-02-04 16:24:19.000000000 +0100
@@ -469,6 +469,9 @@ struct address_space_operations {
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 
+	ssize_t (*perform_write)(struct file *, struct address_space *mapping,
+				struct iov_iter *i, loff_t pos);
+
 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
 	sector_t (*bmap)(struct address_space *, sector_t);
 	void (*invalidatepage) (struct page *, unsigned long);
Index: linux/mm/filemap.c
===================================================================
--- linux.orig/mm/filemap.c	2008-02-04 15:24:03.000000000 +0100
+++ linux/mm/filemap.c	2008-02-04 16:22:55.000000000 +0100
@@ -2312,7 +2312,9 @@ generic_file_buffered_write(struct kiocb
 	struct iov_iter i;
 
 	iov_iter_init(&i, iov, nr_segs, count, written);
-	if (a_ops->write_begin)
+	if (a_ops->perform_write)
+		status = a_ops->perform_write(file, mapping, &i, pos);
+	else if (a_ops->write_begin)
 		status = generic_perform_write(file, &i, pos);
 	else
 		status = generic_perform_write_2copy(file, &i, pos);
Index: linux/Documentation/filesystems/vfs.txt
===================================================================
--- linux.orig/Documentation/filesystems/vfs.txt	2008-02-04 12:28:50.000000000 +0100
+++ linux/Documentation/filesystems/vfs.txt	2008-02-04 16:23:44.000000000 +0100
@@ -533,6 +533,9 @@ struct address_space_operations {
 	int (*write_end)(struct file *, struct address_space *mapping,
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
+	ssize_t (*perform_write)(struct file *, struct address_space *mapping,
+				struct iov_iter *i, loff_t pos);
+
 	sector_t (*bmap)(struct address_space *, sector_t);
 	int (*invalidatepage) (struct page *, unsigned long);
 	int (*releasepage) (struct page *, int);
@@ -664,6 +667,17 @@ struct address_space_operations {
         Returns < 0 on failure, otherwise the number of bytes (<= 'copied')
         that were able to be copied into pagecache.
 
+  perform_write: This is a single-call, bulk version of write_begin/write_end
+        operations. It is only used in the buffered write path (write_begin
+        must still be implemented), and not for in-kernel writes to pagecache.
+        It takes an iov_iter structure, which provides a descriptor for the
+        source data (and has associated iov_iter_xxx helpers to operate on
+        that data). There are also file, mapping, and pos arguments, which
+        specify the destination of the data.
+
+        Returns < 0 on failure if nothing was written out, otherwise returns
+        the number of bytes copied into pagecache.
+
   bmap: called by the VFS to map a logical block offset within object to
   	physical block number. This method is used by the FIBMAP
   	ioctl and for working with swap-files.  To be able to swap to

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
