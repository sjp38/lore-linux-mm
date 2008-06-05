Message-Id: <20080605021505.694195095@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com>
Date: Thu, 05 Jun 2008 11:12:16 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 5/5] introduce sysctl of throttle
Content-Disposition: inline; filename=05-reclaim-throttle-sysctl-v7.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

introduce sysctl parameter of max task of throttle.

<usage>
 # echo 5 > /proc/sys/vm/max_nr_task_per_zone
</usage>



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


---
 include/linux/swap.h |    2 ++
 kernel/sysctl.c      |    9 +++++++++
 mm/vmscan.c          |    4 +++-
 3 files changed, 14 insertions(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -125,9 +125,11 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
-#define MAX_RECLAIM_TASKS CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE
+#define MAX_RECLAIM_TASKS vm_max_nr_task_per_zone
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
+int vm_max_nr_task_per_zone __read_mostly
+       = CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 #define scan_global_lru(sc)	(!(sc)->mem_cgroup)
Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -206,6 +206,8 @@ static inline int zone_reclaim(struct zo
 
 extern int kswapd_run(int nid);
 
+extern int vm_max_nr_task_per_zone;
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
Index: b/kernel/sysctl.c
===================================================================
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1151,6 +1151,15 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "max_nr_task_per_zone",
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
