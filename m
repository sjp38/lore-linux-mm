Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 575E7828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:20:34 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l184so13395441lfl.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:20:34 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id v129si4126697wme.91.2016.06.21.07.20.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 07:20:33 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id CE43698B21
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:20:32 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 25/27] mm: page_alloc: Cache the last node whose dirty limit is reached
Date: Tue, 21 Jun 2016 15:16:04 +0100
Message-Id: <1466518566-30034-26-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b5080475481..6d0a527cff3d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2853,6 +2853,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 {
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
+	struct pglist_data *last_pgdat_dirty_limit = NULL;
+
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
@@ -2885,8 +2887,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
