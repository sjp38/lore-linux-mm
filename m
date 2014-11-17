Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 69CE06B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 05:41:40 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so7202140pad.15
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 02:41:40 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id zs5si34973819pac.18.2014.11.17.02.41.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 17 Nov 2014 02:41:39 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NF60027YJ1CGN90@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 17 Nov 2014 19:41:36 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm: page_alloc: store updated page migratetype to avoid
 misusing stale value
Date: Mon, 17 Nov 2014 18:40:10 +0800
Message-id: <000301d00253$0fcd0560$2f671020$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>, mina86@mina86.com, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>

The commit ad53f92e(fix incorrect isolation behavior by rechecking migratetype)
patch series describe the race between page isolation and free path, and try to
fix the freepage account issues.

However, there is still a little issue: freed page could have stale migratetype
in the free_list. This would cause some bad behavior if we misuse this stale
value later.
Such as: in __test_page_isolated_in_pageblock() we check the buddy page, if the
page's stale migratetype is not MIGRATE_ISOLATE, which will cause unnecessary
page move action.

This patch store the page's updated migratetype after free the page to the
free_list to avoid subsequent misusing stale value, and use a WARN_ON_ONCE
to catch a potential undetected race between isolatation and free path.


Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_alloc.c     |    1 +
 mm/page_isolation.c |   17 +++++------------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c9..177fca0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -622,6 +622,7 @@ static inline void __free_one_page(struct page *page,
 	}
 
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
+	set_freepage_migratetype(page, migratetype);
 out:
 	zone->free_area[order].nr_free++;
 }
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index c8778f7..0618071 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -223,19 +223,12 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 		page = pfn_to_page(pfn);
 		if (PageBuddy(page)) {
 			/*
-			 * If race between isolatation and allocation happens,
-			 * some free pages could be in MIGRATE_MOVABLE list
-			 * although pageblock's migratation type of the page
-			 * is MIGRATE_ISOLATE. Catch it and move the page into
-			 * MIGRATE_ISOLATE list.
+			 * Use a WARN_ON_ONCE to catch a potential undetected
+			 * race between isolatation and free pages, even if
+			 * we try to avoid this issue.
 			 */
-			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
-				struct page *end_page;
-
-				end_page = page + (1 << page_order(page)) - 1;
-				move_freepages(page_zone(page), page, end_page,
-						MIGRATE_ISOLATE);
-			}
+			WARN_ON_ONCE(get_freepage_migratetype(page) !=
+					MIGRATE_ISOLATE);
 			pfn += 1 << page_order(page);
 		}
 		else if (page_count(page) == 0 &&
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
