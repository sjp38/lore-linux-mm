Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDA866B026D
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:55:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y62so29923939pfd.3
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:55:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v90si27961014pfk.397.2017.12.28.23.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:55:12 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/17] mm: move get_dev_pagemap out of line
Date: Fri, 29 Dec 2017 08:54:00 +0100
Message-Id: <20171229075406.1936-12-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a pretty big function, which should be out of line in general,
and a no-op stub if CONFIG_ZONE_DEVICD? is not set.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memremap.h | 39 ++++-----------------------------------
 kernel/memremap.c        | 36 ++++++++++++++++++++++++++++++++++--
 2 files changed, 38 insertions(+), 37 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index d5a6736d9737..26e8aaba27d5 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -133,7 +133,8 @@ struct dev_pagemap {
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
-struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
+struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap);
 
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
@@ -153,7 +154,8 @@ static inline void *devm_memremap_pages(struct device *dev,
 	return ERR_PTR(-ENXIO);
 }
 
-static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
+static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
+		struct dev_pagemap *pgmap)
 {
 	return NULL;
 }
@@ -183,39 +185,6 @@ static inline bool is_device_public_page(const struct page *page)
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
index 64b12c806cc5..3df6cd4ffb40 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -314,7 +314,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 }
 
 /* assumes rcu_read_lock() held at entry */
-struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
+static struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
 	struct page_map *page_map;
 
@@ -501,8 +501,40 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 
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
