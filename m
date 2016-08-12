Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5F14828F3
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:45:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so6451089pfg.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:45:06 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sj4si10055422pab.213.2016.08.12.11.39.00
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 20/41] mm: make write_cache_pages() work on huge pages
Date: Fri, 12 Aug 2016 21:38:03 +0300
Message-Id: <1471027104-115213-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We writeback whole huge page a time. Let's adjust iteration this way.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h      |  1 +
 include/linux/pagemap.h |  1 +
 mm/page-writeback.c     | 17 ++++++++++++-----
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08ed53eeedd5..b68d77912313 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1054,6 +1054,7 @@ struct address_space *page_file_mapping(struct page *page)
  */
 static inline pgoff_t page_index(struct page *page)
 {
+	page = compound_head(page);
 	if (unlikely(PageSwapCache(page)))
 		return page_private(page);
 	return page->index;
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index d9cf4e0f35dc..24e14ef1cfe5 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -518,6 +518,7 @@ static inline void wait_on_page_locked(struct page *page)
  */
 static inline void wait_on_page_writeback(struct page *page)
 {
+	page = compound_head(page);
 	if (PageWriteback(page))
 		wait_on_page_bit(page, PG_writeback);
 }
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f4cd7d8005c9..6390c9488e29 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2242,7 +2242,7 @@ retry:
 			 * mapping. However, page->index will not change
 			 * because we have a reference on the page.
 			 */
-			if (page->index > end) {
+			if (page_to_pgoff(page) > end) {
 				/*
 				 * can't be range_cyclic (1st pass) because
 				 * end == -1 in that case.
@@ -2251,7 +2251,12 @@ retry:
 				break;
 			}
 
-			done_index = page->index;
+			done_index = page_to_pgoff(page);
+			if (PageTransCompound(page)) {
+				index = round_up(index + 1, HPAGE_PMD_NR);
+				i += HPAGE_PMD_NR -
+					done_index % HPAGE_PMD_NR - 1;
+			}
 
 			lock_page(page);
 
@@ -2263,7 +2268,7 @@ retry:
 			 * even if there is now a new, dirty page at the same
 			 * pagecache address.
 			 */
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_mapping(page) != mapping)) {
 continue_unlock:
 				unlock_page(page);
 				continue;
@@ -2301,7 +2306,8 @@ continue_unlock:
 					 * not be suitable for data integrity
 					 * writeout).
 					 */
-					done_index = page->index + 1;
+					done_index = compound_head(page)->index
+						+ hpage_nr_pages(page);
 					done = 1;
 					break;
 				}
@@ -2313,7 +2319,8 @@ continue_unlock:
 			 * keep going until we have written all the pages
 			 * we tagged for writeback prior to entering this loop.
 			 */
-			if (--wbc->nr_to_write <= 0 &&
+			wbc->nr_to_write -= hpage_nr_pages(page);
+			if (wbc->nr_to_write <= 0 &&
 			    wbc->sync_mode == WB_SYNC_NONE) {
 				done = 1;
 				break;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
