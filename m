Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 59E696B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 01:39:27 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so1522639pac.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 22:39:26 -0700 (PDT)
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com. [209.85.220.50])
        by mx.google.com with ESMTPS id bf5si6794480pbb.45.2015.03.25.22.39.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 22:39:26 -0700 (PDT)
Received: by pabxg6 with SMTP id xg6so52683514pab.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 22:39:26 -0700 (PDT)
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Date: Thu, 26 Mar 2015 11:09:01 +0530
Message-Id: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, cl@linux.com
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, vinmenon@codeaurora.org, shashim@codeaurora.org, mhocko@suse.cz, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, linux-mm@kvack.org, Viresh Kumar <viresh.kumar@linaro.org>

A delayed work to schedule vmstat_shepherd() is queued at periodic intervals for
internal working of vmstat core. This work and its timer end up waking an idle
cpu sometimes, as this always stays on CPU0.

Because we re-queue the work from its handler, idle_cpu() returns false and so
the timer (used by delayed work) never migrates to any other CPU.

This may not be the desired behavior always as waking up an idle CPU to queue
work on few other CPUs isn't good from power-consumption point of view.

In order to avoid waking up an idle core, we can replace schedule_delayed_work()
with a normal work plus a separate timer. The timer handler will then queue the
work after re-arming the timer. If the CPU was idle before the timer fired,
idle_cpu() will mostly return true and the next timer shall be migrated to a
non-idle CPU.

But the timer core has a limitation, when the timer is re-armed from its
handler, timer core disables migration of that timer to other cores. Details of
that limitation are present in kernel/time/timer.c:__mod_timer() routine.

Another simple yet effective solution can be to keep two timers with same
handler and keep toggling between them, so that the above limitation doesn't
hold true anymore.

This patch replaces schedule_delayed_work() with schedule_work() plus two
timers. After this, it was seen that the timer and its do get migrated to other
non-idle CPUs, when the local cpu is idle.

Tested-by: Vinayak Menon <vinmenon@codeaurora.org>
Tested-by: Shiraz Hashim <shashim@codeaurora.org>
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
This patch isn't sent to say its the best way forward, but to get a discussion
started on the same.

 mm/vmstat.c | 31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4f5cd974e11a..d45e4243a046 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1424,8 +1424,18 @@ static bool need_update(int cpu)
  * inactivity.
  */
 static void vmstat_shepherd(struct work_struct *w);
+static DECLARE_WORK(shepherd, vmstat_shepherd);
 
-static DECLARE_DELAYED_WORK(shepherd, vmstat_shepherd);
+/*
+ * Two timers are used here to avoid waking up an idle CPU. If a single timer is
+ * kept, then re-arming the timer from its handler doesn't let us migrate it.
+ */
+static struct timer_list shepherd_timer[2];
+#define toggle_timer() (shepherd_timer_index = !shepherd_timer_index,	\
+			&shepherd_timer[shepherd_timer_index])
+
+static void vmstat_shepherd_timer(unsigned long data);
+static int shepherd_timer_index;
 
 static void vmstat_shepherd(struct work_struct *w)
 {
@@ -1441,15 +1451,19 @@ static void vmstat_shepherd(struct work_struct *w)
 				&per_cpu(vmstat_work, cpu), 0);
 
 	put_online_cpus();
+}
 
-	schedule_delayed_work(&shepherd,
-		round_jiffies_relative(sysctl_stat_interval));
+static void vmstat_shepherd_timer(unsigned long data)
+{
+	mod_timer(toggle_timer(),
+		  jiffies + round_jiffies_relative(sysctl_stat_interval));
+	schedule_work(&shepherd);
 
 }
 
 static void __init start_shepherd_timer(void)
 {
-	int cpu;
+	int cpu, i = -1;
 
 	for_each_possible_cpu(cpu)
 		INIT_DELAYED_WORK(per_cpu_ptr(&vmstat_work, cpu),
@@ -1459,8 +1473,13 @@ static void __init start_shepherd_timer(void)
 		BUG();
 	cpumask_copy(cpu_stat_off, cpu_online_mask);
 
-	schedule_delayed_work(&shepherd,
-		round_jiffies_relative(sysctl_stat_interval));
+	while (++i < 2) {
+		init_timer(&shepherd_timer[i]);
+		shepherd_timer[i].function = vmstat_shepherd_timer;
+	};
+
+	mod_timer(toggle_timer(),
+		  jiffies + round_jiffies_relative(sysctl_stat_interval));
 }
 
 static void vmstat_cpu_dead(int node)
-- 
2.3.0.rc0.44.ga94655d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
