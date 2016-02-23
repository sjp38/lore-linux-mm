Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CBE9828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:21:29 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id a4so214029153wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:21:29 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id w7si40153858wmw.101.2016.02.23.07.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:21:28 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 454A01C1D23
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:21:28 +0000 (GMT)
Date: Tue, 23 Feb 2016 15:21:26 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 27/27] mm: page_alloc: Cache the last node whose dirty limit
 is reached
Message-ID: <20160223152126.GM2854@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

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
index 4fcd6298b9a1..b20713c42bd1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2580,6 +2580,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
+	struct pglist_data *last_pgdat_dirty_limit = NULL;
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -2619,8 +2620,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		 * will require awareness of zones in the
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
