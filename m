Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 66C3F6B0037
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:20 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 19:14:19 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5B5811FF003C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:09:17 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EHG4135856
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EHvF004975
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:17 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 03/25] mm/memory_hotplug: factor out zone+pgdat growth.
Date: Thu, 11 Apr 2013 18:13:35 -0700
Message-Id: <1365729237-29711-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Create a new function grow_pgdat_and_zone() which handles locking +
growth of a zone & the pgdat which it is associated with.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/memory_hotplug.h |  3 +++
 mm/memory_hotplug.c            | 17 +++++++++++------
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index b6a3be7..cd393014 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -78,6 +78,9 @@ static inline void zone_seqlock_init(struct zone *zone)
 {
 	seqlock_init(&zone->span_seqlock);
 }
+extern void grow_pgdat_and_zone(struct zone *zone, unsigned long start_pfn,
+				unsigned long end_pfn);
+
 extern int zone_grow_free_lists(struct zone *zone, unsigned long new_nr_pages);
 extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 46de32a..8f4d8d3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -390,13 +390,22 @@ static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
 					pgdat->node_start_pfn;
 }
 
+void grow_pgdat_and_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+	unsigned long flags;
+	pgdat_resize_lock(zone->zone_pgdat, &flags);
+	grow_zone_span(zone, start_pfn, end_pfn);
+	grow_pgdat_span(zone->zone_pgdat, start_pfn, end_pfn);
+	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+}
+
 static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
 	int nid = pgdat->node_id;
 	int zone_type;
-	unsigned long flags;
 	int ret;
 
 	zone_type = zone - pgdat->node_zones;
@@ -404,11 +413,7 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	if (ret)
 		return ret;
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
-	grow_pgdat_span(zone->zone_pgdat, phys_start_pfn,
-			phys_start_pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	grow_pgdat_and_zone(zone, phys_start_pfn, phys_start_pfn + nr_pages);
 	memmap_init_zone(nr_pages, nid, zone_type,
 			 phys_start_pfn, MEMMAP_HOTPLUG);
 	return 0;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
