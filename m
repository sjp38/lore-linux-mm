Date: Sun, 30 Mar 2008 17:19:40 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH][-mm][2/2] introduce sysctl i/f of max task of throttle
In-Reply-To: <20080330171152.89D5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080330171152.89D5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080330171528.89DB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

introduce sysctl parameter of max task of throttle.

<usage>
 # echo 5 > /proc/sys/vm/max_nr_task_per_zone

 set max reclaim tasks at the same time to 5.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/swap.h |    2 ++
 kernel/sysctl.c      |    9 +++++++++
 mm/vmscan.c          |    3 ++-
 3 files changed, 13 insertions(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-03-27 17:47:15.000000000 +0900
+++ b/mm/vmscan.c	2008-03-27 17:47:39.000000000 +0900
@@ -124,9 +124,10 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
-#define MAX_RECLAIM_TASKS CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE
+#define MAX_RECLAIM_TASKS vm_max_nr_task_per_zone
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
+int vm_max_nr_task_per_zone = CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 #define scan_global_lru(sc)	(!(sc)->mem_cgroup)
Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h	2008-03-27 17:45:45.000000000 +0900
+++ b/include/linux/swap.h	2008-03-27 17:47:39.000000000 +0900
@@ -206,6 +206,8 @@ static inline int zone_reclaim(struct zo
 
 extern int kswapd_run(int nid);
 
+extern int vm_max_nr_task_per_zone;
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
Index: b/kernel/sysctl.c
===================================================================
--- a/kernel/sysctl.c	2008-03-27 17:45:45.000000000 +0900
+++ b/kernel/sysctl.c	2008-03-27 19:41:12.000000000 +0900
@@ -1141,6 +1141,15 @@ static struct ctl_table vm_table[] = {
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
