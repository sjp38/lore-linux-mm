Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EC4F85F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:13:15 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:13:22 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m1prfj5qxp.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 8/9] vfs: Implement generic revoked file operations
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


revoked_file_ops is a set of file operations designed to be used
when a files backing store has been removed.

revoked_file_ops return 0 from reads (aka EOF). Tell poll the file is
always ready for I/O and return -EIO from all other operations.

This is designed to allow userspace to gracefully file descriptors
that enter this unusable state.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/Makefile        |    2 +-
 fs/revoked_file.c  |  181 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |    2 +
 3 files changed, 184 insertions(+), 1 deletions(-)
 create mode 100644 fs/revoked_file.c

diff --git a/fs/Makefile b/fs/Makefile
index af6d047..7787ddd 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o drop_caches.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o
+		stack.o fs_struct.o revoked_file.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
diff --git a/fs/revoked_file.c b/fs/revoked_file.c
new file mode 100644
index 0000000..9936693
--- /dev/null
+++ b/fs/revoked_file.c
@@ -0,0 +1,181 @@
+/*
+ *  linux/fs/revoked_file.c
+ *
+ *  Copyright (C) 1997, Stephen Tweedie
+ *
+ *  Provide stub functions for unreadable inodes
+ *
+ *  Fabian Frederick : August 2003 - All file operations assigned to EIO
+ *
+ *  Eric Biederman : 8 April 2008 - Derivied from bad_inode.c
+ */
+
+#include <linux/fs.h>
+#include <linux/module.h>
+#include <linux/stat.h>
+#include <linux/time.h>
+#include <linux/namei.h>
+#include <linux/poll.h>
+
+static loff_t revoked_file_llseek(struct file *file, loff_t offset, int origin)
+{
+	return -EIO;
+}
+
+static ssize_t revoked_file_read(struct file *filp, char __user *buf,
+			size_t size, loff_t *ppos)
+{
+        return 0;
+}
+
+static ssize_t revoked_file_write(struct file *filp, const char __user *buf,
+			size_t siz, loff_t *ppos)
+{
+        return -EIO;
+}
+
+static ssize_t revoked_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
+			unsigned long nr_segs, loff_t pos)
+{
+	return 0;
+}
+
+static ssize_t revoked_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
+			unsigned long nr_segs, loff_t pos)
+{
+	return -EIO;
+}
+
+static int revoked_file_readdir(struct file *filp, void *dirent, filldir_t filldir)
+{
+	return -EIO;
+}
+
+static unsigned int revoked_file_poll(struct file *filp, poll_table *wait)
+{
+	return POLLIN | POLLOUT | POLLERR | POLLRDNORM | POLLWRNORM;
+}
+
+static int revoked_file_ioctl (struct inode *inode, struct file *filp,
+			unsigned int cmd, unsigned long arg)
+{
+	return -EIO;
+}
+
+static long revoked_file_unlocked_ioctl(struct file *file, unsigned cmd,
+			unsigned long arg)
+{
+	return -EIO;
+}
+
+static long revoked_file_compat_ioctl(struct file *file, unsigned int cmd,
+			unsigned long arg)
+{
+	return -EIO;
+}
+
+static int revoked_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return -EIO;
+}
+
+static int revoked_file_open(struct inode *inode, struct file *filp)
+{
+	return -EIO;
+}
+
+static int revoked_file_flush(struct file *file, fl_owner_t id)
+{
+	return 0;
+}
+
+static int revoked_file_release(struct inode *inode, struct file *filp)
+{
+	return 0;
+}
+
+static int revoked_file_fsync(struct file *file, struct dentry *dentry,
+			int datasync)
+{
+	return -EIO;
+}
+
+static int revoked_file_aio_fsync(struct kiocb *iocb, int datasync)
+{
+	return -EIO;
+}
+
+static int revoked_file_fasync(int fd, struct file *filp, int on)
+{
+	return -EIO;
+}
+
+static int revoked_file_lock(struct file *file, int cmd, struct file_lock *fl)
+{
+	return -EIO;
+}
+
+static ssize_t revoked_file_sendpage(struct file *file, struct page *page,
+			int off, size_t len, loff_t *pos, int more)
+{
+	return -EIO;
+}
+
+static unsigned long revoked_file_get_unmapped_area(struct file *file,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags)
+{
+	return -EIO;
+}
+
+static int revoked_file_check_flags(int flags)
+{
+	return -EIO;
+}
+
+static int revoked_file_flock(struct file *filp, int cmd, struct file_lock *fl)
+{
+	return -EIO;
+}
+
+static ssize_t revoked_file_splice_write(struct pipe_inode_info *pipe,
+			struct file *out, loff_t *ppos, size_t len,
+			unsigned int flags)
+{
+	return -EIO;
+}
+
+static ssize_t revoked_file_splice_read(struct file *in, loff_t *ppos,
+			struct pipe_inode_info *pipe, size_t len,
+			unsigned int flags)
+{
+	return -EIO;
+}
+
+const struct file_operations revoked_file_ops =
+{
+	.llseek		= revoked_file_llseek,
+	.read		= revoked_file_read,
+	.write		= revoked_file_write,
+	.aio_read	= revoked_file_aio_read,
+	.aio_write	= revoked_file_aio_write,
+	.readdir	= revoked_file_readdir,
+	.poll		= revoked_file_poll,
+	.ioctl		= revoked_file_ioctl,
+	.unlocked_ioctl	= revoked_file_unlocked_ioctl,
+	.compat_ioctl	= revoked_file_compat_ioctl,
+	.mmap		= revoked_file_mmap,
+	.open		= revoked_file_open,
+	.flush		= revoked_file_flush,
+	.release	= revoked_file_release,
+	.fsync		= revoked_file_fsync,
+	.aio_fsync	= revoked_file_aio_fsync,
+	.fasync		= revoked_file_fasync,
+	.lock		= revoked_file_lock,
+	.sendpage	= revoked_file_sendpage,
+	.get_unmapped_area = revoked_file_get_unmapped_area,
+	.check_flags	= revoked_file_check_flags,
+	.flock		= revoked_file_flock,
+	.splice_write	= revoked_file_splice_write,
+	.splice_read	= revoked_file_splice_read,
+};
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a82a2ea..2fb0871 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -896,6 +896,8 @@ extern int fops_substitute(struct file *file, const struct file_operations *f_op
 extern void inode_fops_substitute(struct inode *inode,
 	const struct file_operations *f_op, struct vm_operations_struct *vm_ops);
 
+extern const struct file_operations revoked_file_ops;
+
 extern struct mutex files_lock;
 #define file_list_lock() mutex_lock(&files_lock);
 #define file_list_unlock() mutex_unlock(&files_lock);
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
