Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEE0A6B026B
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:53 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f7so5846278pfa.21
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 31si3910984plg.522.2017.12.07.07.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:52 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 01/14] mm: move get_dev_pagemap out of line
Date: Thu,  7 Dec 2017 07:08:27 -0800
Message-Id: <20171207150840.28409-2-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

This is a pretty big function, which should be out of line in general,
and a no-op stub if CONFIG_ZONE_DEVICD? is not set.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h | 42 +++++-------------------------------------
 kernel/memremap.c        | 36 ++++++++++++++++++++++++++++++++++--
 2 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 10d23c367048..f24e0c71d6a6 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -136,8 +136,8 @@ struct dev_pagemap {
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
-struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
-
+struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap);
 static inline bool is_zone_device_page(const struct page *page);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
@@ -153,11 +153,12 @@ static inline void *devm_memremap_pages(struct device *dev,
 	return ERR_PTR(-ENXIO);
 }
 
-static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
+static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap)
 {
 	return NULL;
 }
-#endif
+#endif /* CONFIG_ZONE_DEVICE */
 
 #if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
 static inline bool is_device_private_page(const struct page *page)
@@ -173,39 +174,6 @@ static inline bool is_device_public_page(const struct page *page)
 }
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
-/**
- * get_dev_pagemap() - take a new live reference on the dev_pagemap for @pfn
- * @pfn: page frame number to lookup page_map
- * @pgmap: optional known pgmap that already has a reference
- *
- * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
- * same mapping.
- */
-static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
-		struct dev_pagemap *pgmap)
-{
-	const struct resource *res = pgmap ? pgmap->res : NULL;
-	resource_size_t phys = PFN_PHYS(pfn);
-
-	/*
-	 * In the cached case we're already holding a live reference so
-	 * we can simply do a blind increment
-	 */
-	if (res && phys >= res->start && phys <= res->end) {
-		percpu_ref_get(pgmap->ref);
-		return pgmap;
-	}
-
-	/* fall back to slow path lookup */
-	rcu_read_lock();
-	pgmap = find_dev_pagemap(phys);
-	if (pgmap && !percpu_ref_tryget_live(pgmap->ref))
-		pgmap = NULL;
-	rcu_read_unlock();
-
-	return pgmap;
-}
-
 static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
 {
 	if (pgmap)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 403ab9cdb949..f0b54eca85b0 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -314,7 +314,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 }
 
 /* assumes rcu_read_lock() held at entry */
-struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
+static struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
 	struct page_map *page_map;
 
@@ -500,8 +500,40 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 
 	return pgmap ? pgmap->altmap : NULL;
 }
-#endif /* CONFIG_ZONE_DEVICE */
 
+/**
+ * get_dev_pagemap() - take a new live reference on the dev_pagemap for @pfn
+ * @pfn: page frame number to lookup page_map
+ * @pgmap: optional known pgmap that already has a reference
+ *
+ * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
+ * same mapping.
+ */
+struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap)
+{
+	const struct resource *res = pgmap ? pgmap->res : NULL;
+	resource_size_t phys = PFN_PHYS(pfn);
+
+	/*
+	 * In the cached case we're already holding a live reference so
+	 * we can simply do a blind increment
+	 */
+	if (res && phys >= res->start && phys <= res->end) {
+		percpu_ref_get(pgmap->ref);
+		return pgmap;
+	}
+
+	/* fall back to slow path lookup */
+	rcu_read_lock();
+	pgmap = find_dev_pagemap(phys);
+	if (pgmap && !percpu_ref_tryget_live(pgmap->ref))
+		pgmap = NULL;
+	rcu_read_unlock();
+
+	return pgmap;
+}
+#endif /* CONFIG_ZONE_DEVICE */
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
 void put_zone_device_private_or_public_page(struct page *page)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
