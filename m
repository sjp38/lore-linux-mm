Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4673B6B0275
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so425581395pga.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:46 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q71si59468288pfj.175.2016.11.29.03.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:45 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 34/36] ext4: make fallocate() operations work with huge pages
Date: Tue, 29 Nov 2016 14:23:02 +0300
Message-Id: <20161129112304.90056-35-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

__ext4_block_zero_page_range() adjusted to calculate starting iblock
correctry for huge pages.

ext4_{collapse,insert}_range() requires page cache invalidation. We need
the invalidation to be aligning to huge page border if huge pages are
possible in page cache.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/extents.c | 10 ++++++++--
 fs/ext4/inode.c   |  3 +--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 7d29ef0f5f5c..99632945b3f5 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -5501,7 +5501,10 @@ int ext4_collapse_range(struct inode *inode, loff_t offset, loff_t len)
 	 * Need to round down offset to be aligned with page size boundary
 	 * for page size > block size.
 	 */
-	ioffset = round_down(offset, PAGE_SIZE);
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+		ioffset = round_down(offset, HPAGE_PMD_SIZE);
+	else
+		ioffset = round_down(offset, PAGE_SIZE);
 	/*
 	 * Write tail of the last page before removed range since it will get
 	 * removed from the page cache below.
@@ -5650,7 +5653,10 @@ int ext4_insert_range(struct inode *inode, loff_t offset, loff_t len)
 	 * Need to round down to align start offset to page size boundary
 	 * for page size > block size.
 	 */
-	ioffset = round_down(offset, PAGE_SIZE);
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+		ioffset = round_down(offset, HPAGE_PMD_SIZE);
+	else
+		ioffset = round_down(offset, PAGE_SIZE);
 	/* Write out all dirty pages */
 	ret = filemap_write_and_wait_range(inode->i_mapping, ioffset,
 			LLONG_MAX);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index ff4f460d3625..263b53ace613 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3807,7 +3807,6 @@ void ext4_set_aops(struct inode *inode)
 static int __ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
-	ext4_fsblk_t index = from >> PAGE_SHIFT;
 	unsigned offset;
 	unsigned blocksize, pos;
 	ext4_lblk_t iblock;
@@ -3826,7 +3825,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 
 	blocksize = inode->i_sb->s_blocksize;
 
-	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = page->index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
