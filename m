Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8C86B02C7
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 17:10:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so72379873pgc.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 14:10:54 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m6si4732965pgg.168.2017.01.19.14.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 14:10:53 -0800 (PST)
Subject: [PATCH v3 01/12] mm: fix type width of section to/from pfn
 conversion macros
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Jan 2017 14:06:41 -0800
Message-ID: <148486360180.19694.6303499052926089764.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

section_nr_to_pfn() will silently accept an argument that is too small
to contain a pfn. Cast the argument to an unsigned long, similar to
PFN_PHYS(). Fix up pfn_to_section_nr() in the same way.

This was discovered in __add_pages() when converting it to use an
signed integer for the loop variable.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    4 ++--
 mm/memory_hotplug.c    |    4 +---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 36d9896fbc1e..df36d21e0247 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1062,8 +1062,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
 #endif
 
-#define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
-#define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
+#define pfn_to_section_nr(pfn) ((unsigned long)(pfn) >> PFN_SECTION_SHIFT)
+#define section_nr_to_pfn(sec) ((unsigned long)(sec) << PFN_SECTION_SHIFT)
 
 #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
 #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e43142c15631..de34951bdf41 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -528,9 +528,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
 int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 			unsigned long nr_pages)
 {
-	unsigned long i;
-	int err = 0;
-	int start_sec, end_sec;
+	int err = 0, i, start_sec, end_sec;
 	struct vmem_altmap *altmap;
 
 	clear_zone_contiguous(zone);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
