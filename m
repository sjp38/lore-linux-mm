Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4A63E6B0038
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:06:25 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so293108eek.21
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 07:06:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si24072813eep.57.2013.12.12.07.06.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 07:06:24 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: page_alloc: Use zone node IDs to approximate locality
Date: Thu, 12 Dec 2013 15:06:18 +0000
Message-Id: <1386860779-2301-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386860779-2301-1-git-send-email-mgorman@suse.de>
References: <1386860779-2301-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

zone_local is using node_distance which is a more expensive call than
necessary. On x86, it's another function call in the allocator fast path
and increases cache footprint. This patch makes the assumption zones on a
local node will share the same node ID. The necessary information should
already be cache hot.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 64020eb..fd9677e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1816,7 +1816,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 
 static bool zone_local(struct zone *local_zone, struct zone *zone)
 {
-	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
+	return zone_to_nid(zone) == numa_node_id();
 }
 
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
