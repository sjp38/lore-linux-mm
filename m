Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD086B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:09:24 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id h7so28366003wjy.6
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:09:24 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id i21si431385wmc.94.2017.02.07.13.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 13:09:23 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id v77so30522053wmv.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:09:23 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm: move pcp and lru-pcp drainging into vmstat_wq
Date: Tue,  7 Feb 2017 22:09:08 +0100
Message-Id: <20170207210908.530-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

We currently have 2 specific WQ_RECLAIM workqueues. One for updating
pcp stats vmstat_wq and one dedicated to drain per cpu lru caches. This
seems more than necessary because both can run on a single WQ. Both
do not block on locks requiring a memory allocation nor perform any
allocations themselves. We will save one rescuer thread this way.

On the other hand drain_all_pages queues work on the system wq which
doesn't have rescuer and so this depend on memory allocation (when all
workers are stuck allocating and new ones cannot be created). This is
not critical as there should be somebody invoking the OOM killer (e.g.
the forking worker) and get the situation unstuck and eventually
performs the draining. Quite annoying though. This worker should be
using WQ_RECLAIM as well. We can reuse the same one as for lru draining
and vmstat.

Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
Tetsuo has noted that drain_all_pages doesn't use WQ_RECLAIM [1]
and asked whether we can move the worker to the vmstat_wq which is
WQ_RECLAIM. I think the deadlock he has described shouldn't happen but
it would be really better to have the rescuer. I also think that we do
not really need 2 or more workqueues and also pull lru draining in.

What do you think? Please note I haven't tested it yet.

[1] http://lkml.kernel.org/r/201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp

 mm/internal.h   |  6 ++++++
 mm/page_alloc.c |  2 +-
 mm/swap.c       | 20 +-------------------
 mm/vmstat.c     | 11 ++++++-----
 4 files changed, 14 insertions(+), 25 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index ccfc2a2969f4..9ecafefe33ba 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -498,4 +498,10 @@ extern const struct trace_print_flags pageflag_names[];
 extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
+/*
+ * only for MM internal work items which do not depend on
+ * any allocations or locks which might depend on allocations
+ */
+extern struct workqueue_struct *vmstat_wq;
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6c48053bcd81..0c0a7c38cd91 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2419,7 +2419,7 @@ void drain_all_pages(struct zone *zone)
 	for_each_cpu(cpu, &cpus_with_pcps) {
 		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
 		INIT_WORK(work, drain_local_pages_wq);
-		schedule_work_on(cpu, work);
+		queue_work_on(cpu, vmstat_wq, work);
 	}
 	for_each_cpu(cpu, &cpus_with_pcps)
 		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
diff --git a/mm/swap.c b/mm/swap.c
index c4910f14f957..23f09d6dd212 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -670,24 +670,6 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
-/*
- * lru_add_drain_wq is used to do lru_add_drain_all() from a WQ_MEM_RECLAIM
- * workqueue, aiding in getting memory freed.
- */
-static struct workqueue_struct *lru_add_drain_wq;
-
-static int __init lru_init(void)
-{
-	lru_add_drain_wq = alloc_workqueue("lru-add-drain", WQ_MEM_RECLAIM, 0);
-
-	if (WARN(!lru_add_drain_wq,
-		"Failed to create workqueue lru_add_drain_wq"))
-		return -ENOMEM;
-
-	return 0;
-}
-early_initcall(lru_init);
-
 void lru_add_drain_all(void)
 {
 	static DEFINE_MUTEX(lock);
@@ -707,7 +689,7 @@ void lru_add_drain_all(void)
 		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
-			queue_work_on(cpu, lru_add_drain_wq, work);
+			queue_work_on(cpu, vmstat_wq, work);
 			cpumask_set_cpu(cpu, &has_work);
 		}
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 69f9aff39a2e..fc9c2d9f014b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1548,8 +1548,8 @@ static const struct file_operations proc_vmstat_file_operations = {
 };
 #endif /* CONFIG_PROC_FS */
 
+struct workqueue_struct *vmstat_wq;
 #ifdef CONFIG_SMP
-static struct workqueue_struct *vmstat_wq;
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
 
@@ -1715,7 +1715,6 @@ static void __init start_shepherd_timer(void)
 		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
 			vmstat_update);
 
-	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 	schedule_delayed_work(&shepherd,
 		round_jiffies_relative(sysctl_stat_interval));
 }
@@ -1763,9 +1762,11 @@ static int vmstat_cpu_dead(unsigned int cpu)
 
 static int __init setup_vmstat(void)
 {
-#ifdef CONFIG_SMP
-	int ret;
+	int ret = 0;
+
+	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 
+#ifdef CONFIG_SMP
 	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
 					NULL, vmstat_cpu_dead);
 	if (ret < 0)
@@ -1789,7 +1790,7 @@ static int __init setup_vmstat(void)
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
 #endif
-	return 0;
+	return ret;
 }
 module_init(setup_vmstat)
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
