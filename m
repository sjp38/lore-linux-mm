Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C17CC6B0261
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:35:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a140so220459wma.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:35:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t130si773074wme.63.2016.04.18.14.35.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 14:35:50 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/18] ext4: Handle transient ENOSPC properly for DAX
Date: Mon, 18 Apr 2016 23:35:24 +0200
Message-Id: <1461015341-20153-2-git-send-email-jack@suse.cz>
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>

ext4_dax_get_blocks() was accidentally omitted fixing get blocks
handlers to properly handle transient ENOSPC errors. Fix it now to use
ext4_get_blocks_trans() helper which takes care of these errors.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/inode.c | 75 +++++++++++++++------------------------------------------
 1 file changed, 20 insertions(+), 55 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 981a1fc30eaa..3e0c06028668 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3218,72 +3218,37 @@ static int ext4_releasepage(struct page *page, gfp_t wait)
 int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
 			    struct buffer_head *bh_result, int create)
 {
-	int ret, err;
-	int credits;
-	struct ext4_map_blocks map;
-	handle_t *handle = NULL;
-	int flags = 0;
+	int ret;
 
 	ext4_debug("ext4_dax_mmap_get_block: inode %lu, create flag %d\n",
 		   inode->i_ino, create);
-	map.m_lblk = iblock;
-	map.m_len = bh_result->b_size >> inode->i_blkbits;
-	credits = ext4_chunk_trans_blocks(inode, map.m_len);
-	if (create) {
-		flags |= EXT4_GET_BLOCKS_PRE_IO | EXT4_GET_BLOCKS_CREATE_ZERO;
-		handle = ext4_journal_start(inode, EXT4_HT_MAP_BLOCKS, credits);
-		if (IS_ERR(handle)) {
-			ret = PTR_ERR(handle);
-			return ret;
-		}
-	}
+	if (!create)
+		return _ext4_get_block(inode, iblock, bh_result, 0);
 
-	ret = ext4_map_blocks(handle, inode, &map, flags);
-	if (create) {
-		err = ext4_journal_stop(handle);
-		if (ret >= 0 && err < 0)
-			ret = err;
-	}
-	if (ret <= 0)
-		goto out;
-	if (map.m_flags & EXT4_MAP_UNWRITTEN) {
-		int err2;
+	ret = ext4_get_block_trans(inode, iblock, bh_result,
+				   EXT4_GET_BLOCKS_PRE_IO |
+				   EXT4_GET_BLOCKS_CREATE_ZERO);
+	if (ret < 0)
+		return ret;
 
+	if (buffer_unwritten(bh_result)) {
 		/*
 		 * We are protected by i_mmap_sem so we know block cannot go
 		 * away from under us even though we dropped i_data_sem.
 		 * Convert extent to written and write zeros there.
-		 *
-		 * Note: We may get here even when create == 0.
 		 */
-		handle = ext4_journal_start(inode, EXT4_HT_MAP_BLOCKS, credits);
-		if (IS_ERR(handle)) {
-			ret = PTR_ERR(handle);
-			goto out;
-		}
-
-		err = ext4_map_blocks(handle, inode, &map,
-		      EXT4_GET_BLOCKS_CONVERT | EXT4_GET_BLOCKS_CREATE_ZERO);
-		if (err < 0)
-			ret = err;
-		err2 = ext4_journal_stop(handle);
-		if (err2 < 0 && ret > 0)
-			ret = err2;
-	}
-out:
-	WARN_ON_ONCE(ret == 0 && create);
-	if (ret > 0) {
-		map_bh(bh_result, inode->i_sb, map.m_pblk);
-		/*
-		 * At least for now we have to clear BH_New so that DAX code
-		 * doesn't attempt to zero blocks again in a racy way.
-		 */
-		map.m_flags &= ~EXT4_MAP_NEW;
-		ext4_update_bh_state(bh_result, map.m_flags);
-		bh_result->b_size = map.m_len << inode->i_blkbits;
-		ret = 0;
+		ret = ext4_get_block_trans(inode, iblock, bh_result,
+					   EXT4_GET_BLOCKS_CONVERT |
+					   EXT4_GET_BLOCKS_CREATE_ZERO);
+		if (ret < 0)
+			return ret;
 	}
-	return ret;
+	/*
+	 * At least for now we have to clear BH_New so that DAX code
+	 * doesn't attempt to zero blocks again in a racy way.
+	 */
+	clear_buffer_new(bh_result);
+	return 0;
 }
 #endif
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
