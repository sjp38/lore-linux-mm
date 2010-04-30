Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8D16004A3
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 19:06:03 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/5] vmscan: fix unmapping behaviour for RECLAIM_SWAP
Date: Sat,  1 May 2010 01:05:29 +0200
Message-Id: <20100430224315.912441727@cmpxchg.org>
In-Reply-To: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
Content-Disposition: inline; filename=vmscan-fix-unmapping-behaviour-for-RECLAIM_SWAP.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The RECLAIM_SWAP flag in zone_reclaim_mode controls whether
zone_reclaim() is allowed to swap or not (obviously).

This is currently implemented by allowing or forbidding reclaim to
unmap pages, which also controls reclaim of shared pages and is thus
not appropriate.

We can do better by using the sc->may_swap parameter instead, which
controls whether the anon lists are scanned.

Unmapping of pages is then allowed per default from zone_reclaim().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2563,8 +2563,8 @@ static int __zone_reclaim(struct zone *z
 	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
-		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
-		.may_swap = 1,
+		.may_unmap = 1,
+		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,
 				       SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
