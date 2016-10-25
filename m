Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 517666B026A
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:20 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ra7so45251pab.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:20 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p187si17912762pfg.145.2016.10.24.17.14.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 20/43] mm: make write_cache_pages() work on huge pages
Date: Tue, 25 Oct 2016 03:13:19 +0300
Message-Id: <20161025001342.76126-21-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index 3a191853faaa..315df8051d06 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1056,6 +1056,7 @@ extern pgoff_t __page_file_index(struct page *page);
  */
 static inline pgoff_t page_index(struct page *page)
 {
+	page = compound_head(page);
 	if (unlikely(PageSwapCache(page)))
 		return __page_file_index(page);
 	return page->index;
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 712343108d31..f9aa8bede15e 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -528,6 +528,7 @@ static inline void wait_on_page_locked(struct page *page)
  */
 static inline void wait_on_page_writeback(struct page *page)
 {
+	page = compound_head(page);
 	if (PageWriteback(page))
 		wait_on_page_bit(page, PG_writeback);
 }
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 439cc63ad903..c76fc90b7039 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2200,7 +2200,7 @@ int write_cache_pages(struct address_space *mapping,
 			 * mapping. However, page->index will not change
 			 * because we have a reference on the page.
 			 */
-			if (page->index > end) {
+			if (page_to_pgoff(page) > end) {
 				/*
 				 * can't be range_cyclic (1st pass) because
 				 * end == -1 in that case.
@@ -2209,7 +2209,12 @@ int write_cache_pages(struct address_space *mapping,
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
 
@@ -2221,7 +2226,7 @@ int write_cache_pages(struct address_space *mapping,
 			 * even if there is now a new, dirty page at the same
 			 * pagecache address.
 			 */
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_mapping(page) != mapping)) {
 continue_unlock:
 				unlock_page(page);
 				continue;
@@ -2259,7 +2264,8 @@ int write_cache_pages(struct address_space *mapping,
 					 * not be suitable for data integrity
 					 * writeout).
 					 */
-					done_index = page->index + 1;
+					done_index = compound_head(page)->index
+						+ hpage_nr_pages(page);
 					done = 1;
 					break;
 				}
@@ -2271,7 +2277,8 @@ int write_cache_pages(struct address_space *mapping,
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
