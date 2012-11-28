Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 68C106B0062
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 05:32:29 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so10156736pbc.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 02:32:28 -0800 (PST)
Date: Wed, 28 Nov 2012 02:29:08 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC] Add mempressure cgroup
Message-ID: <20121128102908.GA15415@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

This is an attempt to implement David Rientjes' idea of mempressure
cgroup.

The main characteristics are the same to what I've tried to add to vmevent
API:

  Internally, it uses Mel Gorman's idea of scanned/reclaimed ratio for
  pressure index calculation. But we don't expose the index to the
  userland. Instead, there are three levels of the pressure:

  o low (just reclaiming, e.g. caches are draining);
  o medium (allocation cost becomes high, e.g. swapping);
  o oom (about to oom very soon).

  The rationale behind exposing levels and not the raw pressure index
  described here: http://lkml.org/lkml/2012/11/16/675

The API uses standard cgroups eventfd notifications:

  $ gcc Documentation/cgroups/cgroup_event_listener.c -o \
	cgroup_event_listener
  $ cd /sys/fs/cgroup/
  $ mkdir mempressure
  $ mount -t cgroup cgroup ./mempressure -o mempressure
  $ cd mempressure
  $ cgroup_event_listener ./mempressure.level low
  ("low", "medium", "oom" are permitted values.)

  Upon hitting the threshold, you should see "/sys/fs/cgroup/mempressure
  low: crossed" messages.

To test that it actually works on per-cgroup basis, I did a small trick: I
moved all kswapd into a separate cgroup, and hooked the listener onto
another (non-root) cgroup. The listener no longer received global reclaim
pressure, which is expected.

For a task it is possible to be in both cpusets, memcg and mempressure
cgroups, so by rearranging the tasks it should be possible to watch a
specific pressure.

Note that while this adds the cgroups support, the code is well separated
and eventually we might add a lightweight, non-cgroups API, i.e. vmevent.
But this is another story.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/cgroup_subsys.h |   6 +
 include/linux/vmstat.h        |   8 ++
 init/Kconfig                  |   5 +
 mm/Makefile                   |   1 +
 mm/mempressure.c              | 287 ++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                   |   3 +
 6 files changed, 310 insertions(+)
 create mode 100644 mm/mempressure.c

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
index 92a86b2..7698341 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -10,6 +10,14 @@
 
 extern int sysctl_stat_interval;
 
+#ifdef CONFIG_CGROUP_MEMPRESSURE
+extern void vmpressure(ulong scanned, ulong reclaimed);
+extern void vmpressure_prio(int prio);
+#else
+static inline void vmpressure(ulong scanned, ulong reclaimed) {}
+static inline void vmpressure_prio(int prio) {}
+#endif
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 /*
  * Light weight per cpu counter implementation.
diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..7065e44 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -826,6 +826,11 @@ config MEMCG_KMEM
 	  the kmem extension can use it to guarantee that no group of processes
 	  will ever exhaust kernel resources alone.
 
+config CGROUP_MEMPRESSURE
+	bool "Memory pressure monitor for Control Groups"
+	help
+	  TODO
+
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS && HUGETLB_PAGE && EXPERIMENTAL
diff --git a/mm/Makefile b/mm/Makefile
index 6b025f8..40cee19 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
 obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_MEMPRESSURE) += mempressure.o
 obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
diff --git a/mm/mempressure.c b/mm/mempressure.c
new file mode 100644
index 0000000..5c85bbe
--- /dev/null
+++ b/mm/mempressure.c
@@ -0,0 +1,287 @@
+/*
+ * Linux VM pressure notifications
+ *
+ * Copyright 2012 Linaro Ltd.
+ *		  Anton Vorontsov <anton.vorontsov@linaro.org>
+ *
+ * Based on ideas from David Rientjes, KOSAKI Motohiro, Leonid Moiseichuk,
+ * Mel Gorman, Minchan Kim and Pekka Enberg.
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
+#include <linux/atomic.h>
+#include <linux/eventfd.h>
+#include <linux/swap.h>
+#include <linux/printk.h>
+
+static void mpc_vmpressure(ulong scanned, ulong reclaimed);
+
+/*
+ * Generic VM Pressure routines (no cgroups or any other API details)
+ */
+
+/* These are defaults. Might make them configurable one day. */
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
+static const char const *vmpressure_str_levels[] = {
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
+void vmpressure(ulong scanned, ulong reclaimed)
+{
+	if (!scanned)
+		return;
+	mpc_vmpressure(scanned, reclaimed);
+}
+
+void vmpressure_prio(int prio)
+{
+	if (prio > vmpressure_level_oom_prio)
+		return;
+
+	/* OK, the prio is below the threshold, send the pre-OOM event. */
+	vmpressure(vmpressure_win, 0);
+}
+
+/*
+ * Memory pressure cgroup code
+ */
+
+struct mpc_state {
+	struct cgroup_subsys_state css;
+	uint scanned;
+	uint reclaimed;
+	struct mutex lock;
+	struct eventfd_ctx *eventfd;
+	enum vmpressure_levels thres;
+};
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
+static void __mpc_vmpressure(ulong scanned, ulong reclaimed)
+{
+	struct mpc_state *mpc = tsk2mpc(current);
+	int level;
+
+	mpc->scanned += scanned;
+	mpc->reclaimed += reclaimed;
+
+	if (mpc->scanned < vmpressure_win)
+		return;
+
+	level = vmpressure_calc_level(vmpressure_win,
+			mpc->scanned, mpc->reclaimed);
+	if (level >= mpc->thres) {
+		mutex_lock(&mpc->lock);
+		if (mpc->eventfd)
+			eventfd_signal(mpc->eventfd, 1);
+		mutex_unlock(&mpc->lock);
+	}
+}
+
+static void mpc_vmpressure(ulong scanned, ulong reclaimed)
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
+	 *   straighforward, and that's how we do things here. But this
+	 *   requires us to not put the vmpressure hooks into hotpath,
+	 *   since we have to grab some locks.
+	 */
+	task_lock(current);
+	__mpc_vmpressure(scanned, reclaimed);
+	task_unlock(current);
+}
+
+static struct cgroup_subsys_state *mpc_create(struct cgroup *cg)
+{
+	struct mpc_state *mpc;
+
+	mpc = kzalloc(sizeof(*mpc), GFP_KERNEL);
+	if (!mpc)
+		return ERR_PTR(-ENOMEM);
+
+	mutex_init(&mpc->lock);
+
+	return &mpc->css;
+}
+
+static int mpc_pre_destroy(struct cgroup *cg)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	int ret = 0;
+
+	mutex_lock(&mpc->lock);
+
+	if (mpc->eventfd)
+		ret = -EBUSY;
+
+	mutex_unlock(&mpc->lock);
+
+	return ret;
+}
+
+static void mpc_destroy(struct cgroup *cg)
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
+	mutex_lock(&mpc->lock);
+
+	level = vmpressure_calc_level(vmpressure_win,
+			mpc->scanned, mpc->reclaimed);
+	mpc->scanned = 0;
+	mpc->reclaimed = 0;
+
+	mutex_unlock(&mpc->lock);
+
+	str = vmpressure_str_levels[level];
+	return simple_read_from_buffer(buf, sz, ppos, str, strlen(str));
+}
+
+static int mpc_register_level_event(struct cgroup *cg, struct cftype *cft,
+				    struct eventfd_ctx *eventfd,
+				    const char *args)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	int i;
+	int ret;
+
+	mutex_lock(&mpc->lock);
+
+	/*
+	 * It's easy to implement multiple thresholds, but so far we don't
+	 * need it.
+	 */
+	if (mpc->eventfd) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	ret = -EINVAL;
+	for (i = 0; i < VMPRESSURE_NUM_LEVELS; i++) {
+		if (strcmp(vmpressure_str_levels[i], args))
+			continue;
+		mpc->eventfd = eventfd;
+		mpc->thres = i;
+		ret = 0;
+		break;
+	}
+out_unlock:
+	mutex_unlock(&mpc->lock);
+
+	return ret;
+}
+
+static void mpc_unregister_level_event(struct cgroup *cg, struct cftype *cft,
+				       struct eventfd_ctx *eventfd)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+
+	mutex_lock(&mpc->lock);
+	BUG_ON(mpc->eventfd != eventfd);
+	mpc->eventfd = NULL;
+	mutex_unlock(&mpc->lock);
+}
+
+static struct cftype mpc_files[] = {
+	{
+		.name = "level",
+		.read = mpc_read_level,
+		.register_event = mpc_register_level_event,
+		.unregister_event = mpc_unregister_level_event,
+	},
+	{},
+};
+
+struct cgroup_subsys mpc_cgroup_subsys = {
+	.name = "mempressure",
+	.subsys_id = mpc_cgroup_subsys_id,
+	.create = mpc_create,
+	.pre_destroy = mpc_pre_destroy,
+	.destroy = mpc_destroy,
+	.base_cftypes = mpc_files,
+};
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 48550c6..430d8a5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1877,6 +1877,8 @@ restart:
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 
+	vmpressure(sc->nr_scanned - nr_scanned, nr_reclaimed);
+
 	/* reclaim/compaction might need reclaim to continue */
 	if (should_continue_reclaim(lruvec, nr_reclaimed,
 				    sc->nr_scanned - nr_scanned, sc))
@@ -2099,6 +2101,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		count_vm_event(ALLOCSTALL);
 
 	do {
+		vmpressure_prio(sc->priority);
 		sc->nr_scanned = 0;
 		aborted_reclaim = shrink_zones(zonelist, sc);
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
