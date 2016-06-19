Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C43666B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 21:49:10 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id y82so213709959oig.3
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 18:49:10 -0700 (PDT)
Received: from m12-13.163.com (m12-13.163.com. [220.181.12.13])
        by mx.google.com with ESMTP id i185si3426361ith.52.2016.06.18.18.49.08
        for <linux-mm@kvack.org>;
        Sat, 18 Jun 2016 18:49:10 -0700 (PDT)
From: Wenwei Tao <wwtao0320@163.com>
Subject: [RFC PATCH 2/3] mm, page_alloc: get page migreate type again when related to highatomic
Date: Sun, 19 Jun 2016 09:48:47 +0800
Message-Id: <1466300927-1364-1-git-send-email-wwtao0320@163.com>
In-Reply-To: <1466242457-2440-1-git-send-email-wwtao0320@163.com>
References: <1466242457-2440-1-git-send-email-wwtao0320@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ww.tao0320@gmail.com

From: Wenwei Tao <ww.tao0320@gmail.com>

The migratetype might get staled, pages might have become highatomic when
we try to free them to the allocator, we might not want to put highatomic
pages into other buddy lists, since they are reserved only for atomic high
order use. And also highatomic pages could have been unreserved,
put them into the hightatomic buddy list might exceed the limit of
highatomic pages. So get the pages migreate type again to put them into
the right lists.

Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
---
 mm/page_alloc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 19f9e76..b72b771 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1079,9 +1079,11 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int batch_free = 0;
 	unsigned long nr_scanned;
 	bool isolated_pageblocks;
+	bool reserved_highatomic;
 
 	spin_lock(&zone->lock);
 	isolated_pageblocks = has_isolate_pageblock(zone);
+	reserved_highatomic = !!zone->nr_reserved_highatomic;
 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
 	if (nr_scanned)
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
@@ -1118,8 +1120,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			mt = get_pcppage_migratetype(page);
 			/* MIGRATE_ISOLATE page should not go to pcplists */
 			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
+			VM_BUG_ON_PAGE(mt == MIGRATE_HIGHATOMIC, page);
 			/* Pageblock could have been isolated meanwhile */
-			if (unlikely(isolated_pageblocks))
+			if (unlikely(isolated_pageblocks ||
+					reserved_highatomic))
 				mt = get_pageblock_migratetype(page);
 
 			if (bulkfree_pcp_prepare(page))
@@ -1144,7 +1148,9 @@ static void free_one_page(struct zone *zone,
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
 	if (unlikely(has_isolate_pageblock(zone) ||
-		is_migrate_isolate(migratetype))) {
+		zone->nr_reserved_highatomic ||
+		is_migrate_isolate(migratetype) ||
+		migratetype == MIGRATE_HIGHATOMIC)) {
 		migratetype = get_pfnblock_migratetype(page, pfn);
 	}
 	__free_one_page(page, pfn, zone, order, migratetype);
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
