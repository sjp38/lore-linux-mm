Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 924F5828F3
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:46:25 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so5719073pac.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:46:25 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.39.02
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 33/41] ext4: make ext4_block_write_begin() aware about huge pages
Date: Fri, 12 Aug 2016 21:38:16 +0300
Message-Id: <1471027104-115213-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It simply matches changes to __block_write_begin_int().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index bee21fffbfb9..1c325f62e766 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1079,9 +1079,8 @@ int do_journal_get_write_access(handle_t *handle,
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
@@ -1090,9 +1089,12 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	struct buffer_head *bh, *head, *wait[2], **wait_bh = wait;
 	bool decrypt = false;
 
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
@@ -1127,9 +1129,15 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
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
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
