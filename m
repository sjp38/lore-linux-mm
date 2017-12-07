Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52F256B026A
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so5873463pfg.19
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n11si1379661plp.730.2017.12.07.07.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:52 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/14] memremap: remove find_dev_pagemap
Date: Thu,  7 Dec 2017 07:08:38 -0800
Message-Id: <20171207150840.28409-13-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

We already have the proper pfn value in both callers, so just open code
the function there.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/memremap.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 4301fb657150..ba5068b9ce07 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -316,14 +316,6 @@ static void devm_memremap_pages_release(void *data)
 		      "%s: failed to free all reserved pages\n", __func__);
 }
 
-/* assumes rcu_read_lock() held at entry */
-static struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
-{
-	WARN_ON_ONCE(!rcu_read_lock_held());
-
-	return radix_tree_lookup(&pgmap_radix, PHYS_PFN(phys));
-}
-
 /**
  * devm_memremap_pages - remap and provide memmap backing for the given resource
  * @dev: hosting device for @res
@@ -496,7 +488,7 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 	 * the memmap.
 	 */
 	rcu_read_lock();
-	pgmap = find_dev_pagemap(__pfn_to_phys(page_to_pfn(page)));
+	pgmap = radix_tree_lookup(&pgmap_radix, page_to_pfn(page));
 	rcu_read_unlock();
 
 	if (!pgmap || !pgmap->altmap_valid)
@@ -515,12 +507,12 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap)
 {
-	resource_size_t phys = PFN_PHYS(pfn);
-
 	/*
 	 * In the cached case we're already holding a live reference.
 	 */
 	if (pgmap) {
+		resource_size_t phys = PFN_PHYS(pfn);
+
 		if (phys >= pgmap->res.start && phys <= pgmap->res.end)
 			return pgmap;
 		put_dev_pagemap(pgmap);
@@ -528,7 +520,7 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 
 	/* fall back to slow path lookup */
 	rcu_read_lock();
-	pgmap = find_dev_pagemap(phys);
+	pgmap = radix_tree_lookup(&pgmap_radix, pfn);
 	if (pgmap && !percpu_ref_tryget_live(pgmap->ref))
 		pgmap = NULL;
 	rcu_read_unlock();
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
