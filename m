Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A69016B0273
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so424901511pgd.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:42 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 1si30856571plm.51.2016.11.29.03.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:41 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 30/36] ext4: make ext4_da_page_release_reservation() aware about huge pages
Date: Tue, 29 Nov 2016 14:22:58 +0300
Message-Id: <20161129112304.90056-31-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For huge pages 'stop' must be within HPAGE_PMD_SIZE.
Let's use hpage_size() in the BUG_ON().

We also need to change how we calculate lblk for cluster deallocation.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index e89249c03d2f..035256019e16 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1572,7 +1572,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	int num_clusters;
 	ext4_fsblk_t lblk;
 
-	BUG_ON(stop > PAGE_SIZE || stop < length);
+	BUG_ON(stop > hpage_size(page) || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
@@ -1607,7 +1607,8 @@ static void ext4_da_page_release_reservation(struct page *page,
 	 * need to release the reserved space for that cluster. */
 	num_clusters = EXT4_NUM_B2C(sbi, to_release);
 	while (num_clusters > 0) {
-		lblk = (page->index << (PAGE_SHIFT - inode->i_blkbits)) +
+		lblk = ((page->index + offset / PAGE_SIZE) <<
+				(PAGE_SHIFT - inode->i_blkbits)) +
 			((num_clusters - 1) << sbi->s_cluster_bits);
 		if (sbi->s_cluster_ratio == 1 ||
 		    !ext4_find_delalloc_cluster(inode, lblk))
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
