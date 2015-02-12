Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8714F6B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:10 -0500 (EST)
Received: by pdev10 with SMTP id v10so10112642pde.10
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:10 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yr7si4094879pac.4.2015.02.11.23.30.08
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:09 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 01/16] mm/page_alloc: correct highmem memory statistics
Date: Thu, 12 Feb 2015 16:32:05 +0900
Message-Id: <1423726340-4084-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

ZONE_MOVABLE could be treated as highmem so we need to consider it for
accurate statistics. And, in following patches, ZONE_CMA will be
introduced and it can be treated as highmem, too. So, instead of
manually adding stat of ZONE_MOVABLE, looping all zones and check whether
the zone is highmem or not and add stat of the zone which can be treated
as highmem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c9..c784035 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3105,6 +3105,8 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 {
 	int zone_type;		/* needs to be signed */
 	unsigned long managed_pages = 0;
+	unsigned long managed_highpages = 0;
+	unsigned long free_highpages = 0;
 	pg_data_t *pgdat = NODE_DATA(nid);
 
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
@@ -3113,12 +3115,19 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	val->sharedram = node_page_state(nid, NR_SHMEM);
 	val->freeram = node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
-	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
-	val->freehigh = zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
-			NR_FREE_PAGES);
+	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
+		struct zone *zone = &pgdat->node_zones[zone_type];
+
+		if (is_highmem(zone)) {
+			managed_highpages += zone->managed_pages;
+			free_highpages += zone_page_state(zone, NR_FREE_PAGES);
+		}
+	}
+	val->totalhigh = managed_highpages;
+	val->freehigh = free_highpages;
 #else
-	val->totalhigh = 0;
-	val->freehigh = 0;
+	val->totalhigh = managed_highpages;
+	val->freehigh = free_highpages;
 #endif
 	val->mem_unit = PAGE_SIZE;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
