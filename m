Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:38 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 09/13] aio: add support for async openat()
Message-ID: <150a0b4905f1d7274b4c2c7f5e3f4d8df5dda1d7.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Another blocking operation used by applications that want aio
functionality is that of opening files that are not resident in memory.
Using the thread based aio helper, add support for IOCB_CMD_OPENAT.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c                     | 120 +++++++++++++++++++++++++++++++++++++------
 include/uapi/linux/aio_abi.h |   2 +
 2 files changed, 107 insertions(+), 15 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 4384df4..346786b 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -40,6 +40,8 @@
 #include <linux/ramfs.h>
 #include <linux/percpu-refcount.h>
 #include <linux/mount.h>
+#include <linux/fdtable.h>
+#include <linux/fs_struct.h>
 
 #include <asm/kmap_types.h>
 #include <asm/uaccess.h>
@@ -204,6 +206,9 @@ struct aio_kiocb {
 	unsigned long		ki_rlimit_fsize;
 	aio_thread_work_fn_t	ki_work_fn;
 	struct work_struct	ki_work;
+	struct fs_struct	*ki_fs;
+	struct files_struct	*ki_files;
+	const struct cred	*ki_cred;
 #endif
 };
 
@@ -227,6 +232,7 @@ static const struct address_space_operations aio_ctx_aops;
 static void aio_complete(struct kiocb *kiocb, long res, long res2);
 ssize_t aio_fsync(struct kiocb *iocb, int datasync);
 long aio_poll(struct aio_kiocb *iocb);
+long aio_openat(struct aio_kiocb *req);
 
 static __always_inline bool aio_may_use_threads(void)
 {
@@ -1496,6 +1502,9 @@ static int aio_thread_queue_iocb_cancel(struct kiocb *kiocb)
 static void aio_thread_fn(struct work_struct *work)
 {
 	struct aio_kiocb *iocb = container_of(work, struct aio_kiocb, ki_work);
+	struct files_struct *old_files = current->files;
+	const struct cred *old_cred = current_cred();
+	struct fs_struct *old_fs = current->fs;
 	kiocb_cancel_fn *old_cancel;
 	long ret;
 
@@ -1503,6 +1512,13 @@ static void aio_thread_fn(struct work_struct *work)
 	current->kiocb = &iocb->common;		/* For io_send_sig(). */
 	WARN_ON(atomic_read(&current->signal->sigcnt) != 1);
 
+	if (iocb->ki_fs)
+		current->fs = iocb->ki_fs;
+	if (iocb->ki_files)
+		current->files = iocb->ki_files;
+	if (iocb->ki_cred)
+		current->cred = iocb->ki_cred;
+
 	/* Check for early stage cancellation and switch to late stage
 	 * cancellation if it has not already occurred.
 	 */
@@ -1519,6 +1535,19 @@ static void aio_thread_fn(struct work_struct *work)
 		     ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK))
 		ret = -EINTR;
 
+	if (iocb->ki_cred) {
+		current->cred = old_cred;
+		put_cred(iocb->ki_cred);
+	}
+	if (iocb->ki_files) {
+		current->files = old_files;
+		put_files_struct(iocb->ki_files);
+	}
+	if (iocb->ki_fs) {
+		exit_fs(current);
+		current->fs = old_fs;
+	}
+
 	/* Completion serializes cancellation by taking ctx_lock, so
 	 * aio_complete() will not return until after force_sig() in
 	 * aio_thread_queue_iocb_cancel().  This should ensure that
@@ -1530,6 +1559,9 @@ static void aio_thread_fn(struct work_struct *work)
 }
 
 #define AIO_THREAD_NEED_TASK	0x0001	/* Need aio_kiocb->ki_submit_task */
+#define AIO_THREAD_NEED_FS	0x0002	/* Need aio_kiocb->ki_fs */
+#define AIO_THREAD_NEED_FILES	0x0004	/* Need aio_kiocb->ki_files */
+#define AIO_THREAD_NEED_CRED	0x0008	/* Need aio_kiocb->ki_cred */
 
 /* aio_thread_queue_iocb
  *	Queues an aio_kiocb for dispatch to a worker thread.  Prepares the
@@ -1547,6 +1579,20 @@ static ssize_t aio_thread_queue_iocb(struct aio_kiocb *iocb,
 		iocb->ki_submit_task = current;
 		get_task_struct(iocb->ki_submit_task);
 	}
+	if (flags & AIO_THREAD_NEED_FS) {
+		struct fs_struct *fs = current->fs;
+
+		iocb->ki_fs = fs;
+		spin_lock(&fs->lock);
+		fs->users++;
+		spin_unlock(&fs->lock);
+	}
+	if (flags & AIO_THREAD_NEED_FILES) {
+		iocb->ki_files = current->files;
+		atomic_inc(&iocb->ki_files->count);
+	}
+	if (flags & AIO_THREAD_NEED_CRED)
+		iocb->ki_cred = get_current_cred();
 
 	/* Cancellation needs to be always available for operations performed
 	 * using helper threads.  Prior to the iocb being assigned to a worker
@@ -1716,22 +1762,54 @@ long aio_poll(struct aio_kiocb *req)
 {
 	return aio_thread_queue_iocb(req, aio_thread_op_poll, 0);
 }
+
+static long aio_thread_op_openat(struct aio_kiocb *req)
+{
+	u64 buf, offset;
+	long ret;
+	u32 fd;
+
+	use_mm(req->ki_ctx->mm);
+	if (unlikely(__get_user(fd, &req->ki_user_iocb->aio_fildes)))
+		ret = -EFAULT;
+	else if (unlikely(__get_user(buf, &req->ki_user_iocb->aio_buf)))
+		ret = -EFAULT;
+	else if (unlikely(__get_user(offset, &req->ki_user_iocb->aio_offset)))
+		ret = -EFAULT;
+	else {
+		ret = do_sys_open((s32)fd,
+				  (const char __user *)(long)buf,
+				  (int)offset,
+				  (unsigned short)(offset >> 32));
+	}
+	unuse_mm(req->ki_ctx->mm);
+	return ret;
+}
+
+long aio_openat(struct aio_kiocb *req)
+{
+	return aio_thread_queue_iocb(req, aio_thread_op_openat,
+				     AIO_THREAD_NEED_TASK |
+				     AIO_THREAD_NEED_FILES |
+				     AIO_THREAD_NEED_CRED);
+}
 #endif /* IS_ENABLED(CONFIG_AIO_THREAD) */
 
 /*
  * aio_run_iocb:
  *	Performs the initial checks and io submission.
  */
-static ssize_t aio_run_iocb(struct aio_kiocb *req, unsigned opcode,
-			    char __user *buf, size_t len, bool compat)
+static ssize_t aio_run_iocb(struct aio_kiocb *req, struct iocb *user_iocb,
+			    bool compat)
 {
 	struct file *file = req->common.ki_filp;
 	ssize_t ret = -EINVAL;
+	char __user *buf;
 	int rw;
 	fmode_t mode;
 	rw_iter_op *iter_op;
 
-	switch (opcode) {
+	switch (user_iocb->aio_lio_opcode) {
 	case IOCB_CMD_PREAD:
 	case IOCB_CMD_PREADV:
 		mode	= FMODE_READ;
@@ -1768,12 +1846,17 @@ rw_common:
 		if (!iter_op)
 			return -EINVAL;
 
-		if (opcode == IOCB_CMD_PREADV || opcode == IOCB_CMD_PWRITEV)
-			ret = aio_setup_vectored_rw(rw, buf, len,
+		buf = (char __user *)(unsigned long)user_iocb->aio_buf;
+		if (user_iocb->aio_lio_opcode == IOCB_CMD_PREADV ||
+		    user_iocb->aio_lio_opcode == IOCB_CMD_PWRITEV)
+			ret = aio_setup_vectored_rw(rw, buf,
+						    user_iocb->aio_nbytes,
 						    &req->ki_iovec, compat,
 						    &req->ki_iter);
 		else {
-			ret = import_single_range(rw, buf, len, req->ki_iovec,
+			ret = import_single_range(rw, buf,
+						  user_iocb->aio_nbytes,
+						  req->ki_iovec,
 						  &req->ki_iter);
 		}
 		if (!ret)
@@ -1810,6 +1893,11 @@ rw_common:
 			ret = aio_poll(req);
 		break;
 
+	case IOCB_CMD_OPENAT:
+		if (aio_may_use_threads())
+			ret = aio_openat(req);
+		break;
+
 	default:
 		pr_debug("EINVAL: no operation provided\n");
 		return -EINVAL;
@@ -1856,14 +1944,19 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	if (unlikely(!req))
 		return -EAGAIN;
 
-	req->common.ki_filp = fget(iocb->aio_fildes);
-	if (unlikely(!req->common.ki_filp)) {
-		ret = -EBADF;
-		goto out_put_req;
+	if (iocb->aio_lio_opcode == IOCB_CMD_OPENAT)
+		req->common.ki_filp = NULL;
+	else {
+		req->common.ki_filp = fget(iocb->aio_fildes);
+		if (unlikely(!req->common.ki_filp)) {
+			ret = -EBADF;
+			goto out_put_req;
+		}
 	}
 	req->common.ki_pos = iocb->aio_offset;
 	req->common.ki_complete = aio_complete;
-	req->common.ki_flags = iocb_flags(req->common.ki_filp);
+	if (req->common.ki_filp)
+		req->common.ki_flags = iocb_flags(req->common.ki_filp);
 
 	if (iocb->aio_flags & IOCB_FLAG_RESFD) {
 		/*
@@ -1891,10 +1984,7 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	req->ki_user_iocb = user_iocb;
 	req->ki_user_data = iocb->aio_data;
 
-	ret = aio_run_iocb(req, iocb->aio_lio_opcode,
-			   (char __user *)(unsigned long)iocb->aio_buf,
-			   iocb->aio_nbytes,
-			   compat);
+	ret = aio_run_iocb(req, iocb, compat);
 	if (ret)
 		goto out_put_req;
 
diff --git a/include/uapi/linux/aio_abi.h b/include/uapi/linux/aio_abi.h
index 7639fb1..0e16988 100644
--- a/include/uapi/linux/aio_abi.h
+++ b/include/uapi/linux/aio_abi.h
@@ -44,6 +44,8 @@ enum {
 	IOCB_CMD_NOOP = 6,
 	IOCB_CMD_PREADV = 7,
 	IOCB_CMD_PWRITEV = 8,
+
+	IOCB_CMD_OPENAT = 9,
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
