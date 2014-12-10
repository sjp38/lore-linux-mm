Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5C63B6B006C
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:46:39 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so1719085pde.29
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:39 -0800 (PST)
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com. [209.85.220.44])
        by mx.google.com with ESMTPS id ji4si4486202pbb.42.2014.12.09.17.46.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:46:38 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so1731446pad.31
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:37 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 1/7] direct-io: don't dirty ITER_BVEC pages on read
Date: Tue,  9 Dec 2014 17:45:42 -0800
Message-Id: <5db70228c7a288ffb8f87a3e4995cf7584e6a56c.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>, Ming Lei <ming.lei@canonical.com>

Reads through the iov_iter infrastructure for kernel pages shouldn't be
dirtied by the direct I/O code.

This is based on Dave Kleikamp's and Ming Lei's previously posted
patches.

Cc: Ming Lei <ming.lei@canonical.com>
Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>
Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/direct-io.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index e181b6b..e542ce4 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -120,6 +120,7 @@ struct dio {
 	spinlock_t bio_lock;		/* protects BIO fields below */
 	int page_errors;		/* errno from get_user_pages() */
 	int is_async;			/* is IO async ? */
+	int should_dirty;		/* should we mark read pages dirty? */
 	bool defer_completion;		/* defer AIO completion to workqueue? */
 	int io_error;			/* IO error in completion path */
 	unsigned long refcount;		/* direct_io_worker() and bios */
@@ -392,7 +393,7 @@ static inline void dio_bio_submit(struct dio *dio, struct dio_submit *sdio)
 	dio->refcount++;
 	spin_unlock_irqrestore(&dio->bio_lock, flags);
 
-	if (dio->is_async && dio->rw == READ)
+	if (dio->is_async && dio->rw == READ && dio->should_dirty)
 		bio_set_pages_dirty(bio);
 
 	if (sdio->submit_io)
@@ -463,13 +464,13 @@ static int dio_bio_complete(struct dio *dio, struct bio *bio)
 	if (!uptodate)
 		dio->io_error = -EIO;
 
-	if (dio->is_async && dio->rw == READ) {
+	if (dio->is_async && dio->rw == READ && dio->should_dirty) {
 		bio_check_pages_dirty(bio);	/* transfers ownership */
 	} else {
 		bio_for_each_segment_all(bvec, bio, i) {
 			struct page *page = bvec->bv_page;
 
-			if (dio->rw == READ && !PageCompound(page))
+			if (dio->rw == READ && !PageCompound(page) && dio->should_dirty)
 				set_page_dirty_lock(page);
 			page_cache_release(page);
 		}
@@ -1177,6 +1178,7 @@ do_blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 
 	dio->inode = inode;
 	dio->rw = rw;
+	dio->should_dirty = !(iter->type & ITER_BVEC);
 
 	/*
 	 * For AIO O_(D)SYNC writes we need to defer completions to a workqueue
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
