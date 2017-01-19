Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2866B02CE
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 17:11:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t6so72758287pgt.6
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 14:11:10 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y190si4738005pfy.194.2017.01.19.14.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 14:11:09 -0800 (PST)
Subject: [PATCH v3 04/12] mm: introduce common definitions for the size and
 mask of a section
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Jan 2017 14:07:03 -0800
Message-ID: <148486362333.19694.14241079169560958896.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

Up-level the local section size and mask from kernel/memremap.c to
global definitions.  These will be used by the new sub-section hotplug
support.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    2 ++
 kernel/memremap.c      |   10 ++++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 18cc15b93d19..aa37e2e860ed 100644
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
index e0a2de6a168b..e58d7828ff9a 100644
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
@@ -267,8 +265,8 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	}
 
 	/* pages are dead and unused, undo the arch mapping */
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(resource_size(res), SECTION_SIZE);
+	align_start = res->start & PA_SECTION_MASK;
+	align_size = ALIGN(resource_size(res), PA_SECTION_SIZE);
 	mem_hotplug_begin();
 	arch_remove_memory(align_start, align_size);
 	mem_hotplug_done();
@@ -314,8 +312,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
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
