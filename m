Message-Id: <20070221144844.280223000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:32 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 28/29] nfs: enable swap on NFS
Content-Disposition: inline; filename=nfs-swapfile.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Provide an ops->swapfile() implementation for NFS. This will set the
NFS socket to SOCK_VMIO and run socket reconnect under PF_MEMALLOC as well
as reset SOCK_VMIO before engaging the protocol ->connect() method.

PF_MEMALLOC should allow the allocation of struct socket and related objects
and the early (re)setting of SOCK_VMIO should allow us to receive the packets
required for the TCP connection buildup.

(swapping continues over a server reset during heavy network traffic)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/Kconfig                  |   14 ++++++++++++
 fs/nfs/file.c               |    6 +++++
 include/linux/sunrpc/xprt.h |    5 +++-
 net/sunrpc/sched.c          |   13 +++++++----
 net/sunrpc/xprtsock.c       |   49 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 81 insertions(+), 6 deletions(-)

Index: linux-2.6-git/fs/nfs/file.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/file.c	2007-02-21 12:15:16.000000000 +0100
+++ linux-2.6-git/fs/nfs/file.c	2007-02-21 12:15:19.000000000 +0100
@@ -324,6 +324,11 @@ static int nfs_launder_page(struct page 
 	return nfs_wb_page(page_file_mapping(page)->host, page);
 }
 
+static int nfs_swapfile(struct address_space *mapping, int enable)
+{
+	return xs_swapper(NFS_CLIENT(mapping->host)->cl_xprt, enable);
+}
+
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -338,6 +343,7 @@ const struct address_space_operations nf
 	.direct_IO = nfs_direct_IO,
 #endif
 	.launder_page = nfs_launder_page,
+	.swapfile = nfs_swapfile,
 };
 
 static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
Index: linux-2.6-git/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6-git.orig/include/linux/sunrpc/xprt.h	2007-02-21 11:04:08.000000000 +0100
+++ linux-2.6-git/include/linux/sunrpc/xprt.h	2007-02-21 12:15:19.000000000 +0100
@@ -149,7 +149,9 @@ struct rpc_xprt {
 	unsigned int		max_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
-				resvport   : 1; /* use a reserved port */
+				resvport   : 1, /* use a reserved port */
+				swapper    : 1; /* we're swapping over this
+						   transport */
 
 	/*
 	 * Connection of transports
@@ -241,6 +243,7 @@ void			xprt_disconnect(struct rpc_xprt *
  */
 struct rpc_xprt *	xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
 struct rpc_xprt *	xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
+int			xs_swapper(struct rpc_xprt *xprt, int enable);
 
 /*
  * Reserved bit positions in xprt->state
Index: linux-2.6-git/net/sunrpc/sched.c
===================================================================
--- linux-2.6-git.orig/net/sunrpc/sched.c	2007-02-21 11:04:08.000000000 +0100
+++ linux-2.6-git/net/sunrpc/sched.c	2007-02-21 12:15:19.000000000 +0100
@@ -751,10 +751,13 @@ void * rpc_malloc(struct rpc_task *task,
 	struct rpc_rqst *req = task->tk_rqstp;
 	gfp_t	gfp;
 
-	if (task->tk_flags & RPC_TASK_SWAPPER)
-		gfp = GFP_ATOMIC;
-	else
-		gfp = GFP_NOFS;
+	/*
+	 * this rcpio thread might be needed by reclaim, hence we cannot
+	 * wait on a regular alloc to succeed.
+	 */
+	gfp = GFP_ATOMIC;
+	if (RPC_IS_SWAPPER(task))
+		gfp |= __GFP_EMERGENCY;
 
 	if (size > RPC_BUFFER_MAXSIZE) {
 		req->rq_buffer = kmalloc(size, gfp);
@@ -834,7 +837,7 @@ void rpc_init_task(struct rpc_task *task
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
 }
 
 static void rpc_free_task(struct rcu_head *rcu)
Index: linux-2.6-git/net/sunrpc/xprtsock.c
===================================================================
--- linux-2.6-git.orig/net/sunrpc/xprtsock.c	2007-02-21 11:04:08.000000000 +0100
+++ linux-2.6-git/net/sunrpc/xprtsock.c	2007-02-21 12:15:19.000000000 +0100
@@ -1215,11 +1215,15 @@ static void xs_udp_connect_worker(struct
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
 
@@ -1257,6 +1261,9 @@ static void xs_udp_connect_worker(struct
 		transport->sock = sock;
 		transport->inet = sk;
 
+		if (xprt->swapper)
+			sk_set_vmio(sk);
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1264,6 +1271,7 @@ static void xs_udp_connect_worker(struct
 out:
 	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	current->flags = pflags;
 }
 
 /*
@@ -1302,11 +1310,15 @@ static void xs_tcp_connect_worker(struct
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
@@ -1356,6 +1368,10 @@ static void xs_tcp_connect_worker(struct
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 
+
+	if (xprt->swapper)
+		sk_set_vmio(transport->inet);
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -1383,6 +1399,7 @@ out:
 	xprt_wake_pending_tasks(xprt, status);
 out_clear:
 	xprt_clear_connecting(xprt);
+	current->flags = pflags;
 }
 
 /**
@@ -1642,6 +1659,38 @@ int init_socket_xprt(void)
 	return 0;
 }
 
+#define RPC_BUF_RESERVE_PAGES	(RPC_MAX_SLOT_TABLE)
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
+		sk_adjust_memalloc(1, RPC_RESERVE_PAGES);
+		sk_set_vmio(transport->inet);
+		xprt->swapper = 1;
+	} else if (xprt->swapper) {
+		xprt->swapper = 0;
+		sk_clear_vmio(transport->inet);
+		sk_adjust_memalloc(-1, -RPC_RESERVE_PAGES);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(xs_swapper);
+
 /**
  * cleanup_socket_xprt - remove xprtsock's sysctls
  *
Index: linux-2.6-git/fs/Kconfig
===================================================================
--- linux-2.6-git.orig/fs/Kconfig	2007-02-21 11:04:08.000000000 +0100
+++ linux-2.6-git/fs/Kconfig	2007-02-21 12:15:19.000000000 +0100
@@ -1621,6 +1621,20 @@ config NFS_DIRECTIO
 	  causes open() to return EINVAL if a file residing in NFS is
 	  opened with the O_DIRECT flag.
 
+config NFS_SWAP
+	bool "Provide swap over NFS support"
+	default n
+	depends on NFS_FS
+	select SLAB_FAIR
+	select NETVM
+	select SWAP_FILE
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

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
