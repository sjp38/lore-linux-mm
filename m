Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:45 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 10/13] aio: add async unlinkat functionality
Message-ID: <3872f0076fb0a1b7e9e71c6735bac9ed55b27bdb.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Enable asynchronous deletion of files by adding support for an aio
unlinkat operation.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c                     | 42 +++++++++++++++++++++++++++++++++---------
 fs/namei.c                   |  2 +-
 include/linux/fs.h           |  1 +
 include/uapi/linux/aio_abi.h |  1 +
 4 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 346786b..3a70492 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -232,7 +232,11 @@ static const struct address_space_operations aio_ctx_aops;
 static void aio_complete(struct kiocb *kiocb, long res, long res2);
 ssize_t aio_fsync(struct kiocb *iocb, int datasync);
 long aio_poll(struct aio_kiocb *iocb);
-long aio_openat(struct aio_kiocb *req);
+
+typedef long (*do_foo_at_t)(int fd, const char *filename, int flags, int mode);
+long aio_do_openat(int fd, const char *filename, int flags, int mode);
+long aio_do_unlinkat(int fd, const char *filename, int flags, int mode);
+long aio_foo_at(struct aio_kiocb *req, do_foo_at_t do_foo_at);
 
 static __always_inline bool aio_may_use_threads(void)
 {
@@ -1763,7 +1767,19 @@ long aio_poll(struct aio_kiocb *req)
 	return aio_thread_queue_iocb(req, aio_thread_op_poll, 0);
 }
 
-static long aio_thread_op_openat(struct aio_kiocb *req)
+long aio_do_openat(int fd, const char *filename, int flags, int mode)
+{
+	return do_sys_open(fd, filename, flags, mode);
+}
+
+long aio_do_unlinkat(int fd, const char *filename, int flags, int mode)
+{
+	if (flags || mode)
+		return -EINVAL;
+	return do_unlinkat(fd, filename);
+}
+
+static long aio_thread_op_foo_at(struct aio_kiocb *req)
 {
 	u64 buf, offset;
 	long ret;
@@ -1777,18 +1793,21 @@ static long aio_thread_op_openat(struct aio_kiocb *req)
 	else if (unlikely(__get_user(offset, &req->ki_user_iocb->aio_offset)))
 		ret = -EFAULT;
 	else {
-		ret = do_sys_open((s32)fd,
-				  (const char __user *)(long)buf,
-				  (int)offset,
-				  (unsigned short)(offset >> 32));
+		do_foo_at_t do_foo_at = (void *)req->ki_data;
+
+		ret = do_foo_at((s32)fd,
+				(const char __user *)(long)buf,
+				(int)offset,
+				(unsigned short)(offset >> 32));
 	}
 	unuse_mm(req->ki_ctx->mm);
 	return ret;
 }
 
-long aio_openat(struct aio_kiocb *req)
+long aio_foo_at(struct aio_kiocb *req, do_foo_at_t do_foo_at)
 {
-	return aio_thread_queue_iocb(req, aio_thread_op_openat,
+	req->ki_data = (unsigned long)(void *)do_foo_at;
+	return aio_thread_queue_iocb(req, aio_thread_op_foo_at,
 				     AIO_THREAD_NEED_TASK |
 				     AIO_THREAD_NEED_FILES |
 				     AIO_THREAD_NEED_CRED);
@@ -1895,7 +1914,12 @@ rw_common:
 
 	case IOCB_CMD_OPENAT:
 		if (aio_may_use_threads())
-			ret = aio_openat(req);
+			ret = aio_foo_at(req, aio_do_openat);
+		break;
+
+	case IOCB_CMD_UNLINKAT:
+		if (aio_may_use_threads())
+			ret = aio_foo_at(req, aio_do_unlinkat);
 		break;
 
 	default:
diff --git a/fs/namei.c b/fs/namei.c
index 0c3974c..84ecc7e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3828,7 +3828,7 @@ EXPORT_SYMBOL(vfs_unlink);
  * writeout happening, and we don't want to prevent access to the directory
  * while waiting on the I/O.
  */
-static long do_unlinkat(int dfd, const char __user *pathname)
+long do_unlinkat(int dfd, const char __user *pathname)
 {
 	int error;
 	struct filename *name;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b3dc406..9051771 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1509,6 +1509,7 @@ extern int vfs_symlink(struct inode *, struct dentry *, const char *);
 extern int vfs_link(struct dentry *, struct inode *, struct dentry *, struct inode **);
 extern int vfs_rmdir(struct inode *, struct dentry *);
 extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
+extern long do_unlinkat(int dfd, const char __user *pathname);
 extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **, unsigned int);
 extern int vfs_whiteout(struct inode *, struct dentry *);
 
diff --git a/include/uapi/linux/aio_abi.h b/include/uapi/linux/aio_abi.h
index 0e16988..63a0d41 100644
--- a/include/uapi/linux/aio_abi.h
+++ b/include/uapi/linux/aio_abi.h
@@ -46,6 +46,7 @@ enum {
 	IOCB_CMD_PWRITEV = 8,
 
 	IOCB_CMD_OPENAT = 9,
+	IOCB_CMD_UNLINKAT = 10,
 };
 
 /*
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
