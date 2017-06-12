Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61C5E6B03AB
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x58so42682407qtc.0
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x30si8885057qte.171.2017.06.12.05.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:51 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 18/20] ext4: use errseq_t based error handling for reporting data writeback errors
Date: Mon, 12 Jun 2017 08:23:14 -0400
Message-Id: <20170612122316.13244-23-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Add the FS_WB_ERRSEQ flag to indicate to other subsystems that errseq_t
based error reporting for data writeback is in effect, and to opt-in to
reporting those errors in call_fsync.

ext4 uses the blockdev mapping for tracking metadata stored in the
pagecache. Sample its wb_err when opening a file and store that in
the f_md_wb_err field. Ensure that we check and advance the metadata
before returning in fsync.

Note that because metadata writeback errors are only tracked on a
per-device level, this does mean that we'll end up reporting an error on
all open file descriptors on this fs when there is a metadata writeback
failure.  That's not ideal, but we can possibly improve upon it in the
future.

ext4 also has several calls to filemap_fdatawait and
filemap_write_and_wait. Those will also be changed in a later patch to
versions that use errseq_t based reporting.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/ext4/dir.c   |  8 ++++++--
 fs/ext4/file.c  |  5 ++++-
 fs/ext4/fsync.c | 23 +++++++++++++++++++----
 fs/ext4/super.c |  6 +++---
 4 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index e8b365000d73..6bbb19510f74 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -611,9 +611,13 @@ static int ext4_dx_readdir(struct file *file, struct dir_context *ctx)
 
 static int ext4_dir_open(struct inode * inode, struct file * filp)
 {
+	int ret = 0;
+
 	if (ext4_encrypted_inode(inode))
-		return fscrypt_get_encryption_info(inode) ? -EACCES : 0;
-	return 0;
+		ret = fscrypt_get_encryption_info(inode) ? -EACCES : 0;
+	if (!ret)
+		filp->f_md_wb_err = filemap_sample_wb_err(inode->i_sb->s_bdev->bd_inode->i_mapping);
+	return ret;
 }
 
 static int ext4_release_dir(struct inode *inode, struct file *filp)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 02ce7e7bbdf5..6e505269132c 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -435,7 +435,10 @@ static int ext4_file_open(struct inode * inode, struct file * filp)
 		if (ret < 0)
 			return ret;
 	}
-	return dquot_file_open(inode, filp);
+	ret = dquot_file_open(inode, filp);
+	if (!ret)
+		filp->f_md_wb_err = filemap_sample_wb_err(sb->s_bdev->bd_inode->i_mapping);
+	return ret;
 }
 
 /*
diff --git a/fs/ext4/fsync.c b/fs/ext4/fsync.c
index 9d549608fd30..09e28b7fd3f6 100644
--- a/fs/ext4/fsync.c
+++ b/fs/ext4/fsync.c
@@ -100,8 +100,10 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	tid_t commit_tid;
 	bool needs_barrier = false;
 
-	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb))))
-		return -EIO;
+	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb)))) {
+		ret = -EIO;
+		goto out;
+	}
 
 	J_ASSERT(ext4_journal_current_handle() == NULL);
 
@@ -126,7 +128,8 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 
 	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 	if (ret)
-		return ret;
+		goto out;
+
 	/*
 	 * data=writeback,ordered:
 	 *  The caller's filemap_fdatawrite()/wait will sync the data.
@@ -152,12 +155,24 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 		needs_barrier = true;
 	ret = jbd2_complete_transaction(journal, commit_tid);
 	if (needs_barrier) {
-	issue_flush:
+issue_flush:
 		err = blkdev_issue_flush(inode->i_sb->s_bdev, GFP_KERNEL, NULL);
 		if (!ret)
 			ret = err;
 	}
 out:
+	/*
+	 * Was there a metadata writeback error since last fsync?
+	 *
+	 * FIXME: ext4 tracks metadata with a whole-block device mapping. So,
+	 * if there is any sort of metadata writeback error, we'll report an
+	 * error on all open fds, even ones not associated with the inode
+	 */
+	err = filemap_report_md_wb_err(file,
+				inode->i_sb->s_bdev->bd_inode->i_mapping);
+	if (!ret)
+		ret = err;
+
 	trace_ext4_sync_file_exit(inode, ret);
 	return ret;
 }
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d37c81f327e7..e98791ebee6f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -119,7 +119,7 @@ static struct file_system_type ext2_fs_type = {
 	.name		= "ext2",
 	.mount		= ext4_mount,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV|FS_WB_ERRSEQ,
 };
 MODULE_ALIAS_FS("ext2");
 MODULE_ALIAS("ext2");
@@ -134,7 +134,7 @@ static struct file_system_type ext3_fs_type = {
 	.name		= "ext3",
 	.mount		= ext4_mount,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV|FS_WB_ERRSEQ,
 };
 MODULE_ALIAS_FS("ext3");
 MODULE_ALIAS("ext3");
@@ -5689,7 +5689,7 @@ static struct file_system_type ext4_fs_type = {
 	.name		= "ext4",
 	.mount		= ext4_mount,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV|FS_WB_ERRSEQ,
 };
 MODULE_ALIAS_FS("ext4");
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
