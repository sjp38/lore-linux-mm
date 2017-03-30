Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4060A6B039F
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:55:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z36so9787661wrc.14
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:03 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id 200si3657628wmg.4.2017.03.30.04.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 04:55:01 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id k6so10133034wre.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:01 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/6] mm: get rid of zone_is_initialized
Date: Thu, 30 Mar 2017 13:54:49 +0200
Message-Id: <20170330115454.32154-2-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-1-mhocko@kernel.org>
References: <20170330115454.32154-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

There shouldn't be any reason to add initialized when we can tell the
same thing from checking whether there are any pages spanned to the
zone. Remove zone_is_initialized() and replace it by zone_is_empty
which can be used for the same set of tests.

This shouldn't have any visible effect

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h | 11 +++++------
 mm/memory_hotplug.c    |  6 +++---
 mm/page_alloc.c        |  5 +----
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 618499159a7c..dbe3b32fe85d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -442,8 +442,6 @@ struct zone {
 	seqlock_t		span_seqlock;
 #endif
 
-	int initialized;
-
 	/* Write-intensive fields used from the page allocator */
 	ZONE_PADDING(_pad1_)
 
@@ -520,14 +518,15 @@ static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
 	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
 }
 
-static inline bool zone_is_initialized(struct zone *zone)
+static inline bool zone_is_empty(struct zone *zone)
 {
-	return zone->initialized;
+	return zone->spanned_pages == 0;
 }
 
-static inline bool zone_is_empty(struct zone *zone)
+static inline bool zone_spans_range(const struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages)
 {
-	return zone->spanned_pages == 0;
+	return zone->zone_start_pfn <= start_pfn && start_pfn + nr_pages < zone_end_pfn(zone);
 }
 
 /*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6fb6bd2df787..699f5a2a8efd 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -348,7 +348,7 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
 static int __ref ensure_zone_is_initialized(struct zone *zone,
 			unsigned long start_pfn, unsigned long num_pages)
 {
-	if (!zone_is_initialized(zone))
+	if (zone_is_empty(zone))
 		return init_currently_empty_zone(zone, start_pfn, num_pages);
 
 	return 0;
@@ -1051,7 +1051,7 @@ bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
 
 		/* no zones in use between current zone and target */
 		for (i = idx + 1; i < target; i++)
-			if (zone_is_initialized(zone - idx + i))
+			if (!zone_is_empty(zone - idx + i))
 				return false;
 	}
 
@@ -1062,7 +1062,7 @@ bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
 
 		/* no zones in use between current zone and target */
 		for (i = target + 1; i < idx; i++)
-			if (zone_is_initialized(zone - idx + i))
+			if (!zone_is_empty(zone - idx + i))
 				return false;
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5ee8a26fa383..af58b51c5897 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -795,7 +795,7 @@ static inline void __free_one_page(struct page *page,
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
-	VM_BUG_ON(!zone_is_initialized(zone));
+	VM_BUG_ON(zone_is_empty(zone));
 	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
 
 	VM_BUG_ON(migratetype == -1);
@@ -5535,9 +5535,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 			zone_start_pfn, (zone_start_pfn + size));
 
 	zone_init_free_lists(zone);
-	zone->initialized = 1;
-
-	return 0;
 }
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
