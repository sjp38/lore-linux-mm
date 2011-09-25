Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C2E709000CF
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 04:56:14 -0400 (EDT)
Received: by mail-pz0-f47.google.com with SMTP id 4so12533619pzk.6
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 01:56:13 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they exist
Date: Sun, 25 Sep 2011 11:54:49 +0300
Message-Id: <1316940890-24138-5-git-send-email-gilad@benyossef.com>
In-Reply-To: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Use a cpumask to track CPUs with per-cpu pages in any zone
and only send an IPI requesting CPUs to drain these pages
to the buddy allocator if they actually have pages.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
---
 mm/page_alloc.c |   53 ++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 44 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..3c079ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -62,6 +62,10 @@
 #include <asm/div64.h>
 #include "internal.h"
 
+/* Which CPUs have per cpu pages  */
+cpumask_var_t cpus_with_pcp;
+static DEFINE_PER_CPU(long, total_cpu_pcp_count);
+
 #ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
 DEFINE_PER_CPU(int, numa_node);
 EXPORT_PER_CPU_SYMBOL(numa_node);
@@ -224,6 +228,25 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
+static inline void inc_pcp_count(int cpu, struct per_cpu_pages *pcp, int count)
+{
+	if (unlikely(!total_cpu_pcp_count))
+		cpumask_set_cpu(cpu, cpus_with_pcp);
+
+	total_cpu_pcp_count += count;
+	pcp->count += count;
+}
+
+static inline void dec_pcp_count(int cpu, struct per_cpu_pages *pcp, int count)
+{
+	pcp->count -= count;
+	total_cpu_pcp_count -= count;
+
+	if (unlikely(!total_cpu_pcp_count))
+		cpumask_clear_cpu(cpu, cpus_with_pcp);
+}
+
+
 static void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
@@ -1072,7 +1095,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	else
 		to_drain = pcp->count;
 	free_pcppages_bulk(zone, to_drain, pcp);
-	pcp->count -= to_drain;
+	dec_pcp_count(smp_processor_id(), pcp, to_drain);
 	local_irq_restore(flags);
 }
 #endif
@@ -1099,7 +1122,7 @@ static void drain_pages(unsigned int cpu)
 		pcp = &pset->pcp;
 		if (pcp->count) {
 			free_pcppages_bulk(zone, pcp->count, pcp);
-			pcp->count = 0;
+			dec_pcp_count(cpu, pcp, pcp->count);
 		}
 		local_irq_restore(flags);
 	}
@@ -1118,7 +1141,7 @@ void drain_local_pages(void *arg)
  */
 void drain_all_pages(void)
 {
-	on_each_cpu(drain_local_pages, NULL, 1);
+	on_each_cpu_mask(cpus_with_pcp, drain_local_pages, NULL, 1);
 }
 
 #ifdef CONFIG_HIBERNATION
@@ -1166,7 +1189,7 @@ void free_hot_cold_page(struct page *page, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
-	int migratetype;
+	int migratetype, cpu;
 	int wasMlocked = __TestClearPageMlocked(page);
 
 	if (!free_pages_prepare(page, 0))
@@ -1194,15 +1217,16 @@ void free_hot_cold_page(struct page *page, int cold)
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
@@ -1305,9 +1329,10 @@ again:
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
@@ -1318,7 +1343,7 @@ again:
 			page = list_entry(list->next, struct page, lru);
 
 		list_del(&page->lru);
-		pcp->count--;
+		dec_pcp_count(smp_processor_id(), pcp, 1);
 	} else {
 		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
 			/*
@@ -3553,6 +3578,8 @@ static int zone_batchsize(struct zone *zone)
 #endif
 }
 
+/* NOTE: If you call this function it is very likely you want to clear
+   cpus_with_pcp as well. */
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
@@ -3591,6 +3618,8 @@ static void setup_zone_pageset(struct zone *zone)
 
 	zone->pageset = alloc_percpu(struct per_cpu_pageset);
 
+	cpumask_clear(cpus_with_pcp);
+
 	for_each_possible_cpu(cpu) {
 		struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
 
@@ -3613,6 +3642,10 @@ void __init setup_per_cpu_pageset(void)
 
 	for_each_populated_zone(zone)
 		setup_zone_pageset(zone);
+
+	/* Allocate the cpus_with_pcp var if CONFIG_CPUMASK_OFFSTACK */
+	zalloc_cpumask_var(&cpus_with_pcp, GFP_NOWAIT);
+
 }
 
 static noinline __init_refok
@@ -3664,6 +3697,8 @@ static int __zone_pcp_update(void *data)
 	int cpu;
 	unsigned long batch = zone_batchsize(zone), flags;
 
+	cpumask_clear(cpus_with_pcp);
+
 	for_each_possible_cpu(cpu) {
 		struct per_cpu_pageset *pset;
 		struct per_cpu_pages *pcp;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
