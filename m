Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A95F56B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n6so5873334pfg.19
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d92si3916375pld.106.2017.12.07.07.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:49 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/14] mm: better abstract out dev_pagemap start_pfn
Date: Thu,  7 Dec 2017 07:08:32 -0800
Message-Id: <20171207150840.28409-7-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h | 6 ++++++
 kernel/memremap.c        | 9 +++++++++
 mm/page_alloc.c          | 4 +---
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index d221f4c0ccac..fe60b4895f56 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -139,6 +139,7 @@ static inline bool is_zone_device_page(const struct page *page);
 int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages);
 bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages);
 unsigned long dev_pagemap_offset(struct page *page);
+unsigned long dev_pagemap_start_pfn(unsigned long start_pfn);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -174,6 +175,11 @@ static inline unsigned long dev_pagemap_offset(struct page *page)
 {
 	return 0;
 }
+
+static inline unsigned long dev_pagemap_start_pfn(unsigned long start_pfn)
+{
+	return 0;
+}
 #endif /* CONFIG_ZONE_DEVICE */
 
 #if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 91a5fc1146b5..01025c5f3037 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -493,6 +493,15 @@ int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages)
 	return 0;
 }
 
+unsigned long dev_pagemap_start_pfn(unsigned long start_pfn)
+{
+	struct vmem_altmap *pgmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
+
+	if (pgmap && start_pfn == pgmap->base_pfn)
+		return pgmap->reserve;
+	return 0;
+}
+
 bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 {
 	struct vmem_altmap *pgmap = to_vmem_altmap((uintptr_t)page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73f5d4556b3d..cf6a702222c3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5305,7 +5305,6 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		unsigned long start_pfn, enum memmap_context context)
 {
-	struct vmem_altmap *altmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
 	unsigned long end_pfn = start_pfn + size;
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long pfn;
@@ -5321,8 +5320,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	 * Honor reservation requested by the driver for this ZONE_DEVICE
 	 * memory
 	 */
-	if (altmap && start_pfn == altmap->base_pfn)
-		start_pfn += altmap->reserve;
+	start_pfn += dev_pagemap_start_pfn(start_pfn);
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
