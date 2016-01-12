Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 12 Jan 2016 17:50:11 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160112225011.GJ347@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org> <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org> <20160112011128.GC6033@dastard> <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com> <20160112022548.GD6033@dastard> <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com> <20160112033708.GE6033@dastard> <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com> <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 08:48:23PM -0800, Linus Torvalds wrote:
> On Mon, Jan 11, 2016 at 8:03 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > So my argument is really that I think it would be better to at least
> > look into maybe creating something less crapulent, and striving to
> > make it easy to make the old legacy interfaces be just wrappers around
> > a more capable model.
> 
> Hmm. Thinking more about this makes me worry about all the system call
> versioning and extra work done by libc.

That is one of my worries, and one of the reasons an async getdents64() 
or readdir() operation isn't in this batch -- there are a ton of ABI 
issues glibc handles on some platforms.

> At least glibc has traditionally decided to munge and extend on kernel
> system call interfaces, to the point where even fairly core data
> structures (like "struct stat") may not always look the same to the
> kernel as they do to user space.
> 
> So with that worry, I have to admit that maybe a limited interface -
> rather than allowing arbitrary generic async system calls - might have
> advantages. Less room for mismatches.
> 
> I'll have to think about this some more.
> 
>                   Linus

I think some cleanups can be made on how and where the AIO operations
are implemented.  A first stab is below (not very tested as of yet,
still have more work to do) that uses an array to dispatch AIO submits.
By using function pointers to dispatch the operations fairly early in
the process, the code that actually does the required verifications is
less spread out and much easier to follow instead of the giant select
cases.

Another possible improvement might be to move things like aio_fsync()
into sync.c with all the other relevant sync code.  That would make much
more sense and make it much more obvious as to which subsystem
maintainers a given set of functionality really belongs.  If that sounds
like an improvement, I can put some effort into that as well.

		-ben

 aio.c |  242 ++++++++++++++++++++++++++++++++----------------------------------
 1 file changed, 118 insertions(+), 124 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index f776dff..0c06e3b 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -177,6 +177,12 @@ typedef long (*aio_thread_work_fn_t)(struct aio_kiocb *iocb);
  */
 #define KIOCB_CANCELLED		((void *) (~0ULL))
 
+#define AIO_THREAD_NEED_TASK	0x0001	/* Need aio_kiocb->ki_submit_task */
+#define AIO_THREAD_NEED_FS	0x0002	/* Need aio_kiocb->ki_fs */
+#define AIO_THREAD_NEED_FILES	0x0004	/* Need aio_kiocb->ki_files */
+#define AIO_THREAD_NEED_CRED	0x0008	/* Need aio_kiocb->ki_cred */
+#define AIO_THREAD_NEED_MM	0x0010	/* Need the mm context */
+
 struct aio_kiocb {
 	struct kiocb		common;
 
@@ -205,6 +211,7 @@ struct aio_kiocb {
 	struct task_struct	*ki_cancel_task;
 	unsigned long		ki_data;
 	unsigned long		ki_rlimit_fsize;
+	unsigned		ki_thread_flags;	/* AIO_THREAD_NEED... */
 	aio_thread_work_fn_t	ki_work_fn;
 	struct work_struct	ki_work;
 	struct fs_struct	*ki_fs;
@@ -231,16 +238,8 @@ static const struct file_operations aio_ring_fops;
 static const struct address_space_operations aio_ctx_aops;
 
 static void aio_complete(struct kiocb *kiocb, long res, long res2);
-ssize_t aio_fsync(struct kiocb *iocb, int datasync);
-long aio_poll(struct aio_kiocb *iocb);
 
 typedef long (*do_foo_at_t)(int fd, const char *filename, int flags, int mode);
-long aio_do_openat(int fd, const char *filename, int flags, int mode);
-long aio_do_unlinkat(int fd, const char *filename, int flags, int mode);
-long aio_foo_at(struct aio_kiocb *req, do_foo_at_t do_foo_at);
-
-long aio_readahead(struct aio_kiocb *iocb, unsigned long len);
-long aio_renameat(struct aio_kiocb *iocb, struct iocb *user_iocb);
 
 static __always_inline bool aio_may_use_threads(void)
 {
@@ -1533,9 +1532,13 @@ static void aio_thread_fn(struct work_struct *work)
 	old_cancel = cmpxchg(&iocb->ki_cancel,
 			     aio_thread_queue_iocb_cancel_early,
 			     aio_thread_queue_iocb_cancel);
-	if (old_cancel != KIOCB_CANCELLED)
+	if (old_cancel != KIOCB_CANCELLED) {
+		if (iocb->ki_thread_flags & AIO_THREAD_NEED_MM)
+			use_mm(iocb->ki_ctx->mm);
 		ret = iocb->ki_work_fn(iocb);
-	else
+		if (iocb->ki_thread_flags & AIO_THREAD_NEED_MM)
+			unuse_mm(iocb->ki_ctx->mm);
+	} else
 		ret = -EINTR;
 
 	current->kiocb = NULL;
@@ -1566,11 +1569,6 @@ static void aio_thread_fn(struct work_struct *work)
 		flush_signals(current);
 }
 
-#define AIO_THREAD_NEED_TASK	0x0001	/* Need aio_kiocb->ki_submit_task */
-#define AIO_THREAD_NEED_FS	0x0002	/* Need aio_kiocb->ki_fs */
-#define AIO_THREAD_NEED_FILES	0x0004	/* Need aio_kiocb->ki_files */
-#define AIO_THREAD_NEED_CRED	0x0008	/* Need aio_kiocb->ki_cred */
-
 /* aio_thread_queue_iocb
  *	Queues an aio_kiocb for dispatch to a worker thread.  Prepares the
  *	aio_kiocb for cancellation.  The caller must provide a function to
@@ -1581,7 +1579,10 @@ static ssize_t aio_thread_queue_iocb(struct aio_kiocb *iocb,
 				     aio_thread_work_fn_t work_fn,
 				     unsigned flags)
 {
+	if (!aio_may_use_threads())
+		return -EINVAL;
 	INIT_WORK(&iocb->ki_work, aio_thread_fn);
+	iocb->ki_thread_flags = flags;
 	iocb->ki_work_fn = work_fn;
 	if (flags & AIO_THREAD_NEED_TASK) {
 		iocb->ki_submit_task = current;
@@ -1618,7 +1619,6 @@ static long aio_thread_op_read_iter(struct aio_kiocb *iocb)
 	struct file *filp;
 	long ret;
 
-	use_mm(iocb->ki_ctx->mm);
 	filp = iocb->common.ki_filp;
 
 	if (filp->f_op->read_iter) {
@@ -1633,7 +1633,6 @@ static long aio_thread_op_read_iter(struct aio_kiocb *iocb)
 					   filp->f_op->read);
 	else
 		ret = -EINVAL;
-	unuse_mm(iocb->ki_ctx->mm);
 	return ret;
 }
 
@@ -1656,7 +1655,7 @@ ssize_t generic_async_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 		return -EINVAL;
 
 	return aio_thread_queue_iocb(req, aio_thread_op_read_iter,
-				     AIO_THREAD_NEED_TASK);
+				     AIO_THREAD_NEED_TASK | AIO_THREAD_NEED_MM);
 }
 EXPORT_SYMBOL(generic_async_read_iter);
 
@@ -1666,7 +1665,6 @@ static long aio_thread_op_write_iter(struct aio_kiocb *iocb)
 	struct file *filp;
 	long ret;
 
-	use_mm(iocb->ki_ctx->mm);
 	filp = iocb->common.ki_filp;
 	saved_rlim_fsize = rlimit(RLIMIT_FSIZE);
 	current->signal->rlim[RLIMIT_FSIZE].rlim_cur = iocb->ki_rlimit_fsize;
@@ -1684,7 +1682,6 @@ static long aio_thread_op_write_iter(struct aio_kiocb *iocb)
 	else
 		ret = -EINVAL;
 	current->signal->rlim[RLIMIT_FSIZE].rlim_cur = saved_rlim_fsize;
-	unuse_mm(iocb->ki_ctx->mm);
 	return ret;
 }
 
@@ -1708,28 +1705,13 @@ ssize_t generic_async_write_iter(struct kiocb *iocb, struct iov_iter *iter)
 	req->ki_rlimit_fsize = rlimit(RLIMIT_FSIZE);
 
 	return aio_thread_queue_iocb(req, aio_thread_op_write_iter,
-				     AIO_THREAD_NEED_TASK);
+				     AIO_THREAD_NEED_TASK | AIO_THREAD_NEED_MM);
 }
 EXPORT_SYMBOL(generic_async_write_iter);
 
 static long aio_thread_op_fsync(struct aio_kiocb *iocb)
 {
-	return vfs_fsync(iocb->common.ki_filp, 0);
-}
-
-static long aio_thread_op_fdatasync(struct aio_kiocb *iocb)
-{
-	return vfs_fsync(iocb->common.ki_filp, 1);
-}
-
-ssize_t aio_fsync(struct kiocb *iocb, int datasync)
-{
-	struct aio_kiocb *req;
-
-	req = container_of(iocb, struct aio_kiocb, common);
-
-	return aio_thread_queue_iocb(req, datasync ? aio_thread_op_fdatasync
-						   : aio_thread_op_fsync, 0);
+	return vfs_fsync(iocb->common.ki_filp, iocb->ki_data);
 }
 
 static long aio_thread_op_poll(struct aio_kiocb *iocb)
@@ -1766,17 +1748,22 @@ static long aio_thread_op_poll(struct aio_kiocb *iocb)
 	return ret;
 }
 
-long aio_poll(struct aio_kiocb *req)
+static long aio_poll(struct aio_kiocb *req, struct iocb *user_iocb, bool compat)
 {
+	if (!req->common.ki_filp->f_op->poll)
+		return -EINVAL;
+	if ((unsigned short)user_iocb->aio_buf != user_iocb->aio_buf)
+		return -EINVAL;
+	req->ki_data = user_iocb->aio_buf;
 	return aio_thread_queue_iocb(req, aio_thread_op_poll, 0);
 }
 
-long aio_do_openat(int fd, const char *filename, int flags, int mode)
+static long aio_do_openat(int fd, const char *filename, int flags, int mode)
 {
 	return do_sys_open(fd, filename, flags, mode);
 }
 
-long aio_do_unlinkat(int fd, const char *filename, int flags, int mode)
+static long aio_do_unlinkat(int fd, const char *filename, int flags, int mode)
 {
 	if (flags || mode)
 		return -EINVAL;
@@ -1789,7 +1776,6 @@ static long aio_thread_op_foo_at(struct aio_kiocb *req)
 	long ret;
 	u32 fd;
 
-	use_mm(req->ki_ctx->mm);
 	if (unlikely(__get_user(fd, &req->ki_user_iocb->aio_fildes)))
 		ret = -EFAULT;
 	else if (unlikely(__get_user(buf, &req->ki_user_iocb->aio_buf)))
@@ -1804,15 +1790,25 @@ static long aio_thread_op_foo_at(struct aio_kiocb *req)
 				(int)offset,
 				(unsigned short)(offset >> 32));
 	}
-	unuse_mm(req->ki_ctx->mm);
 	return ret;
 }
 
-long aio_foo_at(struct aio_kiocb *req, do_foo_at_t do_foo_at)
+static long aio_openat(struct aio_kiocb *req, struct iocb *uiocb, bool compat)
 {
-	req->ki_data = (unsigned long)(void *)do_foo_at;
+	req->ki_data = (unsigned long)(void *)aio_do_openat;
 	return aio_thread_queue_iocb(req, aio_thread_op_foo_at,
 				     AIO_THREAD_NEED_TASK |
+				     AIO_THREAD_NEED_MM |
+				     AIO_THREAD_NEED_FILES |
+				     AIO_THREAD_NEED_CRED);
+}
+
+static long aio_unlink(struct aio_kiocb *req, struct iocb *uiocb, bool compt)
+{
+	req->ki_data = (unsigned long)(void *)aio_do_unlinkat;
+	return aio_thread_queue_iocb(req, aio_thread_op_foo_at,
+				     AIO_THREAD_NEED_TASK |
+				     AIO_THREAD_NEED_MM |
 				     AIO_THREAD_NEED_FILES |
 				     AIO_THREAD_NEED_CRED);
 }
@@ -1898,17 +1894,23 @@ static long aio_thread_op_readahead(struct aio_kiocb *iocb)
 	return 0;
 }
 
-long aio_readahead(struct aio_kiocb *iocb, unsigned long len)
+static long aio_ra(struct aio_kiocb *iocb, struct iocb *uiocb, bool compat)
 {
 	struct address_space *mapping = iocb->common.ki_filp->f_mapping;
 	pgoff_t index, end;
 	loff_t epos, isize;
 	int do_io = 0;
+	size_t len;
 
+	if (!aio_may_use_threads())
+		return -EINVAL;
+	if (uiocb->aio_buf)
+		return -EINVAL;
 	if (!mapping || !mapping->a_ops)
 		return -EBADF;
 	if (!mapping->a_ops->readpage && !mapping->a_ops->readpages)
 		return -EBADF;
+	len = uiocb->aio_nbytes;
 	if (!len)
 		return 0;
 
@@ -1958,7 +1960,6 @@ static long aio_thread_op_renameat(struct aio_kiocb *iocb)
 	unsigned flags;
 	long ret;
 
-	use_mm(aio_get_mm(&iocb->common));
 	if (unlikely(copy_from_user(&info, user_info, sizeof(info)))) {
 		ret = -EFAULT;
 		goto done;
@@ -1979,39 +1980,47 @@ static long aio_thread_op_renameat(struct aio_kiocb *iocb)
 	else
 		ret = sys_renameat2(olddir, old, newdir, new, flags);
 done:
-	unuse_mm(aio_get_mm(&iocb->common));
 	return ret;
 }
 
-long aio_renameat(struct aio_kiocb *iocb, struct iocb *user_iocb)
+static long aio_rename(struct aio_kiocb *iocb, struct iocb *user_iocb, bool c)
 {
-	const void * __user user_info;
-
 	if (user_iocb->aio_nbytes != sizeof(struct renameat_info))
 		return -EINVAL;
 	if (user_iocb->aio_offset)
 		return -EINVAL;
 
-	user_info = (const void * __user)(long)user_iocb->aio_buf;
-	if (unlikely(!access_ok(VERIFY_READ, user_info,
-				sizeof(struct renameat_info))))
-		return -EFAULT;
-
-	iocb->common.private = (void *)user_info;
+	iocb->common.private = (void *)(long)user_iocb->aio_buf;
 	return aio_thread_queue_iocb(iocb, aio_thread_op_renameat,
 				     AIO_THREAD_NEED_TASK |
+				     AIO_THREAD_NEED_MM |
 				     AIO_THREAD_NEED_FS |
 				     AIO_THREAD_NEED_FILES |
 				     AIO_THREAD_NEED_CRED);
 }
 #endif /* IS_ENABLED(CONFIG_AIO_THREAD) */
 
+long aio_fsync(struct aio_kiocb *req, struct iocb *user_iocb, bool compat)
+{
+	bool datasync = (user_iocb->aio_lio_opcode == IOCB_CMD_FDSYNC);
+	struct file *file = req->common.ki_filp;
+
+	if (file->f_op->aio_fsync)
+		return file->f_op->aio_fsync(&req->common, datasync);
+#if IS_ENABLED(CONFIG_AIO_THREAD)
+	if (file->f_op->fsync) {
+		req->ki_data = datasync;
+		return aio_thread_queue_iocb(req, aio_thread_op_fsync, 0);
+	}
+#endif
+	return -EINVAL;
+}
+
 /*
- * aio_run_iocb:
- *	Performs the initial checks and io submission.
+ * aio_rw:
+ *	Implements read/write vectored and non-vectored
  */
-static ssize_t aio_run_iocb(struct aio_kiocb *req, struct iocb *user_iocb,
-			    bool compat)
+static long aio_rw(struct aio_kiocb *req, struct iocb *user_iocb, bool compat)
 {
 	struct file *file = req->common.ki_filp;
 	ssize_t ret = -EINVAL;
@@ -2085,70 +2094,42 @@ rw_common:
 			file_end_write(file);
 		break;
 
-	case IOCB_CMD_FDSYNC:
-		if (file->f_op->aio_fsync)
-			ret = file->f_op->aio_fsync(&req->common, 1);
-		else if (file->f_op->fsync && (aio_may_use_threads()))
-			ret = aio_fsync(&req->common, 1);
-		break;
-
-	case IOCB_CMD_FSYNC:
-		if (file->f_op->aio_fsync)
-			ret = file->f_op->aio_fsync(&req->common, 0);
-		else if (file->f_op->fsync && (aio_may_use_threads()))
-			ret = aio_fsync(&req->common, 0);
-		break;
-
-	case IOCB_CMD_POLL:
-		if (aio_may_use_threads())
-			ret = aio_poll(req);
-		break;
-
-	case IOCB_CMD_OPENAT:
-		if (aio_may_use_threads())
-			ret = aio_foo_at(req, aio_do_openat);
-		break;
-
-	case IOCB_CMD_UNLINKAT:
-		if (aio_may_use_threads())
-			ret = aio_foo_at(req, aio_do_unlinkat);
-		break;
-
-	case IOCB_CMD_READAHEAD:
-		if (user_iocb->aio_buf)
-			return -EINVAL;
-		if (aio_may_use_threads())
-			ret = aio_readahead(req, user_iocb->aio_nbytes);
-		break;
-
-	case IOCB_CMD_RENAMEAT:
-		if (aio_may_use_threads())
-			ret = aio_renameat(req, user_iocb);
-		break;
-
 	default:
 		pr_debug("EINVAL: no operation provided\n");
-		return -EINVAL;
 	}
+	return ret;
+}
 
-	if (ret != -EIOCBQUEUED) {
-		/*
-		 * There's no easy way to restart the syscall since other AIO's
-		 * may be already running. Just fail this IO with EINTR.
-		 */
-		if (unlikely(ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
-			     ret == -ERESTARTNOHAND ||
-			     ret == -ERESTART_RESTARTBLOCK))
-			ret = -EINTR;
-		aio_complete(&req->common, ret, 0);
-	}
+typedef long (*aio_submit_fn_t)(struct aio_kiocb *req, struct iocb *iocb,
+				bool compat);
 
-	return 0;
-}
+#define NEED_FD			0x0001
+
+struct submit_info {
+	aio_submit_fn_t		fn;
+	unsigned long		flags;
+};
+
+static const struct submit_info aio_submit_info[] = {
+	[IOCB_CMD_PREAD]	= { aio_rw,	NEED_FD },
+	[IOCB_CMD_PWRITE]	= { aio_rw,	NEED_FD },
+	[IOCB_CMD_PREADV]	= { aio_rw,	NEED_FD },
+	[IOCB_CMD_PWRITEV]	= { aio_rw,	NEED_FD },
+	[IOCB_CMD_FSYNC]	= { aio_fsync,	NEED_FD },
+	[IOCB_CMD_FDSYNC]	= { aio_fsync,	NEED_FD },
+#if IS_ENABLED(CONFIG_AIO_THREAD)
+	[IOCB_CMD_POLL]		= { aio_poll,	NEED_FD },
+	[IOCB_CMD_OPENAT]	= { aio_openat,	0 },
+	[IOCB_CMD_UNLINKAT]	= { aio_unlink,	0 },
+	[IOCB_CMD_READAHEAD]	= { aio_ra,	NEED_FD },
+	[IOCB_CMD_RENAMEAT]	= { aio_rename,	0 },
+#endif
+};
 
 static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 			 struct iocb *iocb, bool compat)
 {
+	const struct submit_info *submit_info;
 	struct aio_kiocb *req;
 	ssize_t ret;
 
@@ -2168,23 +2149,26 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 		return -EINVAL;
 	}
 
+	if (unlikely(iocb->aio_lio_opcode >= ARRAY_SIZE(aio_submit_info)))
+		return -EINVAL;
+	submit_info = &aio_submit_info[iocb->aio_lio_opcode];
+	if (unlikely(!submit_info->fn))
+		return -EINVAL;
+
 	req = aio_get_req(ctx);
 	if (unlikely(!req))
 		return -EAGAIN;
 
-	if (iocb->aio_lio_opcode == IOCB_CMD_OPENAT)
-		req->common.ki_filp = NULL;
-	else {
+	if (submit_info->flags & NEED_FD) {
 		req->common.ki_filp = fget(iocb->aio_fildes);
 		if (unlikely(!req->common.ki_filp)) {
 			ret = -EBADF;
 			goto out_put_req;
 		}
+		req->common.ki_flags = iocb_flags(req->common.ki_filp);
 	}
 	req->common.ki_pos = iocb->aio_offset;
 	req->common.ki_complete = aio_complete;
-	if (req->common.ki_filp)
-		req->common.ki_flags = iocb_flags(req->common.ki_filp);
 
 	if (iocb->aio_flags & IOCB_FLAG_RESFD) {
 		/*
@@ -2212,10 +2196,20 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	req->ki_user_iocb = user_iocb;
 	req->ki_user_data = iocb->aio_data;
 
-	ret = aio_run_iocb(req, iocb, compat);
-	if (ret)
-		goto out_put_req;
-
+	ret = submit_info->fn(req, iocb, compat);
+	if (ret != -EIOCBQUEUED) {
+		/*
+		 * There's no easy way to restart the syscall since other AIO's
+		 * may be already running. Just fail this IO with EINTR.
+		 */
+		if (unlikely(ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
+			     ret == -ERESTARTNOHAND ||
+			     ret == -ERESTART_RESTARTBLOCK))
+			ret = -EINTR;
+		else if (IS_ERR_VALUE(ret))
+			goto out_put_req;
+		aio_complete(&req->common, ret, 0);
+	}
 	return 0;
 out_put_req:
 	put_reqs_available(ctx, 1);
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
