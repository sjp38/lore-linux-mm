Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id E4AE86B00B9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:27:10 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id mz13so416489bkb.4
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:27:10 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id rl5si8484120bkb.77.2014.02.25.12.27.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 12:27:09 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: page_alloc: reset aging cycle with GFP_THISNODE
Date: Tue, 25 Feb 2014 15:27:01 -0500
Message-Id: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Stancek <jstancek@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Jan Stancek reports manual page migration encountering allocation
failures after some pages when there is still plenty of memory free,
and bisected the problem down to 81c0a2bb515f ("mm: page_alloc: fair
zone allocator policy").

The problem is that page migration uses GFP_THISNODE and this makes
the page allocator bail out before entering the slowpath entirely,
without resetting the zone round-robin batches.  A string of such
allocations will fail long before the node's free memory is exhausted.

GFP_THISNODE is a special flag for callsites that implement their own
clever node fallback and so no direct reclaim should be invoked.  But
if the allocations fail, the fair allocation batches should still be
reset, and if the node is full, it should be aged in the background.

Make GFP_THISNODE wake up kswapd and reset the zone batches, but bail
out before entering direct reclaim to not stall the allocating task.

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@kernel.org> # 3.12+
---
 mm/page_alloc.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3758a09a009..b92f66e78ec1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2493,18 +2493,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 	}
 
-	/*
-	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
-	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
-	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
-	 * using a larger set of nodes after it has established that the
-	 * allowed per node queues are empty and that nodes are
-	 * over allocated.
-	 */
-	if (IS_ENABLED(CONFIG_NUMA) &&
-			(gfp_mask & GFP_THISNODE) == GFP_THISNODE)
-		goto nopage;
-
 restart:
 	prepare_slowpath(gfp_mask, order, zonelist,
 			 high_zoneidx, preferred_zone);
@@ -2549,6 +2537,18 @@ rebalance:
 		}
 	}
 
+	/*
+	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
+	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
+	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
+	 * using a larger set of nodes after it has established that the
+	 * allowed per node queues are empty and that nodes are
+	 * over allocated.
+	 */
+	if (IS_ENABLED(CONFIG_NUMA) &&
+			(gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+		goto nopage;
+
 	/* Atomic allocations - we can't balance anything */
 	if (!wait) {
 		/*
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
