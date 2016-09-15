Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3339F28025A
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id wk8so83645564pab.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:58 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y187si3556097pfy.250.2016.09.15.04.55.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 36/41] ext4: handle writeback with huge pages
Date: Thu, 15 Sep 2016 14:55:18 +0300
Message-Id: <20160915115523.29737-37-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Modify mpage_map_and_submit_buffers() and mpage_release_unused_pages()
to deal with huge pages.

Mostly result of try-and-error. Critical view would be appriciated.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 61 ++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 43 insertions(+), 18 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 6a8da1a8409c..f2e34e340e65 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1652,18 +1652,30 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 		if (nr_pages == 0)
 			break;
 		for (i = 0; i < nr_pages; i++) {
-			struct page *page = pvec.pages[i];
+			struct page *page = compound_head(pvec.pages[i]);
+
 			if (page->index > end)
 				break;
 			BUG_ON(!PageLocked(page));
 			BUG_ON(PageWriteback(page));
 			if (invalidate) {
-				block_invalidatepage(page, 0, PAGE_SIZE);
+				unsigned long offset, len;
+
+				offset = (index % hpage_nr_pages(page));
+				len = min_t(unsigned long, end - page->index,
+						hpage_nr_pages(page));
+
+				block_invalidatepage(page, offset << PAGE_SHIFT,
+						len << PAGE_SHIFT);
 				ClearPageUptodate(page);
 			}
 			unlock_page(page);
+			if (PageTransHuge(page))
+				break;
 		}
-		index = pvec.pages[nr_pages - 1]->index + 1;
+		index = page_to_pgoff(pvec.pages[nr_pages - 1]) + 1;
+		if (PageTransCompound(pvec.pages[nr_pages - 1]))
+			index = round_up(index, HPAGE_PMD_NR);
 		pagevec_release(&pvec);
 	}
 }
@@ -2097,16 +2109,16 @@ static int mpage_submit_page(struct mpage_da_data *mpd, struct page *page)
 	loff_t size = i_size_read(mpd->inode);
 	int err;
 
-	BUG_ON(page->index != mpd->first_page);
-	if (page->index == size >> PAGE_SHIFT)
-		len = size & ~PAGE_MASK;
-	else
-		len = PAGE_SIZE;
+	page = compound_head(page);
+	len = hpage_size(page);
+	if (page->index + hpage_nr_pages(page) - 1 == size >> PAGE_SHIFT)
+		len = size & ~hpage_mask(page);
+
 	clear_page_dirty_for_io(page);
 	err = ext4_bio_write_page(&mpd->io_submit, page, len, mpd->wbc, false);
 	if (!err)
-		mpd->wbc->nr_to_write--;
-	mpd->first_page++;
+		mpd->wbc->nr_to_write -= hpage_nr_pages(page);
+	mpd->first_page = round_up(mpd->first_page + 1, hpage_nr_pages(page));
 
 	return err;
 }
@@ -2254,12 +2266,16 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 			break;
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
+			unsigned long diff;
 
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				break;
 			/* Up to 'end' pages must be contiguous */
-			BUG_ON(page->index != start);
+			BUG_ON(page_to_pgoff(page) != start);
+			diff = (page - compound_head(page)) << bpp_bits;
 			bh = head = page_buffers(page);
+			while (diff--)
+				bh = bh->b_this_page;
 			do {
 				if (lblk < mpd->map.m_lblk)
 					continue;
@@ -2296,7 +2312,10 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 			 * supports blocksize < pagesize as we will try to
 			 * convert potentially unmapped parts of inode.
 			 */
-			mpd->io_submit.io_end->size += PAGE_SIZE;
+			if (PageTransCompound(page))
+				mpd->io_submit.io_end->size += HPAGE_PMD_SIZE;
+			else
+				mpd->io_submit.io_end->size += PAGE_SIZE;
 			/* Page fully mapped - let IO run! */
 			err = mpage_submit_page(mpd, page);
 			if (err < 0) {
@@ -2304,6 +2323,10 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 				return err;
 			}
 			start++;
+			if (PageTransCompound(page)) {
+				start = round_up(start, HPAGE_PMD_NR);
+				break;
+			}
 		}
 		pagevec_release(&pvec);
 	}
@@ -2543,7 +2566,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			 * mapping. However, page->index will not change
 			 * because we have a reference on the page.
 			 */
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				goto out;
 
 			/*
@@ -2558,7 +2581,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 				goto out;
 
 			/* If we can't merge this page, we are done. */
-			if (mpd->map.m_len > 0 && mpd->next_page != page->index)
+			if (mpd->map.m_len > 0 && mpd->next_page != page_to_pgoff(page))
 				goto out;
 
 			lock_page(page);
@@ -2572,7 +2595,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			if (!PageDirty(page) ||
 			    (PageWriteback(page) &&
 			     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
-			    unlikely(page->mapping != mapping)) {
+			    unlikely(page_mapping(page) != mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -2581,8 +2604,10 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			BUG_ON(PageWriteback(page));
 
 			if (mpd->map.m_len == 0)
-				mpd->first_page = page->index;
-			mpd->next_page = page->index + 1;
+				mpd->first_page = page_to_pgoff(page);
+			page = compound_head(page);
+			mpd->next_page = round_up(page->index + 1,
+					hpage_nr_pages(page));
 			/* Add all dirty buffers to mpd */
 			lblk = ((ext4_lblk_t)page->index) <<
 				(PAGE_SHIFT - blkbits);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
