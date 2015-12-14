Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3A16B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 00:02:33 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so97454345pac.1
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 21:02:32 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 83si14460011pfl.23.2015.12.13.21.02.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Dec 2015 21:02:32 -0800 (PST)
Received: by pabur14 with SMTP id ur14so97972206pab.0
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 21:02:31 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/2] mm/compaction: fix invalid free_pfn and compact_cached_free_pfn
Date: Mon, 14 Dec 2015 14:02:20 +0900
Message-Id: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

free_pfn and compact_cached_free_pfn are the pointer that remember
restart position of freepage scanner. When they are reset or invalid,
we set them to zone_end_pfn because freepage scanner works in reverse
direction. But, because zone range is defined as [zone_start_pfn,
zone_end_pfn), zone_end_pfn is invalid to access. Therefore, we should
not store it to free_pfn and compact_cached_free_pfn. Instead, we need
to store zone_end_pfn - 1 to them. There is one more thing we should
consider. Freepage scanner scan reversely by pageblock unit. If free_pfn
and compact_cached_free_pfn are set to middle of pageblock, it regards
that sitiation as that it already scans front part of pageblock so we
lose opportunity to scan there. To fix-up, this patch do round_down()
to guarantee that reset position will be pageblock aligned.

Note that thanks to the current pageblock_pfn_to_page() implementation,
actual access to zone_end_pfn doesn't happen until now. But, following
patch will change pageblock_pfn_to_page() so this patch is needed
from now on.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 585de54..56fa321 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -200,7 +200,8 @@ static void reset_cached_positions(struct zone *zone)
 {
 	zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
 	zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
-	zone->compact_cached_free_pfn = zone_end_pfn(zone);
+	zone->compact_cached_free_pfn =
+			round_down(zone_end_pfn(zone) - 1, pageblock_nr_pages);
 }
 
 /*
@@ -1371,11 +1372,11 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 */
 	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
 	cc->free_pfn = zone->compact_cached_free_pfn;
-	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
-		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
+	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
+		cc->free_pfn = round_down(end_pfn - 1, pageblock_nr_pages);
 		zone->compact_cached_free_pfn = cc->free_pfn;
 	}
-	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
+	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
 		cc->migrate_pfn = start_pfn;
 		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
