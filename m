Message-Id: <20080724141531.402850877@chello.nl>
References: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:01:11 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 29/30] nfs: enable swap on NFS
Content-Disposition: inline; filename=nfs-swap_ops.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Implement all the new swapfile a_ops for NFS. This will set the NFS socket to
SOCK_MEMALLOC and run socket reconnect under PF_MEMALLOC as well as reset
SOCK_MEMALLOC before engaging the protocol ->connect() method.

PF_MEMALLOC should allow the allocation of struct socket and related objects
and the early (re)setting of SOCK_MEMALLOC should allow us to receive the
packets required for the TCP connection buildup.

(swapping continues over a server reset during heavy network traffic)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/Kconfig                  |   17 ++++++++++
 fs/nfs/file.c               |   18 ++++++++++
 fs/nfs/write.c              |   22 +++++++++++++
 include/linux/nfs_fs.h      |    2 +
 include/linux/sunrpc/xprt.h |    5 ++-
 net/sunrpc/sched.c          |    9 ++++-
 net/sunrpc/xprtsock.c       |   73 ++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 143 insertions(+), 3 deletions(-)

Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c
+++ linux-2.6/fs/nfs/file.c
@@ -434,6 +434,18 @@ static int nfs_launder_page(struct page 
 	return nfs_wb_page(inode, page);
 }
 
+#ifdef CONFIG_NFS_SWAP
+static int nfs_swapon(struct file *file)
+{
+	return xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 1);
+}
+
+static int nfs_swapoff(struct file *file)
+{
+	return xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 0);
+}
+#endif
+
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -446,6 +458,12 @@ const struct address_space_operations nf
 	.releasepage = nfs_release_page,
 	.direct_IO = nfs_direct_IO,
 	.launder_page = nfs_launder_page,
+#ifdef CONFIG_NFS_SWAP
+	.swapon = nfs_swapon,
+	.swapoff = nfs_swapoff,
+	.swap_out = nfs_swap_out,
+	.swap_in = nfs_readpage,
+#endif
 };
 
 static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -330,6 +330,28 @@ int nfs_writepage(struct page *page, str
 	return ret;
 }
 
+static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
+		unsigned int offset, unsigned int count);
+
+int nfs_swap_out(struct file *file, struct page *page,
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
Index: linux-2.6/include/linux/nfs_fs.h
===================================================================
--- linux-2.6.orig/include/linux/nfs_fs.h
+++ linux-2.6/include/linux/nfs_fs.h
@@ -463,6 +463,8 @@ extern int  nfs_flush_incompatible(struc
 extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
 extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern void nfs_writedata_release(void *);
+extern int  nfs_swap_out(struct file *file, struct page *page,
+			 struct writeback_control *wbc);
 
 /*
  * Try to write back everything synchronously (but check the
Index: linux-2.6/fs/Kconfig
===================================================================
--- linux-2.6.orig/fs/Kconfig
+++ linux-2.6/fs/Kconfig
@@ -1692,6 +1692,18 @@ config ROOT_NFS
 
 	  Most people say N here.
 
+config NFS_SWAP
+	bool "Provide swap over NFS support"
+	default n
+	depends on NFS_FS
+	select SUNRPC_SWAP
+	help
+	  This option enables swapon to work on files located on NFS mounts.
+
+	  For more details, see Documentation/network-swap.txt
+
+	  If unsure, say N.
+
 config NFSD
 	tristate "NFS server support"
 	depends on INET
@@ -1813,6 +1825,11 @@ config SUNRPC_XPRT_RDMA
 
 	  If unsure, say N.
 
+config SUNRPC_SWAP
+	def_bool n
+	depends on SUNRPC
+	select NETVM
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
Index: linux-2.6/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.orig/include/linux/sunrpc/xprt.h
+++ linux-2.6/include/linux/sunrpc/xprt.h
@@ -147,7 +147,9 @@ struct rpc_xprt {
 	unsigned int		max_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
-				resvport   : 1; /* use a reserved port */
+				resvport   : 1, /* use a reserved port */
+				swapper    : 1; /* we're swapping over this
+						   transport */
 	unsigned int		bind_index;	/* bind function index */
 
 	/*
@@ -249,6 +251,7 @@ void			xprt_release_rqst_cong(struct rpc
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
+int			xs_swapper(struct rpc_xprt *xprt, int enable);
 
 /*
  * Reserved bit positions in xprt->state
Index: linux-2.6/net/sunrpc/sched.c
===================================================================
--- linux-2.6.orig/net/sunrpc/sched.c
+++ linux-2.6/net/sunrpc/sched.c
@@ -729,7 +729,10 @@ struct rpc_buffer {
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
@@ -800,6 +803,8 @@ static void rpc_init_task(struct rpc_tas
 		kref_get(&task->tk_client->cl_kref);
 		if (task->tk_client->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
+		if (task->tk_client->cl_xprt->swapper)
+			task->tk_flags |= RPC_TASK_SWAPPER;
 	}
 
 	if (task->tk_ops->rpc_call_prepare != NULL)
@@ -825,7 +830,7 @@ static void rpc_init_task(struct rpc_tas
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
 }
 
 /*
Index: linux-2.6/net/sunrpc/xprtsock.c
===================================================================
--- linux-2.6.orig/net/sunrpc/xprtsock.c
+++ linux-2.6/net/sunrpc/xprtsock.c
@@ -1445,6 +1445,55 @@ static inline void xs_reclassify_socket6
 }
 #endif
 
+#ifdef CONFIG_SUNRPC_SWAP
+static void xs_set_memalloc(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	if (xprt->swapper)
+		sk_set_memalloc(transport->inet);
+}
+
+#define RPC_BUF_RESERVE_PAGES \
+	kmalloc_estimate_fixed(sizeof(struct rpc_rqst), GFP_KERNEL, RPC_MAX_SLOT_TABLE)
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
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	int err = 0;
+
+	if (enable) {
+		/*
+		 * keep one extra sock reference so the reserve won't dip
+		 * when the socket gets reconnected.
+		 */
+		err = sk_adjust_memalloc(1, RPC_RESERVE_PAGES);
+		if (!err) {
+			xprt->swapper = 1;
+			xs_set_memalloc(xprt);
+		}
+	} else if (xprt->swapper) {
+		xprt->swapper = 0;
+		sk_clear_memalloc(transport->inet);
+		sk_adjust_memalloc(-1, -RPC_RESERVE_PAGES);
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
@@ -1469,6 +1518,8 @@ static void xs_udp_finish_connecting(str
 		transport->sock = sock;
 		transport->inet = sk;
 
+		xs_set_memalloc(xprt);
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1486,11 +1537,15 @@ static void xs_udp_connect_worker4(struc
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int err, status = -EIO;
 
 	if (xprt->shutdown || !xprt_bound(xprt))
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	/* Start by resetting any existing state */
 	xs_close(xprt);
 
@@ -1513,6 +1568,7 @@ static void xs_udp_connect_worker4(struc
 out:
 	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
@@ -1527,11 +1583,15 @@ static void xs_udp_connect_worker6(struc
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int err, status = -EIO;
 
 	if (xprt->shutdown || !xprt_bound(xprt))
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	/* Start by resetting any existing state */
 	xs_close(xprt);
 
@@ -1554,6 +1614,7 @@ static void xs_udp_connect_worker6(struc
 out:
 	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /*
@@ -1613,6 +1674,8 @@ static int xs_tcp_finish_connecting(stru
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 
+	xs_set_memalloc(xprt);
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -1631,11 +1694,15 @@ static void xs_tcp_connect_worker4(struc
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int err, status = -EIO;
 
 	if (xprt->shutdown || !xprt_bound(xprt))
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	if (!sock) {
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
@@ -1677,6 +1744,7 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 out_clear:
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
@@ -1691,11 +1759,15 @@ static void xs_tcp_connect_worker6(struc
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int err, status = -EIO;
 
 	if (xprt->shutdown || !xprt_bound(xprt))
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	if (!sock) {
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
@@ -1736,6 +1808,7 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 out_clear:
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
