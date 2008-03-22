Date: Sat, 22 Mar 2008 19:51:05 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [for -mm][PATCH][2/2] page reclaim throttle take3 
In-Reply-To: <20080322192928.B30B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080322192928.B30B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080322194827.B314.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This patch adds sysctl that changes the number of max reclaim task. 



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/swap.h |    2 ++
 kernel/sysctl.c      |    9 +++++++++
 mm/vmscan.c          |    7 +++++--
 3 files changed, 16 insertions(+), 2 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-03-21 22:36:10.000000000 +0900
+++ b/mm/vmscan.c	2008-03-21 22:36:12.000000000 +0900
@@ -127,6 +127,8 @@ long vm_total_pages;	/* The total number
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
+int vm_max_nr_task_per_zone = CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE;
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 #define scan_global_lru(sc)	(!(sc)->mem_cgroup)
 #else
@@ -1202,7 +1204,7 @@ static int shrink_zone(int priority, str
 
 	wait_event(zone->reclaim_throttle_waitq,
 		   atomic_add_unless(&zone->nr_reclaimers, 1,
-				     CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE));
+ 				     vm_max_nr_task_per_zone));
 
 	/* more reclaim until needed? */
 	if (scan_global_lru(sc) &&
@@ -1430,7 +1432,8 @@ static unsigned long do_try_to_free_page
 			last_check_time = jiffies;
 
 			/* more reclaim until needed? */
-			for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+			for_each_zone_zonelist(zone, z, zonelist,
+					       high_zoneidx) {
 				if (zone_watermark_ok(zone, sc->order,
 						      4 * zone->pages_high,
 						      high_zoneidx, 0)) {
Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h	2008-03-14 21:51:36.000000000 +0900
+++ b/include/linux/swap.h	2008-03-14 22:31:35.000000000 +0900
@@ -206,6 +206,8 @@ static inline int zone_reclaim(struct zo
 
 extern int kswapd_run(int nid);
 
+extern int vm_max_nr_task_per_zone;
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
Index: b/kernel/sysctl.c
===================================================================
--- a/kernel/sysctl.c	2008-03-14 22:23:09.000000000 +0900
+++ b/kernel/sysctl.c	2008-03-14 22:32:08.000000000 +0900
@@ -1141,6 +1141,15 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "vm_max_nr_task_per_zone",
+		.data           = &vm_max_nr_task_per_zone,
+		.maxlen         = sizeof(vm_max_nr_task_per_zone),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec,
+		.strategy       = &sysctl_intvec,
+	},
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
