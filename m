Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 29BDE6B005C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:21:45 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/7] ext4: Deprecate nobh mount option
Date: Thu, 17 Sep 2009 17:21:43 +0200
Message-Id: <1253200907-31392-4-git-send-email-jack@suse.cz>
In-Reply-To: <1253200907-31392-1-git-send-email-jack@suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

This option doesn't do anything interesting for ext4 anymore since we attach
buffers to the page in page_mkwrite and in write_begin to support delayed
allocation and properly handle ENOSPC caused by mmaped writes.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/inode.c |   42 ++++++++++++------------------------------
 fs/ext4/super.c |   10 +++-------
 2 files changed, 15 insertions(+), 37 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index f9c642b..58492ab 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2481,20 +2481,17 @@ static int ext4_da_get_block_prep(struct inode *inode, sector_t iblock,
 }
 
 /*
- * This function is used as a standard get_block_t calback function
- * when there is no desire to allocate any blocks.  It is used as a
- * callback function for block_prepare_write(), nobh_writepage(), and
- * block_write_full_page().  These functions should only try to map a
- * single block at a time.
+ * This function is used as a standard get_block_t calback function when there
+ * is no desire to allocate any blocks.  It is used as a callback function for
+ * block_prepare_write() and block_write_full_page().  These functions should
+ * only try to map a single block at a time.
  *
- * Since this function doesn't do block allocations even if the caller
- * requests it by passing in create=1, it is critically important that
- * any caller checks to make sure that any buffer heads are returned
- * by this function are either all already mapped or marked for
- * delayed allocation before calling nobh_writepage() or
- * block_write_full_page().  Otherwise, b_blocknr could be left
- * unitialized, and the page write functions will be taken by
- * surprise.
+ * Since this function doesn't do block allocations even if the caller requests
+ * it by passing in create=1, it is critically important that any caller checks
+ * to make sure that any buffer heads are returned by this function are either
+ * all already mapped or marked for delayed allocation before calling
+ * block_write_full_page().  Otherwise, b_blocknr could be left unitialized,
+ * and the page write functions will be taken by surprise.
  */
 static int noalloc_get_block_write(struct inode *inode, sector_t iblock,
 				   struct buffer_head *bh_result, int create)
@@ -2690,11 +2687,7 @@ static int ext4_writepage(struct page *page,
 		return __ext4_journalled_writepage(page, wbc, len);
 	}
 
-	if (test_opt(inode->i_sb, NOBH) && ext4_should_writeback_data(inode))
-		ret = nobh_writepage(page, noalloc_get_block_write, wbc);
-	else
-		ret = block_write_full_page(page, noalloc_get_block_write,
-					    wbc);
+	ret = block_write_full_page(page, noalloc_get_block_write, wbc);
 
 	return ret;
 }
@@ -3463,17 +3456,6 @@ int ext4_block_truncate_page(handle_t *handle,
 	length = blocksize - (offset & (blocksize - 1));
 	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
 
-	/*
-	 * For "nobh" option,  we can only work if we don't need to
-	 * read-in the page - otherwise we create buffers to do the IO.
-	 */
-	if (!page_has_buffers(page) && test_opt(inode->i_sb, NOBH) &&
-	     ext4_should_writeback_data(inode) && PageUptodate(page)) {
-		zero_user(page, offset, length);
-		set_page_dirty(page);
-		goto unlock;
-	}
-
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 8f4f079..160051f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -846,8 +846,6 @@ static int ext4_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	seq_puts(seq, test_opt(sb, BARRIER) ? "1" : "0");
 	if (test_opt(sb, JOURNAL_ASYNC_COMMIT))
 		seq_puts(seq, ",journal_async_commit");
-	if (test_opt(sb, NOBH))
-		seq_puts(seq, ",nobh");
 	if (test_opt(sb, I_VERSION))
 		seq_puts(seq, ",i_version");
 	if (!test_opt(sb, DELALLOC))
@@ -2775,11 +2773,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 no_journal:
 
 	if (test_opt(sb, NOBH)) {
-		if (!(test_opt(sb, DATA_FLAGS) == EXT4_MOUNT_WRITEBACK_DATA)) {
-			ext4_msg(sb, KERN_WARNING, "Ignoring nobh option - "
-				"its supported only with writeback mode");
-			clear_opt(sbi->s_mount_opt, NOBH);
-		}
+		ext4_msg(sb, KERN_WARNING, "nobh option is deprecated. "
+					   "Ignoring it.");
+		clear_opt(sbi->s_mount_opt, NOBH);
 	}
 	/*
 	 * The jbd2_journal_load will have done any necessary log recovery,
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
