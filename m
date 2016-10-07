Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 825A76B0261
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 17:09:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r16so34906995pfg.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 14:09:16 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n9si18446948pac.82.2016.10.07.14.09.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 14:09:14 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 05/17] ext2: return -EIO on ext2_iomap_end() failure
Date: Fri,  7 Oct 2016 15:08:52 -0600
Message-Id: <1475874544-24842-6-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Right now we just return 0 for success, but we really want to let callers
know about this failure.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext2/inode.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index c7dbb46..368913c 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -830,8 +830,10 @@ ext2_iomap_end(struct inode *inode, loff_t offset, loff_t length,
 {
 	if (iomap->type == IOMAP_MAPPED &&
 	    written < length &&
-	    (flags & IOMAP_WRITE))
+	    (flags & IOMAP_WRITE)) {
 		ext2_write_failed(inode->i_mapping, offset + length);
+		return -EIO;
+	}
 	return 0;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
