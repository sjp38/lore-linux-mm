Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6CE0F8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 15:00:32 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 6/8] Add __GFP_OTHER_NODE flag
Date: Thu,  3 Mar 2011 11:59:49 -0800
Message-Id: <1299182391-6061-7-git-send-email-andi@firstfloor.org>
In-Reply-To: <1299182391-6061-1-git-send-email-andi@firstfloor.org>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, aarcange@redhat.com

From: Andi Kleen <ak@linux.intel.com>

Add a new __GFP_OTHER_NODE flag to tell the low level numa statistics
in zone_statistics() that an allocation is on behalf of another thread.
This way the local and remote counters can be still correct, even
when background daemons like khugepaged are changing memory
mappings.

This only affects the accounting, but I think it's worth doing that
right to avoid confusing users.

I first tried to just pass down the right node, but this required
a lot of changes to pass down this parameter and at least one
addition of a 10th argument to a 9 argument function. Using
the flag is a lot less intrusive.

Open: should be also used for migration?

Cc: aarcange@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/gfp.h    |    2 ++
 include/linux/vmstat.h |    4 ++--
 mm/page_alloc.c        |    2 +-
 mm/vmstat.c            |    9 +++++++--
 4 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 814d50e..a064724 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -35,6 +35,7 @@ struct vm_area_struct;
 #define ___GFP_NOTRACK		0
 #endif
 #define ___GFP_NO_KSWAPD	0x400000u
+#define ___GFP_OTHER_NODE	0x800000u
 
 /*
  * GFP bitmasks..
@@ -83,6 +84,7 @@ struct vm_area_struct;
 #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
 #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
+#define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
 
 /*
  * This may seem redundant, but it's a way of annotating false positives vs.
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 833e676..9b5c63d 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -220,12 +220,12 @@ static inline unsigned long node_page_state(int node,
 		zone_page_state(&zones[ZONE_MOVABLE], item);
 }
 
-extern void zone_statistics(struct zone *, struct zone *);
+extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
 
 #else
 
 #define node_page_state(node, item) global_page_state(item)
-#define zone_statistics(_zl,_z) do { } while (0)
+#define zone_statistics(_zl,_z, gfp) do { } while (0)
 
 #endif /* CONFIG_NUMA */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a873e61..4ce06a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1333,7 +1333,7 @@ again:
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
-	zone_statistics(preferred_zone, zone);
+	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
 
 	VM_BUG_ON(bad_range(zone, page));
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0c3b504..2b461ed 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -500,8 +500,12 @@ void refresh_cpu_vm_stats(int cpu)
  * z 	    = the zone from which the allocation occurred.
  *
  * Must be called with interrupts disabled.
+ * 
+ * When __GFP_OTHER_NODE is set assume the node of the preferred
+ * zone is the local node. This is useful for daemons who allocate
+ * memory on behalf of other processes.
  */
-void zone_statistics(struct zone *preferred_zone, struct zone *z)
+void zone_statistics(struct zone *preferred_zone, struct zone *z, gfp_t flags)
 {
 	if (z->zone_pgdat == preferred_zone->zone_pgdat) {
 		__inc_zone_state(z, NUMA_HIT);
@@ -509,7 +513,8 @@ void zone_statistics(struct zone *preferred_zone, struct zone *z)
 		__inc_zone_state(z, NUMA_MISS);
 		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
 	}
-	if (z->node == numa_node_id())
+	if (z->node == ((flags & __GFP_OTHER_NODE) ? 
+			preferred_zone->node : numa_node_id()))
 		__inc_zone_state(z, NUMA_LOCAL);
 	else
 		__inc_zone_state(z, NUMA_OTHER);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
