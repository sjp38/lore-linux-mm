Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 810C882905
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:22 -0500 (EST)
Received: by pdjg10 with SMTP id g10so10212686pdj.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:22 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xg2si2761310pbc.112.2015.02.11.23.30.11
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:12 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 08/16] power: watch out zone range overlap
Date: Thu, 12 Feb 2015 16:32:12 +0900
Message-Id: <1423726340-4084-9-git-send-email-iamjoonsoo.kim@lge.com>
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

mark_free_pages() check and mark free status of page on the zone. Since
we iterate pfn to unmark free bit and we iterate buddy list directly
to mark free bit, if we don't check page's zone and mark it as non-free,
following buddy checker missed the page which is not on this zone and
we can get false free status.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1c45934b..7733663 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1365,6 +1365,9 @@ void mark_free_pages(struct zone *zone)
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
 
+			if (page_zone(page) != zone)
+				continue;
+
 			if (!swsusp_page_is_forbidden(page))
 				swsusp_unset_page_free(page);
 		}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
