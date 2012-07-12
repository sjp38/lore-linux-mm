Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A774C6B0099
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:41:25 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/12] nfs: enable swap on NFS
Date: Thu, 12 Jul 2012 07:41:04 +0100
Message-Id: <1342075266-29593-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Implement the new swapfile a_ops for NFS and hook up ->direct_IO. This
will set the NFS socket to SOCK_MEMALLOC and run socket reconnect
under PF_MEMALLOC as well as reset SOCK_MEMALLOC before engaging the
protocol ->connect() method.

PF_MEMALLOC should allow the allocation of struct socket and related
objects and the early (re)setting of SOCK_MEMALLOC should allow us
to receive the packets required for the TCP connection buildup.

[jlayton@redhat.com: Restore PF_MEMALLOC task flags in all cases]
[dfeng@redhat.com: Fix handling of multiple swap files]
[a.p.zijlstra@chello.nl: Original patch]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 fs/nfs/Kconfig              |    8 +++++
 fs/nfs/direct.c             |   82 ++++++++++++++++++++++++++++---------------
 fs/nfs/file.c               |   22 ++++++++++--
 include/linux/nfs_fs.h      |    4 +--
 include/linux/sunrpc/xprt.h |    3 ++
 net/sunrpc/Kconfig          |    5 +++
 net/sunrpc/clnt.c           |    2 ++
 net/sunrpc/sched.c          |    7 ++--
 net/sunrpc/xprtsock.c       |   54 ++++++++++++++++++++++++++++
 9 files changed, 153 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index b47452f..07f35c6 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -85,6 +85,14 @@ config NFS_V4
 
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
 	depends on NFS_V4 && EXPERIMENTAL
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4825337..94d46e1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -115,17 +115,28 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
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
 
 static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
@@ -303,7 +314,7 @@ static const struct nfs_pgio_completion_ops nfs_direct_read_completion_ops = {
  */
 static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *desc,
 						const struct iovec *iov,
-						loff_t pos)
+						loff_t pos, bool uio)
 {
 	struct nfs_direct_req *dreq = desc->pg_dreq;
 	struct nfs_open_context *ctx = dreq->ctx;
@@ -331,12 +342,20 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 					  GFP_KERNEL);
 		if (!pagevec)
 			break;
-		down_read(&current->mm->mmap_sem);
-		result = get_user_pages(current, current->mm, user_addr,
+		if (uio) {
+			down_read(&current->mm->mmap_sem);
+			result = get_user_pages(current, current->mm, user_addr,
 					npages, 1, 0, pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
-		if (result < 0)
-			break;
+			up_read(&current->mm->mmap_sem);
+			if (result < 0)
+				break;
+		} else {
+			WARN_ON(npages != 1);
+			result = get_kernel_page(user_addr, 1, pagevec);
+			if (WARN_ON(result != 1))
+				break;
+		}
+
 		if ((unsigned)result < npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
@@ -386,7 +405,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 					      const struct iovec *iov,
 					      unsigned long nr_segs,
-					      loff_t pos)
+					      loff_t pos, bool uio)
 {
 	struct nfs_pageio_descriptor desc;
 	ssize_t result = -EINVAL;
@@ -400,7 +419,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_read_schedule_segment(&desc, vec, pos);
+		result = nfs_direct_read_schedule_segment(&desc, vec, pos, uio);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -426,7 +445,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 }
 
 static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
-			       unsigned long nr_segs, loff_t pos)
+			       unsigned long nr_segs, loff_t pos, bool uio)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -444,7 +463,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
+	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos, uio);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 	NFS_I(inode)->read_io += result;
@@ -610,7 +629,7 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
  */
 static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *desc,
 						 const struct iovec *iov,
-						 loff_t pos)
+						 loff_t pos, bool uio)
 {
 	struct nfs_direct_req *dreq = desc->pg_dreq;
 	struct nfs_open_context *ctx = dreq->ctx;
@@ -638,12 +657,19 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 		if (!pagevec)
 			break;
 
-		down_read(&current->mm->mmap_sem);
-		result = get_user_pages(current, current->mm, user_addr,
-					npages, 0, 0, pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
-		if (result < 0)
-			break;
+		if (uio) {
+			down_read(&current->mm->mmap_sem);
+			result = get_user_pages(current, current->mm, user_addr,
+						npages, 0, 0, pagevec, NULL);
+			up_read(&current->mm->mmap_sem);
+			if (result < 0)
+				break;
+		} else {
+			WARN_ON(npages != 1);
+			result = get_kernel_page(user_addr, 0, pagevec);
+			if (WARN_ON(result != 1))
+				break;
+		}
 
 		if ((unsigned)result < npages) {
 			bytes = result * PAGE_SIZE;
@@ -774,7 +800,7 @@ static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops = {
 static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 					       const struct iovec *iov,
 					       unsigned long nr_segs,
-					       loff_t pos)
+					       loff_t pos, bool uio)
 {
 	struct nfs_pageio_descriptor desc;
 	struct inode *inode = dreq->inode;
@@ -790,7 +816,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_write_schedule_segment(&desc, vec, pos);
+		result = nfs_direct_write_schedule_segment(&desc, vec, pos, uio);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -818,7 +844,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
 static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos,
-				size_t count)
+				size_t count, bool uio)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -836,7 +862,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos);
+	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, uio);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -867,7 +893,7 @@ out:
  * cache.
  */
 ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+				unsigned long nr_segs, loff_t pos, bool uio)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
@@ -892,7 +918,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_read(count);
 
-	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
+	retval = nfs_direct_read(iocb, iov, nr_segs, pos, uio);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
@@ -923,7 +949,7 @@ out:
  * is no atomic O_APPEND write facility in the NFS protocol.
  */
 ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+				unsigned long nr_segs, loff_t pos, bool uio)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
@@ -955,7 +981,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_write(count);
 
-	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
+	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count, uio);
 	if (retval > 0) {
 		struct inode *inode = mapping->host;
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2076464..ff93f08 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -194,7 +194,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t result;
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
+		return nfs_file_direct_read(iocb, iov, nr_segs, pos, true);
 
 	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -501,6 +501,20 @@ static int nfs_launder_page(struct page *page)
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
@@ -515,6 +529,10 @@ const struct address_space_operations nfs_file_aops = {
 	.migratepage = nfs_migrate_page,
 	.launder_page = nfs_launder_page,
 	.error_remove_page = generic_error_remove_page,
+#ifdef CONFIG_NFS_SWAP
+	.swap_activate = nfs_swap_activate,
+	.swap_deactivate = nfs_swap_deactivate,
+#endif
 };
 
 /*
@@ -589,7 +607,7 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	size_t count = iov_length(iov, nr_segs);
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_write(iocb, iov, nr_segs, pos);
+		return nfs_file_direct_write(iocb, iov, nr_segs, pos, true);
 
 	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b23cfc1..fae495a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -477,10 +477,10 @@ extern ssize_t nfs_direct_IO(int, struct kiocb *, const struct iovec *, loff_t,
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
index 77d278d..cff40aa 100644
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
@@ -316,6 +318,7 @@ void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
+int			xs_swapper(struct rpc_xprt *xprt, int enable);
 
 /*
  * Reserved bit positions in xprt->state
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 9fe8857..03d03e3 100644
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
index f56f045..09e71d1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -717,6 +717,8 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 		atomic_inc(&clnt->cl_count);
 		if (clnt->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
+		if (task->tk_client->cl_xprt->swapper)
+			task->tk_flags |= RPC_TASK_SWAPPER;
 		/* Add to the client's list of all tasks */
 		spin_lock(&clnt->cl_lock);
 		list_add_tail(&task->tk_task, &clnt->cl_tasks);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 994cfea..83a4c43 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -812,7 +812,10 @@ static void rpc_async_schedule(struct work_struct *work)
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
@@ -886,7 +889,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 62d0dac..83bb0eb 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1927,6 +1927,45 @@ out:
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
@@ -1951,6 +1990,8 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		transport->sock = sock;
 		transport->inet = sk;
 
+		xs_set_memalloc(xprt);
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1962,11 +2003,15 @@ static void xs_udp_setup_socket(struct work_struct *work)
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
@@ -1985,6 +2030,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /*
@@ -2075,6 +2121,8 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	if (!xprt_bound(xprt))
 		goto out;
 
+	xs_set_memalloc(xprt);
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -2105,11 +2153,15 @@ static void xs_tcp_setup_socket(struct work_struct *work)
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
@@ -2159,6 +2211,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -EINPROGRESS:
 	case -EALREADY:
 		xprt_clear_connecting(xprt);
+		tsk_restore_flags(current, pflags, PF_MEMALLOC);
 		return;
 	case -EINVAL:
 		/* Happens, for instance, if the user specified a link
@@ -2171,6 +2224,7 @@ out_eagain:
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
