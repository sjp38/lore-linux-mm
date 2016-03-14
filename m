Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 14 Mar 2016 13:17:37 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: aio openat Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160314171737.GK17923@kvack.org>
References: <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com> <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com> <20160115202131.GH6330@kvack.org> <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com> <20160120195957.GV6033@dastard> <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com> <20160120204449.GC12249@kvack.org> <20160120214546.GX6033@dastard> <CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com> <20160123043922.GF6033@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160123043922.GF6033@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Sat, Jan 23, 2016 at 03:39:22PM +1100, Dave Chinner wrote:
> On Wed, Jan 20, 2016 at 03:07:26PM -0800, Linus Torvalds wrote:
...
> > We could do things like that for the name loopkup for openat() too, where
> > we could handle the successful RCU loopkup synchronously, but then if we
> > fall out of RCU mode we'd do the thread.
> 
> We'd have to do quite a bit of work to unwind back out to the AIO
> layer before we can dispatch the open operation again in a thread,
> wouldn't we?

I had some time last week to make an aio openat do what it can in 
submit context.  The results are an improvement: when openat is handled 
in submit context it completes in about half the time it takes compared 
to the round trip via the work queue, and it's not terribly much code 
either.

		-ben
-- 
"Thought is the essence of where you are now."

 fs/aio.c              |  122 +++++++++++++++++++++++++++++++++++++++++---------
 fs/internal.h         |    1 
 fs/namei.c            |   16 ++++--
 fs/open.c             |    2 
 include/linux/namei.h |    1 
 5 files changed, 117 insertions(+), 25 deletions(-)

commit 5d3d80fcf99287decc4774af01967cebbb0242fd
Author: Benjamin LaHaise <bcrl@kvack.org>
Date:   Thu Mar 10 17:15:07 2016 -0500

    aio: add support for in-submit openat
    
    Using the LOOKUP_RCU infrastructure added for open(), implement such
    functionality to enable in io_submit() openat() that does a non-blocking
    file open operation.  This avoids the overhead of punting to another
    kernel thread to complete the open operation when the files and data are
    already in the dcache.  This helps cut simple aio openat() from ~60-90K
    cycles to ~24-45K cycles on my test system.
    
    Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

diff --git a/fs/aio.c b/fs/aio.c
index 0a9309e..67c58b6 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -42,6 +42,8 @@
 #include <linux/mount.h>
 #include <linux/fdtable.h>
 #include <linux/fs_struct.h>
+#include <linux/fsnotify.h>
+#include <linux/namei.h>
 #include <../mm/internal.h>
 
 #include <asm/kmap_types.h>
@@ -163,6 +165,7 @@ struct kioctx {
 
 struct aio_kiocb;
 typedef long (*aio_thread_work_fn_t)(struct aio_kiocb *iocb);
+typedef void (*aio_destruct_fn_t)(struct aio_kiocb *iocb);
 
 /*
  * We use ki_cancel == KIOCB_CANCELLED to indicate that a kiocb has been either
@@ -210,6 +213,7 @@ struct aio_kiocb {
 #if IS_ENABLED(CONFIG_AIO_THREAD)
 	struct task_struct	*ki_cancel_task;
 	unsigned long		ki_data;
+	unsigned long		ki_data2;
 	unsigned long		ki_rlimit_fsize;
 	unsigned		ki_thread_flags;	/* AIO_THREAD_NEED... */
 	aio_thread_work_fn_t	ki_work_fn;
@@ -217,6 +221,7 @@ struct aio_kiocb {
 	struct fs_struct	*ki_fs;
 	struct files_struct	*ki_files;
 	const struct cred	*ki_cred;
+	aio_destruct_fn_t	ki_destruct_fn;
 #endif
 };
 
@@ -1093,6 +1098,8 @@ out_put:
 
 static void kiocb_free(struct aio_kiocb *req)
 {
+	if (req->ki_destruct_fn)
+		req->ki_destruct_fn(req);
 	if (req->common.ki_filp)
 		fput(req->common.ki_filp);
 	if (req->ki_eventfd != NULL)
@@ -1546,6 +1553,18 @@ static void aio_thread_fn(struct work_struct *work)
 		     ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK))
 		ret = -EINTR;
 
+	/* Completion serializes cancellation by taking ctx_lock, so
+	 * aio_complete() will not return until after force_sig() in
+	 * aio_thread_queue_iocb_cancel().  This should ensure that
+	 * the signal is pending before being flushed in this thread.
+	 */
+	aio_complete(&iocb->common, ret, 0);
+	if (fatal_signal_pending(current))
+		flush_signals(current);
+
+	/* Clean up state after aio_complete() since ki_destruct may still
+	 * need to access them.
+	 */
 	if (iocb->ki_cred) {
 		current->cred = old_cred;
 		put_cred(iocb->ki_cred);
@@ -1558,15 +1577,6 @@ static void aio_thread_fn(struct work_struct *work)
 		exit_fs(current);
 		current->fs = old_fs;
 	}
-
-	/* Completion serializes cancellation by taking ctx_lock, so
-	 * aio_complete() will not return until after force_sig() in
-	 * aio_thread_queue_iocb_cancel().  This should ensure that
-	 * the signal is pending before being flushed in this thread.
-	 */
-	aio_complete(&iocb->common, ret, 0);
-	if (fatal_signal_pending(current))
-		flush_signals(current);
 }
 
 /* aio_thread_queue_iocb
@@ -1758,11 +1768,6 @@ static long aio_poll(struct aio_kiocb *req, struct iocb *user_iocb, bool compat)
 	return aio_thread_queue_iocb(req, aio_thread_op_poll, 0);
 }
 
-static long aio_do_openat(int fd, const char *filename, int flags, int mode)
-{
-	return do_sys_open(fd, filename, flags, mode);
-}
-
 static long aio_do_unlinkat(int fd, const char *filename, int flags, int mode)
 {
 	if (flags || mode)
@@ -1793,14 +1798,91 @@ static long aio_thread_op_foo_at(struct aio_kiocb *req)
 	return ret;
 }
 
+static void openat_destruct(struct aio_kiocb *req)
+{
+	struct filename *filename = req->common.private;
+	int fd;
+
+	putname(filename);
+	fd = req->ki_data;
+	if (fd >= 0)
+		put_unused_fd(fd);
+}
+
+static long aio_thread_op_openat(struct aio_kiocb *req)
+{
+	struct filename *filename = req->common.private;
+	int mode = req->common.ki_pos >> 32;
+	int flags = req->common.ki_pos;
+	struct open_flags op;
+	struct file *f;
+	int dfd = req->ki_data2;
+
+	build_open_flags(flags, mode, &op);
+	f = do_filp_open(dfd, filename, &op);
+	if (!IS_ERR(f)) {
+		int fd = req->ki_data;
+		/* Prevent openat_destruct from doing put_unused_fd() */
+		req->ki_data = -1;
+		fsnotify_open(f);
+		fd_install(fd, f);
+		return fd;
+	}
+	return PTR_ERR(f);
+}
+
 static long aio_openat(struct aio_kiocb *req, struct iocb *uiocb, bool compat)
 {
-	req->ki_data = (unsigned long)(void *)aio_do_openat;
-	return aio_thread_queue_iocb(req, aio_thread_op_foo_at,
-				     AIO_THREAD_NEED_TASK |
-				     AIO_THREAD_NEED_MM |
-				     AIO_THREAD_NEED_FILES |
-				     AIO_THREAD_NEED_CRED);
+	int mode = req->common.ki_pos >> 32;
+	struct filename *filename;
+	struct open_flags op;
+	int flags;
+	int fd;
+
+	if (force_o_largefile())
+		req->common.ki_pos |= O_LARGEFILE;
+	flags = req->common.ki_pos;
+	fd = build_open_flags(flags, mode, &op);
+	if (fd)
+		goto out_err;
+
+	filename = getname((const char __user *)(long)uiocb->aio_buf);
+	if (IS_ERR(filename)) {
+		fd = PTR_ERR(filename);
+		goto out_err;
+	}
+	req->common.private = filename;
+	req->ki_destruct_fn = openat_destruct;
+	req->ki_data = fd = get_unused_fd_flags(flags);
+	if (fd >= 0) {
+		struct file *f;
+		op.lookup_flags |= LOOKUP_RCU | LOOKUP_NONBLOCK;
+		req->ki_data = fd;
+		req->ki_data2 = uiocb->aio_fildes;
+		f = do_filp_open(uiocb->aio_fildes, filename, &op);
+		if (IS_ERR(f) && ((PTR_ERR(f) == -ECHILD) ||
+				  (PTR_ERR(f) == -ESTALE) ||
+				  (PTR_ERR(f) == -EAGAIN))) {
+			int ret;
+			ret = aio_thread_queue_iocb(req, aio_thread_op_openat,
+						   AIO_THREAD_NEED_TASK |
+						   AIO_THREAD_NEED_FILES |
+						   AIO_THREAD_NEED_CRED);
+			if (ret == -EIOCBQUEUED)
+				return ret;
+			put_unused_fd(fd);
+			fd = ret;
+		} else if (IS_ERR(f)) {
+			put_unused_fd(fd);
+			fd = PTR_ERR(f);
+		} else {
+			fsnotify_open(f);
+			fd_install(fd, f);
+		}
+	}
+out_err:
+	aio_complete(&req->common, fd, 0);
+	return -EIOCBQUEUED;
 }
 
 static long aio_unlink(struct aio_kiocb *req, struct iocb *uiocb, bool compt)
diff --git a/fs/internal.h b/fs/internal.h
index 57b6010..c421572 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -102,6 +102,7 @@ struct open_flags {
 	int intent;
 	int lookup_flags;
 };
+extern int build_open_flags(int flags, umode_t mode, struct open_flags *op);
 extern struct file *do_filp_open(int dfd, struct filename *pathname,
 		const struct open_flags *op);
 extern struct file *do_file_open_root(struct dentry *, struct vfsmount *,
diff --git a/fs/namei.c b/fs/namei.c
index 84ecc7e..260782f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3079,6 +3079,12 @@ retry_lookup:
 		 * dropping this one anyway.
 		 */
 	}
+
+	if (nd->flags & LOOKUP_NONBLOCK) {
+		error = -EAGAIN;
+		goto out;
+	}
+		
 	mutex_lock(&dir->d_inode->i_mutex);
 	error = lookup_open(nd, &path, file, op, got_write, opened);
 	mutex_unlock(&dir->d_inode->i_mutex);
@@ -3356,10 +3362,12 @@ struct file *do_filp_open(int dfd, struct filename *pathname,
 
 	set_nameidata(&nd, dfd, pathname);
 	filp = path_openat(&nd, op, flags | LOOKUP_RCU);
-	if (unlikely(filp == ERR_PTR(-ECHILD)))
-		filp = path_openat(&nd, op, flags);
-	if (unlikely(filp == ERR_PTR(-ESTALE)))
-		filp = path_openat(&nd, op, flags | LOOKUP_REVAL);
+	if (!(op->lookup_flags & LOOKUP_RCU)) {
+		if (unlikely(filp == ERR_PTR(-ECHILD)))
+			filp = path_openat(&nd, op, flags);
+		if (unlikely(filp == ERR_PTR(-ESTALE)))
+			filp = path_openat(&nd, op, flags | LOOKUP_REVAL);
+	}
 	restore_nameidata();
 	return filp;
 }
diff --git a/fs/open.c b/fs/open.c
index b6f1e96..f6a45cb 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -884,7 +884,7 @@ struct file *dentry_open(const struct path *path, int flags,
 }
 EXPORT_SYMBOL(dentry_open);
 
-static inline int build_open_flags(int flags, umode_t mode, struct open_flags *op)
+inline int build_open_flags(int flags, umode_t mode, struct open_flags *op)
 {
 	int lookup_flags = 0;
 	int acc_mode;
diff --git a/include/linux/namei.h b/include/linux/namei.h
index d8c6334..1e76579 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -43,6 +43,7 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_JUMPED		0x1000
 #define LOOKUP_ROOT		0x2000
 #define LOOKUP_EMPTY		0x4000
+#define LOOKUP_NONBLOCK		0x8000
 
 extern int user_path_at_empty(int, const char __user *, unsigned, struct path *, int *empty);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
