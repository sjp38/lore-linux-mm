Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 306E16B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 21:45:40 -0400 (EDT)
Subject: [PATCH 1/5]memhp: update zone pcp at memory online
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 09:47:03 +0800
Message-Id: <1246240023.26292.17.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

In my test, 128M memory is hot add, but zone's pcp batch is 0, which
is an obvious error. When pages are onlined, zone pcp should be
updated accordingly.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/linux/mm.h  |    2 ++
 mm/memory_hotplug.c |    1 +
 mm/page_alloc.c     |   25 +++++++++++++++++++++++++
 3 files changed, 28 insertions(+)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2009-06-26 09:41:08.000000000 +0800
+++ linux/include/linux/mm.h	2009-06-26 09:41:10.000000000 +0800
@@ -1073,6 +1073,8 @@ extern void setup_per_cpu_pageset(void);
 static inline void setup_per_cpu_pageset(void) {}
 #endif
 
+extern void zone_pcp_update(struct zone *zone);
+
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
 
Index: linux/mm/memory_hotplug.c
===================================================================
--- linux.orig/mm/memory_hotplug.c	2009-06-26 09:41:08.000000000 +0800
+++ linux/mm/memory_hotplug.c	2009-06-26 09:41:10.000000000 +0800
@@ -422,6 +422,7 @@ int online_pages(unsigned long pfn, unsi
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 
+	zone_pcp_update(zone);
 	setup_per_zone_wmarks();
 	calculate_zone_inactive_ratio(zone);
 	if (onlined_pages) {
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-06-26 09:41:08.000000000 +0800
+++ linux/mm/page_alloc.c	2009-06-26 09:41:10.000000000 +0800
@@ -3131,6 +3131,31 @@ int zone_wait_table_init(struct zone *zo
 	return 0;
 }
 
+static int __zone_pcp_update(void *data)
+{
+	struct zone *zone = data;
+	int cpu;
+	unsigned long batch = zone_batchsize(zone), flags;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		struct per_cpu_pageset *pset;
+		struct per_cpu_pages *pcp;
+
+		pset = zone_pcp(zone, cpu);
+		pcp = &pset->pcp;
+
+		local_irq_save(flags);
+		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
+		setup_pageset(pset, batch);
+		local_irq_restore(flags);
+	}
+}
+
+void zone_pcp_update(struct zone *zone)
+{
+	stop_machine(__zone_pcp_update, zone, NULL);
+}
+
 static __meminit void zone_pcp_init(struct zone *zone)
 {
 	int cpu;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
