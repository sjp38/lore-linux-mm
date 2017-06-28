Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F2FC26B0292
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 23:45:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u5so46464437pgq.14
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 20:45:37 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 61si762344plz.299.2017.06.27.20.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 20:45:36 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id e199so7228609pfh.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 20:45:36 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/memory_hotplug: adjust zone/node size during __offline_pages()
Date: Wed, 28 Jun 2017 11:45:31 +0800
Message-Id: <20170628034531.70940-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

After onlining a memory_block and then offline it, the valid_zones will not
come back to the original state.

For example:

    $cat memory4?/valid_zones
    Movable Normal
    Movable Normal
    Movable Normal

    $echo online > memory40/state
    $cat memory4?/valid_zones
    Movable
    Movable
    Movable

    $echo offline > memory40/state
    $cat memory4?/valid_zones
    Movable
    Movable
    Movable

While the expected behavior is back to the original valid_zones.

The reason is during __offline_pages(), zone/node related fields are not
adjusted.

This patch adjusts zone/node related fields in __offline_pages().

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memory_hotplug.c | 42 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 6 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9b94ca67ab00..823939d57f9b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -879,8 +879,8 @@ bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
 	return online_type == MMOP_ONLINE_KEEP;
 }
 
-static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
-		unsigned long nr_pages)
+static void __meminit upsize_zone_range(struct zone *zone,
+		unsigned long start_pfn, unsigned long nr_pages)
 {
 	unsigned long old_end_pfn = zone_end_pfn(zone);
 
@@ -890,8 +890,21 @@ static void __meminit resize_zone_range(struct zone *zone, unsigned long start_p
 	zone->spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - zone->zone_start_pfn;
 }
 
-static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned long start_pfn,
-                                     unsigned long nr_pages)
+static void __meminit downsize_zone_range(struct zone *zone,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	unsigned long old_end_pfn = zone_end_pfn(zone);
+
+	if (start_pfn == zone->zone_start_pfn
+		|| old_end_pfn == (start_pfn + nr_pages))
+		zone->spanned_pages -= nr_pages;
+
+	if (start_pfn == zone->zone_start_pfn)
+		zone->zone_start_pfn += nr_pages;
+}
+
+static void __meminit upsize_pgdat_range(struct pglist_data *pgdat,
+		unsigned long start_pfn, unsigned long nr_pages)
 {
 	unsigned long old_end_pfn = pgdat_end_pfn(pgdat);
 
@@ -901,6 +914,19 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
 	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
 }
 
+static void __meminit downsize_pgdat_range(struct pglist_data *pgdat,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	unsigned long old_end_pfn = pgdat_end_pfn(pgdat);
+
+	if (pgdat->node_start_pfn == start_pfn)
+		pgdat->node_start_pfn = start_pfn;
+
+	if (pgdat->node_start_pfn == start_pfn
+		|| old_end_pfn == (start_pfn + nr_pages))
+		pgdat->node_spanned_pages -= nr_pages;
+}
+
 void __ref move_pfn_range_to_zone(struct zone *zone,
 		unsigned long start_pfn, unsigned long nr_pages)
 {
@@ -916,9 +942,9 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
 	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
 	pgdat_resize_lock(pgdat, &flags);
 	zone_span_writelock(zone);
-	resize_zone_range(zone, start_pfn, nr_pages);
+	upsize_zone_range(zone, start_pfn, nr_pages);
 	zone_span_writeunlock(zone);
-	resize_pgdat_range(pgdat, start_pfn, nr_pages);
+	upsize_pgdat_range(pgdat, start_pfn, nr_pages);
 	pgdat_resize_unlock(pgdat, &flags);
 
 	/*
@@ -1809,7 +1835,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	zone->present_pages -= offlined_pages;
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
+	zone_span_writelock(zone);
+	downsize_zone_range(zone, start_pfn, nr_pages);
+	zone_span_writeunlock(zone);
 	zone->zone_pgdat->node_present_pages -= offlined_pages;
+	downsize_pgdat_range(zone->zone_pgdat, start_pfn, nr_pages);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
 	init_per_zone_wmark_min();
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
