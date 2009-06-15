Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5879C6B005C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:11 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/11] ext3: Get rid of extenddisksize parameter of ext3_get_blocks_handle()
Date: Mon, 15 Jun 2009 19:59:48 +0200
Message-Id: <1245088797-29533-2-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Get rid of extenddisksize parameter of ext3_get_blocks_handle(). This seems to
be a relict from some old days and setting disksize in this function does not
make much sence. Currently it was set only by ext3_getblk().  Since the
parameter has some effect only if create == 1, it is easy to check that the
three callers which end up calling ext3_getblk() with create == 1 (ext3_append,
ext3_quota_write, ext3_mkdir) do the right thing and set disksize themselves.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext3/dir.c           |    3 +--
 fs/ext3/inode.c         |   13 +++----------
 include/linux/ext3_fs.h |    2 +-
 3 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
index 3d724a9..373fa90 100644
--- a/fs/ext3/dir.c
+++ b/fs/ext3/dir.c
@@ -130,8 +130,7 @@ static int ext3_readdir(struct file * filp,
 		struct buffer_head *bh = NULL;
 
 		map_bh.b_state = 0;
-		err = ext3_get_blocks_handle(NULL, inode, blk, 1,
-						&map_bh, 0, 0);
+		err = ext3_get_blocks_handle(NULL, inode, blk, 1, &map_bh, 0);
 		if (err > 0) {
 			pgoff_t index = map_bh.b_blocknr >>
 					(PAGE_CACHE_SHIFT - inode->i_blkbits);
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index b0248c6..2d4b2ca 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -788,7 +788,7 @@ err_out:
 int ext3_get_blocks_handle(handle_t *handle, struct inode *inode,
 		sector_t iblock, unsigned long maxblocks,
 		struct buffer_head *bh_result,
-		int create, int extend_disksize)
+		int create)
 {
 	int err = -EIO;
 	int offsets[4];
@@ -911,13 +911,6 @@ int ext3_get_blocks_handle(handle_t *handle, struct inode *inode,
 	if (!err)
 		err = ext3_splice_branch(handle, inode, iblock,
 					partial, indirect_blks, count);
-	/*
-	 * i_disksize growing is protected by truncate_mutex.  Don't forget to
-	 * protect it if you're about to implement concurrent
-	 * ext3_get_block() -bzzz
-	*/
-	if (!err && extend_disksize && inode->i_size > ei->i_disksize)
-		ei->i_disksize = inode->i_size;
 	mutex_unlock(&ei->truncate_mutex);
 	if (err)
 		goto cleanup;
@@ -972,7 +965,7 @@ static int ext3_get_block(struct inode *inode, sector_t iblock,
 	}
 
 	ret = ext3_get_blocks_handle(handle, inode, iblock,
-					max_blocks, bh_result, create, 0);
+					max_blocks, bh_result, create);
 	if (ret > 0) {
 		bh_result->b_size = (ret << inode->i_blkbits);
 		ret = 0;
@@ -1005,7 +998,7 @@ struct buffer_head *ext3_getblk(handle_t *handle, struct inode *inode,
 	dummy.b_blocknr = -1000;
 	buffer_trace_init(&dummy.b_history);
 	err = ext3_get_blocks_handle(handle, inode, block, 1,
-					&dummy, create, 1);
+					&dummy, create);
 	/*
 	 * ext3_get_blocks_handle() returns number of blocks
 	 * mapped. 0 in case of a HOLE.
diff --git a/include/linux/ext3_fs.h b/include/linux/ext3_fs.h
index 634a5e5..7499b36 100644
--- a/include/linux/ext3_fs.h
+++ b/include/linux/ext3_fs.h
@@ -874,7 +874,7 @@ struct buffer_head * ext3_getblk (handle_t *, struct inode *, long, int, int *);
 struct buffer_head * ext3_bread (handle_t *, struct inode *, int, int, int *);
 int ext3_get_blocks_handle(handle_t *handle, struct inode *inode,
 	sector_t iblock, unsigned long maxblocks, struct buffer_head *bh_result,
-	int create, int extend_disksize);
+	int create);
 
 extern struct inode *ext3_iget(struct super_block *, unsigned long);
 extern int  ext3_write_inode (struct inode *, int);
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
