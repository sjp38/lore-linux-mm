Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:23 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Enable a fully asynchronous fsync and fdatasync operations in aio using
the aio thread queuing mechanism.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c | 41 +++++++++++++++++++++++++++++++----------
 1 file changed, 31 insertions(+), 10 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 88af450..576b780 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -224,8 +224,9 @@ static const struct file_operations aio_ring_fops;
 static const struct address_space_operations aio_ctx_aops;
 
 static void aio_complete(struct kiocb *kiocb, long res, long res2);
+ssize_t aio_fsync(struct kiocb *iocb, int datasync);
 
-static bool aio_may_use_threads(void)
+static __always_inline bool aio_may_use_threads(void)
 {
 #if IS_ENABLED(CONFIG_AIO_THREAD)
 	return !!(aio_auto_threads & 1);
@@ -1654,6 +1655,26 @@ ssize_t generic_async_write_iter(struct kiocb *iocb, struct iov_iter *iter)
 				     AIO_THREAD_NEED_TASK);
 }
 EXPORT_SYMBOL(generic_async_write_iter);
+
+static long aio_thread_op_fsync(struct aio_kiocb *iocb)
+{
+	return vfs_fsync(iocb->common.ki_filp, 0);
+}
+
+static long aio_thread_op_fdatasync(struct aio_kiocb *iocb)
+{
+	return vfs_fsync(iocb->common.ki_filp, 1);
+}
+
+ssize_t aio_fsync(struct kiocb *iocb, int datasync)
+{
+	struct aio_kiocb *req;
+
+	req = container_of(iocb, struct aio_kiocb, common);
+
+	return aio_thread_queue_iocb(req, datasync ? aio_thread_op_fdatasync
+						   : aio_thread_op_fsync, 0);
+}
 #endif /* IS_ENABLED(CONFIG_AIO_THREAD) */
 
 /*
@@ -1664,7 +1685,7 @@ static ssize_t aio_run_iocb(struct aio_kiocb *req, unsigned opcode,
 			    char __user *buf, size_t len, bool compat)
 {
 	struct file *file = req->common.ki_filp;
-	ssize_t ret;
+	ssize_t ret = -EINVAL;
 	int rw;
 	fmode_t mode;
 	rw_iter_op *iter_op;
@@ -1730,17 +1751,17 @@ rw_common:
 		break;
 
 	case IOCB_CMD_FDSYNC:
-		if (!file->f_op->aio_fsync)
-			return -EINVAL;
-
-		ret = file->f_op->aio_fsync(&req->common, 1);
+		if (file->f_op->aio_fsync)
+			ret = file->f_op->aio_fsync(&req->common, 1);
+		else if (file->f_op->fsync && (aio_may_use_threads()))
+			ret = aio_fsync(&req->common, 1);
 		break;
 
 	case IOCB_CMD_FSYNC:
-		if (!file->f_op->aio_fsync)
-			return -EINVAL;
-
-		ret = file->f_op->aio_fsync(&req->common, 0);
+		if (file->f_op->aio_fsync)
+			ret = file->f_op->aio_fsync(&req->common, 0);
+		else if (file->f_op->fsync && (aio_may_use_threads()))
+			ret = aio_fsync(&req->common, 0);
 		break;
 
 	default:
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
