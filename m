Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 57C3F6B1409
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:54 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/11] nfs: enable swap on NFS
Date: Mon,  6 Feb 2012 22:56:39 +0000
Message-Id: <1328569001-17599-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1328569001-17599-1-git-send-email-mgorman@suse.de>
References: <1328569001-17599-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Implement the new swapfile a_ops for NFS and hook up ->direct_IO. This
will set the NFS socket to SOCK_MEMALLOC and run socket reconnect
under PF_MEMALLOC as well as reset SOCK_MEMALLOC before engaging the
protocol ->connect() method.

PF_MEMALLOC should allow the allocation of struct socket and related
objects and the early (re)setting of SOCK_MEMALLOC should allow us
to receive the packets required for the TCP connection buildup.

[dfeng@redhat.com: Fix handling of multiple swap files]
[a.p.zijlstra@chello.nl: Original patch]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/nfs/Kconfig              |    8 ++++
 fs/nfs/direct.c             |   94 +++++++++++++++++++++++++++++--------------
 fs/nfs/file.c               |   22 +++++++++-
 include/linux/nfs_fs.h      |    4 +-
 include/linux/sunrpc/xprt.h |    3 +
 net/sunrpc/Kconfig          |    5 ++
 net/sunrpc/clnt.c           |    2 +
 net/sunrpc/sched.c          |    7 ++-
 net/sunrpc/xprtsock.c       |   53 ++++++++++++++++++++++++
 9 files changed, 161 insertions(+), 37 deletions(-)

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
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1940f1a..822a53a 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -112,17 +112,28 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
  * @nr_segs: size of iovec array
  *
  * The presence of this routine in the address space ops vector means
- * the NFS client supports direct I/O.  However, we shunt off direct
- * read and write requests before the VFS gets them, so this method
- * should never be called.
+ * the NFS client supports direct I/O. However, for most direct IO, we
+ * shunt off direct read and write requests before the VFS gets them,
+ * so this method is only ever called for swap.
  */
 ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov, loff_t pos, unsigned long nr_segs)
 {
+#ifndef CONFIG_NFS_SWAP
 	dprintk("NFS: nfs_direct_IO (%s) off/no(%Ld/%lu) EINVAL\n",
 			iocb->ki_filp->f_path.dentry->d_name.name,
 			(long long) pos, nr_segs);
 
 	return -EINVAL;
+#else
+	VM_BUG_ON(iocb->ki_left != PAGE_SIZE);
+	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
+
+	if (rw == READ || rw == KERNEL_READ)
+		return nfs_file_direct_read(iocb, iov, nr_segs, pos,
+				rw == READ ? true : false);
+	return nfs_file_direct_write(iocb, iov, nr_segs, pos,
+				rw == WRITE ? true : false);
+#endif /* CONFIG_NFS_SWAP */
 }
 
 static void nfs_direct_dirty_pages(struct page **pages, unsigned int pgbase, size_t count)
@@ -281,7 +292,7 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
  */
 static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 						const struct iovec *iov,
-						loff_t pos)
+						loff_t pos, bool uio)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->dentry->d_inode;
@@ -315,13 +326,22 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
-		result = get_user_pages(current, current->mm, user_addr,
-					data->npages, 1, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
-		if (result < 0) {
-			nfs_readdata_free(data);
-			break;
+		if (uio) {
+			down_read(&current->mm->mmap_sem);
+			result = get_user_pages(current, current->mm, user_addr,
+				data->npages, 1, 0, data->pagevec, NULL);
+			up_read(&current->mm->mmap_sem);
+			if (result < 0) {
+				nfs_readdata_free(data);
+				break;
+			}
+		} else {
+			WARN_ON(data->npages != 1);
+			result = get_kernel_page(user_addr, 1, data->pagevec);
+			if (WARN_ON(result != 1)) {
+				nfs_readdata_free(data);
+				break;
+			}
 		}
 		if ((unsigned)result < data->npages) {
 			bytes = result * PAGE_SIZE;
@@ -389,7 +409,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 					      const struct iovec *iov,
 					      unsigned long nr_segs,
-					      loff_t pos)
+					      loff_t pos, bool uio)
 {
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
@@ -399,7 +419,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_read_schedule_segment(dreq, vec, pos);
+		result = nfs_direct_read_schedule_segment(dreq, vec, pos, uio);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -423,7 +443,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 }
 
 static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
-			       unsigned long nr_segs, loff_t pos)
+			       unsigned long nr_segs, loff_t pos, bool uio)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -441,7 +461,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
+	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos, uio);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -712,7 +732,8 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
  */
 static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 						 const struct iovec *iov,
-						 loff_t pos, int sync)
+						 loff_t pos, int sync,
+						 bool uio)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->dentry->d_inode;
@@ -746,13 +767,22 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
-		result = get_user_pages(current, current->mm, user_addr,
-					data->npages, 0, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
-		if (result < 0) {
-			nfs_writedata_free(data);
-			break;
+		if (uio) {
+			down_read(&current->mm->mmap_sem);
+			result = get_user_pages(current, current->mm, user_addr,
+				data->npages, 0, 0, data->pagevec, NULL);
+			up_read(&current->mm->mmap_sem);
+			if (result < 0) {
+				nfs_writedata_free(data);
+				break;
+			}
+		} else {
+			WARN_ON(data->npages != 1);
+			result = get_kernel_page(user_addr, 0, data->pagevec);
+			if (WARN_ON(result != 1)) {
+				nfs_writedata_free(data);
+				break;
+			}
 		}
 		if ((unsigned)result < data->npages) {
 			bytes = result * PAGE_SIZE;
@@ -824,7 +854,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 					       const struct iovec *iov,
 					       unsigned long nr_segs,
-					       loff_t pos, int sync)
+					       loff_t pos, int sync,
+					       bool uio)
 {
 	ssize_t result = 0;
 	size_t requested_bytes = 0;
@@ -835,7 +866,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
 		result = nfs_direct_write_schedule_segment(dreq, vec,
-							   pos, sync);
+							   pos, sync, uio);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -860,7 +891,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
 static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos,
-				size_t count)
+				size_t count, bool uio)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -884,7 +915,8 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, sync);
+	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos,
+								sync, uio);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -915,7 +947,7 @@ out:
  * cache.
  */
 ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+				unsigned long nr_segs, loff_t pos, bool uio)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
@@ -940,7 +972,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_read(count);
 
-	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
+	retval = nfs_direct_read(iocb, iov, nr_segs, pos, uio);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
@@ -971,7 +1003,7 @@ out:
  * is no atomic O_APPEND write facility in the NFS protocol.
  */
 ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+				unsigned long nr_segs, loff_t pos, bool uio)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
@@ -1003,7 +1035,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_write(count);
 
-	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
+	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count, uio);
 
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2a0a750..68a563b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -188,7 +188,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t result;
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
+		return nfs_file_direct_read(iocb, iov, nr_segs, pos, true);
 
 	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -487,6 +487,20 @@ static int nfs_launder_page(struct page *page)
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
@@ -501,6 +515,10 @@ const struct address_space_operations nfs_file_aops = {
 	.migratepage = nfs_migrate_page,
 	.launder_page = nfs_launder_page,
 	.error_remove_page = generic_error_remove_page,
+#ifdef CONFIG_NFS_SWAP
+	.swap_activate = nfs_swap_activate,
+	.swap_deactivate = nfs_swap_deactivate,
+#endif
 };
 
 /*
@@ -573,7 +591,7 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	size_t count = iov_length(iov, nr_segs);
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_write(iocb, iov, nr_segs, pos);
+		return nfs_file_direct_write(iocb, iov, nr_segs, pos, true);
 
 	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 8c29950..4dc0f8c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -455,10 +455,10 @@ extern ssize_t nfs_direct_IO(int, struct kiocb *, const struct iovec *, loff_t,
 			unsigned long);
 extern ssize_t nfs_file_direct_read(struct kiocb *iocb,
 			const struct iovec *iov, unsigned long nr_segs,
-			loff_t pos);
+			loff_t pos, bool uio);
 extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
 			const struct iovec *iov, unsigned long nr_segs,
-			loff_t pos);
+			loff_t pos, bool uio);
 
 /*
  * linux/fs/nfs/dir.c
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 15518a1..62e6259 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -174,6 +174,8 @@ struct rpc_xprt {
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
 				resvport   : 1; /* use a reserved port */
+	unsigned int		swapper;	/* we're swapping over this
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
index f0268ea..277fb86 100644
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
index 3341d89..cb7ef6c 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -771,7 +771,10 @@ static void rpc_async_schedule(struct work_struct *work)
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
@@ -845,7 +848,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 55472c4..e3c6a70 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1930,6 +1930,45 @@ out:
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
@@ -1954,6 +1993,8 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		transport->sock = sock;
 		transport->inet = sk;
 
+		xs_set_memalloc(xprt);
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1965,11 +2006,15 @@ static void xs_udp_setup_socket(struct work_struct *work)
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
@@ -1988,6 +2033,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /*
@@ -2078,6 +2124,8 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	if (!xprt_bound(xprt))
 		goto out;
 
+	xs_set_memalloc(xprt);
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -2108,11 +2156,15 @@ static void xs_tcp_setup_socket(struct work_struct *work)
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
@@ -2174,6 +2226,7 @@ out_eagain:
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
