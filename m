Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E20F36B005C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 12:17:03 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/4] Reintroduce zone_reclaim_interval for when zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Date: Tue,  9 Jun 2009 18:01:44 +0100
Message-Id: <1244566904-31470-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1244566904-31470-1-git-send-email-mel@csn.ul.ie>
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On NUMA machines, the administrator can configure zone_reclaim_mode that is a
more targetted form of direct reclaim. On machines with large NUMA distances,
zone_reclaim_mode defaults to 1 meaning that clean unmapped pages will be
reclaimed if the zone watermarks are not being met. The problem is that
zone_reclaim() may get into a situation where it scans excessively without
making progress.

One such situation occured where a large tmpfs mount occupied a
large percentage of memory overall. The pages did not get reclaimed by
zone_reclaim(), but the lists are uselessly scanned frequencly making the
CPU spin at 100%. The observation in the field was that malloc() stalled
for a long time (minutes in some cases) when this situation occurs. This
situation should be resolved now and there are counters in place that
detect when the scan-avoidance heuristics break but the heuristics might
still not be bullet proof. If they fail again, the kernel should respond
in some fashion other than scanning uselessly chewing up CPU time.

This patch reintroduces zone_reclaim_interval which was removed by commit
34aa1330f9b3c5783d269851d467326525207422 [zoned vm counters: zone_reclaim:
remove /proc/sys/vm/zone_reclaim_interval. In the event the scan-avoidance
heuristics fail, the event is counted and zone_reclaim_interval avoids
excessive scanning.

Signed-off-by: Mel Gorman <mel@csn.ul.ie
Acked-by: Rik van Riel <riel@redhat.com>
---
 Documentation/sysctl/vm.txt |   15 +++++++++++++++
 include/linux/mmzone.h      |    9 +++++++++
 include/linux/swap.h        |    1 +
 kernel/sysctl.c             |    9 +++++++++
 mm/vmscan.c                 |   24 ++++++++++++++++++++++++
 5 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 0ea5adb..22ffc3e 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -52,6 +52,7 @@ Currently, these files are in /proc/sys/vm:
 - swappiness
 - vfs_cache_pressure
 - zone_reclaim_mode
+- zone_reclaim_interval
 
 
 ==============================================================
@@ -621,4 +622,18 @@ Allowing regular swap effectively restricts allocations to the local
 node unless explicitly overridden by memory policies or cpuset
 configurations.
 
+================================================================
+
+zone_reclaim_interval:
+
+The time allowed for off-node allocations after zone reclaim
+has failed to reclaim enough pages to allow a local allocation.
+
+Time is set in seconds and set by default to 30 seconds.
+
+Reduce the interval if undesired off-node allocations occur or
+set to 0 to always try and reclaim pages for node-local memory.
+However, too frequent scans will have a negative impact on
+off-node allocation performance and manifest as high CPU usage.
+
 ============ End of Document =================================
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8895985..3a53e1c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -335,6 +335,15 @@ struct zone {
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 
 	/*
+	 * timestamp (in jiffies) of the last zone_reclaim that scanned
+	 * but failed to free enough pages. This is used to avoid repeated
+	 * scans when zone_reclaim() is unable to detect in advance that
+	 * the scanning is useless. This can happen for example if a zone
+	 * has large numbers of clean unmapped file pages on tmpfs
+	 */
+	unsigned long		zone_reclaim_failure;
+
+	/*
 	 * prev_priority holds the scanning priority for this zone.  It is
 	 * defined as the scanning priority at which we achieved our reclaim
 	 * target at the previous try_to_free_pages() or balance_pgdat()
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c88b366..28a01e3 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -225,6 +225,7 @@ extern long vm_total_pages;
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
+extern int zone_reclaim_interval;
 extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 0554886..2afffa5 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1221,6 +1221,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "zone_reclaim_interval",
+		.data           = &zone_reclaim_interval,
+		.maxlen         = sizeof(zone_reclaim_interval),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec_jiffies,
+		.strategy       = &sysctl_jiffies,
+	},
+	{
 		.ctl_name	= VM_MIN_UNMAPPED,
 		.procname	= "min_unmapped_ratio",
 		.data		= &sysctl_min_unmapped_ratio,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8be4582..5fa4843 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2315,6 +2315,13 @@ int zone_reclaim_mode __read_mostly;
 #define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
 
 /*
+ * Minimum time between zone_reclaim() scans that failed. Ordinarily, a
+ * scan will not fail because it will be determined in advance if it can
+ * succeeed but this does not always work. See mmzone.h
+ */
+int zone_reclaim_interval __read_mostly = 30*HZ;
+
+/*
  * Priority for ZONE_RECLAIM. This determines the fraction of pages
  * of a node considered for each zone_reclaim. 4 scans 1/16th of
  * a zone.
@@ -2464,6 +2471,15 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
 		return ZONE_RECLAIM_FULL;
 
+	/* Watch for jiffie wraparound */
+	if (unlikely(jiffies < zone->zone_reclaim_failure))
+		zone->zone_reclaim_failure = jiffies;
+
+	/* Do not attempt a scan if scanning failed recently */
+	if (time_before(jiffies,
+			zone->zone_reclaim_failure + zone_reclaim_interval))
+		return ZONE_RECLAIM_FULL;
+
 	if (zone_is_all_unreclaimable(zone))
 		return ZONE_RECLAIM_FULL;
 
@@ -2491,6 +2507,14 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	if (!ret) {
 		count_vm_events(PGSCAN_ZONERECLAIM_FAILED, 1);
+
+		/*
+		 * We were unable to reclaim enough pages to stay on node and
+		 * unable to detect in advance that the scan would fail. Allow
+		 * off node accesses for zone_reclaim_inteval jiffies before
+		 * trying zone_reclaim() again
+		 */
+		zone->zone_reclaim_failure = jiffies;
 	}
 
 	return ret;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
