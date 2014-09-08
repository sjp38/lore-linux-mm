From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: fix zone allocation fairness on UP
Date: Mon,  8 Sep 2014 08:35:51 -0400
Message-ID: <1410179751-28115-1-git-send-email-hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

The zone allocation batches can easily underflow due to higher-order
allocations or spills to remote nodes.  On SMP that's fine, because
underflows are expected from concurrency and dealt with by returning
0.  But on UP, zone_page_state will just return a wrapped unsigned
long, which will get past the <= 0 check and then consider the zone
eligible until its watermarks are hit.

3a025760fc15 ("mm: page_alloc: spill to remote nodes before waking
kswapd") already made the counter-resetting use atomic_long_read() to
accomodate underflows from remote spills, but it didn't go all the way
with it.  Make it clear that these batches are expected to go negative
regardless of concurrency, and use atomic_long_read() everywhere.

Fixes: 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "3.12+" <stable@kernel.org>
---
 mm/page_alloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d4c8a2..eee961958021 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1612,7 +1612,7 @@ again:
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
-	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
+	if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
 	    !zone_is_fair_depleted(zone))
 		zone_set_flag(zone, ZONE_FAIR_DEPLETED);
 
@@ -5701,9 +5701,8 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
 
 		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-				      high_wmark_pages(zone) -
-				      low_wmark_pages(zone) -
-				      zone_page_state(zone, NR_ALLOC_BATCH));
+			high_wmark_pages(zone) - low_wmark_pages(zone) -
+			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
 
 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
-- 
2.0.4
