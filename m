Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E4EE38292A
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:32 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2869672pab.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:32 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id cy5si3983852pbc.87.2015.02.11.23.30.14
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:15 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 14/16] mm/cma: print stealed page count
Date: Thu, 12 Feb 2015 16:32:18 +0900
Message-Id: <1423726340-4084-15-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reserved pages for CMA could be on different zone. To figure out
memory map correctly, per zone number of stealed pages for CMA
would be needed.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/cma.c |   28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index 267fa14..b165c1a 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -40,6 +40,8 @@ struct cma cma_areas[MAX_CMA_AREAS];
 unsigned cma_area_count;
 static DEFINE_MUTEX(cma_mutex);
 
+static unsigned long __initdata stealed_pages[MAX_NUMNODES][MAX_NR_ZONES];
+
 unsigned long cma_total_pages(unsigned long node_start_pfn,
 				unsigned long node_end_pfn)
 {
@@ -98,6 +100,7 @@ static int __init cma_activate_area(struct cma *cma)
 	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
 	unsigned i = cma->count >> pageblock_order;
 	int nid;
+	int zone_index;
 
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 
@@ -125,6 +128,8 @@ static int __init cma_activate_area(struct cma *cma)
 			if (page_to_nid(pfn_to_page(pfn)) != nid)
 				goto err;
 		}
+		zone_index = zone_idx(page_zone(pfn_to_page(base_pfn)));
+		stealed_pages[nid][zone_index] += pageblock_nr_pages;
 		init_cma_reserved_pageblock(base_pfn);
 	} while (--i);
 
@@ -145,7 +150,9 @@ err:
 
 static int __init cma_init_reserved_areas(void)
 {
-	int i;
+	int i, j;
+	pg_data_t *pgdat;
+	struct zone *zone;
 
 	for (i = 0; i < cma_area_count; i++) {
 		int ret = cma_activate_area(&cma_areas[i]);
@@ -154,6 +161,25 @@ static int __init cma_init_reserved_areas(void)
 			return ret;
 	}
 
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		for (j = 0; j < MAX_NR_ZONES; j++) {
+			if (stealed_pages[i][j])
+				goto print;
+		}
+		continue;
+
+print:
+		pgdat = NODE_DATA(i);
+		for (j = 0; j < MAX_NR_ZONES; j++) {
+			if (!stealed_pages[i][j])
+				continue;
+
+			zone = pgdat->node_zones + j;
+			pr_info("Steal %lu pages from %s\n",
+				stealed_pages[i][j], zone->name);
+		}
+	}
+
 	return 0;
 }
 core_initcall(cma_init_reserved_areas);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
