Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:06:50 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 03/13] aio: for async operations, make the iter argument persistent
Message-ID: <bec1e16e50afbf609c149278e6d9740bcb08f5d2.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

When implementing async read/write operations, the complexity of having
to duplicate the iter argument before passing to another thread leads to
duplicate code.  There is no reason async operations issued by the aio
core need to be placed on the stack when an aio_kiocb is allocated for
each operation, so put the iter and iovec into aio_kiocb instead of on
the stack.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c | 41 +++++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 20 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 2cd5071..fc453ca 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -187,6 +187,10 @@ struct aio_kiocb {
 	 * this is the underlying eventfd context to deliver events to.
 	 */
 	struct eventfd_ctx	*ki_eventfd;
+
+	struct iov_iter		ki_iter;
+	struct iovec		*ki_iovec;
+	struct iovec		ki_inline_vecs[UIO_FASTIOV];
 };
 
 /*------ sysctl variables----*/
@@ -1026,6 +1030,7 @@ static inline struct aio_kiocb *aio_get_req(struct kioctx *ctx)
 	percpu_ref_get(&ctx->reqs);
 
 	req->ki_ctx = ctx;
+	req->ki_iovec = req->ki_inline_vecs;
 	return req;
 out_put:
 	put_reqs_available(ctx, 1);
@@ -1038,6 +1043,8 @@ static void kiocb_free(struct aio_kiocb *req)
 		fput(req->common.ki_filp);
 	if (req->ki_eventfd != NULL)
 		eventfd_ctx_put(req->ki_eventfd);
+	if (req->ki_iovec != req->ki_inline_vecs)
+		kfree(req->ki_iovec);
 	kmem_cache_free(kiocb_cachep, req);
 }
 
@@ -1417,16 +1424,14 @@ static int aio_setup_vectored_rw(int rw, char __user *buf, size_t len,
  * aio_run_iocb:
  *	Performs the initial checks and io submission.
  */
-static ssize_t aio_run_iocb(struct kiocb *req, unsigned opcode,
+static ssize_t aio_run_iocb(struct aio_kiocb *req, unsigned opcode,
 			    char __user *buf, size_t len, bool compat)
 {
-	struct file *file = req->ki_filp;
+	struct file *file = req->common.ki_filp;
 	ssize_t ret;
 	int rw;
 	fmode_t mode;
 	rw_iter_op *iter_op;
-	struct iovec inline_vecs[UIO_FASTIOV], *iovec = inline_vecs;
-	struct iov_iter iter;
 
 	switch (opcode) {
 	case IOCB_CMD_PREAD:
@@ -1451,43 +1456,39 @@ rw_common:
 
 		if (opcode == IOCB_CMD_PREADV || opcode == IOCB_CMD_PWRITEV)
 			ret = aio_setup_vectored_rw(rw, buf, len,
-						&iovec, compat, &iter);
+						    &req->ki_iovec, compat,
+						    &req->ki_iter);
 		else {
-			ret = import_single_range(rw, buf, len, iovec, &iter);
-			iovec = NULL;
+			ret = import_single_range(rw, buf, len, req->ki_iovec,
+						  &req->ki_iter);
 		}
 		if (!ret)
-			ret = rw_verify_area(rw, file, &req->ki_pos,
-					     iov_iter_count(&iter));
-		if (ret < 0) {
-			kfree(iovec);
+			ret = rw_verify_area(rw, file, &req->common.ki_pos,
+					     iov_iter_count(&req->ki_iter));
+		if (ret < 0)
 			return ret;
-		}
-
-		len = ret;
 
 		if (rw == WRITE)
 			file_start_write(file);
 
-		ret = iter_op(req, &iter);
+		ret = iter_op(&req->common, &req->ki_iter);
 
 		if (rw == WRITE)
 			file_end_write(file);
-		kfree(iovec);
 		break;
 
 	case IOCB_CMD_FDSYNC:
 		if (!file->f_op->aio_fsync)
 			return -EINVAL;
 
-		ret = file->f_op->aio_fsync(req, 1);
+		ret = file->f_op->aio_fsync(&req->common, 1);
 		break;
 
 	case IOCB_CMD_FSYNC:
 		if (!file->f_op->aio_fsync)
 			return -EINVAL;
 
-		ret = file->f_op->aio_fsync(req, 0);
+		ret = file->f_op->aio_fsync(&req->common, 0);
 		break;
 
 	default:
@@ -1504,7 +1505,7 @@ rw_common:
 			     ret == -ERESTARTNOHAND ||
 			     ret == -ERESTART_RESTARTBLOCK))
 			ret = -EINTR;
-		aio_complete(req, ret, 0);
+		aio_complete(&req->common, ret, 0);
 	}
 
 	return 0;
@@ -1571,7 +1572,7 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	req->ki_user_iocb = user_iocb;
 	req->ki_user_data = iocb->aio_data;
 
-	ret = aio_run_iocb(&req->common, iocb->aio_lio_opcode,
+	ret = aio_run_iocb(req, iocb->aio_lio_opcode,
 			   (char __user *)(unsigned long)iocb->aio_buf,
 			   iocb->aio_nbytes,
 			   compat);
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
