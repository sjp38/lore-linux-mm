Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC446B0273
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so308738077pgf.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:46 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j9si1196448pfc.290.2017.01.26.03.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:45 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 13/37] mm: make write_cache_pages() work on huge pages
Date: Thu, 26 Jan 2017 14:57:55 +0300
Message-Id: <20170126115819.58875-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
index b84615b0f64c..9e87155af456 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1045,6 +1045,7 @@ extern pgoff_t __page_file_index(struct page *page);
  */
 static inline pgoff_t page_index(struct page *page)
 {
+	page = compound_head(page);
 	if (unlikely(PageSwapCache(page)))
 		return __page_file_index(page);
 	return page->index;
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9a93b9c3d662..e3eb6dc03286 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -545,6 +545,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
  */
 static inline void wait_on_page_writeback(struct page *page)
 {
+	page = compound_head(page);
 	if (PageWriteback(page))
 		wait_on_page_bit(page, PG_writeback);
 }
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 290e8b7d3181..47d5b12c460e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2209,7 +2209,7 @@ int write_cache_pages(struct address_space *mapping,
 			 * mapping. However, page->index will not change
 			 * because we have a reference on the page.
 			 */
-			if (page->index > end) {
+			if (page_to_pgoff(page) > end) {
 				/*
 				 * can't be range_cyclic (1st pass) because
 				 * end == -1 in that case.
@@ -2218,7 +2218,12 @@ int write_cache_pages(struct address_space *mapping,
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
 
@@ -2230,7 +2235,7 @@ int write_cache_pages(struct address_space *mapping,
 			 * even if there is now a new, dirty page at the same
 			 * pagecache address.
 			 */
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_mapping(page) != mapping)) {
 continue_unlock:
 				unlock_page(page);
 				continue;
@@ -2268,7 +2273,8 @@ int write_cache_pages(struct address_space *mapping,
 					 * not be suitable for data integrity
 					 * writeout).
 					 */
-					done_index = page->index + 1;
+					done_index = compound_head(page)->index
+						+ hpage_nr_pages(page);
 					done = 1;
 					break;
 				}
@@ -2280,7 +2286,8 @@ int write_cache_pages(struct address_space *mapping,
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
