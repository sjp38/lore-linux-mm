Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 012BC600372
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:15:42 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 51/96] c/r: support for open pipes
Date: Wed, 17 Mar 2010 12:08:39 -0400
Message-Id: <1268842164-5590-52-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

A pipe is a double-headed inode with a buffer attached to it. We
checkpoint the pipe buffer only once, as soon as we hit one side of
the pipe, regardless whether it is read- or write- end.

To checkpoint a file descriptor that refers to a pipe (either end), we
first lookup the inode in the hash table: If not found, it is the
first encounter of this pipe. Besides the file descriptor, we also (a)
save the pipe data, and (b) register the pipe inode in the hash. If
found, it is the second encounter of this pipe, namely, as we hit the
other end of the same pipe. In both cases we write the pipe-objref of
the inode.

To restore, create a new pipe and thus have two file pointers (read-
and write- ends). We only use one of them, depending on which side was
checkpointed first. We register the file pointer of the other end in
the hash table, with the pipe_objref given for this pipe from the
checkpoint, to be used later when the other arrives. At this point we
also restore the contents of the pipe buffers.

To save the pipe buffer, given a source pipe, use do_tee() to clone
its contents into a temporary 'struct pipe_inode_info', and then use
do_splice_from() to transfer it directly to the checkpoint image file.

To restore the pipe buffer, with a fresh newly allocated target pipe,
use do_splice_to() to splice the data directly between the checkpoint
image file and the pipe.

Changelog[v19-rc1]:
  - Switch to ckpt_obj_try_fetch()
  - [Matt Helsley] Add cpp definitions for enums
Changelog[v18]:
  - Adjust format of pipe buffer to include the mandatory pre-header
Changelog[v17]:
  - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/files.c             |    7 ++
 fs/pipe.c                      |  157 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    9 +++
 include/linux/pipe_fs_i.h      |    8 ++
 4 files changed, 181 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index b404c8f..1c294fe 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -17,6 +17,7 @@
 #include <linux/file.h>
 #include <linux/fdtable.h>
 #include <linux/fsnotify.h>
+#include <linux/pipe_fs_i.h>
 #include <linux/syscalls.h>
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
@@ -592,6 +593,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_GENERIC,
 		.restore = generic_file_restore,
 	},
+	/* pipes */
+	{
+		.file_name = "PIPE",
+		.file_type = CKPT_FILE_PIPE,
+		.restore = pipe_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/fs/pipe.c b/fs/pipe.c
index 37ba29f..747b2d7 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -13,11 +13,13 @@
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/splice.h>
 #include <linux/uio.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/audit.h>
 #include <linux/syscalls.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -828,6 +830,158 @@ pipe_rdwr_open(struct inode *inode, struct file *filp)
 	return ret;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int checkpoint_pipe(struct ckpt_ctx *ctx, struct inode *inode)
+{
+	struct pipe_inode_info *pipe;
+	int len, ret = -ENOMEM;
+
+	pipe = alloc_pipe_info(NULL);
+	if (!pipe)
+		return ret;
+
+	pipe->readers = 1;	/* bluff link_pipe() below */
+	len = link_pipe(inode->i_pipe, pipe, INT_MAX, SPLICE_F_NONBLOCK);
+	if (len == -EAGAIN)
+		len = 0;
+	if (len < 0) {
+		ret = len;
+		goto out;
+	}
+
+	ret = ckpt_write_obj_type(ctx, NULL, len, CKPT_HDR_PIPE_BUF);
+	if (ret < 0)
+		goto out;
+
+	ret = do_splice_from(pipe, ctx->file, &ctx->file->f_pos, len, 0);
+	if (ret < 0)
+		goto out;
+	if (ret != len)
+		ret = -EPIPE;  /* can occur due to an error in target file */
+ out:
+	__free_pipe_info(pipe);
+	return ret;
+}
+
+static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_pipe *h;
+	struct inode *inode = file->f_dentry->d_inode;
+	int objref, first, ret;
+
+	objref = ckpt_obj_lookup_add(ctx, inode, CKPT_OBJ_INODE, &first);
+	if (objref < 0)
+		return objref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_PIPE;
+	h->pipe_objref = objref;
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, &h->common.h);
+	if (ret < 0)
+		goto out;
+
+	if (first)
+		ret = checkpoint_pipe(ctx, inode);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_pipe(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct pipe_inode_info *pipe;
+	int len, ret;
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_PIPE_BUF);
+	if (len < 0)
+		return len;
+
+	pipe = file->f_dentry->d_inode->i_pipe;
+	ret = do_splice_to(ctx->file, &ctx->file->f_pos, pipe, len, 0);
+
+	if (ret >= 0 && ret != len)
+		ret = -EPIPE;  /* can occur due to an error in source file */
+
+	return ret;
+}
+
+struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_pipe *h = (struct ckpt_hdr_file_pipe *) ptr;
+	struct file *file;
+	int fds[2], which, ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE  ||
+	    ptr->h.len != sizeof(*h) || ptr->f_type != CKPT_FILE_PIPE)
+		return ERR_PTR(-EINVAL);
+
+	if (h->pipe_objref <= 0)
+		return ERR_PTR(-EINVAL);
+
+	file = ckpt_obj_try_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
+	/*
+	 * If ckpt_obj_try_fetch() returned ERR_PTR(-EINVAL), then this is
+	 * the first time we see this pipe so need to restore the
+	 * contents.  Otherwise, use the file pointer skip forward.
+	 */
+	if (!IS_ERR(file)) {
+		get_file(file);
+	} else if (PTR_ERR(file) == -EINVAL) {
+		/* first encounter of this pipe: create it */
+		ret = do_pipe_flags(fds, 0);
+		if (ret < 0)
+			return file;
+
+		which = (ptr->f_flags & O_WRONLY ? 1 : 0);
+		/*
+		 * Below we return the file corersponding to one side
+		 * of the pipe for our caller to use. Now insert the
+		 * other side of the pipe to the hash, to be picked up
+		 * when that side is restored.
+		 */
+		file = fget(fds[1-which]);	/* the 'other' side */
+		if (!file)	/* this should _never_ happen ! */
+			return ERR_PTR(-EBADF);
+		ret = ckpt_obj_insert(ctx, file, h->pipe_objref, CKPT_OBJ_FILE);
+		if (ret < 0)
+			goto out;
+
+		ret = restore_pipe(ctx, file);
+		fput(file);
+		if (ret < 0)
+			return ERR_PTR(ret);
+
+		file = fget(fds[which]);	/* 'this' side */
+		if (!file)	/* this should _never_ happen ! */
+			return ERR_PTR(-EBADF);
+
+		/* get rid of the file descriptors (caller sets that) */
+		sys_close(fds[which]);
+		sys_close(fds[1-which]);
+	} else {
+		return file;
+	}
+
+	ret = restore_file_common(ctx, file, ptr);
+ out:
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+
+	return file;
+}
+#else
+#define pipe_file_checkpoint  NULL
+#endif /* CONFIG_CHECKPOINT */
+
 /*
  * The file_operations structs are not static because they
  * are also used in linux/fs/fifo.c to do operations on FIFOs.
@@ -844,6 +998,7 @@ const struct file_operations read_pipefifo_fops = {
 	.open		= pipe_read_open,
 	.release	= pipe_read_release,
 	.fasync		= pipe_read_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations write_pipefifo_fops = {
@@ -856,6 +1011,7 @@ const struct file_operations write_pipefifo_fops = {
 	.open		= pipe_write_open,
 	.release	= pipe_write_release,
 	.fasync		= pipe_write_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations rdwr_pipefifo_fops = {
@@ -869,6 +1025,7 @@ const struct file_operations rdwr_pipefifo_fops = {
 	.open		= pipe_rdwr_open,
 	.release	= pipe_rdwr_release,
 	.fasync		= pipe_rdwr_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 struct pipe_inode_info * alloc_pipe_info(struct inode *inode)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 6fae6ef..885d06b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -90,6 +90,8 @@ enum {
 #define CKPT_HDR_FILE_NAME CKPT_HDR_FILE_NAME
 	CKPT_HDR_FILE,
 #define CKPT_HDR_FILE CKPT_HDR_FILE
+	CKPT_HDR_PIPE_BUF,
+#define CKPT_HDR_PIPE_BUF CKPT_HDR_PIPE_BUF
 
 	CKPT_HDR_MM = 401,
 #define CKPT_HDR_MM CKPT_HDR_MM
@@ -277,6 +279,8 @@ enum file_type {
 #define CKPT_FILE_IGNORE CKPT_FILE_IGNORE
 	CKPT_FILE_GENERIC,
 #define CKPT_FILE_GENERIC CKPT_FILE_GENERIC
+	CKPT_FILE_PIPE,
+#define CKPT_FILE_PIPE CKPT_FILE_PIPE
 	CKPT_FILE_MAX
 #define CKPT_FILE_MAX CKPT_FILE_MAX
 };
@@ -296,6 +300,11 @@ struct ckpt_hdr_file_generic {
 	struct ckpt_hdr_file common;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_pipe {
+	struct ckpt_hdr_file common;
+	__s32 pipe_objref;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index b43a9e0..e526a12 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -154,4 +154,12 @@ int generic_pipe_buf_confirm(struct pipe_inode_info *, struct pipe_buffer *);
 int generic_pipe_buf_steal(struct pipe_inode_info *, struct pipe_buffer *);
 void generic_pipe_buf_release(struct pipe_inode_info *, struct pipe_buffer *);
 
+/* checkpoint/restart */
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+extern struct file *pipe_file_restore(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_file *ptr);
+#endif
+
 #endif
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
