Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5FBE05F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:10:46 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:10:49 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m11vrz75me.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 6/9] vfs: Utilize fops_read_lock where appropriate
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/compat.c     |   31 ++++++++----
 fs/fcntl.c      |   32 ++++++++----
 fs/ioctl.c      |   39 +++++++++------
 fs/locks.c      |   81 +++++++++++++++++++++++++------
 fs/open.c       |   12 ++++-
 fs/read_write.c |  143 ++++++++++++++++++++++++++++++++++++++++++-------------
 fs/readdir.c    |   14 ++++-
 fs/select.c     |   17 +++++-
 8 files changed, 276 insertions(+), 93 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 3f84d5f..a73ca0d 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1090,6 +1090,7 @@ out:
 #endif /* ! __ARCH_OMIT_COMPAT_SYS_GETDENTS64 */
 
 static ssize_t compat_do_readv_writev(int type, struct file *file,
+			       const struct file_operations *f_op,
 			       const struct compat_iovec __user *uvector,
 			       unsigned long nr_segs, loff_t *pos)
 {
@@ -1117,7 +1118,7 @@ static ssize_t compat_do_readv_writev(int type, struct file *file,
 	ret = -EINVAL;
 	if ((nr_segs > UIO_MAXIOV) || (nr_segs <= 0))
 		goto out;
-	if (!file->f_op)
+	if (!f_op)
 		goto out;
 	if (nr_segs > UIO_FASTIOV) {
 		ret = -ENOMEM;
@@ -1170,11 +1171,11 @@ static ssize_t compat_do_readv_writev(int type, struct file *file,
 
 	fnv = NULL;
 	if (type == READ) {
-		fn = file->f_op->read;
-		fnv = file->f_op->aio_read;
+		fn = f_op->read;
+		fnv = f_op->aio_read;
 	} else {
-		fn = (io_fn_t)file->f_op->write;
-		fnv = file->f_op->aio_write;
+		fn = (io_fn_t)f_op->write;
+		fnv = f_op->aio_write;
 	}
 
 	if (fnv)
@@ -1200,21 +1201,27 @@ static size_t compat_readv(struct file *file,
 			   const struct compat_iovec __user *vec,
 			   unsigned long vlen, loff_t *pos)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
 	ssize_t ret = -EBADF;
 
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
+
 	if (!(file->f_mode & FMODE_READ))
 		goto out;
 
 	ret = -EINVAL;
-	if (!file->f_op || (!file->f_op->aio_read && !file->f_op->read))
+	if (!f_op || (!f_op->aio_read && !f_op->read))
 		goto out;
 
-	ret = compat_do_readv_writev(READ, file, vec, vlen, pos);
+	ret = compat_do_readv_writev(READ, file, f_op, vec, vlen, pos);
 
 out:
 	if (ret > 0)
 		add_rchar(current, ret);
 	inc_syscr(current);
+	fops_read_unlock(file, fops_idx);
 	return ret;
 }
 
@@ -1257,21 +1264,27 @@ static size_t compat_writev(struct file *file,
 			    const struct compat_iovec __user *vec,
 			    unsigned long vlen, loff_t *pos)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
 	ssize_t ret = -EBADF;
 
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
+
 	if (!(file->f_mode & FMODE_WRITE))
 		goto out;
 
 	ret = -EINVAL;
-	if (!file->f_op || (!file->f_op->aio_write && !file->f_op->write))
+	if (!f_op || (!f_op->aio_write && !f_op->write))
 		goto out;
 
-	ret = compat_do_readv_writev(WRITE, file, vec, vlen, pos);
+	ret = compat_do_readv_writev(WRITE, file, f_op, vec, vlen, pos);
 
 out:
 	if (ret > 0)
 		add_wchar(current, ret);
 	inc_syscw(current);
+	fops_read_unlock(file, fops_idx);
 	return ret;
 }
 
diff --git a/fs/fcntl.c b/fs/fcntl.c
index cc8e4de..2718aea 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -146,42 +146,51 @@ SYSCALL_DEFINE1(dup, unsigned int, fildes)
 static int setfl(int fd, struct file * filp, unsigned long arg)
 {
 	struct inode * inode = filp->f_path.dentry->d_inode;
-	int error = 0;
+	const struct file_operations *f_op;
+	int fops_idx;
+	int error;
+
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
 
 	/*
 	 * O_APPEND cannot be cleared if the file is marked as append-only
 	 * and the file is open for write.
 	 */
+	error = -EPERM;
 	if (((arg ^ filp->f_flags) & O_APPEND) && IS_APPEND(inode))
-		return -EPERM;
+		goto out;
 
 	/* O_NOATIME can only be set by the owner or superuser */
+	error = -EPERM;
 	if ((arg & O_NOATIME) && !(filp->f_flags & O_NOATIME))
 		if (!is_owner_or_cap(inode))
-			return -EPERM;
+			goto out;
 
 	/* required for strict SunOS emulation */
 	if (O_NONBLOCK != O_NDELAY)
 	       if (arg & O_NDELAY)
 		   arg |= O_NONBLOCK;
 
+	error = -EINVAL;
 	if (arg & O_DIRECT) {
 		if (!filp->f_mapping || !filp->f_mapping->a_ops ||
-			!filp->f_mapping->a_ops->direct_IO)
-				return -EINVAL;
+		    !filp->f_mapping->a_ops->direct_IO)
+			goto out;
 	}
 
-	if (filp->f_op && filp->f_op->check_flags)
-		error = filp->f_op->check_flags(arg);
+	error = 0;
+	if (f_op && f_op->check_flags)
+		error = f_op->check_flags(arg);
 	if (error)
-		return error;
+		goto out;
 
 	/*
 	 * ->fasync() is responsible for setting the FASYNC bit.
 	 */
-	if (((arg ^ filp->f_flags) & FASYNC) && filp->f_op &&
-			filp->f_op->fasync) {
-		error = filp->f_op->fasync(fd, filp, (arg & FASYNC) != 0);
+	if (((arg ^ filp->f_flags) & FASYNC) && f_op &&
+			f_op->fasync) {
+		error = f_op->fasync(fd, filp, (arg & FASYNC) != 0);
 		if (error < 0)
 			goto out;
 		if (error > 0)
@@ -192,6 +201,7 @@ static int setfl(int fd, struct file * filp, unsigned long arg)
 	spin_unlock(&filp->f_lock);
 
  out:
+	fops_read_unlock(filp, fops_idx);
 	return error;
 }
 
diff --git a/fs/ioctl.c b/fs/ioctl.c
index ac2d47e..158030b 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -33,23 +33,23 @@
  *
  * Returns 0 on success, -errno on error.
  */
-static long vfs_ioctl(struct file *filp, unsigned int cmd,
-		      unsigned long arg)
+static long vfs_ioctl(struct file *filp, const struct file_operations *f_op,
+		      unsigned int cmd, unsigned long arg)
 {
 	int error = -ENOTTY;
 
-	if (!filp->f_op)
+	if (!f_op)
 		goto out;
 
-	if (filp->f_op->unlocked_ioctl) {
-		error = filp->f_op->unlocked_ioctl(filp, cmd, arg);
+	if (f_op->unlocked_ioctl) {
+		error = f_op->unlocked_ioctl(filp, cmd, arg);
 		if (error == -ENOIOCTLCMD)
 			error = -EINVAL;
 		goto out;
-	} else if (filp->f_op->ioctl) {
+	} else if (f_op->ioctl) {
 		lock_kernel();
-		error = filp->f_op->ioctl(filp->f_path.dentry->d_inode,
-					  filp, cmd, arg);
+		error = f_op->ioctl(filp->f_path.dentry->d_inode, filp,
+				    cmd, arg);
 		unlock_kernel();
 	}
 
@@ -370,8 +370,8 @@ EXPORT_SYMBOL(generic_block_fiemap);
 
 #endif  /*  CONFIG_BLOCK  */
 
-static int file_ioctl(struct file *filp, unsigned int cmd,
-		unsigned long arg)
+static int file_ioctl(struct file *filp, const struct file_operations *f_op,
+		unsigned int cmd, unsigned long arg)
 {
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	int __user *p = (int __user *)arg;
@@ -387,7 +387,7 @@ static int file_ioctl(struct file *filp, unsigned int cmd,
 		return put_user(i_size_read(inode) - filp->f_pos, p);
 	}
 
-	return vfs_ioctl(filp, cmd, arg);
+	return vfs_ioctl(filp, f_op, cmd, arg);
 }
 
 static int ioctl_fionbio(struct file *filp, int __user *argp)
@@ -414,6 +414,7 @@ static int ioctl_fionbio(struct file *filp, int __user *argp)
 }
 
 static int ioctl_fioasync(unsigned int fd, struct file *filp,
+			  const struct file_operations *f_op,
 			  int __user *argp)
 {
 	unsigned int flag;
@@ -426,9 +427,9 @@ static int ioctl_fioasync(unsigned int fd, struct file *filp,
 
 	/* Did FASYNC state change ? */
 	if ((flag ^ filp->f_flags) & FASYNC) {
-		if (filp->f_op && filp->f_op->fasync)
+		if (f_op && f_op->fasync)
 			/* fasync() adjusts filp->f_flags */
-			error = filp->f_op->fasync(fd, filp, on);
+			error = f_op->fasync(fd, filp, on);
 		else
 			error = -ENOTTY;
 	}
@@ -482,9 +483,14 @@ static int ioctl_fsthaw(struct file *filp)
 int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
 	     unsigned long arg)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
 	int error = 0;
 	int __user *argp = (int __user *)arg;
 
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
 	switch (cmd) {
 	case FIOCLEX:
 		set_close_on_exec(fd, 1);
@@ -499,7 +505,7 @@ int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
 		break;
 
 	case FIOASYNC:
-		error = ioctl_fioasync(fd, filp, argp);
+		error = ioctl_fioasync(fd, filp, f_op, argp);
 		break;
 
 	case FIOQSIZE:
@@ -524,11 +530,12 @@ int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
 
 	default:
 		if (S_ISREG(filp->f_path.dentry->d_inode->i_mode))
-			error = file_ioctl(filp, cmd, arg);
+			error = file_ioctl(filp, f_op, cmd, arg);
 		else
-			error = vfs_ioctl(filp, cmd, arg);
+			error = vfs_ioctl(filp, f_op, cmd, arg);
 		break;
 	}
+	fops_read_unlock(filp, fops_idx);
 	return error;
 }
 
diff --git a/fs/locks.c b/fs/locks.c
index ec3deea..5ff959e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1463,15 +1463,21 @@ EXPORT_SYMBOL(generic_setlease);
 
 int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
 	int error;
 
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
 	lock_kernel();
-	if (filp->f_op && filp->f_op->setlease)
-		error = filp->f_op->setlease(filp, arg, lease);
+	if (f_op && f_op->setlease)
+		error = f_op->setlease(filp, arg, lease);
 	else
 		error = generic_setlease(filp, arg, lease);
 	unlock_kernel();
 
+	fops_read_unlock(filp, fops_idx);
 	return error;
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
@@ -1566,9 +1572,11 @@ EXPORT_SYMBOL(flock_lock_file_wait);
  */
 SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 {
+	const struct file_operations *f_op;
 	struct file *filp;
 	struct file_lock *lock;
 	int can_sleep, unlock;
+	int fops_idx;
 	int error;
 
 	error = -EBADF;
@@ -1594,13 +1602,18 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 	if (error)
 		goto out_free;
 
-	if (filp->f_op && filp->f_op->flock)
-		error = filp->f_op->flock(filp,
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
+	if (f_op && f_op->flock)
+		error = f_op->flock(filp,
 					  (can_sleep) ? F_SETLKW : F_SETLK,
 					  lock);
 	else
 		error = flock_lock_file_wait(filp, lock);
 
+	fops_read_unlock(filp, fops_idx);
+
  out_free:
 	locks_free_lock(lock);
 
@@ -1620,10 +1633,20 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
  */
 int vfs_test_lock(struct file *filp, struct file_lock *fl)
 {
-	if (filp->f_op && filp->f_op->lock)
-		return filp->f_op->lock(filp, F_GETLK, fl);
-	posix_test_lock(filp, fl);
-	return 0;
+	const struct file_operations *f_op;
+	int fops_idx;
+	int ret = 0;
+
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
+	if (f_op && f_op->lock)
+		ret = filp->f_op->lock(filp, F_GETLK, fl);
+	else
+		posix_test_lock(filp, fl);
+
+	fops_read_unlock(filp, fops_idx);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(vfs_test_lock);
 
@@ -1732,10 +1755,20 @@ out:
  */
 int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl, struct file_lock *conf)
 {
-	if (filp->f_op && filp->f_op->lock)
-		return filp->f_op->lock(filp, cmd, fl);
+	const struct file_operations *f_op;
+	int fops_idx;
+	int ret;
+
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
+	if (f_op && f_op->lock)
+		ret = f_op->lock(filp, cmd, fl);
 	else
-		return posix_lock_file(filp, fl, conf);
+		ret = posix_lock_file(filp, fl, conf);
+
+	fops_read_unlock(filp, fops_idx);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(vfs_lock_file);
 
@@ -1999,13 +2032,18 @@ EXPORT_SYMBOL(locks_remove_posix);
 void locks_remove_flock(struct file *filp)
 {
 	struct inode * inode = filp->f_path.dentry->d_inode;
+	const struct file_operations *f_op;
 	struct file_lock *fl;
 	struct file_lock **before;
+	int fops_idx;
 
 	if (!inode->i_flock)
 		return;
 
-	if (filp->f_op && filp->f_op->flock) {
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
+	if (f_op && f_op->flock) {
 		struct file_lock fl = {
 			.fl_pid = current->tgid,
 			.fl_file = filp,
@@ -2013,11 +2051,13 @@ void locks_remove_flock(struct file *filp)
 			.fl_type = F_UNLCK,
 			.fl_end = OFFSET_MAX,
 		};
-		filp->f_op->flock(filp, F_SETLKW, &fl);
+		f_op->flock(filp, F_SETLKW, &fl);
 		if (fl.fl_ops && fl.fl_ops->fl_release_private)
 			fl.fl_ops->fl_release_private(&fl);
 	}
 
+	fops_read_unlock(filp, fops_idx);
+
 	lock_kernel();
 	before = &inode->i_flock;
 
@@ -2071,9 +2111,18 @@ EXPORT_SYMBOL(posix_unblock_lock);
  */
 int vfs_cancel_lock(struct file *filp, struct file_lock *fl)
 {
-	if (filp->f_op && filp->f_op->lock)
-		return filp->f_op->lock(filp, F_CANCELLK, fl);
-	return 0;
+	const struct file_operations *f_op;
+	int fops_idx;
+	int ret = 0;
+
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
+	if (f_op && f_op->lock)
+		ret = f_op->lock(filp, F_CANCELLK, fl);
+
+	fops_read_unlock(filp, fops_idx);
+	return ret;
 }
 
 EXPORT_SYMBOL_GPL(vfs_cancel_lock);
diff --git a/fs/open.c b/fs/open.c
index 0b75dde..67031e7 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -398,6 +398,7 @@ SYSCALL_DEFINE(fallocate)(int fd, int mode, loff_t offset, loff_t len)
 		goto out;
 	if (!(file->f_mode & FMODE_WRITE))
 		goto out_fput;
+
 	/*
 	 * Revalidate the write permissions, in case security policy has
 	 * changed since the files were opened.
@@ -1107,6 +1108,8 @@ SYSCALL_DEFINE2(creat, const char __user *, pathname, int, mode)
  */
 int filp_close(struct file *filp, fl_owner_t id)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
 	int retval = 0;
 
 	if (!file_count(filp)) {
@@ -1114,8 +1117,13 @@ int filp_close(struct file *filp, fl_owner_t id)
 		return 0;
 	}
 
-	if (filp->f_op && filp->f_op->flush)
-		retval = filp->f_op->flush(filp, id);
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
+	if (f_op && f_op->flush)
+		retval = f_op->flush(filp, id);
+
+	fops_read_unlock(filp, fops_idx);
 
 	dnotify_flush(filp, id);
 	locks_remove_posix(filp, id);
diff --git a/fs/read_write.c b/fs/read_write.c
index 9d1e76b..4def2ee 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -136,14 +136,23 @@ EXPORT_SYMBOL(default_llseek);
 loff_t vfs_llseek(struct file *file, loff_t offset, int origin)
 {
 	loff_t (*fn)(struct file *, loff_t, int);
+	const struct file_operations *f_op;
+	int fops_idx;
+	loff_t ret;
+
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
 
 	fn = no_llseek;
 	if (file->f_mode & FMODE_LSEEK) {
 		fn = default_llseek;
-		if (file->f_op && file->f_op->llseek)
-			fn = file->f_op->llseek;
+		if (f_op && f_op->llseek)
+			fn = f_op->llseek;
 	}
-	return fn(file, offset, origin);
+	ret = fn(file, offset, origin);
+
+	fops_read_unlock(file, fops_idx);
+	return ret;
 }
 EXPORT_SYMBOL(vfs_llseek);
 
@@ -252,15 +261,20 @@ static void wait_on_retry_sync_kiocb(struct kiocb *iocb)
 ssize_t do_sync_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
 {
 	struct iovec iov = { .iov_base = buf, .iov_len = len };
+	const struct file_operations *f_op;
 	struct kiocb kiocb;
+	int fops_idx;
 	ssize_t ret;
 
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
 	kiocb.ki_left = len;
 
 	for (;;) {
-		ret = filp->f_op->aio_read(&kiocb, &iov, 1, kiocb.ki_pos);
+		ret = f_op->aio_read(&kiocb, &iov, 1, kiocb.ki_pos);
 		if (ret != -EIOCBRETRY)
 			break;
 		wait_on_retry_sync_kiocb(&kiocb);
@@ -269,6 +283,8 @@ ssize_t do_sync_read(struct file *filp, char __user *buf, size_t len, loff_t *pp
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&kiocb);
 	*ppos = kiocb.ki_pos;
+	fops_read_unlock(filp, fops_idx);
+
 	return ret;
 }
 
@@ -276,20 +292,28 @@ EXPORT_SYMBOL(do_sync_read);
 
 ssize_t vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
 	ssize_t ret;
 
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
+
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_READ))
-		return -EBADF;
-	if (!file->f_op || (!file->f_op->read && !file->f_op->aio_read))
-		return -EINVAL;
+		goto out;
+	ret = -EINVAL;
+	if (!f_op || (!f_op->read && !f_op->aio_read))
+		goto out;
+	ret = -EFAULT;
 	if (unlikely(!access_ok(VERIFY_WRITE, buf, count)))
-		return -EFAULT;
+		goto out;
 
 	ret = rw_verify_area(READ, file, pos, count);
 	if (ret >= 0) {
 		count = ret;
-		if (file->f_op->read)
-			ret = file->f_op->read(file, buf, count, pos);
+		if (f_op->read)
+			ret = f_op->read(file, buf, count, pos);
 		else
 			ret = do_sync_read(file, buf, count, pos);
 		if (ret > 0) {
@@ -298,7 +322,8 @@ ssize_t vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos)
 		}
 		inc_syscr(current);
 	}
-
+out:
+	fops_read_unlock(file, fops_idx);
 	return ret;
 }
 
@@ -307,15 +332,20 @@ EXPORT_SYMBOL(vfs_read);
 ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, loff_t *ppos)
 {
 	struct iovec iov = { .iov_base = (void __user *)buf, .iov_len = len };
+	const struct file_operations *f_op;
 	struct kiocb kiocb;
+	int fops_idx;
 	ssize_t ret;
 
+	fops_idx = fops_read_lock(filp);
+	f_op = rcu_dereference(filp->f_op);
+
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
 	kiocb.ki_left = len;
 
 	for (;;) {
-		ret = filp->f_op->aio_write(&kiocb, &iov, 1, kiocb.ki_pos);
+		ret = f_op->aio_write(&kiocb, &iov, 1, kiocb.ki_pos);
 		if (ret != -EIOCBRETRY)
 			break;
 		wait_on_retry_sync_kiocb(&kiocb);
@@ -324,6 +354,8 @@ ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, lof
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&kiocb);
 	*ppos = kiocb.ki_pos;
+
+	fops_read_unlock(filp, fops_idx);
 	return ret;
 }
 
@@ -331,20 +363,28 @@ EXPORT_SYMBOL(do_sync_write);
 
 ssize_t vfs_write(struct file *file, const char __user *buf, size_t count, loff_t *pos)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
 	ssize_t ret;
 
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
+
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_WRITE))
-		return -EBADF;
-	if (!file->f_op || (!file->f_op->write && !file->f_op->aio_write))
-		return -EINVAL;
+		goto out;
+	ret = -EINVAL;
+	if (!f_op || (!f_op->write && !f_op->aio_write))
+		goto out;
+	ret = -EFAULT;
 	if (unlikely(!access_ok(VERIFY_READ, buf, count)))
-		return -EFAULT;
+		goto out;
 
 	ret = rw_verify_area(WRITE, file, pos, count);
 	if (ret >= 0) {
 		count = ret;
-		if (file->f_op->write)
-			ret = file->f_op->write(file, buf, count, pos);
+		if (f_op->write)
+			ret = f_op->write(file, buf, count, pos);
 		else
 			ret = do_sync_write(file, buf, count, pos);
 		if (ret > 0) {
@@ -354,6 +394,8 @@ ssize_t vfs_write(struct file *file, const char __user *buf, size_t count, loff_
 		inc_syscw(current);
 	}
 
+out:
+	fops_read_unlock(file, fops_idx);
 	return ret;
 }
 
@@ -611,6 +653,7 @@ out:
 }
 
 static ssize_t do_readv_writev(int type, struct file *file,
+			       const struct file_operations *f_op,
 			       const struct iovec __user * uvector,
 			       unsigned long nr_segs, loff_t *pos)
 {
@@ -621,7 +664,7 @@ static ssize_t do_readv_writev(int type, struct file *file,
 	io_fn_t fn;
 	iov_fn_t fnv;
 
-	if (!file->f_op) {
+	if (!f_op) {
 		ret = -EINVAL;
 		goto out;
 	}
@@ -638,11 +681,11 @@ static ssize_t do_readv_writev(int type, struct file *file,
 
 	fnv = NULL;
 	if (type == READ) {
-		fn = file->f_op->read;
-		fnv = file->f_op->aio_read;
+		fn = f_op->read;
+		fnv = f_op->aio_read;
 	} else {
-		fn = (io_fn_t)file->f_op->write;
-		fnv = file->f_op->aio_write;
+		fn = (io_fn_t)f_op->write;
+		fnv = f_op->aio_write;
 	}
 
 	if (fnv)
@@ -666,12 +709,25 @@ out:
 ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
 		  unsigned long vlen, loff_t *pos)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
+	ssize_t ret;
+
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
+
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_READ))
-		return -EBADF;
-	if (!file->f_op || (!file->f_op->aio_read && !file->f_op->read))
-		return -EINVAL;
+		goto out;
+	ret = -EINVAL;
+	if (!f_op || (!f_op->aio_read && !f_op->read))
+		goto out;
+
+	ret = do_readv_writev(READ, file, f_op, vec, vlen, pos);
 
-	return do_readv_writev(READ, file, vec, vlen, pos);
+out:
+	fops_read_unlock(file, fops_idx);
+	return ret;
 }
 
 EXPORT_SYMBOL(vfs_readv);
@@ -679,12 +735,25 @@ EXPORT_SYMBOL(vfs_readv);
 ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
 		   unsigned long vlen, loff_t *pos)
 {
+	const struct file_operations *f_op;
+	int fops_idx;
+	ssize_t ret;
+
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
+
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_WRITE))
-		return -EBADF;
-	if (!file->f_op || (!file->f_op->aio_write && !file->f_op->write))
-		return -EINVAL;
+		goto out;
+	ret = -EINVAL;
+	if (!f_op || (!f_op->aio_write && !f_op->write))
+		goto out;
+
+	ret = do_readv_writev(WRITE, file, f_op, vec, vlen, pos);
 
-	return do_readv_writev(WRITE, file, vec, vlen, pos);
+out:
+	fops_read_unlock(file, fops_idx);
+	return ret;
 }
 
 EXPORT_SYMBOL(vfs_writev);
@@ -790,8 +859,10 @@ SYSCALL_DEFINE5(pwritev, unsigned long, fd, const struct iovec __user *, vec,
 static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 			   size_t count, loff_t max)
 {
+	const struct file_operations *in_f_op, *out_f_op;
 	struct file * in_file, * out_file;
 	struct inode * in_inode, * out_inode;
+	int in_fops_idx, out_fops_idx;
 	loff_t pos;
 	ssize_t retval;
 	int fput_needed_in, fput_needed_out, fl;
@@ -803,13 +874,15 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 	in_file = fget_light(in_fd, &fput_needed_in);
 	if (!in_file)
 		goto out;
+	in_fops_idx = fops_read_lock(in_file);
 	if (!(in_file->f_mode & FMODE_READ))
 		goto fput_in;
 	retval = -EINVAL;
 	in_inode = in_file->f_path.dentry->d_inode;
 	if (!in_inode)
 		goto fput_in;
-	if (!in_file->f_op || !in_file->f_op->splice_read)
+	in_f_op = rcu_dereference(in_file->f_op);
+	if (!in_f_op || !in_f_op->splice_read)
 		goto fput_in;
 	retval = -ESPIPE;
 	if (!ppos)
@@ -829,10 +902,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 	out_file = fget_light(out_fd, &fput_needed_out);
 	if (!out_file)
 		goto fput_in;
+	out_fops_idx = fops_read_lock(out_file);
 	if (!(out_file->f_mode & FMODE_WRITE))
 		goto fput_out;
 	retval = -EINVAL;
-	if (!out_file->f_op || !out_file->f_op->sendpage)
+	out_f_op = rcu_dereference(out_file->f_op);
+	if (!out_f_op || !out_f_op->sendpage)
 		goto fput_out;
 	out_inode = out_file->f_path.dentry->d_inode;
 	retval = rw_verify_area(WRITE, out_file, &out_file->f_pos, count);
@@ -878,8 +953,10 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 		retval = -EOVERFLOW;
 
 fput_out:
+	fops_read_unlock(out_file, out_fops_idx);
 	fput_light(out_file, fput_needed_out);
 fput_in:
+	fops_read_unlock(in_file, in_fops_idx);
 	fput_light(in_file, fput_needed_in);
 out:
 	return retval;
diff --git a/fs/readdir.c b/fs/readdir.c
index 7723401..6017fa6 100644
--- a/fs/readdir.c
+++ b/fs/readdir.c
@@ -21,9 +21,16 @@
 
 int vfs_readdir(struct file *file, filldir_t filler, void *buf)
 {
-	struct inode *inode = file->f_path.dentry->d_inode;
+	const struct file_operations *f_op;
+	struct inode *inode;
+	int fops_idx;
 	int res = -ENOTDIR;
-	if (!file->f_op || !file->f_op->readdir)
+
+	fops_idx = fops_read_lock(file);
+	f_op = rcu_dereference(file->f_op);
+
+	inode = file->f_path.dentry->d_inode;
+	if (!f_op || !f_op->readdir)
 		goto out;
 
 	res = security_file_permission(file, MAY_READ);
@@ -36,11 +43,12 @@ int vfs_readdir(struct file *file, filldir_t filler, void *buf)
 
 	res = -ENOENT;
 	if (!IS_DEADDIR(inode)) {
-		res = file->f_op->readdir(file, buf, filler);
+		res = f_op->readdir(file, buf, filler);
 		file_accessed(file);
 	}
 	mutex_unlock(&inode->i_mutex);
 out:
+	fops_read_unlock(file, fops_idx);
 	return res;
 }
 
diff --git a/fs/select.c b/fs/select.c
index 0fe0e14..8f736a9 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -416,10 +416,12 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 					continue;
 				file = fget_light(i, &fput_needed);
 				if (file) {
-					f_op = file->f_op;
+					int fops_idx = fops_read_lock(file);
+					f_op = rcu_dereference(file->f_op);
 					mask = DEFAULT_POLLMASK;
 					if (f_op && f_op->poll)
 						mask = (*f_op->poll)(file, retval ? NULL : wait);
+					fops_read_unlock(file, fops_idx);
 					fput_light(file, fput_needed);
 					if ((mask & POLLIN_SET) && (in & bit)) {
 						res_in |= bit;
@@ -684,11 +686,20 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
 		file = fget_light(fd, &fput_needed);
 		mask = POLLNVAL;
 		if (file != NULL) {
+			const struct file_operations *f_op;
+			int fops_idx;
+
+			fops_idx = fops_read_lock(file);
+			f_op = rcu_dereference(file->f_op);
+
 			mask = DEFAULT_POLLMASK;
-			if (file->f_op && file->f_op->poll)
-				mask = file->f_op->poll(file, pwait);
+			if (f_op && f_op->poll)
+				mask = f_op->poll(file, pwait);
+
 			/* Mask out unneeded events. */
 			mask &= pollfd->events | POLLERR | POLLHUP;
+
+			fops_read_unlock(file, fops_idx);
 			fput_light(file, fput_needed);
 		}
 	}
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
