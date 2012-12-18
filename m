Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 80E1F6B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 10:40:37 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id ro2so523973pbb.39
        for <linux-mm@kvack.org>; Tue, 18 Dec 2012 07:40:36 -0800 (PST)
Date: Tue, 18 Dec 2012 07:40:30 -0800
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] memcg: don't register hotcpu notifier from ->css_alloc()
Message-ID: <20121218154030.GC10220@mtj.dyndns.org>
References: <20121214012436.GA25481@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121214012436.GA25481@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

648bb56d07 ("cgroup: lock cgroup_mutex in cgroup_init_subsys()") made
cgroup_init_subsys() grab cgroup_mutex before invoking ->css_alloc()
for the root css.  Because memcg registers hotcpu notifier from
->css_alloc() for the root css, this introduced circular locking
dependency between cgroup_mutex and cpu hotplug.

Fix it by moving hotcpu notifier registration to a subsys initcall.

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
   #2:  (x86_cpu_hotplug_driver_mutex){+.+...}, at: [<ffffffff81079277>] cpu_hotplug_driver_lock+0x1
+7/0x20
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
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>
---
Michal, if it looks okay, can you please route this patch?

Thanks.

 mm/memcontrol.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 12307b3..7d8a27f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4982,7 +4982,6 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 						&per_cpu(memcg_stock, cpu);
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
-		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		memcg->use_hierarchy = parent->use_hierarchy;
@@ -5644,6 +5643,19 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.use_id = 1,
 };
 
+/*
+ * The rest of init is performed during ->css_alloc() for root css which
+ * happens before initcalls.  hotcpu_notifier() can't be done together as
+ * it would introduce circular locking by adding cgroup_lock -> cpu hotplug
+ * dependency.  Do it from a subsys_initcall().
+ */
+static int __init mem_cgroup_init(void)
+{
+	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+	return 0;
+}
+subsys_initcall(mem_cgroup_init);
+
 #ifdef CONFIG_MEMCG_SWAP
 static int __init enable_swap_account(char *s)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
