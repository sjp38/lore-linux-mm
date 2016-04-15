Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0887782F66
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:18:01 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so64129979lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:18:00 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id he10si1868778wjb.155.2016.04.15.02.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:17:59 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 857091C10DB
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:17:59 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 25/27] mm: page_alloc: Cache the last node whose dirty limit is reached
Date: Fri, 15 Apr 2016 10:13:31 +0100
Message-Id: <1460711613-2761-26-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
index 125f344ff105..d0ca26152716 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2889,6 +2889,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 {
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
+	struct pglist_data *last_pgdat_dirty_limit = NULL;
+
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
@@ -2921,8 +2923,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
