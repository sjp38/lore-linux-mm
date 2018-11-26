Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55A406B426B
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:07:31 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w1so4874442qta.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 08:07:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor871417qte.27.2018.11.26.08.07.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 08:07:27 -0800 (PST)
Date: Mon, 26 Nov 2018 11:07:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Hackbench pipes regression bisected to PSI
Message-ID: <20181126160724.GA21268@cmpxchg.org>
References: <20181126133420.GN23260@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126133420.GN23260@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

Hi Mel,

On Mon, Nov 26, 2018 at 01:34:20PM +0000, Mel Gorman wrote:
> Hi Johannes,
> 
> PSI is a great idea but it does have overhead and if enabled by Kconfig
> then it incurs a hit whether the user is aware of the feature or not. I
> think enabling by default is unnecessary as it should only be enabled if
> the information is being consumed. While the Kconfig exists, it's all or
> nothing if distributions want to have the feature available.

Yes, let's make this easier to pick and choose. Obviously I'd rather
you shipped it default-disabled than not at all.

> I've included a bisection report below showing a 6-10% regression on a
> single socket skylake machine. Would you mind doing one or all of the
> following to fix it please?
> 
> a) disable it by default
> b) put psi_disable behind a static branch to move the overhead to zero
>    if it's disabled
> c) optionally enable/disable at runtime (least important as at a glance,
>    this may be problematic)

For a) I'd suggest we do what we do in other places that face this
vendor kernel trade-off (NUMA balancing comes to mind): one option to
build the feature, one option to set whether the default is on or off.

And b) is pretty straight-forward, let's do that too.

c) is not possible, as we need the complete task counts to calculate
pressure, and maintaining those counts are where the sched cost is.

> Last good/First bad commit
> ==========================
> Last good commit: eb414681d5a07d28d2ff90dc05f69ec6b232ebd2
> First bad commit: 2ce7135adc9ad081aa3c49744144376ac74fea60
> From 2ce7135adc9ad081aa3c49744144376ac74fea60 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 26 Oct 2018 15:06:31 -0700
> Subject: [PATCH] psi: cgroup support
> On a system that executes multiple cgrouped jobs and independent
> workloads, we don't just care about the health of the overall system, but
> also that of individual jobs, so that we can ensure individual job health,
> fairness between jobs, or prioritize some jobs over others.
> This patch implements pressure stall tracking for cgroups.  In kernels
> with CONFIG_PSI=y, cgroup2 groups will have cpu.pressure, memory.pressure,
> and io.pressure files that track aggregate pressure stall times for only
> the tasks inside the cgroup.

It's curious that the cgroup support patch is the offender, not the
psi patch itself (that adds some cost as per the hackbench results,
but not as much). What kind of cgroup setup does this code run in?

Anyway, how about the following?

>From 6ae33455b8083fc9f5d5fbfe971f70253b0dbacd Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 26 Nov 2018 09:39:23 -0500
Subject: [PATCH] psi: make disabling/enabling easier for vendor kernels

Mel Gorman reports a hackbench regression with psi that would prohibit
shipping the suse kernel with it default-enabled, but he'd still like
users to be able to opt in at little to no cost to others.

With the current combination of CONFIG_PSI and the psi_disabled bool
set from the commandline, this is a challenge. Do the following things
to make it easier:

1. Add a config option CONFIG_PSI_DEFAULT_ENABLED that allows distros
   to enable CONFIG_PSI in their kernel, but leaving the feature
   disabled unless a user requests it at boot-time.

   To avoid double negatives, rename psi_disabled= to psi_enable=.

2. Make psi_disabled a static branch to eliminate any branch costs
   when the feature is disabled.

Reported-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/psi.h  |  3 ++-
 init/Kconfig         |  9 +++++++++
 kernel/sched/psi.c   | 30 +++++++++++++++++++++---------
 kernel/sched/stats.h |  8 ++++----
 4 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/include/linux/psi.h b/include/linux/psi.h
index 8e0725aac0aa..7006008d5b72 100644
--- a/include/linux/psi.h
+++ b/include/linux/psi.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_PSI_H
 #define _LINUX_PSI_H
 
+#include <linux/jump_label.h>
 #include <linux/psi_types.h>
 #include <linux/sched.h>
 
@@ -9,7 +10,7 @@ struct css_set;
 
 #ifdef CONFIG_PSI
 
-extern bool psi_disabled;
+extern struct static_key_false psi_disabled;
 
 void psi_init(void);
 
diff --git a/init/Kconfig b/init/Kconfig
index a4112e95724a..cf5b5a0dcbc2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -509,6 +509,15 @@ config PSI
 
 	  Say N if unsure.
 
+config PSI_DEFAULT_DISABLED
+	bool "Require boot parameter to enable pressure stall information tracking"
+	default n
+	depends on PSI
+	help
+	  If set, pressure stall information tracking will be disabled
+	  per default but can be enabled through passing psi_enable=1
+	  on the kernel commandline during boot.
+
 endmenu # "CPU/Task time and stats accounting"
 
 config CPU_ISOLATION
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 3d7355d7c3e3..9da0af3cd898 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -136,8 +136,18 @@
 
 static int psi_bug __read_mostly;
 
-bool psi_disabled __read_mostly;
-core_param(psi_disabled, psi_disabled, bool, 0644);
+DEFINE_STATIC_KEY_FALSE(psi_disabled);
+
+#ifdef CONFIG_PSI_DEFAULT_DISABLED
+bool psi_enable;
+#else
+bool psi_enable = true;
+#endif
+static int __init parse_psi_enable(char *str)
+{
+	return kstrtobool(str, &psi_enable) == 0;
+}
+__setup("psi_enable=", parse_psi_enable);
 
 /* Running averages - we need to be higher-res than loadavg */
 #define PSI_FREQ	(2*HZ+1)	/* 2 sec intervals */
@@ -169,8 +179,10 @@ static void group_init(struct psi_group *group)
 
 void __init psi_init(void)
 {
-	if (psi_disabled)
+	if (!psi_enable) {
+		static_branch_enable(&psi_disabled);
 		return;
+	}
 
 	psi_period = jiffies_to_nsecs(PSI_FREQ);
 	group_init(&psi_system);
@@ -549,7 +561,7 @@ void psi_memstall_enter(unsigned long *flags)
 	struct rq_flags rf;
 	struct rq *rq;
 
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return;
 
 	*flags = current->flags & PF_MEMSTALL;
@@ -579,7 +591,7 @@ void psi_memstall_leave(unsigned long *flags)
 	struct rq_flags rf;
 	struct rq *rq;
 
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return;
 
 	if (*flags)
@@ -600,7 +612,7 @@ void psi_memstall_leave(unsigned long *flags)
 #ifdef CONFIG_CGROUPS
 int psi_cgroup_alloc(struct cgroup *cgroup)
 {
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return 0;
 
 	cgroup->psi.pcpu = alloc_percpu(struct psi_group_cpu);
@@ -612,7 +624,7 @@ int psi_cgroup_alloc(struct cgroup *cgroup)
 
 void psi_cgroup_free(struct cgroup *cgroup)
 {
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return;
 
 	cancel_delayed_work_sync(&cgroup->psi.clock_work);
@@ -637,7 +649,7 @@ void cgroup_move_task(struct task_struct *task, struct css_set *to)
 	struct rq_flags rf;
 	struct rq *rq;
 
-	if (psi_disabled) {
+	if (static_branch_likely(&psi_disabled)) {
 		/*
 		 * Lame to do this here, but the scheduler cannot be locked
 		 * from the outside, so we move cgroups from inside sched/.
@@ -673,7 +685,7 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 {
 	int full;
 
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return -EOPNOTSUPP;
 
 	update_stats(group);
diff --git a/kernel/sched/stats.h b/kernel/sched/stats.h
index 4904c4677000..aa0de240fb41 100644
--- a/kernel/sched/stats.h
+++ b/kernel/sched/stats.h
@@ -66,7 +66,7 @@ static inline void psi_enqueue(struct task_struct *p, bool wakeup)
 {
 	int clear = 0, set = TSK_RUNNING;
 
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return;
 
 	if (!wakeup || p->sched_psi_wake_requeue) {
@@ -86,7 +86,7 @@ static inline void psi_dequeue(struct task_struct *p, bool sleep)
 {
 	int clear = TSK_RUNNING, set = 0;
 
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return;
 
 	if (!sleep) {
@@ -102,7 +102,7 @@ static inline void psi_dequeue(struct task_struct *p, bool sleep)
 
 static inline void psi_ttwu_dequeue(struct task_struct *p)
 {
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return;
 	/*
 	 * Is the task being migrated during a wakeup? Make sure to
@@ -128,7 +128,7 @@ static inline void psi_ttwu_dequeue(struct task_struct *p)
 
 static inline void psi_task_tick(struct rq *rq)
 {
-	if (psi_disabled)
+	if (static_branch_likely(&psi_disabled))
 		return;
 
 	if (unlikely(rq->curr->flags & PF_MEMSTALL))
-- 
2.19.1
