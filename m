Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 328259003C8
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 05:36:19 -0400 (EDT)
Received: by ioeg141 with SMTP id g141so80152957ioe.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:36:19 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id pc6si9073807pdb.191.2015.07.31.02.36.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 02:36:18 -0700 (PDT)
Message-ID: <55BB4027.7080200@huawei.com>
Date: Fri, 31 Jul 2015 17:30:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: add the block to the tail of the list in expand()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

__free_one_page() will judge whether the the next-highest order is free,
then add the block to the tail or not. So when we split large order block, 
add the small block to the tail, it will reduce fragment.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 506eac8..517a11c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1267,7 +1267,12 @@ static inline void expand(struct zone *zone, struct page *page,
 			set_page_guard(zone, &page[size], high, migratetype);
 			continue;
 		}
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		/*
+		 * Add the block to the tail of the list, so it's less likely
+		 * to be used soon and more likely to be merged when the page
+		 * is freed.
+		 */
+		list_add_tail(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
