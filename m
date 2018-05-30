Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1486B0269
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:58:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e1-v6so1885094pgp.20
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:58:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o9-v6si27215048pgp.508.2018.05.30.02.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 02:58:34 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/13] mm: split ->readpages calls to avoid non-contiguous pages lists
Date: Wed, 30 May 2018 11:58:04 +0200
Message-Id: <20180530095813.31245-5-hch@lst.de>
In-Reply-To: <20180530095813.31245-1-hch@lst.de>
References: <20180530095813.31245-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

That way file systems don't have to go spotting for non-contiguous pages
and work around them.  It also kicks off I/O earlier, allowing it to
finish earlier and reduce latency.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 mm/readahead.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index fa4d4b767130..e273f0de3376 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -140,8 +140,8 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 }
 
 /*
- * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates all
- * the pages first, then submits them all for I/O. This avoids the very bad
+ * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates
+ * the pages first, then submits them for I/O. This avoids the very bad
  * behaviour which would occur if page allocations are causing VM writeback.
  * We really don't want to intermingle reads and writes like that.
  *
@@ -177,8 +177,18 @@ unsigned int __do_page_cache_readahead(struct address_space *mapping,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->i_pages, page_offset);
 		rcu_read_unlock();
-		if (page && !radix_tree_exceptional_entry(page))
+		if (page && !radix_tree_exceptional_entry(page)) {
+			/*
+			 * Page already present?  Kick off the current batch of
+			 * contiguous pages before continuing with the next
+			 * batch.
+			 */
+			if (nr_pages)
+				read_pages(mapping, filp, &page_pool, nr_pages,
+						gfp_mask);
+			nr_pages = 0;
 			continue;
+		}
 
 		page = __page_cache_alloc(gfp_mask);
 		if (!page)
-- 
2.17.0
