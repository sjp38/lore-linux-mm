Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4A72A6B0074
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 03:09:57 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so789641pad.11
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 00:09:57 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id h7si5245494pdl.85.2014.11.06.00.09.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 06 Nov 2014 00:09:56 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NEL00GVBYOHWP00@mailout2.samsung.com> for
 linux-mm@kvack.org; Thu, 06 Nov 2014 17:09:53 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 2/2] mm: page_isolation: fix zone_freepage accounting
Date: Thu, 06 Nov 2014 16:09:08 +0800
Message-id: <000101cff999$09225070$1b66f150$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com, 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, mina86@mina86.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

If race between isolatation and allocation happens, we could need to move
some freepages to MIGRATE_ISOLATE in __test_page_isolated_in_pageblock().
The current code ignores the zone_freepage accounting after the move,
which cause the zone NR_FREE_PAGES and NR_FREE_CMA_PAGES statistics incorrect.

This patch fixes this rare issue.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_isolation.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 3ddc8b3..15b51de 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -193,12 +193,15 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			 * is MIGRATE_ISOLATE. Catch it and move the page into
 			 * MIGRATE_ISOLATE list.
 			 */
-			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
+			int migratetype = get_freepage_migratetype(page);
+			if (migratetype != MIGRATE_ISOLATE) {
 				struct page *end_page;
 
 				end_page = page + (1 << page_order(page)) - 1;
 				move_freepages(page_zone(page), page, end_page,
 						MIGRATE_ISOLATE);
+				__mod_zone_freepage_state(zone,
+					-(1 << page_order(page)), migratetype);
 			}
 			pfn += 1 << page_order(page);
 		}
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
