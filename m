Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8ECF6B0607
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:48:57 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f10-v6so5330795pln.21
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:48:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v5-v6si7424708pfe.63.2018.05.18.09.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:48:56 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 08/34] mm: split ->readpages calls to avoid non-contiguous pages lists
Date: Fri, 18 May 2018 18:48:04 +0200
Message-Id: <20180518164830.1552-9-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

That way file systems don't have to go spotting for non-contiguous pages
and work around them.  It also kicks off I/O earlier, allowing it to
finish earlier and reduce latency.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/readahead.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index fa4d4b767130..044ab0c137cc 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
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
