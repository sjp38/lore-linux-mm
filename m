Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A91F26B0279
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:48 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so308739429pgf.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:48 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u5si26287445pgi.223.2017.01.26.03.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 20/37] truncate: make truncate_inode_pages_range() aware about huge pages
Date: Thu, 26 Jan 2017 14:58:02 +0300
Message-Id: <20170126115819.58875-21-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
 fs/buffer.c        |  2 +-
 include/linux/mm.h |  9 +++++-
 mm/truncate.c      | 86 ++++++++++++++++++++++++++++++++++++++++++++----------
 3 files changed, 80 insertions(+), 17 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 17167b299d0f..f92090fed933 100644
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9e87155af456..41a97260f865 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1328,8 +1328,15 @@ int get_kernel_page(unsigned long start, int write, struct page **pages);
 struct page *get_dump_page(unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
-extern void do_invalidatepage(struct page *page, unsigned int offset,
+extern void __do_invalidatepage(struct page *page, unsigned int offset,
 			      unsigned int length);
+static inline void do_invalidatepage(struct page *page, unsigned int offset,
+		unsigned int length)
+{
+	if (page_has_private(page))
+		__do_invalidatepage(page, offset, length);
+}
+
 
 int __set_page_dirty_nobuffers(struct page *page);
 int __set_page_dirty_no_writeback(struct page *page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 3a1a1c1a654e..81e1a13acb63 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -112,12 +112,12 @@ static int invalidate_exceptional_entry2(struct address_space *mapping,
  * point.  Because the caller is about to free (and possibly reuse) those
  * blocks on-disk.
  */
-void do_invalidatepage(struct page *page, unsigned int offset,
+void __do_invalidatepage(struct page *page, unsigned int offset,
 		       unsigned int length)
 {
 	void (*invalidatepage)(struct page *, unsigned int, unsigned int);
 
-	invalidatepage = page->mapping->a_ops->invalidatepage;
+	invalidatepage = page_mapping(page)->a_ops->invalidatepage;
 #ifdef CONFIG_BLOCK
 	if (!invalidatepage)
 		invalidatepage = block_invalidatepage;
@@ -142,8 +142,7 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	if (page->mapping != mapping)
 		return -EIO;
 
-	if (page_has_private(page))
-		do_invalidatepage(page, 0, PAGE_SIZE);
+	do_invalidatepage(page, 0, hpage_size(page));
 
 	/*
 	 * Some filesystems seem to re-dirty the page even after
@@ -316,13 +315,35 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				unlock_page(page);
 				continue;
 			}
+
+			if (PageTransHuge(page)) {
+				int j, first = 0, last = HPAGE_PMD_NR - 1;
+
+				if (start > page->index)
+					first = start & (HPAGE_PMD_NR - 1);
+				if (index == round_down(end, HPAGE_PMD_NR))
+					last = (end - 1) & (HPAGE_PMD_NR - 1);
+
+				/* Range starts or ends in the middle of THP */
+				if (first != 0 || last != HPAGE_PMD_NR - 1) {
+					int off, len;
+					for (j = first; j <= last; j++)
+						clear_highpage(page + j);
+					off = first * PAGE_SIZE;
+					len = (last + 1) * PAGE_SIZE - off;
+					do_invalidatepage(page, off, len);
+					unlock_page(page);
+					continue;
+				}
+			}
+
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
 		pagevec_remove_exceptionals(&pvec);
+		index += pvec.nr ? hpage_nr_pages(pvec.pages[pvec.nr - 1]) : 1;
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 
 	if (partial_start) {
@@ -337,9 +358,12 @@ void truncate_inode_pages_range(struct address_space *mapping,
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
@@ -350,9 +374,12 @@ void truncate_inode_pages_range(struct address_space *mapping,
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
@@ -366,7 +393,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 	index = start;
 	for ( ; ; ) {
-		cond_resched();
+restart:	cond_resched();
 		if (!pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
 			/* If all gone from start onwards, we're done */
@@ -389,8 +416,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			index = indices[i];
 			if (index >= end) {
 				/* Restart punch to make sure all gone */
-				index = start - 1;
-				break;
+				index = start;
+				goto restart;
 			}
 
 			if (radix_tree_exceptional_entry(page)) {
@@ -402,12 +429,41 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			lock_page(page);
 			WARN_ON(page_to_index(page) != index);
 			wait_on_page_writeback(page);
+
+			if (PageTransHuge(page)) {
+				int j, first = 0, last = HPAGE_PMD_NR - 1;
+
+				if (start > page->index)
+					first = start & (HPAGE_PMD_NR - 1);
+				if (index == round_down(end, HPAGE_PMD_NR))
+					last = (end - 1) & (HPAGE_PMD_NR - 1);
+
+				/*
+				 * On Partial thp truncate due 'start' in
+				 * middle of THP: don't need to look on these
+				 * pages again on !pvec.nr restart.
+				 */
+				start = page->index + HPAGE_PMD_NR;
+
+				/* Range starts or ends in the middle of THP */
+				if (first != 0 || last != HPAGE_PMD_NR - 1) {
+					int off, len;
+					for (j = first; j <= last; j++)
+						clear_highpage(page + j);
+					off = first * PAGE_SIZE;
+					len = (last + 1) * PAGE_SIZE - off;
+					do_invalidatepage(page, off, len);
+					unlock_page(page);
+					continue;
+				}
+			}
+
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
 		pagevec_remove_exceptionals(&pvec);
+		index += pvec.nr ? hpage_nr_pages(pvec.pages[pvec.nr - 1]) : 1;
 		pagevec_release(&pvec);
-		index++;
 	}
 	cleancache_invalidate_inode(mapping);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
