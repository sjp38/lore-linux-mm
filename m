Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40A0E28025C
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so89458631pfb.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id bm5si1150675pad.46.2016.09.15.04.55.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 37/41] ext4: make EXT4_IOC_MOVE_EXT work with huge pages
Date: Thu, 15 Sep 2016 14:55:19 +0300
Message-Id: <20160915115523.29737-38-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Adjust how we find relevant block within page and how we clear the
required part of the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/move_extent.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index a920c5d29fac..f3efdd0e0eaf 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -210,7 +210,9 @@ mext_page_mkuptodate(struct page *page, unsigned from, unsigned to)
 				return err;
 			}
 			if (!buffer_mapped(bh)) {
-				zero_user(page, block_start, blocksize);
+				zero_user(page + block_start / PAGE_SIZE,
+						block_start % PAGE_SIZE,
+						blocksize);
 				set_buffer_uptodate(bh);
 				continue;
 			}
@@ -267,10 +269,11 @@ move_extent_per_page(struct file *o_filp, struct inode *donor_inode,
 	unsigned int tmp_data_size, data_size, replaced_size;
 	int i, err2, jblocks, retries = 0;
 	int replaced_count = 0;
-	int from = data_offset_in_page << orig_inode->i_blkbits;
+	int from;
 	int blocks_per_page = PAGE_SIZE >> orig_inode->i_blkbits;
 	struct super_block *sb = orig_inode->i_sb;
 	struct buffer_head *bh = NULL;
+	int diff;
 
 	/*
 	 * It needs twice the amount of ordinary journal buffers because
@@ -355,6 +358,9 @@ again:
 		goto unlock_pages;
 	}
 data_copy:
+	diff = (pagep[0] - compound_head(pagep[0])) * blocks_per_page;
+	from = (data_offset_in_page + diff) << orig_inode->i_blkbits;
+	pagep[0] = compound_head(pagep[0]);
 	*err = mext_page_mkuptodate(pagep[0], from, from + replaced_size);
 	if (*err)
 		goto unlock_pages;
@@ -384,7 +390,7 @@ data_copy:
 	if (!page_has_buffers(pagep[0]))
 		create_empty_buffers(pagep[0], 1 << orig_inode->i_blkbits, 0);
 	bh = page_buffers(pagep[0]);
-	for (i = 0; i < data_offset_in_page; i++)
+	for (i = 0; i < data_offset_in_page + diff; i++)
 		bh = bh->b_this_page;
 	for (i = 0; i < block_len_in_page; i++) {
 		*err = ext4_get_block(orig_inode, orig_blk_offset + i, bh, 0);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
