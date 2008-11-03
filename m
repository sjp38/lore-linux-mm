Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id mA3MJEhL008806
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:19:14 GMT
Received: from wf-out-1314.google.com (wfg24.prod.google.com [10.142.7.24])
	by wpaz13.hot.corp.google.com with ESMTP id mA3MJCU6024722
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 14:19:12 -0800
Received: by wf-out-1314.google.com with SMTP id 24so3056649wfg.15
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 14:19:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <604427e00811031340k56634773g6e260d79e6cb51e7@mail.gmail.com>
References: <604427e00811031340k56634773g6e260d79e6cb51e7@mail.gmail.com>
Date: Mon, 3 Nov 2008 14:19:11 -0800
Message-ID: <604427e00811031419k2e990061kdb03f4b715b51fb9@mail.gmail.com>
Subject: Re: [RFC][PATCH]Per-cgroup OOM handler
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Rohit Seth <rohitseth@google.com>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

sorry, please use the following patch. (deleted the double definition
in cgroup_subsys.h from last patch)

Per-cgroup OOM handler ported from cpuset to cgroup.

Per cgroup OOM handler allows a userspace handler catches and handle the OOM,
the OOMing thread doesn't trigger a kill, but returns to alloc_pages to try
again; alternatively usersapce can cause the OOM killer to go ahead as normal.

It's a standalone subsystem that can work with either the memory cgroup or
with cpusets(where memory is constrained by numa nodes).

The features are:

- an oom.delay file that controls how long a thread will pause in the
OOM killer waiting for a response from userspace (in milliseconds)

- an oom.await file that a userspace handler can write a timeout value
to, and be awoken either when a process in that cgroup enters the OOM
killer, or the timeout expires.

example:
(mount oom as normal cgroup subsystem as well as cpuset)
1. mount -t cgroup -o cpuset,oom cpuset /dev/cpuset

(config sample cpuset contains single fakenuma node with 128M and one
cpu core)
2. mkdir /dev/cpuset/sample
   echo 1 > /dev/cpuset/sample/cpuset.mems
   echo 1 > /dev/cpuset/sample/cpuset.cpus

(config the oom.delay to be 10sec)
3. echo 10000 >/dev/cpuset/sample/oom.oom_delay

(put the shell in the wait-queue with max 60sec waitting)
4. echo 60000 >/dev/cpuset/sample/oom.await_oom

(trigger the oom by mlockall 600M anon memory)
5. /oom 600000000

When the sample cpuset triggers the OOM, it will wake-up the
OOM-handler thread that slept in step 4, sleep for a jiffie, and then
return to alloc_pages() to try again. This sleep gives the OOM-handler
time to deal with the OOM, for example by giving another memory node
to the OOMing cpuset.

We're sending out this in-house patch to start discussion about what
might be appropriate for supporting user-space OOM-handling in the
mainline kernel. Potential improvements include:

- providing more information in the OOM notification, such as the pid
that triggered the OOM, and a unique id for that OOM instance that can
be tied to later OOM-kill notifications.

- allowing better notifications from userspace back to the kernel.

 Documentation/cgroups/oom-handler.txt |   49 ++++++++
 include/linux/cgroup_subsys.h         |   12 ++
 include/linux/cpuset.h                |    7 +-
 init/Kconfig                          |    8 ++
 kernel/cpuset.c                       |    8 +-
 mm/oom_kill.c                         |  220 +++++++++++++++++++++++++++++++++
 6 files changed, 301 insertions(+), 3 deletions(-)

Signed-off-by:Paul Menage <menage@google.com>
	      David Rientjes <rientjes@google.com>
	      Ying Han <yinghan@google.com>


diff --git a/Documentation/cgroups/oom-handler.txt
b/Documentation/cgroups/oom-handler.txt
new file mode 100644
index 0000000..aa006fe
--- /dev/null
+++ b/Documentation/cgroups/oom-handler.txt
@@ -0,0 +1,49 @@
+Per cgroup OOM handler allows a userspace handler catches and handle the OOM,
+the OOMing thread doesn't trigger a kill, but returns to alloc_pages to try
+again; alternatively usersapce can cause the OOM killer to go ahead as normal.
+
+It's a standalone subsystem that can work with either the memory cgroup or
+with cpusets(where memory is constrained by numa nodes).
+
+The features are:
+
+- an oom.delay file that controls how long a thread will pause in the
+OOM killer waiting for a response from userspace (in milliseconds)
+
+- an oom.await file that a userspace handler can write a timeout value
+to, and be awoken either when a process in that cgroup enters the OOM
+killer, or the timeout expires.
+
+example:
+(mount oom as normal cgroup subsystem as well as cpuset)
+1. mount -t cgroup -o cpuset,oom cpuset /dev/cpuset
+
+(config sample cpuset contains single fakenuma node with 128M and one
+cpu core)
+2. mkdir /dev/cpuset/sample
+   echo 1 > /dev/cpuset/sample/cpuset.mems
+   echo 1 > /dev/cpuset/sample/cpuset.cpus
+
+(config the oom.delay to be 10sec)
+3. echo 10000 >/dev/cpuset/sample/oom.oom_delay
+
+(put the shell in the wait-queue with max 60sec waitting)
+4. echo 60000 >/dev/cpuset/sample/oom.await_oom
+
+(trigger the oom by mlockall 600M anon memory)
+5. /oom 600000000
+
+When the sample cpuset triggers the OOM, it will wake-up the
+OOM-handler thread that slept in step 4, sleep for a jiffie, and then
+return to alloc_pages() to try again. This sleep gives the OOM-handler
+time to deal with the OOM, for example by giving another memory node
+to the OOMing cpuset.
+
+Potential improvements include:
+- providing more information in the OOM notification, such as the pid
+that triggered the OOM, and a unique id for that OOM instance that can
+be tied to later OOM-kill notifications.
+
+- allowing better notifications from userspace back to the kernel.
+
+
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 9c22396..23fe6c7 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -54,3 +54,9 @@ SUBSYS(freezer)
 #endif

 /* */
+
+#ifdef CONFIG_CGROUP_OOM_CONT
+SUBSYS(oom_cgroup)
+#endif
+
+/* */
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 2691926..26dab22 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -25,7 +25,7 @@ extern void cpuset_cpus_allowed_locked(struct
task_struct *p, cpumask_t *mask);
 extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
 #define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
-void cpuset_update_task_memory_state(void);
+int cpuset_update_task_memory_state(void);
 int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);

 extern int __cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask);
@@ -103,7 +103,10 @@ static inline nodemask_t
cpuset_mems_allowed(struct task_struct *p)

 #define cpuset_current_mems_allowed (node_states[N_HIGH_MEMORY])
 static inline void cpuset_init_current_mems_allowed(void) {}
-static inline void cpuset_update_task_memory_state(void) {}
+static inline int cpuset_update_task_memory_state(void)
+{
+	return 1;
+}

 static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
diff --git a/init/Kconfig b/init/Kconfig
index 44e9208..971b0b5 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -324,6 +324,14 @@ config CPUSETS

 	  Say N if unsure.

+config CGROUP_OOM_CONT
+	bool "OOM controller for cgroups"
+	depends on CGROUPS
+	help
+	  This option allows userspace to trap OOM conditions on a
+	  per-cgroup basis, and take action that might prevent the OOM from
+	  occurring.
+
 #
 # Architectures with an unreliable sched_clock() should select this:
 #
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3e00526..c986423 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -355,13 +355,17 @@ static void guarantee_online_mems(const struct
cpuset *cs, nodemask_t *pmask)
  * within the tasks context, when it is trying to allocate memory
  * (in various mm/mempolicy.c routines) and notices that some other
  * task has been modifying its cpuset.
+ *
+ * Returns non-zero if the state was updated, including when it is
+ * an effective no-op.
  */

-void cpuset_update_task_memory_state(void)
+int cpuset_update_task_memory_state(void)
 {
 	int my_cpusets_mem_gen;
 	struct task_struct *tsk = current;
 	struct cpuset *cs;
+	int ret = 0;

 	if (task_cs(tsk) == &top_cpuset) {
 		/* Don't need rcu for top_cpuset.  It's never freed. */
@@ -389,7 +393,9 @@ void cpuset_update_task_memory_state(void)
 		task_unlock(tsk);
 		mutex_unlock(&callback_mutex);
 		mpol_rebind_task(tsk, &tsk->mems_allowed);
+		ret = 1;
 	}
+	return ret;
 }

 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 64e5b4b..5677b72 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -32,6 +32,219 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks;
 static DEFINE_SPINLOCK(zone_scan_mutex);
+
+#ifdef CONFIG_CGROUP_OOM_CONT
+struct oom_cgroup {
+	struct cgroup_subsys_state css;
+
+	/* How long between first OOM indication and actual OOM kill
+	 * for processes in this cgroup */
+	unsigned long oom_delay;
+
+	/* When the current OOM delay began. Zero means no delay in progress */
+	unsigned long oom_since;
+
+	/* Wait queue for userspace OOM handler */
+	wait_queue_head_t oom_wait;
+
+	spinlock_t oom_lock;
+};
+
+static inline
+struct oom_cgroup *oom_cgroup_from_cont(struct cgroup *cont)
+{
+	return container_of(cgroup_subsys_state(cont, oom_cgroup_subsys_id),
+				struct oom_cgroup, css);
+}
+
+static inline
+struct oom_cgroup *oom_cgroup_from_task(struct task_struct *task)
+{
+	return container_of(task_subsys_state(task, oom_cgroup_subsys_id),
+					struct oom_cgroup, css);
+}
+
+/*
+ * Takes oom_lock during call.
+ */
+static int oom_cgroup_write_delay(struct cgroup *cont, struct cftype *cft,
+				u64 delay)
+{
+	struct oom_cgroup *cs = oom_cgroup_from_cont(cont);
+
+	/* Sanity check */
+	if (unlikely(delay > 60 * 1000))
+		return -EINVAL;
+	spin_lock(&cs->oom_lock);
+	cs->oom_delay = msecs_to_jiffies(delay);
+	spin_unlock(&cs->oom_lock);
+	return 0;
+}
+
+/*
+ * sleeps until the cgroup enters OOM (or a maximum of N milliseconds if N is
+ * passed). Clears the OOM condition in the cgroup when it returns.
+ */
+static int oom_cgroup_write_await(struct cgroup *cont, struct cftype *cft,
+				u64 await)
+{
+	int retval = 0;
+	struct oom_cgroup *cs = oom_cgroup_from_cont(cont);
+
+	/* Don't try to wait for more than a minute */
+	await = min(await, 60ULL * 1000);
+	/* Try waiting for up to a second for an OOM condition */
+	wait_event_interruptible_timeout(cs->oom_wait, cs->oom_since ||
+					 cgroup_is_removed(cs->css.cgroup),
+					 msecs_to_jiffies(await));
+	spin_lock(&cs->oom_lock);
+	if (cgroup_is_removed(cs->css.cgroup)) {
+		/* The cpuset was removed while we slept */
+		retval = -ENODEV;
+	} else if (cs->oom_since) {
+		/* We reached OOM. Clear the OOM condition now that
+		 * userspace knows about it */
+		cs->oom_since = 0;
+	} else if (signal_pending(current)) {
+		retval = -EINTR;
+	} else {
+		/* No OOM yet */
+		retval = -ETIMEDOUT;
+	}
+	spin_unlock(&cs->oom_lock);
+	return retval;
+}
+
+static u64 oom_cgroup_read_delay(struct cgroup *cont, struct cftype *cft)
+{
+	return oom_cgroup_from_cont(cont)->oom_delay;
+}
+
+static struct cftype oom_cgroup_files[] = {
+	{
+		.name = "delay",
+		.read_u64 = oom_cgroup_read_delay,
+		.write_u64 = oom_cgroup_write_delay,
+	},
+
+	{
+		.name = "await",
+		.write_u64 = oom_cgroup_write_await,
+	},
+};
+
+static struct cgroup_subsys_state *oom_cgroup_create(
+		struct cgroup_subsys *ss,
+		struct cgroup *cont)
+{
+	struct oom_cgroup *oom;
+
+	oom = kmalloc(sizeof(*oom), GFP_KERNEL);
+	if (!oom)
+		return ERR_PTR(-ENOMEM);
+
+	oom->oom_delay = 0;
+	init_waitqueue_head(&oom->oom_wait);
+	oom->oom_since = 0;
+	spin_lock_init(&oom->oom_lock);
+
+	return &oom->css;
+}
+
+static void oom_cgroup_destroy(struct cgroup_subsys *ss,
+			struct cgroup *cont)
+{
+	kfree(oom_cgroup_from_cont(cont));
+}
+
+static int oom_cgroup_populate(struct cgroup_subsys *ss,
+			struct cgroup *cont)
+{
+	return cgroup_add_files(cont, ss, oom_cgroup_files,
+					ARRAY_SIZE(oom_cgroup_files));
+}
+
+struct cgroup_subsys oom_cgroup_subsys = {
+	.name = "oom",
+	.subsys_id = oom_cgroup_subsys_id,
+	.create = oom_cgroup_create,
+	.destroy = oom_cgroup_destroy,
+	.populate = oom_cgroup_populate,
+};
+
+
+/*
+ * Call with no cpuset mutex held. Determines whether this process
+ * should allow an OOM to proceed as normal (retval==1) or should try
+ * again to allocate memory (retval==0). If necessary, sleeps and then
+ * updates the task's mems_allowed to let userspace update the memory
+ * nodes for the task's cpuset.
+ */
+static int cgroup_should_oom(void)
+{
+	int ret = 1; /* OOM by default */
+	struct oom_cgroup *cs;
+
+	task_lock(current);
+	cs = oom_cgroup_from_task(current);
+
+	spin_lock(&cs->oom_lock);
+	if (cs->oom_delay) {
+		/* We have an OOM delay configured */
+		if (cs->oom_since) {
+			/* We're already OOMing - see if we're over
+			 * the time limit. Also make sure that jiffie
+			 * wrap-around doesn't make us think we're in
+			 * an incredibly long OOM delay */
+			unsigned long deadline = cs->oom_since + cs->oom_delay;
+			if (time_after(deadline, jiffies) &&
+			    !time_after(cs->oom_since, jiffies)) {
+				/* Not OOM yet */
+				ret = 0;
+			}
+		} else {
+			/* This is the first OOM */
+			ret = 0;
+			cs->oom_since = jiffies;
+			/* Avoid problems with jiffie wrap - make an
+			 * oom_since of zero always mean not
+			 * OOMing */
+			if (!cs->oom_since)
+				cs->oom_since = 1;
+			printk(KERN_WARNING
+			       "Cpuset %s (pid %d) sending memory "
+			       "notification to userland at %lu%s\n",
+			       cs->css.cgroup->dentry->d_name.name,
+			       current->pid, jiffies,
+			       waitqueue_active(&cs->oom_wait) ?
+			       "" : " (no waiters)");
+		}
+		if (!ret) {
+			/* If we're planning to retry, we should wake
+			 * up any userspace waiter in order to let it
+			 * handle the OOM
+			 */
+			wake_up_all(&cs->oom_wait);
+		}
+	}
+
+	spin_unlock(&cs->oom_lock);
+	task_unlock(current);
+	if (!ret) {
+		/* If we're not going to OOM, we should sleep for a
+		 * bit to give userspace a chance to respond before we
+		 * go back and try to reclaim again */
+		schedule_timeout_uninterruptible(1);
+	}
+	return ret;
+}
+#else /* !CONFIG_CGROUP_OOM_CONT */
+static inline int cgroup_should_oom(void)
+{
+	return 1;
+}
+#endif
+
 /* #define DEBUG */

 /**
@@ -526,6 +739,13 @@ void out_of_memory(struct zonelist *zonelist,
gfp_t gfp_mask, int order)
 	unsigned long freed = 0;
 	enum oom_constraint constraint;

+	/*
+	 * It is important to call in this order since cgroup_should_oom()
+	 * might sleep and give userspace chance to update mems.
+	 */
+	if (!cgroup_should_oom() || cpuset_update_task_memory_state())
+		return;
+
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
 		/* Got some memory back in the last second. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
