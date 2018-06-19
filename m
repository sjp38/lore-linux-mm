Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 783D26B000C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:15:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o19-v6so6102444pgn.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:15:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z10-v6si11873907pgv.1.2018.06.18.23.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 23:15:05 -0700 (PDT)
Subject: [PATCH v3 4/8] mm,
 devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE support
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Jun 2018 23:04:59 -0700
Message-ID: <152938829976.17797.11139256105673921009.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In preparation for consolidating all ZONE_DEVICE enabling via
devm_memremap_pages(), teach it how to handle the constraints of
MEMORY_DEVICE_PRIVATE ranges.

Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Reported-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   38 ++++++++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 92b8d7057321..16141b608b63 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -131,8 +131,13 @@ static void devm_memremap_pages_release(void *data)
 		- align_start;
 
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size, pgmap->altmap_valid ?
-			&pgmap->altmap : NULL);
+	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
+		pfn = align_start >> PAGE_SHIFT;
+		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
+				align_size >> PAGE_SHIFT, NULL);
+	} else
+		arch_remove_memory(align_start, align_size,
+				pgmap->altmap_valid ? &pgmap->altmap : NULL);
 	mem_hotplug_done();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
@@ -216,11 +221,32 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
-	error = arch_add_memory(nid, align_start, align_size, altmap, false);
-	if (!error)
-		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-					align_start >> PAGE_SHIFT,
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
+		struct zone *zone;
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
