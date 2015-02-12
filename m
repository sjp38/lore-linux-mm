Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 69F6B6B006E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:18 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id eu11so9577092pac.10
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:18 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id zc5si3998485pbc.76.2015.02.11.23.30.10
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:11 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 06/16] mm/page_alloc: watch out zone range overlap
Date: Thu, 12 Feb 2015 16:32:10 +0900
Message-Id: <1423726340-4084-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In the following patches, new zone, ZONE_CMA, will be introduced and
it would be overlapped with other zones. Currently, many places
iterating pfn range doesn't consider possibility of zone overlap and
this would cause a problem such as printing wrong statistics information.
To prevent this situation, this patch add some code to consider zone
overlapping before adding ZONE_CMA.

setup_zone_migrate_reserve() reserve some pages for specific zone so
should consider zone overlap.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c784035..1c45934b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4040,8 +4040,8 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 			continue;
 		page = pfn_to_page(pfn);
 
-		/* Watch out for overlapping nodes */
-		if (page_to_nid(page) != zone_to_nid(zone))
+		/* Watch out for overlapping zones */
+		if (page_zone(page) != zone)
 			continue;
 
 		block_migratetype = get_pageblock_migratetype(page);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
