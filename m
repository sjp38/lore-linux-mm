Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id AC9C36B00AB
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 10:40:00 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id n12so999846wgh.33
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 07:40:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg8si3708975wib.8.2014.07.16.07.39.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 07:39:58 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Date: Wed, 16 Jul 2014 16:39:38 +0200
Message-Id: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Starting with 8f9ac36d2cbb (cgroup: distinguish the default and legacy
hierarchies when handling cftypes) memory cgroup controller doesn't
export any knobs because all of them are marked as legacy. The idea is
that only selected knobs are exported for the new cgroup API.

This patch exports the core knobs for the memory controller. The
following knobs are not and won't be available in the default (aka
unified) hierarchy:
- use_hierarchy - was one of the biggest mistakes when memory controller
  was introduced. It allows for creating hierarchical cgroups structure
  which doesn't have any hierarchical accounting. This leads to really
  strange configurations where other co-mounted controllers behave
  hierarchically while memory controller doesn't.
  All controllers have to be hierarchical with the new cgroups API so
  this knob doesn't make any sense here.
- force_empty - has been introduced primarily to drop memory before it
  gets reparented on the group removal.  This alone doesn't sound
  fully justified because reparented pages which are not in use can be
  reclaimed also later when there is a memory pressure on the parent
  level.
  Another use-case would be something like per-memcg /proc/sys/vm/drop_caches
  which doesn't sound like a great idea either. We are trying to get
  away from using it on the global level so we shouldn't allow that on
  per-memcg level as well.
- soft_limit_in_bytes - has been originally introduced to help to
  recover from the overcommit situations where the overall hard limits
  on the system are higher than the available memory. A group which has
  the largest excess on the soft limit is reclaimed to help to reduce
  memory pressure during the global memory pressure.
  The primary problem with this tunable is that every memcg is soft
  unlimited by default which is reverse to what would be expected from
  such a knob.
  Another problem is that soft limit is considered only during the
  global memory pressure rather than on an external memory pressure in
  general (e.g. triggered by the limit hit on a parent up the
  hierarchy).
  There are other issues which are tight to the implementation (e.g.
  priority-0 reclaim used for the soft limit reclaim etc.) which are
  really hard to fix without breaking potential users.
  There will be a replacement for the soft limit in the unified
  hierarchy and users will be encouraged to switch their configuration
  to the new scheme. Until this is available users are suggested to stay
  with the legacy cgroup API.

TCP kmem sub-controller is not exported at this stage because this one has
seen basically no traction since it was merged and it is not entirely
clear why kmem controller cannot be used for the same purpose. Having 2
controllers for tracking kernel memory allocations sounds like too much.
If there are use-cases and reasons for not merging it into kmem then we
can reconsider and allow it for the new cgroups API later.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/cgroups/memory.txt |  19 ++++---
 mm/memcontrol.c                  | 105 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 115 insertions(+), 9 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 02ab997a1ed2..a8f01497c5de 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -62,10 +62,10 @@ Brief summary of control files.
  memory.memsw.failcnt		 # show the number of memory+Swap hits limits
  memory.max_usage_in_bytes	 # show max memory usage recorded
  memory.memsw.max_usage_in_bytes # show max memory+Swap usage recorded
- memory.soft_limit_in_bytes	 # set/show soft limit of memory usage
+[D] memory.soft_limit_in_bytes	 # set/show soft limit of memory usage
  memory.stat			 # show various statistics
- memory.use_hierarchy		 # set/show hierarchical account enabled
- memory.force_empty		 # trigger forced move charge to parent
+[D] memory.use_hierarchy		 # set/show hierarchical account enabled
+[D] memory.force_empty		 # trigger forced move charge to parent
  memory.pressure_level		 # set memory pressure notifications
  memory.swappiness		 # set/show swappiness parameter of vmscan
 				 (See sysctl's vm.swappiness)
@@ -78,10 +78,15 @@ Brief summary of control files.
  memory.kmem.failcnt             # show the number of kernel memory usage hits limits
  memory.kmem.max_usage_in_bytes  # show max kernel memory usage recorded
 
- memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
- memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
- memory.kmem.tcp.failcnt            # show the number of tcp buf memory usage hits limits
- memory.kmem.tcp.max_usage_in_bytes # show max tcp buf memory usage recorded
+[D] memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
+[D] memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
+[D] memory.kmem.tcp.failcnt            # show the number of tcp buf memory usage hits limits
+[D] memory.kmem.tcp.max_usage_in_bytes # show max tcp buf memory usage recorded
+
+Knobs marked as [D] are considered deprecated and they won't be available in
+the new cgroup Unified hierarchy API (see
+Documentation/cgroups/unified-hierarchy.txt for more information). They are
+still available with the legacy hierarchy though.
 
 1. History
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fa99a3e2e427..9ed40a045d27 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5226,7 +5226,11 @@ out_kfree:
 	return ret;
 }
 
-static struct cftype mem_cgroup_files[] = {
+/*
+ * memcg knobs for the legacy cgroup API. No new files should be
+ * added here.
+ */
+static struct cftype legacy_mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
@@ -5334,6 +5338,100 @@ static struct cftype mem_cgroup_files[] = {
 	{ },	/* terminate */
 };
 
+/* memcg knobs for new cgroups API (default aka unified hierarchy) */
+static struct cftype dfl_mem_cgroup_files[] = {
+	{
+		.name = "usage_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "max_usage_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
+		.write = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
+		.write = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "failcnt",
+		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
+		.write = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "stat",
+		.seq_show = memcg_stat_show,
+	},
+	{
+		.name = "cgroup.event_control",		/* XXX: for compat */
+		.write = memcg_write_event_control,
+		.flags = CFTYPE_NO_PREFIX,
+		.mode = S_IWUGO,
+	},
+	{
+		.name = "swappiness",
+		.read_u64 = mem_cgroup_swappiness_read,
+		.write_u64 = mem_cgroup_swappiness_write,
+	},
+	{
+		.name = "move_charge_at_immigrate",
+		.read_u64 = mem_cgroup_move_charge_read,
+		.write_u64 = mem_cgroup_move_charge_write,
+	},
+	{
+		.name = "oom_control",
+		.seq_show = mem_cgroup_oom_control_read,
+		.write_u64 = mem_cgroup_oom_control_write,
+		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
+	},
+	{
+		.name = "pressure_level",
+	},
+#ifdef CONFIG_NUMA
+	{
+		.name = "numa_stat",
+		.seq_show = memcg_numa_stat_show,
+	},
+#endif
+#ifdef CONFIG_MEMCG_KMEM
+	{
+		.name = "kmem.limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
+		.write = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "kmem.max_usage_in_bytes",
+		.private = MEMFILE_PRIVATE(_KMEM, RES_MAX_USAGE),
+		.write = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "kmem.usage_in_bytes",
+		.private = MEMFILE_PRIVATE(_KMEM, RES_USAGE),
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "kmem.failcnt",
+		.private = MEMFILE_PRIVATE(_KMEM, RES_FAILCNT),
+		.write = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+#ifdef CONFIG_SLABINFO
+	{
+		.name = "kmem.slabinfo",
+		.seq_show = mem_cgroup_slabinfo_read,
+	},
+#endif
+#endif
+	{ },	/* terminate */
+};
+
 #ifdef CONFIG_MEMCG_SWAP
 static struct cftype memsw_cgroup_files[] = {
 	{
@@ -6266,7 +6364,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.bind = mem_cgroup_bind,
-	.legacy_cftypes = mem_cgroup_files,
+	.legacy_cftypes = legacy_mem_cgroup_files,
+	.dfl_cftypes = dfl_mem_cgroup_files,
 	.early_init = 0,
 };
 
@@ -6285,6 +6384,8 @@ static void __init memsw_file_init(void)
 {
 	WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
 					  memsw_cgroup_files));
+	WARN_ON(cgroup_add_dfl_cftypes(&memory_cgrp_subsys,
+					  memsw_cgroup_files));
 }
 
 static void __init enable_swap_cgroup(void)
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
