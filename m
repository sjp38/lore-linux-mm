Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 560266B004D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:17 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 14/30] thp, mm: naive support of thp in generic read/write routines
Date: Thu, 14 Mar 2013 19:50:19 +0200
Message-Id: <1363283435-7666-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now we still write/read at most PAGE_CACHE_SIZE bytes a time.

This implementation doesn't cover address spaces with backing store.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   35 ++++++++++++++++++++++++++++++-----
 1 file changed, 30 insertions(+), 5 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index bdedb1b..79ba9cd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1165,12 +1165,23 @@ find_page:
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
@@ -1212,18 +1223,25 @@ page_ok:
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
 
@@ -1238,8 +1256,9 @@ page_ok:
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
@@ -2440,8 +2459,13 @@ again:
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
 
@@ -2464,6 +2488,7 @@ again:
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
