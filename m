Date: Tue, 27 Nov 2007 12:03:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [5/10] calculate active/inactive imbalance per cgroup
Message-Id: <20071127120314.e2386282.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

calculate active/inactive imbalance per memory cgroup.

Changelog V1 -> V2:
 - removed "total" (just count inactive and active)
 - fixed comment
 - fixed return type to be "long".

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/memcontrol.h |    8 ++++++++
 mm/memcontrol.c            |   14 ++++++++++++++
 2 files changed, 22 insertions(+)

Index: linux-2.6.24-rc3-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc3-mm1.orig/mm/memcontrol.c	2007-11-27 10:44:19.000000000 +0900
+++ linux-2.6.24-rc3-mm1/mm/memcontrol.c	2007-11-27 11:19:51.000000000 +0900
@@ -437,6 +437,20 @@
 	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
 	return (int)((rss * 100L) / total);
 }
+/*
+ * This function is called from vmscan.c. In page reclaiming loop. balance
+ * between active and inactive list is calculated. For memory controller
+ * page reclaiming, we should use using mem_cgroup's imbalance rather than
+ * zone's global lru imbalance.
+ */
+long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
+{
+	unsigned long active, inactive;
+	/* active and inactive are the number of pages. 'long' is ok.*/
+	active = mem_cgroup_get_all_zonestat(mem, MEM_CGROUP_ZSTAT_ACTIVE);
+	inactive = mem_cgroup_get_all_zonestat(mem, MEM_CGROUP_ZSTAT_INACTIVE);
+	return (long) (active / (inactive + 1));
+}
 
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
Index: linux-2.6.24-rc3-mm1/include/linux/memcontrol.h
===================================================================
--- linux-2.6.24-rc3-mm1.orig/include/linux/memcontrol.h	2007-11-27 10:44:19.000000000 +0900
+++ linux-2.6.24-rc3-mm1/include/linux/memcontrol.h	2007-11-27 11:19:00.000000000 +0900
@@ -65,6 +65,8 @@
  * For memory reclaim.
  */
 extern int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem);
+extern long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem);
+
 
 
 #else /* CONFIG_CGROUP_MEM_CONT */
@@ -142,6 +144,12 @@
 {
 	return 0;
 }
+
+static inline int mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
+{
+	return 0;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
