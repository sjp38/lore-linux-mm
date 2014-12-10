Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 86DB06B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:46:41 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so1741883pac.11
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:41 -0800 (PST)
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com. [209.85.220.48])
        by mx.google.com with ESMTPS id dz5si4310474pbb.176.2014.12.09.17.46.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:46:40 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1744128pab.7
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:39 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 2/7] nfs: don't dirty ITER_BVEC pages read through direct I/O
Date: Tue,  9 Dec 2014 17:45:43 -0800
Message-Id: <55ee5dcf11066baf17b5d8aa485fdcd7be78dec0.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

As with the generic blockdev code, kernel pages shouldn't be dirtied by
the direct I/O path.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/nfs/direct.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 10bf072..a67fa2c 100644
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
