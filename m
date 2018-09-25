Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 583D48E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 02:30:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 11-v6so4302665pgd.1
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 23:30:36 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 69-v6si1530356pla.505.2018.09.24.23.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 23:30:35 -0700 (PDT)
Subject: [PATCH v6 4/7] mm,
 devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE support
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 24 Sep 2018 23:15:15 -0700
Message-ID: <153785611587.283091.3545117308977274134.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153785609460.283091.17422092801700439095.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153785609460.283091.17422092801700439095.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In preparation for consolidating all ZONE_DEVICE enabling via
devm_memremap_pages(), teach it how to handle the constraints of
MEMORY_DEVICE_PRIVATE ranges.

Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
[jglisse: call move_pfn_range_to_zone for MEMORY_DEVICE_PRIVATE]
Acked-by: Christoph Hellwig <hch@lst.de>
Reported-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   53 +++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 41 insertions(+), 12 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index fe2a9cd0b9c1..6e32fe36b460 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -132,9 +132,15 @@ static void devm_memremap_pages_release(void *data)
 		- align_start;
 
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size, pgmap->altmap_valid ?
-			&pgmap->altmap : NULL);
-	kasan_remove_zero_shadow(__va(align_start), align_size);
+	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
+		pfn = align_start >> PAGE_SHIFT;
+		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
+				align_size >> PAGE_SHIFT, NULL);
+	} else {
+		arch_remove_memory(align_start, align_size,
+				pgmap->altmap_valid ? &pgmap->altmap : NULL);
+		kasan_remove_zero_shadow(__va(align_start), align_size);
+	}
 	mem_hotplug_done();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
@@ -232,17 +238,40 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = kasan_add_zero_shadow(__va(align_start), align_size);
-	if (error) {
-		mem_hotplug_done();
-		goto err_kasan;
+
+	/*
+	 * For device private memory we call add_pages() as we only need to
+	 * allocate and initialize struct page for the device memory. More-
+	 * over the device memory is un-accessible thus we do not want to
+	 * create a linear mapping for the memory like arch_add_memory()
+	 * would do.
+	 *
+	 * For all other device memory types, which are accessible by
+	 * the CPU, we do want the linear mapping and thus use
+	 * arch_add_memory().
+	 */
+	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
+		error = add_pages(nid, align_start >> PAGE_SHIFT,
+				align_size >> PAGE_SHIFT, NULL, false);
+	} else {
+		error = kasan_add_zero_shadow(__va(align_start), align_size);
+		if (error) {
+			mem_hotplug_done();
+			goto err_kasan;
+		}
+
+		error = arch_add_memory(nid, align_start, align_size, altmap,
+				false);
+	}
+
+	if (!error) {
+		struct zone *zone;
+
+		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
+		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
+				align_size >> PAGE_SHIFT, altmap);
 	}
 
-	error = arch_add_memory(nid, align_start, align_size, altmap, false);
-	if (!error)
-		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-					align_start >> PAGE_SHIFT,
-					align_size >> PAGE_SHIFT, altmap);
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
