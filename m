Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 566AD6B0044
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:09:13 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 15:09:12 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7A65538C804D
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:09:03 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DJ90pb272350
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:09:01 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DJ8t8G001345
	for <linux-mm@kvack.org>; Mon, 13 May 2013 13:08:56 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH RESEND v3 05/11] mm/page_alloc: convert zone_pcp_update() to rely on memory barriers instead of stop_machine()
Date: Mon, 13 May 2013 12:08:17 -0700
Message-Id: <1368472103-3427-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

zone_pcp_update()'s goal is to adjust the ->high and ->mark members of a
percpu pageset based on a zone's ->managed_pages. We don't need to drain
the entire percpu pageset just to modify these fields.

This lets us avoid calling setup_pageset() (and the draining required to
call it) and instead allows simply setting the fields' values (with some
attention paid to memory barriers to prevent the relationship between
->batch and ->high from being thrown off).

This does change the behavior of zone_pcp_update() as the percpu
pagesets will not be drained when zone_pcp_update() is called (they will
end up being shrunk, not completely drained, later when a 0-order page
is freed in free_hot_cold_page()).

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 33 +++++++++------------------------
 1 file changed, 9 insertions(+), 24 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 71d843d..5a00195 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6083,33 +6083,18 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-static int __meminit __zone_pcp_update(void *data)
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
-		if (pcp->count > 0)
-			free_pcppages_bulk(zone, pcp->count, pcp);
-		drain_zonestat(zone, pset);
-		setup_pageset(pset, batch);
-		local_irq_restore(flags);
-	}
-	return 0;
-}
-
+/*
+ * The zone indicated has a new number of managed_pages; batch sizes and percpu
+ * page high values need to be recalulated.
+ */
 void __meminit zone_pcp_update(struct zone *zone)
 {
+	unsigned cpu;
+	unsigned long batch;
 	mutex_lock(&pcp_batch_high_lock);
-	stop_machine(__zone_pcp_update, zone, NULL);
+	batch = zone_batchsize(zone);
+	for_each_possible_cpu(cpu)
+		pageset_set_batch(per_cpu_ptr(zone->pageset, cpu), batch);
 	mutex_unlock(&pcp_batch_high_lock);
 }
 #endif
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
