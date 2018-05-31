Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4F8F6B000A
	for <linux-mm@kvack.org>; Thu, 31 May 2018 14:06:30 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u7-v6so13776971plq.3
        for <linux-mm@kvack.org>; Thu, 31 May 2018 11:06:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o87-v6si13283928pfi.295.2018.05.31.11.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 May 2018 11:06:29 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/13] mm: give the 'ret' variable a better name __do_page_cache_readahead
Date: Thu, 31 May 2018 20:06:03 +0200
Message-Id: <20180531180614.21506-3-hch@lst.de>
In-Reply-To: <20180531180614.21506-1-hch@lst.de>
References: <20180531180614.21506-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

It counts the number of pages acted on, so name it nr_pages to make that
obvious.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 mm/readahead.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 539bbb6c1fad..16d0cb1e2616 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -156,7 +156,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	unsigned long end_index;	/* The last page we want to read */
 	LIST_HEAD(page_pool);
 	int page_idx;
-	int ret = 0;
+	int nr_pages = 0;
 	loff_t isize = i_size_read(inode);
 	gfp_t gfp_mask = readahead_gfp_mask(mapping);
 
@@ -187,7 +187,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		list_add(&page->lru, &page_pool);
 		if (page_idx == nr_to_read - lookahead_size)
 			SetPageReadahead(page);
-		ret++;
+		nr_pages++;
 	}
 
 	/*
@@ -195,11 +195,11 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	 * uptodate then the caller will launch readpage again, and
 	 * will then handle the error.
 	 */
-	if (ret)
-		read_pages(mapping, filp, &page_pool, ret, gfp_mask);
+	if (nr_pages)
+		read_pages(mapping, filp, &page_pool, nr_pages, gfp_mask);
 	BUG_ON(!list_empty(&page_pool));
 out:
-	return ret;
+	return nr_pages;
 }
 
 /*
-- 
2.17.0
