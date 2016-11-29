Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3E16B0273
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:42 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so254532430pfy.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:42 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b192si56373317pga.202.2016.11.29.03.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:41 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 27/36] ext4: handle huge pages in __ext4_block_zero_page_range()
Date: Tue, 29 Nov 2016 14:22:55 +0300
Message-Id: <20161129112304.90056-28-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As the function handles zeroing range only within one block, the
required changes are trivial, just remove assuption on page size.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 387aa857770b..d3143dfe9962 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3776,7 +3776,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
 	ext4_fsblk_t index = from >> PAGE_SHIFT;
-	unsigned offset = from & (PAGE_SIZE-1);
+	unsigned offset;
 	unsigned blocksize, pos;
 	ext4_lblk_t iblock;
 	struct inode *inode = mapping->host;
@@ -3789,6 +3789,9 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 	if (!page)
 		return -ENOMEM;
 
+	page = compound_head(page);
+	offset = from & ~hpage_mask(page);
+
 	blocksize = inode->i_sb->s_blocksize;
 
 	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
@@ -3845,7 +3848,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		if (err)
 			goto unlock;
 	}
-	zero_user(page, offset, length);
+	zero_user(page + offset / PAGE_SIZE, offset % PAGE_SIZE, length);
 	BUFFER_TRACE(bh, "zeroed end of block");
 
 	if (ext4_should_journal_data(inode)) {
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
