Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3778D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:36:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 83EFC3EE0AE
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:36:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A9E145DE51
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:36:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5246345DE4E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:36:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 44455E78003
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:36:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 037941DB803E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:36:29 +0900 (JST)
Date: Mon, 25 Apr 2011 18:29:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/7] memcg high watermark interface
Message-Id: <20110425182953.fd33f261.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

Add memory.high_wmark_distance and reclaim_wmarks API per memcg.
The first adjust the internal low/high wmark calculation and 
the reclaim_wmarks exports the current value of watermarks.
low_wmark is caclurated in automatic.

$ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
$ cat /dev/cgroup/A/memory.limit_in_bytes
524288000

$ echo 50m >/dev/cgroup/A/memory.high_wmark_distance

$ cat /dev/cgroup/A/memory.reclaim_wmarks
low_wmark 476053504
high_wmark 471859200

Change v8a..v7
   1. removed low_wmark_distance it's now automatic.
   2. added Documenation.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   43 ++++++++++++++++++++++++++++
 mm/memcontrol.c                  |   58 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 100 insertions(+), 1 deletion(-)

Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -4074,6 +4074,40 @@ static int mem_cgroup_swappiness_write(s
 	return 0;
 }
 
+static u64 mem_cgroup_high_wmark_distance_read(struct cgroup *cgrp,
+					       struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return memcg->high_wmark_distance;
+}
+
+static int mem_cgroup_high_wmark_distance_write(struct cgroup *cont,
+						struct cftype *cft,
+						const char *buffer)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	unsigned long long val;
+	u64 limit;
+	int ret;
+
+	if (!cont->parent)
+		return -EINVAL;
+
+	ret = res_counter_memparse_write_strategy(buffer, &val);
+	if (ret)
+		return -EINVAL;
+
+	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+	if (val >= limit)
+		return -EINVAL;
+
+	memcg->high_wmark_distance = val;
+
+	setup_per_memcg_wmarks(memcg);
+	return 0;
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4365,6 +4399,21 @@ static void mem_cgroup_oom_unregister_ev
 	mutex_unlock(&memcg_oom_mutex);
 }
 
+static int mem_cgroup_wmark_read(struct cgroup *cgrp,
+	struct cftype *cft,  struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	u64 low_wmark, high_wmark;
+
+	low_wmark = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
+	high_wmark = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
+
+	cb->fill(cb, "low_wmark", low_wmark);
+	cb->fill(cb, "high_wmark", high_wmark);
+
+	return 0;
+}
+
 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 	struct cftype *cft,  struct cgroup_map_cb *cb)
 {
@@ -4468,6 +4517,15 @@ static struct cftype mem_cgroup_files[] 
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "high_wmark_distance",
+		.write_string = mem_cgroup_high_wmark_distance_write,
+		.read_u64 = mem_cgroup_high_wmark_distance_read,
+	},
+	{
+		.name = "reclaim_wmarks",
+		.read_map = mem_cgroup_wmark_read,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
Index: memcg/Documentation/cgroups/memory.txt
===================================================================
--- memcg.orig/Documentation/cgroups/memory.txt
+++ memcg/Documentation/cgroups/memory.txt
@@ -68,6 +68,8 @@ Brief summary of control files.
 				 (See sysctl's vm.swappiness)
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
+ memory.hiwmark_distance	 # set/show watermark control
+ memory.reclaim_wmarks		 # show watermark details.
 
 1. History
 
@@ -501,6 +503,7 @@ NOTE2: When panic_on_oom is set to "2", 
        case of an OOM event in any cgroup.
 
 7. Soft limits
+(See Watermarks, too.)
 
 Soft limits allow for greater sharing of memory. The idea behind soft limits
 is to allow control groups to use as much of the memory as needed, provided
@@ -649,7 +652,45 @@ At reading, current status of OOM is sho
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
-11. TODO
+11. Watermarks
+
+Tasks gets big overhead when it hits memory limit because it needs to scan
+memory and free them. To avoid that, some background memory freeing by
+kernel will be helpful. Memory cgroup supports background memory freeing
+by threshold called Watermarks. It can be used for fuzzy limiting of memory.
+
+For example, if you have 1G limit and set
+  - high_watermark ....980M
+  - low_watermark  ....984M
+Memory freeing work by kernel starts when usage goes over 984M until memory
+usage goes down to 980M. Of course, this cousumes CPU. So, the kernel controls
+this work to avoid too much cpu hogging.
+
+11.1 memory.high_wmark_distance
+
+This is an interface for high_wmark. You can specify the distance between
+the limit of memory and high_watemark here. For example, under 1G limit memroy
+cgroup,
+  # echo 20M > memory.high_wmark_distance
+will set high_watermark as 980M. low_watermark is _automatically_ determined
+because big distance between high-low watermark tend to use too much CPU and
+it's difficult to determine low_watermark by users.
+
+With this, memory usage will be reduced to 980M as time goes by.
+After setting memory.high_wmark_distance to be 20M, assume you update
+memory.limit_in_bytes to be 2G bytes. In this case, hiwh_watermak is 1980M.
+
+Another thinking, assume you have memory.limit_in_bytes to be 1G.
+Then, set memory.high_wmark_distance as 300M. Then, you can limit memory
+usage under 700M in moderate way and you can limit it under 1G with hard
+limit.
+
+11.2 memory.reclaim_wmarks
+
+This interface shows high_watermark and low_watermark in bytes. Maybe
+useful at compareing usage/watermarks.
+
+12. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
