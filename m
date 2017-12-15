Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B944B6B0276
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:11:15 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q3so7050907pgv.16
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:11:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q4si4633029pgf.448.2017.12.15.06.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 06:11:14 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 17/17] memremap: merge find_dev_pagemap into get_dev_pagemap
Date: Fri, 15 Dec 2017 15:09:47 +0100
Message-Id: <20171215140947.26075-18-hch@lst.de>
In-Reply-To: <20171215140947.26075-1-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is only one caller of the trivial function find_dev_pagemap left,
so just merge it into the caller.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/memremap.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index fd0e7c44e6bd..c04000361664 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -306,14 +306,6 @@ static void devm_memremap_pages_release(void *data)
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
@@ -466,7 +458,7 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 
 	/* fall back to slow path lookup */
 	rcu_read_lock();
-	pgmap = find_dev_pagemap(phys);
+	pgmap = radix_tree_lookup(&pgmap_radix, PHYS_PFN(phys));
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
