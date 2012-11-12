Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 62A586B004D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 03:30:13 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDD008QZ8Y19BS0@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Nov 2012 17:30:11 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MDD00LHE8Y0C190@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 12 Nov 2012 17:30:11 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: use migrate_prep() instead of migrate_prep_local()
Date: Mon, 12 Nov 2012 09:29:49 +0100
Message-id: <1352708989-25359-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, SeongHwan Yoon <sunghwan.yun@samsung.com>

__alloc_contig_migrate_range() should use all possible ways to get all the
pages migrated from the given memory range, so pruning per-cpu lru lists
for all CPUs is required, regadless the cost of such operation. Otherwise
some pages which got stuck at per-cpu lru list might get missed by
migration procedure causing the contiguous allocation to fail.

Reported-by: SeongHwan Yoon <sunghwan.yun@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1bfe2b0..fcb9719 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5677,7 +5677,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 	unsigned int tries = 0;
 	int ret = 0;
 
-	migrate_prep_local();
+	migrate_prep();
 
 	while (pfn < end || !list_empty(&cc->migratepages)) {
 		if (fatal_signal_pending(current)) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
