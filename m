Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id BBED36B0026
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:23:39 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 11/16] thp, mm: naive support of thp in generic read/write routines
Date: Mon, 28 Jan 2013 11:24:23 +0200
Message-Id: <1359365068-10147-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now we still write/read at most PAGE_CACHE_SIZE bytes a time.

This implementation doesn't cover address spaces with backing store.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   35 ++++++++++++++++++++++++++++++-----
 1 file changed, 30 insertions(+), 5 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 68e47e4..a7331fb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1161,12 +1161,23 @@ find_page:
 			if (unlikely(page == NULL))
 				goto no_cached_page;
 		}
+		if (PageTransTail(page)) {
+			page_cache_release(page);
+			page = find_get_page(mapping,
+					index & ~HPAGE_CACHE_INDEX_MASK);
+			if (!PageTransHuge(page)) {
+				page_cache_release(page);
+				goto find_page;
+			}
+		}
 		if (PageReadahead(page)) {
+			BUG_ON(PageTransHuge(page));
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
 					index, last_index - index);
 		}
 		if (!PageUptodate(page)) {
+			BUG_ON(PageTransHuge(page));
 			if (inode->i_blkbits == PAGE_CACHE_SHIFT ||
 					!mapping->a_ops->is_partially_uptodate)
 				goto page_not_up_to_date;
@@ -1208,18 +1219,25 @@ page_ok:
 		}
 		nr = nr - offset;
 
+		/* Recalculate offset in page if we've got a huge page */
+		if (PageTransHuge(page)) {
+			offset = (((loff_t)index << PAGE_CACHE_SHIFT) + offset);
+			offset &= ~HPAGE_PMD_MASK;
+		}
+
 		/* If users can be writing to this page using arbitrary
 		 * virtual addresses, take care about potential aliasing
 		 * before reading the page on the kernel side.
 		 */
 		if (mapping_writably_mapped(mapping))
-			flush_dcache_page(page);
+			flush_dcache_page(page + (offset >> PAGE_CACHE_SHIFT));
 
 		/*
 		 * When a sequential read accesses a page several times,
 		 * only mark it as accessed the first time.
 		 */
-		if (prev_index != index || offset != prev_offset)
+		if (prev_index != index ||
+				(offset & ~PAGE_CACHE_MASK) != prev_offset)
 			mark_page_accessed(page);
 		prev_index = index;
 
@@ -1234,8 +1252,9 @@ page_ok:
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = file_read_actor(desc, page, offset, nr);
-		offset += ret;
+		ret = file_read_actor(desc, page + (offset >> PAGE_CACHE_SHIFT),
+				offset & ~PAGE_CACHE_MASK, nr);
+		offset =  (offset & ~PAGE_CACHE_MASK) + ret;
 		index += offset >> PAGE_CACHE_SHIFT;
 		offset &= ~PAGE_CACHE_MASK;
 		prev_offset = offset;
@@ -2433,8 +2452,13 @@ again:
 		if (mapping_writably_mapped(mapping))
 			flush_dcache_page(page);
 
+		if (PageTransHuge(page))
+			offset = pos & ~HPAGE_PMD_MASK;
+
 		pagefault_disable();
-		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
+		copied = iov_iter_copy_from_user_atomic(
+				page + (offset >> PAGE_CACHE_SHIFT),
+				i, offset & ~PAGE_CACHE_MASK, bytes);
 		pagefault_enable();
 		flush_dcache_page(page);
 
@@ -2457,6 +2481,7 @@ again:
 			 * because not all segments in the iov can be copied at
 			 * once without a pagefault.
 			 */
+			offset = pos & ~PAGE_CACHE_MASK;
 			bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
 						iov_iter_single_seg_count(i));
 			goto again;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
