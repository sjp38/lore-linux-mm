Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BD40E6B0070
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 02:53:55 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so76604pad.3
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 23:53:55 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id tk10si590869pac.134.2014.12.08.23.53.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 08 Dec 2014 23:53:54 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGB00H2Q1XR1SC0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Dec 2014 16:53:51 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 3/3] mm: page_alloc: remove redundant
 set_freepage_migratetype() calls
Date: Tue, 09 Dec 2014 15:51:49 +0800
Message-id: <000301d01385$45554a60$cfffdf20$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, vbabka@suse.cz, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The freepage_migratetype is a temporary cached value which represents
the free page's pageblock migratetype. Now we use it in two scenarios:

1. Use it as a cached value in page freeing path. This cached value
is temporary and non-100% update, which help us decide which pcp
freelist and buddy freelist the page should go rather than using
get_pfnblock_migratetype() to save some instructions.
When there is race between page isolation and free path, we need use
additional method to get a accurate value to put the free pages to
the correct freelist and get a precise free pages statistics.

2. Use it in page alloc path to update NR_FREE_CMA_PAGES statistics.

This patch aims at the scenario 1 and removes two redundant
set_freepage_migratetype() calls, which will make sense in the hot path.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_alloc.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c9..99af01a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -775,7 +775,6 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	set_freepage_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
 	local_irq_restore(flags);
 }
@@ -1024,7 +1023,6 @@ int move_freepages(struct zone *zone,
 		order = page_order(page);
 		list_move(&page->lru,
 			  &zone->free_area[order].free_list[migratetype]);
-		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
