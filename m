Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C120D28025F
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 16:48:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so51122327pfv.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:48:17 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id ez7si4297005pab.6.2016.09.27.13.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 13:48:15 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 02/11] ext4: tell DAX the size of allocation holes
Date: Tue, 27 Sep 2016 14:47:53 -0600
Message-Id: <1475009282-9818-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

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
index 0900cb4..9075fac 100644
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
