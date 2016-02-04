Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C04F84403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 01:19:40 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 65so33780236pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:19:40 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id x9si14399007pas.214.2016.02.03.22.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 22:19:40 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id w123so33902233pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:19:40 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 1/3] mm/compaction: fix invalid free_pfn and compact_cached_free_pfn
Date: Thu,  4 Feb 2016 15:19:33 +0900
Message-Id: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
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

Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
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
