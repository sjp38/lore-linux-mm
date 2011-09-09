Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AC95D6B0202
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 06:57:34 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/14] mm: Ignore mempolicies when using ALLOC_NO_WATERMARK
Date: Fri,  9 Sep 2011 11:57:16 +0100
Message-Id: <1315565845-16857-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1315565845-16857-1-git-send-email-mgorman@suse.de>
References: <1315565845-16857-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

The reserve is proportionally distributed over all !highmem zones
in the system. So we need to allow an emergency allocation access to
all zones.  In order to do that we need to break out of any mempolicy
boundaries we might have.

In my opinion that does not break mempolicies as those are user
oriented and not system oriented. That is, system allocations are
not guaranteed to be within mempolicy boundaries. For instance IRQs
do not even have a mempolicy.

So breaking out of mempolicy boundaries for 'rare' emergency
allocations, which are always system allocations (as opposed to user)
is ok.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 31e0eb2..17c8f93 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2140,6 +2140,13 @@ rebalance:
 
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
+		/*
+		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
+		 * the allocation is high priority and these type of
+		 * allocations are system rather than user orientated
+		 */
+		zonelist = node_zonelist(numa_node_id(), gfp_mask);
+
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
