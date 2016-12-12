Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCBB6B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:47:23 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o3so26995443wjo.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:47:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dw13si45147098wjb.44.2016.12.12.08.47.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 08:47:22 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/6] dax: Avoid page invalidation races and unnecessary radix tree traversals
Date: Mon, 12 Dec 2016 17:47:05 +0100
Message-Id: <20161212164708.23244-4-jack@suse.cz>
In-Reply-To: <20161212164708.23244-1-jack@suse.cz>
References: <20161212164708.23244-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

Currently dax_iomap_rw() takes care of invalidating page tables and
evicting hole pages from the radix tree when write(2) to the file
happens. This invalidation is only necessary when there is some block
allocation resulting from write(2). Furthermore in current place the
invalidation is racy wrt page fault instantiating a hole page just after
we have invalidated it.

So perform the page invalidation inside dax_iomap_actor() where we can
do it only when really necessary and after blocks have been allocated so
nobody will be instantiating new hole pages anymore.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 71863f0d51f7..97858dd5dab6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -986,6 +986,17 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 	if (WARN_ON_ONCE(iomap->type != IOMAP_MAPPED))
 		return -EIO;
 
+	/*
+	 * Write can allocate block for an area which has a hole page mapped
+	 * into page tables. We have to tear down these mappings so that data
+	 * written by write(2) is visible in mmap.
+	 */
+	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
+		invalidate_inode_pages2_range(inode->i_mapping,
+					      pos >> PAGE_SHIFT,
+					      (end - 1) >> PAGE_SHIFT);
+	}
+
 	while (pos < end) {
 		unsigned offset = pos & (PAGE_SIZE - 1);
 		struct blk_dax_ctl dax = { 0 };
@@ -1044,23 +1055,6 @@ dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 	if (iov_iter_rw(iter) == WRITE)
 		flags |= IOMAP_WRITE;
 
-	/*
-	 * Yes, even DAX files can have page cache attached to them:  A zeroed
-	 * page is inserted into the pagecache when we have to serve a write
-	 * fault on a hole.  It should never be dirtied and can simply be
-	 * dropped from the pagecache once we get real data for the page.
-	 *
-	 * XXX: This is racy against mmap, and there's nothing we can do about
-	 * it. We'll eventually need to shift this down even further so that
-	 * we can check if we allocated blocks over a hole first.
-	 */
-	if (mapping->nrpages) {
-		ret = invalidate_inode_pages2_range(mapping,
-				pos >> PAGE_SHIFT,
-				(pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT);
-		WARN_ON_ONCE(ret);
-	}
-
 	while (iov_iter_count(iter)) {
 		ret = iomap_apply(inode, pos, iov_iter_count(iter), flags, ops,
 				iter, dax_iomap_actor);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
