Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 1AF246B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 08:26:28 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3681761pbb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 05:26:27 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 1/5] vmstat: Implement refresh_vm_stats()
Date: Fri,  1 Jun 2012 05:24:02 -0700
Message-Id: <1338553446-22292-1-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20120601122118.GA6128@lizard>
References: <20120601122118.GA6128@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

This function forcibly flushes per-cpu vmstat diff counters to the
global counters.

Note that we don't try to flush percpu pagesets, the pcp will be
still flushed once per 3 seconds.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/vmstat.h |    2 ++
 mm/vmstat.c            |   22 +++++++++++++++++++++-
 2 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 65efb92..2a53896 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -200,6 +200,7 @@ extern void __inc_zone_state(struct zone *, enum zone_stat_item);
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
+void refresh_vm_stats(void);
 void refresh_cpu_vm_stats(int);
 void refresh_zone_stat_thresholds(void);
 
@@ -253,6 +254,7 @@ static inline void __dec_zone_page_state(struct page *page,
 
 #define set_pgdat_percpu_threshold(pgdat, callback) { }
 
+static inline void refresh_vm_stats(void) { }
 static inline void refresh_cpu_vm_stats(int cpu) { }
 static inline void refresh_zone_stat_thresholds(void) { }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..4a9d432 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -13,6 +13,7 @@
 #include <linux/err.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/smp.h>
 #include <linux/cpu.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
@@ -434,7 +435,7 @@ EXPORT_SYMBOL(dec_zone_page_state);
  * with the global counters. These could cause remote node cache line
  * bouncing and will have to be only done when necessary.
  */
-void refresh_cpu_vm_stats(int cpu)
+static void __refresh_cpu_vm_stats(int cpu, bool drain_pcp)
 {
 	struct zone *zone;
 	int i;
@@ -456,11 +457,15 @@ void refresh_cpu_vm_stats(int cpu)
 				local_irq_restore(flags);
 				atomic_long_add(v, &zone->vm_stat[i]);
 				global_diff[i] += v;
+				if (!drain_pcp)
+					continue;
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
 				p->expire = 3;
 #endif
 			}
+		if (!drain_pcp)
+			continue;
 		cond_resched();
 #ifdef CONFIG_NUMA
 		/*
@@ -495,6 +500,21 @@ void refresh_cpu_vm_stats(int cpu)
 			atomic_long_add(global_diff[i], &vm_stat[i]);
 }
 
+void refresh_cpu_vm_stats(int cpu)
+{
+	__refresh_cpu_vm_stats(cpu, 1);
+}
+
+static void smp_call_refresh_cpu_vm_stats(void *info)
+{
+	__refresh_cpu_vm_stats(smp_processor_id(), 0);
+}
+
+void refresh_vm_stats(void)
+{
+	smp_call_function(smp_call_refresh_cpu_vm_stats, NULL, 1);
+}
+
 #endif
 
 #ifdef CONFIG_NUMA
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
