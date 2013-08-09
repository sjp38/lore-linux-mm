Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id E19446B0034
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 20:44:57 -0400 (EDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR800J5GNEPC9C0@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Aug 2013 09:44:56 +0900 (KST)
From: Joonyoung Shim <jy0922.shim@samsung.com>
Subject: [PATCH v2] Revert
 "mm/memory-hotplug: fix lowmem count overflow when offline pages"
Date: Fri, 09 Aug 2013 09:44:52 +0900
Message-id: <1376009092-9676-1-git-send-email-jy0922.shim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, kosaki.motohiro@gmail.com, b.zolnierkie@samsung.com

This reverts commit cea27eb2a202959783f81254c48c250ddd80e129
("mm/memory-hotplug: fix lowmem count overflow when offline pages").

The fixed bug by commit cea27eb was fixed to another way by commit
3dcc057 ("mm: correctly update zone->managed_pages"). The commit 3dcc057
enhances memory_hotplug.c to adjust totalhigh_pages when hot-removing
memory, for details please refer to:
http://marc.info/?l=linux-mm&m=136957578620221&w=2

So, if not revert commit cea27eb, currently causes duplicated decreasing
of totalhigh_pages.

Signed-off-by: Joonyoung Shim <jy0922.shim@samsung.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
Changes v1 -> v2:
 - Update commit descriptions suggested by Bartlomiej.

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
