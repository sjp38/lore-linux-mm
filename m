Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9756B6B0264
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:08:25 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id os4so70078368pac.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:25 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id f6si11124162pab.112.2016.10.13.01.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 01:08:24 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id s8so4533735pfj.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:24 -0700 (PDT)
From: js1304@gmail.com
Subject: [RFC PATCH 5/5] mm/page_alloc: support fixed migratetype pageblock
Date: Thu, 13 Oct 2016 17:08:22 +0900
Message-Id: <1476346102-26928-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We have migratetype facility to minimise fragmentation. It dynamically
changes migratetype of pageblock based on some criterias but it never
be perfect. Some migratetype pages are often placed in the other
migratetype pageblock. We call this pageblock as mixed pageblock.

There are two types of mixed pageblock. Movable page on unmovable
pageblock and unmovable page on movable pageblock. (I simply ignore
reclaimble migratetype/pageblock for easy explanation.) Earlier case is
not a big problem because movable page is reclaimable or migratable. We can
reclaim/migrate it when necessary so it usually doesn't contribute
fragmentation. Actual problem is caused by later case. We don't have
any way to reclaim/migrate this page and it prevents to make high order
freepage.

This later case happens when there is too less unmovable freepage. When
unmovable freepage runs out, fallback allocation happens and unmovable
allocation would be served by movable pageblock.

To solve/prevent this problem, we need to have enough unmovable freepage
to satisfy all unmovable allocation request by unmovable pageblock.
If we set enough unmovable pageblock at boot and fix it's migratetype
until power off, we would have more unmovable freepage during runtime and
mitigate above problem.

This patch provides a way to set minimum number of unmovable pageblock
at boot time. In my test, with proper setup, I can't see any mixed
pageblock where unmovable allocation stay on movable pageblock.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 90 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 90 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6b60e26..846c8c7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1406,6 +1406,89 @@ void clear_zone_contiguous(struct zone *zone)
 	zone->contiguous = false;
 }
 
+static unsigned long ratio_unmovable, ratio_reclaimable;
+
+static int __init early_ratio_unmovable(char *buf)
+{
+	if (!buf)
+		return -EINVAL;
+
+	return kstrtoul(buf, 0, &ratio_unmovable);
+}
+early_param("ratio_unmovable", early_ratio_unmovable);
+
+static int __init early_ratio_reclaimable(char *buf)
+{
+	if (!buf)
+		return -EINVAL;
+
+	return kstrtoul(buf, 0, &ratio_reclaimable);
+}
+early_param("ratio_reclaimable", early_ratio_reclaimable);
+
+static void __reserve_zone_fixed_pageblock(struct zone *zone,
+					int migratetype, int nr)
+{
+	unsigned long block_start_pfn = zone->zone_start_pfn;
+	unsigned long block_end_pfn;
+	struct page *page;
+	int count = 0;
+	int pageblocks = MAX_ORDER_NR_PAGES / pageblock_nr_pages;
+	int i;
+
+	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
+	for (; block_start_pfn < zone_end_pfn(zone) &&
+			count + pageblocks <= nr;
+			block_start_pfn = block_end_pfn,
+			 block_end_pfn += pageblock_nr_pages) {
+
+		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
+
+		if (!__pageblock_pfn_to_page(block_start_pfn,
+					     block_end_pfn, zone))
+			continue;
+
+		page = pfn_to_page(block_start_pfn);
+		if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
+			continue;
+
+		if (!PageBuddy(page))
+			continue;
+
+		if (page_order(page) != MAX_ORDER - 1)
+			continue;
+
+		move_freepages_block(zone, page, migratetype);
+		i = pageblocks;
+		do {
+			set_pageblock_migratetype(page, migratetype);
+			set_pageblock_flags_group(page, 1,
+				PB_migrate_fixed, PB_migrate_fixed);
+			count++;
+			page += pageblock_nr_pages;
+		} while (--i);
+	}
+
+	pr_info("Node %d %s %d pageblocks are permanently reserved for migratetype %d\n",
+		zone_to_nid(zone), zone->name, count, migratetype);
+}
+
+static void reserve_zone_fixed_pageblock(struct zone *zone)
+{
+	unsigned long nr_unmovable, nr_reclaimable;
+
+	nr_unmovable = (zone->managed_pages * ratio_unmovable / 100);
+	nr_unmovable /= pageblock_nr_pages;
+
+	nr_reclaimable = (zone->managed_pages * ratio_reclaimable / 100);
+	nr_reclaimable /= pageblock_nr_pages;
+
+	__reserve_zone_fixed_pageblock(zone,
+		MIGRATE_UNMOVABLE, nr_unmovable);
+	__reserve_zone_fixed_pageblock(zone,
+		MIGRATE_RECLAIMABLE, nr_reclaimable);
+}
+
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static void __init deferred_free_range(struct page *page,
 					unsigned long pfn, int nr_pages)
@@ -1567,6 +1650,7 @@ static int __init deferred_init_memmap(void *data)
 void __init page_alloc_init_late(void)
 {
 	struct zone *zone;
+	unsigned long flags;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	int nid;
@@ -1584,6 +1668,12 @@ void __init page_alloc_init_late(void)
 	files_maxfiles_init();
 #endif
 
+	for_each_populated_zone(zone) {
+		spin_lock_irqsave(&zone->lock, flags);
+		reserve_zone_fixed_pageblock(zone);
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+
 	for_each_populated_zone(zone)
 		set_zone_contiguous(zone);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
