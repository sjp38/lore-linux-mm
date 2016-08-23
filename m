Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 416986B0253
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:04:32 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so280768407pab.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 15:04:32 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id hm6si5740071pac.254.2016.08.23.15.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 15:04:31 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Date: Tue, 23 Aug 2016 16:04:12 -0600
Message-Id: <20160823220419.11717-3-ross.zwisler@linux.intel.com>
In-Reply-To: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>

When DAX calls ext2_get_block() and the file offset points to a hole we
currently don't set bh_result->b_size.  When we re-enable PMD faults DAX
will need bh_result->b_size to tell it the size of the hole so it can
decide whether to fault in a 4 KiB zero page or a 2 MiB zero page.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext2/inode.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index d5c7d09..dd55d74 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -773,6 +773,9 @@ int ext2_get_block(struct inode *inode, sector_t iblock, struct buffer_head *bh_
 	if (ret > 0) {
 		bh_result->b_size = (ret << inode->i_blkbits);
 		ret = 0;
+	} else if (ret == 0) {
+		/* hole case, need to fill in bh_result->b_size */
+		bh_result->b_size = 1 << inode->i_blkbits;
 	}
 	return ret;
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
