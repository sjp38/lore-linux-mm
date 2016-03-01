Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B8EB26B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 21:57:17 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so103108906pad.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 18:57:17 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kx15si8547828pab.43.2016.02.29.18.57.17
        for <linux-mm@kvack.org>;
        Mon, 29 Feb 2016 18:57:17 -0800 (PST)
Subject: [PATCH 2/2] mm: fix mixed zone detection in devm_memremap_pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Feb 2016 18:56:31 -0800
Message-ID: <20160301025631.12812.85197.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20160301025620.12812.87268.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160301025620.12812.87268.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

The check for whether we overlap "System RAM" needs to be done at
section granularity.  For example a system with the following mapping:

    100000000-37bffffff : System RAM
    37c000000-837ffffff : Persistent Memory

...is unable to use devm_memremap_pages() as it would result in two
zones colliding within a given section.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index b981a7b023f0..4c7d08339f62 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -270,9 +270,10 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
-	int is_ram = region_intersects(res->start, resource_size(res),
-			"System RAM");
-	resource_size_t key, align_start, align_size, align_end;
+	resource_size_t align_start = res->start & ~(SECTION_SIZE - 1);
+	resource_size_t align_size = ALIGN(resource_size(res), SECTION_SIZE);
+	int is_ram = region_intersects(align_start, align_size, "System RAM");
+	resource_size_t key, align_end;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
 	unsigned long pfn;
@@ -314,8 +315,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 	align_end = align_start + align_size - 1;
 	for (key = align_start; key <= align_end; key += SECTION_SIZE) {
 		struct dev_pagemap *dup;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
