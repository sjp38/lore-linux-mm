Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE4B6B02A5
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:46:01 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f81-v6so24750722qkb.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:46:01 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id r41si497493qtj.56.2018.11.12.07.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:46:00 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 8/9] dmapool: improve accuracy of debug statistics
Message-ID: <bb0ee76c-78ac-b75b-b32d-8c94d881f7d6@cybernetics.com>
Date: Mon, 12 Nov 2018 10:45:58 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: linux-scsi@vger.kernel.org

The "total number of blocks in pool" debug statistic currently does not
take the boundary value into account, so it diverges from the "total
number of blocks in use" statistic when a boundary is in effect.  Add a
calculation for the number of blocks per allocation that takes the
boundary into account, and use it to replace the inaccurate calculation.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

This depends on patch #1 "dmapool: fix boundary comparison" for the
calculated blks_per_alloc value to be correct.

The added blks_per_alloc value will also be used in the next patch.

--- linux/mm/dmapool.c.orig	2018-08-06 17:48:54.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-06 17:52:53.000000000 -0400
@@ -61,6 +61,7 @@ struct dma_pool {		/* the pool */
 	struct device *dev;
 	unsigned int allocation;
 	unsigned int boundary;
+	unsigned int blks_per_alloc;
 	char name[32];
 	struct list_head pools;
 };
@@ -105,8 +106,7 @@ show_pools(struct device *dev, struct de
 		/* per-pool info, no real statistics yet */
 		temp = scnprintf(next, size, "%-16s %4zu %4zu %4u %2u\n",
 				 pool->name, blocks,
-				 (size_t) pages *
-				 (pool->allocation / pool->size),
+				 (size_t) pages * pool->blks_per_alloc,
 				 pool->size, pages);
 		size -= temp;
 		next += temp;
@@ -182,6 +182,9 @@ struct dma_pool *dma_pool_create(const c
 	retval->size = size;
 	retval->boundary = boundary;
 	retval->allocation = allocation;
+	retval->blks_per_alloc =
+		(allocation / boundary) * (boundary / size) +
+		(allocation % boundary) / size;
 
 	INIT_LIST_HEAD(&retval->pools);
 
