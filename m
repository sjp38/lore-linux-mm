Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 811046B00C3
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:52 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 45/80] splice: export pipe/file-to-pipe/file functionality
Date: Wed, 23 Sep 2009 19:51:25 -0400
Message-Id: <1253749920-18673-46-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

During pipes c/r pipes we need to save and restore pipe buffers. But
do_splice() requires two file descriptors, therefore we can't use it,
as we always have one file descriptor (checkpoint image) and one
pipe_inode_info.

This patch exports interfaces that work at the pipe_inode_info level,
namely link_pipe(), do_splice_to() and do_splice_from(). They are used
in the following patch to to save and restore pipe buffers without
unnecessary data copy.

It slightly modifies both do_splice_to() and do_splice_from() to
detect the case of pipe-to-pipe transfer, in which case they invoke
splice_pipe_to_pipe() directly.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 fs/splice.c            |   61 ++++++++++++++++++++++++++++++++---------------
 include/linux/splice.h |    9 +++++++
 2 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 73766d2..f251b4c 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1055,18 +1055,43 @@ ssize_t generic_splice_sendpage(struct pipe_inode_info *pipe, struct file *out,
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
+static int splice_pipe_to_pipe(struct pipe_inode_info *ipipe,
+			       struct pipe_inode_info *opipe,
+			       size_t len, unsigned int flags);
+
+/*
  * Attempt to initiate a splice from pipe to file.
  */
-static long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
-			   loff_t *ppos, size_t len, unsigned int flags)
+long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
+		    loff_t *ppos, size_t len, unsigned int flags)
 {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *,
 				loff_t *, size_t, unsigned int);
+	struct pipe_inode_info *opipe;
 	int ret;
 
 	if (unlikely(!(out->f_mode & FMODE_WRITE)))
 		return -EBADF;
 
+	/* When called directly (e.g. from c/r) output may be a pipe */
+	opipe = pipe_info(out->f_path.dentry->d_inode);
+	if (opipe) {
+		BUG_ON(opipe == pipe);
+		return splice_pipe_to_pipe(pipe, opipe, len, flags);
+	}
+
 	if (unlikely(out->f_flags & O_APPEND))
 		return -EINVAL;
 
@@ -1084,17 +1109,25 @@ static long do_splice_from(struct pipe_inode_info *pipe, struct file *out,
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
 	ssize_t (*splice_read)(struct file *, loff_t *,
 			       struct pipe_inode_info *, size_t, unsigned int);
+	struct pipe_inode_info *ipipe;
 	int ret;
 
 	if (unlikely(!(in->f_mode & FMODE_READ)))
 		return -EBADF;
 
+	/* When called firectly (e.g. from c/r) input may be a pipe */
+	ipipe = pipe_info(in->f_path.dentry->d_inode);
+	if (ipipe) {
+		BUG_ON(ipipe == pipe);
+		return splice_pipe_to_pipe(ipipe, pipe, len, flags);
+	}
+
 	ret = rw_verify_area(READ, in, ppos, len);
 	if (unlikely(ret < 0))
 		return ret;
@@ -1273,18 +1306,6 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 static int splice_pipe_to_pipe(struct pipe_inode_info *ipipe,
 			       struct pipe_inode_info *opipe,
 			       size_t len, unsigned int flags);
-/*
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
 
 /*
  * Determine where to splice to/from.
@@ -1887,9 +1908,9 @@ retry:
 /*
  * Link contents of ipipe to opipe.
  */
-static int link_pipe(struct pipe_inode_info *ipipe,
-		     struct pipe_inode_info *opipe,
-		     size_t len, unsigned int flags)
+int link_pipe(struct pipe_inode_info *ipipe,
+	      struct pipe_inode_info *opipe,
+	      size_t len, unsigned int flags)
 {
 	struct pipe_buffer *ibuf, *obuf;
 	int ret = 0, i = 0, nbuf;
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 18e7c7c..431662c 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -82,4 +82,13 @@ extern ssize_t splice_to_pipe(struct pipe_inode_info *,
 extern ssize_t splice_direct_to_actor(struct file *, struct splice_desc *,
 				      splice_direct_actor *);
 
+extern int link_pipe(struct pipe_inode_info *ipipe,
+		     struct pipe_inode_info *opipe,
+		     size_t len, unsigned int flags);
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
