Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE2E6B028B
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:56 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ra7so50253pab.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:56 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h185si17988090pgc.324.2016.10.24.17.14.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 35/43] ext4: make ext4_block_write_begin() aware about huge pages
Date: Tue, 25 Oct 2016 03:13:34 +0300
Message-Id: <20161025001342.76126-36-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It simply matches changes to __block_write_begin_int().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c1728d2bf47b..1eae6801846c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1087,9 +1087,8 @@ int do_journal_get_write_access(handle_t *handle,
 static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 				  get_block_t *get_block)
 {
-	unsigned from = pos & (PAGE_SIZE - 1);
-	unsigned to = from + len;
-	struct inode *inode = page->mapping->host;
+	unsigned from, to;
+	struct inode *inode = page_mapping(page)->host;
 	unsigned block_start, block_end;
 	sector_t block;
 	int err = 0;
@@ -1097,10 +1096,14 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	unsigned bbits;
 	struct buffer_head *bh, *head, *wait[2], **wait_bh = wait;
 	bool decrypt = false;
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
 
 	if (!page_has_buffers(page))
@@ -1113,10 +1116,8 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	    block++, block_start = block_end, bh = bh->b_this_page) {
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
@@ -1129,19 +1130,25 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
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
-					zero_user_segments(page, to, block_end,
-							   block_start, from);
+				if (block_end > to || block_start < from) {
+					BUG_ON(to - from  > PAGE_SIZE);
+					zero_user_segments(page +
+							block_start / PAGE_SIZE,
+							to % PAGE_SIZE,
+							(block_start % PAGE_SIZE) + blocksize,
+							block_start % PAGE_SIZE,
+							from % PAGE_SIZE);
+				}
 				continue;
 			}
 		}
-		if (PageUptodate(page)) {
+		if (uptodate) {
 			if (!buffer_uptodate(bh))
 				set_buffer_uptodate(bh);
 			continue;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
