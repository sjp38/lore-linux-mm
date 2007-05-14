Message-Id: <20070514060651.164919000@wotan.suse.de>
References: <20070514060619.689648000@wotan.suse.de>
Date: Mon, 14 May 2007 16:06:27 +1000
From: npiggin@suse.de
Subject: [patch 08/41] mm: write iovec cleanup
Content-Disposition: inline; filename=mm-write-iov-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hide some of the open-coded nr_segs tests into the iovec helpers. This is
all to simplify generic_file_buffered_write, because that gets more complex
in the next patch.

Cc: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>

 mm/filemap.c     |   36 +++++--------------
 mm/filemap.h     |  104 +++++++++++++++++++++++++++----------------------------
 mm/filemap_xip.c |   17 +++-----
 3 files changed, 69 insertions(+), 88 deletions(-)

Index: linux-2.6/mm/filemap.h
===================================================================
--- linux-2.6.orig/mm/filemap.h
+++ linux-2.6/mm/filemap.h
@@ -22,82 +22,82 @@ __filemap_copy_from_user_iovec_inatomic(
 
 /*
  * Copy as much as we can into the page and return the number of bytes which
- * were sucessfully copied.  If a fault is encountered then clear the page
- * out to (offset+bytes) and return the number of bytes which were copied.
- *
- * NOTE: For this to work reliably we really want copy_from_user_inatomic_nocache
- * to *NOT* zero any tail of the buffer that it failed to copy.  If it does,
- * and if the following non-atomic copy succeeds, then there is a small window
- * where the target page contains neither the data before the write, nor the
- * data after the write (it contains zero).  A read at this time will see
- * data that is inconsistent with any ordering of the read and the write.
- * (This has been detected in practice).
+ * were sucessfully copied.  If a fault is encountered then return the number of
+ * bytes which were copied.
  */
 static inline size_t
-filemap_copy_from_user(struct page *page, unsigned long offset,
-			const char __user *buf, unsigned bytes)
+filemap_copy_from_user_atomic(struct page *page, unsigned long offset,
+			const struct iovec *iov, unsigned long nr_segs,
+			size_t base, size_t bytes)
 {
 	char *kaddr;
-	int left;
+	size_t copied;
 
 	kaddr = kmap_atomic(page, KM_USER0);
-	left = __copy_from_user_inatomic_nocache(kaddr + offset, buf, bytes);
+	if (likely(nr_segs == 1)) {
+		int left;
+		char __user *buf = iov->iov_base + base;
+		left = __copy_from_user_inatomic_nocache(kaddr + offset,
+							buf, bytes);
+		copied = bytes - left;
+	} else {
+		copied = __filemap_copy_from_user_iovec_inatomic(kaddr + offset,
+							iov, base, bytes);
+	}
 	kunmap_atomic(kaddr, KM_USER0);
 
-	if (left != 0) {
-		/* Do it the slow way */
-		kaddr = kmap(page);
-		left = __copy_from_user_nocache(kaddr + offset, buf, bytes);
-		kunmap(page);
-	}
-	return bytes - left;
+	return copied;
 }
 
 /*
- * This has the same sideeffects and return value as filemap_copy_from_user().
- * The difference is that on a fault we need to memset the remainder of the
- * page (out to offset+bytes), to emulate filemap_copy_from_user()'s
- * single-segment behaviour.
+ * This has the same sideeffects and return value as
+ * filemap_copy_from_user_atomic().
+ * The difference is that it attempts to resolve faults.
  */
 static inline size_t
-filemap_copy_from_user_iovec(struct page *page, unsigned long offset,
-			const struct iovec *iov, size_t base, size_t bytes)
+filemap_copy_from_user(struct page *page, unsigned long offset,
+			const struct iovec *iov, unsigned long nr_segs,
+			 size_t base, size_t bytes)
 {
 	char *kaddr;
 	size_t copied;
 
-	kaddr = kmap_atomic(page, KM_USER0);
-	copied = __filemap_copy_from_user_iovec_inatomic(kaddr + offset, iov,
-							 base, bytes);
-	kunmap_atomic(kaddr, KM_USER0);
-	if (copied != bytes) {
-		kaddr = kmap(page);
-		copied = __filemap_copy_from_user_iovec_inatomic(kaddr + offset, iov,
-								 base, bytes);
-		if (bytes - copied)
-			memset(kaddr + offset + copied, 0, bytes - copied);
-		kunmap(page);
+	kaddr = kmap(page);
+	if (likely(nr_segs == 1)) {
+		int left;
+		char __user *buf = iov->iov_base + base;
+		left = __copy_from_user_nocache(kaddr + offset, buf, bytes);
+		copied = bytes - left;
+	} else {
+		copied = __filemap_copy_from_user_iovec_inatomic(kaddr + offset,
+							iov, base, bytes);
 	}
+	kunmap(page);
 	return copied;
 }
 
 static inline void
-filemap_set_next_iovec(const struct iovec **iovp, size_t *basep, size_t bytes)
+filemap_set_next_iovec(const struct iovec **iovp, unsigned long nr_segs,
+						 size_t *basep, size_t bytes)
 {
-	const struct iovec *iov = *iovp;
-	size_t base = *basep;
-
-	while (bytes) {
-		int copy = min(bytes, iov->iov_len - base);
-
-		bytes -= copy;
-		base += copy;
-		if (iov->iov_len == base) {
-			iov++;
-			base = 0;
+	if (likely(nr_segs == 1)) {
+		*basep += bytes;
+	} else {
+		const struct iovec *iov = *iovp;
+		size_t base = *basep;
+
+		while (bytes) {
+			int copy = min(bytes, iov->iov_len - base);
+
+			bytes -= copy;
+			base += copy;
+			if (iov->iov_len == base) {
+				iov++;
+				base = 0;
+			}
 		}
+		*iovp = iov;
+		*basep = base;
 	}
-	*iovp = iov;
-	*basep = base;
 }
 #endif
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1886,12 +1886,7 @@ generic_file_buffered_write(struct kiocb
 	/*
 	 * handle partial DIO write.  Adjust cur_iov if needed.
 	 */
-	if (likely(nr_segs == 1))
-		buf = iov->iov_base + written;
-	else {
-		filemap_set_next_iovec(&cur_iov, &iov_offset, written);
-		buf = cur_iov->iov_base + iov_offset;
-	}
+	filemap_set_next_iovec(&cur_iov, nr_segs, &iov_offset, written);
 
 	do {
 		struct page *page;
@@ -1901,6 +1896,7 @@ generic_file_buffered_write(struct kiocb
 		size_t bytes;		/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */
 
+		buf = cur_iov->iov_base + iov_offset;
 		offset = (pos & (PAGE_CACHE_SIZE - 1));
 		index = pos >> PAGE_CACHE_SHIFT;
 		bytes = PAGE_CACHE_SIZE - offset;
@@ -1932,13 +1928,10 @@ generic_file_buffered_write(struct kiocb
 		if (unlikely(status))
 			goto fs_write_aop_error;
 
-		if (likely(nr_segs == 1))
-			copied = filemap_copy_from_user(page, offset,
-							buf, bytes);
-		else
-			copied = filemap_copy_from_user_iovec(page, offset,
-						cur_iov, iov_offset, bytes);
+		copied = filemap_copy_from_user(page, offset,
+					cur_iov, nr_segs, iov_offset, bytes);
 		flush_dcache_page(page);
+
 		status = a_ops->commit_write(file, page, offset, offset+bytes);
 		if (unlikely(status < 0 || status == AOP_TRUNCATED_PAGE))
 			goto fs_write_aop_error;
@@ -1949,20 +1942,11 @@ generic_file_buffered_write(struct kiocb
 		if (unlikely(status > 0)) /* filesystem did partial write */
 			copied = status;
 
-		if (likely(copied > 0)) {
-			written += copied;
-			count -= copied;
-			pos += copied;
-			buf += copied;
-			if (unlikely(nr_segs > 1)) {
-				filemap_set_next_iovec(&cur_iov,
-						&iov_offset, copied);
-				if (count)
-					buf = cur_iov->iov_base + iov_offset;
-			} else {
-				iov_offset += copied;
-			}
-		}
+		written += copied;
+		count -= copied;
+		pos += copied;
+		filemap_set_next_iovec(&cur_iov, nr_segs, &iov_offset, copied);
+
 		unlock_page(page);
 		mark_page_accessed(page);
 		page_cache_release(page);
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -14,7 +14,6 @@
 #include <linux/uio.h>
 #include <linux/rmap.h>
 #include <asm/tlbflush.h>
-#include "filemap.h"
 
 /*
  * We do use our own empty page to avoid interference with other users
@@ -318,6 +317,7 @@ __xip_file_write(struct file *filp, cons
 		unsigned long index;
 		unsigned long offset;
 		size_t copied;
+		char *kaddr;
 
 		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
 		index = pos >> PAGE_CACHE_SHIFT;
@@ -325,14 +325,6 @@ __xip_file_write(struct file *filp, cons
 		if (bytes > count)
 			bytes = count;
 
-		/*
-		 * Bring in the user page that we will copy from _first_.
-		 * Otherwise there's a nasty deadlock on copying from the
-		 * same page as we're writing to, without it being marked
-		 * up-to-date.
-		 */
-		fault_in_pages_readable(buf, bytes);
-
 		page = a_ops->get_xip_page(mapping,
 					   index*(PAGE_SIZE/512), 0);
 		if (IS_ERR(page) && (PTR_ERR(page) == -ENODATA)) {
@@ -349,8 +341,13 @@ __xip_file_write(struct file *filp, cons
 			break;
 		}
 
-		copied = filemap_copy_from_user(page, offset, buf, bytes);
+		fault_in_pages_readable(buf, bytes);
+		kaddr = kmap_atomic(page, KM_USER0);
+		copied = bytes -
+			__copy_from_user_inatomic_nocache(kaddr, buf, bytes);
+		kunmap_atomic(kaddr, KM_USER0);
 		flush_dcache_page(page);
+
 		if (likely(copied > 0)) {
 			status = copied;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
