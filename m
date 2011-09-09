Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 17B726B025A
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 07:01:10 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/10] nfs: enable swap on NFS
Date: Fri,  9 Sep 2011 12:00:52 +0100
Message-Id: <1315566054-17209-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1315566054-17209-1-git-send-email-mgorman@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Implement all the new swapfile a_ops for NFS. This will set the NFS
socket to SOCK_MEMALLOC and run socket reconnect under PF_MEMALLOC as
well as reset SOCK_MEMALLOC before engaging the protocol ->connect()
method.

PF_MEMALLOC should allow the allocation of struct socket and related
objects and the early (re)setting of SOCK_MEMALLOC should allow us
to receive the packets required for the TCP connection buildup.

[dfeng@redhat.com: Fix handling of multiple swap files]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/nfs/Kconfig              |    8 ++++++
 fs/nfs/file.c               |   20 +++++++++++++++
 fs/nfs/write.c              |   33 ++++++++++++++++++++++++-
 include/linux/nfs_fs.h      |    2 +
 include/linux/sunrpc/xprt.h |    3 ++
 net/sunrpc/Kconfig          |    5 ++++
 net/sunrpc/clnt.c           |    2 +
 net/sunrpc/sched.c          |    7 ++++-
 net/sunrpc/xprtsock.c       |   57 +++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 134 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index dbcd821..7c3b921 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -74,6 +74,14 @@ config NFS_V4
 
 	  If unsure, say Y.
 
+config NFS_SWAP
+	bool "Provide swap over NFS support"
+	default n
+	depends on NFS_FS
+	select SUNRPC_SWAP
+	help
+	  This option enables swapon to work on files located on NFS mounts.
+
 config NFS_V4_1
 	bool "NFS client support for NFSv4.1 (EXPERIMENTAL)"
 	depends on NFS_FS && NFS_V4 && EXPERIMENTAL
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 38c7cf4..2fdb1bd 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -536,6 +536,20 @@ static int nfs_launder_page(struct page *page)
 	return nfs_wb_page(inode, page);
 }
 
+#ifdef CONFIG_NFS_SWAP
+static int nfs_swap_activate(struct swap_info_struct *sis, struct file *file,
+						sector_t *span)
+{
+	*span = sis->pages;
+	return xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 1);
+}
+
+static void nfs_swap_deactivate(struct file *file)
+{
+	xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 0);
+}
+#endif
+
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -550,6 +564,12 @@ const struct address_space_operations nfs_file_aops = {
 	.migratepage = nfs_migrate_page,
 	.launder_page = nfs_launder_page,
 	.error_remove_page = generic_error_remove_page,
+#ifdef CONFIG_NFS_SWAP
+	.swap_activate = nfs_swap_activate,
+	.swap_deactivate = nfs_swap_deactivate,
+	.swap_writepage = nfs_swap_writepage,
+	.swap_readpage = nfs_readpage,
+#endif
 };
 
 /*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 15e3b7a..475e1f2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -369,6 +369,28 @@ int nfs_writepage(struct page *page, struct writeback_control *wbc)
 	return ret;
 }
 
+static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
+		unsigned int offset, unsigned int count);
+
+int nfs_swap_writepage(struct file *file, struct page *page,
+		 struct writeback_control *wbc)
+{
+	struct nfs_open_context *ctx = nfs_file_open_context(file);
+	int status;
+
+	status = nfs_writepage_setup(ctx, page, 0, nfs_page_length(page));
+	if (status < 0) {
+		nfs_set_pageerror(page);
+		goto out;
+	}
+
+	status = nfs_writepage_locked(page, wbc);
+
+out:
+	unlock_page(page);
+	return status;
+}
+
 static int nfs_writepages_callback(struct page *page, struct writeback_control *wbc, void *data)
 {
 	int ret;
@@ -734,7 +756,16 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	/* Update file length */
 	nfs_grow_file(page, offset, count);
 	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
-	nfs_mark_request_dirty(req);
+
+	/*
+	 * There is no need to mark swapfile requests as dirty like normal
+	 * writepage requests as page dirtying and cleaning is managed
+	 * from the mm. If a PageSwapCache page is marked dirty like this,
+	 * it will still be dirty after kswapd calls writepage and may
+	 * never be released
+	 */
+	if (!PageSwapCache(page))
+		nfs_mark_request_dirty(req);
 	nfs_clear_page_tag_locked(req);
 	return 0;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index eaac770..c7a1e01 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -513,6 +513,8 @@ extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
 extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
 extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
+extern int  nfs_swap_writepage(struct file *file, struct page *page,
+			 struct writeback_control *wbc);
 
 /*
  * Try to write back everything synchronously (but check the
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 15518a1..bc2fd1e 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -174,6 +174,8 @@ struct rpc_xprt {
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
 				resvport   : 1; /* use a reserved port */
+	unsigned int		swapper; 	/* we're swapping over this
+						   transport */
 	unsigned int		bind_index;	/* bind function index */
 
 	/*
@@ -311,6 +313,7 @@ void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
+int			xs_swapper(struct rpc_xprt *xprt, int enable);
 
 /*
  * Reserved bit positions in xprt->state
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index ffd243d..0e9d340 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -21,6 +21,11 @@ config SUNRPC_XPRT_RDMA
 
 	  If unsure, say N.
 
+config SUNRPC_SWAP
+	bool
+	depends on SUNRPC
+	select NETVM
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism"
 	depends on SUNRPC && CRYPTO
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c5347d2..63547e0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -594,6 +594,8 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 		atomic_inc(&clnt->cl_count);
 		if (clnt->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
+		if (task->tk_client->cl_xprt->swapper)
+			task->tk_flags |= RPC_TASK_SWAPPER;
 		/* Add to the client's list of all tasks */
 		spin_lock(&clnt->cl_lock);
 		list_add_tail(&task->tk_task, &clnt->cl_tasks);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d12ffa5..e116ab2 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -748,7 +748,10 @@ static void rpc_async_schedule(struct work_struct *work)
 void *rpc_malloc(struct rpc_task *task, size_t size)
 {
 	struct rpc_buffer *buf;
-	gfp_t gfp = RPC_IS_SWAPPER(task) ? GFP_ATOMIC : GFP_NOWAIT;
+	gfp_t gfp = GFP_NOWAIT;
+
+	if (RPC_IS_SWAPPER(task))
+		gfp |= __GFP_MEMALLOC;
 
 	size += sizeof(struct rpc_buffer);
 	if (size <= RPC_BUFFER_MAXSIZE)
@@ -828,7 +831,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d7f97ef..6448abe 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1931,6 +1931,49 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 }
 
+#ifdef CONFIG_SUNRPC_SWAP
+static void xs_set_memalloc(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
+			xprt);
+
+	if (xprt->swapper)
+		sk_set_memalloc(transport->inet);
+}
+
+#define RPC_BUF_RESERVE_PAGES \
+	kmalloc_estimate_objs(sizeof(struct rpc_rqst), GFP_KERNEL, RPC_MAX_SLOT_TABLE)
+#define RPC_RESERVE_PAGES	(RPC_BUF_RESERVE_PAGES + TX_RESERVE_PAGES)
+
+/**
+ * xs_swapper - Tag this transport as being used for swap.
+ * @xprt: transport to tag
+ * @enable: enable/disable
+ *
+ */
+int xs_swapper(struct rpc_xprt *xprt, int enable)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
+			xprt);
+	int err = 0;
+
+	if (enable) {
+		xprt->swapper++;
+		xs_set_memalloc(xprt);
+	} else if (xprt->swapper) {
+		xprt->swapper--;
+		sk_clear_memalloc(transport->inet);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(xs_swapper);
+#else
+static void xs_set_memalloc(struct rpc_xprt *xprt)
+{
+}
+#endif
+
 static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -1955,6 +1998,8 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		transport->sock = sock;
 		transport->inet = sk;
 
+		xs_set_memalloc(xprt);
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1966,11 +2011,15 @@ static void xs_udp_setup_socket(struct work_struct *work)
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 	sock = xs_create_sock(xprt, transport,
@@ -1989,6 +2038,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /*
@@ -2079,6 +2129,8 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	if (!xprt_bound(xprt))
 		goto out;
 
+	xs_set_memalloc(xprt);
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -2109,11 +2161,15 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct socket *sock = transport->sock;
 	struct rpc_xprt *xprt = &transport->xprt;
+	unsigned long pflags = current->flags;
 	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		sock = xs_create_sock(xprt, transport,
@@ -2175,6 +2231,7 @@ out_eagain:
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
