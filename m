Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5547A6B027B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:24:05 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id v188so19256258wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:24:05 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id y186si3246007wmy.43.2016.04.06.04.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:24:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 0610B1C1D64
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:24:04 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 25/27] mm: page_alloc: Cache the last node whose dirty limit is reached
Date: Wed,  6 Apr 2016 12:22:14 +0100
Message-Id: <1459941736-3633-26-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
References: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

If a page is about to be dirtied then the page allocator attempts to limit
the total number of dirty pages that exists in any given zone. The call
to node_dirty_ok is expensive so this patch records if the last pgdat
examined hit the dirty limits. In some cases, this reduces the number
of calls to node_dirty_ok().

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 54cfe26dcc66..a6e6184d3e38 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2607,6 +2607,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
+	struct pglist_data *last_pgdat_dirty_limit = NULL;
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -2639,8 +2640,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		 * will require awareness of nodes in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if (ac->spread_dirty_pages && !node_dirty_ok(zone->zone_pgdat))
-			continue;
+		if (ac->spread_dirty_pages) {
+			if (last_pgdat_dirty_limit == zone->zone_pgdat)
+				continue;
+
+			if (!node_dirty_ok(zone->zone_pgdat)) {
+				last_pgdat_dirty_limit = zone->zone_pgdat;
+				continue;
+			}
+		}
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
