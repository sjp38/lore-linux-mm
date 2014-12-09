Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id F04766B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 02:51:49 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so59313pab.18
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 23:51:49 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id d5si569432pdd.145.2014.12.08.23.51.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 08 Dec 2014 23:51:48 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGB00HTD1UA1SB0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Dec 2014 16:51:46 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 1/3] mm: page_isolation: remove redundant moving for isolated
 buddy pages
Date: Tue, 09 Dec 2014 15:50:35 +0800
Message-id: <000101d01384$fac61240$f05236c0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, vbabka@suse.cz, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The commit ad53f92e(fix incorrect isolation behavior by rechecking migratetype)
patch series describe the race between page isolation and alloc/free path, and
fix the race.

Now, after the pageblock has been isolated, free buddy pages are already in
the free_list[MIGRATE_ISOLATE] and will not be allocated for usage. So the
current freepage_migratetype check is unnecessary and it will cause redundant
page move. That is to say, even if the buddy page's migratetype is not
MIGRATE_ISOLATE, the page is in free_list[MIGRATE_ISOLATE], we just move it
from free_list[MIGRATE_ISOLATE] to free_list[MIGRATE_ISOLATE].

This patch removes the unnecessary freepage_migratetype check and the
redundant page moving.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_isolation.c |   17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index c8778f7..6e5174d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -221,23 +221,8 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
-		if (PageBuddy(page)) {
-			/*
-			 * If race between isolatation and allocation happens,
-			 * some free pages could be in MIGRATE_MOVABLE list
-			 * although pageblock's migratation type of the page
-			 * is MIGRATE_ISOLATE. Catch it and move the page into
-			 * MIGRATE_ISOLATE list.
-			 */
-			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
-				struct page *end_page;
-
-				end_page = page + (1 << page_order(page)) - 1;
-				move_freepages(page_zone(page), page, end_page,
-						MIGRATE_ISOLATE);
-			}
+		if (PageBuddy(page))
 			pfn += 1 << page_order(page);
-		}
 		else if (page_count(page) == 0 &&
 			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
 			pfn += 1;
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
