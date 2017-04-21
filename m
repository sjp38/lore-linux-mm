Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9524C6B03A7
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:13 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x128so5407094qkb.14
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a48si9632959qte.93.2017.04.21.07.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:12 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 11/14] sched: Misc preps for cgroup unified hierarchy interface
Date: Fri, 21 Apr 2017 10:04:09 -0400
Message-Id: <1492783452-12267-12-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

From: Tejun Heo <tj@kernel.org>

Make the following changes in preparation for the cpu controller
interface implementation for the unified hierarchy.  This patch
doesn't cause any functional differences.

* s/cpu_stats_show()/cpu_cfs_stats_show()/

* s/cpu_files/cpu_legacy_files/

* Separate out cpuacct_stats_read() from cpuacct_stats_show().  While
  at it, make the @val array u64 for consistency.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/sched/core.c    |  8 ++++----
 kernel/sched/cpuacct.c | 29 ++++++++++++++++++-----------
 2 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 27b4dd5..5e3a217 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7209,7 +7209,7 @@ static int __cfs_schedulable(struct task_group *tg, u64 period, u64 quota)
 	return ret;
 }
 
-static int cpu_stats_show(struct seq_file *sf, void *v)
+static int cpu_cfs_stats_show(struct seq_file *sf, void *v)
 {
 	struct task_group *tg = css_tg(seq_css(sf));
 	struct cfs_bandwidth *cfs_b = &tg->cfs_bandwidth;
@@ -7249,7 +7249,7 @@ static u64 cpu_rt_period_read_uint(struct cgroup_subsys_state *css,
 }
 #endif /* CONFIG_RT_GROUP_SCHED */
 
-static struct cftype cpu_files[] = {
+static struct cftype cpu_legacy_files[] = {
 #ifdef CONFIG_FAIR_GROUP_SCHED
 	{
 		.name = "shares",
@@ -7270,7 +7270,7 @@ static u64 cpu_rt_period_read_uint(struct cgroup_subsys_state *css,
 	},
 	{
 		.name = "stat",
-		.seq_show = cpu_stats_show,
+		.seq_show = cpu_cfs_stats_show,
 	},
 #endif
 #ifdef CONFIG_RT_GROUP_SCHED
@@ -7296,7 +7296,7 @@ struct cgroup_subsys cpu_cgrp_subsys = {
 	.fork		= cpu_cgroup_fork,
 	.can_attach	= cpu_cgroup_can_attach,
 	.attach		= cpu_cgroup_attach,
-	.legacy_cftypes	= cpu_files,
+	.legacy_cftypes	= cpu_legacy_files,
 	.early_init	= true,
 };
 
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index f95ab29..6151c23 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -276,26 +276,33 @@ static int cpuacct_all_seq_show(struct seq_file *m, void *V)
 	return 0;
 }
 
-static int cpuacct_stats_show(struct seq_file *sf, void *v)
+static void cpuacct_stats_read(struct cpuacct *ca,
+			       u64 (*val)[CPUACCT_STAT_NSTATS])
 {
-	struct cpuacct *ca = css_ca(seq_css(sf));
-	s64 val[CPUACCT_STAT_NSTATS];
 	int cpu;
-	int stat;
 
-	memset(val, 0, sizeof(val));
+	memset(val, 0, sizeof(*val));
+
 	for_each_possible_cpu(cpu) {
 		u64 *cpustat = per_cpu_ptr(ca->cpustat, cpu)->cpustat;
 
-		val[CPUACCT_STAT_USER]   += cpustat[CPUTIME_USER];
-		val[CPUACCT_STAT_USER]   += cpustat[CPUTIME_NICE];
-		val[CPUACCT_STAT_SYSTEM] += cpustat[CPUTIME_SYSTEM];
-		val[CPUACCT_STAT_SYSTEM] += cpustat[CPUTIME_IRQ];
-		val[CPUACCT_STAT_SYSTEM] += cpustat[CPUTIME_SOFTIRQ];
+		(*val)[CPUACCT_STAT_USER]   += cpustat[CPUTIME_USER];
+		(*val)[CPUACCT_STAT_USER]   += cpustat[CPUTIME_NICE];
+		(*val)[CPUACCT_STAT_SYSTEM] += cpustat[CPUTIME_SYSTEM];
+		(*val)[CPUACCT_STAT_SYSTEM] += cpustat[CPUTIME_IRQ];
+		(*val)[CPUACCT_STAT_SYSTEM] += cpustat[CPUTIME_SOFTIRQ];
 	}
+}
+
+static int cpuacct_stats_show(struct seq_file *sf, void *v)
+{
+	u64 val[CPUACCT_STAT_NSTATS];
+	int stat;
+
+	cpuacct_stats_read(css_ca(seq_css(sf)), &val);
 
 	for (stat = 0; stat < CPUACCT_STAT_NSTATS; stat++) {
-		seq_printf(sf, "%s %lld\n",
+		seq_printf(sf, "%s %llu\n",
 			   cpuacct_stat_desc[stat],
 			   (long long)nsec_to_clock_t(val[stat]));
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
