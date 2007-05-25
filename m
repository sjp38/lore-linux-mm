Message-Id: <20070524053154.602580000@linux.local0.net>
References: <20070524052844.860329000@suse.de>
Date: Fri, 25 May 2007 22:21:53 +1000
From: npiggin@suse.de
Subject: [patch 09/41] mm: fix pagecache write deadlocks
Content-Disposition: inline; filename=mm-pagecache-write-deadlocks.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Modify the core write() code so that it won't take a pagefault while holding a
lock on the pagecache page. There are a number of different deadlocks possible
if we try to do such a thing:

1.  generic_buffered_write
2.   lock_page
3.    prepare_write
4.     unlock_page+vmtruncate
5.     copy_from_user
6.      mmap_sem(r)
7.       handle_mm_fault
8.        lock_page (filemap_nopage)
9.    commit_write
10.  unlock_page

a. sys_munmap / sys_mlock / others
b.  mmap_sem(w)
c.   make_pages_present
d.    get_user_pages
e.     handle_mm_fault
f.      lock_page (filemap_nopage)

2,8	- recursive deadlock if page is same
2,8;2,8	- ABBA deadlock is page is different
2,6;b,f	- ABBA deadlock if page is same

The solution is as follows:
1.  If we find the destination page is uptodate, continue as normal, but use
    atomic usercopies which do not take pagefaults and do not zero the uncopied
    tail of the destination. The destination is already uptodate, so we can
    commit_write the full length even if there was a partial copy: it does not
    matter that the tail was not modified, because if it is dirtied and written
    back to disk it will not cause any problems (uptodate *means* that the
    destination page is as new or newer than the copy on disk).

1a. The above requires that fault_in_pages_readable correctly returns access
    information, because atomic usercopies cannot distinguish between
    non-present pages in a readable mapping, from lack of a readable mapping.

2.  If we find the destination page is non uptodate, unlock it (this could be
    made slightly more optimal), then allocate a temporary page to copy the
    source data into. Relock the destination page and continue with the copy.
    However, instead of a usercopy (which might take a fault), copy the data
    from the pinned temporary page via the kernel address space.

(also, rename maxlen to seglen, because it was confusing)

This increases the CPU/memory copy cost by almost 50% on the affected
workloads. That will be solved by introducing a new set of pagecache write
aops in a subsequent patch.

Cc: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>

 include/linux/pagemap.h |   11 +++-
 mm/filemap.c            |  122 ++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 112 insertions(+), 21 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1900,11 +1900,12 @@ generic_file_buffered_write(struct kiocb
 	filemap_set_next_iovec(&cur_iov, nr_segs, &iov_offset, written);
 
 	do {
+		struct page *src_page;
 		struct page *page;
 		pgoff_t index;		/* Pagecache index for current page */
 		unsigned long offset;	/* Offset into pagecache page */
-		unsigned long maxlen;	/* Bytes remaining in current iovec */
-		size_t bytes;		/* Bytes to write to page */
+		unsigned long seglen;	/* Bytes remaining in current iovec */
+		unsigned long bytes;	/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */
 
 		buf = cur_iov->iov_base + iov_offset;
@@ -1914,20 +1915,30 @@ generic_file_buffered_write(struct kiocb
 		if (bytes > count)
 			bytes = count;
 
-		maxlen = cur_iov->iov_len - iov_offset;
-		if (maxlen > bytes)
-			maxlen = bytes;
+		/*
+		 * a non-NULL src_page indicates that we're doing the
+		 * copy via get_user_pages and kmap.
+		 */
+		src_page = NULL;
+
+		seglen = cur_iov->iov_len - iov_offset;
+		if (seglen > bytes)
+			seglen = bytes;
 
-#ifndef CONFIG_DEBUG_VM
 		/*
 		 * Bring in the user page that we will copy from _first_.
 		 * Otherwise there's a nasty deadlock on copying from the
 		 * same page as we're writing to, without it being marked
 		 * up-to-date.
+		 *
+		 * Not only is this an optimisation, but it is also required
+		 * to check that the address is actually valid, when atomic
+		 * usercopies are used, below.
 		 */
-		fault_in_pages_readable(buf, maxlen);
-#endif
-
+		if (unlikely(fault_in_pages_readable(buf, seglen))) {
+			status = -EFAULT;
+			break;
+		}
 
 		page = __grab_cache_page(mapping, index);
 		if (!page) {
@@ -1935,32 +1946,104 @@ generic_file_buffered_write(struct kiocb
 			break;
 		}
 
+		/*
+		 * non-uptodate pages cannot cope with short copies, and we
+		 * cannot take a pagefault with the destination page locked.
+		 * So pin the source page to copy it.
+		 */
+		if (!PageUptodate(page)) {
+			unlock_page(page);
+
+			src_page = alloc_page(GFP_KERNEL);
+			if (!src_page) {
+				page_cache_release(page);
+				status = -ENOMEM;
+				break;
+			}
+
+			/*
+			 * Cannot get_user_pages with a page locked for the
+			 * same reason as we can't take a page fault with a
+			 * page locked (as explained below).
+			 */
+			copied = filemap_copy_from_user(src_page, offset,
+					cur_iov, nr_segs, iov_offset, bytes);
+			if (unlikely(copied == 0)) {
+				status = -EFAULT;
+				page_cache_release(page);
+				page_cache_release(src_page);
+				break;
+			}
+			bytes = copied;
+
+			lock_page(page);
+			/*
+			 * Can't handle the page going uptodate here, because
+			 * that means we would use non-atomic usercopies, which
+			 * zero out the tail of the page, which can cause
+			 * zeroes to become transiently visible. We could just
+			 * use a non-zeroing copy, but the APIs aren't too
+			 * consistent.
+			 */
+			if (unlikely(!page->mapping || PageUptodate(page))) {
+				unlock_page(page);
+				page_cache_release(page);
+				page_cache_release(src_page);
+				continue;
+			}
+
+		}
+
 		status = a_ops->prepare_write(file, page, offset, offset+bytes);
 		if (unlikely(status))
 			goto fs_write_aop_error;
 
-		copied = filemap_copy_from_user(page, offset,
+		if (!src_page) {
+			/*
+			 * Must not enter the pagefault handler here, because
+			 * we hold the page lock, so we might recursively
+			 * deadlock on the same lock, or get an ABBA deadlock
+			 * against a different lock, or against the mmap_sem
+			 * (which nests outside the page lock).  So increment
+			 * preempt count, and use _atomic usercopies.
+			 *
+			 * The page is uptodate so we are OK to encounter a
+			 * short copy: if unmodified parts of the page are
+			 * marked dirty and written out to disk, it doesn't
+			 * really matter.
+			 */
+			pagefault_disable();
+			copied = filemap_copy_from_user_atomic(page, offset,
 					cur_iov, nr_segs, iov_offset, bytes);
+			pagefault_enable();
+		} else {
+			void *src, *dst;
+			src = kmap_atomic(src_page, KM_USER0);
+			dst = kmap_atomic(page, KM_USER1);
+			memcpy(dst + offset, src + offset, bytes);
+			kunmap_atomic(dst, KM_USER1);
+			kunmap_atomic(src, KM_USER0);
+			copied = bytes;
+		}
 		flush_dcache_page(page);
 
 		status = a_ops->commit_write(file, page, offset, offset+bytes);
 		if (unlikely(status < 0 || status == AOP_TRUNCATED_PAGE))
 			goto fs_write_aop_error;
-		if (unlikely(copied != bytes)) {
-			status = -EFAULT;
-			goto fs_write_aop_error;
-		}
 		if (unlikely(status > 0)) /* filesystem did partial write */
-			copied = status;
+			copied = min_t(size_t, copied, status);
+
+		unlock_page(page);
+		mark_page_accessed(page);
+		page_cache_release(page);
+		if (src_page)
+			page_cache_release(src_page);
 
 		written += copied;
 		count -= copied;
 		pos += copied;
 		filemap_set_next_iovec(&cur_iov, nr_segs, &iov_offset, copied);
 
-		unlock_page(page);
-		mark_page_accessed(page);
-		page_cache_release(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 		continue;
@@ -1969,6 +2052,8 @@ fs_write_aop_error:
 		if (status != AOP_TRUNCATED_PAGE)
 			unlock_page(page);
 		page_cache_release(page);
+		if (src_page)
+			page_cache_release(src_page);
 
 		/*
 		 * prepare_write() may have instantiated a few blocks
@@ -1981,7 +2066,6 @@ fs_write_aop_error:
 			continue;
 		else
 			break;
-
 	} while (count);
 	*ppos = pos;
 
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -218,6 +218,9 @@ static inline int fault_in_pages_writeab
 {
 	int ret;
 
+	if (unlikely(size == 0))
+		return 0;
+
 	/*
 	 * Writing zeroes into userspace here is OK, because we know that if
 	 * the zero gets there, we'll be overwriting it.
@@ -237,19 +240,23 @@ static inline int fault_in_pages_writeab
 	return ret;
 }
 
-static inline void fault_in_pages_readable(const char __user *uaddr, int size)
+static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 {
 	volatile char c;
 	int ret;
 
+	if (unlikely(size == 0))
+		return 0;
+
 	ret = __get_user(c, uaddr);
 	if (ret == 0) {
 		const char __user *end = uaddr + size - 1;
 
 		if (((unsigned long)uaddr & PAGE_MASK) !=
 				((unsigned long)end & PAGE_MASK))
-		 	__get_user(c, end);
+		 	ret = __get_user(c, end);
 	}
+	return ret;
 }
 
 #endif /* _LINUX_PAGEMAP_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
