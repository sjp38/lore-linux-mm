Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D757F6B0073
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 05:52:30 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH 4/4] mm/hotplug: mark memory hotplug code in page_alloc.c as __meminit
Date: Thu, 5 Jul 2012 17:45:32 +0800
Message-ID: <1341481532-1700-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
References: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

Mark functions used by both boot and memory hotplug as __meminit to reduce
memory footprint when memory hotplug is disabled.

Alos guard zone_pcp_update() with CONFIG_MEMORY_HOTPLUG because it's only
used by memory hotplug code.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 mm/page_alloc.c |   66 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5964b7a..da08449 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3409,7 +3409,7 @@ static void setup_zone_pageset(struct zone *zone);
 DEFINE_MUTEX(zonelists_mutex);
 
 /* return values int ....just for stop_machine() */
-static __init_refok int __build_all_zonelists(void *data)
+static int __build_all_zonelists(void *data)
 {
 	int nid;
 	int cpu;
@@ -3753,7 +3753,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
-static int zone_batchsize(struct zone *zone)
+static int __meminit zone_batchsize(struct zone *zone)
 {
 #ifdef CONFIG_MMU
 	int batch;
@@ -3835,7 +3835,7 @@ static void setup_pagelist_highmark(struct per_cpu_pageset *p,
 		pcp->batch = PAGE_SHIFT * 8;
 }
 
-static void setup_zone_pageset(struct zone *zone)
+static void __meminit setup_zone_pageset(struct zone *zone)
 {
 	int cpu;
 
@@ -3908,33 +3908,7 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 	return 0;
 }
 
-static int __zone_pcp_update(void *data)
-{
-	struct zone *zone = data;
-	int cpu;
-	unsigned long batch = zone_batchsize(zone), flags;
-
-	for_each_possible_cpu(cpu) {
-		struct per_cpu_pageset *pset;
-		struct per_cpu_pages *pcp;
-
-		pset = per_cpu_ptr(zone->pageset, cpu);
-		pcp = &pset->pcp;
-
-		local_irq_save(flags);
-		free_pcppages_bulk(zone, pcp->count, pcp);
-		setup_pageset(pset, batch);
-		local_irq_restore(flags);
-	}
-	return 0;
-}
-
-void zone_pcp_update(struct zone *zone)
-{
-	stop_machine(__zone_pcp_update, zone, NULL);
-}
-
-static __meminit void zone_pcp_init(struct zone *zone)
+static void __meminit zone_pcp_init(struct zone *zone)
 {
 	/*
 	 * per cpu subsystem is not up at this point. The following code
@@ -3949,7 +3923,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
 					 zone_batchsize(zone));
 }
 
-__meminit int init_currently_empty_zone(struct zone *zone,
+int __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long zone_start_pfn,
 					unsigned long size,
 					enum memmap_context context)
@@ -4757,7 +4731,7 @@ out:
 }
 
 /* Any regular memory on that node ? */
-static void check_for_regular_memory(pg_data_t *pgdat)
+static void __init check_for_regular_memory(pg_data_t *pgdat)
 {
 #ifdef CONFIG_HIGHMEM
 	enum zone_type zone_type;
@@ -5871,6 +5845,34 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 }
 #endif
 
+#ifdef	CONFIG_MEMORY_HOTPLUG
+static int __meminit __zone_pcp_update(void *data)
+{
+	struct zone *zone = data;
+	int cpu;
+	unsigned long batch = zone_batchsize(zone), flags;
+
+	for_each_possible_cpu(cpu) {
+		struct per_cpu_pageset *pset;
+		struct per_cpu_pages *pcp;
+
+		pset = per_cpu_ptr(zone->pageset, cpu);
+		pcp = &pset->pcp;
+
+		local_irq_save(flags);
+		free_pcppages_bulk(zone, pcp->count, pcp);
+		setup_pageset(pset, batch);
+		local_irq_restore(flags);
+	}
+	return 0;
+}
+
+void __meminit zone_pcp_update(struct zone *zone)
+{
+	stop_machine(__zone_pcp_update, zone, NULL);
+}
+#endif
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 void zone_pcp_reset(struct zone *zone)
 {
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
