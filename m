Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7486B00BF
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:50 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 71/80] c/r: [pty 1/2] allow allocation of desired pty slave
Date: Wed, 23 Sep 2009 19:51:51 -0400
Message-Id: <1253749920-18673-72-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

During restart, we need to allocate pty slaves with the same
identifiers as recorded during checkpoint. Modify the allocation code
to allow an in-kernel caller to request a specific slave identifier.

For this, add a new field to task_struct - 'required_id'. It will
hold the desired identifier when restoring a (master) pty.

The code in ptmx_open() will use this value only for tasks that try to
open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
isn't CKPT_REQUIRED_NONE (-1).

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 drivers/char/pty.c        |   65 +++++++++++++++++++++++++++++++++++++++++---
 drivers/char/tty_io.c     |    4 +-
 fs/devpts/inode.c         |   13 +++++++--
 include/linux/devpts_fs.h |    6 +++-
 include/linux/sched.h     |    1 +
 include/linux/tty.h       |    2 +
 6 files changed, 80 insertions(+), 11 deletions(-)

diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index b33d668..e2fef99 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -612,9 +612,10 @@ static const struct tty_operations pty_unix98_ops = {
 };
 
 /**
- *	ptmx_open		-	open a unix 98 pty master
+ *	__ptmx_open		-	open a unix 98 pty master
  *	@inode: inode of device file
  *	@filp: file pointer to tty
+ *	@index: desired slave index
  *
  *	Allocate a unix98 pty master device from the ptmx driver.
  *
@@ -623,16 +624,15 @@ static const struct tty_operations pty_unix98_ops = {
  *		allocated_ptys_lock handles the list of free pty numbers
  */
 
-static int __ptmx_open(struct inode *inode, struct file *filp)
+static int __ptmx_open(struct inode *inode, struct file *filp, int index)
 {
 	struct tty_struct *tty;
 	int retval;
-	int index;
 
 	nonseekable_open(inode, filp);
 
 	/* find a device that is not in use. */
-	index = devpts_new_index(inode);
+	index = devpts_new_index(inode, index);
 	if (index < 0)
 		return index;
 
@@ -668,12 +668,66 @@ static int ptmx_open(struct inode *inode, struct file *filp)
 {
 	int ret;
 
+#ifdef CONFIG_CHECKPOINT
+	/*
+	 * If current task is restarting, we skip the actual open.
+	 * Instead, leave it up to the caller (restart code) to invoke
+	 * __ptmx_open() with the desired pty index request.
+	 *
+	 * NOTE: this gives a half-baked file that has ptmx f_op but
+	 * the tty (private_data) is NULL. It is the responsibility of
+	 * the _caller_ to ensure proper initialization before
+	 * allowing it to be used (ptmx_release() tolerates NULL tty).
+	 */
+	if (current->flags & PF_RESTARTING)
+		return 0;
+#endif
+
 	lock_kernel();
-	ret = __ptmx_open(inode, filp);
+	ret = __ptmx_open(inode, filp, UNSPECIFIED_PTY_INDEX);
 	unlock_kernel();
 	return ret;
 }
 
+static int ptmx_release(struct inode *inode, struct file *filp)
+{
+#ifdef CONFIG_CHECKPOINT
+	/*
+	 * It is possible for a restart to create a half-baked
+	 * ptmx file - see ptmx_open(). In that case there is no
+	 * tty (private_data) and nothing to do.
+	 */
+	if (!filp->private_data)
+		return 0;
+#endif
+
+	return tty_release(inode, filp);
+}
+
+struct file *pty_open_by_index(char *ptmxpath, int index)
+{
+	struct file *ptmxfile;
+	int ret;
+
+	/*
+	 * We need to pick a way to specify which devpts mountpoint to
+	 * use. For now, we'll just use whatever /dev/ptmx points to.
+	 */
+	ptmxfile = filp_open(ptmxpath, O_RDWR|O_NOCTTY, 0);
+	if (IS_ERR(ptmxfile))
+		return ptmxfile;
+
+	lock_kernel();
+	ret = __ptmx_open(ptmxfile->f_dentry->d_inode, ptmxfile, index);
+	unlock_kernel();
+	if (ret) {
+		fput(ptmxfile);
+		return ERR_PTR(ret);
+	}
+
+	return ptmxfile;
+}
+
 static struct file_operations ptmx_fops;
 
 static void __init unix98_pty_init(void)
@@ -730,6 +784,7 @@ static void __init unix98_pty_init(void)
 	/* Now create the /dev/ptmx special device */
 	tty_default_fops(&ptmx_fops);
 	ptmx_fops.open = ptmx_open;
+	ptmx_fops.release = ptmx_release;
 
 	cdev_init(&ptmx_cdev, &ptmx_fops);
 	if (cdev_add(&ptmx_cdev, MKDEV(TTYAUX_MAJOR, 2), 1) ||
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index a3afa0c..7853ea2 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -142,7 +142,7 @@ ssize_t redirected_tty_write(struct file *, const char __user *,
 							size_t, loff_t *);
 static unsigned int tty_poll(struct file *, poll_table *);
 static int tty_open(struct inode *, struct file *);
-static int tty_release(struct inode *, struct file *);
+int tty_release(struct inode *, struct file *);
 long tty_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 #ifdef CONFIG_COMPAT
 static long tty_compat_ioctl(struct file *file, unsigned int cmd,
@@ -1846,7 +1846,7 @@ static int tty_open(struct inode *inode, struct file *filp)
  *		Takes bkl. See tty_release_dev
  */
 
-static int tty_release(struct inode *inode, struct file *filp)
+int tty_release(struct inode *inode, struct file *filp)
 {
 	lock_kernel();
 	tty_release_dev(filp);
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 75efb02..82a2160 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -433,11 +433,11 @@ static struct file_system_type devpts_fs_type = {
  * to the System V naming convention
  */
 
-int devpts_new_index(struct inode *ptmx_inode)
+int devpts_new_index(struct inode *ptmx_inode, int req_idx)
 {
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
-	int index;
+	int index = req_idx;
 	int ida_ret;
 
 retry:
@@ -445,7 +445,9 @@ retry:
 		return -ENOMEM;
 
 	mutex_lock(&allocated_ptys_lock);
-	ida_ret = ida_get_new(&fsi->allocated_ptys, &index);
+	if (index == UNSPECIFIED_PTY_INDEX)
+		index = 0;
+	ida_ret = ida_get_new_above(&fsi->allocated_ptys, index, &index);
 	if (ida_ret < 0) {
 		mutex_unlock(&allocated_ptys_lock);
 		if (ida_ret == -EAGAIN)
@@ -453,6 +455,11 @@ retry:
 		return -EIO;
 	}
 
+	if (req_idx != UNSPECIFIED_PTY_INDEX && index != req_idx) {
+		ida_remove(&fsi->allocated_ptys, index);
+		mutex_unlock(&allocated_ptys_lock);
+		return -EBUSY;
+	}
 	if (index >= pty_limit) {
 		ida_remove(&fsi->allocated_ptys, index);
 		mutex_unlock(&allocated_ptys_lock);
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 5ce0e5f..163a70e 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -15,9 +15,13 @@
 
 #include <linux/errno.h>
 
+#define UNSPECIFIED_PTY_INDEX -1
+
 #ifdef CONFIG_UNIX98_PTYS
 
-int devpts_new_index(struct inode *ptmx_inode);
+struct file *pty_open_by_index(char *ptmxpath, int index);
+
+int devpts_new_index(struct inode *ptmx_inode, int req_idx);
 void devpts_kill_index(struct inode *ptmx_inode, int idx);
 /* mknod in devpts */
 int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 91b57db..0ab9553 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1482,6 +1482,7 @@ struct task_struct {
 #endif /* CONFIG_TRACING */
 #ifdef CONFIG_CHECKPOINT
 	struct ckpt_ctx *checkpoint_ctx;
+	unsigned long required_id;
 #endif
 };
 
diff --git a/include/linux/tty.h b/include/linux/tty.h
index e8c6c91..fd40561 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -468,6 +468,8 @@ extern void tty_ldisc_begin(void);
 /* This last one is just for the tty layer internals and shouldn't be used elsewhere */
 extern void tty_ldisc_enable(struct tty_struct *tty);
 
+/* This one is for ptmx_close() */
+extern int tty_release(struct inode *inode, struct file *filp);
 
 /* n_tty.c */
 extern struct tty_ldisc_ops tty_ldisc_N_TTY;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
