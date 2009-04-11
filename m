Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5B3175F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:07:38 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:07:39 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m1ab6n75ro.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 4/9] vfs: Generalize the file_list
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


file_list_lock is held when files are being revoked
aka hung up on in tty_io, and also needs to be done
in a more general revoke case.  The more general revoke
case also needs to sleep so I have converted file_list_lock
into a mutex.

To make it clear what is on the file list and when I have changed
file_move to file_add.  The callers have been modified to to ensure
file_add is called exactly once on a file.  In __dentry_open
file_add is called on everything except device files.  In __ptmx_open
and __tty_open file_add is called to place the ttys on the tty_files
list.

To make using the file_list for efficient for handling revokes
I have moved the list head from the superblock to the inode.
This means only relevant files need to be looked at.

fs_may_remount_ro and mark_files_ro have been modified to
walk the inode list to find all of the inodes and then to
walk the file list on those inodes.  It is a slightly slower
process but just as efficient and potentially more correct
as inodes may have some influence on the the rw state of the
filesystem that files do not.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/char/pty.c    |    2 +-
 drivers/char/tty_io.c |    2 +-
 fs/file_table.c       |   27 ++++++++++++++++++---------
 fs/inode.c            |    1 +
 fs/open.c             |    3 ++-
 fs/super.c            |   49 +++++++++++++++++++++++++++----------------------
 include/linux/fs.h    |   10 +++++-----
 7 files changed, 55 insertions(+), 39 deletions(-)

diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index 31038a0..3ed304c 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -662,7 +662,7 @@ static int __ptmx_open(struct inode *inode, struct file *filp)
 
 	set_bit(TTY_PTY_LOCK, &tty->flags); /* LOCK THE SLAVE */
 	filp->private_data = tty;
-	file_move(filp, &tty->tty_files);
+	file_add(filp, &tty->tty_files);
 
 	retval = devpts_pty_new(inode, tty->link);
 	if (retval)
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 66b99a2..22b978e 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -1836,7 +1836,7 @@ got_driver:
 		return PTR_ERR(tty);
 
 	filp->private_data = tty;
-	file_move(filp, &tty->tty_files);
+	file_add(filp, &tty->tty_files);
 	check_tty_count(tty, "tty_open");
 	if (tty->driver->type == TTY_DRIVER_TYPE_PTY &&
 	    tty->driver->subtype == PTY_TYPE_MASTER)
diff --git a/fs/file_table.c b/fs/file_table.c
index 54018fe..03d74b6 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -22,6 +22,7 @@
 #include <linux/fsnotify.h>
 #include <linux/sysctl.h>
 #include <linux/percpu_counter.h>
+#include <linux/writeback.h>
 
 #include <asm/atomic.h>
 
@@ -31,7 +32,7 @@ struct files_stat_struct files_stat = {
 };
 
 /* public. Not pretty! */
-__cacheline_aligned_in_smp DEFINE_SPINLOCK(files_lock);
+__cacheline_aligned_in_smp DEFINE_MUTEX(files_lock);
 
 /* SLAB cache for file structures */
 static struct kmem_cache *filp_cachep __read_mostly;
@@ -357,12 +358,12 @@ void put_filp(struct file *file)
 	}
 }
 
-void file_move(struct file *file, struct list_head *list)
+void file_add(struct file *file, struct list_head *list)
 {
 	if (!list)
 		return;
 	file_list_lock();
-	list_move(&file->f_u.fu_list, list);
+	list_add(&file->f_u.fu_list, list);
 	file_list_unlock();
 }
 
@@ -377,24 +378,32 @@ void file_kill(struct file *file)
 
 int fs_may_remount_ro(struct super_block *sb)
 {
+	struct inode *inode;
 	struct file *file;
 
 	/* Check that no files are currently opened for writing. */
 	file_list_lock();
-	list_for_each_entry(file, &sb->s_files, f_u.fu_list) {
-		struct inode *inode = file->f_path.dentry->d_inode;
-
+	spin_lock(&inode_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
 		/* File with pending delete? */
 		if (inode->i_nlink == 0)
 			goto too_bad;
 
-		/* Writeable file? */
-		if (S_ISREG(inode->i_mode) && (file->f_mode & FMODE_WRITE))
-			goto too_bad;
+		/* Regular file */
+		if (!S_ISREG(inode->i_mode))
+			continue;
+
+		list_for_each_entry(file, &inode->i_files, f_u.fu_list) {
+			/* Writeable file? */
+			if (file->f_mode & FMODE_WRITE)
+				goto too_bad;
+		}
 	}
+	spin_unlock(&inode_lock);
 	file_list_unlock();
 	return 1; /* Tis' cool bro. */
 too_bad:
+	spin_unlock(&inode_lock);
 	file_list_unlock();
 	return 0;
 }
diff --git a/fs/inode.c b/fs/inode.c
index d06d6d2..9682caf 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -238,6 +238,7 @@ void inode_init_once(struct inode *inode)
 	memset(inode, 0, sizeof(*inode));
 	INIT_HLIST_NODE(&inode->i_hash);
 	INIT_LIST_HEAD(&inode->i_dentry);
+	INIT_LIST_HEAD(&inode->i_files);
 	INIT_LIST_HEAD(&inode->i_devices);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
 	spin_lock_init(&inode->i_data.tree_lock);
diff --git a/fs/open.c b/fs/open.c
index 377eb25..5e201cb 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -828,7 +828,8 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 	f->f_path.mnt = mnt;
 	f->f_pos = 0;
 	f->f_op = fops_get(inode->i_fop);
-	file_move(f, &inode->i_sb->s_files);
+	if (!special_file(inode->i_mode))
+		file_add(f, &inode->i_files);
 
 	error = security_dentry_open(f, cred);
 	if (error)
diff --git a/fs/super.c b/fs/super.c
index 786fe7d..e55299c 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -67,7 +67,6 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		INIT_LIST_HEAD(&s->s_dirty);
 		INIT_LIST_HEAD(&s->s_io);
 		INIT_LIST_HEAD(&s->s_more_io);
-		INIT_LIST_HEAD(&s->s_files);
 		INIT_LIST_HEAD(&s->s_instances);
 		INIT_HLIST_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
@@ -597,32 +596,38 @@ out:
 
 static void mark_files_ro(struct super_block *sb)
 {
+	struct inode *inode;
 	struct file *f;
 
 retry:
 	file_list_lock();
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
+		list_for_each_entry(f, &inode->i_files, f_u.fu_list) {
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
+			spin_unlock(&inode_lock);
+			file_list_unlock();
+			/*
+			 * This can sleep, so we can't hold
+			 * the inode_lock spinlock.
+			 */
+			mnt_drop_write(mnt);
+			mntput(mnt);
+			goto retry;
+		}
 	}
+	spin_unlock(&inode_lock);
 	file_list_unlock();
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 562d285..7805d20 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -656,6 +656,7 @@ struct inode {
 	struct list_head	i_list;
 	struct list_head	i_sb_list;
 	struct list_head	i_dentry;
+	struct list_head	i_files;
 	unsigned long		i_ino;
 	atomic_t		i_count;
 	unsigned int		i_nlink;
@@ -878,9 +879,9 @@ struct file {
 	unsigned long f_mnt_write_state;
 #endif
 };
-extern spinlock_t files_lock;
-#define file_list_lock() spin_lock(&files_lock);
-#define file_list_unlock() spin_unlock(&files_lock);
+extern struct mutex files_lock;
+#define file_list_lock() mutex_lock(&files_lock);
+#define file_list_unlock() mutex_unlock(&files_lock);
 
 #define get_file(x)	atomic_long_inc(&(x)->f_count)
 #define file_count(x)	atomic_long_read(&(x)->f_count)
@@ -1277,7 +1278,6 @@ struct super_block {
 	struct list_head	s_io;		/* parked for writeback */
 	struct list_head	s_more_io;	/* parked for more writeback */
 	struct hlist_head	s_anon;		/* anonymous dentries for (nfs) exporting */
-	struct list_head	s_files;
 	/* s_dentry_lru and s_nr_dentry_unused are protected by dcache_lock */
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
@@ -2116,7 +2116,7 @@ static inline void insert_inode_hash(struct inode *inode) {
 }
 
 extern struct file * get_empty_filp(void);
-extern void file_move(struct file *f, struct list_head *list);
+extern void file_add(struct file *f, struct list_head *list);
 extern void file_kill(struct file *f);
 #ifdef CONFIG_BLOCK
 struct bio;
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
