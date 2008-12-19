Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C873F6B0047
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 01:18:07 -0500 (EST)
Date: Fri, 19 Dec 2008 07:20:12 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/2] mnt_want_write speedup 2
Message-ID: <20081219062012.GB16268@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081219061937.GA16268@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <haveblue@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


This patch speeds up lmbench lat_mmap test by about another 2% after the
first patch.

Before:
 avg = 462.286
 std = 5.46106

After:
 avg = 453.12
 std = 9.58257

(50 runs of each, stddev gives a reasonable confidence)

It does this by introducing mnt_clone_write, which avoids some heavyweight
operations of mnt_want_write if called on a vfsmount which we know already
has a write count; and mnt_want_write_file, which can call mnt_clone_write
if the file is open for write.

After these two patches, mnt_want_write and mnt_drop_write go from 7% on
the profile down to 1.3% (including mnt_clone_write).

---
 fs/file_table.c       |    3 +--
 fs/inode.c            |    2 +-
 fs/namespace.c        |   38 ++++++++++++++++++++++++++++++++++++++
 fs/open.c             |    4 ++--
 fs/xattr.c            |    4 ++--
 include/linux/mount.h |    2 ++
 6 files changed, 46 insertions(+), 7 deletions(-)

Index: linux-2.6/fs/file_table.c
===================================================================
--- linux-2.6.orig/fs/file_table.c
+++ linux-2.6/fs/file_table.c
@@ -210,8 +210,7 @@ int init_file(struct file *file, struct
 	 */
 	if ((mode & FMODE_WRITE) && !special_file(dentry->d_inode->i_mode)) {
 		file_take_write(file);
-		error = mnt_want_write(mnt);
-		WARN_ON(error);
+		mnt_clone_write(mnt);
 	}
 	return error;
 }
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -1249,7 +1249,7 @@ void file_update_time(struct file *file)
 	if (IS_NOCMTIME(inode))
 		return;
 
-	err = mnt_want_write(file->f_path.mnt);
+	err = mnt_want_write_file(file->f_path.mnt, file);
 	if (err)
 		return;
 
Index: linux-2.6/fs/namespace.c
===================================================================
--- linux-2.6.orig/fs/namespace.c
+++ linux-2.6/fs/namespace.c
@@ -264,6 +264,44 @@ out:
 EXPORT_SYMBOL_GPL(mnt_want_write);
 
 /**
+ * mnt_clone_write - get write access to a mount
+ * @mnt: the mount on which to take a write
+ *
+ * This is effectively like mnt_want_write, except
+ * it must only be used to take an extra write reference
+ * on a mountpoint that we already know has a write reference
+ * on it. This allows some optimisation.
+ *
+ * After finished, mnt_drop_write must be called as usual to
+ * drop the reference.
+ */
+void mnt_clone_write(struct vfsmount *mnt)
+{
+	preempt_disable();
+	inc_mnt_writers(mnt);
+	preempt_enable();
+}
+EXPORT_SYMBOL_GPL(mnt_clone_write);
+
+/**
+ * mnt_want_write_file - get write access to a file's mount
+ * @file: the file who's mount on which to take a write
+ *
+ * This is like mnt_want_write, but it takes a file and can
+ * do some optimisations if the file is open for write already
+ */
+int mnt_want_write_file(struct vfsmount *mnt, struct file *file)
+{
+	if (!(file->f_mode & FMODE_WRITE))
+		return mnt_want_write(mnt);
+	else {
+		mnt_clone_write(mnt);
+		return 0;
+	}
+}
+EXPORT_SYMBOL_GPL(mnt_want_write_file);
+
+/**
  * mnt_drop_write - give up write access to a mount
  * @mnt: the mount on which to give up write access
  *
Index: linux-2.6/fs/open.c
===================================================================
--- linux-2.6.orig/fs/open.c
+++ linux-2.6/fs/open.c
@@ -597,7 +597,7 @@ asmlinkage long sys_fchmod(unsigned int
 
 	audit_inode(NULL, dentry);
 
-	err = mnt_want_write(file->f_path.mnt);
+	err = mnt_want_write_file(file->f_path.mnt, file);
 	if (err)
 		goto out_putf;
 	mutex_lock(&inode->i_mutex);
@@ -748,7 +748,7 @@ asmlinkage long sys_fchown(unsigned int
 	if (!file)
 		goto out;
 
-	error = mnt_want_write(file->f_path.mnt);
+	error = mnt_want_write_file(file->f_path.mnt, file);
 	if (error)
 		goto out_fput;
 	dentry = file->f_path.dentry;
Index: linux-2.6/fs/xattr.c
===================================================================
--- linux-2.6.orig/fs/xattr.c
+++ linux-2.6/fs/xattr.c
@@ -302,7 +302,7 @@ sys_fsetxattr(int fd, const char __user
 		return error;
 	dentry = f->f_path.dentry;
 	audit_inode(NULL, dentry);
-	error = mnt_want_write(f->f_path.mnt);
+	error = mnt_want_write_file(f->f_path.mnt, f);
 	if (!error) {
 		error = setxattr(dentry, name, value, size, flags);
 		mnt_drop_write(f->f_path.mnt);
@@ -533,7 +533,7 @@ sys_fremovexattr(int fd, const char __us
 		return error;
 	dentry = f->f_path.dentry;
 	audit_inode(NULL, dentry);
-	error = mnt_want_write(f->f_path.mnt);
+	error = mnt_want_write_file(f->f_path.mnt, f);
 	if (!error) {
 		error = removexattr(dentry, name);
 		mnt_drop_write(f->f_path.mnt);
Index: linux-2.6/include/linux/mount.h
===================================================================
--- linux-2.6.orig/include/linux/mount.h
+++ linux-2.6/include/linux/mount.h
@@ -90,6 +90,8 @@ static inline struct vfsmount *mntget(st
 }
 
 extern int mnt_want_write(struct vfsmount *mnt);
+extern int mnt_want_write_file(struct vfsmount *mnt, struct file *file);
+extern void mnt_clone_write(struct vfsmount *mnt);
 extern void mnt_drop_write(struct vfsmount *mnt);
 extern void mntput_no_expire(struct vfsmount *mnt);
 extern void mnt_pin(struct vfsmount *mnt);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
