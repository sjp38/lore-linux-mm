Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD15B280255
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:59:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so53763146pgj.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:59:18 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d10si1239657pln.27.2017.01.26.03.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:59:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 18/37] fs: make block_write_{begin,end}() be able to handle huge pages
Date: Thu, 26 Jan 2017 14:58:00 +0300
Message-Id: <20170126115819.58875-19-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
index 72462beca909..d05524f14846 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1902,6 +1902,7 @@ void page_zero_new_buffers(struct page *page, unsigned from, unsigned to)
 {
 	unsigned int block_start, block_end;
 	struct buffer_head *head, *bh;
+	bool uptodate = PageUptodate(page);
 
 	BUG_ON(!PageLocked(page));
 	if (!page_has_buffers(page))
@@ -1912,21 +1913,21 @@ void page_zero_new_buffers(struct page *page, unsigned from, unsigned to)
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
@@ -1992,18 +1993,21 @@ iomap_to_bh(struct inode *inode, sector_t block, struct buffer_head *bh,
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
@@ -2016,10 +2020,8 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
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
@@ -2036,23 +2038,28 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 
 			if (buffer_new(bh)) {
 				clean_bdev_bh_alias(bh);
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
@@ -2089,6 +2096,7 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 	unsigned blocksize;
 	struct buffer_head *bh, *head;
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	bh = head = page_buffers(page);
 	blocksize = bh->b_size;
 
@@ -2102,7 +2110,8 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 			set_buffer_uptodate(bh);
 			mark_buffer_dirty(bh);
 		}
-		clear_buffer_new(bh);
+		if (buffer_new(bh))
+			clear_buffer_new(bh);
 
 		block_start = block_end;
 		bh = bh->b_this_page;
@@ -2155,7 +2164,8 @@ int block_write_end(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	unsigned start;
 
-	start = pos & (PAGE_SIZE - 1);
+	page = compound_head(page);
+	start = pos & ~hpage_mask(page);
 
 	if (unlikely(copied < len)) {
 		/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
