Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7306B0263
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:09:57 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so116748917pab.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:09:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p4si19115744paz.202.2016.08.15.12.09.54
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 12:09:54 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 2/7] ext4: tell DAX the size of allocation holes
Date: Mon, 15 Aug 2016 13:09:13 -0600
Message-Id: <20160815190918.20672-3-ross.zwisler@linux.intel.com>
In-Reply-To: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

When DAX calls _ext4_get_block() and the file offset points to a hole we
currently don't set bh->b_size.  When we re-enable PMD faults DAX will
need bh->b_size to tell it the size of the hole so it can decide whether to
fault in a 4 KiB zero page or a 2 MiB zero page.

_ext4_get_block() has the hole size information from ext4_map_blocks(), so
populate bh->b_size.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext4/inode.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3131747..1808013 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -759,6 +759,9 @@ static int _ext4_get_block(struct inode *inode, sector_t iblock,
 		ext4_update_bh_state(bh, map.m_flags);
 		bh->b_size = inode->i_sb->s_blocksize * map.m_len;
 		ret = 0;
+	} else if (ret == 0) {
+		/* hole case, need to fill in bh->b_size */
+		bh->b_size = inode->i_sb->s_blocksize * map.m_len;
 	}
 	return ret;
 }
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
