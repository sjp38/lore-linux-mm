Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D8A0D6B0262
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:12:53 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id v188so120491181wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:12:53 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id wg3si33503635wjb.162.2016.04.12.03.12.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:12:52 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 4CB1D98F6D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:12:52 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 04/24] mm, page_alloc: Inline zone_statistics
Date: Tue, 12 Apr 2016 11:12:05 +0100
Message-Id: <1460455945-29644-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

zone_statistics has one call-site but it's a public function. Make
it static and inline.

The performance difference on a page allocator microbenchmark is;

                                           4.6.0-rc2                  4.6.0-rc2
                                    statbranch-v1r20           statinline-v1r20
Min      alloc-odr0-1               419.00 (  0.00%)           412.00 (  1.67%)
Min      alloc-odr0-2               305.00 (  0.00%)           301.00 (  1.31%)
Min      alloc-odr0-4               250.00 (  0.00%)           247.00 (  1.20%)
Min      alloc-odr0-8               219.00 (  0.00%)           215.00 (  1.83%)
Min      alloc-odr0-16              203.00 (  0.00%)           199.00 (  1.97%)
Min      alloc-odr0-32              195.00 (  0.00%)           191.00 (  2.05%)
Min      alloc-odr0-64              191.00 (  0.00%)           187.00 (  2.09%)
Min      alloc-odr0-128             189.00 (  0.00%)           185.00 (  2.12%)
Min      alloc-odr0-256             198.00 (  0.00%)           193.00 (  2.53%)
Min      alloc-odr0-512             210.00 (  0.00%)           207.00 (  1.43%)
Min      alloc-odr0-1024            216.00 (  0.00%)           213.00 (  1.39%)
Min      alloc-odr0-2048            221.00 (  0.00%)           220.00 (  0.45%)
Min      alloc-odr0-4096            227.00 (  0.00%)           226.00 (  0.44%)
Min      alloc-odr0-8192            232.00 (  0.00%)           229.00 (  1.29%)
Min      alloc-odr0-16384           232.00 (  0.00%)           229.00 (  1.29%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/vmstat.h |  2 --
 mm/page_alloc.c        | 31 +++++++++++++++++++++++++++++++
 mm/vmstat.c            | 29 -----------------------------
 3 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 73fae8c4a5fb..152d26b7f972 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -163,12 +163,10 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 #ifdef CONFIG_NUMA
 
 extern unsigned long node_page_state(int node, enum zone_stat_item item);
-extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
 
 #else
 
 #define node_page_state(node, item) global_page_state(item)
-#define zone_statistics(_zl, _z, gfp) do { } while (0)
 
 #endif /* CONFIG_NUMA */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6812de41f698..b56c2b2911a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2352,6 +2352,37 @@ int split_free_page(struct page *page)
 }
 
 /*
+ * Update NUMA hit/miss statistics 
+ *
+ * Must be called with interrupts disabled.
+ *
+ * When __GFP_OTHER_NODE is set assume the node of the preferred
+ * zone is the local node. This is useful for daemons who allocate
+ * memory on behalf of other processes.
+ */
+static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
+								gfp_t flags)
+{
+#ifdef CONFIG_NUMA
+	int local_nid = numa_node_id();
+	enum zone_stat_item local_stat = NUMA_LOCAL;
+
+	if (unlikely(flags & __GFP_OTHER_NODE)) {
+		local_stat = NUMA_OTHER;
+		local_nid = preferred_zone->node;
+	}
+
+	if (z->node == local_nid) {
+		__inc_zone_state(z, NUMA_HIT);
+		__inc_zone_state(z, local_stat);
+	} else {
+		__inc_zone_state(z, NUMA_MISS);
+		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
+	}
+#endif
+}
+
+/*
  * Allocate a page from the given zone. Use pcplists for order-0 allocations.
  */
 static inline
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2e58ead9bcf5..a4bda11eac8d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -570,35 +570,6 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 
 #ifdef CONFIG_NUMA
 /*
- * zonelist = the list of zones passed to the allocator
- * z 	    = the zone from which the allocation occurred.
- *
- * Must be called with interrupts disabled.
- *
- * When __GFP_OTHER_NODE is set assume the node of the preferred
- * zone is the local node. This is useful for daemons who allocate
- * memory on behalf of other processes.
- */
-void zone_statistics(struct zone *preferred_zone, struct zone *z, gfp_t flags)
-{
-	int local_nid = numa_node_id();
-	enum zone_stat_item local_stat = NUMA_LOCAL;
-
-	if (unlikely(flags & __GFP_OTHER_NODE)) {
-		local_stat = NUMA_OTHER;
-		local_nid = preferred_zone->node;
-	}
-
-	if (z->node == local_nid) {
-		__inc_zone_state(z, NUMA_HIT);
-		__inc_zone_state(z, local_stat);
-	} else {
-		__inc_zone_state(z, NUMA_MISS);
-		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
-	}
-}
-
-/*
  * Determine the per node value of a stat item.
  */
 unsigned long node_page_state(int node, enum zone_stat_item item)
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
