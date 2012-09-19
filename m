Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E4EFA6B002B
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 03:26:34 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] memory-hotplug: fix zone stat mismatch
Date: Wed, 19 Sep 2012 16:29:08 +0900
Message-Id: <1348039748-32111-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Shaohua Li <shli@fusionio.com>

During memory-hotplug stress test, I found NR_ISOLATED_[ANON|FILE]
are increasing so that kernel are hang out.

The cause is that when we do memory-hotadd after memory-remove,
__zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
without draining vm_stat_diff of all CPU.

This patch fixes it.

Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Shaohua Li <shli@fusionio.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
Andrew, I think it's a candidate of stable but didn't Cced
stable.
Please send this patch to stable if reviewer couldn't find
any fault when you merge.

Thanks.

 include/linux/vmstat.h |    4 ++++
 mm/page_alloc.c        |    1 +
 mm/vmstat.c            |   12 ++++++++++++
 3 files changed, 17 insertions(+)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index ad2cfd5..5d31876 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -198,6 +198,8 @@ extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 void refresh_cpu_vm_stats(int);
 void refresh_zone_stat_thresholds(void);
 
+void drain_zonestat(struct zone *zone, struct per_cpu_pageset *);
+
 int calculate_pressure_threshold(struct zone *zone);
 int calculate_normal_threshold(struct zone *zone);
 void set_pgdat_percpu_threshold(pg_data_t *pgdat,
@@ -251,6 +253,8 @@ static inline void __dec_zone_page_state(struct page *page,
 static inline void refresh_cpu_vm_stats(int cpu) { }
 static inline void refresh_zone_stat_thresholds(void) { }
 
+static inline void drain_zonestat(struct zone *zone,
+			struct per_cpu_pageset *pset) { }
 #endif		/* CONFIG_SMP */
 
 extern const char * const vmstat_text[];
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ab58346..5d005c8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5904,6 +5904,7 @@ static int __meminit __zone_pcp_update(void *data)
 		local_irq_save(flags);
 		if (pcp->count > 0)
 			free_pcppages_bulk(zone, pcp->count, pcp);
+		drain_zonestat(zone, pset);
 		setup_pageset(pset, batch);
 		local_irq_restore(flags);
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index b3e3b9d..d4cc1c2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -495,6 +495,18 @@ void refresh_cpu_vm_stats(int cpu)
 			atomic_long_add(global_diff[i], &vm_stat[i]);
 }
 
+void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
+{
+	int i;
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		if (pset->vm_stat_diff[i]) {
+			int v = pset->vm_stat_diff[i];
+			pset->vm_stat_diff[i] = 0;
+			atomic_long_add(v, &zone->vm_stat[i]);
+			atomic_long_add(v, &vm_stat[i]);
+		}
+}
 #endif
 
 #ifdef CONFIG_NUMA
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
