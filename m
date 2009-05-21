Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B81E6B005A
	for <linux-mm@kvack.org>; Wed, 20 May 2009 20:23:25 -0400 (EDT)
Received: by mail-fx0-f168.google.com with SMTP id 12so1130015fxm.38
        for <linux-mm@kvack.org>; Wed, 20 May 2009 17:23:45 -0700 (PDT)
Date: Thu, 21 May 2009 09:23:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 2/3] add inactive ratio calculation function of each zone V2
Message-Id: <20090521092321.ee57585e.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Changelog since V1 
 o Change function name from calculate_zone_inactive_ratio to calculate_inactive_ratio
   - by Mel Gorman advise
 o Modify tab indent - by Mel Gorman advise

This patch devide setup_per_zone_inactive_ratio with
per-zone inactive ratio calculaton.

This patch is just for helping my next patch.
(reset wmark_min and inactive ratio of zone when hotplug happens)

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Rik van Riel <riel@redhat.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm.h |    1 +
 mm/page_alloc.c    |   28 ++++++++++++++++------------
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7ea4d1b..5d7a835 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1059,6 +1059,7 @@ extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
 extern void setup_per_zone_wmarks(void);
+extern void calculate_zone_inactive_ratio(struct zone *zone);
 extern void mem_init(void);
 extern void __init mmap_init(void);
 extern void show_mem(void);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b518ea7..f11cfbf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4553,22 +4553,26 @@ void setup_per_zone_wmarks(void)
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-static void __init setup_per_zone_inactive_ratio(void)
+void calculate_zone_inactive_ratio(struct zone *zone)
 {
-	struct zone *zone;
+	unsigned int gb, ratio;
 
-	for_each_zone(zone) {
-		unsigned int gb, ratio;
+	/* Zone size in gigabytes */
+	gb = zone->present_pages >> (30 - PAGE_SHIFT);
+	if (gb)
+		ratio = int_sqrt(10 * gb);
+	else
+		ratio = 1;
 
-		/* Zone size in gigabytes */
-		gb = zone->present_pages >> (30 - PAGE_SHIFT);
-		if (gb)
-			ratio = int_sqrt(10 * gb);
-		else
-			ratio = 1;
+	zone->inactive_ratio = ratio;
+}
 
-		zone->inactive_ratio = ratio;
-	}
+static void __init setup_per_zone_inactive_ratio(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone)
+		calculate_zone_inactive_ratio(zone);	
 }
 
 /*
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
