Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCF9E280258
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:52 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fu12so85061443pac.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:52 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y187si3556097pfy.250.2016.09.15.04.55.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 35/41] ext4: make ext4_da_page_release_reservation() aware about huge pages
Date: Thu, 15 Sep 2016 14:55:17 +0300
Message-Id: <20160915115523.29737-36-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index deacd3499ec7..6a8da1a8409c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1558,7 +1558,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	int num_clusters;
 	ext4_fsblk_t lblk;
 
-	BUG_ON(stop > PAGE_SIZE || stop < length);
+	BUG_ON(stop > hpage_size(page) || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
@@ -1593,7 +1593,8 @@ static void ext4_da_page_release_reservation(struct page *page,
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
