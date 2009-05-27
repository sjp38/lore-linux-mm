Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 096B86B00A9
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:08 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 27/43] c/r: support for open pipes
Date: Wed, 27 May 2009 13:32:53 -0400
Message-Id: <1243445589-32388-28-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
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

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/files.c             |    7 ++
 fs/pipe.c                      |  173 ++++++++++++++++++++++++++++++++++++++++
 fs/splice.c                    |   10 +-
 include/linux/checkpoint_hdr.h |   12 +++
 include/linux/pipe_fs_i.h      |    6 ++
 include/linux/splice.h         |    9 ++
 6 files changed, 212 insertions(+), 5 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index d7583d3..b264e40 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -17,6 +17,7 @@
 #include <linux/file.h>
 #include <linux/fdtable.h>
 #include <linux/fsnotify.h>
+#include <linux/pipe_fs_i.h>
 #include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -433,6 +434,12 @@ static struct restore_file_ops restore_file_ops[] = {
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
index 13414ec..d0aba56 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -13,6 +13,7 @@
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/splice.h>
 #include <linux/uio.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
@@ -22,6 +23,9 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
 /*
  * We use a start+len construction, which provides full use of the 
  * allocated memory.
@@ -795,6 +799,172 @@ pipe_rdwr_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int checkpoint_pipe(struct ckpt_ctx *ctx, struct inode *inode)
+{
+	struct ckpt_hdr_file_pipe_state *h;
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
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_PIPE);
+	if (!h)
+		goto out;
+	h->pipe_len = len;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
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
+	struct ckpt_hdr_file_pipe_state *h;
+	struct pipe_inode_info *pipe;
+	int len, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_PIPE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	len = h->pipe_len;
+	ckpt_hdr_put(ctx, h);
+
+	if (len < 0)
+		return -EINVAL;
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
+	file = ckpt_obj_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
+	/*
+	 * If ckpt_obj_fetch() returned NULL, then this is the first
+	 * time we see this pipe so need to restore the contents.
+	 * Otherwise, use the file pointer skip forward.
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
+		ret = ckpt_obj_insert(ctx, file,
+				      h->pipe_objref, CKPT_OBJ_FILE);
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
@@ -811,6 +981,7 @@ const struct file_operations read_pipefifo_fops = {
 	.open		= pipe_read_open,
 	.release	= pipe_read_release,
 	.fasync		= pipe_read_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations write_pipefifo_fops = {
@@ -823,6 +994,7 @@ const struct file_operations write_pipefifo_fops = {
 	.open		= pipe_write_open,
 	.release	= pipe_write_release,
 	.fasync		= pipe_write_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations rdwr_pipefifo_fops = {
@@ -836,6 +1008,7 @@ const struct file_operations rdwr_pipefifo_fops = {
 	.open		= pipe_rdwr_open,
 	.release	= pipe_rdwr_release,
 	.fasync		= pipe_rdwr_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 struct pipe_inode_info * alloc_pipe_info(struct inode *inode)
diff --git a/fs/splice.c b/fs/splice.c
index 96e0d58..de34b7c 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -979,8 +979,8 @@ static long do_splice_pipes(struct pipe_inode_info *ipipe,
 /*
  * Attempt to initiate a splice from pipe to file.
  */
-static long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
-			   loff_t *ppos, size_t len, unsigned int flags)
+long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
+		    loff_t *ppos, size_t len, unsigned int flags)
 {
 	struct pipe_inode_info *opipe;
 	int ret;
@@ -1011,9 +1011,9 @@ static long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
 /*
  * Attempt to initiate a splice from a file to a pipe.
  */
-static long do_splice_to(struct file *in, loff_t *ppos,
-			 struct pipe_inode_info *pipe, size_t len,
-			 unsigned int flags)
+long do_splice_to(struct file *in, loff_t *ppos,
+		  struct pipe_inode_info *pipe, size_t len,
+		  unsigned int flags)
 {
 	struct pipe_inode_info *ipipe;
 	int ret;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 36328e1..14654e8 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -59,6 +59,7 @@ enum {
 	CKPT_HDR_FILE_DESC,
 	CKPT_HDR_FILE_NAME,
 	CKPT_HDR_FILE,
+	CKPT_HDR_FILE_PIPE,
 
 	CKPT_HDR_MM = 401,
 	CKPT_HDR_VMA,
@@ -197,6 +198,7 @@ struct ckpt_hdr_file_desc {
 enum file_type {
 	CKPT_FILE_IGNORE = 0,
 	CKPT_FILE_GENERIC,
+	CKPT_FILE_PIPE,
 	CKPT_FILE_MAX
 };
 
@@ -215,6 +217,16 @@ struct ckpt_hdr_file_generic {
 	struct ckpt_hdr_file common;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_pipe {
+	struct ckpt_hdr_file common;
+	__s32 pipe_objref;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_pipe_state {
+	struct ckpt_hdr h;
+	__s32 pipe_len;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index c8f0385..b877598 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -153,4 +153,10 @@ void generic_pipe_buf_get(struct pipe_inode_info *, struct pipe_buffer *);
 int generic_pipe_buf_confirm(struct pipe_inode_info *, struct pipe_buffer *);
 int generic_pipe_buf_steal(struct pipe_inode_info *, struct pipe_buffer *);
 
+/* checkpoint/restart */
+#ifdef CONFIG_CHECKPOINT
+extern struct file *pipe_file_restore(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_file *ptr);
+#endif
+
 #endif
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 5f3faa9..50b475d 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -83,4 +83,13 @@ extern ssize_t splice_to_pipe(struct pipe_inode_info *,
 extern ssize_t splice_direct_to_actor(struct file *, struct splice_desc *,
 				      splice_direct_actor *);
 
+extern long link_pipe(struct pipe_inode_info *ipipe,
+		      struct pipe_inode_info *opipe,
+		      size_t len, unsigned int flags);
+extern long do_splice_to(struct file *in, loff_t *ppos,
+			 struct pipe_inode_info *pipe, size_t len,
+			 unsigned int flags);
+extern long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
+			   loff_t *ppos, size_t len, unsigned int flags);
+
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
