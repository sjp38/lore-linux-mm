Message-Id: <200405222208.i4MM8Dr13315@mail.osdl.org>
Subject: [patch 27/57] numa api: Add statistics
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:07:43 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

Add NUMA hit/miss statistics to page allocation and display them in sysfs.

This is not 100% required for NUMA API, but without this it is very

The overhead is quite low because all counters are per CPU and only happens
when CONFIG_NUMA is defined.


---

 25-akpm/include/linux/mmzone.h |    8 +++++++
 25-akpm/mm/page_alloc.c        |   42 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 46 insertions(+), 4 deletions(-)

diff -puN include/linux/mmzone.h~numa-api-statistics include/linux/mmzone.h
--- 25/include/linux/mmzone.h~numa-api-statistics	2004-05-22 14:56:25.909152736 -0700
+++ 25-akpm/include/linux/mmzone.h	2004-05-22 14:56:25.913152128 -0700
@@ -52,6 +52,14 @@ struct per_cpu_pages {
 
 struct per_cpu_pageset {
 	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
+#ifdef CONFIG_NUMA
+	unsigned long numa_hit;		/* allocated in intended node */
+	unsigned long numa_miss;	/* allocated in non intended node */
+	unsigned long numa_foreign;	/* was intended here, hit elsewhere */
+	unsigned long interleave_hit; 	/* interleaver prefered this zone */
+	unsigned long local_node;	/* allocation from local node */
+	unsigned long other_node;	/* allocation from other node */
+#endif
 } ____cacheline_aligned_in_smp;
 
 #define ZONE_DMA		0
diff -puN mm/page_alloc.c~numa-api-statistics mm/page_alloc.c
--- 25/mm/page_alloc.c~numa-api-statistics	2004-05-22 14:56:25.910152584 -0700
+++ 25-akpm/mm/page_alloc.c	2004-05-22 14:59:36.977105992 -0700
@@ -460,6 +460,32 @@ void drain_local_pages(void)
 }
 #endif /* CONFIG_PM */
 
+static void zone_statistics(struct zonelist *zonelist, struct zone *z)
+{
+#ifdef CONFIG_NUMA
+	unsigned long flags;
+	int cpu;
+	pg_data_t *pg = z->zone_pgdat;
+	pg_data_t *orig = zonelist->zones[0]->zone_pgdat;
+	struct per_cpu_pageset *p;
+
+	local_irq_save(flags);
+	cpu = smp_processor_id();
+	p = &z->pageset[cpu];
+	if (pg == orig) {
+		z->pageset[cpu].numa_hit++;
+	} else {
+		p->numa_miss++;
+		zonelist->zones[0]->pageset[cpu].numa_foreign++;
+	}
+	if (pg == NODE_DATA(numa_node_id()))
+		p->local_node++;
+	else
+		p->other_node++;
+	local_irq_restore(flags);
+#endif
+}
+
 /*
  * Free a 0-order page
  */
@@ -593,8 +619,10 @@ __alloc_pages(unsigned int gfp_mask, uns
 		if (z->free_pages >= min ||
 				(!wait && z->free_pages >= z->pages_high)) {
 			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page)
+			if (page) {
+				zone_statistics(zonelist, z);
 				goto got_pg;
+			}
 		}
 	}
 
@@ -616,8 +644,10 @@ __alloc_pages(unsigned int gfp_mask, uns
 		if (z->free_pages >= min ||
 				(!wait && z->free_pages >= z->pages_high)) {
 			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page)
+			if (page) {
+				zone_statistics(zonelist, z);
 				goto got_pg;
+			}
 		}
 	}
 
@@ -630,8 +660,10 @@ rebalance:
 			struct zone *z = zones[i];
 
 			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page)
+			if (page) {
+				zone_statistics(zonelist, z);
 				goto got_pg;
+			}
 		}
 		goto nopage;
 	}
@@ -658,8 +690,10 @@ rebalance:
 		if (z->free_pages >= min ||
 				(!wait && z->free_pages >= z->pages_high)) {
 			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page)
+			if (page) {
+ 				zone_statistics(zonelist, z);
 				goto got_pg;
+			}
 		}
 	}
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
