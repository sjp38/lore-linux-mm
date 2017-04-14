Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C99BF6B0390
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 10:08:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q25so47003868pfg.6
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 07:08:00 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0098.outbound.protection.outlook.com. [104.47.2.98])
        by mx.google.com with ESMTPS id y18si2151114pgf.123.2017.04.14.07.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Apr 2017 07:07:59 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/4] fs: fix data invalidation in the cleancache during direct IO
Date: Fri, 14 Apr 2017 17:07:50 +0300
Message-ID: <20170414140753.16108-2-aryabinin@virtuozzo.com>
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

Some direct write fs hooks call invalidate_inode_pages2[_range]()
conditionally iff mapping->nrpages is not zero. If page cache is empty,
buffered read following after direct IO write would get stale data from
the cleancache.

Also it doesn't feel right to check only for ->nrpages because
invalidate_inode_pages2[_range] invalidates exceptional entries as well.

Fix this by calling invalidate_inode_pages2[_range]() regardless of nrpages
state.

Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 fs/9p/vfs_file.c |  2 +-
 fs/cifs/inode.c  |  2 +-
 fs/dax.c         |  2 +-
 fs/iomap.c       | 16 +++++++---------
 fs/nfs/direct.c  |  6 ++----
 fs/nfs/inode.c   |  8 +++++---
 mm/filemap.c     | 26 +++++++++++---------------
 7 files changed, 28 insertions(+), 34 deletions(-)

diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index 3de3b4a8..786d0de 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -423,7 +423,7 @@ v9fs_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 		unsigned long pg_start, pg_end;
 		pg_start = origin >> PAGE_SHIFT;
 		pg_end = (origin + retval - 1) >> PAGE_SHIFT;
-		if (inode->i_mapping && inode->i_mapping->nrpages)
+		if (inode->i_mapping)
 			invalidate_inode_pages2_range(inode->i_mapping,
 						      pg_start, pg_end);
 		iocb->ki_pos += retval;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index c3b2fa0..6539fa3 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1857,7 +1857,7 @@ cifs_invalidate_mapping(struct inode *inode)
 {
 	int rc = 0;
 
-	if (inode->i_mapping && inode->i_mapping->nrpages != 0) {
+	if (inode->i_mapping) {
 		rc = invalidate_inode_pages2(inode->i_mapping);
 		if (rc)
 			cifs_dbg(VFS, "%s: could not invalidate inode %p\n",
diff --git a/fs/dax.c b/fs/dax.c
index 2e382fe..1e8cca0 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1047,7 +1047,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 	 * into page tables. We have to tear down these mappings so that data
 	 * written by write(2) is visible in mmap.
 	 */
-	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
+	if ((iomap->flags & IOMAP_F_NEW)) {
 		invalidate_inode_pages2_range(inode->i_mapping,
 					      pos >> PAGE_SHIFT,
 					      (end - 1) >> PAGE_SHIFT);
diff --git a/fs/iomap.c b/fs/iomap.c
index 0b457ff..7e1f947 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -880,16 +880,14 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
 		flags |= IOMAP_WRITE;
 	}
 
-	if (mapping->nrpages) {
-		ret = filemap_write_and_wait_range(mapping, start, end);
-		if (ret)
-			goto out_free_dio;
+	ret = filemap_write_and_wait_range(mapping, start, end);
+	if (ret)
+		goto out_free_dio;
 
-		ret = invalidate_inode_pages2_range(mapping,
+	ret = invalidate_inode_pages2_range(mapping,
 				start >> PAGE_SHIFT, end >> PAGE_SHIFT);
-		WARN_ON_ONCE(ret);
-		ret = 0;
-	}
+	WARN_ON_ONCE(ret);
+	ret = 0;
 
 	inode_dio_begin(inode);
 
@@ -944,7 +942,7 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
 	 * one is a pretty crazy thing to do, so we don't support it 100%.  If
 	 * this invalidation fails, tough, the write still worked...
 	 */
-	if (iov_iter_rw(iter) == WRITE && mapping->nrpages) {
+	if (iov_iter_rw(iter) == WRITE) {
 		int err = invalidate_inode_pages2_range(mapping,
 				start >> PAGE_SHIFT, end >> PAGE_SHIFT);
 		WARN_ON_ONCE(err);
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index aab32fc..183ab4d 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -1024,10 +1024,8 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 
 	result = nfs_direct_write_schedule_iovec(dreq, iter, pos);
 
-	if (mapping->nrpages) {
-		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_SHIFT, end);
-	}
+	invalidate_inode_pages2_range(mapping,
+				pos >> PAGE_SHIFT, end);
 
 	nfs_end_io_direct(inode);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f489a5a..b727ec8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1118,10 +1118,12 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 			if (ret < 0)
 				return ret;
 		}
-		ret = invalidate_inode_pages2(mapping);
-		if (ret < 0)
-			return ret;
 	}
+
+	ret = invalidate_inode_pages2(mapping);
+	if (ret < 0)
+		return ret;
+
 	if (S_ISDIR(inode->i_mode)) {
 		spin_lock(&inode->i_lock);
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
diff --git a/mm/filemap.c b/mm/filemap.c
index e9e5f7b..d233d59 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2721,18 +2721,16 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from)
 	 * about to write.  We do this *before* the write so that we can return
 	 * without clobbering -EIOCBQUEUED from ->direct_IO().
 	 */
-	if (mapping->nrpages) {
-		written = invalidate_inode_pages2_range(mapping,
+	written = invalidate_inode_pages2_range(mapping,
 					pos >> PAGE_SHIFT, end);
-		/*
-		 * If a page can not be invalidated, return 0 to fall back
-		 * to buffered write.
-		 */
-		if (written) {
-			if (written == -EBUSY)
-				return 0;
-			goto out;
-		}
+	/*
+	 * If a page can not be invalidated, return 0 to fall back
+	 * to buffered write.
+	 */
+	if (written) {
+		if (written == -EBUSY)
+			return 0;
+		goto out;
 	}
 
 	data = *from;
@@ -2746,10 +2744,8 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from)
 	 * so we don't support it 100%.  If this invalidation
 	 * fails, tough, the write still worked...
 	 */
-	if (mapping->nrpages) {
-		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_SHIFT, end);
-	}
+	invalidate_inode_pages2_range(mapping,
+				pos >> PAGE_SHIFT, end);
 
 	if (written > 0) {
 		pos += written;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
