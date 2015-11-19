Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6267B6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 07:31:08 -0500 (EST)
Received: by wmdw130 with SMTP id w130so238280733wmd.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:31:08 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id wo7si10976469wjb.160.2015.11.19.04.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 04:31:07 -0800 (PST)
Received: by wmvv187 with SMTP id v187so23132595wmv.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:31:07 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, vmstat: Allow WQ concurrency to discover memory reclaim doesn't make any progress
Date: Thu, 19 Nov 2015 13:30:53 +0100
Message-Id: <1447936253-18134-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, Cristopher Lameter <clameter@sgi.com>, =?UTF-8?q?Arkadiusz=20Mi=C5=9Bkiewicz?= <arekm@maven.pl>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo Handa has reported that the system might basically livelock in OOM
condition without triggering the OOM killer. The issue is caused by
internal dependency of the direct reclaim on vmstat counter updates (via
zone_reclaimable) which are performed from the workqueue context.
If all the current workers get assigned to an allocation request,
though, they will be looping inside the allocator trying to reclaim
memory but zone_reclaimable can see stalled numbers so it will consider
a zone reclaimable even though it has been scanned way too much. WQ
concurrency logic will not consider this situation as a congested workqueue
because it relies that worker would have to sleep in such a situation.
This also means that it doesn't try to spawn new workers or invoke
the rescuer thread if the one is assigned to the queue.

In order to fix this issue we need to do two things. First we have to
let wq concurrency code know that we are in trouble so we have to do
a short sleep. In order to prevent from issues handled by 0e093d99763e
("writeback: do not sleep on the congestion queue if there are no
congested BDIs or if significant congestion is not being encountered in
the current zone") we limit the sleep only to worker threads which are
the ones of the interest anyway.

The second thing to do is to create a dedicated workqueue for vmstat and
mark it WQ_MEM_RECLAIM to note it participates in the reclaim and to
have a spare worker thread for it.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable # 2.6.36+
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
[I am convinced that I have posted this as a separate patch but I cannot
find it in the archive nor in my inbox, so let me try again.]

Hi Andrew,

The original issue reported by Tetsuo [1] has seen multiple attempts for
a fix. The easiest one being [2] which was targeted to the particular
problem. There was a more general concern that looping inside the
allocator without ever sleeping breaks the basic assumption of worker
concurrency logic so the fix should be more general. Another attempt [3]
therefore added a short (1 jiffy) sleep into the page allocator. This
would, however, introduce sleeping for all callers of the page allocator
which is not really needed. This patch tries to be a compromise and
introduce sleeping only where it matters - for kworkers.

Even though we haven't seen bug reports in the past I would suggest
backporting this to the stable trees. The issue is present since we have
stopped useing congestion_wait in the retry loop because WQ concurrency
is older as well as vmstat worqueue based refresh AFAICS.

[1] http://lkml.kernel.org/r/201510130025.EJF21331.FFOQJtVOMLFHSO%40I-love.SAKURA.ne.jp
[2] http://lkml.kernel.org/r/201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp
[3] http://lkml.kernel.org/r/201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp

 mm/backing-dev.c | 19 ++++++++++++++++---
 mm/vmstat.c      |  6 ++++--
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8ed2ffd963c5..7340353f8aea 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -957,8 +957,9 @@ EXPORT_SYMBOL(congestion_wait);
  * jiffies for either a BDI to exit congestion of the given @sync queue
  * or a write to complete.
  *
- * In the absence of zone congestion, cond_resched() is called to yield
- * the processor if necessary but otherwise does not sleep.
+ * In the absence of zone congestion, a short sleep or a cond_resched is
+ * performed to yield the processor and to allow other subsystems to make
+ * a forward progress.
  *
  * The return value is 0 if the sleep is for the full timeout. Otherwise,
  * it is the number of jiffies that were still remaining when the function
@@ -978,7 +979,19 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 	 */
 	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
 	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
-		cond_resched();
+
+		/*
+		 * Memory allocation/reclaim might be called from a WQ
+		 * context and the current implementation of the WQ
+		 * concurrency control doesn't recognize that a particular
+		 * WQ is congested if the worker thread is looping without
+		 * ever sleeping. Therefore we have to do a short sleep
+		 * here rather than calling cond_resched().
+		 */
+		if (current->flags & PF_WQ_WORKER)
+			schedule_timeout(1);
+		else
+			cond_resched();
 
 		/* In case we scheduled, work out time remaining */
 		ret = timeout - (jiffies - start);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 45dcbcb5c594..0975da8e3432 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1381,6 +1381,7 @@ static const struct file_operations proc_vmstat_file_operations = {
 #endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_SMP
+static struct workqueue_struct *vmstat_wq;
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
 static cpumask_var_t cpu_stat_off;
@@ -1393,7 +1394,7 @@ static void vmstat_update(struct work_struct *w)
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
-		schedule_delayed_work_on(smp_processor_id(),
+		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
 			this_cpu_ptr(&vmstat_work),
 			round_jiffies_relative(sysctl_stat_interval));
 	} else {
@@ -1462,7 +1463,7 @@ static void vmstat_shepherd(struct work_struct *w)
 		if (need_update(cpu) &&
 			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
 
-			schedule_delayed_work_on(cpu,
+			queue_delayed_work_on(cpu, vmstat_wq,
 				&per_cpu(vmstat_work, cpu), 0);
 
 	put_online_cpus();
@@ -1551,6 +1552,7 @@ static int __init setup_vmstat(void)
 
 	start_shepherd_timer();
 	cpu_notifier_register_done();
+	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
