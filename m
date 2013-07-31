Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 6492E6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:50:02 -0400 (EDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MQS00GW2LVC72L0@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 31 Jul 2013 17:50:00 +0900 (KST)
From: Joonyoung Shim <jy0922.shim@samsung.com>
Subject: [PATCH] Revert
 "mm/memory-hotplug: fix lowmem count overflow when offline pages"
Date: Wed, 31 Jul 2013 17:50:02 +0900
Message-id: <1375260602-2462-1-git-send-email-jy0922.shim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, kosaki.motohiro@gmail.com

This reverts commit cea27eb2a202959783f81254c48c250ddd80e129.

Fixed to adjust totalhigh_pages when hot-removing memory by commit
3dcc0571cd64816309765b7c7e4691a4cadf2ee7, so that commit occurs
duplicated decreasing of totalhigh_pages.

Signed-off-by: Joonyoung Shim <jy0922.shim@samsung.com>
---
The commit cea27eb2a202959783f81254c48c250ddd80e129 is only for stable,
is it right?

 mm/page_alloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..2b28216 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6274,10 +6274,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		list_del(&page->lru);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
-#ifdef CONFIG_HIGHMEM
-		if (PageHighMem(page))
-			totalhigh_pages -= 1 << order;
-#endif
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
