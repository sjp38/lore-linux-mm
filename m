Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2848E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 22:34:06 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e8-v6so1934558plt.4
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 19:34:06 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c126-v6si2721165pfa.130.2018.09.12.19.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 19:34:05 -0700 (PDT)
Subject: [PATCH v5 4/7] mm,
 devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE support
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Sep 2018 19:22:22 -0700
Message-ID: <153680534246.453305.10522027577023444732.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In preparation for consolidating all ZONE_DEVICE enabling via
devm_memremap_pages(), teach it how to handle the constraints of
MEMORY_DEVICE_PRIVATE ranges.

Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Reported-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   51 +++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 39 insertions(+), 12 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index ab5eb570d28d..3234a771e63a 100644
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
@@ -234,17 +240,38 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = kasan_add_zero_shadow(__va(align_start), align_size);
-	if (error) {
-		mem_hotplug_done();
-		goto err_kasan;
-	}
 
-	error = arch_add_memory(nid, align_start, align_size, altmap, false);
-	if (!error)
-		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-					align_start >> PAGE_SHIFT,
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
+		struct zone *zone;
+
+		error = kasan_add_zero_shadow(__va(align_start), align_size);
+		if (error) {
+			mem_hotplug_done();
+			goto err_kasan;
+		}
+
+		error = arch_add_memory(nid, align_start, align_size, altmap,
+				false);
+		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
+		if (!error)
+			move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
 					align_size >> PAGE_SHIFT, altmap);
+	}
+
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
