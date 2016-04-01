Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 455586B0253
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:10:23 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fe3so79190232pab.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:23 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id xg10si17734468pab.141.2016.03.31.19.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:10:22 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id e128so61531218pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:22 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/4] mm/page_alloc: correct highmem memory statistics
Date: Fri,  1 Apr 2016 11:10:08 +0900
Message-Id: <1459476610-31076-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

ZONE_MOVABLE could be treated as highmem so we need to consider it for
accurate statistics. And, in following patches, ZONE_CMA will be
introduced and it can be treated as highmem, too. So, instead of
manually adding stat of ZONE_MOVABLE, looping all zones and check whether
the zone is highmem or not and add stat of the zone which can be treated
as highmem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 437a934..173e616 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3897,6 +3897,8 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 {
 	int zone_type;		/* needs to be signed */
 	unsigned long managed_pages = 0;
+	unsigned long managed_highpages = 0;
+	unsigned long free_highpages = 0;
 	pg_data_t *pgdat = NODE_DATA(nid);
 
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
@@ -3905,12 +3907,19 @@ void si_meminfo_node(struct sysinfo *val, int nid)
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
