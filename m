Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id F04626B028D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:45:48 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l6so182309114wml.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:45:48 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id v124si23234914wmg.0.2016.04.12.03.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:45:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 93B201C25FB
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:45:47 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 26/28] mm: page_alloc: Cache the last node whose dirty limit is reached
Date: Tue, 12 Apr 2016 11:45:02 +0100
Message-Id: <1460457904-754-13-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
 <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

If a page is about to be dirtied then the page allocator attempts to limit
the total number of dirty pages that exists in any given zone. The call
to node_dirty_ok is expensive so this patch records if the last pgdat
examined hit the dirty limits. In some cases, this reduces the number
of calls to node_dirty_ok().

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b54f45876130..490a3cd34b7d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2699,6 +2699,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 {
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
+	struct pglist_data *last_pgdat_dirty_limit = NULL;
+
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
@@ -2731,8 +2733,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
 		if (!zone_watermark_fast(zone, order, mark,
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
