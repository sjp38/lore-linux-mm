Message-Id: <20080621154724.203822363@szeredi.hu>
References: <20080621154607.154640724@szeredi.hu>
Date: Sat, 21 Jun 2008 17:46:09 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [rfc patch 2/4] splice: remove steal from pipe_buf_operations
Content-Disposition: inline; filename=splice_remove_steal.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

The 'steal' operation hasn't been used for some time.  Remove it and
the associated dead code.  If it's needed in the future, it can always
be easily restored.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/pipe.c                 |   31 -----------------------
 fs/splice.c               |   62 ----------------------------------------------
 include/linux/pipe_fs_i.h |   20 ++------------
 kernel/relay.c            |    1 
 net/core/skbuff.c         |    8 -----
 5 files changed, 3 insertions(+), 119 deletions(-)

Index: linux-2.6/fs/pipe.c
===================================================================
--- linux-2.6.orig/fs/pipe.c	2008-06-21 10:17:43.000000000 +0200
+++ linux-2.6/fs/pipe.c	2008-06-21 11:46:52.000000000 +0200
@@ -209,36 +209,6 @@ void generic_pipe_buf_unmap(struct pipe_
 }
 
 /**
- * generic_pipe_buf_steal - attempt to take ownership of a &pipe_buffer
- * @pipe:	the pipe that the buffer belongs to
- * @buf:	the buffer to attempt to steal
- *
- * Description:
- *	This function attempts to steal the &struct page attached to
- *	@buf. If successful, this function returns 0 and returns with
- *	the page locked. The caller may then reuse the page for whatever
- *	he wishes; the typical use is insertion into a different file
- *	page cache.
- */
-int generic_pipe_buf_steal(struct pipe_inode_info *pipe,
-			   struct pipe_buffer *buf)
-{
-	struct page *page = buf->page;
-
-	/*
-	 * A reference of one is golden, that means that the owner of this
-	 * page is the only one holding a reference to it. lock the page
-	 * and return OK.
-	 */
-	if (page_count(page) == 1) {
-		lock_page(page);
-		return 0;
-	}
-
-	return 1;
-}
-
-/**
  * generic_pipe_buf_get - get a reference to a &struct pipe_buffer
  * @pipe:	the pipe that the buffer belongs to
  * @buf:	the buffer to get a reference to
@@ -274,7 +244,6 @@ static const struct pipe_buf_operations 
 	.unmap = generic_pipe_buf_unmap,
 	.confirm = generic_pipe_buf_confirm,
 	.release = anon_pipe_buf_release,
-	.steal = generic_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2008-06-21 10:19:01.000000000 +0200
+++ linux-2.6/fs/splice.c	2008-06-21 11:46:52.000000000 +0200
@@ -30,56 +30,6 @@
 #include <linux/uio.h>
 #include <linux/security.h>
 
-/*
- * Attempt to steal a page from a pipe buffer. This should perhaps go into
- * a vm helper function, it's already simplified quite a bit by the
- * addition of remove_mapping(). If success is returned, the caller may
- * attempt to reuse this page for another destination.
- */
-static int page_cache_pipe_buf_steal(struct pipe_inode_info *pipe,
-				     struct pipe_buffer *buf)
-{
-	struct page *page = buf->page;
-	struct address_space *mapping;
-
-	lock_page(page);
-
-	mapping = page_mapping(page);
-	if (mapping) {
-		WARN_ON(!PageUptodate(page));
-
-		/*
-		 * At least for ext2 with nobh option, we need to wait on
-		 * writeback completing on this page, since we'll remove it
-		 * from the pagecache.  Otherwise truncate wont wait on the
-		 * page, allowing the disk blocks to be reused by someone else
-		 * before we actually wrote our data to them. fs corruption
-		 * ensues.
-		 */
-		wait_on_page_writeback(page);
-
-		if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
-			goto out_unlock;
-
-		/*
-		 * If we succeeded in removing the mapping, set LRU flag
-		 * and return good.
-		 */
-		if (remove_mapping(mapping, page)) {
-			buf->flags |= PIPE_BUF_FLAG_LRU;
-			return 0;
-		}
-	}
-
-	/*
-	 * Raced with truncate or failed to remove page from current
-	 * address space, unlock and return failure.
-	 */
-out_unlock:
-	unlock_page(page);
-	return 1;
-}
-
 static void page_cache_pipe_buf_release(struct pipe_inode_info *pipe,
 					struct pipe_buffer *buf)
 {
@@ -135,27 +85,15 @@ static const struct pipe_buf_operations 
 	.unmap = generic_pipe_buf_unmap,
 	.confirm = page_cache_pipe_buf_confirm,
 	.release = page_cache_pipe_buf_release,
-	.steal = page_cache_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 
-static int user_page_pipe_buf_steal(struct pipe_inode_info *pipe,
-				    struct pipe_buffer *buf)
-{
-	if (!(buf->flags & PIPE_BUF_FLAG_GIFT))
-		return 1;
-
-	buf->flags |= PIPE_BUF_FLAG_LRU;
-	return generic_pipe_buf_steal(pipe, buf);
-}
-
 static const struct pipe_buf_operations user_page_pipe_buf_ops = {
 	.can_merge = 0,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
 	.confirm = generic_pipe_buf_confirm,
 	.release = page_cache_pipe_buf_release,
-	.steal = user_page_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 
Index: linux-2.6/include/linux/pipe_fs_i.h
===================================================================
--- linux-2.6.orig/include/linux/pipe_fs_i.h	2008-06-21 10:17:43.000000000 +0200
+++ linux-2.6/include/linux/pipe_fs_i.h	2008-06-21 11:46:52.000000000 +0200
@@ -61,16 +61,13 @@ struct pipe_inode_info {
  * Note on the nesting of these functions:
  *
  * ->confirm()
- *	->steal()
- *	...
  *	->map()
  *	...
  *	->unmap()
  *
- * That is, ->map() must be called on a confirmed buffer,
- * same goes for ->steal(). See below for the meaning of each
- * operation. Also see kerneldoc in fs/pipe.c for the pipe
- * and generic variants of these hooks.
+ * That is, ->map() must be called on a confirmed buffer. See below
+ * for the meaning of each operation. Also see kerneldoc in fs/pipe.c
+ * for the pipe and generic variants of these hooks.
  */
 struct pipe_buf_operations {
 	/*
@@ -115,16 +112,6 @@ struct pipe_buf_operations {
 	void (*release)(struct pipe_inode_info *, struct pipe_buffer *);
 
 	/*
-	 * Attempt to take ownership of the pipe buffer and its contents.
-	 * ->steal() returns 0 for success, in which case the contents
-	 * of the pipe (the buf->page) is locked and now completely owned
-	 * by the caller. The page may then be transferred to a different
-	 * mapping, the most often used case is insertion into different
-	 * file address space cache.
-	 */
-	int (*steal)(struct pipe_inode_info *, struct pipe_buffer *);
-
-	/*
 	 * Get a reference to the pipe buffer.
 	 */
 	void (*get)(struct pipe_inode_info *, struct pipe_buffer *);
@@ -146,6 +133,5 @@ void *generic_pipe_buf_map(struct pipe_i
 void generic_pipe_buf_unmap(struct pipe_inode_info *, struct pipe_buffer *, void *);
 void generic_pipe_buf_get(struct pipe_inode_info *, struct pipe_buffer *);
 int generic_pipe_buf_confirm(struct pipe_inode_info *, struct pipe_buffer *);
-int generic_pipe_buf_steal(struct pipe_inode_info *, struct pipe_buffer *);
 
 #endif
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2008-06-21 10:17:43.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2008-06-21 11:46:52.000000000 +0200
@@ -88,13 +88,6 @@ static void sock_pipe_buf_get(struct pip
 	skb_get(skb);
 }
 
-static int sock_pipe_buf_steal(struct pipe_inode_info *pipe,
-			       struct pipe_buffer *buf)
-{
-	return 1;
-}
-
-
 /* Pipe buffer operations for a socket. */
 static struct pipe_buf_operations sock_pipe_buf_ops = {
 	.can_merge = 0,
@@ -102,7 +95,6 @@ static struct pipe_buf_operations sock_p
 	.unmap = generic_pipe_buf_unmap,
 	.confirm = generic_pipe_buf_confirm,
 	.release = sock_pipe_buf_release,
-	.steal = sock_pipe_buf_steal,
 	.get = sock_pipe_buf_get,
 };
 
Index: linux-2.6/kernel/relay.c
===================================================================
--- linux-2.6.orig/kernel/relay.c	2008-06-21 11:46:52.000000000 +0200
+++ linux-2.6/kernel/relay.c	2008-06-21 11:47:05.000000000 +0200
@@ -1081,7 +1081,6 @@ static struct pipe_buf_operations relay_
 	.unmap = generic_pipe_buf_unmap,
 	.confirm = generic_pipe_buf_confirm,
 	.release = relay_pipe_buf_release,
-	.steal = generic_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
