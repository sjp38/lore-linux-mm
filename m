Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 413836B0080
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:34:46 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so6262945pad.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 13:34:45 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 07/13] cpuset: drop async_rebuild_sched_domains()
Date: Wed, 28 Nov 2012 13:34:14 -0800
Message-Id: <1354138460-19286-8-git-send-email-tj@kernel.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj@kernel.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

get_online_cpus() is already nested inside cgroup_mutex from memcg
when it's registering cpu notifiers.  Also, in generall, we want to
make cgroup_mutex one of the outermost locks and be able to use
get_online_cpus() and friends from cgroup methods.

Currently, cpuset avoids nesting get_online_cpus() inside cgroup_mutex
by bouncing sched_domain rebuilding to a work item.  As such nesting
is gonna be allowed, remove the workqueue bouncing code and always
rebuild sched_domains synchronously.  This also nests
sched_domains_mutex inside cgroup_mutex, which should be okay.

Note that the CPU / memory hotplug path still grabs the two locks in
the reverse order and thus this is a deadlock hazard; however, the two
locks are already deadlock-prone and the hotplug path will be updated
by further patches.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 76 ++++++++++++---------------------------------------------
 1 file changed, 16 insertions(+), 60 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 8bdd983..2049504 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -61,14 +61,6 @@
 #include <linux/cgroup.h>
 
 /*
- * Workqueue for cpuset related tasks.
- *
- * Using kevent workqueue may cause deadlock when memory_migrate
- * is set. So we create a separate workqueue thread for cpuset.
- */
-static struct workqueue_struct *cpuset_wq;
-
-/*
  * Tracks how many cpusets are currently defined in system.
  * When there is only one cpuset (the root cpuset) we can
  * short circuit some hooks.
@@ -752,25 +744,25 @@ done:
 /*
  * Rebuild scheduler domains.
  *
- * Call with neither cgroup_mutex held nor within get_online_cpus().
- * Takes both cgroup_mutex and get_online_cpus().
+ * If the flag 'sched_load_balance' of any cpuset with non-empty
+ * 'cpus' changes, or if the 'cpus' allowed changes in any cpuset
+ * which has that flag enabled, or if any cpuset with a non-empty
+ * 'cpus' is removed, then call this routine to rebuild the
+ * scheduler's dynamic sched domains.
  *
- * Cannot be directly called from cpuset code handling changes
- * to the cpuset pseudo-filesystem, because it cannot be called
- * from code that already holds cgroup_mutex.
+ * Call with cgroup_mutex held.  Takes get_online_cpus().
  */
-static void do_rebuild_sched_domains(struct work_struct *unused)
+static void rebuild_sched_domains_locked(void)
 {
 	struct sched_domain_attr *attr;
 	cpumask_var_t *doms;
 	int ndoms;
 
+	WARN_ON_ONCE(!cgroup_lock_is_held());
 	get_online_cpus();
 
 	/* Generate domain masks and attrs */
-	cgroup_lock();
 	ndoms = generate_sched_domains(&doms, &attr);
-	cgroup_unlock();
 
 	/* Have scheduler rebuild the domains */
 	partition_sched_domains(ndoms, doms, attr);
@@ -778,7 +770,7 @@ static void do_rebuild_sched_domains(struct work_struct *unused)
 	put_online_cpus();
 }
 #else /* !CONFIG_SMP */
-static void do_rebuild_sched_domains(struct work_struct *unused)
+static void rebuild_sched_domains_locked(void)
 {
 }
 
@@ -790,44 +782,11 @@ static int generate_sched_domains(cpumask_var_t **domains,
 }
 #endif /* CONFIG_SMP */
 
-static DECLARE_WORK(rebuild_sched_domains_work, do_rebuild_sched_domains);
-
-/*
- * Rebuild scheduler domains, asynchronously via workqueue.
- *
- * If the flag 'sched_load_balance' of any cpuset with non-empty
- * 'cpus' changes, or if the 'cpus' allowed changes in any cpuset
- * which has that flag enabled, or if any cpuset with a non-empty
- * 'cpus' is removed, then call this routine to rebuild the
- * scheduler's dynamic sched domains.
- *
- * The rebuild_sched_domains() and partition_sched_domains()
- * routines must nest cgroup_lock() inside get_online_cpus(),
- * but such cpuset changes as these must nest that locking the
- * other way, holding cgroup_lock() for much of the code.
- *
- * So in order to avoid an ABBA deadlock, the cpuset code handling
- * these user changes delegates the actual sched domain rebuilding
- * to a separate workqueue thread, which ends up processing the
- * above do_rebuild_sched_domains() function.
- */
-static void async_rebuild_sched_domains(void)
-{
-	queue_work(cpuset_wq, &rebuild_sched_domains_work);
-}
-
-/*
- * Accomplishes the same scheduler domain rebuild as the above
- * async_rebuild_sched_domains(), however it directly calls the
- * rebuild routine synchronously rather than calling it via an
- * asynchronous work thread.
- *
- * This can only be called from code that is not holding
- * cgroup_mutex (not nested in a cgroup_lock() call.)
- */
 void rebuild_sched_domains(void)
 {
-	do_rebuild_sched_domains(NULL);
+	cgroup_lock();
+	rebuild_sched_domains_locked();
+	cgroup_unlock();
 }
 
 /**
@@ -947,7 +906,7 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 	heap_free(&heap);
 
 	if (is_load_balanced)
-		async_rebuild_sched_domains();
+		rebuild_sched_domains_locked();
 	return 0;
 }
 
@@ -1195,7 +1154,7 @@ static int update_relax_domain_level(struct cpuset *cs, s64 val)
 		cs->relax_domain_level = val;
 		if (!cpumask_empty(cs->cpus_allowed) &&
 		    is_sched_load_balance(cs))
-			async_rebuild_sched_domains();
+			rebuild_sched_domains_locked();
 	}
 
 	return 0;
@@ -1287,7 +1246,7 @@ static int update_flag(cpuset_flagbits_t bit, struct cpuset *cs,
 	mutex_unlock(&callback_mutex);
 
 	if (!cpumask_empty(trialcs->cpus_allowed) && balance_flag_changed)
-		async_rebuild_sched_domains();
+		rebuild_sched_domains_locked();
 
 	if (spread_flag_changed)
 		update_tasks_flags(cs, &heap);
@@ -1905,7 +1864,7 @@ static void cpuset_css_offline(struct cgroup *cgrp)
 /*
  * If the cpuset being removed has its flag 'sched_load_balance'
  * enabled, then simulate turning sched_load_balance off, which
- * will call async_rebuild_sched_domains().
+ * will call rebuild_sched_domains_locked().
  */
 
 static void cpuset_css_free(struct cgroup *cont)
@@ -2210,9 +2169,6 @@ void __init cpuset_init_smp(void)
 	top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
 
 	hotplug_memory_notifier(cpuset_track_online_nodes, 10);
-
-	cpuset_wq = create_singlethread_workqueue("cpuset");
-	BUG_ON(!cpuset_wq);
 }
 
 /**
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
