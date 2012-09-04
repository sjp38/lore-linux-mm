Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 171C06B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:21:59 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 4/5] cpuacct: do not gather cpuacct statistics when not mounted
Date: Tue,  4 Sep 2012 18:18:19 +0400
Message-Id: <1346768300-10282-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1346768300-10282-1-git-send-email-glommer@parallels.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org, tj@kernel.org, Glauber Costa <glommer@parallels.com>

Currently, the only test that prevents us from running the expensive
cpuacct_charge() is cpuacct_subsys.active == true. This will hold at all
times after the subsystem is activated, even if it is not mounted.

IOW, use it or not, you pay it. By hooking with the bind() callback, we
can detect when cpuacct is mounted or umounted, and stop collecting
statistics when this cgroup is not in use.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Dave Jones <davej@redhat.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Paul Turner <pjt@google.com>
CC: Lennart Poettering <lennart@poettering.net>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Tejun Heo <tj@kernel.org>
---
 kernel/sched/core.c  | 8 ++++++++
 kernel/sched/sched.h | 3 +++
 2 files changed, 11 insertions(+)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index e46871d..d654bd1 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -8595,6 +8595,13 @@ static struct cftype files[] = {
 	{ }	/* terminate */
 };
 
+bool cpuacct_mounted;
+
+void cpuacct_bind(struct cgroup *root)
+{
+	cpuacct_mounted = root->root == root_cpuacct.css.cgroup->root;
+}
+
 /*
  * charge this task's execution time to its accounting group.
  *
@@ -8628,6 +8635,7 @@ struct cgroup_subsys cpuacct_subsys = {
 	.destroy = cpuacct_destroy,
 	.subsys_id = cpuacct_subsys_id,
 	.base_cftypes = files,
+	.bind = cpuacct_bind,
 #ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
 	.comounts = 1,
 	.must_comount = { cpu_cgroup_subsys_id, },
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 1da9fa8..d33f777 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -887,6 +887,7 @@ extern void update_idle_cpu_load(struct rq *this_rq);
 #include <linux/cgroup.h>
 
 extern bool cpuacct_from_cpu;
+extern bool cpuacct_mounted;
 
 /* track cpu usage of a group of tasks and its child groups */
 struct cpuacct {
@@ -921,6 +922,8 @@ extern void __cpuacct_charge(struct task_struct *tsk, u64 cputime);
 
 static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime)
 {
+	if (unlikely(!cpuacct_mounted))
+		return;
 #ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
 	if (likely(!cpuacct_from_cpu))
 		return;
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
