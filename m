Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F68F6B039F
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m57so42581082qta.9
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y74si8441472qky.95.2017.06.12.05.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:34 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 10/13] ext4: add more robust reporting of metadata writeback errors
Date: Mon, 12 Jun 2017 08:23:02 -0400
Message-Id: <20170612122316.13244-11-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

ext4 uses the blockdev mapping for tracking metadata stored in the
pagecache. Sample its wb_err when opening a file and store that in
the f_md_wb_err field.

Change ext4_sync_file to check for data errors first, and then check the
blockdev mapping for metadata errors afterward.

Note that because metadata writeback errors are only tracked on a
per-device level, this does mean that we'll end up reporting an error on
all open file descriptors when there is a metadata writeback failure.
That's not ideal, but we can possibly improve upon it in the future.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/ext4/dir.c   |  8 ++++++--
 fs/ext4/file.c  |  5 ++++-
 fs/ext4/fsync.c | 13 +++++++++++++
 3 files changed, 23 insertions(+), 3 deletions(-)

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
index 831fd6beebf0..fe0d6e01c4b7 100644
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
index 03d6259d8662..36363a6730d7 100644
--- a/fs/ext4/fsync.c
+++ b/fs/ext4/fsync.c
@@ -165,6 +165,19 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	err = filemap_report_wb_err(file);
 	if (!ret)
 		ret = err;
+
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
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
