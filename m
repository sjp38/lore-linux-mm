Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3F5536B007D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:34:51 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so10587559pbc.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 13:34:50 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 09/13] cpuset: don't nest cgroup_mutex inside get_online_cpus()
Date: Wed, 28 Nov 2012 13:34:16 -0800
Message-Id: <1354138460-19286-10-git-send-email-tj@kernel.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj@kernel.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

CPU / memory hotplug path currently grabs cgroup_mutex from hotplug
event notifications.  As other places nest the other way around, we
end up with lockdep warning attached below.

We want to keep cgroup_mutex outer to most locks including hotplug
ones.  Break the circular dependency by handling hotplug from a work
item.  Convert cpuset_handle_hotplug() to cpuset_hotplug_workfn() and
schedule it from the hotplug notifications.  As the function can
already handle multiple mixed events without any input, converting it
to a work function is trivial.

This decouples cpuset hotplug handling from the notification callbacks
and there can be an arbitrary delay between the actual event and
updates to cpuset.  Scheduler and mm can handle it fine but moving
tasks out of an empty cpuset may race against writes to the cpuset
restoring execution resources which can lead to confusing behavior.
Flush hotplug work item from cpuset_write_resmask() to avoid such
confusions.

  ======================================================
  [ INFO: possible circular locking dependency detected ]
  3.7.0-rc4-work+ #42 Not tainted
  -------------------------------------------------------
  bash/645 is trying to acquire lock:
   (cgroup_mutex){+.+.+.}, at: [<ffffffff8110c5b7>] cgroup_lock+0x17/0x20

  but task is already holding lock:
   (cpu_hotplug.lock){+.+.+.}, at: [<ffffffff8109300f>] cpu_hotplug_begin+0x2f/0x60

  which lock already depends on the new lock.


  the existing dependency chain (in reverse order) is:

 -> #1 (cpu_hotplug.lock){+.+.+.}:
	 [<ffffffff810f8357>] lock_acquire+0x97/0x1e0
	 [<ffffffff81be4701>] mutex_lock_nested+0x61/0x3b0
	 [<ffffffff810930fc>] get_online_cpus+0x3c/0x60
	 [<ffffffff811152fb>] rebuild_sched_domains_locked+0x1b/0x70
	 [<ffffffff81116718>] cpuset_write_resmask+0x298/0x2c0
	 [<ffffffff8110f70f>] cgroup_file_write+0x1ef/0x300
	 [<ffffffff811c3b78>] vfs_write+0xa8/0x160
	 [<ffffffff811c3e82>] sys_write+0x52/0xa0
	 [<ffffffff81be89c2>] system_call_fastpath+0x16/0x1b

 -> #0 (cgroup_mutex){+.+.+.}:
	 [<ffffffff810f74de>] __lock_acquire+0x14ce/0x1d20
	 [<ffffffff810f8357>] lock_acquire+0x97/0x1e0
	 [<ffffffff81be4701>] mutex_lock_nested+0x61/0x3b0
	 [<ffffffff8110c5b7>] cgroup_lock+0x17/0x20
	 [<ffffffff81116deb>] cpuset_handle_hotplug+0x1b/0x560
	 [<ffffffff8111744e>] cpuset_update_active_cpus+0xe/0x10
	 [<ffffffff810d0587>] cpuset_cpu_inactive+0x47/0x50
	 [<ffffffff810c1476>] notifier_call_chain+0x66/0x150
	 [<ffffffff810c156e>] __raw_notifier_call_chain+0xe/0x10
	 [<ffffffff81092fa0>] __cpu_notify+0x20/0x40
	 [<ffffffff81b9827e>] _cpu_down+0x7e/0x2f0
	 [<ffffffff81b98526>] cpu_down+0x36/0x50
	 [<ffffffff81b9c12d>] store_online+0x5d/0xe0
	 [<ffffffff816b6ef8>] dev_attr_store+0x18/0x30
	 [<ffffffff8123bb50>] sysfs_write_file+0xe0/0x150
	 [<ffffffff811c3b78>] vfs_write+0xa8/0x160
	 [<ffffffff811c3e82>] sys_write+0x52/0xa0
	 [<ffffffff81be89c2>] system_call_fastpath+0x16/0x1b

  other info that might help us debug this:

   Possible unsafe locking scenario:

	 CPU0                    CPU1
	 ----                    ----
    lock(cpu_hotplug.lock);
				 lock(cgroup_mutex);
				 lock(cpu_hotplug.lock);
    lock(cgroup_mutex);

   *** DEADLOCK ***

  5 locks held by bash/645:
   #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff8123bab8>] sysfs_write_file+0x48/0x150
   #1:  (s_active#42){.+.+.+}, at: [<ffffffff8123bb38>] sysfs_write_file+0xc8/0x150
   #2:  (x86_cpu_hotplug_driver_mutex){+.+...}, at: [<ffffffff81079277>] cpu_hotplug_driver_lock+0x17/0x20
   #3:  (cpu_add_remove_lock){+.+.+.}, at: [<ffffffff81093157>] cpu_maps_update_begin+0x17/0x20
   #4:  (cpu_hotplug.lock){+.+.+.}, at: [<ffffffff8109300f>] cpu_hotplug_begin+0x2f/0x60

  stack backtrace:
  Pid: 645, comm: bash Not tainted 3.7.0-rc4-work+ #42
  Call Trace:
   [<ffffffff81bdadfd>] print_circular_bug+0x28e/0x29f
   [<ffffffff810f74de>] __lock_acquire+0x14ce/0x1d20
   [<ffffffff810f8357>] lock_acquire+0x97/0x1e0
   [<ffffffff81be4701>] mutex_lock_nested+0x61/0x3b0
   [<ffffffff8110c5b7>] cgroup_lock+0x17/0x20
   [<ffffffff81116deb>] cpuset_handle_hotplug+0x1b/0x560
   [<ffffffff8111744e>] cpuset_update_active_cpus+0xe/0x10
   [<ffffffff810d0587>] cpuset_cpu_inactive+0x47/0x50
   [<ffffffff810c1476>] notifier_call_chain+0x66/0x150
   [<ffffffff810c156e>] __raw_notifier_call_chain+0xe/0x10
   [<ffffffff81092fa0>] __cpu_notify+0x20/0x40
   [<ffffffff81b9827e>] _cpu_down+0x7e/0x2f0
   [<ffffffff81b98526>] cpu_down+0x36/0x50
   [<ffffffff81b9c12d>] store_online+0x5d/0xe0
   [<ffffffff816b6ef8>] dev_attr_store+0x18/0x30
   [<ffffffff8123bb50>] sysfs_write_file+0xe0/0x150
   [<ffffffff811c3b78>] vfs_write+0xa8/0x160
   [<ffffffff811c3e82>] sys_write+0x52/0xa0
   [<ffffffff81be89c2>] system_call_fastpath+0x16/0x1b

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4ab3e4c..b530fba 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -252,6 +252,13 @@ static char cpuset_nodelist[CPUSET_NODELIST_LEN];
 static DEFINE_SPINLOCK(cpuset_buffer_lock);
 
 /*
+ * CPU / memory hotplug is handled asynchronously.
+ */
+static void cpuset_hotplug_workfn(struct work_struct *work);
+
+static DECLARE_WORK(cpuset_hotplug_work, cpuset_hotplug_workfn);
+
+/*
  * This is ugly, but preserves the userspace API for existing cpuset
  * users. If someone tries to mount the "cpuset" filesystem, we
  * silently switch it to mount "cgroup" instead
@@ -1518,6 +1525,19 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct cpuset *trialcs;
 
+	/*
+	 * CPU or memory hotunplug may leave @cs w/o any execution
+	 * resources, in which case the hotplug code asynchronously updates
+	 * configuration and transfers all tasks to the nearest ancestor
+	 * which can execute.
+	 *
+	 * As writes to "cpus" or "mems" may restore @cs's execution
+	 * resources, wait for the previously scheduled operations before
+	 * proceeding, so that we don't end up keep removing tasks added
+	 * after execution capability is restored.
+	 */
+	flush_work(&cpuset_hotplug_work);
+
 	if (!cgroup_lock_live_group(cgrp))
 		return -ENODEV;
 
@@ -2045,7 +2065,7 @@ static void cpuset_propagate_hotplug(struct cpuset *cs)
 }
 
 /**
- * cpuset_handle_hotplug - handle CPU/memory hot[un]plug
+ * cpuset_hotplug_workfn - handle CPU/memory hotunplug for a cpuset
  *
  * This function is called after either CPU or memory configuration has
  * changed and updates cpuset accordingly.  The top_cpuset is always
@@ -2060,7 +2080,7 @@ static void cpuset_propagate_hotplug(struct cpuset *cs)
  * Note that CPU offlining during suspend is ignored.  We don't modify
  * cpusets across suspend/resume cycles at all.
  */
-static void cpuset_handle_hotplug(void)
+static void cpuset_hotplug_workfn(struct work_struct *work)
 {
 	static cpumask_t new_cpus, tmp_cpus;
 	static nodemask_t new_mems, tmp_mems;
@@ -2127,7 +2147,7 @@ static void cpuset_handle_hotplug(void)
 
 void cpuset_update_active_cpus(bool cpu_online)
 {
-	cpuset_handle_hotplug();
+	schedule_work(&cpuset_hotplug_work);
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
@@ -2139,7 +2159,7 @@ void cpuset_update_active_cpus(bool cpu_online)
 static int cpuset_track_online_nodes(struct notifier_block *self,
 				     unsigned long action, void *arg)
 {
-	cpuset_handle_hotplug();
+	schedule_work(&cpuset_hotplug_work);
 	return NOTIFY_OK;
 }
 #endif
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
