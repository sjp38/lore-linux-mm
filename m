Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DEAF46B027A
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r16so132112763pfg.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:26 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m8si17919501pfa.203.2016.10.24.17.14.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 37/43] ext4: make ext4_da_page_release_reservation() aware about huge pages
Date: Tue, 25 Oct 2016 03:13:36 +0300
Message-Id: <20161025001342.76126-38-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index 59cd2b113eb2..869df0504174 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1565,7 +1565,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	int num_clusters;
 	ext4_fsblk_t lblk;
 
-	BUG_ON(stop > PAGE_SIZE || stop < length);
+	BUG_ON(stop > hpage_size(page) || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
@@ -1600,7 +1600,8 @@ static void ext4_da_page_release_reservation(struct page *page,
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
