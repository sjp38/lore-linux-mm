Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5020D6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 10:47:26 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id ho1so1129281wib.13
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 07:47:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mz5si47801470wic.67.2014.06.06.07.47.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 07:47:24 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit reclaim
Date: Fri,  6 Jun 2014 16:46:50 +0200
Message-Id: <1402066010-25901-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1402066010-25901-1-git-send-email-mhocko@suse.cz>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Some users (e.g. Google) would like to have stronger semantic than low
limit offers currently. The fallback mode is not desirable and they
prefer hitting OOM killer rather than ignoring low limit for protected
groups. There are other possible usecases which can benefit from hard
guarantees. I can imagine workloads where setting low_limit to the same
value as hard_limit to prevent from any reclaim at all makes a lot of
sense because reclaim is much more disrupting than restart of the load.

This patch adds a new per memcg memory.reclaim_strategy knob which
tells what to do in a situation when memory reclaim cannot do any
progress because all groups in the reclaimed hierarchy are within their
low_limit. There are two options available:
	- low_limit_best_effort - the current mode when reclaim falls
	  back to the even reclaim of all groups in the reclaimed
	  hierarchy
	- low_limit_guarantee - groups within low_limit are never
	  reclaimed and OOM killer is triggered instead. OOM message
	  will mention the fact that the OOM was triggered due to
	  low_limit reclaim protection.

Root memcg's knob refers to the global memory reclaim and new memcgs
inherit the setting from parents (or root memcg if this is
!use_hierarchy setup). The initial value for the root memcg is defined
by the config (CONFIG_MEMCG_LOW_LIMIT_GUARANTEE or
CONFIG_MEMCG_LOW_LIMIT_BEST_EFFORT) and it can be changed later in
runtime.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/cgroups/memory.txt | 21 +++++++++--
 include/linux/memcontrol.h       |  5 +++
 init/Kconfig                     | 75 ++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c                  | 55 +++++++++++++++++++++++++++++
 mm/oom_kill.c                    |  6 ++--
 mm/vmscan.c                      |  5 ++-
 6 files changed, 161 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index bf895d7e1363..c6785d575b18 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -61,6 +61,8 @@ Brief summary of control files.
  memory.low_limit_breached	 # number of times low_limit has been
 				 # ignored and the cgroup reclaimed even
 				 # when it was above the limit
+ memory.reclaim_strategy	 # strategy when no progress can be made
+				 # because of low_limit reclaim protection
  memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
  memory.failcnt			 # show the number of memory usage hits limits
  memory.memsw.failcnt		 # show the number of memory+Swap hits limits
@@ -253,9 +255,22 @@ low_limit_in_bytes knob. If the limit is non-zero the reclaim logic
 doesn't include groups (and their subgroups - see 6. Hierarchy support)
 which are below the low limit if there is other eligible cgroup in the
 reclaimed hierarchy. If all groups which participate reclaim are under
-their low limits then all of them are reclaimed and the low limit is
-ignored. low_limit_breached counter in memory.stat file can be checked
-to see how many times such an event occurred.
+their low limits then reclaim cannot make any forward process. The further
+behavior depends on memory.reclaim_strategy configuration of the memory
+cgroup which is target of the memory pressure. There are two possible
+modes available:
+	- low_limit_best_effort - low_limit value is ignored and all the
+	  groups are reclaimed evenly. low_limit_breached counter in
+	  memory.stat file of each cgroup can be checked to see how many
+	  times such an event occurred.
+	- low_limit_guarantee - no groups are reclaimed and OOM killer will
+	  be triggered to sort out the situation.
+
+memory.reclaim_strategy is inherited from parent cgroup but it can
+be changed down the hierarchy. Root cgroup's file refers to the
+global memory reclaim and it is defined according to config (either
+CONFIG_MEMCG_LOW_LIMIT_GUARANTEE or CONFIG_MEMCG_LOW_LIMIT_BEST_EFFORT)
+and can be changed in runtime as well.
 
 Note2: When panic_on_oom is set to "2", the whole system will panic.
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5e2ca2163b12..0b61da737521 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -97,6 +97,7 @@ extern bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
 
 extern void mem_cgroup_guarantee_breached(struct mem_cgroup *memcg);
 extern bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root);
+extern bool mem_cgroup_hard_guarantee(struct mem_cgroup *memcg);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
@@ -306,6 +307,10 @@ static inline bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
 {
 	return false;
 }
+static inline bool mem_cgroup_hard_guarantee(struct mem_cgroup *memcg)
+{
+	return false;
+}
 
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
diff --git a/init/Kconfig b/init/Kconfig
index 8a2d7394c75f..fe78f3f99265 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -936,6 +936,81 @@ config MEMCG
 	  this, you can set "cgroup_disable=memory" at your boot option to
 	  disable memory resource controller and you can avoid overheads.
 	  (and lose benefits of memory resource controller)
+choice
+	prompt "Memory Resource Controller reclaim protection"
+	depends on MEMCG
+	help
+	   Memory resource controller allows for memory protection by
+	   low_limit_in_bytes knob. If the memory consumption of all
+	   processes inside the group is less than the limit then
+	   the group is excluded from the memory reclaim and so the
+	   charged memory is protected from external memory pressure.
+	   This can be used for memory isolation of different loads
+	   running on the same machines by separating them to groups
+	   with appropriate low limits.
+
+	   Please note that the configuration of low limits has to be
+	   done carefully because inappropriate setup can render the machine
+	   unusable. A typical example would be a too large limit and
+	   so not enough memory available for the rest of the system
+	   resulting in memory trashing or other misbehaviors.
+
+	   If the memory reclaim ends up in a position that all memory
+	   cgroups are within their limits then there is no way to proceed
+	   and free some memory. There are two possible situations how to
+	   handle this situation. The reclaimer can either fall back to
+	   ignoring low_limits and reclaim all groups in fair manner or
+	   Out of memory killer is triggered to sort out the situation.
+
+	   This section provides a way to setup default behavior which is
+	   then inherited by newly created memory cgroups. Each cgroup can
+	   redefine this default by memory.reclaim_strategy file and the
+	   behavior will apply to the memory pressure applied to it. Root
+	   memory cgroup controls behavior of the global memory pressure.
+
+config MEMCG_LOW_LIMIT_BEST_EFFORT
+	bool "Treat low_limit as a best effort"
+	help
+	   Memory reclaim (both global and triggered by hard limit) will
+	   fall back to the proportional reclaim when all memory cgroups
+	   of the reclaimed hierarchy are within their low_limits. This
+	   situation shouldn't happen if the cumulative low_limit setup
+	   doesn't overcommit available memory (available RAM for global
+	   reclaim resp. hard limit). User space memory, which is tracked
+	   by Memory Resource Controller, is not the only one on the system,
+	   though, and kernel has to use some memory as well and that is
+	   not a fixed amount. So sometimes it might be really hard to
+	   estimate to appropriate maximum for low_limits so they are still
+	   safe.
+
+	   If you need a reasonable memory isolation and the workload
+	   protected by the low_limit will handle ephemeral reclaim much
+	   better than a potential OOM killer then you should use this
+	   mode. memory.stat file and low_limit_breached counter will
+	   tell you how many times the limit has been ignored because
+	   the system couldn't make any progress due to low_limit setup.
+
+config MEMCG_LOW_LIMIT_GUARANTEE
+	bool "Treat low_limit as a hard guarantee"
+	help
+	   Memory reclaim (both global and triggered by hard limit) will
+	   trigger OOM killer (either global one or memcg depending on
+	   the reclaim context) to resolve the situation.
+
+	   Although this setup might sound too harsh it has a nice property
+	   that once the low_limit is set the group is guaranteed to be
+	   unreclaimable under all conditions. A process from the group
+	   still might get killed by OOM killer though. This is a really
+	   strong property and should be used with care. Administrator
+	   has be to be careful to keep enough memory for the kernel, drivers
+	   and other memory which is not accounted to Memory Controller
+	   (e.g. hugetlbfs, slab allocations, page tables, etc...).
+
+	   Select this option if you need low_limit to behave as a guarantee
+	   and absolutely no reclaim is allowed while groups are within the
+	   limit.
+
+endchoice
 
 config MEMCG_SWAP
 	bool "Memory Resource Controller Swap Extension"
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7f62b6533f60..302691dceb8c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -377,6 +377,8 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;
 
+	bool hard_low_limit;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
@@ -2856,6 +2858,22 @@ bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
 	return true;
 }
 
+/** mem_cgroup_hard_guarantee - Does the memcg require hard guarantee for memory
+ * @memcg: memcg to check
+ *
+ * Reclaimer is not allow to reclaim group if mem_cgroup_within_guarantee is
+ * true.
+ */
+bool mem_cgroup_hard_guarantee(struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return false;
+
+	if (!memcg)
+		memcg = root_mem_cgroup;
+	return memcg->hard_low_limit;
+}
+
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	struct mem_cgroup *memcg = NULL;
@@ -5203,6 +5221,33 @@ static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
 	return ret;
 }
 
+static int mem_cgroup_write_reclaim_strategy(struct cgroup_subsys_state *css, struct cftype *cft,
+			    char *buffer)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	int ret = 0;
+
+	if (!strncmp(buffer, "low_limit_guarantee",
+				sizeof("low_limit_guarantee"))) {
+		memcg->hard_low_limit = true;
+	} else if (!strncmp(buffer, "low_limit_best_effort",
+				sizeof("low_limit_best_effort"))) {
+		memcg->hard_low_limit = false;
+	} else
+		ret = -EINVAL;
+
+	return ret;
+}
+
+static int mem_cgroup_read_reclaim_strategy(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	seq_printf(m, "%s\n", memcg->hard_low_limit ?
+			"low_limit_guarantee" : "low_limit_best_effort");
+
+	return 0;
+}
+
 static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
 		unsigned long long *mem_limit, unsigned long long *memsw_limit)
 {
@@ -6110,6 +6155,11 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_read_u64,
 	},
 	{
+		.name = "reclaim_strategy",
+		.write_string = mem_cgroup_write_reclaim_strategy,
+		.seq_show = mem_cgroup_read_reclaim_strategy
+	},
+	{
 		.name = "soft_limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_SOFT_LIMIT),
 		.write_string = mem_cgroup_write,
@@ -6375,6 +6425,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	/* root ? */
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
+#ifdef CONFIG_MEMCG_LOW_LIMIT_GUARANTEE
+		memcg->hard_low_limit = true;
+#endif
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
 		res_counter_init(&memcg->kmem, NULL);
@@ -6418,6 +6471,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		res_counter_init(&memcg->res, &parent->res);
 		res_counter_init(&memcg->memsw, &parent->memsw);
 		res_counter_init(&memcg->kmem, &parent->kmem);
+		memcg->hard_low_limit = parent->hard_low_limit;
 
 		/*
 		 * No need to take a reference to the parent because cgroup
@@ -6434,6 +6488,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		 */
 		if (parent != root_mem_cgroup)
 			memory_cgrp_subsys.broken_hierarchy = true;
+		memcg->hard_low_limit = root_mem_cgroup->hard_low_limit;
 	}
 	mutex_unlock(&memcg_create_mutex);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3291e82d4352..80e5aafe7ade 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -392,9 +392,11 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 {
 	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_score_adj=%hd\n",
+		"oom_score_adj=%hd%s\n",
 		current->comm, gfp_mask, order,
-		current->signal->oom_score_adj);
+		current->signal->oom_score_adj,
+		mem_cgroup_all_within_guarantee(memcg) ?
+		" because all groups are withing low_limit guarantee":"");
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
 	dump_stack();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99137aecd95f..11e841bb5d44 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2309,8 +2309,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		 * b) multiple reclaimers are racing and so the first round
 		 *    should be retried
 		 */
-		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
+		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup)) {
+			if (mem_cgroup_hard_guarantee(sc->target_mem_cgroup))
+				break;
 			honor_guarantee = false;
+		}
 	}
 }
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
