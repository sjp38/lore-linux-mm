Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E30668296C
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so6142802pfd.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:25 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.39.02
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 39/41] ext4: make fallocate() operations work with huge pages
Date: Fri, 12 Aug 2016 21:38:22 +0300
Message-Id: <1471027104-115213-40-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index d7ccb7f51dfc..d46aeda70fb0 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -5525,7 +5525,10 @@ int ext4_collapse_range(struct inode *inode, loff_t offset, loff_t len)
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
@@ -5674,7 +5677,10 @@ int ext4_insert_range(struct inode *inode, loff_t offset, loff_t len)
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
index 0a3aee4a57f7..cd8d03559896 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3712,7 +3712,6 @@ void ext4_set_aops(struct inode *inode)
 static int __ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
-	ext4_fsblk_t index = from >> PAGE_SHIFT;
 	unsigned offset;
 	unsigned blocksize, pos;
 	ext4_lblk_t iblock;
@@ -3731,7 +3730,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 
 	blocksize = inode->i_sb->s_blocksize;
 
-	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = page->index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
