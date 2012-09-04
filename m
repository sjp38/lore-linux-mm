Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 360F16B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:21:52 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 2/5] sched: adjust exec_clock to use it as cpu usage metric
Date: Tue,  4 Sep 2012 18:18:17 +0400
Message-Id: <1346768300-10282-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1346768300-10282-1-git-send-email-glommer@parallels.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org, tj@kernel.org, Glauber Costa <glommer@parallels.com>

exec_clock already provides per-group cpu usage metrics, and can be
reused by cpuacct in case cpu and cpuacct are comounted.

However, it is only provided by tasks in fair class. Doing the same for
rt is easy, and can be done in an already existing hierarchy loop. This
is an improvement over the independent hierarchy walk executed by
cpuacct.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Dave Jones <davej@redhat.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Paul Turner <pjt@google.com>
CC: Lennart Poettering <lennart@poettering.net>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Tejun Heo <tj@kernel.org>
---
 kernel/sched/rt.c    | 1 +
 kernel/sched/sched.h | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/kernel/sched/rt.c b/kernel/sched/rt.c
index 573e1ca..40ef6af 100644
--- a/kernel/sched/rt.c
+++ b/kernel/sched/rt.c
@@ -930,6 +930,7 @@ static void update_curr_rt(struct rq *rq)
 
 	for_each_sched_rt_entity(rt_se) {
 		rt_rq = rt_rq_of_se(rt_se);
+		schedstat_add(rt_rq, exec_clock, delta_exec);
 
 		if (sched_rt_runtime(rt_rq) != RUNTIME_INF) {
 			raw_spin_lock(&rt_rq->rt_runtime_lock);
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 55844f2..8da579d 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -204,6 +204,7 @@ struct cfs_rq {
 	unsigned int nr_running, h_nr_running;
 
 	u64 exec_clock;
+	u64 prev_exec_clock;
 	u64 min_vruntime;
 #ifndef CONFIG_64BIT
 	u64 min_vruntime_copy;
@@ -295,6 +296,8 @@ struct rt_rq {
 	struct plist_head pushable_tasks;
 #endif
 	int rt_throttled;
+	u64 exec_clock;
+	u64 prev_exec_clock;
 	u64 rt_time;
 	u64 rt_runtime;
 	/* Nests inside the rq lock: */
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
