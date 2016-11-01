Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 129256B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 15:54:28 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f129so127900875itc.3
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:54:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id ys9si6556151pab.266.2016.11.01.12.54.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 12:54:27 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v9 01/16] ext4: tell DAX the size of allocation holes
Date: Tue,  1 Nov 2016 13:54:03 -0600
Message-Id: <1478030058-1422-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1478030058-1422-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1478030058-1422-1-git-send-email-ross.zwisler@linux.intel.com>
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
