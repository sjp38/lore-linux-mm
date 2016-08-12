Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 732CF6B025E
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:44:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so6417773pfg.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:44:11 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.39.02
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 36/41] ext4: handle writeback with huge pages
Date: Fri, 12 Aug 2016 21:38:19 +0300
Message-Id: <1471027104-115213-37-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Modify mpage_map_and_submit_buffers() and mpage_release_unused_pages()
to deal with huge pages.

Mostly result of try-and-error. Critical view would be appriciated.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 60 +++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 43 insertions(+), 17 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 84ccb4469e0b..0a3aee4a57f7 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1652,18 +1652,31 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
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
+			if (PageTransHuge(page)) {
+				index = page->index + HPAGE_PMD_NR;
+				goto release;
+			}
 		}
 		index = pvec.pages[nr_pages - 1]->index + 1;
+release:
 		pagevec_release(&pvec);
 	}
 }
@@ -2097,16 +2110,16 @@ static int mpage_submit_page(struct mpage_da_data *mpd, struct page *page)
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
@@ -2254,12 +2267,16 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
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
@@ -2296,7 +2313,10 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
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
@@ -2304,6 +2324,10 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
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
@@ -2543,7 +2567,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			 * mapping. However, page->index will not change
 			 * because we have a reference on the page.
 			 */
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				goto out;
 
 			/*
@@ -2558,7 +2582,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 				goto out;
 
 			/* If we can't merge this page, we are done. */
-			if (mpd->map.m_len > 0 && mpd->next_page != page->index)
+			if (mpd->map.m_len > 0 && mpd->next_page != page_to_pgoff(page))
 				goto out;
 
 			lock_page(page);
@@ -2572,7 +2596,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			if (!PageDirty(page) ||
 			    (PageWriteback(page) &&
 			     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
-			    unlikely(page->mapping != mapping)) {
+			    unlikely(page_mapping(page) != mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -2581,8 +2605,10 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
