Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 939DC6B005D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 06:07:52 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDD004SQG92MYZ0@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Nov 2012 20:07:50 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MDD005O9G8TX340@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 12 Nov 2012 20:07:50 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: cma: WARN if freed memory is still in use
Date: Mon, 12 Nov 2012 12:07:26 +0100
Message-id: <1352718446-32313-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Memory return to free_contig_range() must have no other references. Let
kernel to complain loudly if page reference count is not equal to 1.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 mm/page_alloc.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 022e4ed..290c2eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5888,8 +5888,13 @@ done:
 
 void free_contig_range(unsigned long pfn, unsigned nr_pages)
 {
-	for (; nr_pages--; ++pfn)
-		__free_page(pfn_to_page(pfn));
+	struct page *page = pfn_to_page(pfn);
+	int refcount = nr_pages;
+	for (; nr_pages--; page++) {
+		refcount -= page_count(page) == 1;
+		__free_page(page);
+	}
+	WARN(refcount != 0, "some pages are still in use!\n");
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
