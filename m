Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id E55646B003B
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 22:03:50 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id mc6so9679431lab.20
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:03:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jj4si20915094lbc.39.2014.09.23.19.03.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 19:03:49 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 24 Sep 2014 11:28:32 +1000
Subject: [PATCH 5/5] NFS/SUNRPC: Remove other deadlock-avoidance mechanisms
 in nfs_release_page()
Message-ID: <20140924012832.4838.429.stgit@notabene.brown>
In-Reply-To: <20140924012422.4838.29188.stgit@notabene.brown>
References: <20140924012422.4838.29188.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

Now that nfs_release_page() doesn't block indefinitely, other deadlock
avoidance mechanisms aren't needed.
 - it doesn't hurt for kswapd to block occasionally.  If it doesn't
   want to block it would clear __GFP_WAIT.  The current_is_kswapd()
   was only added to avoid deadlocks and we have a new approach for
   that.
 - memory allocation in the SUNRPC layer can very rarely try to
   ->releasepage() a page it is trying to handle.  The deadlock
   is removed as nfs_release_page() doesn't block indefinitely.

So we don't need to set PF_FSTRANS for sunrpc network operations any
more.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/file.c                   |   14 ++++++--------
 net/sunrpc/sched.c              |    2 --
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtsock.c           |   10 ----------
 4 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 1243a15438d0..de322d3f4a29 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -469,20 +469,18 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
 	/* Always try to initiate a 'commit' if relevant, but only
-	 * wait for it if __GFP_WAIT is set and the calling process is
-	 * allowed to block.  Even then, only wait 1 second and only
-	 * if the 'bdi' is not congested.
+	 * wait for it if __GFP_WAIT is set.  Even then, only wait 1
+	 * second and only if the 'bdi' is not congested.
 	 * Waiting indefinitely can cause deadlocks when the NFS
-	 * server is on this machine, and there is no particular need
-	 * to wait extensively here.  A short wait has the benefit
-	 * that someone else can worry about the freezer.
+	 * server is on this machine, when a new TCP connection is
+	 * needed and in other rare cases.  There is no particular
+	 * need to wait extensively here.  A short wait has the
+	 * benefit that someone else can worry about the freezer.
 	 */
 	if (mapping) {
 		struct nfs_server *nfss = NFS_SERVER(mapping->host);
 		nfs_commit_inode(mapping->host, 0);
 		if ((gfp & __GFP_WAIT) &&
-		    !current_is_kswapd() &&
-		    !(current->flags & PF_FSTRANS) &&
 		    !bdi_write_congested(&nfss->backing_dev_info)) {
 			wait_on_page_bit_killable_timeout(page, PG_private,
 							  HZ);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9358c79fd589..fe3441abdbe5 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -821,9 +821,7 @@ void rpc_execute(struct rpc_task *task)
 
 static void rpc_async_schedule(struct work_struct *work)
 {
-	current->flags |= PF_FSTRANS;
 	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
-	current->flags &= ~PF_FSTRANS;
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 2faac4940563..6a4615dd0261 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -205,7 +205,6 @@ xprt_rdma_connect_worker(struct work_struct *work)
 	struct rpc_xprt *xprt = &r_xprt->xprt;
 	int rc = 0;
 
-	current->flags |= PF_FSTRANS;
 	xprt_clear_connected(xprt);
 
 	dprintk("RPC:       %s: %sconnect\n", __func__,
@@ -216,7 +215,6 @@ xprt_rdma_connect_worker(struct work_struct *work)
 
 	dprintk("RPC:       %s: exit\n", __func__);
 	xprt_clear_connecting(xprt);
-	current->flags &= ~PF_FSTRANS;
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 43cd89eacfab..4707c0c8568b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1927,8 +1927,6 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 	struct socket *sock;
 	int status = -EIO;
 
-	current->flags |= PF_FSTRANS;
-
 	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	status = __sock_create(xprt->xprt_net, AF_LOCAL,
 					SOCK_STREAM, 0, &sock, 1);
@@ -1968,7 +1966,6 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
-	current->flags &= ~PF_FSTRANS;
 	return status;
 }
 
@@ -2071,8 +2068,6 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int status = -EIO;
 
-	current->flags |= PF_FSTRANS;
-
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 	sock = xs_create_sock(xprt, transport,
@@ -2092,7 +2087,6 @@ static void xs_udp_setup_socket(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
-	current->flags &= ~PF_FSTRANS;
 }
 
 /*
@@ -2229,8 +2223,6 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	struct rpc_xprt *xprt = &transport->xprt;
 	int status = -EIO;
 
-	current->flags |= PF_FSTRANS;
-
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		sock = xs_create_sock(xprt, transport,
@@ -2276,7 +2268,6 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -EINPROGRESS:
 	case -EALREADY:
 		xprt_clear_connecting(xprt);
-		current->flags &= ~PF_FSTRANS;
 		return;
 	case -EINVAL:
 		/* Happens, for instance, if the user specified a link
@@ -2294,7 +2285,6 @@ out_eagain:
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
-	current->flags &= ~PF_FSTRANS;
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
