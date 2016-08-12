Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29E9B828F3
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:47:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so6540271pfg.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:47:19 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sj4si10055422pab.213.2016.08.12.11.39.01
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 26/41] truncate: make truncate_inode_pages_range() aware about huge pages
Date: Fri, 12 Aug 2016 21:38:09 +0300
Message-Id: <1471027104-115213-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As with shmem_undo_range(), truncate_inode_pages_range() removes huge
pages, if it fully within range.

Partial truncate of huge pages zero out this part of THP.

Unlike with shmem, it doesn't prevent us having holes in the middle of
huge page we still can skip writeback not touched buffers.

With memory-mapped IO we would loose holes in some cases when we have
THP in page cache, since we cannot track access on 4k level in this
case.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/buffer.c   |  2 +-
 mm/truncate.c | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 88 insertions(+), 9 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index e53808e790e2..20898b051044 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1534,7 +1534,7 @@ void block_invalidatepage(struct page *page, unsigned int offset,
 	/*
 	 * Check for overflow
 	 */
-	BUG_ON(stop > PAGE_SIZE || stop < length);
+	BUG_ON(stop > hpage_size(page) || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
diff --git a/mm/truncate.c b/mm/truncate.c
index ce904e4b1708..9c339e6255f2 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -90,7 +90,7 @@ void do_invalidatepage(struct page *page, unsigned int offset,
 {
 	void (*invalidatepage)(struct page *, unsigned int, unsigned int);
 
-	invalidatepage = page->mapping->a_ops->invalidatepage;
+	invalidatepage = page_mapping(page)->a_ops->invalidatepage;
 #ifdef CONFIG_BLOCK
 	if (!invalidatepage)
 		invalidatepage = block_invalidatepage;
@@ -116,7 +116,7 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 		return -EIO;
 
 	if (page_has_private(page))
-		do_invalidatepage(page, 0, PAGE_SIZE);
+		do_invalidatepage(page, 0, hpage_size(page));
 
 	/*
 	 * Some filesystems seem to re-dirty the page even after
@@ -288,6 +288,36 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				unlock_page(page);
 				continue;
 			}
+
+			if (PageTransTail(page)) {
+				/* Middle of THP: zero out the page */
+				clear_highpage(page);
+				if (page_has_private(page)) {
+					int off = page - compound_head(page);
+					do_invalidatepage(compound_head(page),
+							off * PAGE_SIZE,
+							PAGE_SIZE);
+				}
+				unlock_page(page);
+				continue;
+			} else if (PageTransHuge(page)) {
+				if (index == round_down(end, HPAGE_PMD_NR)) {
+					/*
+					 * Range ends in the middle of THP:
+					 * zero out the page
+					 */
+					clear_highpage(page);
+					if (page_has_private(page)) {
+						do_invalidatepage(page, 0,
+								PAGE_SIZE);
+					}
+					unlock_page(page);
+					continue;
+				}
+				index += HPAGE_PMD_NR - 1;
+				i += HPAGE_PMD_NR - 1;
+			}
+
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
@@ -309,9 +339,12 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			wait_on_page_writeback(page);
 			zero_user_segment(page, partial_start, top);
 			cleancache_invalidate_page(mapping, page);
-			if (page_has_private(page))
-				do_invalidatepage(page, partial_start,
-						  top - partial_start);
+			if (page_has_private(page)) {
+				int off = page - compound_head(page);
+				do_invalidatepage(compound_head(page),
+						off * PAGE_SIZE + partial_start,
+						top - partial_start);
+			}
 			unlock_page(page);
 			put_page(page);
 		}
@@ -322,9 +355,12 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			wait_on_page_writeback(page);
 			zero_user_segment(page, 0, partial_end);
 			cleancache_invalidate_page(mapping, page);
-			if (page_has_private(page))
-				do_invalidatepage(page, 0,
-						  partial_end);
+			if (page_has_private(page)) {
+				int off = page - compound_head(page);
+				do_invalidatepage(compound_head(page),
+						off * PAGE_SIZE,
+						partial_end);
+			}
 			unlock_page(page);
 			put_page(page);
 		}
@@ -373,6 +409,49 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			lock_page(page);
 			WARN_ON(page_to_pgoff(page) != index);
 			wait_on_page_writeback(page);
+
+			if (PageTransTail(page)) {
+				/* Middle of THP: zero out the page */
+				clear_highpage(page);
+				if (page_has_private(page)) {
+					int off = page - compound_head(page);
+					do_invalidatepage(compound_head(page),
+							off * PAGE_SIZE,
+							PAGE_SIZE);
+				}
+				unlock_page(page);
+				/*
+				 * Partial thp truncate due 'start' in middle
+				 * of THP: don't need to look on these pages
+				 * again on !pvec.nr restart.
+				 */
+				if (index != round_down(end, HPAGE_PMD_NR))
+					start++;
+				continue;
+			} else if (PageTransHuge(page)) {
+				if (index == round_down(end, HPAGE_PMD_NR)) {
+					/*
+					 * Range ends in the middle of THP:
+					 * zero out the page
+					 */
+					clear_highpage(page);
+					if (page_has_private(page)) {
+						do_invalidatepage(page, 0,
+								PAGE_SIZE);
+					}
+					unlock_page(page);
+					/*
+					 * Partial thp truncate due 'end' in
+					 * middle of THP: don't need to look on
+					 * these pages again restart.
+					 */
+					start++;
+					continue;
+				}
+				index += HPAGE_PMD_NR - 1;
+				i += HPAGE_PMD_NR - 1;
+			}
+
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
