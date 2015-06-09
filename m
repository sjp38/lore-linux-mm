From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC] panic_on_oom_timeout
Date: Tue, 9 Jun 2015 19:03:10 +0200
Message-ID: <20150609170310.GA8990@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi,
during the last iteration of the timeout based oom killer discussion
(http://marc.info/?l=linux-mm&m=143351457601723) I've proposed to
introduce panic_on_oom_timeout as an extension to panic_on_oom rather
than oom timeout which would allow OOM killer to select another oom
victim and do that until the OOM is resolved or the system panics due to
potential oom victims depletion.

My main rationale for going panic_on_oom_timeout way is that this
approach will lead to much more predictable behavior because the system
will get to a usable state after given amount of time + reboot time.
On the other hand, if the other approach was chosen then there is no
guarantee that another victim would be in any better situation than the
original one. In fact there might be many tasks blocked on a single lock
(e.g. i_mutex) and the oom killer doesn't have any way to find out which
task to kill in order to make the progress. The result would be
N*timeout time period when the system is basically unusable and the N is
unknown to the admin.

I think that it is more appropriate to shut such a system down when such
a corner case is hit rather than struggle for basically unbounded amount
of time.

Thoughts? An RFC implementing this is below. It is quite trivial and
I've tried to test it a bit. I will add the missing pieces if this looks
like a way to go.

There are obviously places in the oom killer and the page allocator path
which could be improved and this patch doesn't try to put them aside. It
is just providing a reasonable the very last resort when things go
really wrong.
---
>From 35b7cff442326c609cdbb78757ef46e6d0ca0c61 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.cz>
Date: Tue, 9 Jun 2015 16:15:42 +0200
Subject: [RFC] oom: implement panic_on_oom_timeout

OOM killer is a desparate last resort reclaim attempt to free some
memory. It is based on heuristics which will never be 100% and may
result in an unusable or a locked up system.

panic_on_oom sysctl knob allows to set the OOM policy to panic the
system instead of trying to resolve the OOM condition. This might be
useful for several reasons - e.g. reduce the downtime to a predictable
amount of time, allow to get a crash dump of the system and debug the
issue post-mortem.

panic_on_oom is, however, a big hammer in many situations when the
OOM condition could be resolved in a reasonable time. So it would be
good to have some middle ground and allow the OOM killer to do its job
but have a failover when things go wrong and it is not able to make any
further progress for a considerable amount of time.

This patch implements panic_on_oom_timeout sysctl which is active
only when panic_on_oom!=0 and it configures a maximum timeout for
the OOM killer to resolve the OOM situation. If the system is still
under OOM after the timeout expires it will panic the system as per
panic_on_oom configuration. A reasonably chosen timeout can protect from
both temporal OOM conditions and allows to have a predictable time frame
for the OOM condition.

The feature is implemented as a delayed work which is scheduled when
the OOM condition is declared for the first time (oom_victims is still
zero) in out_of_memory and it is canceled in exit_oom_victim after
the oom_victims count drops down to zero. For this time period OOM
killer cannot kill new tasks and it only allows exiting or killed
tasks to access memory reserves (and increase oom_victims counter via
mark_oom_victim) in order to make a progress so it is reasonable to
consider the elevated oom_victims count as an ongoing OOM condition

The log will then contain something like:
[  904.144494] run_test.sh invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[  904.145854] run_test.sh cpuset=/ mems_allowed=0
[  904.146651] CPU: 0 PID: 5244 Comm: run_test.sh Not tainted 4.0.0-oomtimeout2-00001-g3b4737913602 #575
[...]
[  905.147523] panic_on_oom timeout 1s has expired
[  905.150049] kworker/0:1 invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[  905.154572] kworker/0:1 cpuset=/ mems_allowed=0
[...]
[  905.503378] Kernel panic - not syncing: Out of memory: system-wide panic_on_oom is enabled

TODO: Documentation update
TODO: check all potential paths which might skip mark_oom_victim
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/oom.h |  1 +
 kernel/sysctl.c     |  8 ++++++
 mm/oom_kill.c       | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 80 insertions(+), 4 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 061e0ffd3493..6884c8dc37a0 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -100,4 +100,5 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern int sysctl_panic_on_oom_timeout;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d6fff89b78db..3ac2e5d0b1e2 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1141,6 +1141,14 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &two,
 	},
 	{
+		.procname	= "panic_on_oom_timeout",
+		.data		= &sysctl_panic_on_oom_timeout,
+		.maxlen		= sizeof(sysctl_panic_on_oom_timeout),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "oom_kill_allocating_task",
 		.data		= &sysctl_oom_kill_allocating_task,
 		.maxlen		= sizeof(sysctl_oom_kill_allocating_task),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d7fb1275e200..9b1ac69caa24 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,11 +35,14 @@
 #include <linux/freezer.h>
 #include <linux/ftrace.h>
 #include <linux/ratelimit.h>
+#include <linux/nodemask.h>
+#include <linux/lockdep.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
 
 int sysctl_panic_on_oom;
+int sysctl_panic_on_oom_timeout;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
@@ -430,6 +433,9 @@ void mark_oom_victim(struct task_struct *tsk)
 	atomic_inc(&oom_victims);
 }
 
+static void delayed_panic_on_oom(struct work_struct *w);
+static DECLARE_DELAYED_WORK(panic_on_oom_work, delayed_panic_on_oom);
+
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
@@ -437,8 +443,10 @@ void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
-	if (!atomic_dec_return(&oom_victims))
+	if (!atomic_dec_return(&oom_victims)) {
+		cancel_delayed_work(&panic_on_oom_work);
 		wake_up_all(&oom_victims_wait);
+	}
 }
 
 /**
@@ -538,6 +546,7 @@ static void __oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	p = find_lock_task_mm(victim);
 	if (!p) {
+		/* TODO cancel delayed_panic_on_oom */
 		put_task_struct(victim);
 		return;
 	} else if (victim != p) {
@@ -606,6 +615,62 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			nodemask, message);
 }
 
+static void panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
+			int order, const nodemask_t *nodemask,
+			struct mem_cgroup *memcg)
+{
+	dump_header(NULL, gfp_mask, order, memcg, nodemask);
+	panic("Out of memory: %s panic_on_oom is enabled\n",
+		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
+}
+
+static struct oom_ctx {
+	enum oom_constraint constraint;
+	gfp_t gfp_mask;
+	int order;
+	nodemask_t nodemask;
+	struct mem_cgroup *memcg;
+	int timeout;
+} oom_ctx;
+
+static void delayed_panic_on_oom(struct work_struct *w)
+{
+	pr_info("panic_on_oom timeout %ds has expired\n", oom_ctx.timeout);
+	panic_on_oom(oom_ctx.constraint, oom_ctx.gfp_mask, oom_ctx.order,
+			&oom_ctx.nodemask, oom_ctx.memcg);
+}
+
+void schedule_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
+			int order, const nodemask_t *nodemask,
+			struct mem_cgroup *memcg, int timeout)
+{
+	lockdep_assert_held(&oom_lock);
+
+	/*
+	 * Only schedule the delayed panic_on_oom when this is the first OOM
+	 * triggered. oom_lock will protect us from races
+	 */
+	if (atomic_read(&oom_victims))
+		return;
+
+	oom_ctx.constraint = constraint;
+	oom_ctx.gfp_mask = gfp_mask;
+	oom_ctx.order = order;
+	if (nodemask)
+		oom_ctx.nodemask = *nodemask;
+	else
+		memset(&oom_ctx.nodemask, 0, sizeof(oom_ctx.nodemask));
+
+	/*
+	 * The killed task should ping the memcg and the even the delayed
+	 * work either expires or strikes before the victim exits.
+	 */
+	oom_ctx.memcg = memcg;
+	oom_ctx.timeout = timeout;
+
+	schedule_delayed_work(&panic_on_oom_work, timeout*HZ);
+}
+
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
@@ -624,9 +689,11 @@ void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 		if (constraint != CONSTRAINT_NONE)
 			return;
 	}
-	dump_header(NULL, gfp_mask, order, memcg, nodemask);
-	panic("Out of memory: %s panic_on_oom is enabled\n",
-		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
+	if (!sysctl_panic_on_oom_timeout)
+		panic_on_oom(constraint, gfp_mask, order, nodemask, memcg);
+	else
+		schedule_panic_on_oom(constraint, gfp_mask, order, nodemask,
+				memcg, sysctl_panic_on_oom_timeout);
 }
 
 static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
-- 
2.1.4

-- 
Michal Hocko
SUSE Labs
