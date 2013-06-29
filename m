Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 2A7FD6B0068
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:47:14 -0400 (EDT)
Subject: [PATCH 15/16] fuse: Turn writeback cache on
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:47:01 +0400
Message-ID: <20130629174654.20175.80011.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

From: Pavel Emelyanov <xemul@openvz.org>

Introduce a bit kernel and userspace exchange between each-other on
the init stage and turn writeback on if the userspace want this and
mount option 'allow_wbcache' is present (controlled by fusermount).

Also add each writable file into per-inode write list and call the
generic_file_aio_write to make use of the Linux page cache engine.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/file.c            |    5 +++++
 fs/fuse/fuse_i.h          |    4 ++++
 fs/fuse/inode.c           |   13 +++++++++++++
 include/uapi/linux/fuse.h |    2 ++
 4 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index ea45cf3..6d30db1 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -208,6 +208,8 @@ void fuse_finish_open(struct inode *inode, struct file *file)
 		spin_unlock(&fc->lock);
 		fuse_invalidate_attr(inode);
 	}
+	if ((file->f_mode & FMODE_WRITE) && fc->writeback_cache)
+		fuse_link_write_file(file);
 }
 
 int fuse_open_common(struct inode *inode, struct file *file, bool isdir)
@@ -1225,6 +1227,9 @@ static ssize_t fuse_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
 	struct iov_iter i;
 	loff_t endbyte = 0;
 
+	if (get_fuse_conn(inode)->writeback_cache)
+		return generic_file_aio_write(iocb, iov, nr_segs, pos);
+
 	WARN_ON(iocb->ki_pos != pos);
 
 	ocount = 0;
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index f969b22..3494457 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -44,6 +44,10 @@
     doing the mount will be allowed to access the filesystem */
 #define FUSE_ALLOW_OTHER         (1 << 1)
 
+/** If the FUSE_ALLOW_WBCACHE flag is given, the filesystem
+    module will enable support of writback cache */
+#define FUSE_ALLOW_WBCACHE       (1 << 2)
+
 /** Number of page pointers embedded in fuse_req */
 #define FUSE_REQ_INLINE_PAGES 1
 
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 591b46c..4beb8e3 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -459,6 +459,7 @@ enum {
 	OPT_ALLOW_OTHER,
 	OPT_MAX_READ,
 	OPT_BLKSIZE,
+	OPT_ALLOW_WBCACHE,
 	OPT_ERR
 };
 
@@ -471,6 +472,7 @@ static const match_table_t tokens = {
 	{OPT_ALLOW_OTHER,		"allow_other"},
 	{OPT_MAX_READ,			"max_read=%u"},
 	{OPT_BLKSIZE,			"blksize=%u"},
+	{OPT_ALLOW_WBCACHE,		"allow_wbcache"},
 	{OPT_ERR,			NULL}
 };
 
@@ -544,6 +546,10 @@ static int parse_fuse_opt(char *opt, struct fuse_mount_data *d, int is_bdev)
 			d->blksize = value;
 			break;
 
+		case OPT_ALLOW_WBCACHE:
+			d->flags |= FUSE_ALLOW_WBCACHE;
+			break;
+
 		default:
 			return 0;
 		}
@@ -571,6 +577,8 @@ static int fuse_show_options(struct seq_file *m, struct dentry *root)
 		seq_printf(m, ",max_read=%u", fc->max_read);
 	if (sb->s_bdev && sb->s_blocksize != FUSE_DEFAULT_BLKSIZE)
 		seq_printf(m, ",blksize=%lu", sb->s_blocksize);
+	if (fc->flags & FUSE_ALLOW_WBCACHE)
+		seq_puts(m, ",allow_wbcache");
 	return 0;
 }
 
@@ -888,6 +896,9 @@ static void process_init_reply(struct fuse_conn *fc, struct fuse_req *req)
 			}
 			if (arg->flags & FUSE_ASYNC_DIO)
 				fc->async_dio = 1;
+			if (arg->flags & FUSE_WRITEBACK_CACHE &&
+			    fc->flags & FUSE_ALLOW_WBCACHE)
+				fc->writeback_cache = 1;
 		} else {
 			ra_pages = fc->max_read / PAGE_CACHE_SIZE;
 			fc->no_lock = 1;
@@ -916,6 +927,8 @@ static void fuse_send_init(struct fuse_conn *fc, struct fuse_req *req)
 		FUSE_SPLICE_WRITE | FUSE_SPLICE_MOVE | FUSE_SPLICE_READ |
 		FUSE_FLOCK_LOCKS | FUSE_IOCTL_DIR | FUSE_AUTO_INVAL_DATA |
 		FUSE_DO_READDIRPLUS | FUSE_READDIRPLUS_AUTO | FUSE_ASYNC_DIO;
+	if (fc->flags & FUSE_ALLOW_WBCACHE)
+		arg->flags |= FUSE_WRITEBACK_CACHE;
 	req->in.h.opcode = FUSE_INIT;
 	req->in.numargs = 1;
 	req->in.args[0].size = sizeof(*arg);
diff --git a/include/uapi/linux/fuse.h b/include/uapi/linux/fuse.h
index 60bb2f9..5c98dd1 100644
--- a/include/uapi/linux/fuse.h
+++ b/include/uapi/linux/fuse.h
@@ -219,6 +219,7 @@ struct fuse_file_lock {
  * FUSE_DO_READDIRPLUS: do READDIRPLUS (READDIR+LOOKUP in one)
  * FUSE_READDIRPLUS_AUTO: adaptive readdirplus
  * FUSE_ASYNC_DIO: asynchronous direct I/O submission
+ * FUSE_WRITEBACK_CACHE: use writeback cache for buffered writes
  */
 #define FUSE_ASYNC_READ		(1 << 0)
 #define FUSE_POSIX_LOCKS	(1 << 1)
@@ -236,6 +237,7 @@ struct fuse_file_lock {
 #define FUSE_DO_READDIRPLUS	(1 << 13)
 #define FUSE_READDIRPLUS_AUTO	(1 << 14)
 #define FUSE_ASYNC_DIO		(1 << 15)
+#define FUSE_WRITEBACK_CACHE	(1 << 16)
 
 /**
  * CUSE INIT request/reply flags

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
