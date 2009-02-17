Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 623F16B00B8
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:46:23 -0500 (EST)
Date: Tue, 17 Feb 2009 20:48:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] vmscan: respect higher order in zone_reclaim()
Message-ID: <20090217194826.GA17415@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

zone_reclaim() already tries to free the requested 2^order pages but
doesn't pass the order information into the inner reclaim code.

This prevents lumpy reclaim from happening on higher orders although
the caller explicitely asked for that.

Fix it up by initializing the order field of the scan control
according to the request.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |    1 +
 1 file changed, 1 insertion(+)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2297,6 +2297,7 @@ static int __zone_reclaim(struct zone *z
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
+		.order = order,
 		.isolate_pages = isolate_pages_global,
 	};
 	unsigned long slab_reclaimable;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
