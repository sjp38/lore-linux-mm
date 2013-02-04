Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 558576B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 05:27:29 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MHO00LRWYDR4XM0@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Feb 2013 19:27:27 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MHO00ERFYDFAT20@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 04 Feb 2013 19:27:27 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: cma: fix accounting of CMA pages placed in high memory
Date: Mon, 04 Feb 2013 11:27:05 +0100
Message-id: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: m.szyprowski@samsung.com, akpm@linux-foundation.org, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com

The total number of low memory pages is determined as
totalram_pages - totalhigh_pages, so without this patch all CMA
pageblocks placed in highmem were accounted to low memory.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/page_alloc.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f5bab0a..6415d93 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -773,6 +773,10 @@ void __init init_cma_reserved_pageblock(struct page *page)
 	set_pageblock_migratetype(page, MIGRATE_CMA);
 	__free_pages(page, pageblock_order);
 	totalram_pages += pageblock_nr_pages;
+#ifdef CONFIG_HIGHMEM
+	if (PageHighMem(page))
+		totalhigh_pages += pageblock_nr_pages;
+#endif
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
