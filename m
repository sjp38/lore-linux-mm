Message-Id: <20070514060650.542405000@wotan.suse.de>
References: <20070514060619.689648000@wotan.suse.de>
Date: Mon, 14 May 2007 16:06:23 +1000
From: npiggin@suse.de
Subject: [patch 04/41] mm: clean up buffered write code
Content-Disposition: inline; filename=mm-generic_file_buffered_write-cleanup.patch
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Rename some variables and fix some types.

Cc: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>

 mm/filemap.c |   35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1900,16 +1900,15 @@ generic_file_buffered_write(struct kiocb
 		size_t count, ssize_t written)
 {
 	struct file *file = iocb->ki_filp;
-	struct address_space * mapping = file->f_mapping;
+	struct address_space *mapping = file->f_mapping;
 	const struct address_space_operations *a_ops = mapping->a_ops;
 	struct inode 	*inode = mapping->host;
 	long		status = 0;
 	struct page	*page;
 	struct page	*cached_page = NULL;
-	size_t		bytes;
 	struct pagevec	lru_pvec;
 	const struct iovec *cur_iov = iov; /* current iovec */
-	size_t		iov_base = 0;	   /* offset in the current iovec */
+	size_t		iov_offset = 0;	   /* offset in the current iovec */
 	char __user	*buf;
 
 	pagevec_init(&lru_pvec, 0);
@@ -1920,31 +1919,33 @@ generic_file_buffered_write(struct kiocb
 	if (likely(nr_segs == 1))
 		buf = iov->iov_base + written;
 	else {
-		filemap_set_next_iovec(&cur_iov, &iov_base, written);
-		buf = cur_iov->iov_base + iov_base;
+		filemap_set_next_iovec(&cur_iov, &iov_offset, written);
+		buf = cur_iov->iov_base + iov_offset;
 	}
 
 	do {
-		unsigned long index;
-		unsigned long offset;
-		unsigned long maxlen;
-		size_t copied;
+		pgoff_t index;		/* Pagecache index for current page */
+		unsigned long offset;	/* Offset into pagecache page */
+		unsigned long maxlen;	/* Bytes remaining in current iovec */
+		size_t bytes;		/* Bytes to write to page */
+		size_t copied;		/* Bytes copied from user */
 
-		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
+		offset = (pos & (PAGE_CACHE_SIZE - 1));
 		index = pos >> PAGE_CACHE_SHIFT;
 		bytes = PAGE_CACHE_SIZE - offset;
 		if (bytes > count)
 			bytes = count;
 
+		maxlen = cur_iov->iov_len - iov_offset;
+		if (maxlen > bytes)
+			maxlen = bytes;
+
 		/*
 		 * Bring in the user page that we will copy from _first_.
 		 * Otherwise there's a nasty deadlock on copying from the
 		 * same page as we're writing to, without it being marked
 		 * up-to-date.
 		 */
-		maxlen = cur_iov->iov_len - iov_base;
-		if (maxlen > bytes)
-			maxlen = bytes;
 		fault_in_pages_readable(buf, maxlen);
 
 		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
@@ -1975,7 +1976,7 @@ generic_file_buffered_write(struct kiocb
 							buf, bytes);
 		else
 			copied = filemap_copy_from_user_iovec(page, offset,
-						cur_iov, iov_base, bytes);
+						cur_iov, iov_offset, bytes);
 		flush_dcache_page(page);
 		status = a_ops->commit_write(file, page, offset, offset+bytes);
 		if (status == AOP_TRUNCATED_PAGE) {
@@ -1993,12 +1994,12 @@ generic_file_buffered_write(struct kiocb
 				buf += status;
 				if (unlikely(nr_segs > 1)) {
 					filemap_set_next_iovec(&cur_iov,
-							&iov_base, status);
+							&iov_offset, status);
 					if (count)
 						buf = cur_iov->iov_base +
-							iov_base;
+							iov_offset;
 				} else {
-					iov_base += status;
+					iov_offset += status;
 				}
 			}
 		}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
