Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB20828FF
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:11 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so5619001pab.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:11 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k84si10104810pfa.56.2016.08.12.11.38.48
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 27/41] truncate: make invalidate_inode_pages2_range() aware about huge pages
Date: Fri, 12 Aug 2016 21:38:10 +0300
Message-Id: <1471027104-115213-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For huge pages we need to unmap whole range covered by the huge page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/truncate.c | 27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 9c339e6255f2..6a445278aaaf 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -708,27 +708,34 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 				continue;
 			}
 			wait_on_page_writeback(page);
+			page = compound_head(page);
+
 			if (page_mapped(page)) {
+				loff_t begin, len;
+
+				begin = page->index << PAGE_SHIFT;
+
 				if (!did_range_unmap) {
 					/*
 					 * Zap the rest of the file in one hit.
 					 */
+					len = (loff_t)(1 + end - page->index) <<
+						PAGE_SHIFT;
+					if (len < hpage_size(page))
+						len = hpage_size(page);
 					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_SHIFT,
-					   (loff_t)(1 + end - index)
-							 << PAGE_SHIFT,
-							 0);
+							begin, len, 0);
 					did_range_unmap = 1;
 				} else {
 					/*
 					 * Just zap this page
 					 */
-					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_SHIFT,
-					   PAGE_SIZE, 0);
+					len = hpage_size(page);
+					unmap_mapping_range(mapping, begin,
+							len, 0 );
 				}
 			}
-			BUG_ON(page_mapped(page));
+			VM_BUG_ON_PAGE(page_mapped(page), page);
 			ret2 = do_launder_page(mapping, page);
 			if (ret2 == 0) {
 				if (!invalidate_complete_page2(mapping, page))
@@ -737,6 +744,10 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			if (ret2 < 0)
 				ret = ret2;
 			unlock_page(page);
+			if (PageTransHuge(page)) {
+				index = page->index + HPAGE_PMD_NR - 1;
+				break;
+			}
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
