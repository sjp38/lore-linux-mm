Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id F16726B0142
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 06:12:04 -0400 (EDT)
Received: by mail-ea0-f172.google.com with SMTP id z7so1671968eaf.31
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 03:12:03 -0700 (PDT)
Message-ID: <515FF344.8040705@gmail.com>
Date: Sat, 06 Apr 2013 12:04:52 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/4] fsfreeze: manage kill signal when sb_start_write is called
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: Chris Mason <chris.mason@fusionio.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Miklos Szeredi <miklos@szeredi.hu>, Alexander Viro <viro@zeniv.linux.org.uk>, Anton Altaparmakov <anton@tuxera.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>, Alex Elder <elder@kernel.org>, xfs@oss.sgi.com, Matthew Wilcox <matthew@wil.cx>, Marco Stornelli <marco.stornelli@gmail.com>, Mike Snitzer <snitzer@redhat.com>, Alasdair G Kergon <agk@redhat.com>, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-ext4@vger.kernel.org, fuse-devel@lists.sourceforge.net, linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

In every place where sb_start_write was called now we must manage
the error code and return -EINTR.

Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
---
 fs/btrfs/file.c    |    9 +++++++--
 fs/cifs/file.c     |    4 +++-
 fs/ext4/mmp.c      |    3 ++-
 fs/ext4/super.c    |    4 +++-
 fs/fuse/file.c     |    4 +++-
 fs/namespace.c     |    8 ++++++--
 fs/ntfs/file.c     |    4 +++-
 fs/ocfs2/file.c    |    4 +++-
 fs/open.c          |    8 ++++++--
 fs/splice.c        |    4 +++-
 fs/xfs/xfs_file.c  |    4 +++-
 include/linux/fs.h |    6 ++++--
 mm/filemap.c       |    4 +++-
 mm/filemap_xip.c   |    4 +++-
 14 files changed, 52 insertions(+), 18 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index ade03e6..4891fda 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -329,7 +329,9 @@ static int __btrfs_run_defrag_inode(struct btrfs_fs_info *fs_info,
 	range.len = (u64)-1;
 	range.start = defrag->last_offset;
 
-	sb_start_write(fs_info->sb);
+	ret = sb_start_write(fs_info->sb);
+	if (ret)
+		goto cleanup;
 	num_defrag = btrfs_defrag_file(inode, NULL, &range, defrag->transid,
 				       BTRFS_DEFRAG_BATCH);
 	sb_end_write(fs_info->sb);
@@ -1514,7 +1516,9 @@ static ssize_t btrfs_file_aio_write(struct kiocb *iocb,
 	size_t count, ocount;
 	bool sync = (file->f_flags & O_DSYNC) || IS_SYNC(file->f_mapping->host);
 
-	sb_start_write(inode->i_sb);
+	err = sb_start_write(inode->i_sb);
+	if (err)
+		goto out2;
 
 	mutex_lock(&inode->i_mutex);
 
@@ -1618,6 +1622,7 @@ static ssize_t btrfs_file_aio_write(struct kiocb *iocb,
 		atomic_dec(&BTRFS_I(inode)->sync_writers);
 out:
 	sb_end_write(inode->i_sb);
+out2:
 	current->backing_dev_info = NULL;
 	return num_written ? num_written : err;
 }
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 7a0dd99..1613eb9 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2520,7 +2520,9 @@ cifs_writev(struct kiocb *iocb, const struct iovec *iov,
 
 	BUG_ON(iocb->ki_pos != pos);
 
-	sb_start_write(inode->i_sb);
+	rc = sb_start_write(inode->i_sb);
+	if (rc)
+		return rc;
 
 	/*
 	 * We need to hold the sem to be sure nobody modifies lock list
diff --git a/fs/ext4/mmp.c b/fs/ext4/mmp.c
index f9b5515..dbdfc6d 100644
--- a/fs/ext4/mmp.c
+++ b/fs/ext4/mmp.c
@@ -48,7 +48,8 @@ static int write_mmp_block(struct super_block *sb, struct buffer_head *bh)
 	 * We protect against freezing so that we don't create dirty buffers
 	 * on frozen filesystem.
 	 */
-	sb_start_write(sb);
+	if (sb_start_write(sb))
+		return 1;
 	ext4_mmp_csum_set(sb, mmp);
 	mark_buffer_dirty(bh);
 	lock_buffer(bh);
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 5d6d535..e6962be 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -2712,7 +2712,9 @@ static int ext4_run_li_request(struct ext4_li_request *elr)
 	sb = elr->lr_super;
 	ngroups = EXT4_SB(sb)->s_groups_count;
 
-	sb_start_write(sb);
+	ret = sb_start_write(sb);
+	if (ret)
+		return 1;
 	for (group = elr->lr_next_group; group < ngroups; group++) {
 		gdp = ext4_get_group_desc(sb, group, NULL);
 		if (!gdp) {
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 34b80ba..57194eb 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -971,7 +971,9 @@ static ssize_t fuse_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
 		return err;
 
 	count = ocount;
-	sb_start_write(inode->i_sb);
+	err = sb_start_write(inode->i_sb);
+	if (err)
+		return err;
 	mutex_lock(&inode->i_mutex);
 
 	/* We can write back this queue in page reclaim */
diff --git a/fs/namespace.c b/fs/namespace.c
index d581e45..2d2b054 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -343,7 +343,9 @@ int mnt_want_write(struct vfsmount *m)
 {
 	int ret;
 
-	sb_start_write(m->mnt_sb);
+	ret = sb_start_write(m->mnt_sb);
+	if (ret)
+		return ret;
 	ret = __mnt_want_write(m);
 	if (ret)
 		sb_end_write(m->mnt_sb);
@@ -403,7 +405,9 @@ int mnt_want_write_file(struct file *file)
 {
 	int ret;
 
-	sb_start_write(file->f_path.mnt->mnt_sb);
+	ret = sb_start_write(file->f_path.mnt->mnt_sb);
+	if (ret)
+		return ret;
 	ret = __mnt_want_write_file(file);
 	if (ret)
 		sb_end_write(file->f_path.mnt->mnt_sb);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 5b2d4f0..a414c53 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -2129,7 +2129,9 @@ static ssize_t ntfs_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
 
 	BUG_ON(iocb->ki_pos != pos);
 
-	sb_start_write(inode->i_sb);
+	ret = sb_start_write(inode->i_sb);
+	if (ret)
+		return ret;
 	mutex_lock(&inode->i_mutex);
 	ret = ntfs_file_aio_write_nolock(iocb, iov, nr_segs, &iocb->ki_pos);
 	mutex_unlock(&inode->i_mutex);
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 6474cb4..8b68176 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2248,7 +2248,9 @@ static ssize_t ocfs2_file_aio_write(struct kiocb *iocb,
 	if (iocb->ki_left == 0)
 		return 0;
 
-	sb_start_write(inode->i_sb);
+	ret = sb_start_write(inode->i_sb);
+	if (ret)
+		return ret;
 
 	appending = file->f_flags & O_APPEND ? 1 : 0;
 	direct_io = file->f_flags & O_DIRECT ? 1 : 0;
diff --git a/fs/open.c b/fs/open.c
index 6835446..4589d88 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -182,7 +182,9 @@ static long do_sys_ftruncate(unsigned int fd, loff_t length, int small)
 	if (IS_APPEND(inode))
 		goto out_putf;
 
-	sb_start_write(inode->i_sb);
+	error = sb_start_write(inode->i_sb);
+	if (error)
+		goto out_putf;
 	error = locks_verify_truncate(inode, f.file, length);
 	if (!error)
 		error = security_path_truncate(&f.file->f_path);
@@ -293,7 +295,9 @@ int do_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 	if (!file->f_op->fallocate)
 		return -EOPNOTSUPP;
 
-	sb_start_write(inode->i_sb);
+	ret = sb_start_write(inode->i_sb);
+	if (ret)
+		return ret;
 	ret = file->f_op->fallocate(file, mode, offset, len);
 	sb_end_write(inode->i_sb);
 	return ret;
diff --git a/fs/splice.c b/fs/splice.c
index 29e394e..4b5c365 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1000,7 +1000,9 @@ generic_file_splice_write(struct pipe_inode_info *pipe, struct file *out,
 	};
 	ssize_t ret;
 
-	sb_start_write(inode->i_sb);
+	ret = sb_start_write(inode->i_sb);
+	if (ret)
+		return ret;
 
 	pipe_lock(pipe);
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index f03bf1a..6ba4c0d 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -775,7 +775,9 @@ xfs_file_aio_write(
 	if (ocount == 0)
 		return 0;
 
-	sb_start_write(inode->i_sb);
+	ret = sb_start_write(inode->i_sb);
+	if (ret)
+		return ret;
 
 	if (XFS_FORCED_SHUTDOWN(ip->i_mount)) {
 		ret = -EIO;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2bfb88d..03921d6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1376,6 +1376,8 @@ static inline void sb_end_intwrite(struct super_block *sb)
  * sb_start_write - get write access to a superblock
  * @sb: the super we write to
  *
+ * It returns zero when no error occured, the error code otherwise.
+ *
  * When a process wants to write data or metadata to a file system (i.e. dirty
  * a page or an inode), it should embed the operation in a sb_start_write() -
  * sb_end_write() pair to get exclusion against file system freezing. This
@@ -1391,9 +1393,9 @@ static inline void sb_end_intwrite(struct super_block *sb)
  *   -> i_mutex			(write path, truncate, directory ops, ...)
  *   -> s_umount		(freeze_super, thaw_super)
  */
-static inline void sb_start_write(struct super_block *sb)
+static inline int sb_start_write(struct super_block *sb)
 {
-	__sb_start_write_wait(sb, SB_FREEZE_WRITE, false);
+	return __sb_start_write_wait(sb, SB_FREEZE_WRITE, true);
 }
 
 static inline int sb_start_write_trylock(struct super_block *sb)
diff --git a/mm/filemap.c b/mm/filemap.c
index e1979fd..b238671 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2528,7 +2528,9 @@ ssize_t generic_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
 
 	BUG_ON(iocb->ki_pos != pos);
 
-	sb_start_write(inode->i_sb);
+	ret = sb_start_write(inode->i_sb);
+	if (ret)
+		return ret;
 	mutex_lock(&inode->i_mutex);
 	ret = __generic_file_aio_write(iocb, iov, nr_segs, &iocb->ki_pos);
 	mutex_unlock(&inode->i_mutex);
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index a912da6..4cde643 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -404,7 +404,9 @@ xip_file_write(struct file *filp, const char __user *buf, size_t len,
 	loff_t pos;
 	ssize_t ret;
 
-	sb_start_write(inode->i_sb);
+	ret = sb_start_write(inode->i_sb);
+	if (ret)
+		return ret;
 
 	mutex_lock(&inode->i_mutex);
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
