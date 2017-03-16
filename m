Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 381316B0395
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:13:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b2so74000758pgc.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 23:13:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m17si4265569pli.193.2017.03.15.23.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 23:13:03 -0700 (PDT)
Subject: [PATCH v4 12/13] mm: enable section-unaligned devm_memremap_pages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 Mar 2017 23:07:52 -0700
Message-ID: <148964447222.19438.8770660811344879796.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Logan Gunthorpe <logang@deltatee.com>

Teach devm_memremap_pages() about the new sub-section capabilities of
arch_{add,remove}_memory().

Cc: Michal Hocko <mhocko@suse.com>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index c4f63346ff52..e6476a8e8b6a 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -256,7 +256,6 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 {
 	struct page_map *page_map = data;
 	struct resource *res = &page_map->res;
-	resource_size_t align_start, align_size;
 	struct dev_pagemap *pgmap = &page_map->pgmap;
 
 	if (percpu_ref_tryget_live(pgmap->ref)) {
@@ -265,14 +264,10 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	}
 
 	/* pages are dead and unused, undo the arch mapping */
-	align_start = res->start & PA_SECTION_MASK;
-	align_size = ALIGN(resource_size(res), PA_SECTION_SIZE);
-
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size);
+	arch_remove_memory(res->start, resource_size(res));
 	mem_hotplug_done();
-
-	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_radix_release(res);
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
 			"%s: failed to free all reserved pages\n", __func__);
@@ -307,17 +302,13 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
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
@@ -350,7 +341,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
-	align_end = align_start + align_size - 1;
 
 	foreach_order_pgoff(res, order, pgoff) {
 		struct dev_pagemap *dup;
@@ -379,13 +369,13 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
-			align_size);
+	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(res->start), 0,
+			resource_size(res));
 	if (error)
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, true);
+	error = arch_add_memory(nid, res->start, resource_size(res), true);
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
@@ -406,7 +396,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
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
