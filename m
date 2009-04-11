Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2513F5F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:08:56 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:08:58 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m163hb75ph.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 5/9] vfs: Introduce basic infrastructure for revoking a file
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


Going forward fops_read_lock should be held whenever file->f_op is being
accesed and when the functions from f_op are executing.

In 4 subsystems sysfs, proc, and sysctl, and tty we have support
for modifing a file descriptor so that the underlying object
can go away.  In looking at the problem of pci hotunplug
it appears that we potentially need that support for all file
descriptors except ones talking to files on filesystems.  Even
on for file descriptors referring to files support for file
the underlying object going away is interesting for implementing
features like umount -f and sys_revoke.

The implementations in sysfs, proc and sysctl are all very similar
and are composed of several components.
- A reference count to track that the file operations are being used.
- An ability to flag the file as no longer being valid.
- An ability to wait until the reference count is no longer used.

Tracking when file_operations functions are running is done by holding
the fops_read_lock across their invocations.

Flagging when the file is no longer valid will be done by taking f_lock
and modifying f_op, with a set of file operations that will return
appropriate error codes,. roughly EIO from most operations, POLLERR
from poll, and 0 from reads, and setting FMODE_REVOKE.

Waiting until the functions are no longer being called is done with
by waiting until f_use goes to 0.  Essentially the same as synchronize_srcu.

When implementing this I encountered an additional challenge.  Ensuring
that f_op->release is called exactly once, in an appropriate context.

To ensure this I have taken several steps.
- file_kill is moved immediate after after frelease in __fput to ensure
  the proper context is present even if fop_substitute calls release.

- open sets FMODE_RELEASE after the open succeeds (but before fops_read_unlock)
  ensuring that fops_subsittute will know if release needs to be called
  after it has finished waiting for all of the files.

- __fput samples fmode and f_op under f_lock and only calls __frelease
  if FMODE_REVOKE has not happened and FMODE_RELEASE is pending.  Leaving
  it up to fops_subsitutate to call __frelease.

- fops_substituate calls __frelease in all cases if after waiting for
  all users of a file to go to zero FMODE_RELEASE is still set.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 Documentation/filesystems/vfs.txt |    4 +
 fs/file_table.c                   |  154 ++++++++++++++++++++++++++++++++++---
 fs/open.c                         |   19 ++++-
 include/linux/fs.h                |   19 +++++
 4 files changed, 181 insertions(+), 15 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index deeeed0..2b115ba 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -807,6 +807,10 @@ otherwise noted.
   splice_read: called by the VFS to splice data from file to a pipe. This
 	       method is used by the splice(2) system call
 
+  awaken_all_waiters: Called in while revoking a file to wake up poll,
+                      aio operations, fasync, and anything else blocked
+		      indefinitely waiting for something to happen.
+
 Note that the file operations are implemented by the specific
 filesystem in which the inode resides. When opening a device node
 (character or block special) most filesystems will call special
diff --git a/fs/file_table.c b/fs/file_table.c
index 03d74b6..d216557 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -23,6 +23,7 @@
 #include <linux/sysctl.h>
 #include <linux/percpu_counter.h>
 #include <linux/writeback.h>
+#include <linux/mm.h>
 
 #include <asm/atomic.h>
 
@@ -204,7 +205,7 @@ int init_file(struct file *file, struct vfsmount *mnt, struct dentry *dentry,
 	file->f_path.dentry = dentry;
 	file->f_path.mnt = mntget(mnt);
 	file->f_mapping = dentry->d_inode->i_mapping;
-	file->f_mode = mode;
+	file->f_mode = mode | FMODE_RELEASE;
 	file->f_op = fop;
 
 	/*
@@ -255,6 +256,51 @@ void drop_file_write_access(struct file *file)
 }
 EXPORT_SYMBOL_GPL(drop_file_write_access);
 
+static void __frelease(struct file *file, struct inode *inode,
+			const struct file_operations *f_op)
+{
+	locks_remove_flock(file);
+	if (unlikely(file->f_flags & FASYNC)) {
+		if (f_op && f_op->fasync)
+			file->f_op->fasync(-1, file, 0);
+	}
+	if (f_op && f_op->release)
+		f_op->release(inode, file);
+
+	if (unlikely(S_ISCHR(inode->i_mode) && inode->i_cdev != NULL))
+		cdev_put(inode->i_cdev);
+}
+
+static void frelease(struct file *file, struct inode *inode)
+
+{
+	const struct file_operations *f_op;
+	int fops_idx;
+	fmode_t mode;
+	int need_release = 0;
+
+	fops_idx = fops_read_lock(file);
+
+	/*
+	 * Ensure that __frelease is called exactly once.
+	 *
+	 * We don't do anything if FMODE_REVOKED is set because
+	 * we will have a f_op without the proper release method
+	 * and so can not cleanup from this path.
+	 */
+	spin_lock(&file->f_lock);
+	f_op = file->f_op;
+	mode = file->f_mode;
+	need_release = (mode & (FMODE_REVOKED | FMODE_RELEASE)) == FMODE_RELEASE;
+	if (need_release)
+		file->f_mode = mode & ~FMODE_RELEASE;
+	spin_unlock(&file->f_lock);
+
+	if (need_release)
+		__frelease(file, inode, f_op);
+	fops_read_unlock(file, fops_idx);
+}
+
 /* __fput is called from task context when aio completion releases the last
  * last use of a struct file *.  Do not use otherwise.
  */
@@ -272,21 +318,14 @@ void __fput(struct file *file)
 	 * in the file cleanup chain.
 	 */
 	eventpoll_release(file);
-	locks_remove_flock(file);
 
-	if (unlikely(file->f_flags & FASYNC)) {
-		if (file->f_op && file->f_op->fasync)
-			file->f_op->fasync(-1, file, 0);
-	}
-	if (file->f_op && file->f_op->release)
-		file->f_op->release(inode, file);
+	frelease(file, inode);
+	file_kill(file);
+
 	security_file_free(file);
 	ima_file_free(file);
-	if (unlikely(S_ISCHR(inode->i_mode) && inode->i_cdev != NULL))
-		cdev_put(inode->i_cdev);
 	fops_put(file->f_op);
 	put_pid(file->f_owner.pid);
-	file_kill(file);
 	if (file->f_mode & FMODE_WRITE)
 		drop_file_write_access(file);
 	file->f_path.dentry = NULL;
@@ -296,6 +335,78 @@ void __fput(struct file *file)
 	mntput(mnt);
 }
 
+int fops_substitute(struct file *file, const struct file_operations *f_op,
+			struct vm_operations_struct *vm_ops)
+{
+	/* Must be called with file_list_lock held */
+	/* This currently assumes that the new f_op does not need
+	 * open or release to be called.
+	 * This currently assumes that it will not be called twice
+	 * on the same file.
+	 */
+	const struct file_operations *old_f_op;
+	fmode_t mode;
+	int err;
+
+	err = -EINVAL;
+	f_op = fops_get(f_op);
+	if (!f_op)
+		goto out;
+	/*
+	 * Ensure we have no new users of the old f_ops.
+	 * Assignment order is important here.
+	 */
+	spin_lock(&file->f_lock);
+	old_f_op = file->f_op;
+	rcu_assign_pointer(file->f_op, f_op);
+	file->f_mode |= FMODE_REVOKED;
+	spin_unlock(&file->f_lock);
+
+	/*
+	 * Drain the existing uses of the original f_ops.
+	 */
+	remap_file_mappings(file, vm_ops);
+	if (old_f_op->awaken_all_waiters)
+		old_f_op->awaken_all_waiters(file);
+
+	/*
+	 * Wait until there are no more callers in the original
+	 * file_operations methods.
+	 */
+	while (atomic_long_read(&file->f_use) > 0)
+		schedule_timeout_interruptible(1);
+
+	/*
+	 * Cleanup the data structures that were associated
+	 * with the old fops.
+	 */
+	spin_lock(&file->f_lock);
+	mode = file->f_mode;
+	file->f_mode = mode & ~FMODE_RELEASE;
+	spin_unlock(&file->f_lock);
+	if (mode & FMODE_RELEASE)
+		__frelease(file, file->f_path.dentry->d_inode, old_f_op);
+	fops_put(old_f_op);
+	file->private_data = NULL;
+	err = 0;
+out:
+	return err;
+}
+
+void inode_fops_substitute(struct inode *inode, 
+	const struct file_operations *f_op,
+	struct vm_operations_struct *vm_ops)
+{
+	struct file *file;
+
+	file_list_lock();
+	/* Prevent new files from showing up with the old f_ops */
+	inode->i_fop = f_op;
+	list_for_each_entry(file, &inode->i_files, f_u.fu_list)
+		fops_substitute(file, f_op, vm_ops);
+	file_list_unlock();
+}
+
 struct file *fget(unsigned int fd)
 {
 	struct file *file;
@@ -358,12 +469,17 @@ void put_filp(struct file *file)
 	}
 }
 
+void __file_add(struct file *file, struct list_head *list)
+{
+	list_add(&file->f_u.fu_list, list);
+}
+
 void file_add(struct file *file, struct list_head *list)
 {
 	if (!list)
 		return;
 	file_list_lock();
-	list_add(&file->f_u.fu_list, list);
+	__file_add(file, list);
 	file_list_unlock();
 }
 
@@ -376,6 +492,20 @@ void file_kill(struct file *file)
 	}
 }
 
+int fops_read_lock(struct file *file)
+{
+	int revoked = (file->f_mode & FMODE_REVOKED);
+	if (likely(!revoked))
+		atomic_long_inc(&file->f_use);
+	return revoked;
+}
+
+void fops_read_unlock(struct file *file, int revoked)
+{
+	if (likely(!revoked))
+		atomic_long_dec(&file->f_use);
+}
+
 int fs_may_remount_ro(struct super_block *sb)
 {
 	struct inode *inode;
diff --git a/fs/open.c b/fs/open.c
index 5e201cb..0b75dde 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -808,7 +808,9 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 					int (*open)(struct inode *, struct file *),
 					const struct cred *cred)
 {
+	const struct file_operations *f_op;
 	struct inode *inode;
+	int fops_idx;
 	int error;
 
 	f->f_flags = flags;
@@ -827,21 +829,31 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 	f->f_path.dentry = dentry;
 	f->f_path.mnt = mnt;
 	f->f_pos = 0;
+
+	file_list_lock();
 	f->f_op = fops_get(inode->i_fop);
 	if (!special_file(inode->i_mode))
-		file_add(f, &inode->i_files);
+		__file_add(f, &inode->i_files);
+	file_list_unlock();
+
+	fops_idx = fops_read_lock(f);
+	f_op = rcu_dereference(f->f_op);
 
 	error = security_dentry_open(f, cred);
 	if (error)
 		goto cleanup_all;
 
-	if (!open && f->f_op)
-		open = f->f_op->open;
+	if (!open && f_op)
+		open = f_op->open;
 	if (open) {
 		error = open(inode, f);
 		if (error)
 			goto cleanup_all;
 	}
+	spin_lock(&f->f_lock);
+	f->f_mode |= FMODE_RELEASE;
+	spin_unlock(&f->f_lock);
+	fops_read_unlock(f, fops_idx);
 
 	f->f_flags &= ~(O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC);
 
@@ -860,6 +872,7 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 	return f;
 
 cleanup_all:
+	fops_read_unlock(f, fops_idx);
 	fops_put(f->f_op);
 	if (f->f_mode & FMODE_WRITE) {
 		put_write_access(inode);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7805d20..a82a2ea 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -78,6 +78,13 @@ struct inodes_stat_t {
 /* File is opened using open(.., 3, ..) and is writeable only for ioctls
    (specialy hack for floppy.c) */
 #define FMODE_WRITE_IOCTL	((__force fmode_t)256)
+/* File release method needs to be called */
+#define FMODE_RELEASE		((__force fmode_t)512)
+/*
+ * The file descriptor has been denied access to the original object.
+ * Likely a module removal, or device has been unplugged.
+ */
+#define FMODE_REVOKED		((__force fmode_t)1024)
 
 /*
  * Don't update ctime and mtime.
@@ -329,6 +336,7 @@ struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
+struct vm_operations_struct;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -856,6 +864,7 @@ struct file {
 	const struct file_operations	*f_op;
 	spinlock_t		f_lock;  /* f_ep_links, f_flags, no IRQ */
 	atomic_long_t		f_count;
+	atomic_long_t		f_use;	/* f_op, private_data */
 	unsigned int 		f_flags;
 	fmode_t			f_mode;
 	loff_t			f_pos;
@@ -879,6 +888,14 @@ struct file {
 	unsigned long f_mnt_write_state;
 #endif
 };
+
+extern int fops_read_lock(struct file *file);
+extern void fops_read_unlock(struct file *file, int idx);
+extern int fops_substitute(struct file *file, const struct file_operations *f_op,
+				struct vm_operations_struct *vm_ops);
+extern void inode_fops_substitute(struct inode *inode,
+	const struct file_operations *f_op, struct vm_operations_struct *vm_ops);
+
 extern struct mutex files_lock;
 #define file_list_lock() mutex_lock(&files_lock);
 #define file_list_unlock() mutex_unlock(&files_lock);
@@ -1452,6 +1469,7 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*awaken_all_waiters)(struct file *);
 };
 
 struct inode_operations {
@@ -2116,6 +2134,7 @@ static inline void insert_inode_hash(struct inode *inode) {
 }
 
 extern struct file * get_empty_filp(void);
+extern void __file_add(struct file *f, struct list_head *list);
 extern void file_add(struct file *f, struct list_head *list);
 extern void file_kill(struct file *f);
 #ifdef CONFIG_BLOCK
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
