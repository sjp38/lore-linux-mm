Date: Thu, 11 Sep 2008 20:18:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 6/9] memcg: optimize stat
Message-Id: <20080911201846.5786c41c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com
List-ID: <linux-mm.kvack.org>

I found mem_cgroup_charge_statistics() is a little big (in object) and
does unnecessary address calclation.
This patch is for optimization to reduce the size of this function.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: mmtom-2.6.27-rc5+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc5+/mm/memcontrol.c
@@ -67,11 +67,10 @@ struct mem_cgroup_stat {
 /*
  * For accounting under irq disable, no need for increment preempt count.
  */
-static void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat *stat,
+static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat_cpu *stat,
 		enum mem_cgroup_stat_index idx, int val)
 {
-	int cpu = smp_processor_id();
-	stat->cpustat[cpu].count[idx] += val;
+	stat->count[idx] += val;
 }
 
 static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
@@ -242,18 +241,21 @@ static void mem_cgroup_charge_statistics
 {
 	int val = (charge)? 1 : -1;
 	struct mem_cgroup_stat *stat = &mem->stat;
+	struct mem_cgroup_stat_cpu *cpustat;
 
 	VM_BUG_ON(!irqs_disabled());
+
+	cpustat = &stat->cpustat[smp_processor_id()];
 	if (PageCgroupCache(pc))
-		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
+		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
 	else
-		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
+		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_RSS, val);
 
 	if (charge)
-		__mem_cgroup_stat_add_safe(stat,
+		__mem_cgroup_stat_add_safe(cpustat,
 				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
 	else
-		__mem_cgroup_stat_add_safe(stat,
+		__mem_cgroup_stat_add_safe(cpustat,
 				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
