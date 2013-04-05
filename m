Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 5873E6B011C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:34:28 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 16:34:27 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BCA816E8044
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:34:21 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r35KYKUB147084
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 16:34:21 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r35KYIsJ025443
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 14:34:18 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 2/3] mm/page_alloc: convert zone_pcp_update() to use on_each_cpu() instead of stop_machine()
Date: Fri,  5 Apr 2013 13:33:49 -0700
Message-Id: <1365194030-28939-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

No off-cpu users of the percpu pagesets exist.

zone_pcp_update()'s goal is to adjust the ->high and ->mark members of a
percpu pageset based on a zone's ->managed_pages. We don't need to drain
the entire percpu pageset just to modify these fields. Avoid calling
setup_pageset() (and the draining required to call it) and instead just
set the fields' values.

This does change the behavior of zone_pcp_update() as the percpu
pagesets will not be drained when zone_pcp_update() is called (they will
end up being shrunk, not completely drained, later when a 0-order page
is freed in free_hot_cold_page()).

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 30 ++++++++++--------------------
 1 file changed, 10 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5877cf0..48f2faa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5987,32 +5987,22 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-static int __meminit __zone_pcp_update(void *data)
+static void __meminit __zone_pcp_update(void *data)
 {
 	struct zone *zone = data;
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
-		if (pcp->count > 0)
-			free_pcppages_bulk(zone, pcp->count, pcp);
-		drain_zonestat(zone, pset);
-		setup_pageset(pset, batch);
-		local_irq_restore(flags);
-	}
-	return 0;
+	unsigned long batch = zone_batchsize(zone);
+	struct per_cpu_pageset *pset =
+		per_cpu_ptr(zone->pageset, smp_processor_id());
+	pageset_set_batch(pset, batch);
 }
 
+/*
+ * The zone indicated has a new number of managed_pages; batch sizes and percpu
+ * page high values need to be recalulated.
+ */
 void __meminit zone_pcp_update(struct zone *zone)
 {
-	stop_machine(__zone_pcp_update, zone, NULL);
+	on_each_cpu(__zone_pcp_update, zone, true);
 }
 #endif
 
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
