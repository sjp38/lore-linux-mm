Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BBDCC8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 12:16:34 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id m16so4350485pgd.0
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 09:16:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p22sor9050510pfi.50.2018.12.14.09.16.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 09:16:31 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH 6/6] psi: introduce psi monitor
Date: Fri, 14 Dec 2018 09:15:08 -0800
Message-Id: <20181214171508.7791-7-surenb@google.com>
In-Reply-To: <20181214171508.7791-1-surenb@google.com>
References: <20181214171508.7791-1-surenb@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com, Suren Baghdasaryan <surenb@google.com>

Psi monitor aims to provide a low-latency short-term pressure
detection mechanism configurable by users. It allows users to
monitor psi metrics growth and trigger events whenever a metric
raises above user-defined threshold within user-defined time window.

Time window is expressed in usecs and threshold can be expressed in
usecs or percentages of the tracking window. Multiple psi resources
with different thresholds and window sizes can be monitored concurrently.

Psi monitors activate when system enters stall state for the monitored
psi metric and deactivate upon exit from the stall state. While system
is in the stall state psi signal growth is monitored at a rate of 10 times
per tracking window. Min window size is 500ms, therefore the min monitoring
interval is 50ms. Max window size is 10s with monitoring interval of 1s.

When activated psi monitor stays active for at least the duration of one
tracking window to avoid repeated activations/deactivations when psi
signal is bouncing.

Notifications to the users are rate-limited to one per tracking window.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 Documentation/accounting/psi.txt | 105 +++++++
 include/linux/psi.h              |  10 +
 include/linux/psi_types.h        |  72 +++++
 kernel/cgroup/cgroup.c           | 107 ++++++-
 kernel/sched/psi.c               | 510 +++++++++++++++++++++++++++++--
 5 files changed, 774 insertions(+), 30 deletions(-)

diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
index b8ca28b60215..b006cc84ad44 100644
--- a/Documentation/accounting/psi.txt
+++ b/Documentation/accounting/psi.txt
@@ -63,6 +63,108 @@ tracked and exported as well, to allow detection of latency spikes
 which wouldn't necessarily make a dent in the time averages, or to
 average trends over custom time frames.
 
+Monitoring for pressure thresholds
+==================================
+
+Users can register triggers and use poll() to be woken up when resource
+pressure exceeds certain thresholds.
+
+A trigger describes the maximum cumulative stall time over a specific
+time window, e.g. 100ms of total stall time within any 500ms window to
+generate a wakeup event.
+
+To register a trigger user has to open psi interface file under
+/proc/pressure/ representing the resource to be monitored and write the
+desired threshold and time window. The open file descriptor should be
+used to wait for trigger events using select(), poll() or epoll().
+The following format is used:
+
+<some|full> <stall %|stall amount in us> <time window in us>
+
+For example writing "some 15% 1000000" or "some 150000 1000000" into
+/proc/pressure/memory would add 15% (150ms) threshold for partial memory
+stall measured within 1sec time window. Writing "full 5% 1000000" or
+"full 50000 1000000" into /proc/pressure/io would add 5% (50ms) threshold
+for full io stall measured within 1sec time window.
+
+Triggers can be set on more than one psi metric and more than one trigger
+for the same psi metric can be specified. However for each trigger a separate
+file descriptor is required to be able to poll it separately from others,
+therefore for each trigger a separate open() syscall should be made even
+when opening the same psi interface file.
+
+Monitors activate only when system enters stall state for the monitored
+psi metric and deactivates upon exit from the stall state. While system is
+in the stall state psi signal growth is monitored at a rate of 10 times per
+tracking window.
+
+The kernel accepts window sizes ranging from 500ms to 10s, therefore min
+monitoring update interval is 50ms and max is 1s.
+
+When activated, psi monitor stays active for at least the duration of one
+tracking window to avoid repeated activations/deactivations when system is
+bouncing in and out of the stall state.
+
+Notifications to the userspace are rate-limited to one per tracking window.
+
+The trigger will de-register when the file descriptor used to define the
+trigger  is closed.
+
+Userspace monitor usage example
+===============================
+
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <poll.h>
+#include <string.h>
+#include <unistd.h>
+
+/*
+ * Monitor memory partial stall with 1s tracking window size
+ * and 15% (150ms) threshold.
+ */
+int main() {
+	const char trig[] = "some 15% 1000000";
+	struct pollfd fds;
+	int n;
+
+	fds.fd = open("/proc/pressure/memory", O_RDWR | O_NONBLOCK);
+	if (fds.fd < 0) {
+		printf("/proc/pressure/memory open error: %s\n",
+			strerror(errno));
+		return 1;
+	}
+	fds.events = POLLPRI;
+
+	if (write(fds.fd, trig, strlen(trig) + 1) < 0) {
+		printf("/proc/pressure/memory write error: %s\n",
+			strerror(errno));
+		return 1;
+	}
+
+	printf("waiting for events...\n");
+	while (1) {
+		n = poll(&fds, 1, -1);
+		if (n < 0) {
+			printf("poll error: %s\n", strerror(errno));
+			return 1;
+		}
+		if (fds.revents & POLLERR) {
+			printf("got POLLERR, event source is gone\n");
+			return 0;
+		}
+		if (fds.revents & POLLPRI) {
+			printf("event triggered!\n");
+		} else {
+			printf("unknown event received: 0x%x\n", fds.revents);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 Cgroup2 interface
 =================
 
@@ -71,3 +173,6 @@ mounted, pressure stall information is also tracked for tasks grouped
 into cgroups. Each subdirectory in the cgroupfs mountpoint contains
 cpu.pressure, memory.pressure, and io.pressure files; the format is
 the same as the /proc/pressure/ files.
+
+Per-cgroup psi monitors can be specified and used the same way as
+system-wide ones.
diff --git a/include/linux/psi.h b/include/linux/psi.h
index 7006008d5b72..7490f8ef83ac 100644
--- a/include/linux/psi.h
+++ b/include/linux/psi.h
@@ -4,6 +4,7 @@
 #include <linux/jump_label.h>
 #include <linux/psi_types.h>
 #include <linux/sched.h>
+#include <linux/poll.h>
 
 struct seq_file;
 struct css_set;
@@ -26,6 +27,15 @@ int psi_show(struct seq_file *s, struct psi_group *group, enum psi_res res);
 int psi_cgroup_alloc(struct cgroup *cgrp);
 void psi_cgroup_free(struct cgroup *cgrp);
 void cgroup_move_task(struct task_struct *p, struct css_set *to);
+
+ssize_t psi_trigger_parse(char *buf, size_t nbytes, enum psi_res res,
+	enum psi_states *state, u32 *threshold_us, u32 *win_sz_us);
+struct psi_trigger *psi_trigger_create(struct psi_group *group,
+	enum psi_states state, u32 threshold_us, u32 win_sz_us);
+void psi_trigger_destroy(struct psi_trigger *t);
+
+__poll_t psi_trigger_poll(struct psi_trigger *t, struct file *file,
+			poll_table *wait);
 #endif
 
 #else /* CONFIG_PSI */
diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 11b32b3395a2..597c3c07d999 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -3,6 +3,7 @@
 
 #include <linux/seqlock.h>
 #include <linux/types.h>
+#include <linux/wait.h>
 
 #ifdef CONFIG_PSI
 
@@ -68,6 +69,63 @@ struct psi_group_cpu {
 	u32 times_prev[NR_PSI_STATES] ____cacheline_aligned_in_smp;
 };
 
+/*
+ * Aggregation clock mode
+ *
+ * REGULAR: Low-interval updates to flush the per-cpu time buckets
+ * SWITCHING: Transitioning from REGULAR to POLLING mode
+ * POLLING: High-frequency polling based on configured growth triggers
+ */
+enum psi_clock_mode {
+	PSI_CLOCK_REGULAR,
+	PSI_CLOCK_SWITCHING,
+	PSI_CLOCK_POLLING,
+};
+
+/* PSI growth tracking window */
+struct psi_window {
+	/* Window size in ns */
+	u64 size;
+
+	/* Start time of the current window in ns */
+	u64 start_time;
+
+	/* Value at the start of the window */
+	u64 start_value;
+
+	/* Value growth per previous window(s) */
+	u64 per_win_growth;
+};
+
+struct psi_trigger {
+	/* PSI state being monitored by the trigger */
+	enum psi_states state;
+
+	/* User-spacified threshold in ns */
+	u64 threshold;
+
+	/* List node inside triggers list */
+	struct list_head node;
+
+	/* Backpointer needed during trigger destruction */
+	struct psi_group *group;
+
+	/* Wait queue for polling */
+	wait_queue_head_t event_wait;
+
+	/* Pending event flag */
+	int event;
+
+	/* Tracking window */
+	struct psi_window win;
+
+	/*
+	 * Time last event was generated. Used for rate-limiting
+	 * events to one per window
+	 */
+	u64 last_event_time;
+};
+
 struct psi_group {
 	/* Protects data used by the aggregator */
 	struct mutex update_lock;
@@ -75,6 +133,8 @@ struct psi_group {
 	/* Per-cpu task state & time tracking */
 	struct psi_group_cpu __percpu *pcpu;
 
+	/* Periodic aggregation control */
+	enum psi_clock_mode clock_mode;
 	struct delayed_work clock_work;
 
 	/* Total stall times observed */
@@ -85,6 +145,18 @@ struct psi_group {
 	u64 avg_last_update;
 	u64 avg_next_update;
 	unsigned long avg[NR_PSI_STATES - 1][3];
+
+	/* Configured polling triggers */
+	struct list_head triggers;
+	u32 nr_triggers[NR_PSI_STATES - 1];
+	u32 trigger_mask;
+	u64 trigger_min_period;
+
+	/* Polling state */
+	/* Total stall times at the start of monitor activation */
+	u64 polling_total[NR_PSI_STATES - 1];
+	u64 polling_next_update;
+	u64 polling_until;
 };
 
 #else /* CONFIG_PSI */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index ffcd7483b8ee..c0d7fe0ca02e 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -3430,7 +3430,101 @@ static int cgroup_cpu_pressure_show(struct seq_file *seq, void *v)
 {
 	return psi_show(seq, &seq_css(seq)->cgroup->psi, PSI_CPU);
 }
-#endif
+
+static ssize_t cgroup_pressure_write(struct kernfs_open_file *of, char *buf,
+					  size_t nbytes, enum psi_res res)
+{
+	enum psi_states state;
+	struct psi_trigger *old;
+	struct psi_trigger *new;
+	struct cgroup *cgrp;
+	u32 threshold_us;
+	u32 win_sz_us;
+	ssize_t ret;
+
+	cgrp = cgroup_kn_lock_live(of->kn, false);
+	if (!cgrp)
+		return -ENODEV;
+
+	cgroup_get(cgrp);
+	cgroup_kn_unlock(of->kn);
+
+	ret = psi_trigger_parse(buf, nbytes, res,
+				&state, &threshold_us, &win_sz_us);
+	if (ret) {
+		cgroup_put(cgrp);
+		return ret;
+	}
+
+	new = psi_trigger_create(&cgrp->psi,
+				state, threshold_us, win_sz_us);
+	if (IS_ERR(new)) {
+		cgroup_put(cgrp);
+		return PTR_ERR(new);
+	}
+
+	old = of->priv;
+	rcu_assign_pointer(of->priv, new);
+	if (old) {
+		synchronize_rcu();
+		psi_trigger_destroy(old);
+	}
+
+	cgroup_put(cgrp);
+
+	return nbytes;
+}
+
+static ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_IO);
+}
+
+static ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_MEM);
+}
+
+static ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_CPU);
+}
+
+static __poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
+					  poll_table *pt)
+{
+	struct psi_trigger *t;
+	__poll_t ret;
+
+	rcu_read_lock();
+	t = rcu_dereference(of->priv);
+	if (t)
+		ret = psi_trigger_poll(t, of->file, pt);
+	else
+		ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+	rcu_read_unlock();
+
+	return ret;
+}
+
+static void cgroup_pressure_release(struct kernfs_open_file *of)
+{
+	struct psi_trigger *t = of->priv;
+
+	if (!t)
+		return;
+
+	rcu_assign_pointer(of->priv, NULL);
+	synchronize_rcu();
+	psi_trigger_destroy(t);
+}
+#endif /* CONFIG_PSI */
 
 static int cgroup_file_open(struct kernfs_open_file *of)
 {
@@ -4579,18 +4673,27 @@ static struct cftype cgroup_base_files[] = {
 		.name = "io.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_io_pressure_show,
+		.write = cgroup_io_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
 	{
 		.name = "memory.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_memory_pressure_show,
+		.write = cgroup_memory_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
 	{
 		.name = "cpu.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_cpu_pressure_show,
+		.write = cgroup_cpu_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
-#endif
+#endif /* CONFIG_PSI */
 	{ }	/* terminate */
 };
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 694edefdd333..4f0e2de5eded 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -4,6 +4,9 @@
  * Copyright (c) 2018 Facebook, Inc.
  * Author: Johannes Weiner <hannes@cmpxchg.org>
  *
+ * Polling support by Suren Baghdasaryan <surenb@google.com>
+ * Copyright (c) 2018 Google, Inc.
+ *
  * When CPU, memory and IO are contended, tasks experience delays that
  * reduce throughput and introduce latencies into the workload. Memory
  * and IO contention, in addition, can cause a full loss of forward
@@ -126,11 +129,16 @@
 
 #include <linux/sched/loadavg.h>
 #include <linux/seq_file.h>
+#include <linux/eventfd.h>
 #include <linux/proc_fs.h>
 #include <linux/seqlock.h>
+#include <linux/uaccess.h>
 #include <linux/cgroup.h>
 #include <linux/module.h>
 #include <linux/sched.h>
+#include <linux/ctype.h>
+#include <linux/file.h>
+#include <linux/poll.h>
 #include <linux/psi.h>
 #include "sched.h"
 
@@ -150,11 +158,16 @@ static int __init setup_psi(char *str)
 __setup("psi=", setup_psi);
 
 /* Running averages - we need to be higher-res than loadavg */
-#define PSI_FREQ	(2*HZ+1)	/* 2 sec intervals */
+#define PSI_FREQ	(2*HZ+1UL)	/* 2 sec intervals */
 #define EXP_10s		1677		/* 1/exp(2s/10s) as fixed-point */
 #define EXP_60s		1981		/* 1/exp(2s/60s) */
 #define EXP_300s	2034		/* 1/exp(2s/300s) */
 
+/* PSI trigger definitions */
+#define PSI_TRIG_MIN_WIN_US 500000		/* Min window size is 500ms */
+#define PSI_TRIG_MAX_WIN_US 10000000	/* Max window size is 10s */
+#define PSI_TRIG_UPDATES_PER_WIN 10		/* 10 updates per window */
+
 /* Sampling frequency in nanoseconds */
 static u64 psi_period __read_mostly;
 
@@ -173,8 +186,17 @@ static void group_init(struct psi_group *group)
 	for_each_possible_cpu(cpu)
 		seqcount_init(&per_cpu_ptr(group->pcpu, cpu)->seq);
 	group->avg_next_update = sched_clock() + psi_period;
+	group->clock_mode = PSI_CLOCK_REGULAR;
 	INIT_DELAYED_WORK(&group->clock_work, psi_update_work);
 	mutex_init(&group->update_lock);
+	/* Init trigger-related members */
+	INIT_LIST_HEAD(&group->triggers);
+	memset(group->nr_triggers, 0, sizeof(group->nr_triggers));
+	group->trigger_mask = 0;
+	group->trigger_min_period = U32_MAX;
+	memset(group->polling_total, 0, sizeof(group->polling_total));
+	group->polling_next_update = ULLONG_MAX;
+	group->polling_until = 0;
 }
 
 void __init psi_init(void)
@@ -260,16 +282,13 @@ static void calc_avgs(unsigned long avg[3], u64 time, u64 period)
 	avg[2] = calc_load(avg[2], EXP_300s, pct);
 }
 
-static void update_stats(struct psi_group *group)
+static void collect_percpu_times(struct psi_group *group)
 {
 	u64 deltas[NR_PSI_STATES - 1] = { 0, };
 	unsigned long nonidle_total = 0;
-	u64 now, expires, period;
 	int cpu;
 	int s;
 
-	mutex_lock(&group->update_lock);
-
 	/*
 	 * Collect the per-cpu time buckets and average them into a
 	 * single time sample that is normalized to wallclock time.
@@ -306,12 +325,16 @@ static void update_stats(struct psi_group *group)
 	/* total= */
 	for (s = 0; s < NR_PSI_STATES - 1; s++)
 		group->total[s] += div_u64(deltas[s], max(nonidle_total, 1UL));
+}
+
+static u64 calculate_averages(struct psi_group *group, u64 now)
+{
+	u64 expires, period;
+	u64 avg_next_update;
+	int s;
 
 	/* avgX= */
-	now = sched_clock();
 	expires = group->avg_next_update;
-	if (now < expires)
-		goto out;
 
 	/*
 	 * The periodic clock tick can get delayed for various
@@ -320,7 +343,7 @@ static void update_stats(struct psi_group *group)
 	 * But the deltas we sample out of the per-cpu buckets above
 	 * are based on the actual time elapsing between clock ticks.
 	 */
-	group->avg_next_update = expires + psi_period;
+	avg_next_update = expires + psi_period;
 	period = now - group->avg_last_update;
 	group->avg_last_update = now;
 
@@ -350,7 +373,152 @@ static void update_stats(struct psi_group *group)
 		group->avg_total[s] += sample;
 		calc_avgs(group->avg[s], sample, period);
 	}
-out:
+
+	return avg_next_update;
+}
+
+/* Trigger tracking window manupulations */
+static void window_init(struct psi_window *win, u64 now, u64 value)
+{
+	win->start_value = value;
+	win->start_time = now;
+	win->per_win_growth = 0;
+}
+
+/*
+ * PSI growth tracking window update and growth calculation routine.
+ * This approximates a sliding tracking window by interpolating
+ * partially elapsed windows using historical growth data from the
+ * previous intervals. This minimizes memory requirements (by not storing
+ * all the intermediate values in the previous window) and simplifies
+ * the calculations. It works well because PSI signal changes only in
+ * positive direction and over relatively small window sizes the growth
+ * is close to linear.
+ */
+static u64 window_update(struct psi_window *win, u64 now, u64 value)
+{
+	u64 interval;
+	u64 growth;
+
+	interval = now - win->start_time;
+	growth = value - win->start_value;
+	/*
+	 * After each tracking window passes win->start_value and
+	 * win->start_time get reset and win->per_win_growth stores
+	 * the average per-window growth of the previous window.
+	 * win->per_win_growth is then used to interpolate additional
+	 * growth from the previous window assuming it was linear.
+	 */
+	if (interval > win->size) {
+		win->per_win_growth = growth;
+		win->start_value = value;
+		win->start_time = now;
+	} else {
+		u32 unelapsed;
+
+		unelapsed = win->size - interval;
+		growth += div_u64(win->per_win_growth * unelapsed, win->size);
+	}
+
+	return growth;
+}
+
+static u64 poll_triggers(struct psi_group *group, u64 now)
+{
+	struct psi_trigger *t;
+	bool new_stall = false;
+
+	/*
+	 * On the first update, initialize the polling state.
+	 * Keep the monitor active for at least the duration of the
+	 * minimum tracking window. This prevents frequent changes to
+	 * clock_mode when system bounces in and out of stall states.
+	 */
+	if (cmpxchg(&group->clock_mode, PSI_CLOCK_SWITCHING,
+				PSI_CLOCK_POLLING) == PSI_CLOCK_SWITCHING) {
+		group->polling_until = now + group->trigger_min_period *
+				PSI_TRIG_UPDATES_PER_WIN;
+		list_for_each_entry(t, &group->triggers, node)
+			window_init(&t->win, now, group->total[t->state]);
+		memcpy(group->polling_total, group->total,
+				sizeof(group->polling_total));
+		goto out_next;
+
+	}
+
+	/*
+	 * On subsequent updates, calculate growth deltas and let
+	 * watchers know when their specified thresholds are exceeded.
+	 */
+	list_for_each_entry(t, &group->triggers, node) {
+		u64 growth;
+
+		/* Check for stall activity */
+		if (group->polling_total[t->state] == group->total[t->state])
+			continue;
+
+		/*
+		 * Multiple triggers might be looking at the same state,
+		 * remember to update group->polling_total[] once we've
+		 * been through all of them. Also remember to extend the
+		 * polling time if we see new stall activity.
+		 */
+		new_stall = true;
+
+		/* Calculate growth since last update */
+		growth = window_update(&t->win, now, group->total[t->state]);
+		if (growth < t->threshold)
+			continue;
+
+		/* Limit event signaling to once per window */
+		if (now < t->last_event_time + t->win.size)
+			continue;
+
+		/* Generate an event */
+		if (cmpxchg(&t->event, 0, 1) == 0)
+			wake_up_interruptible(&t->event_wait);
+		t->last_event_time = now;
+	}
+
+	if (new_stall) {
+		memcpy(group->polling_total, group->total,
+			   sizeof(group->polling_total));
+		group->polling_until = now +
+			(group->trigger_min_period * PSI_TRIG_UPDATES_PER_WIN);
+	}
+
+out_next:
+	/* No more new stall in the last window? Disable polling */
+	if (now >= group->polling_until) {
+		WARN_ONCE(group->clock_mode != PSI_CLOCK_POLLING,
+				"psi: invalid clock mode %d\n",
+				group->clock_mode);
+		group->clock_mode = PSI_CLOCK_REGULAR;
+		return ULLONG_MAX;
+	}
+
+	return now + group->trigger_min_period;
+}
+
+/*
+ * Update total stall, update averages if it's time,
+ * check all triggers if in polling state.
+ */
+static void psi_update(struct psi_group *group)
+{
+	u64 now;
+
+	mutex_lock(&group->update_lock);
+
+	collect_percpu_times(group);
+
+	now = sched_clock();
+	if (now >= group->avg_next_update)
+		group->avg_next_update = calculate_averages(group, now);
+
+	if (now >= group->polling_next_update)
+		group->polling_next_update = poll_triggers(group, now);
+
 	mutex_unlock(&group->update_lock);
 }
 
@@ -358,28 +526,23 @@ static void psi_update_work(struct work_struct *work)
 {
 	struct delayed_work *dwork;
 	struct psi_group *group;
-	unsigned long delay = 0;
-	u64 now;
+	u64 next_update;
 
 	dwork = to_delayed_work(work);
 	group = container_of(dwork, struct psi_group, clock_work);
 
 	/*
-	 * If there is task activity, periodically fold the per-cpu
-	 * times and feed samples into the running averages. If things
-	 * are idle and there is no data to process, stop the clock.
-	 * Once restarted, we'll catch up the running averages in one
-	 * go - see calc_avgs() and missed_periods.
+	 * Periodically fold the per-cpu times and feed samples
+	 * into the running averages.
 	 */
 
-	update_stats(group);
+	psi_update(group);
 
-	now = sched_clock();
-	if (group->avg_next_update > now) {
-		delay = nsecs_to_jiffies(
-				group->avg_next_update - now) + 1;
-	}
-	schedule_delayed_work(dwork, delay);
+	/* Calculate closest update time */
+	next_update = min(group->polling_next_update,
+				group->avg_next_update);
+	schedule_delayed_work(dwork, min(PSI_FREQ,
+		nsecs_to_jiffies(next_update - sched_clock()) + 1));
 }
 
 static void record_times(struct psi_group_cpu *groupc, int cpu,
@@ -475,6 +638,24 @@ static void psi_group_change(struct psi_group *group, int cpu,
 	groupc->state_mask = state_mask;
 
 	write_seqcount_end(&groupc->seq);
+
+	/*
+	 * If there is a trigger set on this state, make sure the
+	 * clock is in polling mode, or switches over right away.
+	 *
+	 * Monitor state changes into PSI_CLOCK_REGULAR at the max rate
+	 * of once per update window (no more than 500ms), therefore
+	 * below condition should happen relatively infrequently and
+	 * cpu cache invalidation rate should stay low.
+	 */
+	if ((state_mask & group->trigger_mask) &&
+		cmpxchg(&group->clock_mode, PSI_CLOCK_REGULAR,
+				PSI_CLOCK_SWITCHING) == PSI_CLOCK_REGULAR) {
+		group->polling_next_update = 0;
+		/* reschedule immediate update */
+		cancel_delayed_work(&group->clock_work);
+		schedule_delayed_work(&group->clock_work, 1);
+	}
 }
 
 static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
@@ -623,6 +804,8 @@ void psi_cgroup_free(struct cgroup *cgroup)
 
 	cancel_delayed_work_sync(&cgroup->psi.clock_work);
 	free_percpu(cgroup->psi.pcpu);
+	/* All triggers must be removed by now by psi_trigger_destroy */
+	WARN_ONCE(cgroup->psi.trigger_mask, "psi: trigger leak\n");
 }
 
 /**
@@ -682,7 +865,7 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 	if (static_branch_likely(&psi_disabled))
 		return -EOPNOTSUPP;
 
-	update_stats(group);
+	psi_update(group);
 
 	for (full = 0; full < 2 - (res == PSI_CPU); full++) {
 		unsigned long avg[3];
@@ -734,25 +917,296 @@ static int psi_cpu_open(struct inode *inode, struct file *file)
 	return single_open(file, psi_cpu_show, NULL);
 }
 
+ssize_t psi_trigger_parse(char *buf, size_t nbytes, enum psi_res res,
+	enum psi_states *state, u32 *threshold_us, u32 *win_sz_us)
+{
+	bool some;
+	bool threshold_pct;
+	u32 threshold;
+	u32 win_sz;
+	char *p;
+
+	p = strsep(&buf, " ");
+	if (p == NULL)
+		return -EINVAL;
+
+	/* parse type */
+	if (!strcmp(p, "some"))
+		some = true;
+	else if (!strcmp(p, "full"))
+		some = false;
+	else
+		return -EINVAL;
+
+	switch (res) {
+	case (PSI_IO):
+		*state = some ? PSI_IO_SOME : PSI_IO_FULL;
+		break;
+	case (PSI_MEM):
+		*state = some ? PSI_MEM_SOME : PSI_MEM_FULL;
+		break;
+	case (PSI_CPU):
+		if (!some)
+			return -EINVAL;
+		*state = PSI_CPU_SOME;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	while (isspace(*buf))
+		buf++;
+
+	p = strsep(&buf, "%");
+	if (p == NULL)
+		return -EINVAL;
+
+	if (buf == NULL) {
+		/* % sign was not found, threshold is specified in us */
+		buf = p;
+		p = strsep(&buf, " ");
+		if (p == NULL)
+			return -EINVAL;
+
+		threshold_pct = false;
+	} else
+		threshold_pct = true;
+
+	/* parse threshold */
+	if (kstrtouint(p, 0, &threshold))
+		return -EINVAL;
+
+	while (isspace(*buf))
+		buf++;
+
+	p = strsep(&buf, " ");
+	if (p == NULL)
+		return -EINVAL;
+
+	/* Parse window size */
+	if (kstrtouint(p, 0, &win_sz))
+		return -EINVAL;
+
+	/* Check window size */
+	if (win_sz < PSI_TRIG_MIN_WIN_US || win_sz > PSI_TRIG_MAX_WIN_US)
+		return -EINVAL;
+
+	if (threshold_pct)
+		threshold = (threshold * win_sz) / 100;
+
+	/* Check threshold */
+	if (threshold == 0 || threshold > win_sz)
+		return -EINVAL;
+
+	*threshold_us = threshold;
+	*win_sz_us = win_sz;
+
+	return 0;
+}
+
+struct psi_trigger *psi_trigger_create(struct psi_group *group,
+		enum psi_states state, u32 threshold_us, u32 win_sz_us)
+{
+	struct psi_trigger *t;
+
+	if (static_branch_likely(&psi_disabled))
+		return ERR_PTR(-EOPNOTSUPP);
+
+	t = kzalloc(sizeof(*t), GFP_KERNEL);
+	if (!t)
+		return ERR_PTR(-ENOMEM);
+
+	t->group = group;
+	t->state = state;
+	t->threshold = threshold_us * NSEC_PER_USEC;
+	t->win.size = win_sz_us * NSEC_PER_USEC;
+	t->event = 0;
+	init_waitqueue_head(&t->event_wait);
+
+	mutex_lock(&group->update_lock);
+
+	list_add(&t->node, &group->triggers);
+	group->trigger_min_period = min(group->trigger_min_period,
+		t->win.size / PSI_TRIG_UPDATES_PER_WIN);
+	group->nr_triggers[t->state]++;
+	group->trigger_mask |= (1 << t->state);
+
+	mutex_unlock(&group->update_lock);
+
+	return t;
+}
+
+void psi_trigger_destroy(struct psi_trigger *t)
+{
+	struct psi_group *group = t->group;
+
+	if (static_branch_likely(&psi_disabled))
+		return;
+
+	mutex_lock(&group->update_lock);
+	if (!list_empty(&t->node)) {
+		struct psi_trigger *tmp;
+		u64 period = ULLONG_MAX;
+
+		list_del_init(&t->node);
+		group->nr_triggers[t->state]--;
+		if (!group->nr_triggers[t->state])
+			group->trigger_mask &= ~(1 << t->state);
+		/* reset min update period for the remaining triggers */
+		list_for_each_entry(tmp, &group->triggers, node) {
+			period = min(period,
+				tmp->win.size / PSI_TRIG_UPDATES_PER_WIN);
+		}
+		group->trigger_min_period = period;
+		/*
+		 * Wakeup waiters to stop polling.
+		 * Can happen if cgroup is deleted from under
+		 * a polling process.
+		 */
+		wake_up_interruptible(&t->event_wait);
+		kfree(t);
+	}
+	mutex_unlock(&group->update_lock);
+}
+
+__poll_t psi_trigger_poll(struct psi_trigger *t,
+				struct file *file, poll_table *wait)
+{
+	if (static_branch_likely(&psi_disabled))
+		return DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+
+	poll_wait(file, &t->event_wait, wait);
+
+	if (cmpxchg(&t->event, 1, 0) == 1)
+		return DEFAULT_POLLMASK | EPOLLPRI;
+
+	/* Wait */
+	return DEFAULT_POLLMASK;
+}
+
+static ssize_t psi_write(struct file *file, const char __user *user_buf,
+				size_t nbytes, enum psi_res res)
+{
+	char buf[32];
+	size_t buf_size;
+	struct seq_file *seq;
+	struct psi_trigger *old;
+	struct psi_trigger *new;
+	enum psi_states state;
+	u32 threshold_us;
+	u32 win_sz_us;
+	ssize_t ret;
+
+	if (static_branch_likely(&psi_disabled))
+		return -EOPNOTSUPP;
+
+	buf_size = min(nbytes, (sizeof(buf) - 1));
+	if (copy_from_user(buf, user_buf, buf_size))
+		return -EFAULT;
+
+	buf[buf_size - 1] = '\0';
+
+	ret = psi_trigger_parse(buf, nbytes, res,
+				&state, &threshold_us, &win_sz_us);
+	if (ret < 0)
+		return ret;
+
+	new = psi_trigger_create(&psi_system,
+					state, threshold_us, win_sz_us);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+
+	seq = file->private_data;
+	/* Take seq->lock to protect seq->private from concurrent writes */
+	mutex_lock(&seq->lock);
+	old = seq->private;
+	rcu_assign_pointer(seq->private, new);
+	mutex_unlock(&seq->lock);
+
+	if (old) {
+		synchronize_rcu();
+		psi_trigger_destroy(old);
+	}
+
+	return nbytes;
+}
+
+static ssize_t psi_io_write(struct file *file,
+		const char __user *user_buf, size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_IO);
+}
+
+static ssize_t psi_memory_write(struct file *file,
+		const char __user *user_buf, size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_MEM);
+}
+
+static ssize_t psi_cpu_write(struct file *file,
+		const char __user *user_buf, size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_CPU);
+}
+
+static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
+{
+	struct seq_file *seq = file->private_data;
+	struct psi_trigger *t;
+	__poll_t ret;
+
+	rcu_read_lock();
+	t = rcu_dereference(seq->private);
+	if (t)
+		ret = psi_trigger_poll(t, file, wait);
+	else
+		ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+	rcu_read_unlock();
+
+	return ret;
+
+}
+
+static int psi_fop_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct psi_trigger *t = seq->private;
+
+	if (static_branch_likely(&psi_disabled) || !t)
+		goto out;
+
+	rcu_assign_pointer(seq->private, NULL);
+	synchronize_rcu();
+	psi_trigger_destroy(t);
+out:
+	return single_release(inode, file);
+}
+
 static const struct file_operations psi_io_fops = {
 	.open           = psi_io_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_io_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static const struct file_operations psi_memory_fops = {
 	.open           = psi_memory_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_memory_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static const struct file_operations psi_cpu_fops = {
 	.open           = psi_cpu_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_cpu_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static int __init psi_late_init(void)
-- 
2.20.0.405.gbc1bbc6f85-goog
