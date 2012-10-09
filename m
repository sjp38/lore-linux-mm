Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id CE44D6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 07:46:01 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBM00DLQJCBVTO0@mailout4.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Oct 2012 20:46:00 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MBM00KDWJCNLK30@mmp1.samsung.com> for linux-mm@kvack.org;
 Tue, 09 Oct 2012 20:46:00 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] mm: compaction: fix bit ranges in
 {get,clear,set}_pageblock_skip()
Date: Tue, 09 Oct 2012 13:43:47 +0200
MIME-version: 1.0
Message-id: <201210091343.47857.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Thierry Reding <thierry.reding@avionic-design.de>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-mm@kvack.org

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] mm: compaction: fix bit ranges in {get,clear,set}_pageblock_skip() 

{get,clear,set}_pageblock_skip() use incorrect bit ranges (please compare
to bit ranges used by {get,set}_pageblock_flags() used for migration types)
and can overwrite pageblock migratetype of the next pageblock in the bitmap.

This fix is needed for "mm: compaction: cache if a pageblock was scanned and
no pages were isolated" patch.

Acked-by: Mel Gorman <mgorman@suse.de>
Tested-by: Thierry Reding <thierry.reding@avionic-design.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
Andrew, please apply.

 include/linux/pageblock-flags.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: b/include/linux/pageblock-flags.h
===================================================================
--- a/include/linux/pageblock-flags.h	2012-10-09 12:50:20.366340001 +0200
+++ b/include/linux/pageblock-flags.h	2012-10-09 12:50:31.794339996 +0200
@@ -71,13 +71,13 @@ void set_pageblock_flags_group(struct pa
 #ifdef CONFIG_COMPACTION
 #define get_pageblock_skip(page) \
 			get_pageblock_flags_group(page, PB_migrate_skip,     \
-							PB_migrate_skip + 1)
+							PB_migrate_skip)
 #define clear_pageblock_skip(page) \
 			set_pageblock_flags_group(page, 0, PB_migrate_skip,  \
-							PB_migrate_skip + 1)
+							PB_migrate_skip)
 #define set_pageblock_skip(page) \
 			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
-							PB_migrate_skip + 1)
+							PB_migrate_skip)
 #endif /* CONFIG_COMPACTION */
 
 #define get_pageblock_flags(page) \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
