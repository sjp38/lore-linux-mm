Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 95FD26B01BD
	for <linux-mm@kvack.org>; Thu, 20 May 2010 07:17:26 -0400 (EDT)
Subject: [RFC PATCH] fuse: support splice() reading from fuse device
Message-Id: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 20 May 2010 13:17:18 +0200
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This continues zero copy I/O support on the fuse interface.  The first
part of the patchset (splice write support on fuse device) was posted
here:

  http://lkml.org/lkml/2010/4/28/215

With Jens' pipe growing patch and additional fuse patches it was
possible to achieve a 20GBytes/s write throghput on my laptop in a
"null" filesystem (no page cache, data goes to /dev/null).

Thanks,
Miklos

----
From: Miklos Szeredi <mszeredi@suse.cz>

Allow userspace filesystem implementation to use splice() to read from
the fuse device.

The filesystem can now transfer data coming from a WRITE request to an
arbitrary file descriptor (regular file, block device or socket)
without having to go through a userspace buffer.

The semantics of using splice() to read messages are:

 1)  with a single splice()  move the whole message from the fuse
     device to a temporary pipe
 2)  read the header from the pipe and determine the message type
 3a) if message is a WRITE then splice data from pipe to destination
 3b) else read the rest of the message

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dev.c |  223 +++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 182 insertions(+), 41 deletions(-)

Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2010-05-13 10:54:19.000000000 +0200
+++ linux-2.6/fs/fuse/dev.c	2010-05-13 18:01:45.000000000 +0200
@@ -515,13 +515,12 @@ struct fuse_copy_state {
 };
 
 static void fuse_copy_init(struct fuse_copy_state *cs, struct fuse_conn *fc,
-			   int write, struct fuse_req *req,
+			   int write,
 			   const struct iovec *iov, unsigned long nr_segs)
 {
 	memset(cs, 0, sizeof(*cs));
 	cs->fc = fc;
 	cs->write = write;
-	cs->req = req;
 	cs->iov = iov;
 	cs->nr_segs = nr_segs;
 }
@@ -532,8 +531,12 @@ static void fuse_copy_finish(struct fuse
 	if (cs->currbuf) {
 		struct pipe_buffer *buf = cs->currbuf;
 
-		buf->ops->unmap(cs->pipe, buf, cs->mapaddr);
-
+		if (!cs->write) {
+			buf->ops->unmap(cs->pipe, buf, cs->mapaddr);
+		} else {
+			kunmap_atomic(cs->mapaddr, KM_USER0);
+			buf->len = PAGE_SIZE - cs->len;
+		}
 		cs->currbuf = NULL;
 		cs->mapaddr = NULL;
 	} else if (cs->mapaddr) {
@@ -561,17 +564,39 @@ static int fuse_copy_fill(struct fuse_co
 	if (cs->pipebufs) {
 		struct pipe_buffer *buf = cs->pipebufs;
 
-		err = buf->ops->confirm(cs->pipe, buf);
-		if (err)
-			return err;
+		if (!cs->write) {
+			err = buf->ops->confirm(cs->pipe, buf);
+			if (err)
+				return err;
+
+			BUG_ON(!cs->nr_segs);
+			cs->currbuf = buf;
+			cs->mapaddr = buf->ops->map(cs->pipe, buf, 1);
+			cs->len = buf->len;
+			cs->buf = cs->mapaddr + buf->offset;
+			cs->pipebufs++;
+			cs->nr_segs--;
+		} else {
+			struct page *page;
+
+			if (cs->nr_segs == PIPE_BUFFERS)
+				return -EIO;
 
-		BUG_ON(!cs->nr_segs);
-		cs->currbuf = buf;
-		cs->mapaddr = buf->ops->map(cs->pipe, buf, 1);
-		cs->len = buf->len;
-		cs->buf = cs->mapaddr + buf->offset;
-		cs->pipebufs++;
-		cs->nr_segs--;
+			page = alloc_page(GFP_HIGHUSER);
+			if (!page)
+				return -ENOMEM;
+
+			buf->page = page;
+			buf->offset = 0;
+			buf->len = 0;
+
+			cs->currbuf = buf;
+			cs->mapaddr = kmap_atomic(page, KM_USER0);
+			cs->buf = cs->mapaddr;
+			cs->len = PAGE_SIZE;
+			cs->pipebufs++;
+			cs->nr_segs++;
+		}
 	} else {
 		if (!cs->seglen) {
 			BUG_ON(!cs->nr_segs);
@@ -731,6 +756,30 @@ out_fallback:
 	return 1;
 }
 
+static int fuse_ref_page(struct fuse_copy_state *cs, struct page *page,
+			 unsigned offset, unsigned count)
+{
+	struct pipe_buffer *buf;
+
+	if (cs->nr_segs == PIPE_BUFFERS)
+		return -EIO;
+
+	unlock_request(cs->fc, cs->req);
+	fuse_copy_finish(cs);
+
+	buf = cs->pipebufs;
+	page_cache_get(page);
+	buf->page = page;
+	buf->offset = offset;
+	buf->len = count;
+
+	cs->pipebufs++;
+	cs->nr_segs++;
+	cs->len = 0;
+
+	return 0;
+}
+
 /*
  * Copy a page in the request to/from the userspace buffer.  Must be
  * done atomically
@@ -747,7 +796,9 @@ static int fuse_copy_page(struct fuse_co
 		kunmap_atomic(mapaddr, KM_USER1);
 	}
 	while (count) {
-		if (!cs->len) {
+		if (cs->write && cs->pipebufs && page) {
+			return fuse_ref_page(cs, page, offset, count);
+		} else if (!cs->len) {
 			if (cs->move_pages && page &&
 			    offset == 0 && count == PAGE_SIZE) {
 				err = fuse_try_move_page(cs, pagep);
@@ -862,11 +913,10 @@ __acquires(&fc->lock)
  *
  * Called with fc->lock held, releases it
  */
-static int fuse_read_interrupt(struct fuse_conn *fc, struct fuse_req *req,
-			       const struct iovec *iov, unsigned long nr_segs)
+static int fuse_read_interrupt(struct fuse_conn *fc, struct fuse_copy_state *cs,
+			       size_t nbytes, struct fuse_req *req)
 __releases(&fc->lock)
 {
-	struct fuse_copy_state cs;
 	struct fuse_in_header ih;
 	struct fuse_interrupt_in arg;
 	unsigned reqsize = sizeof(ih) + sizeof(arg);
@@ -882,14 +932,13 @@ __releases(&fc->lock)
 	arg.unique = req->in.h.unique;
 
 	spin_unlock(&fc->lock);
-	if (iov_length(iov, nr_segs) < reqsize)
+	if (nbytes < reqsize)
 		return -EINVAL;
 
-	fuse_copy_init(&cs, fc, 1, NULL, iov, nr_segs);
-	err = fuse_copy_one(&cs, &ih, sizeof(ih));
+	err = fuse_copy_one(cs, &ih, sizeof(ih));
 	if (!err)
-		err = fuse_copy_one(&cs, &arg, sizeof(arg));
-	fuse_copy_finish(&cs);
+		err = fuse_copy_one(cs, &arg, sizeof(arg));
+	fuse_copy_finish(cs);
 
 	return err ? err : reqsize;
 }
@@ -903,18 +952,13 @@ __releases(&fc->lock)
  * request_end().  Otherwise add it to the processing list, and set
  * the 'sent' flag.
  */
-static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
-			      unsigned long nr_segs, loff_t pos)
+static ssize_t fuse_dev_do_read(struct fuse_conn *fc, struct file *file,
+				struct fuse_copy_state *cs, size_t nbytes)
 {
 	int err;
 	struct fuse_req *req;
 	struct fuse_in *in;
-	struct fuse_copy_state cs;
 	unsigned reqsize;
-	struct file *file = iocb->ki_filp;
-	struct fuse_conn *fc = fuse_get_conn(file);
-	if (!fc)
-		return -EPERM;
 
  restart:
 	spin_lock(&fc->lock);
@@ -934,7 +978,7 @@ static ssize_t fuse_dev_read(struct kioc
 	if (!list_empty(&fc->interrupts)) {
 		req = list_entry(fc->interrupts.next, struct fuse_req,
 				 intr_entry);
-		return fuse_read_interrupt(fc, req, iov, nr_segs);
+		return fuse_read_interrupt(fc, cs, nbytes, req);
 	}
 
 	req = list_entry(fc->pending.next, struct fuse_req, list);
@@ -944,7 +988,7 @@ static ssize_t fuse_dev_read(struct kioc
 	in = &req->in;
 	reqsize = in->h.len;
 	/* If request is too large, reply with an error and restart the read */
-	if (iov_length(iov, nr_segs) < reqsize) {
+	if (nbytes < reqsize) {
 		req->out.h.error = -EIO;
 		/* SETXATTR is special, since it may contain too large data */
 		if (in->h.opcode == FUSE_SETXATTR)
@@ -953,12 +997,12 @@ static ssize_t fuse_dev_read(struct kioc
 		goto restart;
 	}
 	spin_unlock(&fc->lock);
-	fuse_copy_init(&cs, fc, 1, req, iov, nr_segs);
-	err = fuse_copy_one(&cs, &in->h, sizeof(in->h));
+	cs->req = req;
+	err = fuse_copy_one(cs, &in->h, sizeof(in->h));
 	if (!err)
-		err = fuse_copy_args(&cs, in->numargs, in->argpages,
+		err = fuse_copy_args(cs, in->numargs, in->argpages,
 				     (struct fuse_arg *) in->args, 0);
-	fuse_copy_finish(&cs);
+	fuse_copy_finish(cs);
 	spin_lock(&fc->lock);
 	req->locked = 0;
 	if (req->aborted) {
@@ -986,6 +1030,105 @@ static ssize_t fuse_dev_read(struct kioc
 	return err;
 }
 
+static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
+			      unsigned long nr_segs, loff_t pos)
+{
+	struct fuse_copy_state cs;
+	struct file *file = iocb->ki_filp;
+	struct fuse_conn *fc = fuse_get_conn(file);
+	if (!fc)
+		return -EPERM;
+
+	fuse_copy_init(&cs, fc, 1, iov, nr_segs);
+
+	return fuse_dev_do_read(fc, file, &cs, iov_length(iov, nr_segs));
+}
+
+static int fuse_dev_pipe_buf_steal(struct pipe_inode_info *pipe,
+				   struct pipe_buffer *buf)
+{
+	return 1;
+}
+
+static const struct pipe_buf_operations fuse_dev_pipe_buf_ops = {
+	.can_merge = 0,
+	.map = generic_pipe_buf_map,
+	.unmap = generic_pipe_buf_unmap,
+	.confirm = generic_pipe_buf_confirm,
+	.release = generic_pipe_buf_release,
+	.steal = fuse_dev_pipe_buf_steal,
+	.get = generic_pipe_buf_get,
+};
+
+static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
+				    struct pipe_inode_info *pipe,
+				    size_t len, unsigned int flags)
+{
+	int ret;
+	int page_nr = 0;
+	int do_wakeup = 0;
+	struct pipe_buffer bufs[PIPE_BUFFERS];
+	struct fuse_copy_state cs;
+	struct fuse_conn *fc = fuse_get_conn(in);
+	if (!fc)
+		return -EPERM;
+
+	fuse_copy_init(&cs, fc, 1, NULL, 0);
+	cs.pipebufs = bufs;
+	cs.pipe = pipe;
+	ret = fuse_dev_do_read(fc, in, &cs, len);
+	if (ret < 0)
+		goto out;
+
+	ret = 0;
+	pipe_lock(pipe);
+
+	if (!pipe->readers) {
+		send_sig(SIGPIPE, current, 0);
+		if (!ret)
+			ret = -EPIPE;
+		goto out_unlock;
+	}
+
+	if (pipe->nrbufs + cs.nr_segs > PIPE_BUFFERS) {
+		ret = -EIO;
+		goto out_unlock;
+	}
+
+	while (page_nr < cs.nr_segs) {
+		int newbuf = (pipe->curbuf + pipe->nrbufs) % PIPE_BUFFERS;
+		struct pipe_buffer *buf = pipe->bufs + newbuf;
+
+		buf->page = bufs[page_nr].page;
+		buf->offset = bufs[page_nr].offset;
+		buf->len = bufs[page_nr].len;
+		buf->ops = &fuse_dev_pipe_buf_ops;
+
+		pipe->nrbufs++;
+		page_nr++;
+		ret += buf->len;
+
+		if (pipe->inode)
+			do_wakeup = 1;
+	}
+
+out_unlock:
+	pipe_unlock(pipe);
+
+	if (do_wakeup) {
+		smp_mb();
+		if (waitqueue_active(&pipe->wait))
+			wake_up_interruptible(&pipe->wait);
+		kill_fasync(&pipe->fasync_readers, SIGIO, POLL_IN);
+	}
+
+out:
+	for (; page_nr < cs.nr_segs; page_nr++)
+		page_cache_release(bufs[page_nr].page);
+
+	return ret;
+}
+
 static int fuse_notify_poll(struct fuse_conn *fc, unsigned int size,
 			    struct fuse_copy_state *cs)
 {
@@ -1246,7 +1389,7 @@ static ssize_t fuse_dev_write(struct kio
 	if (!fc)
 		return -EPERM;
 
-	fuse_copy_init(&cs, fc, 0, NULL, iov, nr_segs);
+	fuse_copy_init(&cs, fc, 0, iov, nr_segs);
 
 	return fuse_dev_do_write(fc, &cs, iov_length(iov, nr_segs));
 }
@@ -1306,11 +1449,8 @@ static ssize_t fuse_dev_splice_write(str
 	}
 	pipe_unlock(pipe);
 
-	memset(&cs, 0, sizeof(struct fuse_copy_state));
-	cs.fc = fc;
-	cs.write = 0;
+	fuse_copy_init(&cs, fc, 0, NULL, nbuf);
 	cs.pipebufs = bufs;
-	cs.nr_segs = nbuf;
 	cs.pipe = pipe;
 
 	if (flags & SPLICE_F_MOVE)
@@ -1467,6 +1607,7 @@ const struct file_operations fuse_dev_op
 	.llseek		= no_llseek,
 	.read		= do_sync_read,
 	.aio_read	= fuse_dev_read,
+	.splice_read	= fuse_dev_splice_read,
 	.write		= do_sync_write,
 	.aio_write	= fuse_dev_write,
 	.splice_write	= fuse_dev_splice_write,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
