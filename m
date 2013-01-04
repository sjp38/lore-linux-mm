Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id CA0386B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 03:32:58 -0500 (EST)
Received: by mail-gh0-f169.google.com with SMTP id r11so1928707ghr.14
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 00:32:57 -0800 (PST)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 1/2] Add mempressure cgroup
Date: Fri,  4 Jan 2013 00:29:11 -0800
Message-Id: <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20130104082751.GA22227@lizard.gateway.2wire.net>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

This commit implements David Rientjes' idea of mempressure cgroup.

The main characteristics are the same to what I've tried to add to vmevent
API; internally, it uses Mel Gorman's idea of scanned/reclaimed ratio for
pressure index calculation. But we don't expose the index to the userland.
Instead, there are three levels of the pressure:

 o low (just reclaiming, e.g. caches are draining);
 o medium (allocation cost becomes high, e.g. swapping);
 o oom (about to oom very soon).

The rationale behind exposing levels and not the raw pressure index
described here: http://lkml.org/lkml/2012/11/16/675

For a task it is possible to be in both cpusets, memcg and mempressure
cgroups, so by rearranging the tasks it is possible to watch a specific
pressure (i.e. caused by cpuset and/or memcg).

Note that while this adds the cgroups support, the code is well separated
and eventually we might add a lightweight, non-cgroups API, i.e. vmevent.
But this is another story.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 Documentation/cgroups/mempressure.txt |  50 ++++++
 include/linux/cgroup_subsys.h         |   6 +
 include/linux/vmstat.h                |  11 ++
 init/Kconfig                          |  12 ++
 mm/Makefile                           |   1 +
 mm/mempressure.c                      | 330 ++++++++++++++++++++++++++++++++++
 mm/vmscan.c                           |   4 +
 7 files changed, 414 insertions(+)
 create mode 100644 Documentation/cgroups/mempressure.txt
 create mode 100644 mm/mempressure.c

diff --git a/Documentation/cgroups/mempressure.txt b/Documentation/cgroups/mempressure.txt
new file mode 100644
index 0000000..dbc0aca
--- /dev/null
+++ b/Documentation/cgroups/mempressure.txt
@@ -0,0 +1,50 @@
+  Memory pressure cgroup
+~~~~~~~~~~~~~~~~~~~~~~~~~~
+  Before using the mempressure cgroup, make sure you have it mounted:
+
+   # cd /sys/fs/cgroup/
+   # mkdir mempressure
+   # mount -t cgroup cgroup ./mempressure -o mempressure
+
+  It is possible to combine cgroups, for example you can mount memory
+  (memcg) and mempressure cgroups together:
+
+   # mount -t cgroup cgroup ./mempressure -o memory,mempressure
+
+  That way the reported pressure will honour memory cgroup limits. The
+  same goes for cpusets.
+
+  After the hierarchy is mounted, you can use the following API:
+
+  /sys/fs/cgroup/.../mempressure.level
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+  To maintain the interactivity/memory allocation cost, one can use the
+  pressure level notifications, and the levels are defined like this:
+
+  The "low" level means that the system is reclaiming memory for new
+  allocations. Monitoring reclaiming activity might be useful for
+  maintaining overall system's cache level. Upon notification, the program
+  (typically "Activity Manager") might analyze vmstat and act in advance
+  (i.e. prematurely shutdown unimportant services).
+
+  The "medium" level means that the system is experiencing medium memory
+  pressure, there is some mild swapping activity. Upon this event
+  applications may decide to free any resources that can be easily
+  reconstructed or re-read from a disk.
+
+  The "oom" level means that the system is actively thrashing, it is about
+  to out of memory (OOM) or even the in-kernel OOM killer is on its way to
+  trigger. Applications should do whatever they can to help the system.
+
+  Event control:
+    Is used to setup an eventfd with a level threshold. The argument to
+    the event control specifies the level threshold.
+  Read:
+    Reads mempory presure levels: low, medium or oom.
+  Write:
+    Not implemented.
+  Test:
+    To set up a notification:
+
+    # cgroup_event_listener ./mempressure.level low
+    ("low", "medium", "oom" are permitted.)
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index f204a7a..b9802e2 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -37,6 +37,12 @@ SUBSYS(mem_cgroup)
 
 /* */
 
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_MEMPRESSURE)
+SUBSYS(mpc_cgroup)
+#endif
+
+/* */
+
 #if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEVICE)
 SUBSYS(devices)
 #endif
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index a13291f..c1a66c7 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -10,6 +10,17 @@
 
 extern int sysctl_stat_interval;
 
+struct mem_cgroup;
+#ifdef CONFIG_CGROUP_MEMPRESSURE
+extern void vmpressure(struct mem_cgroup *memcg,
+		       ulong scanned, ulong reclaimed);
+extern void vmpressure_prio(struct mem_cgroup *memcg, int prio);
+#else
+static inline void vmpressure(struct mem_cgroup *memcg,
+			      ulong scanned, ulong reclaimed) {}
+static inline void vmpressure_prio(struct mem_cgroup *memcg, int prio) {}
+#endif
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 /*
  * Light weight per cpu counter implementation.
diff --git a/init/Kconfig b/init/Kconfig
index 7d30240..d526249 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -891,6 +891,18 @@ config MEMCG_KMEM
 	  the kmem extension can use it to guarantee that no group of processes
 	  will ever exhaust kernel resources alone.
 
+config CGROUP_MEMPRESSURE
+	bool "Memory pressure monitor for Control Groups"
+	help
+	  The memory pressure monitor cgroup provides a facility for
+	  userland programs so that they could easily assist the kernel
+	  with the memory management. So far the API provides simple,
+	  levels-based memory pressure notifications.
+
+	  For more information see Documentation/cgroups/mempressure.txt
+
+	  If unsure, say N.
+
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS && HUGETLB_PAGE && EXPERIMENTAL
diff --git a/mm/Makefile b/mm/Makefile
index 3a46287..e69bbda 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -51,6 +51,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
 obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_MEMPRESSURE) += mempressure.o
 obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
diff --git a/mm/mempressure.c b/mm/mempressure.c
new file mode 100644
index 0000000..ea312bb
--- /dev/null
+++ b/mm/mempressure.c
@@ -0,0 +1,330 @@
+/*
+ * Linux VM pressure
+ *
+ * Copyright 2012 Linaro Ltd.
+ *		  Anton Vorontsov <anton.vorontsov@linaro.org>
+ *
+ * Based on ideas from Andrew Morton, David Rientjes, KOSAKI Motohiro,
+ * Leonid Moiseichuk, Mel Gorman, Minchan Kim and Pekka Enberg.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/vmstat.h>
+#include <linux/eventfd.h>
+#include <linux/swap.h>
+#include <linux/printk.h>
+
+static void mpc_vmpressure(struct mem_cgroup *memcg, ulong s, ulong r);
+
+/*
+ * Generic VM Pressure routines (no cgroups or any other API details)
+ */
+
+/*
+ * The window size is the number of scanned pages before we try to analyze
+ * the scanned/reclaimed ratio (or difference).
+ *
+ * It is used as a rate-limit tunable for the "low" level notification,
+ * and for averaging medium/oom levels. Using small window sizes can cause
+ * lot of false positives, but too big window size will delay the
+ * notifications.
+ */
+static const uint vmpressure_win = SWAP_CLUSTER_MAX * 16;
+static const uint vmpressure_level_med = 60;
+static const uint vmpressure_level_oom = 99;
+static const uint vmpressure_level_oom_prio = 4;
+
+enum vmpressure_levels {
+	VMPRESSURE_LOW = 0,
+	VMPRESSURE_MEDIUM,
+	VMPRESSURE_OOM,
+	VMPRESSURE_NUM_LEVELS,
+};
+
+static const char *vmpressure_str_levels[] = {
+	[VMPRESSURE_LOW] = "low",
+	[VMPRESSURE_MEDIUM] = "medium",
+	[VMPRESSURE_OOM] = "oom",
+};
+
+static enum vmpressure_levels vmpressure_level(uint pressure)
+{
+	if (pressure >= vmpressure_level_oom)
+		return VMPRESSURE_OOM;
+	else if (pressure >= vmpressure_level_med)
+		return VMPRESSURE_MEDIUM;
+	return VMPRESSURE_LOW;
+}
+
+static ulong vmpressure_calc_level(uint win, uint s, uint r)
+{
+	ulong p;
+
+	if (!s)
+		return 0;
+
+	/*
+	 * We calculate the ratio (in percents) of how many pages were
+	 * scanned vs. reclaimed in a given time frame (window). Note that
+	 * time is in VM reclaimer's "ticks", i.e. number of pages
+	 * scanned. This makes it possible to set desired reaction time
+	 * and serves as a ratelimit.
+	 */
+	p = win - (r * win / s);
+	p = p * 100 / win;
+
+	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, p, s, r);
+
+	return vmpressure_level(p);
+}
+
+void vmpressure(struct mem_cgroup *memcg, ulong scanned, ulong reclaimed)
+{
+	if (!scanned)
+		return;
+	mpc_vmpressure(memcg, scanned, reclaimed);
+}
+
+void vmpressure_prio(struct mem_cgroup *memcg, int prio)
+{
+	if (prio > vmpressure_level_oom_prio)
+		return;
+
+	/* OK, the prio is below the threshold, send the pre-OOM event. */
+	vmpressure(memcg, vmpressure_win, 0);
+}
+
+/*
+ * Memory pressure cgroup code
+ */
+
+struct mpc_event {
+	struct eventfd_ctx *efd;
+	enum vmpressure_levels level;
+	struct list_head node;
+};
+
+struct mpc_state {
+	struct cgroup_subsys_state css;
+
+	uint scanned;
+	uint reclaimed;
+	struct mutex sr_lock;
+
+	struct list_head events;
+	struct mutex events_lock;
+
+	struct work_struct work;
+};
+
+static struct mpc_state *wk2mpc(struct work_struct *wk)
+{
+	return container_of(wk, struct mpc_state, work);
+}
+
+static struct mpc_state *css2mpc(struct cgroup_subsys_state *css)
+{
+	return container_of(css, struct mpc_state, css);
+}
+
+static struct mpc_state *tsk2mpc(struct task_struct *tsk)
+{
+	return css2mpc(task_subsys_state(tsk, mpc_cgroup_subsys_id));
+}
+
+static struct mpc_state *cg2mpc(struct cgroup *cg)
+{
+	return css2mpc(cgroup_subsys_state(cg, mpc_cgroup_subsys_id));
+}
+
+static void mpc_event(struct mpc_state *mpc, ulong s, ulong r)
+{
+	struct mpc_event *ev;
+	int level = vmpressure_calc_level(vmpressure_win, s, r);
+
+	mutex_lock(&mpc->events_lock);
+
+	list_for_each_entry(ev, &mpc->events, node) {
+		if (level >= ev->level)
+			eventfd_signal(ev->efd, 1);
+	}
+
+	mutex_unlock(&mpc->events_lock);
+}
+
+static void mpc_vmpressure_wk_fn(struct work_struct *wk)
+{
+	struct mpc_state *mpc = wk2mpc(wk);
+	ulong s;
+	ulong r;
+
+	mutex_lock(&mpc->sr_lock);
+	s = mpc->scanned;
+	r = mpc->reclaimed;
+	mpc->scanned = 0;
+	mpc->reclaimed = 0;
+	mutex_unlock(&mpc->sr_lock);
+
+	mpc_event(mpc, s, r);
+}
+
+static void __mpc_vmpressure(struct mpc_state *mpc, ulong s, ulong r)
+{
+	mutex_lock(&mpc->sr_lock);
+	mpc->scanned += s;
+	mpc->reclaimed += r;
+	mutex_unlock(&mpc->sr_lock);
+
+	if (s < vmpressure_win || work_pending(&mpc->work))
+		return;
+
+	schedule_work(&mpc->work);
+}
+
+static void mpc_vmpressure(struct mem_cgroup *memcg, ulong s, ulong r)
+{
+	/*
+	 * There are two options for implementing cgroup pressure
+	 * notifications:
+	 *
+	 * - Store pressure counter atomically in the task struct. Upon
+	 *   hitting 'window' wake up a workqueue that will walk every
+	 *   task and sum per-thread pressure into cgroup pressure (to
+	 *   which the task belongs). The cons are obvious: bloats task
+	 *   struct, have to walk all processes and makes pressue less
+	 *   accurate (the window becomes per-thread);
+	 *
+	 * - Store pressure counters in per-cgroup state. This is easy and
+	 *   straightforward, and that's how we do things here. But this
+	 *   requires us to not put the vmpressure hooks into hotpath,
+	 *   since we have to grab some locks.
+	 */
+
+#ifdef CONFIG_MEMCG
+	if (memcg) {
+		struct cgroup_subsys_state *css = mem_cgroup_css(memcg);
+		struct cgroup *cg = css->cgroup;
+		struct mpc_state *mpc = cg2mpc(cg);
+
+		if (mpc)
+			__mpc_vmpressure(mpc, s, r);
+		return;
+	}
+#endif
+	task_lock(current);
+	__mpc_vmpressure(tsk2mpc(current), s, r);
+	task_unlock(current);
+}
+
+static struct cgroup_subsys_state *mpc_css_alloc(struct cgroup *cg)
+{
+	struct mpc_state *mpc;
+
+	mpc = kzalloc(sizeof(*mpc), GFP_KERNEL);
+	if (!mpc)
+		return ERR_PTR(-ENOMEM);
+
+	mutex_init(&mpc->sr_lock);
+	mutex_init(&mpc->events_lock);
+	INIT_LIST_HEAD(&mpc->events);
+	INIT_WORK(&mpc->work, mpc_vmpressure_wk_fn);
+
+	return &mpc->css;
+}
+
+static void mpc_css_free(struct cgroup *cg)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+
+	kfree(mpc);
+}
+
+static ssize_t mpc_read_level(struct cgroup *cg, struct cftype *cft,
+			      struct file *file, char __user *buf,
+			      size_t sz, loff_t *ppos)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	uint level;
+	const char *str;
+
+	mutex_lock(&mpc->sr_lock);
+
+	level = vmpressure_calc_level(vmpressure_win,
+			mpc->scanned, mpc->reclaimed);
+
+	mutex_unlock(&mpc->sr_lock);
+
+	str = vmpressure_str_levels[level];
+	return simple_read_from_buffer(buf, sz, ppos, str, strlen(str));
+}
+
+static int mpc_register_level(struct cgroup *cg, struct cftype *cft,
+			      struct eventfd_ctx *eventfd, const char *args)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	struct mpc_event *ev;
+	int lvl;
+
+	for (lvl = 0; lvl < VMPRESSURE_NUM_LEVELS; lvl++) {
+		if (!strcmp(vmpressure_str_levels[lvl], args))
+			break;
+	}
+
+	if (lvl >= VMPRESSURE_NUM_LEVELS)
+		return -EINVAL;
+
+	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
+	if (!ev)
+		return -ENOMEM;
+
+	ev->efd = eventfd;
+	ev->level = lvl;
+
+	mutex_lock(&mpc->events_lock);
+	list_add(&ev->node, &mpc->events);
+	mutex_unlock(&mpc->events_lock);
+
+	return 0;
+}
+
+static void mpc_unregister_level(struct cgroup *cg, struct cftype *cft,
+				 struct eventfd_ctx *eventfd)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	struct mpc_event *ev;
+
+	mutex_lock(&mpc->events_lock);
+	list_for_each_entry(ev, &mpc->events, node) {
+		if (ev->efd != eventfd)
+			continue;
+		list_del(&ev->node);
+		kfree(ev);
+		break;
+	}
+	mutex_unlock(&mpc->events_lock);
+}
+
+static struct cftype mpc_files[] = {
+	{
+		.name = "level",
+		.read = mpc_read_level,
+		.register_event = mpc_register_level,
+		.unregister_event = mpc_unregister_level,
+	},
+	{},
+};
+
+struct cgroup_subsys mpc_cgroup_subsys = {
+	.name = "mempressure",
+	.subsys_id = mpc_cgroup_subsys_id,
+	.css_alloc = mpc_css_alloc,
+	.css_free = mpc_css_free,
+	.base_cftypes = mpc_files,
+};
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 16b42af..fed0e04 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1900,6 +1900,9 @@ restart:
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 
+	vmpressure(sc->target_mem_cgroup,
+		   sc->nr_scanned - nr_scanned, nr_reclaimed);
+
 	/* reclaim/compaction might need reclaim to continue */
 	if (should_continue_reclaim(lruvec, nr_reclaimed,
 				    sc->nr_scanned - nr_scanned, sc))
@@ -2122,6 +2125,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		count_vm_event(ALLOCSTALL);
 
 	do {
+		vmpressure_prio(sc->target_mem_cgroup, sc->priority);
 		sc->nr_scanned = 0;
 		aborted_reclaim = shrink_zones(zonelist, sc);
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
