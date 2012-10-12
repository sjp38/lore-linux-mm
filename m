Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 063286B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 06:15:02 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2991499pad.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 03:15:02 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 1/3] mm: vmstat: Implement set_zone_stat_thresholds() helper
Date: Fri, 12 Oct 2012 03:11:57 -0700
Message-Id: <1350036719-29031-1-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20121012101115.GA11825@lizard>
References: <20121012101115.GA11825@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

There are two things that affect vmstat accuracy:

- Per CPU pageset stats to global stats synchronization time;
- Per CPU pageset stats thresholds;

Currently user can only change vmstat update time (via stat_interval
sysctl, which is 1 second by default).

As for thresholds, the max threshold is 125 pages, which is per CPU, per
zone, so the vmstat inaccuracy might be significant. With vmevent API we
will able to set vmstat thresholds as well -- we will use this small
helper for this.

Note that since various MM areas depend on the accuracy too, we should be
very carefully to not downgrade it. User also have to understand that
lower thresholds puts more pressure on caches, and can somewhat degrade
performance, especially on very large systems. But that's the price for
accuracy (if it is needed).

p.s.

set_pgdat_percpu_threshold() used for_each_possible_cpu(), and
refresh_zone_stat_thresholds() used for_each_online_cpu(). I think
for_each_possible_cpu() is unnecessary, as on CPU hotplug we call
refresh_zone_stat_thresholds() anyway.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/vmstat.h |  6 ++++++
 mm/vmstat.c            | 52 ++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index ad2cfd5..590808d 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -202,6 +202,9 @@ int calculate_pressure_threshold(struct zone *zone);
 int calculate_normal_threshold(struct zone *zone);
 void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 				int (*calculate_pressure)(struct zone *));
+s8 set_zone_stat_thresholds(struct zone *zone,
+			    int (*calc_thres)(struct zone *zone),
+			    s8 force);
 #else /* CONFIG_SMP */
 
 /*
@@ -248,6 +251,9 @@ static inline void __dec_zone_page_state(struct page *page,
 
 #define set_pgdat_percpu_threshold(pgdat, callback) { }
 
+static inline s8 set_zone_stat_thresholds(struct zone *zone,
+					  int (*calc_thres)(struct zone *zone),
+					  s8 force) { return 0; }
 static inline void refresh_cpu_vm_stats(int cpu) { }
 static inline void refresh_zone_stat_thresholds(void) { }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index df7a674..3609e3e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -155,22 +155,55 @@ int calculate_normal_threshold(struct zone *zone)
 }
 
 /*
+ * set_zone_stat_thresholds() - Set zone stat thresholds
+ * @zone:	A zone to set thresholds for
+ * @calc_thres:	An optional callback to calculate thresholds
+ * @force:	An optional threshold value to force thresholds
+ *
+ * This function sets stat thresholds for a desired zone. The thresholds
+ * are either calculated by the optional @calc_thres callback, or set to
+ * the @force value. If @force is greater than current zone's threshold,
+ * the new value is ignored.
+ */
+s8 set_zone_stat_thresholds(struct zone *zone,
+			    int (*calc_thres)(struct zone *zone),
+			    s8 force)
+{
+	static s8 forced_threshold;
+	s8 thres = force;
+	uint cpu;
+
+	if (!calc_thres) {
+		if (!force)
+			calc_thres = calculate_normal_threshold;
+		forced_threshold = force;
+	}
+
+	if (calc_thres) {
+		thres = calc_thres(zone);
+		if (forced_threshold)
+			thres = min(thres, forced_threshold);
+	}
+
+	for_each_online_cpu(cpu)
+		per_cpu_ptr(zone->pageset, cpu)->stat_threshold = thres;
+
+	return thres;
+}
+
+/*
  * Refresh the thresholds for each zone.
  */
 void refresh_zone_stat_thresholds(void)
 {
 	struct zone *zone;
-	int cpu;
 	int threshold;
 
 	for_each_populated_zone(zone) {
 		unsigned long max_drift, tolerate_drift;
 
-		threshold = calculate_normal_threshold(zone);
-
-		for_each_online_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
+		threshold = set_zone_stat_thresholds(zone,
+				calculate_normal_threshold, 0);
 
 		/*
 		 * Only set percpu_drift_mark if there is a danger that
@@ -189,8 +222,6 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 				int (*calculate_pressure)(struct zone *))
 {
 	struct zone *zone;
-	int cpu;
-	int threshold;
 	int i;
 
 	for (i = 0; i < pgdat->nr_zones; i++) {
@@ -198,10 +229,7 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 		if (!zone->percpu_drift_mark)
 			continue;
 
-		threshold = (*calculate_pressure)(zone);
-		for_each_possible_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
+		set_zone_stat_thresholds(zone, calculate_pressure, 0);
 	}
 }
 
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
