Message-Id: <20080621154726.494538562@szeredi.hu>
References: <20080621154607.154640724@szeredi.hu>
Date: Sat, 21 Jun 2008 17:46:10 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [rfc patch 3/4] splice: remove confirm from pipe_buf_operations
Content-Disposition: inline; filename=splice_remove_confirm.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

The 'confirm' operation was only used for splicing from page cache, to
wait for read on a page to finish.  But generic_file_splice_read()
already blocks on readahead reads, so it seems logical to block on the
rare and slow single page reads too.

So wait for readpage to finish inside __generic_file_splice_read() and
remove the 'confirm' method.

This also fixes short return counts when the filesystem (e.g. fuse)
invalidates the page between insertation and removal.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 drivers/block/loop.c      |    5 ---
 fs/nfsd/vfs.c             |    9 ------
 fs/pipe.c                 |   27 ------------------
 fs/splice.c               |   69 +++++-----------------------------------------
 include/linux/pipe_fs_i.h |   22 +-------------
 kernel/relay.c            |    1 
 net/core/skbuff.c         |    1 
 7 files changed, 11 insertions(+), 123 deletions(-)

Index: linux-2.6/drivers/block/loop.c
===================================================================
--- linux-2.6.orig/drivers/block/loop.c	2008-06-21 11:46:52.000000000 +0200
+++ linux-2.6/drivers/block/loop.c	2008-06-21 11:51:39.000000000 +0200
@@ -395,11 +395,6 @@ lo_splice_actor(struct pipe_inode_info *
 	struct page *page = buf->page;
 	sector_t IV;
 	size_t size;
-	int ret;
-
-	ret = buf->ops->confirm(pipe, buf);
-	if (unlikely(ret))
-		return ret;
 
 	IV = ((sector_t) page->index << (PAGE_CACHE_SHIFT - 9)) +
 							(buf->offset >> 9);
Index: linux-2.6/fs/pipe.c
===================================================================
--- linux-2.6.orig/fs/pipe.c	2008-06-21 11:46:52.000000000 +0200
+++ linux-2.6/fs/pipe.c	2008-06-21 11:47:09.000000000 +0200
@@ -223,26 +223,10 @@ void generic_pipe_buf_get(struct pipe_in
 	page_cache_get(buf->page);
 }
 
-/**
- * generic_pipe_buf_confirm - verify contents of the pipe buffer
- * @info:	the pipe that the buffer belongs to
- * @buf:	the buffer to confirm
- *
- * Description:
- *	This function does nothing, because the generic pipe code uses
- *	pages that are always good when inserted into the pipe.
- */
-int generic_pipe_buf_confirm(struct pipe_inode_info *info,
-			     struct pipe_buffer *buf)
-{
-	return 0;
-}
-
 static const struct pipe_buf_operations anon_pipe_buf_ops = {
 	.can_merge = 1,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
-	.confirm = generic_pipe_buf_confirm,
 	.release = anon_pipe_buf_release,
 	.get = generic_pipe_buf_get,
 };
@@ -281,13 +265,6 @@ pipe_read(struct kiocb *iocb, const stru
 			if (chars > total_len)
 				chars = total_len;
 
-			error = ops->confirm(pipe, buf);
-			if (error) {
-				if (!ret)
-					error = ret;
-				break;
-			}
-
 			atomic = !iov_fault_in_pages_write(iov, chars);
 redo:
 			addr = ops->map(pipe, buf, atomic);
@@ -402,10 +379,6 @@ pipe_write(struct kiocb *iocb, const str
 			int error, atomic = 1;
 			void *addr;
 
-			error = ops->confirm(pipe, buf);
-			if (error)
-				goto out;
-
 			iov_fault_in_pages_read(iov, chars);
 redo1:
 			addr = ops->map(pipe, buf, atomic);
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2008-06-21 11:46:52.000000000 +0200
+++ linux-2.6/fs/splice.c	2008-06-21 11:49:52.000000000 +0200
@@ -37,53 +37,10 @@ static void page_cache_pipe_buf_release(
 	buf->flags &= ~PIPE_BUF_FLAG_LRU;
 }
 
-/*
- * Check whether the contents of buf is OK to access. Since the content
- * is a page cache page, IO may be in flight.
- */
-static int page_cache_pipe_buf_confirm(struct pipe_inode_info *pipe,
-				       struct pipe_buffer *buf)
-{
-	struct page *page = buf->page;
-	int err;
-
-	if (!PageUptodate(page)) {
-		lock_page(page);
-
-		/*
-		 * Page got truncated/unhashed. This will cause a 0-byte
-		 * splice, if this is the first page.
-		 */
-		if (!page->mapping) {
-			err = -ENODATA;
-			goto error;
-		}
-
-		/*
-		 * Uh oh, read-error from disk.
-		 */
-		if (!PageUptodate(page)) {
-			err = -EIO;
-			goto error;
-		}
-
-		/*
-		 * Page is ok afterall, we are done.
-		 */
-		unlock_page(page);
-	}
-
-	return 0;
-error:
-	unlock_page(page);
-	return err;
-}
-
 static const struct pipe_buf_operations page_cache_pipe_buf_ops = {
 	.can_merge = 0,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
-	.confirm = page_cache_pipe_buf_confirm,
 	.release = page_cache_pipe_buf_release,
 	.get = generic_pipe_buf_get,
 };
@@ -92,7 +49,6 @@ static const struct pipe_buf_operations 
 	.can_merge = 0,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
-	.confirm = generic_pipe_buf_confirm,
 	.release = page_cache_pipe_buf_release,
 	.get = generic_pipe_buf_get,
 };
@@ -349,6 +305,11 @@ __generic_file_splice_read(struct file *
 
 				break;
 			}
+			wait_on_page_locked(page);
+			if (!PageUptodate(page)) {
+				error = -EIO;
+				break;
+			}
 		}
 fill_it:
 		/*
@@ -451,13 +412,10 @@ static int pipe_to_sendpage(struct pipe_
 	loff_t pos = sd->pos;
 	int ret, more;
 
-	ret = buf->ops->confirm(pipe, buf);
-	if (!ret) {
-		more = (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
+	more = (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
 
-		ret = file->f_op->sendpage(file, buf->page, buf->offset,
-					   sd->len, &pos, more);
-	}
+	ret = file->f_op->sendpage(file, buf->page, buf->offset,
+				   sd->len, &pos, more);
 
 	return ret;
 }
@@ -492,13 +450,6 @@ static int pipe_to_file(struct pipe_inod
 	void *fsdata;
 	int ret;
 
-	/*
-	 * make sure the data in this buffer is uptodate
-	 */
-	ret = buf->ops->confirm(pipe, buf);
-	if (unlikely(ret))
-		return ret;
-
 	offset = sd->pos & ~PAGE_CACHE_MASK;
 
 	this_len = sd->len;
@@ -1231,10 +1182,6 @@ static int pipe_to_user(struct pipe_inod
 	char *src;
 	int ret;
 
-	ret = buf->ops->confirm(pipe, buf);
-	if (unlikely(ret))
-		return ret;
-
 	/*
 	 * See if we can use the atomic maps, by prefaulting in the
 	 * pages and doing an atomic copy
Index: linux-2.6/include/linux/pipe_fs_i.h
===================================================================
--- linux-2.6.orig/include/linux/pipe_fs_i.h	2008-06-21 11:46:52.000000000 +0200
+++ linux-2.6/include/linux/pipe_fs_i.h	2008-06-21 11:47:09.000000000 +0200
@@ -58,16 +58,8 @@ struct pipe_inode_info {
 };
 
 /*
- * Note on the nesting of these functions:
- *
- * ->confirm()
- *	->map()
- *	...
- *	->unmap()
- *
- * That is, ->map() must be called on a confirmed buffer. See below
- * for the meaning of each operation. Also see kerneldoc in fs/pipe.c
- * for the pipe and generic variants of these hooks.
+ * Also see kerneldoc in fs/pipe.c for the pipe and generic variants
+ * of these hooks.
  */
 struct pipe_buf_operations {
 	/*
@@ -97,15 +89,6 @@ struct pipe_buf_operations {
 	void (*unmap)(struct pipe_inode_info *, struct pipe_buffer *, void *);
 
 	/*
-	 * ->confirm() verifies that the data in the pipe buffer is there
-	 * and that the contents are good. If the pages in the pipe belong
-	 * to a file system, we may need to wait for IO completion in this
-	 * hook. Returns 0 for good, or a negative error value in case of
-	 * error.
-	 */
-	int (*confirm)(struct pipe_inode_info *, struct pipe_buffer *);
-
-	/*
 	 * When the contents of this pipe buffer has been completely
 	 * consumed by a reader, ->release() is called.
 	 */
@@ -132,6 +115,5 @@ void __free_pipe_info(struct pipe_inode_
 void *generic_pipe_buf_map(struct pipe_inode_info *, struct pipe_buffer *, int);
 void generic_pipe_buf_unmap(struct pipe_inode_info *, struct pipe_buffer *, void *);
 void generic_pipe_buf_get(struct pipe_inode_info *, struct pipe_buffer *);
-int generic_pipe_buf_confirm(struct pipe_inode_info *, struct pipe_buffer *);
 
 #endif
Index: linux-2.6/kernel/relay.c
===================================================================
--- linux-2.6.orig/kernel/relay.c	2008-06-21 11:47:05.000000000 +0200
+++ linux-2.6/kernel/relay.c	2008-06-21 11:47:09.000000000 +0200
@@ -1079,7 +1079,6 @@ static struct pipe_buf_operations relay_
 	.can_merge = 0,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
-	.confirm = generic_pipe_buf_confirm,
 	.release = relay_pipe_buf_release,
 	.get = generic_pipe_buf_get,
 };
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2008-06-21 11:46:52.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2008-06-21 11:47:09.000000000 +0200
@@ -93,7 +93,6 @@ static struct pipe_buf_operations sock_p
 	.can_merge = 0,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
-	.confirm = generic_pipe_buf_confirm,
 	.release = sock_pipe_buf_release,
 	.get = sock_pipe_buf_get,
 };
Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c	2008-06-19 14:58:10.000000000 +0200
+++ linux-2.6/fs/nfsd/vfs.c	2008-06-21 11:50:57.000000000 +0200
@@ -839,14 +839,7 @@ nfsd_splice_actor(struct pipe_inode_info
 	struct svc_rqst *rqstp = sd->u.data;
 	struct page **pp = rqstp->rq_respages + rqstp->rq_resused;
 	struct page *page = buf->page;
-	size_t size;
-	int ret;
-
-	ret = buf->ops->confirm(pipe, buf);
-	if (unlikely(ret))
-		return ret;
-
-	size = sd->len;
+	size_t size = sd->len;
 
 	if (rqstp->rq_res.page_len == 0) {
 		get_page(page);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
