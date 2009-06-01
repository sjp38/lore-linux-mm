Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9792D6B00F5
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:41 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:28 -0700
Message-Id: <1243893048-17031-3-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 03/23] vfs: Generalize the file_list
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@xmission.com>

In the implementation of revoke it is desirable to find all of the
files we want to operation on.  Currently tty's and mark_files_ro
use the file_list for this, and this patch generalizes the file
list so it can be used more efficiently.

This patch starts by introducing struct file_list making the file
list a first class object.  file_list_lock and file_list_unlock
are modified to take this object, making it clear which file_list
we intended to lock.

file_move is transformed into file_list_add taking a file_list and not
allowing the movement of one file to another. __dentry_open
is modified to support this by only adding normal files in open,
special files have always been ignored when walking the file_list.
__dentry_open skipping special files allows __ptmx_open and __tty_open
to safely call file_add as they are adding the file to the file_list
for the first time.

file_kill has been renamed file_list_del to make it clear what it is
doing and to keep from confusing it with a more revoke like operation.

put_filp has been modified to not take file_list_del as we are never
on a file_list when put_filp is called.

fs_may_remount_ro and mark_files_ro have been modified to walk the
inode list to find all of the inodes and then to walk the file list
on those inodes.  It can be a slightly longer walk as we frequently
cache inodes that we do not have open but the overall complexity
should be about the same, these are slow path functions, and it
gives us much greater flexibility overall.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/char/pty.c       |    2 +-
 drivers/char/tty_io.c    |   22 ++++-----
 fs/file_table.c          |  117 +++++++++++++++++++++++++---------------------
 fs/inode.c               |    1 +
 fs/open.c                |    6 ++-
 fs/select.c              |    2 -
 fs/super.c               |    1 -
 include/linux/fs.h       |   24 +++++++--
 include/linux/tty.h      |    2 +-
 security/selinux/hooks.c |    8 ++--
 10 files changed, 102 insertions(+), 83 deletions(-)

diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index 31038a0..585f700 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -662,7 +662,7 @@ static int __ptmx_open(struct inode *inode, struct file *filp)
 
 	set_bit(TTY_PTY_LOCK, &tty->flags); /* LOCK THE SLAVE */
 	filp->private_data = tty;
-	file_move(filp, &tty->tty_files);
+	file_list_add(filp, &tty->tty_files);
 
 	retval = devpts_pty_new(inode, tty->link);
 	if (retval)
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 66b99a2..b5c0ca1 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -235,11 +235,11 @@ static int check_tty_count(struct tty_struct *tty, const char *routine)
 	struct list_head *p;
 	int count = 0;
 
-	file_list_lock();
-	list_for_each(p, &tty->tty_files) {
+	file_list_lock(&tty->tty_files);
+	list_for_each(p, &tty->tty_files.list) {
 		count++;
 	}
-	file_list_unlock();
+	file_list_unlock(&tty->tty_files);
 	if (tty->driver->type == TTY_DRIVER_TYPE_PTY &&
 	    tty->driver->subtype == PTY_TYPE_SLAVE &&
 	    tty->link && tty->link->count)
@@ -554,9 +554,9 @@ static void do_tty_hangup(struct work_struct *work)
 	spin_unlock(&redirect_lock);
 
 	check_tty_count(tty, "do_tty_hangup");
-	file_list_lock();
+	file_list_lock(&tty->tty_files);
 	/* This breaks for file handles being sent over AF_UNIX sockets ? */
-	list_for_each_entry(filp, &tty->tty_files, f_u.fu_list) {
+	list_for_each_entry(filp, &tty->tty_files.list, f_u.fu_list) {
 		if (filp->f_op->write == redirected_tty_write)
 			cons_filp = filp;
 		if (filp->f_op->write != tty_write)
@@ -565,7 +565,7 @@ static void do_tty_hangup(struct work_struct *work)
 		tty_fasync(-1, filp, 0);	/* can't block */
 		filp->f_op = &hung_up_tty_fops;
 	}
-	file_list_unlock();
+	file_list_unlock(&tty->tty_files);
 	/*
 	 * FIXME! What are the locking issues here? This may me overdoing
 	 * things... This question is especially important now that we've
@@ -1467,10 +1467,6 @@ static void release_one_tty(struct kref *kref)
 	tty_driver_kref_put(driver);
 	module_put(driver->owner);
 
-	file_list_lock();
-	list_del_init(&tty->tty_files);
-	file_list_unlock();
-
 	free_tty_struct(tty);
 }
 
@@ -1678,7 +1674,7 @@ void tty_release_dev(struct file *filp)
 	 *  - do_tty_hangup no longer sees this file descriptor as
 	 *    something that needs to be handled for hangups.
 	 */
-	file_kill(filp);
+	file_list_del(filp, &tty->tty_files);
 	filp->private_data = NULL;
 
 	/*
@@ -1836,7 +1832,7 @@ got_driver:
 		return PTR_ERR(tty);
 
 	filp->private_data = tty;
-	file_move(filp, &tty->tty_files);
+	file_list_add(filp, &tty->tty_files);
 	check_tty_count(tty, "tty_open");
 	if (tty->driver->type == TTY_DRIVER_TYPE_PTY &&
 	    tty->driver->subtype == PTY_TYPE_MASTER)
@@ -2779,7 +2775,7 @@ void initialize_tty_struct(struct tty_struct *tty,
 	mutex_init(&tty->echo_lock);
 	spin_lock_init(&tty->read_lock);
 	spin_lock_init(&tty->ctrl_lock);
-	INIT_LIST_HEAD(&tty->tty_files);
+	init_file_list(&tty->tty_files);
 	INIT_WORK(&tty->SAK_work, do_SAK_work);
 
 	tty->driver = driver;
diff --git a/fs/file_table.c b/fs/file_table.c
index 334ce39..978f267 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -22,6 +22,7 @@
 #include <linux/fsnotify.h>
 #include <linux/sysctl.h>
 #include <linux/percpu_counter.h>
+#include <linux/writeback.h>
 
 #include <asm/atomic.h>
 
@@ -30,9 +31,6 @@ struct files_stat_struct files_stat = {
 	.max_files = NR_FILE
 };
 
-/* public. Not pretty! */
-__cacheline_aligned_in_smp DEFINE_SPINLOCK(files_lock);
-
 /* SLAB cache for file structures */
 static struct kmem_cache *filp_cachep __read_mostly;
 
@@ -285,7 +283,8 @@ void __fput(struct file *file)
 		cdev_put(inode->i_cdev);
 	fops_put(file->f_op);
 	put_pid(file->f_owner.pid);
-	file_kill(file);
+	if (!special_file(inode->i_mode))
+		file_list_del(file, &inode->i_files);
 	if (file->f_mode & FMODE_WRITE)
 		drop_file_write_access(file);
 	file->f_path.dentry = NULL;
@@ -352,50 +351,57 @@ void put_filp(struct file *file)
 {
 	if (atomic_long_dec_and_test(&file->f_count)) {
 		security_file_free(file);
-		file_kill(file);
 		file_free(file);
 	}
 }
 
-void file_move(struct file *file, struct list_head *list)
+void init_file_list(struct file_list *files)
 {
-	if (!list)
-		return;
-	file_list_lock();
-	list_move(&file->f_u.fu_list, list);
-	file_list_unlock();
+	INIT_LIST_HEAD(&files->list);
+	spin_lock_init(&files->lock);
 }
 
-void file_kill(struct file *file)
+void file_list_add(struct file *file, struct file_list *files)
 {
-	if (!list_empty(&file->f_u.fu_list)) {
-		file_list_lock();
-		list_del_init(&file->f_u.fu_list);
-		file_list_unlock();
-	}
+	file_list_lock(files);
+	list_add(&file->f_u.fu_list, &files->list);
+	file_list_unlock(files);
+}
+EXPORT_SYMBOL(file_list_add);
+
+void file_list_del(struct file *file, struct file_list *files)
+{
+	file_list_lock(files);
+	list_del_init(&file->f_u.fu_list);
+	file_list_unlock(files);
 }
+EXPORT_SYMBOL(file_list_del);
 
 int fs_may_remount_ro(struct super_block *sb)
 {
+	struct inode *inode;
 	struct file *file;
 
 	/* Check that no files are currently opened for writing. */
-	file_list_lock();
-	list_for_each_entry(file, &sb->s_files, f_u.fu_list) {
-		struct inode *inode = file->f_path.dentry->d_inode;
-
-		/* File with pending delete? */
-		if (inode->i_nlink == 0)
-			goto too_bad;
-
-		/* Writeable file? */
-		if (S_ISREG(inode->i_mode) && (file->f_mode & FMODE_WRITE))
-			goto too_bad;
+	spin_lock(&inode_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		file_list_lock(&inode->i_files);
+		list_for_each_entry(file, &inode->i_files.list, f_u.fu_list) {
+			/* File with pending delete? */
+			if (inode->i_nlink == 0)
+				goto too_bad;
+
+			/* Writeable file? */
+			if (S_ISREG(inode->i_mode) && (file->f_mode & FMODE_WRITE))
+				goto too_bad;
+		}
+		file_list_unlock(&inode->i_files);
 	}
-	file_list_unlock();
+	spin_unlock(&inode_lock);
 	return 1; /* Tis' cool bro. */
 too_bad:
-	file_list_unlock();
+	file_list_unlock(&inode->i_files);
+	spin_unlock(&inode_lock);
 	return 0;
 }
 
@@ -408,33 +414,38 @@ too_bad:
  */
 void mark_files_ro(struct super_block *sb)
 {
+	struct inode *inode;
 	struct file *f;
 
 retry:
-	file_list_lock();
-	list_for_each_entry(f, &sb->s_files, f_u.fu_list) {
-		struct vfsmount *mnt;
-		if (!S_ISREG(f->f_path.dentry->d_inode->i_mode))
-		       continue;
-		if (!file_count(f))
-			continue;
-		if (!(f->f_mode & FMODE_WRITE))
-			continue;
-		f->f_mode &= ~FMODE_WRITE;
-		if (file_check_writeable(f) != 0)
-			continue;
-		file_release_write(f);
-		mnt = mntget(f->f_path.mnt);
-		file_list_unlock();
-		/*
-		 * This can sleep, so we can't hold
-		 * the file_list_lock() spinlock.
-		 */
-		mnt_drop_write(mnt);
-		mntput(mnt);
-		goto retry;
+	spin_lock(&inode_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		file_list_lock(&inode->i_files);
+		list_for_each_entry(f, &inode->i_files.list, f_u.fu_list) {
+			struct vfsmount *mnt;
+			if (!S_ISREG(f->f_path.dentry->d_inode->i_mode))
+				continue;
+			if (!file_count(f))
+				continue;
+			if (!(f->f_mode & FMODE_WRITE))
+				continue;
+			f->f_mode &= ~FMODE_WRITE;
+			if (file_check_writeable(f) != 0)
+				continue;
+			file_release_write(f);
+			mnt = mntget(f->f_path.mnt);
+			file_list_unlock(&inode->i_files);
+			/*
+			 * This can sleep, so we can't hold
+			 * the file_list_lock() spinlock.
+			 */
+			mnt_drop_write(mnt);
+			mntput(mnt);
+			goto retry;
+		}
+		file_list_unlock(&inode->i_files);
 	}
-	file_list_unlock();
+	spin_unlock(&inode_lock);
 }
 
 void __init files_init(unsigned long mempages)
diff --git a/fs/inode.c b/fs/inode.c
index 9d26490..9d52d43 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -251,6 +251,7 @@ void inode_init_once(struct inode *inode)
 	INIT_LIST_HEAD(&inode->inotify_watches);
 	mutex_init(&inode->inotify_mutex);
 #endif
+	init_file_list(&inode->i_files);
 }
 EXPORT_SYMBOL(inode_init_once);
 
diff --git a/fs/open.c b/fs/open.c
index 7200e23..20c3fc0 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -828,7 +828,8 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 	f->f_path.mnt = mnt;
 	f->f_pos = 0;
 	f->f_op = fops_get(inode->i_fop);
-	file_move(f, &inode->i_sb->s_files);
+	if (!special_file(inode->i_mode))
+		file_list_add(f, &inode->i_files);
 
 	error = security_dentry_open(f, cred);
 	if (error)
@@ -873,7 +874,8 @@ cleanup_all:
 			mnt_drop_write(mnt);
 		}
 	}
-	file_kill(f);
+	if (!special_file(inode->i_mode))
+		file_list_del(f, &inode->i_files);
 	f->f_path.dentry = NULL;
 	f->f_path.mnt = NULL;
 cleanup_file:
diff --git a/fs/select.c b/fs/select.c
index bd30fe8..99e4145 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -942,7 +942,6 @@ SYSCALL_DEFINE5(ppoll, struct pollfd __user *, ufds, unsigned int, nfds,
 }
 #endif /* HAVE_SET_RESTORE_SIGMASK */
 
-#ifdef CONFIG_FILE_HOTPLUG
 static int unpoll_file_once(wait_queue_head_t *q, struct file *file)
 {
 	unsigned long flags;
@@ -971,4 +970,3 @@ void unpoll_file(wait_queue_head_t *q, struct file *file)
 		schedule_timeout_uninterruptible(1);
 }
 EXPORT_SYMBOL(unpoll_file);
-#endif
diff --git a/fs/super.c b/fs/super.c
index 2ea1586..477aeb4 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -65,7 +65,6 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		INIT_LIST_HEAD(&s->s_dirty);
 		INIT_LIST_HEAD(&s->s_io);
 		INIT_LIST_HEAD(&s->s_more_io);
-		INIT_LIST_HEAD(&s->s_files);
 		INIT_LIST_HEAD(&s->s_instances);
 		INIT_HLIST_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 73242c3..5329fd6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -699,6 +699,11 @@ static inline int mapping_writably_mapped(struct address_space *mapping)
 	return mapping->i_mmap_writable != 0;
 }
 
+struct file_list {
+	spinlock_t		lock;
+	struct list_head	list;
+};
+
 /*
  * Use sequence counter to get consistent i_size on 32-bit processors.
  */
@@ -764,6 +769,7 @@ struct inode {
 	struct list_head	inotify_watches; /* watches on this inode */
 	struct mutex		inotify_mutex;	/* protects the watches list */
 #endif
+	struct file_list	i_files;
 
 	unsigned long		i_state;
 	unsigned long		dirtied_when;	/* jiffies of first dirtying */
@@ -934,9 +940,15 @@ struct file {
 	unsigned long f_mnt_write_state;
 #endif
 };
-extern spinlock_t files_lock;
-#define file_list_lock() spin_lock(&files_lock);
-#define file_list_unlock() spin_unlock(&files_lock);
+
+static inline void file_list_lock(struct file_list *files)
+{
+	spin_lock(&files->lock);
+}
+static inline void file_list_unlock(struct file_list *files)
+{
+	spin_unlock(&files->lock);
+}
 
 #define get_file(x)	atomic_long_inc(&(x)->f_count)
 #define file_count(x)	atomic_long_read(&(x)->f_count)
@@ -1333,7 +1345,6 @@ struct super_block {
 	struct list_head	s_io;		/* parked for writeback */
 	struct list_head	s_more_io;	/* parked for more writeback */
 	struct hlist_head	s_anon;		/* anonymous dentries for (nfs) exporting */
-	struct list_head	s_files;
 	/* s_dentry_lru and s_nr_dentry_unused are protected by dcache_lock */
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
@@ -2163,8 +2174,9 @@ static inline void insert_inode_hash(struct inode *inode) {
 }
 
 extern struct file * get_empty_filp(void);
-extern void file_move(struct file *f, struct list_head *list);
-extern void file_kill(struct file *f);
+extern void init_file_list(struct file_list *files);
+extern void file_list_add(struct file *f, struct file_list *files);
+extern void file_list_del(struct file *f, struct file_list *files);
 #ifdef CONFIG_BLOCK
 struct bio;
 extern void submit_bio(int, struct bio *);
diff --git a/include/linux/tty.h b/include/linux/tty.h
index fc39db9..7f04a5e 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -250,7 +250,7 @@ struct tty_struct {
 	struct work_struct hangup_work;
 	void *disc_data;
 	void *driver_data;
-	struct list_head tty_files;
+	struct file_list tty_files;
 
 #define N_TTY_BUF_SIZE 4096
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fcad7c..65afe36 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2244,8 +2244,8 @@ static inline void flush_unauthorized_files(const struct cred *cred,
 
 	tty = get_current_tty();
 	if (tty) {
-		file_list_lock();
-		if (!list_empty(&tty->tty_files)) {
+		file_list_lock(&tty->tty_files);
+		if (!list_empty(&tty->tty_files.list)) {
 			struct inode *inode;
 
 			/* Revalidate access to controlling tty.
@@ -2253,14 +2253,14 @@ static inline void flush_unauthorized_files(const struct cred *cred,
 			   than using file_has_perm, as this particular open
 			   file may belong to another process and we are only
 			   interested in the inode-based check here. */
-			file = list_first_entry(&tty->tty_files, struct file, f_u.fu_list);
+			file = list_first_entry(&tty->tty_files.list, struct file, f_u.fu_list);
 			inode = file->f_path.dentry->d_inode;
 			if (inode_has_perm(cred, inode,
 					   FILE__READ | FILE__WRITE, NULL)) {
 				drop_tty = 1;
 			}
 		}
-		file_list_unlock();
+		file_list_unlock(&tty->tty_files);
 		tty_kref_put(tty);
 	}
 	/* Reset controlling tty. */
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
