Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id D80946B0038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 06:15:38 -0400 (EDT)
Received: by ykaz22 with SMTP id z22so77607420yka.2
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 03:15:38 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id i196si7914194ywg.216.2015.10.16.03.08.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Oct 2015 03:15:38 -0700 (PDT)
Message-ID: <5620CC36.4090107@huawei.com>
Date: Fri, 16 Oct 2015 18:06:46 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: reset migratetype if the range spans two pageblocks
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, mhocko@suse.com, js1304@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, alexander.h.duyck@redhat.com, zhongjiang@huawei.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

__rmqueue_fallback() will change the migratetype of pageblock,
so it is possible that two continuous pageblocks have different
migratetypes.

When freeing all pages of the two blocks, they will be merged
to 4M, and added to the buddy list which the migratetype is the
first pageblock's.

If later alloc some pages and split the 4M, the second pageblock
will be added to the buddy list, and the migratetype is the first
pageblock's, so it is different from the its pageblock's.

That means the page in buddy list's migratetype is different from
the page in pageblock's migratetype. This will make confusion.

However,if we change the hotpath, it will be performance degradation,
so any better ideas?

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48aaf7b..5c91348 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -726,6 +726,9 @@ static inline void __free_one_page(struct page *page,
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
 	zone->free_area[order].nr_free++;
+	/* If the range spans two pageblocks, reset the migratetype. */
+	if (order > pageblock_order)
+		change_pageblock_range(page, order, migratetype);
 }
 
 static inline int free_pages_check(struct page *page)
-- 
2.0.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
