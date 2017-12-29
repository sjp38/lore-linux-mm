Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC4D16B0275
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:55:32 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t65so29877680pfe.22
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:55:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z100si28143451plh.172.2017.12.28.23.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:55:31 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 17/17] memremap: merge find_dev_pagemap into get_dev_pagemap
Date: Fri, 29 Dec 2017 08:54:06 +0100
Message-Id: <20171229075406.1936-18-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is only one caller of the trivial function find_dev_pagemap left,
so just merge it into the caller.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index a9a948cd3d7f..ada31b0d76d4 100644
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
