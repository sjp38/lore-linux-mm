Message-Id: <20071030160915.763378000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:32 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 31/33] nfs: enable swap on NFS
Content-Disposition: inline; filename=nfs-swapfile.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Provide an a_ops->swapfile() implementation for NFS. This will set the
NFS socket to SOCK_MEMALLOC and run socket reconnect under PF_MEMALLOC as well
as reset SOCK_MEMALLOC before engaging the protocol ->connect() method.

PF_MEMALLOC should allow the allocation of struct socket and related objects
and the early (re)setting of SOCK_MEMALLOC should allow us to receive the packets
required for the TCP connection buildup.

(swapping continues over a server reset during heavy network traffic)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/Kconfig                  |   18 ++++++++++++
 fs/nfs/file.c               |   10 ++++++
 include/linux/sunrpc/xprt.h |    5 ++-
 net/sunrpc/sched.c          |    9 ++++--
 net/sunrpc/xprtsock.c       |   63 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 102 insertions(+), 3 deletions(-)

Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c
+++ linux-2.6/fs/nfs/file.c
@@ -371,6 +371,13 @@ static int nfs_launder_page(struct page 
 	return nfs_wb_page(page_file_mapping(page)->host, page);
 }
 
+#ifdef CONFIG_NFS_SWAP
+static int nfs_swapfile(struct address_space *mapping, int enable)
+{
+	return xs_swapper(NFS_CLIENT(mapping->host)->cl_xprt, enable);
+}
+#endif
+
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -385,6 +392,9 @@ const struct address_space_operations nf
 	.direct_IO = nfs_direct_IO,
 #endif
 	.launder_page = nfs_launder_page,
+#ifdef CONFIG_NFS_SWAP
+	.swapfile = nfs_swapfile,
+#endif
 };
 
 static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
Index: linux-2.6/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.orig/include/linux/sunrpc/xprt.h
+++ linux-2.6/include/linux/sunrpc/xprt.h
@@ -143,7 +143,9 @@ struct rpc_xprt {
 	unsigned int		max_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
-				resvport   : 1; /* use a reserved port */
+				resvport   : 1, /* use a reserved port */
+				swapper    : 1; /* we're swapping over this
+						   transport */
 	unsigned int		bind_index;	/* bind function index */
 
 	/*
@@ -246,6 +248,7 @@ struct rpc_rqst *	xprt_lookup_rqst(struc
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect(struct rpc_xprt *xprt);
+int			xs_swapper(struct rpc_xprt *xprt, int enable);
 
 /*
  * Reserved bit positions in xprt->state
Index: linux-2.6/net/sunrpc/sched.c
===================================================================
--- linux-2.6.orig/net/sunrpc/sched.c
+++ linux-2.6/net/sunrpc/sched.c
@@ -761,7 +761,10 @@ struct rpc_buffer {
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
@@ -817,6 +820,8 @@ void rpc_init_task(struct rpc_task *task
 	atomic_set(&task->tk_count, 1);
 	task->tk_client = clnt;
 	task->tk_flags  = flags;
+	if (clnt->cl_xprt->swapper)
+		task->tk_flags |= RPC_TASK_SWAPPER;
 	task->tk_ops = tk_ops;
 	if (tk_ops->rpc_call_prepare != NULL)
 		task->tk_action = rpc_prepare_task;
@@ -853,7 +858,7 @@ void rpc_init_task(struct rpc_task *task
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
 }
 
 static void rpc_free_task(struct rcu_head *rcu)
Index: linux-2.6/net/sunrpc/xprtsock.c
===================================================================
--- linux-2.6.orig/net/sunrpc/xprtsock.c
+++ linux-2.6/net/sunrpc/xprtsock.c
@@ -1397,6 +1397,9 @@ static void xs_udp_finish_connecting(str
 		transport->sock = sock;
 		transport->inet = sk;
 
+		if (xprt->swapper)
+			sk_set_memalloc(sk);
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1414,11 +1417,15 @@ static void xs_udp_connect_worker4(struc
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
 
@@ -1441,6 +1448,7 @@ static void xs_udp_connect_worker4(struc
 out:
 	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
@@ -1455,11 +1463,15 @@ static void xs_udp_connect_worker6(struc
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
 
@@ -1482,6 +1494,7 @@ static void xs_udp_connect_worker6(struc
 out:
 	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /*
@@ -1541,6 +1554,9 @@ static int xs_tcp_finish_connecting(stru
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 
+	if (xprt->swapper)
+		sk_set_memalloc(transport->inet);
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -1559,11 +1575,15 @@ static void xs_tcp_connect_worker4(struc
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
@@ -1606,6 +1626,7 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 out_clear:
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
@@ -1620,11 +1641,15 @@ static void xs_tcp_connect_worker6(struc
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
@@ -1666,6 +1691,7 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 out_clear:
 	xprt_clear_connecting(xprt);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
@@ -1985,6 +2011,43 @@ int init_socket_xprt(void)
 	return 0;
 }
 
+#ifdef CONFIG_SUNRPC_SWAP
+#define RPC_BUF_RESERVE_PAGES \
+	kestimate_single(sizeof(struct rpc_rqst), GFP_KERNEL, RPC_MAX_SLOT_TABLE)
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
+			sk_set_memalloc(transport->inet);
+			xprt->swapper = 1;
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
+#endif
+
 /**
  * cleanup_socket_xprt - remove xprtsock's sysctls, unregister
  *
Index: linux-2.6/fs/Kconfig
===================================================================
--- linux-2.6.orig/fs/Kconfig
+++ linux-2.6/fs/Kconfig
@@ -1690,6 +1690,18 @@ config NFS_DIRECTIO
 	  causes open() to return EINVAL if a file residing in NFS is
 	  opened with the O_DIRECT flag.
 
+config NFS_SWAP
+	bool "Provide swap over NFS support"
+	default n
+	depends on NFS_FS
+	select SUNRPC_SWAP
+	help
+	  This option enables swapon to work on files located on NFS mounts.
+
+	  For more details, see Documentation/vm_deadlock.txt
+
+	  If unsure, say N.
+
 config NFSD
 	tristate "NFS server support"
 	depends on INET
@@ -1824,6 +1836,12 @@ config SUNRPC_BIND34
 	  If unsure, say N to get traditional behavior (version 2 rpcbind
 	  requests only).
 
+config SUNRPC_SWAP
+	def_bool n
+	depends on SUNRPC
+	select NETVM
+	select SWAP_FILE
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
