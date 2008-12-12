Return-Path: <linux-kernel-owner+w=401wt.eu-S1757945AbYLLIfX@vger.kernel.org>
Date: Fri, 12 Dec 2008 17:34:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH mmotm] memcg show real limit under hierarchy mode
Message-Id: <20081212173410.5085a9a1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


From:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Show "real" limit of memcg.
This helps my debugging and maybe useful for users.

While testing hierarchy like this

	mount -t cgroup none /cgroup -t memory
	mkdir /cgroup/A
	set use_hierarchy==1 to "A"
	mkdir /cgroup/A/01
	mkdir /cgroup/A/01/02
	mkdir /cgroup/A/01/03
	mkdir /cgroup/A/01/03/04
	mkdir /cgroup/A/08
	mkdir /cgroup/A/08/01
	....
and set each own limit to them, "real" limit of each memcg is unclear.
This patch shows real limit by checking all ancestors.

Changelog: (v1) -> (v2)
	- remove "if" and use "min(a,b)"

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.28-Dec11/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec11.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec11/mm/memcontrol.c
@@ -1757,6 +1757,34 @@ static int mem_cgroup_write(struct cgrou
 	return ret;
 }
 
+static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
+		unsigned long long *mem_limit, unsigned long long *memsw_limit)
+{
+	struct cgroup *cgroup;
+	unsigned long long min_limit, min_memsw_limit, tmp;
+
+	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+	cgroup = memcg->css.cgroup;
+	if (!memcg->use_hierarchy)
+		goto out;
+
+	while (cgroup->parent) {
+		cgroup = cgroup->parent;
+		memcg = mem_cgroup_from_cont(cgroup);
+		if (!memcg->use_hierarchy)
+			break;
+		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
+		min_limit = min(min_limit, tmp);
+		tmp = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+		min_memsw_limit = min(min_memsw_limit, tmp);
+	}
+out:
+	*mem_limit = min_limit;
+	*memsw_limit = min_memsw_limit;
+	return;
+}
+
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *mem;
@@ -1830,6 +1858,13 @@ static int mem_control_stat_show(struct 
 		cb->fill(cb, "unevictable", unevictable * PAGE_SIZE);
 
 	}
+	{
+		unsigned long long limit, memsw_limit;
+		memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
+		cb->fill(cb, "hierarchical_memory_limit", limit);
+		if (do_swap_account)
+			cb->fill(cb, "hierarchical_memsw_limit", memsw_limit);
+	}
 
 #ifdef CONFIG_DEBUG_VM
 	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
