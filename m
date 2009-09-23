Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEF896B00B7
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:47 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 33/80] c/r: introduce new 'file_operations': ->checkpoint, ->collect()
Date: Wed, 23 Sep 2009 19:51:13 -0400
Message-Id: <1253749920-18673-34-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
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
---
 fs/fcntl.c         |   21 +++++++++++++--------
 include/linux/fs.h |    7 +++++++
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index ae41308..78d3116 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -339,6 +339,18 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
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
@@ -348,14 +360,7 @@ SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
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
index a21f175..02638a7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -388,6 +388,7 @@ struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
+struct ckpt_ctx;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -1088,6 +1089,8 @@ struct file_lock {
 
 #include <linux/fcntl.h>
 
+extern int vfs_fcntl(int fd, unsigned cmd, unsigned long arg, struct file *fp);
+
 extern void send_sigio(struct fown_struct *fown, int fd, int band);
 
 /* fs/sync.c */
@@ -1510,6 +1513,8 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*checkpoint)(struct ckpt_ctx *, struct file *);
+	int (*collect)(struct ckpt_ctx *, struct file *);
 };
 
 struct inode_operations {
@@ -2311,6 +2316,8 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
 void inode_set_bytes(struct inode *inode, loff_t bytes);
 
+#define generic_file_checkpoint NULL
+
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
 extern int vfs_stat(char __user *, struct kstat *);
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
