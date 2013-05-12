Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E07646B0068
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:39 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 20/39] thp, mm: naive support of thp in generic read/write routines
Date: Sun, 12 May 2013 04:23:17 +0300
Message-Id: <1368321816-17719-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now we still write/read at most PAGE_CACHE_SIZE bytes a time.

This implementation doesn't cover address spaces with backing store.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index e086ef0..ebd361a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1177,6 +1177,17 @@ find_page:
 			if (unlikely(page == NULL))
 				goto no_cached_page;
 		}
+		if (PageTransCompound(page)) {
+			struct page *head = compound_trans_head(page);
+			/*
+			 * We don't yet support huge pages in page cache
+			 * for filesystems with backing device, so pages
+			 * should always be up-to-date.
+			 */
+			BUG_ON(ra->ra_pages);
+			BUG_ON(!PageUptodate(head));
+			goto page_ok;
+		}
 		if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
@@ -2413,8 +2424,13 @@ again:
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
 
@@ -2437,6 +2453,7 @@ again:
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
