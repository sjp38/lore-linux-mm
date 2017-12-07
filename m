Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B74E6B026D
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p1so5876430pfp.13
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o3si3815426pls.436.2017.12.07.07.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:53 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/14] mm: better abstract out dev_pagemap alloc
Date: Thu,  7 Dec 2017 07:08:30 -0800
Message-Id: <20171207150840.28409-5-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Add a new helper that both looks up the pagemap and initializes the
alloc counter.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h |  7 +++++++
 kernel/memremap.c        | 18 ++++++++++++++++++
 mm/memory_hotplug.c      | 23 +++++------------------
 3 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 8f4d96f0e265..054397a9414f 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -138,6 +138,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap);
 static inline bool is_zone_device_page(const struct page *page);
+int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages);
 bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
@@ -159,6 +160,12 @@ static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 	return NULL;
 }
 
+static inline int dev_pagemap_add_pages(unsigned long phys_start_pfn,
+		unsigned nr_pages)
+{
+	return 0;
+}
+
 static inline bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 {
 	return false;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 1b7c5bc93162..c86bcd63e2cd 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -470,6 +470,24 @@ unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
 	return altmap->reserve + altmap->free;
 }
 
+int dev_pagemap_add_pages(unsigned long phys_start_pfn, unsigned nr_pages)
+{
+	struct vmem_altmap *pgmap;
+
+	pgmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
+	if (!pgmap)
+		return 0;
+
+	if (pgmap->base_pfn != phys_start_pfn ||
+	    vmem_altmap_offset(pgmap) > nr_pages) {
+		pr_warn_once("memory add fail, invalid map\n");
+		return -EINVAL;
+	}
+
+	pgmap->alloc = 0;
+	return 0;
+}
+
 bool dev_pagemap_free_pages(struct page *page, unsigned nr_pages)
 {
 	struct vmem_altmap *pgmap = to_vmem_altmap((uintptr_t)page);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c52aa05b106c..3e7c728f97e3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -297,25 +297,14 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
-	struct vmem_altmap *altmap;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
-	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
-	if (altmap) {
-		/*
-		 * Validate altmap is within bounds of the total request
-		 */
-		if (altmap->base_pfn != phys_start_pfn
-				|| vmem_altmap_offset(altmap) > nr_pages) {
-			pr_warn_once("memory add fail, invalid altmap\n");
-			err = -EINVAL;
-			goto out;
-		}
-		altmap->alloc = 0;
-	}
+	err = dev_pagemap_add_pages(phys_start_pfn, nr_pages);
+	if (err)
+		return err;
 
 	for (i = start_sec; i <= end_sec; i++) {
 		err = __add_section(nid, section_nr_to_pfn(i), want_memblock);
@@ -326,13 +315,11 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		 * Warning will be printed if there is collision.
 		 */
 		if (err && (err != -EEXIST))
-			break;
-		err = 0;
+			return err;
 		cond_resched();
 	}
 	vmemmap_populate_print_last();
-out:
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(__add_pages);
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
