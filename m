Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D285280251
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:47 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu12so85058194pac.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:47 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y187si3556097pfy.250.2016.09.15.04.55.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 24/41] fs: make block_write_{begin,end}() be able to handle huge pages
Date: Thu, 15 Sep 2016 14:55:06 +0300
Message-Id: <20160915115523.29737-25-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's more or less straight-forward.

Most changes are around getting offset/len withing page right and zero
out desired part of the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/buffer.c | 53 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 31 insertions(+), 22 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 2739f5dae690..7f50e5a63670 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1870,21 +1870,21 @@ void page_zero_new_buffers(struct page *page, unsigned from, unsigned to)
 	do {
 		block_end = block_start + bh->b_size;
 
-		if (buffer_new(bh)) {
-			if (block_end > from && block_start < to) {
-				if (!PageUptodate(page)) {
-					unsigned start, size;
+		if (buffer_new(bh) && block_end > from && block_start < to) {
+			if (!PageUptodate(page)) {
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
@@ -1950,18 +1950,20 @@ iomap_to_bh(struct inode *inode, sector_t block, struct buffer_head *bh,
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
@@ -2001,10 +2003,15 @@ int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
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
@@ -2048,6 +2055,7 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 	unsigned blocksize;
 	struct buffer_head *bh, *head;
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	bh = head = page_buffers(page);
 	blocksize = bh->b_size;
 
@@ -2114,7 +2122,8 @@ int block_write_end(struct file *file, struct address_space *mapping,
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
