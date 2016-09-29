Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id C27A46B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 18:49:35 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu14so167030717pad.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 15:49:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d86si16422436pfe.90.2016.09.29.15.49.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 15:49:35 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 01/12] ext4: allow DAX writeback for hole punch
Date: Thu, 29 Sep 2016 16:49:19 -0600
Message-Id: <1475189370-31634-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, stable@vger.kernel.org

Currently when doing a DAX hole punch with ext4 we fail to do a writeback.
This is because the logic around filemap_write_and_wait_range() in
ext4_punch_hole() only looks for dirty page cache pages in the radix tree,
not for dirty DAX exceptional entries.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: <stable@vger.kernel.org>
---
 fs/ext4/inode.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3131747..0900cb4 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3890,7 +3890,7 @@ int ext4_update_disksize_before_punch(struct inode *inode, loff_t offset,
 }
 
 /*
- * ext4_punch_hole: punches a hole in a file by releaseing the blocks
+ * ext4_punch_hole: punches a hole in a file by releasing the blocks
  * associated with the given offset and length
  *
  * @inode:  File inode
@@ -3919,7 +3919,7 @@ int ext4_punch_hole(struct inode *inode, loff_t offset, loff_t length)
 	 * Write out all dirty pages to avoid race conditions
 	 * Then release them.
 	 */
-	if (mapping->nrpages && mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
+	if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
 		ret = filemap_write_and_wait_range(mapping, offset,
 						   offset + length - 1);
 		if (ret)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
