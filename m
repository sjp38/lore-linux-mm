Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B68B26B0229
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:59 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 37/96] c/r: introduce new 'file_operations': ->checkpoint, ->collect()
Date: Wed, 17 Mar 2010 12:08:25 -0400
Message-Id: <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

While we assume all normal files and directories can be checkpointed,
there are, as usual in the VFS, specialized places that will always
need an ability to override these defaults. Although we could do this
completely in the checkpoint code, that would bitrot quickly.

This adds a new 'file_operations' function for checkpointing a file.
It is assumed that there should be a dirt-simple way to make something
(un)checkpointable that fits in with current code.

As you can see in the ext[234] patches down the road, all that we have
to do to make something simple be supported is add a single "generic"
f_op entry.

Also adds a new 'file_operations' function for 'collecting' a file for
leak-detection during full-container checkpoint. This is useful for
those files that hold references to other "collectable" objects. Two
examples are pty files that point to corresponding tty objects, and
eventpoll files that refer to the files they are monitoring.

Finally, this patch introduces vfs_fcntl() so that it can be called
from restart (see patch adding restart of files).

Changelog[v17]
  - Introduce 'collect' method
Changelog[v17]
  - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 fs/fcntl.c         |   21 +++++++++++++--------
 include/linux/fs.h |    7 +++++++
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 97e01dc..e1f02ca 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -418,6 +418,18 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 	return err;
 }
 
+int vfs_fcntl(int fd, unsigned int cmd, unsigned long arg, struct file *filp)
+{
+	int err;
+
+	err = security_file_fcntl(filp, cmd, arg);
+	if (err)
+		goto out;
+	err = do_fcntl(fd, cmd, arg, filp);
+ out:
+	return err;
+}
+
 SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
 {	
 	struct file *filp;
@@ -427,14 +439,7 @@ SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
 	if (!filp)
 		goto out;
 
-	err = security_file_fcntl(filp, cmd, arg);
-	if (err) {
-		fput(filp);
-		return err;
-	}
-
-	err = do_fcntl(fd, cmd, arg, filp);
-
+	err = vfs_fcntl(fd, cmd, arg, filp);
  	fput(filp);
 out:
 	return err;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6c08df2..65ebec5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -394,6 +394,7 @@ struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
+struct ckpt_ctx;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -1093,6 +1094,8 @@ struct file_lock {
 
 #include <linux/fcntl.h>
 
+extern int vfs_fcntl(int fd, unsigned cmd, unsigned long arg, struct file *fp);
+
 extern void send_sigio(struct fown_struct *fown, int fd, int band);
 
 #ifdef CONFIG_FILE_LOCKING
@@ -1504,6 +1507,8 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*checkpoint)(struct ckpt_ctx *, struct file *);
+	int (*collect)(struct ckpt_ctx *, struct file *);
 };
 
 struct inode_operations {
@@ -2313,6 +2318,8 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
 void inode_set_bytes(struct inode *inode, loff_t bytes);
 
+#define generic_file_checkpoint NULL
+
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
 extern int vfs_stat(char __user *, struct kstat *);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
