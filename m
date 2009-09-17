Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 834966B005A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:21:45 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 5/7] ext4: Convert filesystem to the new truncate calling convention
Date: Thu, 17 Sep 2009 17:21:45 +0200
Message-Id: <1253200907-31392-6-git-send-email-jack@suse.cz>
In-Reply-To: <1253200907-31392-1-git-send-email-jack@suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, Jan Kara <jack@suse.cz>, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

CC: linux-ext4@vger.kernel.org
CC: tytso@mit.edu
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/file.c  |    2 +-
 fs/ext4/inode.c |  166 ++++++++++++++++++++++++++++++++----------------------
 2 files changed, 99 insertions(+), 69 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 3f1873f..22f49d7 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -198,7 +198,7 @@ const struct file_operations ext4_file_operations = {
 };
 
 const struct inode_operations ext4_file_inode_operations = {
-	.truncate	= ext4_truncate,
+	.new_truncate	= 1,
 	.setattr	= ext4_setattr,
 	.getattr	= ext4_getattr,
 #ifdef CONFIG_EXT4_FS_XATTR
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 58492ab..be25874 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3354,6 +3354,7 @@ static int ext4_journalled_set_page_dirty(struct page *page)
 }
 
 static const struct address_space_operations ext4_ordered_aops = {
+	.new_writepage		= 1,
 	.readpage		= ext4_readpage,
 	.readpages		= ext4_readpages,
 	.writepage		= ext4_writepage,
@@ -3369,6 +3370,7 @@ static const struct address_space_operations ext4_ordered_aops = {
 };
 
 static const struct address_space_operations ext4_writeback_aops = {
+	.new_writepage		= 1,
 	.readpage		= ext4_readpage,
 	.readpages		= ext4_readpages,
 	.writepage		= ext4_writepage,
@@ -3384,6 +3386,7 @@ static const struct address_space_operations ext4_writeback_aops = {
 };
 
 static const struct address_space_operations ext4_journalled_aops = {
+	.new_writepage		= 1,
 	.readpage		= ext4_readpage,
 	.readpages		= ext4_readpages,
 	.writepage		= ext4_writepage,
@@ -3398,6 +3401,7 @@ static const struct address_space_operations ext4_journalled_aops = {
 };
 
 static const struct address_space_operations ext4_da_aops = {
+	.new_writepage		= 1,
 	.readpage		= ext4_readpage,
 	.readpages		= ext4_readpages,
 	.writepage		= ext4_writepage,
@@ -4682,28 +4686,97 @@ int ext4_write_inode(struct inode *inode, int wait)
 }
 
 /*
- * ext4_setattr()
+ * ext4_setsize()
+ *
+ * This is a helper for ext4_setattr(). It sets i_size, truncates page cache
+ * and truncates inode blocks if they are over i_size.
  *
- * Called from notify_change.
+ * We take care of updating i_disksize and adding inode to the orphan list.
+ * That makes sure that we can guarantee that any commit will leave the blocks
+ * being truncated in an unused state on disk.  (On recovery, the inode will
+ * get truncated and the blocks will be freed, so we have a strong guarantee
+ * that no future commit will leave these blocks visible to the user.)
  *
- * We want to trap VFS attempts to truncate the file as soon as
- * possible.  In particular, we want to make sure that when the VFS
- * shrinks i_size, we put the inode on the orphan list and modify
- * i_disksize immediately, so that during the subsequent flushing of
- * dirty pages and freeing of disk blocks, we can guarantee that any
- * commit will leave the blocks being flushed in an unused state on
- * disk.  (On recovery, the inode will get truncated and the blocks will
- * be freed, so we have a strong guarantee that no future commit will
- * leave these blocks visible to the user.)
+ * Another thing we have to assure is that if we are in ordered mode and inode
+ * is still attached to the committing transaction, we must we start writeout
+ * of all the dirty pages which are being truncated.  This way we are sure that
+ * all the data written in the previous transaction are already on disk
+ * (truncate waits for pages under writeback).
+ */
+static int ext4_setsize(struct inode *inode, loff_t newsize)
+{
+	int error = 0, rc;
+	loff_t oldsize = inode->i_size;
+	handle_t *handle;
+
+	error = inode_newsize_ok(inode, newsize);
+	if (error)
+		goto out;
+	/* VFS should have checked these and return error... */
+	WARN_ON(!S_ISREG(inode->i_mode) || IS_APPEND(inode) ||
+		IS_IMMUTABLE(inode));
+
+	if (newsize < oldsize) {
+		handle = ext4_journal_start(inode, 3);
+		if (IS_ERR(handle)) {
+			error = PTR_ERR(handle);
+			goto err_out;
+		}
+
+		error = ext4_orphan_add(handle, inode);
+		EXT4_I(inode)->i_disksize = newsize;
+		rc = ext4_mark_inode_dirty(handle, inode);
+		if (!error)
+			error = rc;
+		ext4_journal_stop(handle);
+
+		if (ext4_should_order_data(inode)) {
+			error = ext4_begin_ordered_truncate(inode, newsize);
+			if (error) {
+				/* Do as much error cleanup as possible */
+				handle = ext4_journal_start(inode, 3);
+				if (IS_ERR(handle)) {
+					ext4_orphan_del(NULL, inode);
+					goto err_out;
+				}
+				ext4_orphan_del(handle, inode);
+				ext4_journal_stop(handle);
+				goto err_out;
+			}
+		}
+	} else if (!(EXT4_I(inode)->i_flags & EXT4_EXTENTS_FL)) {
+		struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
+
+		if (newsize > sbi->s_bitmap_maxbytes) {
+			error = -EFBIG;
+			goto out;
+		}
+	}
+
+	i_size_write(inode, newsize);
+	truncate_pagecache(inode, oldsize, newsize);
+	ext4_truncate(inode);
+
+	/*
+	 * If we failed to get a transaction handle at all, we need to clean up
+         * the in-core orphan list manually.
+	 */
+	if (inode->i_nlink)
+		ext4_orphan_del(NULL, inode);
+err_out:
+	ext4_std_error(inode->i_sb, error);
+out:
+	return error;
+}
+
+
+/*
+ * ext4_setattr()
  *
- * Another thing we have to assure is that if we are in ordered mode
- * and inode is still attached to the committing transaction, we must
- * we start writeout of all the dirty pages which are being truncated.
- * This way we are sure that all the data written in the previous
- * transaction are already on disk (truncate waits for pages under
- * writeback).
+ * Handle special things ext4 needs for changing owner of the file, changing
+ * ACLs, or truncating file.
  *
- * Called with inode->i_mutex down.
+ * Called from notify_change with inode->i_mutex down.
  */
 int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 {
@@ -4743,61 +4816,18 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	}
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		if (!(EXT4_I(inode)->i_flags & EXT4_EXTENTS_FL)) {
-			struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
-
-			if (attr->ia_size > sbi->s_bitmap_maxbytes) {
-				error = -EFBIG;
-				goto err_out;
-			}
-		}
-	}
-
-	if (S_ISREG(inode->i_mode) &&
-	    attr->ia_valid & ATTR_SIZE && attr->ia_size < inode->i_size) {
-		handle_t *handle;
-
-		handle = ext4_journal_start(inode, 3);
-		if (IS_ERR(handle)) {
-			error = PTR_ERR(handle);
-			goto err_out;
-		}
-
-		error = ext4_orphan_add(handle, inode);
-		EXT4_I(inode)->i_disksize = attr->ia_size;
-		rc = ext4_mark_inode_dirty(handle, inode);
-		if (!error)
-			error = rc;
-		ext4_journal_stop(handle);
-
-		if (ext4_should_order_data(inode)) {
-			error = ext4_begin_ordered_truncate(inode,
-							    attr->ia_size);
-			if (error) {
-				/* Do as much error cleanup as possible */
-				handle = ext4_journal_start(inode, 3);
-				if (IS_ERR(handle)) {
-					ext4_orphan_del(NULL, inode);
-					goto err_out;
-				}
-				ext4_orphan_del(handle, inode);
-				ext4_journal_stop(handle);
-				goto err_out;
-			}
-		}
+		error = ext4_setsize(inode, attr->ia_size);
+		if (error)
+			return error;
 	}
 
-	rc = inode_setattr(inode, attr);
-
-	/* If inode_setattr's call to ext4_truncate failed to get a
-	 * transaction handle at all, we need to clean up the in-core
-	 * orphan list manually. */
-	if (inode->i_nlink)
-		ext4_orphan_del(NULL, inode);
+	generic_setattr(inode, attr);
 
-	if (!rc && (ia_valid & ATTR_MODE))
+	if (ia_valid & ATTR_MODE)
 		rc = ext4_acl_chmod(inode);
 
+	/* Mark inode dirty due to changes done by generic_setattr() */
+	mark_inode_dirty(inode);
 err_out:
 	ext4_std_error(inode->i_sb, error);
 	if (!error)
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
