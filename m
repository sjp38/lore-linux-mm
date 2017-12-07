Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24E2B6B0261
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p1so5876302pfp.13
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d62si3835863pga.87.2017.12.07.07.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:50 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/14] mm: better abstract out dev_pagemap freeing
Date: Thu,  7 Dec 2017 07:08:29 -0800
Message-Id: <20171207150840.28409-4-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Add a new helper that both looks up the pagemap and updates the alloc
counter.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/mm/init_64.c | 6 ++----
 arch/x86/mm/init_64.c     | 5 +----
 include/linux/memremap.h  | 7 ++++++-
 kernel/memremap.c         | 9 +++++++--
 4 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index a07722531b32..d6a040198edf 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -268,7 +268,6 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 
 	for (; start < end; start += page_size) {
 		unsigned long nr_pages, addr;
-		struct vmem_altmap *altmap;
 		struct page *section_base;
 		struct page *page;
 
@@ -288,9 +287,8 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 		section_base = pfn_to_page(vmemmap_section_start(start));
 		nr_pages = 1 << page_order;
 
-		altmap = to_vmem_altmap((unsigned long) section_base);
-		if (altmap) {
-			vmem_altmap_free(altmap, nr_pages);
+		if (dev_pagemap_free_pages(section_base, nr_pages)) {
+			;
 		} else if (PageReserved(page)) {
 			/* allocated from bootmem */
 			if (page_size < PAGE_SIZE) {
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 4a837289f2ad..f5e51b941d19 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -804,12 +804,9 @@ static void __meminit free_pagetable(struct page *page, int order)
 {
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
-	struct vmem_altmap *altmap = to_vmem_altmap((unsigned long) page);
 
-	if (altmap) {
-		vmem_altmap_free(altmap, nr_pages);
+	if (dev_pagemap_free_pages(page, nr_pages))
 		return;
-	}
 
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f24e0c71d6a6..8f4d96f0e265 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -27,7 +27,6 @@ struct vmem_altmap {
 };
 
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
-void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
 
 #ifdef CONFIG_ZONE_DEVICE
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
@@ -139,6 +138,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap);
 static inline bool is_zone_device_page(const struct page *page);
+bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -158,6 +158,11 @@ static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 {
 	return NULL;
 }
+
+static inline bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
+{
+	return false;
+}
 #endif /* CONFIG_ZONE_DEVICE */
 
 #if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 502fa107a585..1b7c5bc93162 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -470,9 +470,14 @@ unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
 	return altmap->reserve + altmap->free;
 }
 
-void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns)
+bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 {
-	altmap->alloc -= nr_pfns;
+	struct vmem_altmap *pgmap = to_vmem_altmap((uintptr_t)page);
+
+	if (!pgmap)
+		return false;
+	pgmap->alloc -= nr_pages;
+	return true;
 }
 
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
