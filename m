Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 800446B0031
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 11:49:55 -0400 (EDT)
Received: by mail-ey0-f169.google.com with SMTP id 4so6776147eye.14
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 08:49:53 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they exist
Date: Sun, 23 Oct 2011 17:48:40 +0200
Message-Id: <1319384922-29632-5-git-send-email-gilad@benyossef.com>
In-Reply-To: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

Use a cpumask to track CPUs with per-cpu pages in any zone
and only send an IPI requesting CPUs to drain these pages
to the buddy allocator if they actually have pages.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
---
 mm/page_alloc.c |   64 +++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 55 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..9551b90 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -57,11 +57,17 @@
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
+#include <linux/percpu.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
+#include <asm/local.h>
 #include "internal.h"
 
+/* Which CPUs have per cpu pages  */
+cpumask_var_t cpus_with_pcp;
+static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);
+
 #ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
 DEFINE_PER_CPU(int, numa_node);
 EXPORT_PER_CPU_SYMBOL(numa_node);
@@ -224,6 +230,36 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
+/*
+ * The following two functions track page counts both per zone/per CPU
+ * and globaly per CPU.
+ *
+ * They must be called with interrupts disabled and either pinned to specific
+ * CPU or for offline CPUs or under stop_machine.
+ */
+
+static inline void inc_pcp_count(int cpu, struct per_cpu_pages *pcp, int count)
+{
+	unsigned long *tot = &per_cpu(total_cpu_pcp_count, cpu);
+
+	if (unlikely(!*tot))
+		cpumask_set_cpu(cpu, cpus_with_pcp);
+
+	*tot += count;
+	pcp->count += count;
+}
+
+static inline void dec_pcp_count(int cpu, struct per_cpu_pages *pcp, int count)
+{
+	unsigned long *tot = &per_cpu(total_cpu_pcp_count, cpu);
+
+	pcp->count -= count;
+	*tot -= count;
+
+	if (unlikely(!*tot))
+		cpumask_clear_cpu(cpu, cpus_with_pcp);
+}
+
 static void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
@@ -1072,7 +1108,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	else
 		to_drain = pcp->count;
 	free_pcppages_bulk(zone, to_drain, pcp);
-	pcp->count -= to_drain;
+	dec_pcp_count(smp_processor_id(), pcp, to_drain);
 	local_irq_restore(flags);
 }
 #endif
@@ -1099,7 +1135,7 @@ static void drain_pages(unsigned int cpu)
 		pcp = &pset->pcp;
 		if (pcp->count) {
 			free_pcppages_bulk(zone, pcp->count, pcp);
-			pcp->count = 0;
+			dec_pcp_count(cpu, pcp, pcp->count);
 		}
 		local_irq_restore(flags);
 	}
@@ -1118,7 +1154,7 @@ void drain_local_pages(void *arg)
  */
 void drain_all_pages(void)
 {
-	on_each_cpu(drain_local_pages, NULL, 1);
+	on_each_cpu_mask(cpus_with_pcp, drain_local_pages, NULL, 1);
 }
 
 #ifdef CONFIG_HIBERNATION
@@ -1166,7 +1202,7 @@ void free_hot_cold_page(struct page *page, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
-	int migratetype;
+	int migratetype, cpu;
 	int wasMlocked = __TestClearPageMlocked(page);
 
 	if (!free_pages_prepare(page, 0))
@@ -1194,15 +1230,16 @@ void free_hot_cold_page(struct page *page, int cold)
 		migratetype = MIGRATE_MOVABLE;
 	}
 
+	cpu = smp_processor_id();
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	if (cold)
 		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	else
 		list_add(&page->lru, &pcp->lists[migratetype]);
-	pcp->count++;
+	inc_pcp_count(cpu, pcp, 1);
 	if (pcp->count >= pcp->high) {
 		free_pcppages_bulk(zone, pcp->batch, pcp);
-		pcp->count -= pcp->batch;
+		dec_pcp_count(cpu, pcp, pcp->batch);
 	}
 
 out:
@@ -1305,9 +1342,10 @@ again:
 		pcp = &this_cpu_ptr(zone->pageset)->pcp;
 		list = &pcp->lists[migratetype];
 		if (list_empty(list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
+			inc_pcp_count(smp_processor_id(), pcp,
+					rmqueue_bulk(zone, 0,
 					pcp->batch, list,
-					migratetype, cold);
+					migratetype, cold));
 			if (unlikely(list_empty(list)))
 				goto failed;
 		}
@@ -1318,7 +1356,7 @@ again:
 			page = list_entry(list->next, struct page, lru);
 
 		list_del(&page->lru);
-		pcp->count--;
+		dec_pcp_count(smp_processor_id(), pcp, 1);
 	} else {
 		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
 			/*
@@ -3553,6 +3591,10 @@ static int zone_batchsize(struct zone *zone)
 #endif
 }
 
+/*
+ * NOTE: If you call this function on a pcp of a populated zone you
+ * need to worry about syncing cpus_with_pcp state as well.
+ */
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
@@ -3673,6 +3715,7 @@ static int __zone_pcp_update(void *data)
 
 		local_irq_save(flags);
 		free_pcppages_bulk(zone, pcp->count, pcp);
+		dec_pcp_count(cpu, pcp, pcp->count);
 		setup_pageset(pset, batch);
 		local_irq_restore(flags);
 	}
@@ -5040,6 +5083,9 @@ static int page_alloc_cpu_notify(struct notifier_block *self,
 void __init page_alloc_init(void)
 {
 	hotcpu_notifier(page_alloc_cpu_notify, 0);
+
+	/* Allocate the cpus_with_pcp var if CONFIG_CPUMASK_OFFSTACK */
+	alloc_bootmem_cpumask_var(&cpus_with_pcp);
 }
 
 /*
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
