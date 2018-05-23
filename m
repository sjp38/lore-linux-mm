Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB9F86B0269
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:44:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id h15-v6so2448536pgv.7
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:44:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l33-v6si18387183pld.440.2018.05.23.07.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:44:21 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/34] mm: give the 'ret' variable a better name __do_page_cache_readahead
Date: Wed, 23 May 2018 16:43:29 +0200
Message-Id: <20180523144357.18985-7-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

It counts the number of pages acted on, so name it nr_pages to make that
obvious.

Signed-off-by: Christoph Hellwig <hch@lst.de>
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
