Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E88436B026F
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so426471020pgx.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:37 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 1si30856571plm.51.2016.11.29.03.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:37 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 21/36] truncate: make invalidate_inode_pages2_range() aware about huge pages
Date: Tue, 29 Nov 2016 14:22:49 +0300
Message-Id: <20161129112304.90056-22-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For huge pages we need to unmap whole range covered by the huge page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/truncate.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index d2d95f283ec3..6df4b06a190f 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -656,27 +656,32 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 				continue;
 			}
 			wait_on_page_writeback(page);
+
 			if (page_mapped(page)) {
+				loff_t begin, len;
+
+				begin = index << PAGE_SHIFT;
 				if (!did_range_unmap) {
 					/*
 					 * Zap the rest of the file in one hit.
 					 */
+					len = (loff_t)(1 + end - index) <<
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
+							len, 0);
 				}
 			}
-			BUG_ON(page_mapped(page));
+			VM_BUG_ON_PAGE(page_mapped(page), page);
 			ret2 = do_launder_page(mapping, page);
 			if (ret2 == 0) {
 				if (!invalidate_complete_page2(mapping, page))
@@ -687,9 +692,9 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			unlock_page(page);
 		}
 		pagevec_remove_exceptionals(&pvec);
+		index += pvec.nr ? hpage_nr_pages(pvec.pages[pvec.nr - 1]) : 1;
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 	cleancache_invalidate_inode(mapping);
 	return ret;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
