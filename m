Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACD66B006E
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 03:53:10 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so1616721pad.27
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 00:53:10 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id w11si1680606pdj.398.2014.07.04.00.53.04
        for <linux-mm@kvack.org>;
        Fri, 04 Jul 2014 00:53:09 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 08/10] mm/page_alloc: use get_onbuddy_migratetype() to get buddy list type
Date: Fri,  4 Jul 2014 16:57:53 +0900
Message-Id: <1404460675-24456-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

When isolating free page, what we want to know is which list
the page is linked. If it is linked in isolate migratetype buddy list,
we can skip watermark check and freepage counting. And if it is linked
in CMA migratetype buddy list, we need to fixup freepage counting. For
this purpose, get_onbuddy_migratetype() is more fit and cheap than
get_pageblock_migratetype(). So use it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e1c4c3e..d9fb8bb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1597,7 +1597,7 @@ static int __isolate_free_page(struct page *page, unsigned int order)
 	BUG_ON(!PageBuddy(page));
 
 	zone = page_zone(page);
-	mt = get_pageblock_migratetype(page);
+	mt = get_onbuddy_migratetype(page);
 
 	if (!is_migrate_isolate(mt)) {
 		/* Obey watermarks as if the page was being allocated */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
