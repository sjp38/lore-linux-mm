Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1745B44043B
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:36:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t10so42419020qte.14
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:36:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z78si2900805qkg.396.2017.06.16.12.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:36:03 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 20/22] ext2: convert to errseq_t based writeback error tracking
Date: Fri, 16 Jun 2017 15:34:25 -0400
Message-Id: <20170616193427.13955-21-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Set the flag to indicate that we want new-style data writeback error
handling.

This means that we need to override the open routines for files and
directories so that we can sample the bdev wb_err at open.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/ext2/dir.c  |  8 ++++++++
 fs/ext2/file.c | 26 +++++++++++++++++++++-----
 2 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index e2709695b177..6e476c9929f8 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -713,6 +713,13 @@ int ext2_empty_dir (struct inode * inode)
 	return 0;
 }
 
+static int ext2_dir_open(struct inode *inode, struct file *file)
+{
+	/* Sample blockdev mapping errseq_t for metadata writeback */
+	file->f_md_wb_err = filemap_sample_wb_err(inode->i_sb->s_bdev->bd_inode->i_mapping);
+	return 0;
+}
+
 const struct file_operations ext2_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
@@ -721,5 +728,6 @@ const struct file_operations ext2_dir_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
+	.open		= ext2_dir_open,
 	.fsync		= ext2_fsync,
 };
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index ed00e7ae0ef3..fd44539f6fce 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -172,17 +172,23 @@ static int ext2_release_file (struct inode * inode, struct file * filp)
 
 int ext2_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
-	int ret;
+	int ret, ret2;
 	struct super_block *sb = file->f_mapping->host->i_sb;
 	struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
 
 	ret = generic_file_fsync(file, start, end, datasync);
-	if (ret == -EIO) {
+	if (ret == -EIO)
 		/* We don't really know where the IO error happened... */
 		ext2_error(sb, __func__,
 			   "detected IO error when writing metadata buffers");
-		ret = -EIO;
-	}
+
+	ret2 = filemap_report_wb_err(file);
+	if (ret == 0)
+		ret = ret2;
+
+	ret2 = filemap_report_md_wb_err(file, mapping);
+	if (ret == 0)
+		ret = ret2;
 	return ret;
 }
 
@@ -204,6 +210,16 @@ static ssize_t ext2_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	return generic_file_write_iter(iocb, from);
 }
 
+static int ext2_file_open(struct inode *inode, struct file *file)
+{
+	int ret;
+
+	ret = dquot_file_open(inode, file);
+	if (likely(ret == 0))
+		file->f_md_wb_err = filemap_sample_wb_err(inode->i_sb->s_bdev->bd_inode->i_mapping);
+	return ret;
+}
+
 const struct file_operations ext2_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read_iter	= ext2_file_read_iter,
@@ -213,7 +229,7 @@ const struct file_operations ext2_file_operations = {
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
 	.mmap		= ext2_file_mmap,
-	.open		= dquot_file_open,
+	.open		= ext2_file_open,
 	.release	= ext2_release_file,
 	.fsync		= ext2_fsync,
 	.get_unmapped_area = thp_get_unmapped_area,
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
