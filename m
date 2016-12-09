Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF7436B026F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 21:45:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so5412451pfb.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 18:45:57 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g15si31388285pli.166.2016.12.08.18.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 18:45:57 -0800 (PST)
Subject: [PATCH v2 10/11] mm: enable section-unaligned devm_memremap_pages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 08 Dec 2016 18:41:47 -0800
Message-ID: <148125130754.13512.16184028876011482135.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, toshi.kani@hpe.com

Teach devm_memremap_pages() about the new sub-section capabilities of
arch_{add,remove}_memory().

Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index bb063a26b67a..6e1595fc3c56 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -254,7 +254,6 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 {
 	struct page_map *page_map = data;
 	struct resource *res = &page_map->res;
-	resource_size_t align_start, align_size;
 	struct dev_pagemap *pgmap = &page_map->pgmap;
 
 	if (percpu_ref_tryget_live(pgmap->ref)) {
@@ -263,10 +262,8 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	}
 
 	/* pages are dead and unused, undo the arch mapping */
-	align_start = res->start & PA_SECTION_MASK;
-	align_size = ALIGN(resource_size(res), PA_SECTION_SIZE);
-	arch_remove_memory(align_start, align_size);
-	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+	arch_remove_memory(res->start, resource_size(res));
+	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_radix_release(res);
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
 			"%s: failed to free all reserved pages\n", __func__);
@@ -301,17 +298,13 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
-	resource_size_t align_start, align_size, align_end;
 	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
 	int error, nid, is_ram;
 
-	align_start = res->start & PA_SECTION_MASK;
-	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
-		- align_start;
-	is_ram = region_intersects(align_start, align_size,
+	is_ram = region_intersects(res->start, resource_size(res),
 		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
 
 	if (is_ram == REGION_MIXED) {
@@ -344,7 +337,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
-	align_end = align_start + align_size - 1;
 
 	/* we're storing full physical addresses in the radix */
 	BUILD_BUG_ON(sizeof(unsigned long) < sizeof(resource_size_t));
@@ -376,12 +368,12 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
-			align_size);
+	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(res->start), 0,
+			resource_size(res));
 	if (error)
 		goto err_pfn_remap;
 
-	error = arch_add_memory(nid, align_start, align_size, true);
+	error = arch_add_memory(nid, res->start, resource_size(res), true);
 	if (error)
 		goto err_add_memory;
 
@@ -401,7 +393,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	return __va(res->start);
 
  err_add_memory:
-	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
  err_pfn_remap:
  err_radix:
 	pgmap_radix_release(res);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
