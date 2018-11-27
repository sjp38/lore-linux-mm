Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D528D6B492F
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:53:35 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x14so14309050ywg.18
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:53:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 195sor552349ywf.56.2018.11.27.08.53.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:53:32 -0800 (PST)
Date: Tue, 27 Nov 2018 11:53:29 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Hackbench pipes regression bisected to PSI
Message-ID: <20181127165329.GA29728@cmpxchg.org>
References: <20181126133420.GN23260@techsingularity.net>
 <20181126160724.GA21268@cmpxchg.org>
 <20181126165446.GQ23260@techsingularity.net>
 <20181126173218.GA22640@cmpxchg.org>
 <20181126232926.GS23260@techsingularity.net>
 <20181127164617.GA29488@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127164617.GA29488@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, Nov 27, 2018 at 11:46:17AM -0500, Johannes Weiner wrote:
> From 347b69a52d1ec7e71df1108cbc5703d6dd0616ba Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 26 Nov 2018 09:39:23 -0500
> Subject: [PATCH] psi: make disabling/enabling easier for vendor kernels
> 
> Mel Gorman reports a hackbench regression with psi that would prohibit
> shipping the suse kernel with it default-enabled, but he'd still like
> users to be able to opt in at little to no cost to others.
> 
> With the current combination of CONFIG_PSI and the psi_disabled bool
> set from the commandline, this is a challenge. Do the following things
> to make it easier:
> 
> 1. Add a config option CONFIG_PSI_DEFAULT_ENABLED that allows distros

This should be:          CONFIG_PSI_DEFAULT_DISABLED

Refreshed the patch.

---

>From dc1511101b4c6aa3f7cfb91d8634a682fe7c147e Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 26 Nov 2018 09:39:23 -0500
Subject: [PATCH] psi: make disabling/enabling easier for vendor kernels

Mel Gorman reports a hackbench regression with psi that would prohibit
shipping the suse kernel with it default-enabled, but he'd still like
users to be able to opt in at little to no cost to others.

With the current combination of CONFIG_PSI and the psi_disabled bool
set from the commandline, this is a challenge. Do the following things
to make it easier:

1. Add a config option CONFIG_PSI_DEFAULT_DISABLED that allows distros
   to enable CONFIG_PSI in their kernel but leave the feature disabled
   unless a user requests it at boot-time.

   To avoid double negatives, rename psi_disabled= to psi=.

2. Make psi_disabled a static branch to eliminate any branch costs
   when the feature is disabled.

In terms of numbers before and after this patch, Mel says:

: The following is a comparision using CONFIG_PSI=n as a baseline against
: your patch and a vanilla kernel
:
:                          4.20.0-rc4             4.20.0-rc4             4.20.0-rc4
:                 kconfigdisable-v1r1                vanilla        psidisable-v1r1
: Amean     1       1.3100 (   0.00%)      1.3923 (  -6.28%)      1.3427 (  -2.49%)
: Amean     3       3.8860 (   0.00%)      4.1230 *  -6.10%*      3.8860 (  -0.00%)
: Amean     5       6.8847 (   0.00%)      8.0390 * -16.77%*      6.7727 (   1.63%)
: Amean     7       9.9310 (   0.00%)     10.8367 *  -9.12%*      9.9910 (  -0.60%)
: Amean     12     16.6577 (   0.00%)     18.2363 *  -9.48%*     17.1083 (  -2.71%)
: Amean     18     26.5133 (   0.00%)     27.8833 *  -5.17%*     25.7663 (   2.82%)
: Amean     24     34.3003 (   0.00%)     34.6830 (  -1.12%)     32.0450 (   6.58%)
: Amean     30     40.0063 (   0.00%)     40.5800 (  -1.43%)     41.5087 (  -3.76%)
: Amean     32     40.1407 (   0.00%)     41.2273 (  -2.71%)     39.9417 (   0.50%)
:
: It's showing that the vanilla kernel takes a hit (as the bisection
: indicated it would) and that disabling PSI by default is reasonably
: close in terms of performance for this particular workload on this
: particular machine so;

Tested-by: Mel Gorman <mgorman@techsingularity.net>
Reported-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 .../admin-guide/kernel-parameters.txt         |  4 +++
 include/linux/psi.h                           |  3 +-
 init/Kconfig                                  |  9 ++++++
 kernel/sched/psi.c                            | 30 +++++++++++++------
 kernel/sched/stats.h                          |  8 ++---
 5 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 19f4423e70d9..8760a343c6d8 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -3504,6 +3504,10 @@
 			before loading.
 			See Documentation/blockdev/ramdisk.txt.
 
+	psi=		[KNL] Enable or disable pressure stall information
+			tracking.
+			Format: <bool>
+
 	psmouse.proto=	[HW,MOUSE] Highest PS2 mouse protocol extension to
 			probe for; one of (bare|imps|exps|lifebook|any).
 	psmouse.rate=	[HW,MOUSE] Set desired mouse report rate, in reports
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
index 3d7355d7c3e3..fe24de3fbc93 100644
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
+static int __init setup_psi(char *str)
+{
+	return kstrtobool(str, &psi_enable) == 0;
+}
+__setup("psi=", setup_psi);
 
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
