Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1548E6B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 05:38:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b2so238664185pgc.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 02:38:51 -0800 (PST)
Received: from dggrg01-dlp.huawei.com ([45.249.212.187])
        by mx.google.com with ESMTPS id z88si22172682pff.228.2017.03.07.02.38.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 02:38:50 -0800 (PST)
Message-ID: <58BE8C91.20600@huawei.com>
Date: Tue, 7 Mar 2017 18:33:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 1/2] mm: use MIGRATE_HIGHATOMIC as late as possible
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

MIGRATE_HIGHATOMIC page blocks are reserved for an atomic
high-order allocation, so use it as late as possible.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40d79a6..2331840 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2714,14 +2714,12 @@ struct page *rmqueue(struct zone *preferred_zone,
 	spin_lock_irqsave(&zone->lock, flags);
 
 	do {
-		page = NULL;
-		if (alloc_flags & ALLOC_HARDER) {
+		page = __rmqueue(zone, order, migratetype);
+		if (!page && alloc_flags & ALLOC_HARDER) {
 			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
 			if (page)
 				trace_mm_page_alloc_zone_locked(page, order, migratetype);
 		}
-		if (!page)
-			page = __rmqueue(zone, order, migratetype);
 	} while (page && check_new_pages(page, order));
 	spin_unlock(&zone->lock);
 	if (!page)
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
