Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 197456B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:08:28 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so12543505pbc.26
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:08:27 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id gx4si6630464pbc.21.2014.02.14.10.08.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 14 Feb 2014 10:08:25 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0Z001M2ZPZVQ40@mailout2.samsung.com> for
 linux-mm@kvack.org; Sat, 15 Feb 2014 03:08:23 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [RFC][PATCH] mm/page_alloc: fix freeing of MIGRATE_RESERVE migratetype
 pages
Date: Fri, 14 Feb 2014 19:08:18 +0100
Message-id: <1995877.GHAxfnIsTj@amdc1032>
MIME-version: 1.0
Content-transfer-encoding: 7Bit
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Pages allocated from MIGRATE_RESERVE migratetype pageblocks
are not freed back to MIGRATE_RESERVE migratetype free
lists in free_pcppages_bulk() if we got to that function
through drain_[zone_]pages() or __zone_pcp_update().
The freeing through free_hot_cold_page() is okay because
freepage migratetype is set to pageblock migratetype before
calling free_pcppages_bulk().  If pages of MIGRATE_RESERVE
migratetype end up on the free lists of other migratetype
whole Reserved pageblock may be later changed to the other
migratetype in __rmqueue_fallback() and it will be never
changed back to be a Reserved pageblock.  Fix the issue by
preserving freepage migratetype as a pageblock migratetype
(instead of overriding it to the requested migratetype)
for MIGRATE_RESERVE migratetype pages in rmqueue_bulk().

The problem was introduced in v2.6.31 by commit ed0ae21
("page allocator: do not call get_pageblock_migratetype()
more than necessary").

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
---
 include/linux/mmzone.h |    5 +++++
 mm/page_alloc.c        |   10 +++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h	2014-02-14 18:59:08.177837747 +0100
+++ b/include/linux/mmzone.h	2014-02-14 18:59:09.077837731 +0100
@@ -63,6 +63,11 @@ enum {
 	MIGRATE_TYPES
 };
 
+static inline bool is_migrate_reserve(int migratetype)
+{
+	return unlikely(migratetype == MIGRATE_RESERVE);
+}
+
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #else
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2014-02-14 18:59:08.185837746 +0100
+++ b/mm/page_alloc.c	2014-02-14 18:59:09.077837731 +0100
@@ -1174,7 +1174,7 @@ static int rmqueue_bulk(struct zone *zon
 			unsigned long count, struct list_head *list,
 			int migratetype, int cold)
 {
-	int mt = migratetype, i;
+	int mt, i;
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
@@ -1195,9 +1195,13 @@ static int rmqueue_bulk(struct zone *zon
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
+		mt = get_pageblock_migratetype(page);
 		if (IS_ENABLED(CONFIG_CMA)) {
-			mt = get_pageblock_migratetype(page);
-			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
+			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt) &&
+			    !is_migrate_reserve(mt))
+				mt = migratetype;
+		} else {
+			if (!is_migrate_reserve(mt))
 				mt = migratetype;
 		}
 		set_freepage_migratetype(page, mt);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
