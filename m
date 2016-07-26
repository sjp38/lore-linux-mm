Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF85828E4
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:37:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hh10so364722274pac.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:37:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id c27si36078541pfk.274.2016.07.25.17.36.35
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 31/33] WIP: ext4: handle writeback with huge pages
Date: Tue, 26 Jul 2016 03:35:33 +0300
Message-Id: <1469493335-3622-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Modify mpage_map_and_submit_buffers() to do writeback with huge pages.

This is somewhat unstable. I have hard time see full picture yet.
More work is required.

Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 2e22f62f007b..29133e4550fc 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2088,16 +2088,16 @@ static int mpage_submit_page(struct mpage_da_data *mpd, struct page *page)
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
@@ -2245,12 +2245,16 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
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
@@ -2287,7 +2291,10 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
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
@@ -2295,6 +2302,10 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
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
@@ -2534,7 +2545,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			 * mapping. However, page->index will not change
 			 * because we have a reference on the page.
 			 */
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				goto out;
 
 			/*
@@ -2563,7 +2574,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			if (!PageDirty(page) ||
 			    (PageWriteback(page) &&
 			     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
-			    unlikely(page->mapping != mapping)) {
+			    unlikely(page_mapping(page) != mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -2572,8 +2583,9 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			BUG_ON(PageWriteback(page));
 
 			if (mpd->map.m_len == 0)
-				mpd->first_page = page->index;
-			mpd->next_page = page->index + 1;
+				mpd->first_page = page_to_pgoff(page);
+			mpd->next_page = round_up(mpd->first_page + 1,
+					hpage_nr_pages(compound_head(page)));
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
