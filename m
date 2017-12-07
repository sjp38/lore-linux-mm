Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C91F6B026F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:09:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 3so5892925pfo.1
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:09:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r20si4246903pfb.51.2017.12.07.07.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:50 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/14] memremap: simplify duplicate region handling in devm_memremap_pages
Date: Thu,  7 Dec 2017 07:08:37 -0800
Message-Id: <20171207150840.28409-12-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

__radix_tree_insert already checks for duplicates and returns -EEXIST in
that case, so remove the duplicate (and racy) duplicates check.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/memremap.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index f4b198304e3b..4301fb657150 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -379,17 +379,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	align_end = align_start + align_size - 1;
 
 	foreach_order_pgoff(res, order, pgoff) {
-		struct dev_pagemap *dup;
-
-		rcu_read_lock();
-		dup = find_dev_pagemap(res->start + PFN_PHYS(pgoff));
-		rcu_read_unlock();
-		if (dup) {
-			dev_err(dev, "%s: %pr collides with mapping for %s\n",
-					__func__, res, dev_name(dup->dev));
-			error = -EBUSY;
-			break;
-		}
 		error = __radix_tree_insert(&pgmap_radix,
 				PHYS_PFN(res->start) + pgoff, order, pgmap);
 		if (error) {
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
