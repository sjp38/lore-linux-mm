Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1776B01F7
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 12:17:31 -0400 (EDT)
Message-Id: <20100428161719.653316888@szeredi.hu>
References: <20100428161636.272097923@szeredi.hu>
Date: Wed, 28 Apr 2010 18:16:41 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [RFC PATCH 5/6] fuse: support splice() writing to fuse device
Content-Disposition: inline; filename=fuse-dev-support-splice.patch
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Allow userspace filesystem implementation to use splice() to write to
the fuse device.  The semantics of using splice() are:

 1) buffer the message header and data in a temporary pipe
 2) with a *single* splice() call move the message from the temporary pipe
    to the fuse device

The READ reply message has the most interesting use for this, since
now the data from an arbitrary file descriptor (which could be a
regular file, a block device or a socket) can be tranferred into the
fuse device without having to go through a userspace buffer.  It will
also allow zero copy moving of pages.

One caveat is that the protocol on the fuse device requires the length
of the whole message to be written into the header.  But the length of
the data transferred into the temporary pipe may not be known in
advance.  The current library implementation works around this by
using vmplice to write the header and modifying the header after
splicing the data into the pipe (error handling omitted):

	struct fuse_out_header out;

	iov.iov_base = &out;
	iov.iov_len = sizeof(struct fuse_out_header);
	vmsplice(pip[1], &iov, 1, 0);
	len = splice(input_fd, input_offset, pip[1], NULL, len, 0);
	/* retrospectively modify the header: */
	out.len = len + sizeof(struct fuse_out_header);
	splice(pip[0], NULL, fuse_chan_fd(req->ch), NULL, out.len, flags);

This works since vmsplice only saves a pointer to the data, it does
not copy the data itself.

Since pipes are currently limited to 16 pages and messages need to be
spliced atomically, the length of the data is limited to 15 pages (or
60kB for 4k pages).

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dev.c        |  169 +++++++++++++++++++++++++++++++++++++++++----------
 include/linux/fuse.h |    5 +
 2 files changed, 142 insertions(+), 32 deletions(-)

Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2010-04-23 16:16:56.000000000 +0200
+++ linux-2.6/fs/fuse/dev.c	2010-04-23 16:17:00.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/slab.h>
+#include <linux/pipe_fs_i.h>
 
 MODULE_ALIAS_MISCDEV(FUSE_MINOR);
 
@@ -498,6 +499,9 @@ struct fuse_copy_state {
 	int write;
 	struct fuse_req *req;
 	const struct iovec *iov;
+	struct pipe_buffer *pipebufs;
+	struct pipe_buffer *currbuf;
+	struct pipe_inode_info *pipe;
 	unsigned long nr_segs;
 	unsigned long seglen;
 	unsigned long addr;
@@ -522,7 +526,14 @@ static void fuse_copy_init(struct fuse_c
 /* Unmap and put previous page of userspace buffer */
 static void fuse_copy_finish(struct fuse_copy_state *cs)
 {
-	if (cs->mapaddr) {
+	if (cs->currbuf) {
+		struct pipe_buffer *buf = cs->currbuf;
+
+		buf->ops->unmap(cs->pipe, buf, cs->mapaddr);
+
+		cs->currbuf = NULL;
+		cs->mapaddr = NULL;
+	} else if (cs->mapaddr) {
 		kunmap_atomic(cs->mapaddr, KM_USER0);
 		if (cs->write) {
 			flush_dcache_page(cs->pg);
@@ -544,23 +555,39 @@ static int fuse_copy_fill(struct fuse_co
 
 	unlock_request(cs->fc, cs->req);
 	fuse_copy_finish(cs);
-	if (!cs->seglen) {
+	if (cs->pipebufs) {
+		struct pipe_buffer *buf = cs->pipebufs;
+
+		err = buf->ops->confirm(cs->pipe, buf);
+		if (err)
+			return err;
+
 		BUG_ON(!cs->nr_segs);
-		cs->seglen = cs->iov[0].iov_len;
-		cs->addr = (unsigned long) cs->iov[0].iov_base;
-		cs->iov++;
+		cs->currbuf = buf;
+		cs->mapaddr = buf->ops->map(cs->pipe, buf, 1);
+		cs->len = buf->len;
+		cs->buf = cs->mapaddr + buf->offset;
+		cs->pipebufs++;
 		cs->nr_segs--;
+	} else {
+		if (!cs->seglen) {
+			BUG_ON(!cs->nr_segs);
+			cs->seglen = cs->iov[0].iov_len;
+			cs->addr = (unsigned long) cs->iov[0].iov_base;
+			cs->iov++;
+			cs->nr_segs--;
+		}
+		err = get_user_pages_fast(cs->addr, 1, cs->write, &cs->pg);
+		if (err < 0)
+			return err;
+		BUG_ON(err != 1);
+		offset = cs->addr % PAGE_SIZE;
+		cs->mapaddr = kmap_atomic(cs->pg, KM_USER0);
+		cs->buf = cs->mapaddr + offset;
+		cs->len = min(PAGE_SIZE - offset, cs->seglen);
+		cs->seglen -= cs->len;
+		cs->addr += cs->len;
 	}
-	err = get_user_pages_fast(cs->addr, 1, cs->write, &cs->pg);
-	if (err < 0)
-		return err;
-	BUG_ON(err != 1);
-	offset = cs->addr % PAGE_SIZE;
-	cs->mapaddr = kmap_atomic(cs->pg, KM_USER0);
-	cs->buf = cs->mapaddr + offset;
-	cs->len = min(PAGE_SIZE - offset, cs->seglen);
-	cs->seglen -= cs->len;
-	cs->addr += cs->len;
 
 	return lock_request(cs->fc, cs->req);
 }
@@ -984,23 +1011,17 @@ static int copy_out_args(struct fuse_cop
  * it from the list and copy the rest of the buffer to the request.
  * The request is finished by calling request_end()
  */
-static ssize_t fuse_dev_write(struct kiocb *iocb, const struct iovec *iov,
-			       unsigned long nr_segs, loff_t pos)
+static ssize_t fuse_dev_do_write(struct fuse_conn *fc,
+				 struct fuse_copy_state *cs, size_t nbytes)
 {
 	int err;
-	size_t nbytes = iov_length(iov, nr_segs);
 	struct fuse_req *req;
 	struct fuse_out_header oh;
-	struct fuse_copy_state cs;
-	struct fuse_conn *fc = fuse_get_conn(iocb->ki_filp);
-	if (!fc)
-		return -EPERM;
 
-	fuse_copy_init(&cs, fc, 0, NULL, iov, nr_segs);
 	if (nbytes < sizeof(struct fuse_out_header))
 		return -EINVAL;
 
-	err = fuse_copy_one(&cs, &oh, sizeof(oh));
+	err = fuse_copy_one(cs, &oh, sizeof(oh));
 	if (err)
 		goto err_finish;
 
@@ -1013,7 +1034,7 @@ static ssize_t fuse_dev_write(struct kio
 	 * and error contains notification code.
 	 */
 	if (!oh.unique) {
-		err = fuse_notify(fc, oh.error, nbytes - sizeof(oh), &cs);
+		err = fuse_notify(fc, oh.error, nbytes - sizeof(oh), cs);
 		return err ? err : nbytes;
 	}
 
@@ -1032,7 +1053,7 @@ static ssize_t fuse_dev_write(struct kio
 
 	if (req->aborted) {
 		spin_unlock(&fc->lock);
-		fuse_copy_finish(&cs);
+		fuse_copy_finish(cs);
 		spin_lock(&fc->lock);
 		request_end(fc, req);
 		return -ENOENT;
@@ -1049,7 +1070,7 @@ static ssize_t fuse_dev_write(struct kio
 			queue_interrupt(fc, req);
 
 		spin_unlock(&fc->lock);
-		fuse_copy_finish(&cs);
+		fuse_copy_finish(cs);
 		return nbytes;
 	}
 
@@ -1057,11 +1078,11 @@ static ssize_t fuse_dev_write(struct kio
 	list_move(&req->list, &fc->io);
 	req->out.h = oh;
 	req->locked = 1;
-	cs.req = req;
+	cs->req = req;
 	spin_unlock(&fc->lock);
 
-	err = copy_out_args(&cs, &req->out, nbytes);
-	fuse_copy_finish(&cs);
+	err = copy_out_args(cs, &req->out, nbytes);
+	fuse_copy_finish(cs);
 
 	spin_lock(&fc->lock);
 	req->locked = 0;
@@ -1077,10 +1098,95 @@ static ssize_t fuse_dev_write(struct kio
  err_unlock:
 	spin_unlock(&fc->lock);
  err_finish:
-	fuse_copy_finish(&cs);
+	fuse_copy_finish(cs);
 	return err;
 }
 
+static ssize_t fuse_dev_write(struct kiocb *iocb, const struct iovec *iov,
+			      unsigned long nr_segs, loff_t pos)
+{
+	struct fuse_copy_state cs;
+	struct fuse_conn *fc = fuse_get_conn(iocb->ki_filp);
+	if (!fc)
+		return -EPERM;
+
+	fuse_copy_init(&cs, fc, 0, NULL, iov, nr_segs);
+
+	return fuse_dev_do_write(fc, &cs, iov_length(iov, nr_segs));
+}
+
+static ssize_t fuse_dev_splice_write(struct pipe_inode_info *pipe,
+				     struct file *out, loff_t *ppos,
+				     size_t len, unsigned int flags)
+{
+	unsigned nbuf;
+	unsigned idx;
+	struct pipe_buffer bufs[PIPE_BUFFERS];
+	struct fuse_copy_state cs;
+	struct fuse_conn *fc;
+	size_t rem;
+	ssize_t ret;
+
+	fc = fuse_get_conn(out);
+	if (!fc)
+		return -EPERM;
+
+	pipe_lock(pipe);
+	nbuf = 0;
+	rem = 0;
+	for (idx = 0; idx < pipe->nrbufs && rem < len; idx++)
+		rem += pipe->bufs[(pipe->curbuf + idx) % PIPE_BUFFERS].len;
+
+	if (rem < len) {
+		pipe_unlock(pipe);
+		return -EINVAL;
+	}
+
+	rem = len;
+	while (rem) {
+		struct pipe_buffer *ibuf;
+		struct pipe_buffer *obuf;
+
+		BUG_ON(nbuf >= PIPE_BUFFERS);
+		BUG_ON(!pipe->nrbufs);
+		ibuf = &pipe->bufs[pipe->curbuf];
+		obuf = &bufs[nbuf];
+
+		if (rem >= ibuf->len) {
+			*obuf = *ibuf;
+			ibuf->ops = NULL;
+			pipe->curbuf = (pipe->curbuf + 1) % PIPE_BUFFERS;
+			pipe->nrbufs--;
+		} else {
+			ibuf->ops->get(pipe, ibuf);
+			*obuf = *ibuf;
+			obuf->flags &= ~PIPE_BUF_FLAG_GIFT;
+			obuf->len = rem;
+			ibuf->offset += obuf->len;
+			ibuf->len -= obuf->len;
+		}
+		nbuf++;
+		rem -= obuf->len;
+	}
+	pipe_unlock(pipe);
+
+	memset(&cs, 0, sizeof(struct fuse_copy_state));
+	cs.fc = fc;
+	cs.write = 0;
+	cs.pipebufs = bufs;
+	cs.nr_segs = nbuf;
+	cs.pipe = pipe;
+
+	ret = fuse_dev_do_write(fc, &cs, len);
+
+	for (idx = 0; idx < nbuf; idx++) {
+		struct pipe_buffer *buf = &bufs[idx];
+		buf->ops->release(pipe, buf);
+	}
+
+	return ret;
+}
+
 static unsigned fuse_dev_poll(struct file *file, poll_table *wait)
 {
 	unsigned mask = POLLOUT | POLLWRNORM;
@@ -1224,6 +1330,7 @@ const struct file_operations fuse_dev_op
 	.aio_read	= fuse_dev_read,
 	.write		= do_sync_write,
 	.aio_write	= fuse_dev_write,
+	.splice_write	= fuse_dev_splice_write,
 	.poll		= fuse_dev_poll,
 	.release	= fuse_dev_release,
 	.fasync		= fuse_dev_fasync,
Index: linux-2.6/include/linux/fuse.h
===================================================================
--- linux-2.6.orig/include/linux/fuse.h	2010-04-23 16:15:44.000000000 +0200
+++ linux-2.6/include/linux/fuse.h	2010-04-23 16:17:00.000000000 +0200
@@ -34,6 +34,9 @@
  * 7.13
  *  - make max number of background requests and congestion threshold
  *    tunables
+ *
+ * 7.14
+ *  - add splice support to fuse device
  */
 
 #ifndef _LINUX_FUSE_H
@@ -65,7 +68,7 @@
 #define FUSE_KERNEL_VERSION 7
 
 /** Minor version number of this interface */
-#define FUSE_KERNEL_MINOR_VERSION 13
+#define FUSE_KERNEL_MINOR_VERSION 14
 
 /** The node ID of the root inode */
 #define FUSE_ROOT_ID 1

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
