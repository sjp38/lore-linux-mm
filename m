Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 9C4346B0163
	for <linux-mm@kvack.org>; Wed, 29 May 2013 21:18:14 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id um15so10103963pbc.39
        for <linux-mm@kvack.org>; Wed, 29 May 2013 18:18:13 -0700 (PDT)
Date: Wed, 29 May 2013 18:18:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: add oom killer delay
Message-ID: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Completely disabling the oom killer for a memcg is problematic if
userspace is unable to address the condition itself, usually because it
is unresponsive.  This scenario creates a memcg deadlock: tasks are
sitting in TASK_KILLABLE waiting for the limit to be increased, a task to
exit or move, or the oom killer reenabled and userspace is unable to do
so.

An additional possible use case is to defer oom killing within a memcg
for a set period of time, probably to prevent unnecessary kills due to
temporary memory spikes, before allowing the kernel to handle the
condition.

This patch adds an oom killer delay so that a memcg may be configured to
wait at least a pre-defined number of milliseconds before calling the oom
killer.  If the oom condition persists for this number of milliseconds,
the oom killer will be called the next time the memory controller
attempts to charge a page (and memory.oom_control is set to 0).  This
allows userspace to have a short period of time to respond to the
condition before deferring to the kernel to kill a task.

Admins may set the oom killer delay using the new interface:

	# echo 60000 > memory.oom_delay_millisecs

This will defer oom killing to the kernel only after 60 seconds has
elapsed by putting the task to sleep for 60 seconds.

This expiration is cleared in four cases:

 - anytime the oom killer is called so another memory.oom_delay_millisecs
   delay is incurred the next time,

 - anytime memory is uncharged from a memcg so it is no longer oom so
   that there is now more available memory,

 - anytime memory.limit_in_bytes is raised so that there is now more
   available memory, and

 - anytime memory.oom_delay_millisecs is written from userspace to change
   the next delay.

Unless one of these events occurs after an oom delay has expired, all
future oom kills in that memcg will continue without incurring any delay.

When a memory.oom_delay_millisecs is set for a cgroup, it is propagated
to all children memcg as well and is inherited when a new memcg is
created.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroups/memory.txt | 27 ++++++++++++++++++
 mm/memcontrol.c                  | 59 ++++++++++++++++++++++++++++++++++++----
 2 files changed, 81 insertions(+), 5 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -71,6 +71,7 @@ Brief summary of control files.
 				 (See sysctl's vm.swappiness)
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
+ memory.oom_delay_millisecs	 # set/show millisecs to wait before oom kill
  memory.numa_stat		 # show the number of memory usage per numa node
 
  memory.kmem.limit_in_bytes      # set/show hard limit for kernel memory
@@ -766,6 +767,32 @@ At reading, current status of OOM is shown.
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
+It is possible to configure an oom killer delay to prevent the possibility that
+the memcg will deadlock looking for memory if userspace has disabled the oom
+killer with oom_control but cannot act to fix the condition itself (usually
+because it is unresponsive).
+
+To set an oom killer delay for a memcg, write the number of milliseconds to wait
+before killing a task to memory.oom_delay_millisecs:
+
+	# echo 60000 > memory.oom_delay_millisecs	# 60 seconds before kill
+
+When this memcg is oom, it is guaranteed that this delay will elapse before the
+kernel kills a process.  If memory is uncharged from this memcg or one of its
+limits is expanded during this period, the oom kill is inhibited.
+
+Disabling the oom killer for a memcg with memory.oom_control takes precedence
+over memory.oom_delay_millisecs, so it must be set to 0 (default) to allow the
+oom kill after the delay has expired.
+
+This value is inherited from the memcg's parent on creation.  Setting a delay
+for a memcg sets the same delay for all children.
+
+There is no delay if memory.oom_delay_millisecs is set to 0 (default).  This
+tunable's upper bound is MAX_SCHEDULE_TIMEOUT (about 24 days on 32-bit and a
+lifetime on 64-bit).
+
+
 11. Memory Pressure
 
 The pressure level notifications can be used to monitor the memory
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -308,6 +308,10 @@ struct mem_cgroup {
 	int	swappiness;
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
+	/* number of ticks to stall before calling oom killer */
+	int		oom_delay;
+	/* expiration of current delay in jiffies, if oom in progress */
+	atomic64_t	oom_delay_expire;
 
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
@@ -2185,8 +2189,11 @@ static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 
 static void memcg_oom_recover(struct mem_cgroup *memcg)
 {
-	if (memcg && atomic_read(&memcg->under_oom))
-		memcg_wakeup_oom(memcg);
+	if (memcg) {
+		atomic64_set(&memcg->oom_delay_expire, 0);
+		if (atomic_read(&memcg->under_oom))
+			memcg_wakeup_oom(memcg);
+	}
 }
 
 /*
@@ -2197,6 +2204,7 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 {
 	struct oom_wait_info owait;
 	bool locked, need_to_kill;
+	long timeout = MAX_SCHEDULE_TIMEOUT;
 
 	owait.memcg = memcg;
 	owait.wait.flags = 0;
@@ -2217,15 +2225,25 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
 	if (!locked || memcg->oom_kill_disable)
 		need_to_kill = false;
-	if (locked)
+	if (locked) {
+		if (memcg->oom_delay) {
+			unsigned long expire;
+
+			expire = atomic64_cmpxchg(&memcg->oom_delay_expire, 0,
+						  jiffies + memcg->oom_delay);
+			need_to_kill = expire && time_after_eq(jiffies, expire);
+			timeout = memcg->oom_delay;
+		}
 		mem_cgroup_oom_notify(memcg);
+	}
 	spin_unlock(&memcg_oom_lock);
 
 	if (need_to_kill) {
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, mask, order);
+		atomic64_set(&memcg->oom_delay_expire, 0);
 	} else {
-		schedule();
+		schedule_timeout(timeout);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
 	spin_lock(&memcg_oom_lock);
@@ -2239,7 +2257,8 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
 		return false;
 	/* Give chance to dying process */
-	schedule_timeout_uninterruptible(1);
+	if (timeout == MAX_SCHEDULE_TIMEOUT)
+		schedule_timeout_uninterruptible(1);
 	return true;
 }
 
@@ -5855,6 +5874,30 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	return 0;
 }
 
+static u64 mem_cgroup_oom_delay_millisecs_read(struct cgroup *cgrp,
+					       struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return jiffies_to_msecs(memcg->oom_delay);
+}
+
+static int mem_cgroup_oom_delay_millisecs_write(struct cgroup *cgrp,
+						struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *iter;
+
+	if (val > MAX_SCHEDULE_TIMEOUT)
+		return -EINVAL;
+
+	for_each_mem_cgroup_tree(iter, memcg) {
+		iter->oom_delay = msecs_to_jiffies(val);
+		memcg_oom_recover(iter);
+	}
+	return 0;
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
@@ -5962,6 +6005,11 @@ static struct cftype mem_cgroup_files[] = {
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
 	{
+		.name = "oom_delay_millisecs",
+		.read_u64 = mem_cgroup_oom_delay_millisecs_read,
+		.write_u64 = mem_cgroup_oom_delay_millisecs_write,
+	},
+	{
 		.name = "pressure_level",
 		.register_event = vmpressure_register_event,
 		.unregister_event = vmpressure_unregister_event,
@@ -6271,6 +6319,7 @@ mem_cgroup_css_online(struct cgroup *cont)
 
 	memcg->use_hierarchy = parent->use_hierarchy;
 	memcg->oom_kill_disable = parent->oom_kill_disable;
+	memcg->oom_delay = parent->oom_delay;
 	memcg->swappiness = mem_cgroup_swappiness(parent);
 
 	if (parent->use_hierarchy) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
