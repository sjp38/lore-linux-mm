Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE2556B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:34:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n85so3481159pfi.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:34:43 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id bo7si34909782pab.241.2016.10.19.12.34.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 12:34:42 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v8 01/16] ext4: tell DAX the size of allocation holes
Date: Wed, 19 Oct 2016 13:34:20 -0600
Message-Id: <1476905675-32581-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

When DAX calls _ext4_get_block() and the file offset points to a hole we
currently don't set bh->b_size.  This is current worked around via
buffer_size_valid() in fs/dax.c.

_ext4_get_block() has the hole size information from ext4_map_blocks(), so
populate bh->b_size so we can remove buffer_size_valid() in a later patch.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/inode.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 9c06472..3d58b2b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -767,6 +767,9 @@ static int _ext4_get_block(struct inode *inode, sector_t iblock,
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
