Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0F0536B13F7
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 03:37:13 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c13so567604eek.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 00:37:12 -0800 (PST)
MIME-Version: 1.0
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v9 7/8] mm: only IPI CPUs to drain local pages if they exist
Date: Thu,  9 Feb 2012 10:36:24 +0200
Message-Id: <1328776585-22518-8-git-send-email-gilad@benyossef.com>
In-Reply-To: <1328776585-22518-1-git-send-email-gilad@benyossef.com>
References: <1328776585-22518-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Milton Miller <miltonm@bga.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>

Calculate a cpumask of CPUs with per-cpu pages in any zone
and only send an IPI requesting CPUs to drain these pages
to the buddy allocator if they actually have pages when
asked to flush.

This patch saves 85%+ of IPIs asking to drain per-cpu
pages in case of severe memory preassure that leads
to OOM since in these cases multiple, possibly concurrent,
allocation requests end up in the direct reclaim code
path so when the per-cpu pages end up reclaimed on first
allocation failure for most of the proceeding allocation
attempts until the memory pressure is off (possibly via
the OOM killer) there are no per-cpu pages on most CPUs
(and there can easily be hundreds of them).

This also has the side effect of shortening the average
latency of direct reclaim by 1 or more order of magnitude
since waiting for all the CPUs to ACK the IPI takes a
long time.

Tested by running "hackbench 400" on a 8 CPU x86 VM and
observing the difference between the number of direct
reclaim attempts that end up in drain_all_pages() and
those were more then 1/2 of the online CPU had any per-cpu
page in them, using the vmstat counters introduced
in the next patch in the series and using proc/interrupts.

In the test sceanrio, this was seen to save around 3600 global
IPIs after trigerring an OOM on a concurrent workload:

$ cat /proc/vmstat | tail -n 2
pcp_global_drain 0
pcp_global_ipi_saved 0

$ cat /proc/interrupts | grep CAL
CAL:          1          2          1          2
          2          2          2          2   Function call interrupts

$ hackbench 400
[OOM messages snipped]

$ cat /proc/vmstat | tail -n 2
pcp_global_drain 3647
pcp_global_ipi_saved 3642

$ cat /proc/interrupts | grep CAL
CAL:          6         13          6          3
          3          3         1 2          7   Function call interrupts

Please note that if the global drain is removed from the
direct reclaim path as a patch from Mel Gorman currently
suggests this should be replaced with an on_each_cpu_cond
invocation.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: linux-fsdevel@vger.kernel.org
CC: Avi Kivity <avi@redhat.com>
CC: Milton Miller <miltonm@bga.com>
CC: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---
 mm/page_alloc.c |   40 ++++++++++++++++++++++++++++++++++++++--
 1 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d2186ec..3a2fc84 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1161,11 +1161,47 @@ void drain_local_pages(void *arg)
 }
 
 /*
- * Spill all the per-cpu pages from all CPUs back into the buddy allocator
+ * Spill all the per-cpu pages from all CPUs back into the buddy allocator.
+ *
+ * Note that this code is protected against sending an IPI to an offline
+ * CPU but does not guarantee sending an IPI to newly hotplugged CPUs:
+ * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs but
+ * nothing keeps CPUs from showing up after we populated the cpumask and
+ * before the call to on_each_cpu_mask().
  */
 void drain_all_pages(void)
 {
-	on_each_cpu(drain_local_pages, NULL, 1);
+	int cpu;
+	struct per_cpu_pageset *pcp;
+	struct zone *zone;
+
+	/*
+	 * Allocate in the BSS so we wont require allocation in
+	 * direct reclaim path for CONFIG_CPUMASK_OFFSTACK=y
+	 */
+	static cpumask_t cpus_with_pcps;
+
+	/*
+	 * We don't care about racing with CPU hotplug event
+	 * as offline notification will cause the notified
+	 * cpu to drain that CPU pcps and on_each_cpu_mask
+	 * disables preemption as part of its processing
+	 */
+	for_each_online_cpu(cpu) {
+		bool has_pcps = false;
+		for_each_populated_zone(zone) {
+			pcp = per_cpu_ptr(zone->pageset, cpu);
+			if (pcp->pcp.count) {
+				has_pcps = true;
+				break;
+			}
+		}
+		if (has_pcps)
+			cpumask_set_cpu(cpu, &cpus_with_pcps);
+		else
+			cpumask_clear_cpu(cpu, &cpus_with_pcps);
+	}
+	on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
 }
 
 #ifdef CONFIG_HIBERNATION
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
