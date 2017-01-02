Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4F8F6B0253
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 10:31:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so75895008wms.7
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 07:31:08 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id e138si69940777wmf.124.2017.01.02.07.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jan 2017 07:31:07 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so82529664wmu.0
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 07:31:07 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: fix remote numa hits statistics
Date: Mon,  2 Jan 2017 16:30:56 +0100
Message-Id: <20170102153057.9451-2-mhocko@kernel.org>
In-Reply-To: <20170102153057.9451-1-mhocko@kernel.org>
References: <20170102153057.9451-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Jia He <hejianet@gmail.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Jia He has noticed that b9f00e147f27 ("mm, page_alloc: reduce branches
in zone_statistics") has an unintentional side effect that remote node
allocation requests are accounted as NUMA_MISS rathat than NUMA_HIT and
NUMA_OTHER if such a request doesn't use __GFP_OTHER_NODE. There are
many of these potentially because the flag is used very rarely while
we have many users of __alloc_pages_node.

Fix this by simply ignoring __GFP_OTHER_NODE (it can be removed in a
follow up patch) and treat all allocations that were satisfied from the
preferred zone's node as NUMA_HITS because this is the same node we
requested the allocation from in most cases. If this is not the local
node then we just account it as NUMA_OTHER rather than NUMA_LOCAL.

One downsize would be that an allocation request for a node which is
outside of the mempolicy nodemask would be reported as a hit which is a
bit weird but that was the case before b9f00e147f27 already.

Reported-by: Jia He <hejianet@gmail.com>
Fixes: b9f00e147f27 ("mm, page_alloc: reduce branches in zone_statistics")
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Vlastimil Babka <vbabka@suse.cz> # with cbmc[1] superpowers
Signed-off-by: Michal Hocko <mhocko@suse.com>

[1] http://paulmck.livejournal.com/38997.html
---
 mm/page_alloc.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f6d5b73e1d7c..e2a44950a685 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2583,30 +2583,23 @@ int __isolate_free_page(struct page *page, unsigned int order)
  * Update NUMA hit/miss statistics
  *
  * Must be called with interrupts disabled.
- *
- * When __GFP_OTHER_NODE is set assume the node of the preferred
- * zone is the local node. This is useful for daemons who allocate
- * memory on behalf of other processes.
  */
 static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
 								gfp_t flags)
 {
 #ifdef CONFIG_NUMA
-	int local_nid = numa_node_id();
 	enum zone_stat_item local_stat = NUMA_LOCAL;
 
-	if (unlikely(flags & __GFP_OTHER_NODE)) {
+	if (z->node != numa_node_id())
 		local_stat = NUMA_OTHER;
-		local_nid = preferred_zone->node;
-	}
 
-	if (z->node == local_nid) {
+	if (z->node == preferred_zone->node)
 		__inc_zone_state(z, NUMA_HIT);
-		__inc_zone_state(z, local_stat);
-	} else {
+	else {
 		__inc_zone_state(z, NUMA_MISS);
 		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
 	}
+	__inc_zone_state(z, local_stat);
 #endif
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
