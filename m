From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 6/12] memcg optimize percpu stat
Date: Thu, 25 Sep 2008 15:18:23 +0900
Message-ID: <20080925151823.62bf6bd6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755120AbYIYGMU@vger.kernel.org>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-Id: linux-mm.kvack.org

Some obvious optimization to memcg.

I found mem_cgroup_charge_statistics() is a little big (in object) and
does unnecessary address calclation.
This patch is for optimization to reduce the size of this function.

And res_counter_charge() is 'likely' to success.

Changelog v3->v4:
 - merged with an other leaf patch.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -66,11 +66,10 @@ struct mem_cgroup_stat {
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
@@ -237,18 +236,21 @@ static void mem_cgroup_charge_statistics
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
 
@@ -609,7 +611,7 @@ static int mem_cgroup_charge_common(stru
 		css_get(&memcg->css);
 	}
 
-	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
+	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
 		if (!(gfp_mask & __GFP_WAIT))
 			goto out;
 
