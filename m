Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 087C86B0023
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:30:20 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EDEFD3EE0BC
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:30:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D025645DECB
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:30:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B716F45DEC3
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:30:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8B62E78003
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:30:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 657FC1DB8037
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:30:09 +0900 (JST)
Date: Thu, 26 May 2011 14:23:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 5/10] memcg keep margin to limit in background
Message-Id: <20110526142323.8e63941a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>


Still magic numbers existing..but...
==
When memcg is used, applications can see latency of memory reclaim
which is caused by the limit of memcg. In general, it's unavoidable
and the user's setting is wrong.

There are some class of application, which uses much Clean file caches
and do some interactive jobs. With that applications, if the kernel
can help memory reclaim in background, application latency can be
hidden to some extent. (It depends on how applications sleep..)

This patch adds a control knob to enable/disable a kernel help
to keep marging to limit in background.

If a user writes
  # echo 1 > /memory.async_control

The memcg tries to keep free space (called margin) to the limit in
background. The size of margin is calculated in dynamic way. The
value is determined to decrease opportunity for appliations to hit limit.
(Now, just use a random_walk.)


Changelog v2 -> v3:
  - totally reworked.
    - calculate margin to the limit in dynamic way.
    - divided user interface and internal flags.
    - added comments.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   44 ++++++++
 mm/memcontrol.c                  |  192 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 234 insertions(+), 2 deletions(-)

Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -115,10 +115,12 @@ enum mem_cgroup_events_index {
 enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_THRESH,
 	MEM_CGROUP_TARGET_SOFTLIMIT,
+	MEM_CGROUP_TARGET_KEEP_MARGIN,
 	MEM_CGROUP_NTARGETS,
 };
 #define THRESHOLDS_EVENTS_TARGET (128)
 #define SOFTLIMIT_EVENTS_TARGET (1024)
+#define KEEP_MARGIN_EVENTS_TARGET (512)
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
@@ -210,6 +212,10 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+static void mem_cgroup_reset_margin_to_limit(struct mem_cgroup *mem);
+static void mem_cgroup_update_margin_to_limit(struct mem_cgroup *mem);
+static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -278,6 +284,15 @@ struct mem_cgroup {
 	 */
 	unsigned long 	move_charge_at_immigrate;
 	/*
+ 	 * Checks for async reclaim.
+ 	 */
+	unsigned long	margin_to_limit_pages; /* margin to limit */
+	spinlock_t	update_margin_lock;
+	unsigned long	async_flags;
+#define AUTO_KEEP_MARGIN_ENABLED	(0) /* user enabled async reclaim */
+#define FAILED_TO_KEEP_MARGIN		(1) /* someone hit limit */
+
+	/*
 	 * percpu counter.
 	 */
 	struct mem_cgroup_stat_cpu *stat;
@@ -713,6 +728,9 @@ static void __mem_cgroup_target_update(s
 	case MEM_CGROUP_TARGET_SOFTLIMIT:
 		next = val + SOFTLIMIT_EVENTS_TARGET;
 		break;
+	case MEM_CGROUP_TARGET_KEEP_MARGIN:
+		next = val + KEEP_MARGIN_EVENTS_TARGET;
+		break;
 	default:
 		return;
 	}
@@ -736,6 +754,12 @@ static void memcg_check_events(struct me
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
+		/* update margin-to-limit and run async reclaim if necessary */
+		if (__memcg_event_check(mem, MEM_CGROUP_TARGET_KEEP_MARGIN)) {
+			mem_cgroup_may_async_reclaim(mem);
+			__mem_cgroup_target_update(mem,
+				MEM_CGROUP_TARGET_KEEP_MARGIN);
+		}
 	}
 }
 
@@ -2267,8 +2291,10 @@ static int mem_cgroup_do_charge(struct m
 	 * of regular pages (CHARGE_BATCH), or a single regular page (1).
 	 *
 	 * Never reclaim on behalf of optional batching, retry with a
-	 * single page instead.
+	 * single page instead. But mark we hit limit and give a hint
+	 * to auto_keep_margin.
 	 */
+	set_bit(FAILED_TO_KEEP_MARGIN, &mem->async_flags);
 	if (nr_pages == CHARGE_BATCH)
 		return CHARGE_RETRY;
 
@@ -3552,6 +3578,7 @@ static int mem_cgroup_resize_limit(struc
 				memcg->memsw_is_minimum = true;
 			else
 				memcg->memsw_is_minimum = false;
+			mem_cgroup_reset_margin_to_limit(memcg);
 		}
 		mutex_unlock(&set_limit_mutex);
 
@@ -3729,6 +3756,131 @@ unsigned long mem_cgroup_soft_limit_recl
 	return nr_reclaimed;
 }
 
+
+/*
+ * Auto-keep-margin and Dynamic auto margin calculation.
+ *
+ * When an application hits memcg's limit, it need to scan LRU and reclaim
+ * memory. This means extra latency is added by setting limit of memcg. With
+ * some class of applications, a kernel help, freeing pages in background
+ * works good and can reduce their latency and stabilize their works.
+ *
+ * The porblem here is what amount of margin should be kept for keeping
+ * applications hit limit. In general, margin to the limit should be as small
+ * as possible because the user wants to use memory up to the limit, he defined.
+ * But small margin is just a small help.
+ * Below is a code for calculating margin to limit in dynamic way. The margin
+ * is determined by the size of limit and workload.
+ *
+ * At initial, margin is set to MIN_MARGIN_TO_LIMIT and the kernel tries to
+ * keep free bytes of it. If someone hit limit and failcnt increases, this
+ * margin is increase by twice. The kernel periodically checks the
+ * status. If it finds free space is enough, it decreases the margin
+ * LIMIT_MARGIN_STEP. This means the window of margin increases
+ * in exponential (to catch rapid workload) but decreased in linear way.
+ *
+ * This feature is enabled only when AUTO_KEEP_MARGIN_ENABLED is set.
+ */
+#define MIN_MARGIN_TO_LIMIT	((4*1024*1024) >> PAGE_SHIFT)
+#define MAX_MARGIN_TO_LIMIT	((64*1024*1024) >> PAGE_SHIFT)
+#define MAX_MARGIN_LIMIT_RATIO  (5)		/* 5% of limit */
+#define MARGIN_SHRINK_STEP	((256 * 1024) >>PAGE_SHIFT)
+
+enum {
+	MARGIN_RESET,	/* used when limit is set */
+	MARGIN_ENLARGE,	/* called when margin seems not enough */
+	MARGIN_SHRINK,	/* called when margin seems enough */
+};
+
+static void
+__mem_cgroup_update_limit_margin(struct mem_cgroup *mem, int action)
+{
+	u64 max_margin, limit;
+
+	/*
+ 	 * Note: this function is racy. But the race will be harmless.
+ 	 */
+
+	limit = res_counter_read_u64(&mem->res, RES_LIMIT) >> PAGE_SHIFT;
+
+	max_margin = min(limit * MAX_MARGIN_LIMIT_RATIO/100,
+			(u64) MAX_MARGIN_TO_LIMIT);
+
+	switch (action) {
+	case MARGIN_RESET:
+		mem->margin_to_limit_pages = MIN_MARGIN_TO_LIMIT;
+		if (mem->margin_to_limit_pages < max_margin)
+			mem->margin_to_limit_pages = max_margin;
+		break;
+	case MARGIN_ENLARGE:
+		if (mem->margin_to_limit_pages < max_margin)
+			mem->margin_to_limit_pages *= 2;
+		if (mem->margin_to_limit_pages > max_margin)
+			mem->margin_to_limit_pages = max_margin;
+		break;
+	case MARGIN_SHRINK:
+		if (mem->margin_to_limit_pages > MIN_MARGIN_TO_LIMIT)
+			mem->margin_to_limit_pages -= MARGIN_SHRINK_STEP;
+		if (mem->margin_to_limit_pages < MIN_MARGIN_TO_LIMIT)
+			mem->margin_to_limit_pages = MIN_MARGIN_TO_LIMIT;
+		break;
+	}
+	return;
+}
+
+/*
+ * Called by percpu event counter.
+ */
+static void mem_cgroup_update_margin_to_limit(struct mem_cgroup *mem)
+{
+	if (!test_bit(AUTO_KEEP_MARGIN_ENABLED, &mem->async_flags))
+		return;
+	/* If someone does update, we don't need to update */
+	if (!spin_trylock(&mem->update_margin_lock))
+		return;
+	/*
+	 * If someone hits limit, enlarge margin. If no one hits and
+	 * it seems there are minimum margin, shrink it.
+	 */
+	if (test_and_clear_bit(FAILED_TO_KEEP_MARGIN, &mem->async_flags))
+		__mem_cgroup_update_limit_margin(mem, MARGIN_ENLARGE);
+	else if (mem_cgroup_margin(mem) > MIN_MARGIN_TO_LIMIT)
+		__mem_cgroup_update_limit_margin(mem, MARGIN_SHRINK);
+
+	spin_unlock(&mem->update_margin_lock);
+	return;
+}
+
+/*
+ * Called when the limit changes.
+ */
+static void mem_cgroup_reset_margin_to_limit(struct mem_cgroup *mem)
+{
+	spin_lock(&mem->update_margin_lock);
+	__mem_cgroup_update_limit_margin(mem, MARGIN_RESET);
+	spin_unlock(&mem->update_margin_lock);
+}
+
+/*
+ * Run a asynchronous memory reclaim on the memcg.
+ */
+static void mem_cgroup_schedule_async_reclaim(struct mem_cgroup *mem)
+{
+}
+
+/*
+ * Check memcg's flag and if margin to limit is smaller than limit_margin,
+ * schedule asynchronous memory reclaim in background.
+ */
+static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem)
+{
+	if (!test_bit(AUTO_KEEP_MARGIN_ENABLED, &mem->async_flags))
+		return;
+	mem_cgroup_update_margin_to_limit(mem);
+	if (mem_cgroup_margin(mem) < mem->margin_to_limit_pages)
+		mem_cgroup_schedule_async_reclaim(mem);
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
@@ -4329,11 +4481,43 @@ static int mem_control_stat_show(struct 
 		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
 		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
 	}
+	cb->fill(cb, "margin_to_limit",
+		(u64)mem_cont->margin_to_limit_pages << PAGE_SHIFT);
 #endif
 
 	return 0;
 }
 
+/*
+ * User flags for async_control is a subset of mem->async_flags. But
+ * this needs to be defined independently to hide implemation details.
+ */
+#define USER_AUTO_KEEP_MARGIN_ENABLE	(0)
+static int mem_cgroup_async_control_write(struct cgroup *cgrp,
+			struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	unsigned long user_flag = val;
+
+	if (test_bit(USER_AUTO_KEEP_MARGIN_ENABLE, &user_flag))
+		set_bit(AUTO_KEEP_MARGIN_ENABLED, &mem->async_flags);
+	else
+		clear_bit(AUTO_KEEP_MARGIN_ENABLED, &mem->async_flags);
+	mem_cgroup_reset_margin_to_limit(mem);
+	return 0;
+}
+
+static u64 mem_cgroup_async_control_read(struct cgroup *cgrp,
+			struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	unsigned long val = 0;
+
+	if (test_bit(AUTO_KEEP_MARGIN_ENABLED, &mem->async_flags))
+		set_bit(USER_AUTO_KEEP_MARGIN_ENABLE, &val);
+	return (u64)val;
+}
+
 static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
@@ -4816,6 +5000,11 @@ static struct cftype memsw_cgroup_files[
 		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
+	{
+		.name = "async_control",
+		.read_u64 = mem_cgroup_async_control_read,
+		.write_u64 = mem_cgroup_async_control_write,
+	},
 };
 
 static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
@@ -5049,6 +5238,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		mem->swappiness = mem_cgroup_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
+	spin_lock_init(&mem->update_margin_lock);
 	mutex_init(&mem->thresholds_lock);
 	return &mem->css;
 free_out:
Index: memcg_async/Documentation/cgroups/memory.txt
===================================================================
--- memcg_async.orig/Documentation/cgroups/memory.txt
+++ memcg_async/Documentation/cgroups/memory.txt
@@ -70,6 +70,7 @@ Brief summary of control files.
 				 (See sysctl's vm.swappiness)
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
+ memory.async_control		 # set control for asynchronous memory reclaim
 
 1. History
 
@@ -433,6 +434,7 @@ recent_rotated_anon	- VM internal parame
 recent_rotated_file	- VM internal parameter. (see mm/vmscan.c)
 recent_scanned_anon	- VM internal parameter. (see mm/vmscan.c)
 recent_scanned_file	- VM internal parameter. (see mm/vmscan.c)
+margin_to_limit		- The margin to limit to be kept.
 
 Memo:
 	recent_rotated means recent frequency of LRU rotation.
@@ -664,7 +666,47 @@ At reading, current status of OOM is sho
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
-11. TODO
+11. Asynchronous memory reclaim
+
+Running some kind of applications which uses many file caches, once memory
+cgroup hit, it gets memory reclaim latency. By shrinking usage in background,
+this latency can be hidden with a kernel help if cpu is enough free.
+
+Memory cgroup provides a method for asynchronous memory reclaim for freeing
+memory before hitting limit. By this, some class of application can reduce
+latency effectively and show good/stable peformance. For example, if an
+application reads data from files bigger than limit, freeing memory in
+background will reduce latency of read.
+
+(*)please note, even if latency is hiddedn, the CPU is used in background.
+   So, asynchronous memory reclaim works effectively only when you have
+   extra unused CPU, or applications tend to sleep. On UP host, context-switch
+   by background job can just make perfomance worse.
+   So, if you see this feature doesn't help your application, please leave it
+   turned off.
+
+11.1 memory.async_control
+
+memory.async_control is a control for asynchronous memory reclaim and
+represented as bitmask of controls.
+
+ bit 0 ....user control of automatic keep margin to limit (see below)
+
+ bit 0:
+   Automatic keep margin to limit is a feature to keep free space to the
+   limit by freeing memory in background. The size of margin is calculated
+   by the kernel automatically and it can be changed with information of
+   jobs.
+
+   This feature can be enabled by
+
+   echo 1 > memory.async_control
+
+   Note: This feature is not propageted to childrens in automatic. This
+   may be conservative but required limitation to avoid using too much
+   cpus.
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
