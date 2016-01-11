Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:14 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 06/13] aio: add queue_work() based threaded aio support
Message-ID: <0137ed2415708f90c4d96372c41371f7d489fa59.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Add support for performing asynchronous reads and writes via kernel
threads by way of the queue_work() functionality.  This enables fully
asynchronous and cancellable reads and writes for any file or device in
the kernel.  Cancellation is implemented by sending a SIGKILL to the
kernel thread executing the async operation.  So long as the read or
write operation can be interrupted by signals, the AIO request can be
cancelled.

This functionality is currently disabled by default until the DoS
implications of having user controlled kernel thread creation are fully
understood.  When compiled into the kernel, this functionality can be
enabled by setting the fs.aio-auto-threads sysctl to 1.  It is expected
that the feature will be enabled by default in a future kernel version.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c            | 236 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/aio.h |   4 +
 include/linux/fs.h  |   2 +
 init/Kconfig        |  13 +++
 kernel/sysctl.c     |   9 ++
 5 files changed, 264 insertions(+)

diff --git a/fs/aio.c b/fs/aio.c
index 55c8ff5..88af450 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -48,6 +48,7 @@
 
 #define AIO_RING_MAGIC			0xa10a10a1
 #define AIO_RING_COMPAT_FEATURES	1
+#define AIO_RING_COMPAT_THREADED	2
 #define AIO_RING_INCOMPAT_FEATURES	0
 struct aio_ring {
 	unsigned	id;	/* kernel internal index number */
@@ -157,6 +158,9 @@ struct kioctx {
 	struct mm_struct	*mm;
 };
 
+struct aio_kiocb;
+typedef long (*aio_thread_work_fn_t)(struct aio_kiocb *iocb);
+
 /*
  * We use ki_cancel == KIOCB_CANCELLED to indicate that a kiocb has been either
  * cancelled or completed (this makes a certain amount of sense because
@@ -194,12 +198,21 @@ struct aio_kiocb {
 
 	/* Fields used for threaded aio helper. */
 	struct task_struct	*ki_submit_task;
+#if IS_ENABLED(CONFIG_AIO_THREAD)
+	struct task_struct	*ki_cancel_task;
+	unsigned long		ki_rlimit_fsize;
+	aio_thread_work_fn_t	ki_work_fn;
+	struct work_struct	ki_work;
+#endif
 };
 
 /*------ sysctl variables----*/
 static DEFINE_SPINLOCK(aio_nr_lock);
 unsigned long aio_nr;		/* current system wide number of aio requests */
 unsigned long aio_max_nr = 0x10000; /* system wide maximum number of aio requests */
+#if IS_ENABLED(CONFIG_AIO_THREAD)
+unsigned long aio_auto_threads;	/* Currently disabled by default */
+#endif
 /*----end sysctl variables---*/
 
 static struct kmem_cache	*kiocb_cachep;
@@ -212,6 +225,15 @@ static const struct address_space_operations aio_ctx_aops;
 
 static void aio_complete(struct kiocb *kiocb, long res, long res2);
 
+static bool aio_may_use_threads(void)
+{
+#if IS_ENABLED(CONFIG_AIO_THREAD)
+	return !!(aio_auto_threads & 1);
+#else
+	return false;
+#endif
+}
+
 static struct file *aio_private_file(struct kioctx *ctx, loff_t nr_pages)
 {
 	struct qstr this = QSTR_INIT("[aio]", 5);
@@ -528,6 +550,8 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ring->head = ring->tail = 0;
 	ring->magic = AIO_RING_MAGIC;
 	ring->compat_features = AIO_RING_COMPAT_FEATURES;
+	if (aio_may_use_threads())
+		ring->compat_features |= AIO_RING_COMPAT_THREADED;
 	ring->incompat_features = AIO_RING_INCOMPAT_FEATURES;
 	ring->header_length = sizeof(struct aio_ring);
 	kunmap_atomic(ring);
@@ -1436,6 +1460,202 @@ static int aio_setup_vectored_rw(int rw, char __user *buf, size_t len,
 				len, UIO_FASTIOV, iovec, iter);
 }
 
+#if IS_ENABLED(CONFIG_AIO_THREAD)
+/* aio_thread_queue_iocb_cancel_early:
+ *	Early stage cancellation helper function for threaded aios.  This
+ *	is used prior to the iocb being assigned to a worker thread.
+ */
+static int aio_thread_queue_iocb_cancel_early(struct kiocb *iocb)
+{
+	return 0;
+}
+
+/* aio_thread_queue_iocb_cancel:
+ *	Late stage cancellation method for threaded aios.  Once an iocb is
+ *	assigned to a worker thread, we use a fatal signal to interrupt an
+ *	in-progress operation.
+ */
+static int aio_thread_queue_iocb_cancel(struct kiocb *kiocb)
+{
+	struct aio_kiocb *iocb = container_of(kiocb, struct aio_kiocb, common);
+
+	if (iocb->ki_cancel_task) {
+		force_sig(SIGKILL, iocb->ki_cancel_task);
+		return 0;
+	}
+	return -EAGAIN;
+}
+
+/* aio_thread_fn:
+ *	Entry point for worker to perform threaded aio.  Handles issues
+ *	arising due to cancellation using signals.
+ */
+static void aio_thread_fn(struct work_struct *work)
+{
+	struct aio_kiocb *iocb = container_of(work, struct aio_kiocb, ki_work);
+	kiocb_cancel_fn *old_cancel;
+	long ret;
+
+	iocb->ki_cancel_task = current;
+	current->kiocb = &iocb->common;		/* For io_send_sig(). */
+	WARN_ON(atomic_read(&current->signal->sigcnt) != 1);
+
+	/* Check for early stage cancellation and switch to late stage
+	 * cancellation if it has not already occurred.
+	 */
+	old_cancel = cmpxchg(&iocb->ki_cancel,
+			     aio_thread_queue_iocb_cancel_early,
+			     aio_thread_queue_iocb_cancel);
+	if (old_cancel != KIOCB_CANCELLED)
+		ret = iocb->ki_work_fn(iocb);
+	else
+		ret = -EINTR;
+
+	current->kiocb = NULL;
+	if (unlikely(ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
+		     ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK))
+		ret = -EINTR;
+
+	/* Completion serializes cancellation by taking ctx_lock, so
+	 * aio_complete() will not return until after force_sig() in
+	 * aio_thread_queue_iocb_cancel().  This should ensure that
+	 * the signal is pending before being flushed in this thread.
+	 */
+	aio_complete(&iocb->common, ret, 0);
+	if (fatal_signal_pending(current))
+		flush_signals(current);
+}
+
+#define AIO_THREAD_NEED_TASK	0x0001	/* Need aio_kiocb->ki_submit_task */
+
+/* aio_thread_queue_iocb
+ *	Queues an aio_kiocb for dispatch to a worker thread.  Prepares the
+ *	aio_kiocb for cancellation.  The caller must provide a function to
+ *	execute the operation in work_fn.  The flags may be provided as an
+ *	ored set AIO_THREAD_xxx.
+ */
+static ssize_t aio_thread_queue_iocb(struct aio_kiocb *iocb,
+				     aio_thread_work_fn_t work_fn,
+				     unsigned flags)
+{
+	INIT_WORK(&iocb->ki_work, aio_thread_fn);
+	iocb->ki_work_fn = work_fn;
+	if (flags & AIO_THREAD_NEED_TASK) {
+		iocb->ki_submit_task = current;
+		get_task_struct(iocb->ki_submit_task);
+	}
+
+	/* Cancellation needs to be always available for operations performed
+	 * using helper threads.  Prior to the iocb being assigned to a worker
+	 * thread, we need to record that a cancellation has occurred.  We
+	 * can do this by having a minimal helper function that is recorded in
+	 * ki_cancel.
+	 */
+	kiocb_set_cancel_fn(&iocb->common, aio_thread_queue_iocb_cancel_early);
+	queue_work(system_long_wq, &iocb->ki_work);
+	return -EIOCBQUEUED;
+}
+
+static long aio_thread_op_read_iter(struct aio_kiocb *iocb)
+{
+	struct file *filp;
+	long ret;
+
+	use_mm(iocb->ki_ctx->mm);
+	filp = iocb->common.ki_filp;
+
+	if (filp->f_op->read_iter) {
+		struct kiocb sync_kiocb;
+
+		init_sync_kiocb(&sync_kiocb, filp);
+		sync_kiocb.ki_pos = iocb->common.ki_pos;
+		ret = filp->f_op->read_iter(&sync_kiocb, &iocb->ki_iter);
+	} else if (filp->f_op->read)
+		ret = do_loop_readv_writev(filp, &iocb->ki_iter,
+					   &iocb->common.ki_pos,
+					   filp->f_op->read);
+	else
+		ret = -EINVAL;
+	unuse_mm(iocb->ki_ctx->mm);
+	return ret;
+}
+
+ssize_t generic_async_read_iter_non_direct(struct kiocb *iocb,
+					   struct iov_iter *iter)
+{
+	if ((iocb->ki_flags & IOCB_DIRECT) ||
+	    (iocb->ki_complete != aio_complete))
+		return iocb->ki_filp->f_op->read_iter(iocb, iter);
+	return generic_async_read_iter(iocb, iter);
+}
+EXPORT_SYMBOL(generic_async_read_iter_non_direct);
+
+ssize_t generic_async_read_iter(struct kiocb *iocb, struct iov_iter *iter)
+{
+	struct aio_kiocb *req;
+
+	req = container_of(iocb, struct aio_kiocb, common);
+	if (iter != &req->ki_iter)
+		return -EINVAL;
+
+	return aio_thread_queue_iocb(req, aio_thread_op_read_iter,
+				     AIO_THREAD_NEED_TASK);
+}
+EXPORT_SYMBOL(generic_async_read_iter);
+
+static long aio_thread_op_write_iter(struct aio_kiocb *iocb)
+{
+	u64 saved_rlim_fsize;
+	struct file *filp;
+	long ret;
+
+	use_mm(iocb->ki_ctx->mm);
+	filp = iocb->common.ki_filp;
+	saved_rlim_fsize = rlimit(RLIMIT_FSIZE);
+	current->signal->rlim[RLIMIT_FSIZE].rlim_cur = iocb->ki_rlimit_fsize;
+
+	if (filp->f_op->write_iter) {
+		struct kiocb sync_kiocb;
+
+		init_sync_kiocb(&sync_kiocb, filp);
+		sync_kiocb.ki_pos = iocb->common.ki_pos;
+		ret = filp->f_op->write_iter(&sync_kiocb, &iocb->ki_iter);
+	} else if (filp->f_op->write)
+		ret = do_loop_readv_writev(filp, &iocb->ki_iter,
+					   &iocb->common.ki_pos,
+					   (io_fn_t)filp->f_op->write);
+	else
+		ret = -EINVAL;
+	current->signal->rlim[RLIMIT_FSIZE].rlim_cur = saved_rlim_fsize;
+	unuse_mm(iocb->ki_ctx->mm);
+	return ret;
+}
+
+ssize_t generic_async_write_iter_non_direct(struct kiocb *iocb,
+					    struct iov_iter *iter)
+{
+	if ((iocb->ki_flags & IOCB_DIRECT) ||
+	    (iocb->ki_complete != aio_complete))
+		return iocb->ki_filp->f_op->write_iter(iocb, iter);
+	return generic_async_write_iter(iocb, iter);
+}
+EXPORT_SYMBOL(generic_async_write_iter_non_direct);
+
+ssize_t generic_async_write_iter(struct kiocb *iocb, struct iov_iter *iter)
+{
+	struct aio_kiocb *req;
+
+	req = container_of(iocb, struct aio_kiocb, common);
+	if (iter != &req->ki_iter)
+		return -EINVAL;
+	req->ki_rlimit_fsize = rlimit(RLIMIT_FSIZE);
+
+	return aio_thread_queue_iocb(req, aio_thread_op_write_iter,
+				     AIO_THREAD_NEED_TASK);
+}
+EXPORT_SYMBOL(generic_async_write_iter);
+#endif /* IS_ENABLED(CONFIG_AIO_THREAD) */
+
 /*
  * aio_run_iocb:
  *	Performs the initial checks and io submission.
@@ -1454,6 +1674,14 @@ static ssize_t aio_run_iocb(struct aio_kiocb *req, unsigned opcode,
 	case IOCB_CMD_PREADV:
 		mode	= FMODE_READ;
 		rw	= READ;
+		iter_op	= file->f_op->async_read_iter;
+		if (iter_op)
+			goto rw_common;
+		if ((aio_may_use_threads()) &&
+		    (file->f_op->read_iter || file->f_op->read)) {
+			iter_op = generic_async_read_iter;
+			goto rw_common;
+		}
 		iter_op	= file->f_op->read_iter;
 		goto rw_common;
 
@@ -1461,6 +1689,14 @@ static ssize_t aio_run_iocb(struct aio_kiocb *req, unsigned opcode,
 	case IOCB_CMD_PWRITEV:
 		mode	= FMODE_WRITE;
 		rw	= WRITE;
+		iter_op	= file->f_op->async_write_iter;
+		if (iter_op)
+			goto rw_common;
+		if ((aio_may_use_threads()) &&
+		    (file->f_op->write_iter || file->f_op->write)) {
+			iter_op = generic_async_write_iter;
+			goto rw_common;
+		}
 		iter_op	= file->f_op->write_iter;
 		goto rw_common;
 rw_common:
diff --git a/include/linux/aio.h b/include/linux/aio.h
index 9a62e8a..7486f19 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -19,6 +19,9 @@ extern long do_io_submit(aio_context_t ctx_id, long nr,
 void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel);
 struct mm_struct *aio_get_mm(struct kiocb *req);
 struct task_struct *aio_get_task(struct kiocb *req);
+struct iov_iter;
+ssize_t generic_async_read_iter(struct kiocb *iocb, struct iov_iter *iter);
+ssize_t generic_async_write_iter(struct kiocb *iocb, struct iov_iter *iter);
 #else
 static inline void exit_aio(struct mm_struct *mm) { }
 static inline long do_io_submit(aio_context_t ctx_id, long nr,
@@ -34,5 +37,6 @@ static inline struct task_struct *aio_get_task(struct kiocb *req)
 /* for sysctl: */
 extern unsigned long aio_nr;
 extern unsigned long aio_max_nr;
+extern unsigned long aio_auto_threads;
 
 #endif /* __LINUX__AIO_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3aa5142..b3dc406 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1604,6 +1604,8 @@ struct file_operations {
 	ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
 	ssize_t (*read_iter) (struct kiocb *, struct iov_iter *);
 	ssize_t (*write_iter) (struct kiocb *, struct iov_iter *);
+	ssize_t (*async_read_iter) (struct kiocb *, struct iov_iter *);
+	ssize_t (*async_write_iter) (struct kiocb *, struct iov_iter *);
 	int (*iterate) (struct file *, struct dir_context *);
 	unsigned int (*poll) (struct file *, struct poll_table_struct *);
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
diff --git a/init/Kconfig b/init/Kconfig
index 235c7a2..33fb8b2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1575,6 +1575,19 @@ config AIO
 	  by some high performance threaded applications. Disabling
 	  this option saves about 7k.
 
+config AIO_THREAD
+	bool "Support kernel thread based AIO" if EXPERT
+	depends on AIO
+	default y
+	help
+	   This option enables using kernel thread based AIO which implements
+	   asynchronous operations using the kernel's queue_work() mechanism.
+	   The automatic use of threads for async operations is currently
+	   disabled by default until the security implications for usage
+	   are completely understood.  This functionality can be enabled at
+	   runtime if this option is enabled by setting the fs.aio-auto-threads
+	   to one.
+
 config ADVISE_SYSCALLS
 	bool "Enable madvise/fadvise syscalls" if EXPERT
 	default y
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index dc6858d..b5e3977 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1677,6 +1677,15 @@ static struct ctl_table fs_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+#if IS_ENABLED(CONFIG_AIO_THREAD)
+	{
+		.procname	= "aio-auto-threads",
+		.data		= &aio_auto_threads,
+		.maxlen		= sizeof(aio_auto_threads),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
+#endif
 #endif /* CONFIG_AIO */
 #ifdef CONFIG_INOTIFY_USER
 	{
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
