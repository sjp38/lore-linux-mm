Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 130F56B0286
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:56 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so178337702pfg.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 38si1220786pln.155.2017.01.26.03.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:55 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 34/37] ext4: make fallocate() operations work with huge pages
Date: Thu, 26 Jan 2017 14:58:16 +0300
Message-Id: <20170126115819.58875-35-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
index 3e295d3350a9..f743e772b44f 100644
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
index 409ebd81e436..5bf68bbe65ec 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3816,7 +3816,6 @@ void ext4_set_aops(struct inode *inode)
 static int __ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
-	ext4_fsblk_t index = from >> PAGE_SHIFT;
 	unsigned offset;
 	unsigned blocksize, pos;
 	ext4_lblk_t iblock;
@@ -3835,7 +3834,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 
 	blocksize = inode->i_sb->s_blocksize;
 
-	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = page->index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
