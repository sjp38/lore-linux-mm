Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0156B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:10:27 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id td3so78792261pab.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:27 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id l27si17789011pfj.18.2016.03.31.19.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:10:26 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id td3so78792115pab.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:10:26 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 3/4] mm/highmem: make nr_free_highpages() handles all highmem zones by itself
Date: Fri,  1 Apr 2016 11:10:09 +0900
Message-Id: <1459476610-31076-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459476610-31076-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

nr_free_highpages() manually add statistics per each highmem zone
and return total value for them. Whenever we add a new highmem zone,
we need to consider this function and it's really troublesome. Make
it handles all highmem zones by itself.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/highmem.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 123bcd3..50b4ca6 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -112,16 +112,12 @@ EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
 
 unsigned int nr_free_highpages (void)
 {
-	pg_data_t *pgdat;
+	struct zone *zone;
 	unsigned int pages = 0;
 
-	for_each_online_pgdat(pgdat) {
-		pages += zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
-			NR_FREE_PAGES);
-		if (zone_movable_is_highmem())
-			pages += zone_page_state(
-					&pgdat->node_zones[ZONE_MOVABLE],
-					NR_FREE_PAGES);
+	for_each_populated_zone(zone) {
+		if (is_highmem(zone))
+			pages += zone_page_state(zone, NR_FREE_PAGES);
 	}
 
 	return pages;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
