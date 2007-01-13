From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070113011255.9449.33228.sendpatchset@linux.site>
In-Reply-To: <20070113011159.9449.4327.sendpatchset@linux.site>
References: <20070113011159.9449.4327.sendpatchset@linux.site>
Subject: [patch 6/10] mm: be sure to trim blocks
Date: Sat, 13 Jan 2007 04:25:11 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

If prepare_write fails with AOP_TRUNCATED_PAGE, or if commit_write fails, then
we may have failed the write operation despite prepare_write having
instantiated blocks past i_size. Fix this, and consolidate the trimming into
one place.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1911,22 +1911,9 @@ generic_file_buffered_write(struct kiocb
 		}
 
 		status = a_ops->prepare_write(file, page, offset, offset+bytes);
-		if (unlikely(status)) {
-			loff_t isize = i_size_read(inode);
+		if (unlikely(status))
+			goto fs_write_aop_error;
 
-			if (status != AOP_TRUNCATED_PAGE)
-				unlock_page(page);
-			page_cache_release(page);
-			if (status == AOP_TRUNCATED_PAGE)
-				continue;
-			/*
-			 * prepare_write() may have instantiated a few blocks
-			 * outside i_size.  Trim these off again.
-			 */
-			if (pos + bytes > isize)
-				vmtruncate(inode, isize);
-			break;
-		}
 		if (likely(nr_segs == 1))
 			copied = filemap_copy_from_user(page, offset,
 							buf, bytes);
@@ -1935,10 +1922,9 @@ generic_file_buffered_write(struct kiocb
 						cur_iov, iov_offset, bytes);
 		flush_dcache_page(page);
 		status = a_ops->commit_write(file, page, offset, offset+bytes);
-		if (status == AOP_TRUNCATED_PAGE) {
-			page_cache_release(page);
-			continue;
-		}
+		if (unlikely(status))
+			goto fs_write_aop_error;
+
 		if (likely(copied > 0)) {
 			if (!status)
 				status = copied;
@@ -1969,6 +1955,25 @@ generic_file_buffered_write(struct kiocb
 			break;
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
+		continue;
+
+fs_write_aop_error:
+		if (status != AOP_TRUNCATED_PAGE)
+			unlock_page(page);
+		page_cache_release(page);
+
+		/*
+		 * prepare_write() may have instantiated a few blocks
+		 * outside i_size.  Trim these off again. Don't need
+		 * i_size_read because we hold i_mutex.
+		 */
+		if (pos + bytes > inode->i_size)
+			vmtruncate(inode, inode->i_size);
+		if (status == AOP_TRUNCATED_PAGE)
+			continue;
+		else
+			break;
+
 	} while (count);
 	*ppos = pos;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
