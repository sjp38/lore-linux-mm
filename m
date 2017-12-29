Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B6D136B0069
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:54:33 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so29923771pfi.2
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:54:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t10si26381744plr.744.2017.12.28.23.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:54:29 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 01/17] memremap: provide stubs for vmem_altmap_offset and vmem_altmap_free
Date: Fri, 29 Dec 2017 08:53:50 +0100
Message-Id: <20171229075406.1936-2-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently all calls to those functions are eliminated by the compiler when
CONFIG_ZONE_DEVICE is not set, but this soon won't be the case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memremap.h | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 10d23c367048..d5a6736d9737 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -26,9 +26,6 @@ struct vmem_altmap {
 	unsigned long alloc;
 };
 
-unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
-void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
-
 #ifdef CONFIG_ZONE_DEVICE
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
 #else
@@ -138,6 +135,9 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 
+unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
+void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
+
 static inline bool is_zone_device_page(const struct page *page);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
@@ -157,7 +157,17 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
 	return NULL;
 }
-#endif
+
+static inline unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
+{
+	return 0;
+}
+
+static inline void vmem_altmap_free(struct vmem_altmap *altmap,
+		unsigned long nr_pfns)
+{
+}
+#endif /* CONFIG_ZONE_DEVICE */
 
 #if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
 static inline bool is_device_private_page(const struct page *page)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
