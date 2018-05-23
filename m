Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79CA86B026A
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:44:25 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g92-v6so14255576plg.6
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:44:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o11-v6si8897836pgp.331.2018.05.23.07.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:44:24 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/34] mm: return an unsigned int from __do_page_cache_readahead
Date: Wed, 23 May 2018 16:43:30 +0200
Message-Id: <20180523144357.18985-8-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

We never return an error, so switch to returning an unsigned int.  Most
callers already did implicit casts to an unsigned type, and the one that
didn't can be simplified now.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/internal.h  |  2 +-
 mm/readahead.c | 15 +++++----------
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..954003ac766a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -53,7 +53,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 			     unsigned long addr, unsigned long end,
 			     struct zap_details *details);
 
-extern int __do_page_cache_readahead(struct address_space *mapping,
+extern unsigned int __do_page_cache_readahead(struct address_space *mapping,
 		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
 		unsigned long lookahead_size);
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 16d0cb1e2616..fa4d4b767130 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -147,16 +147,16 @@ static int read_pages(struct address_space *mapping, struct file *filp,
  *
  * Returns the number of pages requested, or the maximum amount of I/O allowed.
  */
-int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
-			pgoff_t offset, unsigned long nr_to_read,
-			unsigned long lookahead_size)
+unsigned int __do_page_cache_readahead(struct address_space *mapping,
+		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
+		unsigned long lookahead_size)
 {
 	struct inode *inode = mapping->host;
 	struct page *page;
 	unsigned long end_index;	/* The last page we want to read */
 	LIST_HEAD(page_pool);
 	int page_idx;
-	int nr_pages = 0;
+	unsigned int nr_pages = 0;
 	loff_t isize = i_size_read(inode);
 	gfp_t gfp_mask = readahead_gfp_mask(mapping);
 
@@ -223,16 +223,11 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	max_pages = max_t(unsigned long, bdi->io_pages, ra->ra_pages);
 	nr_to_read = min(nr_to_read, max_pages);
 	while (nr_to_read) {
-		int err;
-
 		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_SIZE;
 
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
-		err = __do_page_cache_readahead(mapping, filp,
-						offset, this_chunk, 0);
-		if (err < 0)
-			return err;
+		__do_page_cache_readahead(mapping, filp, offset, this_chunk, 0);
 
 		offset += this_chunk;
 		nr_to_read -= this_chunk;
-- 
2.17.0
