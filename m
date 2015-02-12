Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id CD1F98292A
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:34 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ey11so9569101pad.11
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:34 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id fi4si3860038pbc.179.2015.02.11.23.30.14
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:15 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 03/16] mm/highmem: make nr_free_highpages() handles all highmem zones by itself
Date: Thu, 12 Feb 2015 16:32:07 +0900
Message-Id: <1423726340-4084-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

nr_free_highpages() manually add statistics per each highmem zone
and return total value for them. Whenever we add a new highmem zone,
we need to consider this function and it's really troublesome. Make
it handles all highmem zones by itself.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/highmem.c |   12 ++++--------
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
