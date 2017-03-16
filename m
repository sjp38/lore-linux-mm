Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA786B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:12:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y6so51949419pfa.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 23:12:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g2si4279806plk.70.2017.03.15.23.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 23:12:20 -0700 (PDT)
Subject: [PATCH v4 04/13] mm: introduce common definitions for the size and
 mask of a section
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 Mar 2017 23:07:09 -0700
Message-ID: <148964442915.19438.13692551999756522608.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index 82a1af3afa04..a95b83ee65ec 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1050,6 +1050,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
+#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
+#define PA_SECTION_MASK		(~(PA_SECTION_SIZE-1))
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
 #define NR_MEM_SECTIONS		(1UL << SECTIONS_SHIFT)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 72e93754c0f4..c4f63346ff52 100644
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
@@ -316,8 +314,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
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
