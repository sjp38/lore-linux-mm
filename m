Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id C4CC46B003A
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:45:06 -0400 (EDT)
Subject: [PATCH 07/16] fuse: Trust kernel i_mtime only
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:44:53 +0400
Message-ID: <20130629174446.20175.25189.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

Let the kernel maintain i_mtime locally:
 - clear S_NOCMTIME
 - implement i_op->update_time()
 - flush mtime on fsync and last close
 - update i_mtime explicitly on truncate and fallocate

Fuse inode flag FUSE_I_MTIME_UPDATED serves as indication that local i_mtime
should be flushed to the server eventually. Some operations (direct write,
truncate, fallocate and setattr) leads to updating mtime on server. So, we can
clear FUSE_I_MTIME_UPDATED when such an operation is completed. This is safe
because these operations (as well as i_op->update_time and fsync) are
protected by i_mutex.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/dir.c    |  116 ++++++++++++++++++++++++++++++++++++++++++++++++------
 fs/fuse/file.c   |   38 +++++++++++++++---
 fs/fuse/fuse_i.h |    6 ++-
 fs/fuse/inode.c  |   13 +++++-
 4 files changed, 151 insertions(+), 22 deletions(-)

diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index b755884..cd67a0c 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -854,8 +854,11 @@ static void fuse_fillattr(struct inode *inode, struct fuse_attr *attr,
 	struct fuse_conn *fc = get_fuse_conn(inode);
 
 	/* see the comment in fuse_change_attributes() */
-	if (fc->writeback_cache && S_ISREG(inode->i_mode))
+	if (fc->writeback_cache && S_ISREG(inode->i_mode)) {
 		attr->size = i_size_read(inode);
+		attr->mtime = inode->i_mtime.tv_sec;
+		attr->mtimensec = inode->i_mtime.tv_nsec;
+	}
 
 	stat->dev = inode->i_sb->s_dev;
 	stat->ino = attr->ino;
@@ -1565,6 +1568,89 @@ void fuse_release_nowrite(struct inode *inode)
 	spin_unlock(&fc->lock);
 }
 
+static void fuse_setattr_fill(struct fuse_conn *fc, struct fuse_req *req,
+			      struct inode *inode,
+			      struct fuse_setattr_in *inarg_p,
+			      struct fuse_attr_out *outarg_p)
+{
+	req->in.h.opcode = FUSE_SETATTR;
+	req->in.h.nodeid = get_node_id(inode);
+	req->in.numargs = 1;
+	req->in.args[0].size = sizeof(*inarg_p);
+	req->in.args[0].value = inarg_p;
+	req->out.numargs = 1;
+	if (fc->minor < 9)
+		req->out.args[0].size = FUSE_COMPAT_ATTR_OUT_SIZE;
+	else
+		req->out.args[0].size = sizeof(*outarg_p);
+	req->out.args[0].value = outarg_p;
+}
+
+/*
+ * Flush inode->i_mtime to the server
+ */
+int fuse_flush_mtime(struct file *file, bool nofail)
+{
+	struct inode *inode = file->f_mapping->host;
+	struct fuse_inode *fi = get_fuse_inode(inode);
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_req *req = NULL;
+	struct fuse_setattr_in inarg;
+	struct fuse_attr_out outarg;
+	int err;
+
+	if (nofail) {
+		req = fuse_get_req_nofail_nopages(fc, file);
+	} else {
+		req = fuse_get_req_nopages(fc);
+		if (IS_ERR(req))
+			return PTR_ERR(req);
+	}
+
+	memset(&inarg, 0, sizeof(inarg));
+	memset(&outarg, 0, sizeof(outarg));
+
+	inarg.valid |= FATTR_MTIME;
+	inarg.mtime = inode->i_mtime.tv_sec;
+	inarg.mtimensec = inode->i_mtime.tv_nsec;
+
+	fuse_setattr_fill(fc, req, inode, &inarg, &outarg);
+	fuse_request_send(fc, req);
+	err = req->out.h.error;
+	fuse_put_request(fc, req);
+
+	if (!err)
+		clear_bit(FUSE_I_MTIME_UPDATED, &fi->state);
+
+	return err;
+}
+
+static inline void set_mtime_helper(struct inode *inode, struct timespec mtime)
+{
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	inode->i_mtime = mtime;
+	clear_bit(FUSE_I_MTIME_UPDATED, &fi->state);
+}
+
+/*
+ * S_NOCMTIME is clear, so we need to update inode->i_mtime manually. But
+ * we can also clear FUSE_I_MTIME_UPDATED if FUSE_SETATTR has just changed
+ * mtime on server.
+ */
+static void fuse_set_mtime_local(struct iattr *iattr, struct inode *inode)
+{
+	unsigned ivalid = iattr->ia_valid;
+
+	if ((ivalid & ATTR_MTIME) && update_mtime(ivalid)) {
+		if (ivalid & ATTR_MTIME_SET)
+			set_mtime_helper(inode, iattr->ia_mtime);
+		else
+			set_mtime_helper(inode, current_fs_time(inode->i_sb));
+	} else if (ivalid & ATTR_SIZE)
+		set_mtime_helper(inode, current_fs_time(inode->i_sb));
+}
+
 /*
  * Set attributes, and at the same time refresh them.
  *
@@ -1621,17 +1707,7 @@ int fuse_do_setattr(struct inode *inode, struct iattr *attr,
 		inarg.valid |= FATTR_LOCKOWNER;
 		inarg.lock_owner = fuse_lock_owner_id(fc, current->files);
 	}
-	req->in.h.opcode = FUSE_SETATTR;
-	req->in.h.nodeid = get_node_id(inode);
-	req->in.numargs = 1;
-	req->in.args[0].size = sizeof(inarg);
-	req->in.args[0].value = &inarg;
-	req->out.numargs = 1;
-	if (fc->minor < 9)
-		req->out.args[0].size = FUSE_COMPAT_ATTR_OUT_SIZE;
-	else
-		req->out.args[0].size = sizeof(outarg);
-	req->out.args[0].value = &outarg;
+	fuse_setattr_fill(fc, req, inode, &inarg, &outarg);
 	fuse_request_send(fc, req);
 	err = req->out.h.error;
 	fuse_put_request(fc, req);
@@ -1648,6 +1724,10 @@ int fuse_do_setattr(struct inode *inode, struct iattr *attr,
 	}
 
 	spin_lock(&fc->lock);
+	/* the kernel maintains i_mtime locally */
+	if (fc->writeback_cache && S_ISREG(inode->i_mode))
+		fuse_set_mtime_local(attr, inode);
+
 	fuse_change_attributes_common(inode, &outarg.attr,
 				      attr_timeout(&outarg));
 	oldsize = inode->i_size;
@@ -1872,6 +1952,17 @@ static int fuse_removexattr(struct dentry *entry, const char *name)
 	return err;
 }
 
+static int fuse_update_time(struct inode *inode, struct timespec *now,
+			    int flags)
+{
+	if (flags & S_MTIME) {
+		inode->i_mtime = *now;
+		set_bit(FUSE_I_MTIME_UPDATED, &get_fuse_inode(inode)->state);
+		BUG_ON(!S_ISREG(inode->i_mode));
+	}
+	return 0;
+}
+
 static const struct inode_operations fuse_dir_inode_operations = {
 	.lookup		= fuse_lookup,
 	.mkdir		= fuse_mkdir,
@@ -1911,6 +2002,7 @@ static const struct inode_operations fuse_common_inode_operations = {
 	.getxattr	= fuse_getxattr,
 	.listxattr	= fuse_listxattr,
 	.removexattr	= fuse_removexattr,
+	.update_time	= fuse_update_time,
 };
 
 static const struct inode_operations fuse_symlink_inode_operations = {
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 98bc0d0..f53697c 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -291,6 +291,10 @@ static int fuse_open(struct inode *inode, struct file *file)
 
 static int fuse_release(struct inode *inode, struct file *file)
 {
+	if (test_bit(FUSE_I_MTIME_UPDATED,
+		     &get_fuse_inode(inode)->state))
+		fuse_flush_mtime(file, true);
+
 	fuse_release_common(file, FUSE_RELEASE);
 
 	/* return value is ignored by VFS */
@@ -458,6 +462,13 @@ int fuse_fsync_common(struct file *file, loff_t start, loff_t end,
 
 	fuse_sync_writes(inode);
 
+	if (test_bit(FUSE_I_MTIME_UPDATED,
+		     &get_fuse_inode(inode)->state)) {
+		int err = fuse_flush_mtime(file, false);
+		if (err)
+			goto out;
+	}
+
 	req = fuse_get_req_nopages(fc);
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
@@ -948,16 +959,21 @@ static size_t fuse_send_write(struct fuse_req *req, struct fuse_io_priv *io,
 	return req->misc.write.out.size;
 }
 
-void fuse_write_update_size(struct inode *inode, loff_t pos)
+bool fuse_write_update_size(struct inode *inode, loff_t pos)
 {
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	struct fuse_inode *fi = get_fuse_inode(inode);
+	bool ret = false;
 
 	spin_lock(&fc->lock);
 	fi->attr_version = ++fc->attr_version;
-	if (pos > inode->i_size)
+	if (pos > inode->i_size) {
 		i_size_write(inode, pos);
+		ret = true;
+	}
 	spin_unlock(&fc->lock);
+
+	return ret;
 }
 
 static size_t fuse_send_write_pages(struct fuse_req *req, struct file *file,
@@ -2495,9 +2511,11 @@ fuse_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 	}
 
 	if (rw == WRITE) {
-		if (ret > 0)
+		if (ret > 0) {
+			struct fuse_inode *fi = get_fuse_inode(inode);
 			fuse_write_update_size(inode, pos);
-		else if (ret < 0 && offset + count > i_size)
+			clear_bit(FUSE_I_MTIME_UPDATED, &fi->state);
+		} else if (ret < 0 && offset + count > i_size)
 			fuse_do_truncate(file);
 	}
 
@@ -2553,8 +2571,16 @@ static long fuse_file_fallocate(struct file *file, int mode, loff_t offset,
 		goto out;
 
 	/* we could have extended the file */
-	if (!(mode & FALLOC_FL_KEEP_SIZE))
-		fuse_write_update_size(inode, offset + length);
+	if (!(mode & FALLOC_FL_KEEP_SIZE)) {
+		bool changed = fuse_write_update_size(inode, offset + length);
+
+		if (changed && fc->writeback_cache) {
+			struct fuse_inode *fi = get_fuse_inode(inode);
+
+			inode->i_mtime = current_fs_time(inode->i_sb);
+			clear_bit(FUSE_I_MTIME_UPDATED, &fi->state);
+		}
+	}
 
 	if (mode & FALLOC_FL_PUNCH_HOLE)
 		truncate_pagecache_range(inode, offset, offset + length - 1);
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index a0062a0..82abb82 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -115,6 +115,8 @@ struct fuse_inode {
 enum {
 	/** Advise readdirplus  */
 	FUSE_I_ADVISE_RDPLUS,
+	/** i_mtime has been updated locally; a flush to userspace needed */
+	FUSE_I_MTIME_UPDATED,
 };
 
 struct fuse_conn;
@@ -867,7 +869,9 @@ long fuse_ioctl_common(struct file *file, unsigned int cmd,
 unsigned fuse_file_poll(struct file *file, poll_table *wait);
 int fuse_dev_release(struct inode *inode, struct file *file);
 
-void fuse_write_update_size(struct inode *inode, loff_t pos);
+bool fuse_write_update_size(struct inode *inode, loff_t pos);
+
+int fuse_flush_mtime(struct file *file, bool nofail);
 
 int fuse_do_setattr(struct inode *inode, struct iattr *attr,
 		    struct file *file);
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 121638d..591b46c 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -170,8 +170,11 @@ void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 	inode->i_blocks  = attr->blocks;
 	inode->i_atime.tv_sec   = attr->atime;
 	inode->i_atime.tv_nsec  = attr->atimensec;
-	inode->i_mtime.tv_sec   = attr->mtime;
-	inode->i_mtime.tv_nsec  = attr->mtimensec;
+	/* mtime from server may be stale due to local buffered write */
+	if (!fc->writeback_cache || !S_ISREG(inode->i_mode)) {
+		inode->i_mtime.tv_sec   = attr->mtime;
+		inode->i_mtime.tv_nsec  = attr->mtimensec;
+	}
 	inode->i_ctime.tv_sec   = attr->ctime;
 	inode->i_ctime.tv_nsec  = attr->ctimensec;
 
@@ -249,6 +252,8 @@ static void fuse_init_inode(struct inode *inode, struct fuse_attr *attr)
 {
 	inode->i_mode = attr->mode & S_IFMT;
 	inode->i_size = attr->size;
+	inode->i_mtime.tv_sec  = attr->mtime;
+	inode->i_mtime.tv_nsec = attr->mtimensec;
 	if (S_ISREG(inode->i_mode)) {
 		fuse_init_common(inode);
 		fuse_init_file_inode(inode);
@@ -295,7 +300,9 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
 		return NULL;
 
 	if ((inode->i_state & I_NEW)) {
-		inode->i_flags |= S_NOATIME|S_NOCMTIME;
+		inode->i_flags |= S_NOATIME;
+		if (!fc->writeback_cache)
+			inode->i_flags |= S_NOCMTIME;
 		inode->i_generation = generation;
 		inode->i_data.backing_dev_info = &fc->bdi;
 		fuse_init_inode(inode, attr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
