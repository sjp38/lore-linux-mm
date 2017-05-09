Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB803280724
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:50:56 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u75so1507219qka.13
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:50:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k28si279331qtf.298.2017.05.09.08.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:50:55 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 24/27][RFC] nfs: convert to new errseq_t based error tracking for writeback errors
Date: Tue,  9 May 2017 11:49:27 -0400
Message-Id: <20170509154930.29524-25-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

Drop the ERROR_WRITE flag and convert the error field in the context to
a errseq_t. Add a new wb_err_cursor to track the reporting of the
errseq_t. In principle, we could use the f_wb_err field in struct file
for that, but that's problematic with the stock reporting in call_fsync.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

---
 fs/nfs/file.c          | 19 +++++++++++--------
 fs/nfs/inode.c         |  5 +++--
 fs/nfs/write.c         |  2 +-
 include/linux/nfs_fs.h |  3 ++-
 4 files changed, 17 insertions(+), 12 deletions(-)

I did this on a lark to see how it would be, but I don't think this is
really better than what's there already. There may be a better way to
provide the right semantics without using an errseq_t here.

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 668213984d68..fd4d2b381d4b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -212,21 +212,24 @@ nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode *inode = file_inode(file);
-	int have_error, do_resend, status;
-	int ret = 0;
+	int do_resend, status;
+	int ret;
 
 	dprintk("NFS: fsync file(%pD2) datasync %d\n", file, datasync);
 
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	do_resend = test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
-	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
+	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	status = nfs_commit_inode(inode, FLUSH_SYNC);
-	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
-	if (have_error) {
-		ret = xchg(&ctx->error, 0);
-		if (ret)
-			goto out;
+	ret = errseq_check(&ctx->wb_err, READ_ONCE(ctx->wb_err_cursor));
+	if (ret) {
+		/* Use f_lock to serialize changes to wb_err_cursor */
+		spin_lock(&file->f_lock);
+		ret = errseq_check_and_advance(&ctx->wb_err, &ctx->wb_err_cursor);
+		spin_unlock(&file->f_lock);
 	}
+	if (ret)
+		goto out;
 	if (status < 0) {
 		ret = status;
 		goto out;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f489a5a71bd5..ca85f6b39e3b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -869,7 +869,8 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
 	ctx->state = NULL;
 	ctx->mode = f_mode;
 	ctx->flags = 0;
-	ctx->error = 0;
+	ctx->wb_err = 0;
+	ctx->wb_err_cursor = 0;
 	ctx->flock_owner = (fl_owner_t)filp;
 	nfs_init_lock_context(&ctx->lock_context);
 	ctx->lock_context.open_context = ctx;
@@ -978,7 +979,7 @@ void nfs_file_clear_open_context(struct file *filp)
 		 * We fatal error on write before. Try to writeback
 		 * every page again.
 		 */
-		if (ctx->error < 0)
+		if (errseq_check(&ctx->wb_err, ctx->wb_err_cursor))
 			invalidate_inode_pages2(inode->i_mapping);
 		filp->private_data = NULL;
 		spin_lock(&inode->i_lock);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index abb2c8a3be42..95a5b4ac6714 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -94,7 +94,7 @@ static void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
-	ctx->error = error;
+	errseq_set(&ctx->wb_err, error);
 	smp_wmb();
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 287f34161086..336adf1a38f7 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -76,7 +76,8 @@ struct nfs_open_context {
 #define NFS_CONTEXT_ERROR_WRITE		(0)
 #define NFS_CONTEXT_RESEND_WRITES	(1)
 #define NFS_CONTEXT_BAD			(2)
-	int error;
+	errseq_t wb_err;		/* where wb errors are tracked */
+	errseq_t wb_err_cursor;		/* reporting cursor */
 
 	struct list_head list;
 	struct nfs4_threshold	*mdsthreshold;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
