Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 133126B02D1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:40:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j16so14825155pfk.4
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:40:26 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50136.outbound.protection.outlook.com. [40.107.5.136])
        by mx.google.com with ESMTPS id m1si19631188plb.2.2017.04.24.09.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 09:40:24 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 1/4] fs: fix data invalidation in the cleancache during direct IO
Date: Mon, 24 Apr 2017 19:41:32 +0300
Message-ID: <20170424164135.22350-2-aryabinin@virtuozzo.com>
In-Reply-To: <20170424164135.22350-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, stable@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Nikolay Borisov <n.borisov.lkml@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Some direct IO write fs hooks call invalidate_inode_pages2[_range]()
conditionally iff mapping->nrpages is not zero. This can't be right,
because invalidate_inode_pages2[_ragne]() also invalidate data in
the cleancache via cleancache_invalidate_inode() call.
So if page cache is empty but there is some data in the cleancache,
buffered read after direct IO write would get stale data from
the cleancache.

Also it doesn't feel right to check only for ->nrpages because
invalidate_inode_pages2[_range] invalidates exceptional entries as well.

Fix this by calling invalidate_inode_pages2[_range]() regardless of nrpages
state.

Note: nfs,cifs,9p doesn't need similar fix because the never call
cleancache_get_page() (nor directly, nor via mpage_readpage[s]()), so they
are not affected by this bug.

Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: <stable@vger.kernel.org>
---
 fs/iomap.c   | 18 ++++++++----------
 mm/filemap.c | 26 +++++++++++---------------
 2 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index cdeed39..f6a6013 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -881,16 +881,14 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
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
-				start >> PAGE_SHIFT, end >> PAGE_SHIFT);
-		WARN_ON_ONCE(ret);
-		ret = 0;
-	}
+	ret = invalidate_inode_pages2_range(mapping,
+			start >> PAGE_SHIFT, end >> PAGE_SHIFT);
+	WARN_ON_ONCE(ret);
+	ret = 0;
 
 	inode_dio_begin(inode);
 
@@ -945,7 +943,7 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
 	 * one is a pretty crazy thing to do, so we don't support it 100%.  If
 	 * this invalidation fails, tough, the write still worked...
 	 */
-	if (iov_iter_rw(iter) == WRITE && mapping->nrpages) {
+	if (iov_iter_rw(iter) == WRITE) {
 		int err = invalidate_inode_pages2_range(mapping,
 				start >> PAGE_SHIFT, end >> PAGE_SHIFT);
 		WARN_ON_ONCE(err);
diff --git a/mm/filemap.c b/mm/filemap.c
index 9eab40e..b7b973b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2720,18 +2720,16 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from)
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
 
 	written = mapping->a_ops->direct_IO(iocb, from);
@@ -2744,10 +2742,8 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from)
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
