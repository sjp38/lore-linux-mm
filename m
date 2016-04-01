Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id EA8AB6B025F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:10:31 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id 4so82875882pfd.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:31 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id g7si17777023pat.103.2016.03.31.19.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:10:31 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id tt10so79088902pab.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:31 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 4/4] mm/vmstat: make node_page_state() handles all zones by itself
Date: Fri,  1 Apr 2016 11:10:10 +0900
Message-Id: <1459476610-31076-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

node_page_state() manually add statistics per each zone and return
total value for all zones. Whenever we add a new zone, we need to
consider this function and it's really troublesome. Make it handles
all zones by itself.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmstat.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0a726e3..a7de9ad 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -600,19 +600,13 @@ void zone_statistics(struct zone *preferred_zone, struct zone *z, gfp_t flags)
 unsigned long node_page_state(int node, enum zone_stat_item item)
 {
 	struct zone *zones = NODE_DATA(node)->node_zones;
+	int i;
+	unsigned long count = 0;
 
-	return
-#ifdef CONFIG_ZONE_DMA
-		zone_page_state(&zones[ZONE_DMA], item) +
-#endif
-#ifdef CONFIG_ZONE_DMA32
-		zone_page_state(&zones[ZONE_DMA32], item) +
-#endif
-#ifdef CONFIG_HIGHMEM
-		zone_page_state(&zones[ZONE_HIGHMEM], item) +
-#endif
-		zone_page_state(&zones[ZONE_NORMAL], item) +
-		zone_page_state(&zones[ZONE_MOVABLE], item);
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		count += zone_page_state(zones + i, item);
+
+	return count;
 }
 
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
