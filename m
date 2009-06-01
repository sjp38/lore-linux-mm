Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DAD446B00E6
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:41 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:29 -0700
Message-Id: <1243893048-17031-4-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Introduce the file_hotplug_lock to protect file->f_op, file->private,
file->f_path from revoke operations.

The file_hotplug_lock is used typically as:
error = -EIO;
if (!file_hotplug_read_trylock(file))
	goto out;
....
file_hotplug_read_unlock(file);

In 5 subsystems sysfs, proc, and sysctl, tty, and sound we have support for
modifing a file descriptor so that the underlying object can go away.
In looking at the problem of pci hotunplug it appears that we
potentially need that support for all file descriptors except ones
talking to files on filesystems.  Even for file descriptors referring
to files, support for file the underlying object going away is
interesting for implementing features like umount -f and sys_revoke.

The implementations in sysfs, proc and sysctl are all very similar and
are composed of several components.
- A reference count to track that the file operations are being used.
- An ability to flag the file as no longer being valid.
- An ability to wait until the file operations are no longer being used.

In addition for a complete solution we need:
- A reliable way the file structures that we need to revoke.
- To wait for but not tamper with ongoing file creation and cleanup.
- A guarantee that all with user space controlled duration are removed.

The file_hotplug_lock has a very unique implementation necessitated by
the need to have no performance impact on existing code.  Classic locking
primitives and reference counting cause pipeline stalls, except for rcu
which provides no ability to preventing reading a data structure while
it is being updated.

file_hotplug_lock keeps the overhead extremely low by dedicating a
small amount of space in the task_struct to store the set of files
the task is currently in the process of using.

The revoke algorithm is simple:
- Find a file on the file_list.
   If it is dying or being created come back later
 * Take a reference to the file, ensuring it does not get freed while the
   revoke code accesses it.
 * Block out new usages of fields guarded by file_hotplug_lock.
 * Kick the underlying implemenation to wake up functions that are potentially
   blocked indefinitely.
 * Wait until there are no tasks holding file_hotplug_read_lock
 * Release the file specific data.
 * Drop the file ref count.
- Repeat until the file list is empty.

The implication of this implementation is that all revoked files will
behave exactly the same way, except for policy controlled by flags in
fmode.  The expected behaivor of revoked is close succeeds all other
operations return -EIO.  Except for the read on ttys this matches the
historical bsd behavior.

Approriate exports are present so modular character devices can
use the file_list

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 Documentation/filesystems/vfs.txt |    5 +
 fs/Kconfig                        |    4 +
 fs/file_table.c                   |  166 ++++++++++++++++++++++++++++++++++--
 fs/open.c                         |    6 ++
 include/linux/fs.h                |   25 ++++++-
 include/linux/sched.h             |    7 ++
 6 files changed, 202 insertions(+), 11 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index f49eecf..d220fd5 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -806,6 +806,11 @@ otherwise noted.
   splice_read: called by the VFS to splice data from file to a pipe. This
 	       method is used by the splice(2) system call
 
+  dead: Called by the VFS to notify a file that it has been killed.
+	Typically this is used to wake up poll, read or other blocking
+	file methods, that could be indefinitely waiting for something
+	to happen.
+
 Note that the file operations are implemented by the specific
 filesystem in which the inode resides. When opening a device node
 (character or block special) most filesystems will call special
diff --git a/fs/Kconfig b/fs/Kconfig
index 9f7270f..2fb86b0 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -265,4 +265,8 @@ endif
 source "fs/nls/Kconfig"
 source "fs/dlm/Kconfig"
 
+config FILE_HOTPLUG
+       bool
+       default n
+
 endmenu
diff --git a/fs/file_table.c b/fs/file_table.c
index 978f267..9db3031 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -23,6 +23,7 @@
 #include <linux/sysctl.h>
 #include <linux/percpu_counter.h>
 #include <linux/writeback.h>
+#include <linux/mm.h>
 
 #include <asm/atomic.h>
 
@@ -201,7 +202,7 @@ int init_file(struct file *file, struct vfsmount *mnt, struct dentry *dentry,
 	file->f_path.dentry = dentry;
 	file->f_path.mnt = mntget(mnt);
 	file->f_mapping = dentry->d_inode->i_mapping;
-	file->f_mode = mode;
+	file->f_mode = mode | FMODE_OPENED;
 	file->f_op = fop;
 
 	/*
@@ -252,17 +253,12 @@ void drop_file_write_access(struct file *file)
 }
 EXPORT_SYMBOL_GPL(drop_file_write_access);
 
-/* __fput is called from task context when aio completion releases the last
- * last use of a struct file *.  Do not use otherwise.
- */
-void __fput(struct file *file)
+static void frelease(struct file *file)
 {
 	struct dentry *dentry = file->f_path.dentry;
 	struct vfsmount *mnt = file->f_path.mnt;
 	struct inode *inode = dentry->d_inode;
 
-	might_sleep();
-
 	fsnotify_close(file);
 	/*
 	 * The function eventpoll_release() should be the first called
@@ -277,23 +273,38 @@ void __fput(struct file *file)
 	}
 	if (file->f_op && file->f_op->release)
 		file->f_op->release(inode, file);
-	security_file_free(file);
 	ima_file_free(file);
 	if (unlikely(S_ISCHR(inode->i_mode) && inode->i_cdev != NULL))
 		cdev_put(inode->i_cdev);
 	fops_put(file->f_op);
-	put_pid(file->f_owner.pid);
 	if (!special_file(inode->i_mode))
 		file_list_del(file, &inode->i_files);
 	if (file->f_mode & FMODE_WRITE)
 		drop_file_write_access(file);
 	file->f_path.dentry = NULL;
 	file->f_path.mnt = NULL;
-	file_free(file);
+	file->f_mapping = NULL;
+	file->f_op = NULL;
+	file->private_data = NULL;
 	dput(dentry);
 	mntput(mnt);
 }
 
+/* __fput is called from task context when aio completion releases the last
+ * last use of a struct file *.  Do not use otherwise.
+ */
+void __fput(struct file *file)
+{
+	might_sleep();
+
+	if (likely(!(file->f_mode & FMODE_DEAD)))
+		frelease(file);
+
+	security_file_free(file);
+	put_pid(file->f_owner.pid);
+	file_free(file);
+}
+
 struct file *fget(unsigned int fd)
 {
 	struct file *file;
@@ -360,6 +371,7 @@ void init_file_list(struct file_list *files)
 	INIT_LIST_HEAD(&files->list);
 	spin_lock_init(&files->lock);
 }
+EXPORT_SYMBOL(init_file_list);
 
 void file_list_add(struct file *file, struct file_list *files)
 {
@@ -377,6 +389,140 @@ void file_list_del(struct file *file, struct file_list *files)
 }
 EXPORT_SYMBOL(file_list_del);
 
+#ifdef CONFIG_FILE_HOTPLUG
+
+static bool file_in_use(struct file *file)
+{
+	struct task_struct *leader, *task;
+	bool in_use = false;
+	int i;
+
+	rcu_read_lock();
+	do_each_thread(leader, task) {
+		for (i = 0; i < MAX_FILE_HOTPLUG_LOCK_DEPTH; i++) {
+			if (task->file_hotplug_lock[i] == file) {
+				in_use = true;
+				goto found;
+			}
+		}
+	} while_each_thread(leader, task);
+found:
+	rcu_read_unlock();
+	return in_use;
+}
+
+static int revoke_file(struct file *file)
+{
+	/* Must be called with f_count held and FMODE_OPENED set */
+	fmode_t mode;
+
+	if (!(file->f_mode  & FMODE_REVOKE))
+		return -EINVAL;
+
+	/*
+	 * Tell everyone this file is dead.
+	 */
+	spin_lock(&file->f_ep_lock);
+	mode = file->f_mode;
+	file->f_mode |= FMODE_DEAD;
+	spin_unlock(&file->f_ep_lock);
+	if (mode & FMODE_DEAD)
+		return -EIO;
+
+	/*
+	 * Notify the file we have killed it.
+	 */
+	if (file->f_op->dead)
+		file->f_op->dead(file);
+
+	/*
+	 * Wait until there are no more callers in the file operations.
+	 */
+	if (file_in_use(file)) {
+		do {
+			schedule_timeout_uninterruptible(1);
+		} while (file_in_use(file));
+	}
+
+	revoke_file_mappings(file);
+	frelease(file);
+
+	return 0;
+}
+
+int revoke_file_list(struct file_list *files)
+{
+	struct file *file;
+	int error = 0;
+	int empty;
+
+restart:
+	file_list_lock(files);
+	list_for_each_entry(file, &files->list, f_u.fu_list) {
+
+		/* Don't touch files that have not yet been fully opened */
+		if (!(file->f_mode & FMODE_OPENED))
+			continue;
+
+		/* Ensure I am looking at the file after it was opened */
+		smp_rmb();
+
+		/* Don't touch files that are in the final stages of being closed. */
+		if (file_count(file) == 0)
+			continue;
+
+		/* Get a reference to the file */
+		if (!atomic_long_inc_not_zero(&file->f_count))
+			continue;
+
+		file_list_unlock(files);
+
+		error = revoke_file(file);
+		fput(file);
+
+		if (unlikely(error))
+			goto out;
+		goto restart;
+	}
+	empty = list_empty(&files->list);
+	file_list_unlock(files);
+	/*
+	 * If the file list had files we can't touch sleep a little while
+	 * and check again.
+	 */
+	if (!empty) {
+		schedule_timeout_uninterruptible(1);
+		goto restart;
+	}
+out:
+	return error;
+}
+EXPORT_SYMBOL(revoke_file_list);
+
+int __lockfunc file_hotplug_read_trylock(struct file *file)
+{
+	fmode_t mode = file->f_mode;
+	int locked = 0;
+	if (!(mode & FMODE_DEAD)) {
+		struct task_struct *tsk = current;
+		int pos = tsk->file_hotplug_lock_depth;
+		if (likely(pos < MAX_FILE_HOTPLUG_LOCK_DEPTH)) {
+			tsk->file_hotplug_lock_depth = pos + 1;
+			tsk->file_hotplug_lock[pos] = file;
+			locked = 1;
+		}
+	}
+	return locked;
+}
+
+void __lockfunc file_hotplug_read_unlock(struct file *file)
+{
+	struct task_struct *tsk = current;
+	tsk->file_hotplug_lock[--(tsk->file_hotplug_lock_depth)] = NULL;
+}
+
+#endif /* CONFIG_FILE_HOTPLUG */
+
 int fs_may_remount_ro(struct super_block *sb)
 {
 	struct inode *inode;
diff --git a/fs/open.c b/fs/open.c
index 20c3fc0..d0b2433 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -809,6 +809,7 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 					const struct cred *cred)
 {
 	struct inode *inode;
+	fmode_t opened_fmode;
 	int error;
 
 	f->f_flags = flags;
@@ -857,6 +858,11 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 		}
 	}
 
+	opened_fmode = f->f_mode | FMODE_OPENED;
+	/* Ensure revoke_file_list sees the opened file */
+	smp_wmb();
+	f->f_mode = opened_fmode;
+
 	return f;
 
 cleanup_all:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5329fd6..f7f4c46 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -87,6 +87,13 @@ struct inodes_stat_t {
  */
 #define FMODE_NOCMTIME		((__force fmode_t)2048)
 
+/* File has successfully been opened */
+#define FMODE_OPENED		((__force fmode_t)4096)
+/* File supports being revoked */
+#define FMODE_REVOKE		((__force fmode_t)8192)
+/* File is dead (has been revoked) */
+#define FMODE_DEAD		((__force fmode_t)16384)
+
 /*
  * The below are the various read and write types that we support. Some of
  * them include behavioral modifiers that send information down to the
@@ -903,6 +910,7 @@ static inline int ra_has_index(struct file_ra_state *ra, pgoff_t index)
 #define FILE_MNT_WRITE_RELEASED	2
 
 struct file {
+	/* file_hotplug_lock f_op, private, f_path, f_mapping */
 	/*
 	 * fu_list becomes invalid after file_free is called and queued via
 	 * fu_rcuhead for RCU freeing
@@ -935,12 +943,26 @@ struct file {
 	/* Used by fs/eventpoll.c to link all the hooks to this file */
 	struct list_head	f_ep_links;
 #endif /* #ifdef CONFIG_EPOLL */
-	struct address_space	*f_mapping;
+	struct address_space	*f_mapping; /* file_hotplug_lock or mmap_sem */
 #ifdef CONFIG_DEBUG_WRITECOUNT
 	unsigned long f_mnt_write_state;
 #endif
 };
 
+#ifdef CONFIG_FILE_HOTPLUG
+extern int file_hotplug_read_trylock(struct file *file);
+extern void file_hotplug_read_unlock(struct file *file);
+extern int revoke_file_list(struct file_list *files);
+#else
+static inline int file_hotplug_read_trylock(struct file *file)
+{
+	return 1;
+}
+static inline void file_hotplug_read_unlock(struct file *file)
+{
+}
+#endif
+
 static inline void file_list_lock(struct file_list *files)
 {
 	spin_lock(&files->lock);
@@ -1514,6 +1536,7 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	void (*dead)(struct file *);
 };
 
 struct inode_operations {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b4c38bc..bbf1616 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1302,6 +1302,13 @@ struct task_struct {
 	struct irqaction *irqaction;
 #endif
 
+/* File hotplug lock */
+#ifdef CONFIG_FILE_HOTPLUG
+#define MAX_FILE_HOTPLUG_LOCK_DEPTH 4U
+	int file_hotplug_lock_depth;
+	struct file *file_hotplug_lock[MAX_FILE_HOTPLUG_LOCK_DEPTH];
+#endif
+
 	/* Protection of the PI data structures: */
 	spinlock_t pi_lock;
 
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
