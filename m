Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CFD86B026D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 12:49:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w14-v6so17386566qkw.2
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 09:49:16 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id y74-v6si1741573qkg.315.2018.08.07.09.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 09:49:15 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v3 08/10] dmapool: improve accuracy of debug statistics
Message-ID: <cbe2fb30-54b3-663e-4e30-448353723b8f@cybernetics.com>
Date: Tue, 7 Aug 2018 12:49:13 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

The "total number of blocks in pool" debug statistic currently does not
take the boundary value into account, so it diverges from the "total
number of blocks in use" statistic when a boundary is in effect.  Add a
calculation for the number of blocks per allocation that takes the
boundary into account, and use it to replace the inaccurate calculation.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

This was split off from "dmapool: reduce footprint in struct page" in v2.

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
 
