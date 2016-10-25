Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACB86B0274
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x70so87505198pfk.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y62si17971548pgy.100.2016.10.24.17.14.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:23 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 25/43] fs: make block_write_{begin,end}() be able to handle huge pages
Date: Tue, 25 Oct 2016 03:13:24 +0300
Message-Id: <20161025001342.76126-26-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's more or less straight-forward.

Most changes are around getting offset/len withing page right and zero
out desired part of the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/buffer.c | 70 +++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 40 insertions(+), 30 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 35b76b1c0308..c078f5d74a2a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1859,6 +1859,7 @@ void page_zero_new_buffers(struct page *page, unsigned from, unsigned to)
 {
 	unsigned int block_start, block_end;
 	struct buffer_head *head, *bh;
+	bool uptodate = PageUptodate(page);
 
 	BUG_ON(!PageLocked(page));
 	if (!page_has_buffers(page))
@@ -1869,21 +1870,21 @@ void page_zero_new_buffers(struct page *page, unsigned from, unsigned to)
 	do {
 		block_end = block_start + bh->b_size;
 
-		if (buffer_new(bh)) {
-			if (block_end > from && block_start < to) {
-				if (!PageUptodate(page)) {
-					unsigned start, size;
+		if (buffer_new(bh) && block_end > from && block_start < to) {
+			if (!uptodate) {
+				unsigned start, size;
 
-					start = max(from, block_start);
-					size = min(to, block_end) - start;
+				start = max(from, block_start);
+				size = min(to, block_end) - start;
 
-					zero_user(page, start, size);
-					set_buffer_uptodate(bh);
-				}
-
-				clear_buffer_new(bh);
-				mark_buffer_dirty(bh);
+				zero_user(page + block_start / PAGE_SIZE,
+						start % PAGE_SIZE,
+						size);
+				set_buffer_uptodate(bh);
 			}
+
+			clear_buffer_new(bh);
+			mark_buffer_dirty(bh);
 		}
 
 		block_start = block_end;
@@ -1949,18 +1950,21 @@ iomap_to_bh(struct inode *inode, sector_t block, struct buffer_head *bh,
 int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 		get_block_t *get_block, struct iomap *iomap)
 {
-	unsigned from = pos & (PAGE_SIZE - 1);
-	unsigned to = from + len;
-	struct inode *inode = page->mapping->host;
+	unsigned from, to;
+	struct inode *inode = page_mapping(page)->host;
 	unsigned block_start, block_end;
 	sector_t block;
 	int err = 0;
 	unsigned blocksize, bbits;
 	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
+	bool uptodate = PageUptodate(page);
 
+	page = compound_head(page);
+	from = pos & ~hpage_mask(page);
+	to = from + len;
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_SIZE);
-	BUG_ON(to > PAGE_SIZE);
+	BUG_ON(from > hpage_size(page));
+	BUG_ON(to > hpage_size(page));
 	BUG_ON(from > to);
 
 	head = create_page_buffers(page, inode, 0);
@@ -1973,10 +1977,8 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 	    block++, block_start=block_end, bh = bh->b_this_page) {
 		block_end = block_start + blocksize;
 		if (block_end <= from || block_start >= to) {
-			if (PageUptodate(page)) {
-				if (!buffer_uptodate(bh))
-					set_buffer_uptodate(bh);
-			}
+			if (uptodate && !buffer_uptodate(bh))
+				set_buffer_uptodate(bh);
 			continue;
 		}
 		if (buffer_new(bh))
@@ -1994,23 +1996,28 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 			if (buffer_new(bh)) {
 				unmap_underlying_metadata(bh->b_bdev,
 							bh->b_blocknr);
-				if (PageUptodate(page)) {
+				if (uptodate) {
 					clear_buffer_new(bh);
 					set_buffer_uptodate(bh);
 					mark_buffer_dirty(bh);
 					continue;
 				}
-				if (block_end > to || block_start < from)
-					zero_user_segments(page,
-						to, block_end,
-						block_start, from);
+				if (block_end > to || block_start < from) {
+					BUG_ON(to - from  > PAGE_SIZE);
+					zero_user_segments(page +
+							block_start / PAGE_SIZE,
+						to % PAGE_SIZE,
+						(block_start % PAGE_SIZE) + blocksize,
+						block_start % PAGE_SIZE,
+						from % PAGE_SIZE);
+				}
 				continue;
 			}
 		}
-		if (PageUptodate(page)) {
+		if (uptodate) {
 			if (!buffer_uptodate(bh))
 				set_buffer_uptodate(bh);
-			continue; 
+			continue;
 		}
 		if (!buffer_uptodate(bh) && !buffer_delay(bh) &&
 		    !buffer_unwritten(bh) &&
@@ -2047,6 +2054,7 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 	unsigned blocksize;
 	struct buffer_head *bh, *head;
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	bh = head = page_buffers(page);
 	blocksize = bh->b_size;
 
@@ -2060,7 +2068,8 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 			set_buffer_uptodate(bh);
 			mark_buffer_dirty(bh);
 		}
-		clear_buffer_new(bh);
+		if (buffer_new(bh))
+			clear_buffer_new(bh);
 
 		block_start = block_end;
 		bh = bh->b_this_page;
@@ -2113,7 +2122,8 @@ int block_write_end(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	unsigned start;
 
-	start = pos & (PAGE_SIZE - 1);
+	page = compound_head(page);
+	start = pos & ~hpage_mask(page);
 
 	if (unlikely(copied < len)) {
 		/*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
