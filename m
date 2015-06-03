Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id B162C900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 16:14:40 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so121704909igb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:14:40 -0700 (PDT)
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com. [209.85.223.169])
        by mx.google.com with ESMTPS id s66si17444232ioi.60.2015.06.03.13.14.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 13:14:40 -0700 (PDT)
Received: by iesa3 with SMTP id a3so21843269ies.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:14:39 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v3 1/5] sunrpc: keep a count of swapfiles associated with the rpc_clnt
Date: Wed,  3 Jun 2015 16:14:25 -0400
Message-Id: <1433362469-2615-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
References: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>, Chuck Lever <chuck.lever@oracle.com>

Jerome reported seeing a warning pop when working with a swapfile on
NFS. The nfs_swap_activate can end up calling sk_set_memalloc while
holding the rcu_read_lock and that function can sleep.

To fix that, we need to take a reference to the xprt while holding the
rcu_read_lock, set the socket up for swapping and then drop that
reference. But, xprt_put is not exported and having NFS deal with the
underlying xprt is a bit of layering violation anyway.

Fix this by adding a set of activate/deactivate functions that take a
rpc_clnt pointer instead of an rpc_xprt, and have nfs_swap_activate and
nfs_swap_deactivate call those.

Also, add a per-rpc_clnt atomic counter to keep track of the number of
active swapfiles associated with it. When the counter does a 0->1
transition, we enable swapping on the xprt, when we do a 1->0 transition
we disable swapping on it.

This also allows us to be a bit more selective with the RPC_TASK_SWAPPER
flag. If non-swapper and swapper clnts are sharing a xprt, then we only
need to flag the tasks from the swapper clnt with that flag.

Acked-by: Mel Gorman <mgorman@suse.de>
Reported-by: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/file.c                | 15 ++--------
 include/linux/sunrpc/clnt.h  |  1 +
 include/linux/sunrpc/sched.h | 16 +++++++++++
 net/sunrpc/clnt.c            | 67 ++++++++++++++++++++++++++++++++++++++------
 net/sunrpc/xprtsock.c        |  3 +-
 5 files changed, 78 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8b8d83a526ce..cc4fa1ed61fc 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -555,31 +555,22 @@ static int nfs_launder_page(struct page *page)
 	return nfs_wb_page(inode, page);
 }
 
-#ifdef CONFIG_NFS_SWAP
 static int nfs_swap_activate(struct swap_info_struct *sis, struct file *file,
 						sector_t *span)
 {
-	int ret;
 	struct rpc_clnt *clnt = NFS_CLIENT(file->f_mapping->host);
 
 	*span = sis->pages;
 
-	rcu_read_lock();
-	ret = xs_swapper(rcu_dereference(clnt->cl_xprt), 1);
-	rcu_read_unlock();
-
-	return ret;
+	return rpc_clnt_swap_activate(clnt);
 }
 
 static void nfs_swap_deactivate(struct file *file)
 {
 	struct rpc_clnt *clnt = NFS_CLIENT(file->f_mapping->host);
 
-	rcu_read_lock();
-	xs_swapper(rcu_dereference(clnt->cl_xprt), 0);
-	rcu_read_unlock();
+	rpc_clnt_swap_deactivate(clnt);
 }
-#endif
 
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
@@ -596,10 +587,8 @@ const struct address_space_operations nfs_file_aops = {
 	.launder_page = nfs_launder_page,
 	.is_dirty_writeback = nfs_check_dirty_writeback,
 	.error_remove_page = generic_error_remove_page,
-#ifdef CONFIG_NFS_SWAP
 	.swap_activate = nfs_swap_activate,
 	.swap_deactivate = nfs_swap_deactivate,
-#endif
 };
 
 /*
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 598ba80ec30c..131032f15cc1 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -56,6 +56,7 @@ struct rpc_clnt {
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
 	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
 
+	atomic_t		cl_swapper;	/* swapfile count */
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME+1];
 	struct rpc_pipe_dir_head cl_pipedir_objects;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 5f1e6bd4c316..3cc54ace99dd 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -269,4 +269,20 @@ static inline void rpc_assign_waitqueue_name(struct rpc_wait_queue *q,
 }
 #endif
 
+#if IS_ENABLED(CONFIG_SUNRPC_SWAP)
+int rpc_clnt_swap_activate(struct rpc_clnt *clnt);
+void rpc_clnt_swap_deactivate(struct rpc_clnt *clnt);
+#else
+static inline int
+rpc_clnt_swap_activate(struct rpc_clnt *clnt)
+{
+	return -EINVAL;
+}
+
+static inline void
+rpc_clnt_swap_deactivate(struct rpc_clnt *clnt)
+{
+}
+#endif /* CONFIG_SUNRPC_SWAP */
+
 #endif /* _LINUX_SUNRPC_SCHED_H_ */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e6ce1517367f..383cb778179f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -891,15 +891,8 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 			task->tk_flags |= RPC_TASK_SOFT;
 		if (clnt->cl_noretranstimeo)
 			task->tk_flags |= RPC_TASK_NO_RETRANS_TIMEOUT;
-		if (sk_memalloc_socks()) {
-			struct rpc_xprt *xprt;
-
-			rcu_read_lock();
-			xprt = rcu_dereference(clnt->cl_xprt);
-			if (xprt->swapper)
-				task->tk_flags |= RPC_TASK_SWAPPER;
-			rcu_read_unlock();
-		}
+		if (atomic_read(&clnt->cl_swapper))
+			task->tk_flags |= RPC_TASK_SWAPPER;
 		/* Add to the client's list of all tasks */
 		spin_lock(&clnt->cl_lock);
 		list_add_tail(&task->tk_task, &clnt->cl_tasks);
@@ -2476,3 +2469,59 @@ void rpc_show_tasks(struct net *net)
 	spin_unlock(&sn->rpc_client_lock);
 }
 #endif
+
+#if IS_ENABLED(CONFIG_SUNRPC_SWAP)
+int
+rpc_clnt_swap_activate(struct rpc_clnt *clnt)
+{
+	int ret = 0;
+	struct rpc_xprt	*xprt;
+
+	if (atomic_inc_return(&clnt->cl_swapper) == 1) {
+retry:
+		rcu_read_lock();
+		xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
+		rcu_read_unlock();
+		if (!xprt) {
+			/*
+			 * If we didn't get a reference, then we likely are
+			 * racing with a migration event. Wait for a grace
+			 * period and try again.
+			 */
+			synchronize_rcu();
+			goto retry;
+		}
+
+		ret = xs_swapper(xprt, 1);
+		xprt_put(xprt);
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_swap_activate);
+
+void
+rpc_clnt_swap_deactivate(struct rpc_clnt *clnt)
+{
+	struct rpc_xprt	*xprt;
+
+	if (atomic_dec_if_positive(&clnt->cl_swapper) == 0) {
+retry:
+		rcu_read_lock();
+		xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
+		rcu_read_unlock();
+		if (!xprt) {
+			/*
+			 * If we didn't get a reference, then we likely are
+			 * racing with a migration event. Wait for a grace
+			 * period and try again.
+			 */
+			synchronize_rcu();
+			goto retry;
+		}
+
+		xs_swapper(xprt, 0);
+		xprt_put(xprt);
+	}
+}
+EXPORT_SYMBOL_GPL(rpc_clnt_swap_deactivate);
+#endif /* CONFIG_SUNRPC_SWAP */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 66891e32c5e3..92d198fd6820 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1960,7 +1960,7 @@ static void xs_local_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 		msleep_interruptible(15000);
 }
 
-#ifdef CONFIG_SUNRPC_SWAP
+#if IS_ENABLED(CONFIG_SUNRPC_SWAP)
 static void xs_set_memalloc(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
@@ -1992,7 +1992,6 @@ int xs_swapper(struct rpc_xprt *xprt, int enable)
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(xs_swapper);
 #else
 static void xs_set_memalloc(struct rpc_xprt *xprt)
 {
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
