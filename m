Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 05A756B0024
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:08:19 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/13] mm: Ignore mempolicies when using ALLOC_NO_WATERMARK
Date: Wed, 27 Apr 2011 17:08:03 +0100
Message-Id: <1303920491-25302-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1303920491-25302-1-git-send-email-mgorman@suse.de>
References: <1303920491-25302-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

The reserve is proportionally distributed over all !highmem zones in the
system. So we need to allow an emergency allocation access to all zones.
In order to do that we need to break out of any mempolicy boundaries we
might have.

In my opinion that does not break mempolicies as those are user oriented
and not system oriented. That is, system allocations are not guaranteed to
be within mempolicy boundaries. For instance IRQs don't even have a mempolicy.

So breaking out of mempolicy boundaries for 'rare' emergency allocations,
which are always system allocations (as opposed to user) is ok.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7e7d9ce..5ff1f71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2085,6 +2085,13 @@ restart:
 rebalance:
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
