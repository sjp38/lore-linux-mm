Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EDC8C6B0073
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 00:27:38 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so10490081pab.18
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:38 -0800 (PST)
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com. [209.85.192.176])
        by mx.google.com with ESMTPS id qb8si5692573pdb.75.2014.12.14.21.27.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 21:27:37 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id r10so8961077pdi.35
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:36 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 6/8] nfs: don't dirty ITER_BVEC pages read through direct I/O
Date: Sun, 14 Dec 2014 21:27:00 -0800
Message-Id: <e5240b33c30d147588d0cdd285d8d95463b3de18.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

As with the generic blockdev code, kernel pages shouldn't be dirtied by
the direct I/O path.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/nfs/direct.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9402b96..a502b3f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -88,6 +88,7 @@ struct nfs_direct_req {
 	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
 	struct work_struct	work;
 	int			flags;
+	int			should_dirty;	/* should we mark read pages dirty? */
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
 	struct nfs_writeverf	verf;		/* unstable write verifier */
@@ -370,7 +371,8 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
 
-		if (!PageCompound(page) && bytes < hdr->good_bytes)
+		if (!PageCompound(page) && bytes < hdr->good_bytes &&
+		    dreq->should_dirty)
 			set_page_dirty(page);
 		bytes += req->wb_bytes;
 		nfs_list_remove_request(req);
@@ -542,6 +544,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 	dreq->inode = inode;
 	dreq->bytes_left = count;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
+	dreq->should_dirty = !(iter->type & ITER_BVEC);
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
 		result = PTR_ERR(l_ctx);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
