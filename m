Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 545AD8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 12:16:21 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so4282874pgc.22
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 09:16:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f15sor8962239pgh.59.2018.12.14.09.16.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 09:16:20 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH 3/6] psi: eliminate lazy clock mode
Date: Fri, 14 Dec 2018 09:15:05 -0800
Message-Id: <20181214171508.7791-4-surenb@google.com>
In-Reply-To: <20181214171508.7791-1-surenb@google.com>
References: <20181214171508.7791-1-surenb@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com, Suren Baghdasaryan <surenb@google.com>

From: Johannes Weiner <hannes@cmpxchg.org>

psi currently stops its periodic 2s aggregation runs when there has
not been any task activity, and wakes it back up later from the
scheduler when the system returns from the idle state.

The coordination between the aggregation worker and the scheduler is
minimal: the scheduler has to nudge the worker if it's not running,
and the worker will reschedule itself periodically until it detects no
more activity.

The polling patches will complicate this, because they introduce
another aggregation mode for high-frequency polling that also
eventually times out if the worker sees no more activity of interest.
That means the scheduler portion would have to coordinate three state
transitions - idle to regular, regular to polling, idle to polling -
with the worker's timeouts and self-rescheduling. The additional
overhead from this is undesirable in the scheduler hotpath.

Eliminate the idle mode and keep the worker doing 2s update intervals
at all times. This eliminates worker coordination from the scheduler
completely. The polling patches will then add it back to switch
between regular mode and high-frequency polling mode.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 kernel/sched/psi.c | 55 +++++++++++++++++++---------------------------
 1 file changed, 22 insertions(+), 33 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index fe24de3fbc93..d2b9c9a1a62f 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -248,18 +248,10 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 	}
 }
 
-static void calc_avgs(unsigned long avg[3], int missed_periods,
-		      u64 time, u64 period)
+static void calc_avgs(unsigned long avg[3], u64 time, u64 period)
 {
 	unsigned long pct;
 
-	/* Fill in zeroes for periods of no activity */
-	if (missed_periods) {
-		avg[0] = calc_load_n(avg[0], EXP_10s, 0, missed_periods);
-		avg[1] = calc_load_n(avg[1], EXP_60s, 0, missed_periods);
-		avg[2] = calc_load_n(avg[2], EXP_300s, 0, missed_periods);
-	}
-
 	/* Sample the most recent active period */
 	pct = div_u64(time * 100, period);
 	pct *= FIXED_1;
@@ -268,10 +260,9 @@ static void calc_avgs(unsigned long avg[3], int missed_periods,
 	avg[2] = calc_load(avg[2], EXP_300s, pct);
 }
 
-static bool update_stats(struct psi_group *group)
+static void update_stats(struct psi_group *group)
 {
 	u64 deltas[NR_PSI_STATES - 1] = { 0, };
-	unsigned long missed_periods = 0;
 	unsigned long nonidle_total = 0;
 	u64 now, expires, period;
 	int cpu;
@@ -321,8 +312,6 @@ static bool update_stats(struct psi_group *group)
 	expires = group->next_update;
 	if (now < expires)
 		goto out;
-	if (now - expires > psi_period)
-		missed_periods = div_u64(now - expires, psi_period);
 
 	/*
 	 * The periodic clock tick can get delayed for various
@@ -331,8 +320,8 @@ static bool update_stats(struct psi_group *group)
 	 * But the deltas we sample out of the per-cpu buckets above
 	 * are based on the actual time elapsing between clock ticks.
 	 */
-	group->next_update = expires + ((1 + missed_periods) * psi_period);
-	period = now - (group->last_update + (missed_periods * psi_period));
+	group->next_update = expires + psi_period;
+	period = now - group->last_update;
 	group->last_update = now;
 
 	for (s = 0; s < NR_PSI_STATES - 1; s++) {
@@ -359,18 +348,18 @@ static bool update_stats(struct psi_group *group)
 		if (sample > period)
 			sample = period;
 		group->total_prev[s] += sample;
-		calc_avgs(group->avg[s], missed_periods, sample, period);
+		calc_avgs(group->avg[s], sample, period);
 	}
 out:
 	mutex_unlock(&group->stat_lock);
-	return nonidle_total;
 }
 
 static void psi_update_work(struct work_struct *work)
 {
 	struct delayed_work *dwork;
 	struct psi_group *group;
-	bool nonidle;
+	unsigned long delay = 0;
+	u64 now;
 
 	dwork = to_delayed_work(work);
 	group = container_of(dwork, struct psi_group, clock_work);
@@ -383,17 +372,12 @@ static void psi_update_work(struct work_struct *work)
 	 * go - see calc_avgs() and missed_periods.
 	 */
 
-	nonidle = update_stats(group);
-
-	if (nonidle) {
-		unsigned long delay = 0;
-		u64 now;
+	update_stats(group);
 
-		now = sched_clock();
-		if (group->next_update > now)
-			delay = nsecs_to_jiffies(group->next_update - now) + 1;
-		schedule_delayed_work(dwork, delay);
-	}
+	now = sched_clock();
+	if (group->next_update > now)
+		delay = nsecs_to_jiffies(group->next_update - now) + 1;
+	schedule_delayed_work(dwork, delay);
 }
 
 static void record_times(struct psi_group_cpu *groupc, int cpu,
@@ -480,9 +464,6 @@ static void psi_group_change(struct psi_group *group, int cpu,
 			groupc->tasks[t]++;
 
 	write_seqcount_end(&groupc->seq);
-
-	if (!delayed_work_pending(&group->clock_work))
-		schedule_delayed_work(&group->clock_work, PSI_FREQ);
 }
 
 static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
@@ -619,6 +600,8 @@ int psi_cgroup_alloc(struct cgroup *cgroup)
 	if (!cgroup->psi.pcpu)
 		return -ENOMEM;
 	group_init(&cgroup->psi);
+	schedule_delayed_work(&cgroup->psi.clock_work, PSI_FREQ);
+
 	return 0;
 }
 
@@ -761,12 +744,18 @@ static const struct file_operations psi_cpu_fops = {
 	.release        = single_release,
 };
 
-static int __init psi_proc_init(void)
+static int __init psi_late_init(void)
 {
+	if (static_branch_likely(&psi_disabled))
+		return 0;
+
+	schedule_delayed_work(&psi_system.clock_work, PSI_FREQ);
+
 	proc_mkdir("pressure", NULL);
 	proc_create("pressure/io", 0, NULL, &psi_io_fops);
 	proc_create("pressure/memory", 0, NULL, &psi_memory_fops);
 	proc_create("pressure/cpu", 0, NULL, &psi_cpu_fops);
+
 	return 0;
 }
-module_init(psi_proc_init);
+module_init(psi_late_init);
-- 
2.20.0.405.gbc1bbc6f85-goog
