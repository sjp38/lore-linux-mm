Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A17982F64
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 17:34:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so125834751pgx.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 14:34:13 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n14si1902326pfb.155.2016.12.01.14.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 14:34:12 -0800 (PST)
Subject: [PATCH 03/11] mm: introduce common definitions for the size and
 mask of a section
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Dec 2016 14:30:03 -0800
Message-ID: <148063140295.37496.10420718896393609930.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148063138593.37496.4684424640746238765.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148063138593.37496.4684424640746238765.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, toshi.kani@hpe.com, linux-nvdimm@lists.01.org

Up-level the local section size and mask from kernel/memremap.c to
global definitions.  These will be used by the new sub-section hotplug
support.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    2 ++
 kernel/memremap.c      |   10 ++++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b13b490321a5..5a0117a72ec4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1048,6 +1048,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
+#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
+#define PA_SECTION_MASK		(~(PA_SECTION_SIZE-1))
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
 #define NR_MEM_SECTIONS		(1UL << SECTIONS_SHIFT)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 10becd7855ca..faf1b7b4114f 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -172,8 +172,6 @@ EXPORT_SYMBOL(devm_memunmap);
 #ifdef CONFIG_ZONE_DEVICE
 static DEFINE_MUTEX(pgmap_lock);
 static RADIX_TREE(pgmap_radix, GFP_KERNEL);
-#define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
-#define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
 struct page_map {
 	struct resource res;
@@ -265,8 +263,8 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	}
 
 	/* pages are dead and unused, undo the arch mapping */
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(res), SECTION_SIZE);
+	align_start = res->start & PA_SECTION_MASK;
+	align_size = ALIGN(resource_size(res), PA_SECTION_SIZE);
 	arch_remove_memory(align_start, align_size);
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
@@ -310,8 +308,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	struct page_map *page_map;
 	int error, nid, is_ram;
 
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+	align_start = res->start & PA_SECTION_MASK;
+	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
 		- align_start;
 	is_ram = region_intersects(align_start, align_size,
 		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
