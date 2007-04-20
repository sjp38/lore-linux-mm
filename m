From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/3] kswapd: use reclaim order in background reclaim
References: <exportbomb.1177081388@pinky>
Message-ID: <d29ea545cf8e69553d30fd2b35f55f9f@pinky>
Date: Fri, 20 Apr 2007 16:03:34 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When an allocator has to dip below the low water mark for a
zone, kswapd is awoken to start background reclaim.  The highest
order of these dipping allocations are accumulated on the zone.
With this patch kswapd uses this hint to force reclaim at that
order via balance_pgdat().

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 428da1a..466435f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1212,6 +1212,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
+		.order = order,
 	};
 	/*
 	 * temp_priority is used to remember the scanning priority at which

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
