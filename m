Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 527D06B00A5
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:11 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 26/43] splice: added support for pipe-to-pipe splice()
Date: Wed, 27 May 2009 13:32:52 -0400
Message-Id: <1243445589-32388-27-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch is a modified version of Max Kellerman patch that allows
splice() between pipes (see http://patchwork/kernel/org/patch/21042).
By refactoring link_pipe(), do_tee() and do_splice_pipes() shrink
considerably. Below is Max's original description:

--
This patch enables the splice() system call to copy buffers from one
pipe to another.  This obvious and trivial use case for splice() was
not supported until now.

It reuses the functions link_ipipe_prep() and link_opipe_prep() from
the tee() system call implementation.
--

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 fs/splice.c |  203 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 166 insertions(+), 37 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 92dd63c..96e0d58 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -903,13 +903,95 @@ ssize_t generic_splice_sendpage(struct pipe_inode_info *pipe, struct file *out,
 EXPORT_SYMBOL(generic_splice_sendpage);
 
 /*
+ * After the inode slimming patch, i_pipe/i_bdev/i_cdev share the same
+ * location, so checking ->i_pipe is not enough to verify that this is a
+ * pipe.
+ */
+static inline struct pipe_inode_info *pipe_info(struct inode *inode)
+{
+	if (S_ISFIFO(inode->i_mode))
+		return inode->i_pipe;
+
+	return NULL;
+}
+
+static int link_pipe_prep(struct pipe_inode_info *ipipe,
+			  struct pipe_inode_info *opipe,
+			  unsigned int flags);
+static long do_link_pipe(struct pipe_inode_info *ipipe,
+			 struct pipe_inode_info *opipe,
+			 size_t len, unsigned int flags, int move);
+
+/**
+* Splice pages from one pipe to another.
+*
+* @ipipe the input pipe
+* @opipe the output pipe
+* @len the maximum number of bytes to move
+* @flags splice modifier flags
+*/
+static long do_splice_pipes(struct pipe_inode_info *ipipe,
+			    struct pipe_inode_info *opipe,
+			    size_t len, unsigned int flags)
+{
+	int do_wakeup;
+	long ret;
+
+	if (ipipe == opipe)
+		return -EINVAL;
+
+	ret = link_pipe_prep(ipipe, opipe, flags);
+	if (ret < 0)
+		return ret;
+
+	/* both pipes are now locked */
+
+	do_wakeup = ipipe->nrbufs;
+	ret = do_link_pipe(ipipe, opipe, len, flags, 1);
+	do_wakeup -= ipipe->nrbufs;
+
+	pipe_unlock(ipipe);
+	pipe_unlock(opipe);
+
+	if (do_wakeup) {
+		/* at least one buffer was removed from the
+		   input pipe: wake up potential writers */
+		smp_mb();
+		if (waitqueue_active(&ipipe->wait))
+			wake_up_interruptible(&ipipe->wait);
+		kill_fasync(&ipipe->fasync_writers, SIGIO, POLL_OUT);
+	}
+
+	/*
+	 * If we put data in the output pipe, wakeup any potential
+	 * readers.
+	 */
+	if (ret > 0) {
+		smp_mb();
+		if (waitqueue_active(&opipe->wait))
+			wake_up_interruptible(&opipe->wait);
+		kill_fasync(&opipe->fasync_readers, SIGIO, POLL_IN);
+	}
+
+	return ret;
+}
+
+/*
  * Attempt to initiate a splice from pipe to file.
  */
 static long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
 			   loff_t *ppos, size_t len, unsigned int flags)
 {
+	struct pipe_inode_info *opipe;
 	int ret;
 
+	opipe = pipe_info(out->f_dentry->d_inode);
+	if (opipe) {
+		if (unlikely(!(out->f_mode & FMODE_WRITE)))
+			return -EBADF;
+		return do_splice_pipes(pipe, opipe, len, flags);
+	}
+
 	if (unlikely(!out->f_op || !out->f_op->splice_write))
 		return -EINVAL;
 
@@ -933,8 +1015,16 @@ static long do_splice_to(struct file *in, loff_t *ppos,
 			 struct pipe_inode_info *pipe, size_t len,
 			 unsigned int flags)
 {
+	struct pipe_inode_info *ipipe;
 	int ret;
 
+	ipipe = pipe_info(in->f_dentry->d_inode);
+	if (ipipe) {
+		if (unlikely(!(in->f_mode & FMODE_READ)))
+			return -EBADF;
+		return do_splice_pipes(ipipe, pipe, len, flags);
+	}
+
 	if (unlikely(!in->f_op || !in->f_op->splice_read))
 		return -EINVAL;
 
@@ -1113,19 +1203,6 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 }
 
 /*
- * After the inode slimming patch, i_pipe/i_bdev/i_cdev share the same
- * location, so checking ->i_pipe is not enough to verify that this is a
- * pipe.
- */
-static inline struct pipe_inode_info *pipe_info(struct inode *inode)
-{
-	if (S_ISFIFO(inode->i_mode))
-		return inode->i_pipe;
-
-	return NULL;
-}
-
-/*
  * Determine where to splice to/from.
  */
 static long do_splice(struct file *in, loff_t __user *off_in,
@@ -1140,7 +1217,10 @@ static long do_splice(struct file *in, loff_t __user *off_in,
 	if (pipe) {
 		if (off_in)
 			return -ESPIPE;
+
 		if (off_out) {
+			if (pipe_info(out->f_path.dentry->d_inode))
+				return -ESPIPE;
 			if (out->f_op->llseek == no_llseek)
 				return -EINVAL;
 			if (copy_from_user(&offset, off_out, sizeof(loff_t)))
@@ -1639,21 +1719,36 @@ static int link_pipe_prep(struct pipe_inode_info *ipipe,
 	return 0;
 }
 
-/*
- * Link contents of ipipe to opipe.
- */
-static int link_pipe(struct pipe_inode_info *ipipe,
-		     struct pipe_inode_info *opipe,
-		     size_t len, unsigned int flags)
+/**
+* Returns the nth pipe buffer after the current one.
+*
+* @i the buffer index, relative to the current one
+*/
+static inline struct pipe_buffer *
+pipe_buffer_at(struct pipe_inode_info *pipe, unsigned i)
 {
-	struct pipe_buffer *ibuf, *obuf;
-	int ret, i = 0, nbuf;
+	BUG_ON(i >= PIPE_BUFFERS);
 
-	ret = link_pipe_prep(ipipe, opipe, flags);
-	if (ret < 0)
-		return ret;
+	return pipe->bufs + ((pipe->curbuf + i) & (PIPE_BUFFERS - 1));
+}
 
-	/* pipes are now locked */
+/**
+ * do_link_pipe - copy or move (splice) contents of ipipe to opipe.
+ * @ipipe: the input pipe
+ * @opipe: the output pipe
+ * @len: the maximum number of byte to copy/move
+ * @flags: splice modifier flags
+ * @move: indicates move operation (otherwise copy)
+ *
+ * expects both pipes to be locked
+ */
+static long do_link_pipe(struct pipe_inode_info *ipipe,
+			struct pipe_inode_info *opipe,
+			size_t len, unsigned int flags, int move)
+{
+	struct pipe_buffer *ibuf, *obuf;
+	long ret = 0;
+	int i = 0;
 
 	do {
 		if (!opipe->readers) {
@@ -1670,16 +1765,8 @@ static int link_pipe(struct pipe_inode_info *ipipe,
 		if (i >= ipipe->nrbufs || opipe->nrbufs >= PIPE_BUFFERS)
 			break;
 
-		ibuf = ipipe->bufs + ((ipipe->curbuf + i) & (PIPE_BUFFERS - 1));
-		nbuf = (opipe->curbuf + opipe->nrbufs) & (PIPE_BUFFERS - 1);
-
-		/*
-		 * Get a reference to this pipe buffer,
-		 * so we can copy the contents over.
-		 */
-		ibuf->ops->get(ipipe, ibuf);
-
-		obuf = opipe->bufs + nbuf;
+		ibuf = pipe_buffer_at(ipipe, i);
+		obuf = pipe_buffer_at(opipe, opipe->nrbufs);
 		*obuf = *ibuf;
 
 		/*
@@ -1688,13 +1775,35 @@ static int link_pipe(struct pipe_inode_info *ipipe,
 		 */
 		obuf->flags &= ~PIPE_BUF_FLAG_GIFT;
 
-		if (obuf->len > len)
+		/* increase the reference count */
+		obuf->ops->get(opipe, obuf);
+
+		/* partial or complete copy/move ? */
+		if (obuf->len > len) {
 			obuf->len = len;
+			if (move) {
+				/* remove portion from ibuf */
+				ibuf->offset += len;
+				ibuf->len -= len;
+			}
+		} else {
+			if (move) {
+				/* remove entirely from ibuf */
+				ibuf->ops->release(ipipe, ibuf);
+				ibuf->ops = NULL;
+
+				ipipe->curbuf = (ipipe->curbuf + 1) &
+					(PIPE_BUFFERS - 1);
+				ipipe->nrbufs--;
+			} else {
+				/* advance pointer in ibuf */
+				i++;
+			}
+		}
 
 		opipe->nrbufs++;
 		ret += obuf->len;
 		len -= obuf->len;
-		i++;
 	} while (len);
 
 	/*
@@ -1704,6 +1813,26 @@ static int link_pipe(struct pipe_inode_info *ipipe,
 	if (!ret && ipipe->waiting_writers && (flags & SPLICE_F_NONBLOCK))
 		ret = -EAGAIN;
 
+	return ret;
+}
+
+/*
+ * Link contents of ipipe to opipe.
+ */
+long link_pipe(struct pipe_inode_info *ipipe,
+	       struct pipe_inode_info *opipe,
+	       size_t len, unsigned int flags)
+{
+	long ret;
+
+	ret = link_pipe_prep(ipipe, opipe, flags);
+	if (ret < 0)
+		return ret;
+
+	/* pipes are now locked */
+
+	ret = do_link_pipe(ipipe, opipe, len, flags, 0);
+
 	pipe_unlock(ipipe);
 	pipe_unlock(opipe);
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
