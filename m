Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF96A82F66
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:05:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so277494476pfg.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 15:05:30 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id hm6si5740071pac.254.2016.08.23.15.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 15:04:30 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 1/9] ext4: allow DAX writeback for hole punch
Date: Tue, 23 Aug 2016 16:04:11 -0600
Message-Id: <20160823220419.11717-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, stable@vger.kernel.org

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
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
