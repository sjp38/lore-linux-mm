Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C714A6B00EA
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 20:41:04 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 1/2] Avoid lock contention on page draining
Date: Tue, 27 Mar 2012 17:40:32 -0700
Message-Id: <1332895233-32471-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tim.c.chen@linux.intel.com, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

drain_all_pages asks all CPUs to drain their PCP lists. This causes a lot
of lock contention because they try to free into the same zones in lock
step.

Make half of the CPUs go through the zones forwards and the other half
backwards. This should lower the contention to half.

I opencoded the backwards walk: there were no macros for it, but it seemed
to obscure to create some extra for this.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/page_alloc.c |   56 +++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..8cd4f6a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1124,6 +1124,23 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 }
 #endif
 
+static void do_drain_zone(struct zone *zone, int cpu)
+{
+	unsigned long flags;
+	struct per_cpu_pageset *pset;
+	struct per_cpu_pages *pcp;
+	
+	local_irq_save(flags);
+	pset = per_cpu_ptr(zone->pageset, cpu);
+	
+	pcp = &pset->pcp;
+	if (pcp->count) {
+		free_pcppages_bulk(zone, pcp->count, pcp);
+		pcp->count = 0;
+	}
+	local_irq_restore(flags);
+}
+
 /*
  * Drain pages of the indicated processor.
  *
@@ -1133,22 +1150,33 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
  */
 static void drain_pages(unsigned int cpu)
 {
-	unsigned long flags;
 	struct zone *zone;
 
-	for_each_populated_zone(zone) {
-		struct per_cpu_pageset *pset;
-		struct per_cpu_pages *pcp;
-
-		local_irq_save(flags);
-		pset = per_cpu_ptr(zone->pageset, cpu);
-
-		pcp = &pset->pcp;
-		if (pcp->count) {
-			free_pcppages_bulk(zone, pcp->count, pcp);
-			pcp->count = 0;
-		}
-		local_irq_restore(flags);
+	/* 
+	 * Let half of the CPUs go through the zones forwards
+	 * and the other half backwards. This reduces lock contention.
+	 */
+	if ((cpu % 2) == 0) { 
+		for_each_populated_zone(zone)
+			do_drain_zone(zone, cpu);
+	} else {
+		int i, j, k = 0;
+	 
+		/* 
+		 * Backwards zone walk. Opencoded because its quite obscure.
+		 */
+		for (i = MAX_NUMNODES - 1; i >= 0; i--) {
+			if (!node_states[N_ONLINE].bits[i / BITS_PER_LONG]) {
+				i -= i % BITS_PER_LONG;
+				continue;				
+			}				
+			if (!node_isset(i, node_states[N_ONLINE]))
+				continue;
+			k++;
+			for (j = MAX_NR_ZONES - 1; j >= 0; j--)
+				do_drain_zone(&NODE_DATA(i)->node_zones[j], cpu);
+		}		
+		WARN_ON(k != num_online_nodes());
 	}
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
