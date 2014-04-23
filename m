Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5796B0074
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 23:48:59 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so256850eek.36
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 20:48:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si1017063een.233.2014.04.22.20.48.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 20:48:57 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 23 Apr 2014 12:40:58 +1000
Subject: [PATCH 5/5] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
Message-ID: <20140423024058.4725.23378.stgit@notabene.brown>
In-Reply-To: <20140423022441.4725.89693.stgit@notabene.brown>
References: <20140423022441.4725.89693.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Mel Gorman <mgorman@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

Support for loop-back mounted NFS filesystems is useful when NFS is
used to access shared storage in a high-availability cluster.

If the node running the NFS server fails some other node can mount the
filesystem and start providing NFS service.  If that node already had
the filesystem NFS mounted, it will now have it loop-back mounted.

nfsd can suffer a deadlock when allocating memory and entering direct
reclaim.
While direct reclaim does not write to the NFS filesystem it can send
and wait for a COMMIT through nfs_release_page().

This patch modifies nfs_release_page() and the functions it calls so
that if the COMMIT is sent to the local host (i.e. is routed over the
loop-back interface) then nfs_release_page() will not wait forever for
that COMMIT to complete.

Aborting early should be safe as kswapd uses the same code but never
waits for the COMMIT.

Always aborting early could upset the balance of memory management so
when the commit was sent to the local host we still wait but with a
100ms timeout.  This is enough to significantly slow down any process
that is allocating lots of memory and often long enough to let the
commit complete.

In those rare cases where it is nfsd, or something that nfsd is
waiting for, that is calling nfs_release_page(), 100ms is not so long
that throughput will be affected.

When fail-over happens a remote (foreign) client will first become
disconnected and then turn into a local client.
To prevent deadlocks from happening at this point, we still have a
timeout when the COMMIT has been sent to a remote client. In this case
the timeout is longer (1 second).

So when a node that has mounted a remote filesystem loses the
connection, nfs_release_page() will stop blocking and start failing.
Memory allocators will then be able to make progress without blocking
in NFS.  Any process which writes to a file will still be blocked in
balance_dirty_pages().

I really need a version of wait_on_bit and friends which supports
timeouts for this patch.  I've hacked something that works by abusing
current->journal_info, but I don't expect that to go upstream.

I cannot simply use schedule_timeout in the wait_bit function as there
could be false wakeups due to hash collisions in bit_waitqueue().
One possibility would to be to have a 'private' field in 'struct
wait_bit_key' that was initialized to 0, and have the address of
that struct passed to the 'action' function.
There are currently 26 of these action functions so it wouldn't be too
hard to change the interface...

It might be good to use something like SetPageReclaim() to ensure that
the page is reclaimed as soon as the COMMIT does complete, but I don't
understand that code well enough yet to supply a patch.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/file.c               |    2 +
 fs/nfs/write.c              |   73 ++++++++++++++++++++++++++++++++++++++-----
 include/linux/freezer.h     |   10 ++++++
 include/uapi/linux/nfs_fs.h |    3 ++
 4 files changed, 79 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5bb790a69c71..64a2999fe290 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -474,7 +474,7 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 	 */
 	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL &&
 	    !(current->flags & PF_FSTRANS)) {
-		int how = FLUSH_SYNC;
+		int how = FLUSH_SYNC | FLUSH_COND_CONNECTED;
 
 		/* Don't let kswapd deadlock waiting for OOM RPC calls */
 		if (current_is_kswapd())
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9a3b6a4cd6b9..eadd3317fd85 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -14,6 +14,7 @@
 #include <linux/writeback.h>
 #include <linux/swap.h>
 #include <linux/migrate.h>
+#include <linux/freezer.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
@@ -1440,6 +1441,43 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 
 
 #if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
+
+static int _wait_bit_connected(struct rpc_clnt *cl)
+{
+	if (fatal_signal_pending(current))
+		return -ERESTARTSYS;
+	if (!cl || rpc_is_foreign(cl)) {
+		/* it might not stay foreign forever */
+		freezable_schedule_timeout_unsafe(HZ);
+	} else {
+		unsigned long *commit_start = current->journal_info;
+		unsigned long waited = jiffies - *commit_start;
+
+		/* we could block forever here ... */
+		if (waited >= HZ/10)
+			/* Too long, give up */
+			return -EAGAIN;
+
+		freezable_schedule_timeout_unsafe(HZ/10 - waited);
+	}
+	return 0;
+}
+
+static int nfs_wait_bit_connected(void *word)
+{
+	struct nfs_inode *nfsi = container_of(word, struct nfs_inode, flags);
+
+	return _wait_bit_connected(NFS_CLIENT(&nfsi->vfs_inode));
+}
+
+static int rpc_wait_bit_connected(void *word)
+{
+	struct rpc_task *task = container_of(word, struct rpc_task, tk_runstate);
+
+	return _wait_bit_connected(task->tk_client);
+}
+
+
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
@@ -1450,7 +1488,8 @@ static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 		return 0;
 	ret = out_of_line_wait_on_bit_lock(&nfsi->flags,
 				NFS_INO_COMMIT,
-				nfs_wait_bit_killable,
+				(may_wait & FLUSH_COND_CONNECTED) ?
+				   nfs_wait_bit_connected : nfs_wait_bit_killable,
 				TASK_KILLABLE);
 	return (ret < 0) ? ret : 1;
 }
@@ -1501,8 +1540,12 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	if (how & FLUSH_SYNC)
-		rpc_wait_for_completion_task(task);
+	if (how & FLUSH_SYNC) {
+		if (how & FLUSH_COND_CONNECTED)
+			__rpc_wait_for_completion_task(task, rpc_wait_bit_connected);
+		else
+			rpc_wait_for_completion_task(task);
+	}
 	rpc_put_task(task);
 	return 0;
 }
@@ -1678,8 +1721,15 @@ int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
 	struct nfs_commit_info cinfo;
-	int may_wait = how & FLUSH_SYNC;
+	int may_wait = how & (FLUSH_SYNC | FLUSH_COND_CONNECTED);
 	int res;
+	int error;
+	unsigned long commit_start;
+
+	if (how & FLUSH_COND_CONNECTED) {
+		commit_start = jiffies;
+		current->journal_info = &commit_start;
+	}
 
 	res = nfs_commit_set_lock(NFS_I(inode), may_wait);
 	if (res <= 0)
@@ -1687,21 +1737,24 @@ int nfs_commit_inode(struct inode *inode, int how)
 	nfs_init_cinfo_from_inode(&cinfo, inode);
 	res = nfs_scan_commit(inode, &head, &cinfo);
 	if (res) {
-		int error;
 
 		error = nfs_generic_commit_list(inode, &head, how, &cinfo);
 		if (error < 0)
-			return error;
+			goto error;
 		if (!may_wait)
 			goto out_mark_dirty;
 		error = wait_on_bit(&NFS_I(inode)->flags,
 				NFS_INO_COMMIT,
-				nfs_wait_bit_killable,
+				(how & FLUSH_COND_CONNECTED) ?
+				   nfs_wait_bit_connected : nfs_wait_bit_killable,
 				TASK_KILLABLE);
+		if ((how & FLUSH_COND_CONNECTED) && error == -EAGAIN)
+			goto out_mark_dirty;
 		if (error < 0)
-			return error;
+			goto error;
 	} else
 		nfs_commit_clear_lock(NFS_I(inode));
+	current->journal_info = NULL;
 	return res;
 	/* Note: If we exit without ensuring that the commit is complete,
 	 * we must mark the inode as dirty. Otherwise, future calls to
@@ -1709,8 +1762,12 @@ int nfs_commit_inode(struct inode *inode, int how)
 	 * that the data is on the disk.
 	 */
 out_mark_dirty:
+	current->journal_info = NULL;
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return res;
+error:
+	current->journal_info = NULL;
+	return error;
 }
 
 static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 7fd81b8c4897..1a32fe0c1255 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -193,6 +193,16 @@ static inline long freezable_schedule_timeout(long timeout)
 	return __retval;
 }
 
+/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
+static inline long freezable_schedule_timeout_unsafe(long timeout)
+{
+	long __retval;
+	freezer_do_not_count();
+	__retval = schedule_timeout(timeout);
+	freezer_count_unsafe();
+	return __retval;
+}
+
 /*
  * Like schedule_timeout_interruptible(), but should not block the freezer.  Do not
  * call this with locks held.
diff --git a/include/uapi/linux/nfs_fs.h b/include/uapi/linux/nfs_fs.h
index 49142287999c..896b8d976896 100644
--- a/include/uapi/linux/nfs_fs.h
+++ b/include/uapi/linux/nfs_fs.h
@@ -35,6 +35,9 @@
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
 #define FLUSH_COND_STABLE	32	/* conditional stable write - only stable
 					 * if everything fits in one RPC */
+#define FLUSH_COND_CONNECTED   64	/* Don't wait for COMMIT unless client
+					 * is connected to a remote host.
+					 */
 
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
