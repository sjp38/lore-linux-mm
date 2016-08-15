Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7199E6B0262
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:09:55 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so116550309pad.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:09:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p4si19115744paz.202.2016.08.15.12.09.53
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 12:09:54 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 1/7] ext2: tell DAX the size of allocation holes
Date: Mon, 15 Aug 2016 13:09:12 -0600
Message-Id: <20160815190918.20672-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

When DAX calls ext2_get_block() and the file offset points to a hole we
currently don't set bh_result->b_size.  When we re-enable PMD faults DAX
will need bh_result->b_size to tell it the size of the hole so it can
decide whether to fault in a 4 KiB zero page or a 2 MiB zero page.

For ext2 we always want DAX to use 4 KiB zero pages, so we just tell DAX
that all holes are 4 KiB in size.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext2/inode.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index d5c7d09..c6d9763 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -773,6 +773,12 @@ int ext2_get_block(struct inode *inode, sector_t iblock, struct buffer_head *bh_
 	if (ret > 0) {
 		bh_result->b_size = (ret << inode->i_blkbits);
 		ret = 0;
+	} else if (ret == 0 && IS_DAX(inode)) {
+		/*
+		 * We have hit a hole.  Tell DAX it is 4k in size so that it
+		 * uses PTE faults.
+		 */
+		bh_result->b_size = PAGE_SIZE;
 	}
 	return ret;
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
