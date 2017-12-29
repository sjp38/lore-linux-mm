Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8448F6B026D
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:55:15 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 73so29893068pfz.11
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:55:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id bd12si27783236plb.694.2017.12.28.23.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:55:14 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/17] mm: optimize dev_pagemap reference counting around get_dev_pagemap
Date: Fri, 29 Dec 2017 08:54:01 +0100
Message-Id: <20171229075406.1936-13-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Change the calling convention so that get_dev_pagemap always consumes the
previous reference instead of doing this using an explicit earlier call to
put_dev_pagemap in the callers.

The callers will still need to put the final reference after finishing the
loop over the pages.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c | 17 +++++++++--------
 mm/gup.c          |  7 +++++--
 2 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 3df6cd4ffb40..891c77487a6a 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -507,22 +507,23 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
  * @pfn: page frame number to lookup page_map
  * @pgmap: optional known pgmap that already has a reference
  *
- * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
- * same mapping.
+ * If @pgmap is non-NULL and covers @pfn it will be returned as-is.  If @pgmap
+ * is non-NULL but does not cover @pfn the reference to it will be released.
  */
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap)
 {
-	const struct resource *res = pgmap ? pgmap->res : NULL;
 	resource_size_t phys = PFN_PHYS(pfn);
 
 	/*
-	 * In the cached case we're already holding a live reference so
-	 * we can simply do a blind increment
+	 * In the cached case we're already holding a live reference.
 	 */
-	if (res && phys >= res->start && phys <= res->end) {
-		percpu_ref_get(pgmap->ref);
-		return pgmap;
+	if (pgmap) {
+		const struct resource *res = pgmap ? pgmap->res : NULL;
+
+		if (res && phys >= res->start && phys <= res->end)
+			return pgmap;
+		put_dev_pagemap(pgmap);
 	}
 
 	/* fall back to slow path lookup */
diff --git a/mm/gup.c b/mm/gup.c
index e0d82b6706d7..3affe7544b0c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1410,7 +1410,6 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 
-		put_dev_pagemap(pgmap);
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
@@ -1420,6 +1419,8 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 	ret = 1;
 
 pte_unmap:
+	if (pgmap)
+		put_dev_pagemap(pgmap);
 	pte_unmap(ptem);
 	return ret;
 }
@@ -1459,10 +1460,12 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		get_page(page);
-		put_dev_pagemap(pgmap);
 		(*nr)++;
 		pfn++;
 	} while (addr += PAGE_SIZE, addr != end);
+
+	if (pgmap)
+		put_dev_pagemap(pgmap);
 	return 1;
 }
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
