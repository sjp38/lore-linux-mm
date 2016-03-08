Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id EB03C6B007E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 17:32:52 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id x188so22832528pfb.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 14:32:52 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id lk8si7442250pab.112.2016.03.08.14.32.52
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 14:32:52 -0800 (PST)
Subject: [PATCH] mm: fix 'size' alignment in devm_memremap_pages()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 08 Mar 2016 14:32:25 -0800
Message-ID: <20160308222516.16008.22439.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

We need to align the end address, not just the size.

Cc: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Hi Andrew, one more fixup to devm_memremap_pages().  I was discussing
patch "mm: fix mixed zone detection in devm_memremap_pages" with Toshi
and noticed that it was mishandling the end-of-range alignment.  Please
apply or fold this into the existing patch.

 kernel/memremap.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index c0f11a498a5a..60baf4d3401e 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -270,14 +270,16 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
-	resource_size_t align_start = res->start & ~(SECTION_SIZE - 1);
-	resource_size_t align_size = ALIGN(resource_size(res), SECTION_SIZE);
-	int is_ram = region_intersects(align_start, align_size, "System RAM");
-	resource_size_t key, align_end;
+	resource_size_t key, align_start, align_size, align_end;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
+	int error, nid, is_ram;
 	unsigned long pfn;
-	int error, nid;
+
+	align_start = res->start & ~(SECTION_SIZE - 1);
+	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+		- align_start;
+	is_ram = region_intersects(align_start, align_size, "System RAM");
 
 	if (is_ram == REGION_MIXED) {
 		WARN_ONCE(1, "%s attempted on mixed region %pr\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
