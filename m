Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7E5280255
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:59:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so307806320pfx.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:59:23 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h73si1238621pfh.1.2017.01.26.03.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:59:22 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 28/37] ext4: make ext4_block_write_begin() aware about huge pages
Date: Thu, 26 Jan 2017 14:58:10 +0300
Message-Id: <20170126115819.58875-29-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
index 7e65a5b78cf1..3eae2d058fd0 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1093,9 +1093,8 @@ int do_journal_get_write_access(handle_t *handle,
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
@@ -1103,10 +1102,14 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
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
@@ -1119,10 +1122,8 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
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
@@ -1134,19 +1135,25 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 				break;
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
