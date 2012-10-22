Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id EFD496B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 07:24:47 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1426097dad.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:24:47 -0700 (PDT)
Date: Mon, 22 Oct 2012 04:21:49 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC 1/2] vmevent: Implement pressure attribute
Message-ID: <20121022112149.GA29325@lizard>
References: <20121022111928.GA12396@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121022111928.GA12396@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

This patch introduces VMEVENT_ATTR_PRESSURE, the attribute reports Linux
virtual memory management pressure. There are three discrete levels:

VMEVENT_PRESSURE_LOW: Notifies that the system is reclaiming memory for
new allocations. Monitoring reclaiming activity might be useful for
maintaining overall system's cache level.

VMEVENT_PRESSURE_MED: The system is experiencing medium memory pressure,
there is some mild swapping activity. Upon this event applications may
decide to free any resources that can be easily reconstructed or re-read
from a disk.

VMEVENT_PRESSURE_OOM: The system is actively thrashing, it is about to out
of memory (OOM) or even the in-kernel OOM killer is on its way to trigger.
Applications should do whatever they can to help the system.

There are three sysctls to tune the behaviour of the levels:

  vmevent_window
  vmevent_level_med
  vmevent_level_oom

Currently vmevent pressure levels are based on the reclaimer inefficiency
index (range from 0 to 100). The index shows the relative time spent by
the kernel uselessly scanning pages, or, in other words, the percentage of
scans of pages (vmevent_window) that were not reclaimed. The higher the
index, the more it should be evident that new allocations' cost becomes
higher.

The files vmevent_level_med and vmevent_level_oom accept the index values
(by default set to 60 and 99 respectively). A non-existent
vmevent_level_low tunable is always set to 0

When index equals to 0, this means that the kernel is reclaiming, but
every scanned page has been successfully reclaimed (so the pressure is
low). 100 means that the kernel is trying to reclaim, but nothing can be
reclaimed (close to OOM).

Window size is used as a rate-limit tunable for VMEVENT_PRESSURE_LOW
notifications and for averaging for VMEVENT_PRESSURE_{MED,OOM} levels. So,
using small window sizes can cause lot of false positives for _MED and
_OOM levels, but too big window size may delay notifications.

By default the window size equals to 256 pages (1MB).

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 Documentation/sysctl/vm.txt |  37 +++++++++++++++
 include/linux/vmevent.h     |  42 +++++++++++++++++
 kernel/sysctl.c             |  24 ++++++++++
 mm/vmevent.c                | 107 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                 |  19 ++++++++
 5 files changed, 229 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 078701f..ff0023b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -44,6 +44,9 @@ Currently, these files are in /proc/sys/vm:
 - nr_overcommit_hugepages
 - nr_trim_pages         (only if CONFIG_MMU=n)
 - numa_zonelist_order
+- vmevent_window
+- vmevent_level_med
+- vmevent_level_oom
 - oom_dump_tasks
 - oom_kill_allocating_task
 - overcommit_memory
@@ -487,6 +490,40 @@ this is causing problems for your system/application.
 
 ==============================================================
 
+vmevent_window
+vmevent_level_med
+vmevent_level_oom
+
+These sysctls are used to tune vmevent_fd(2) behaviour.
+
+Currently vmevent pressure levels are based on the reclaimer inefficiency
+index (range from 0 to 100). The files vmevent_level_med and
+vmevent_level_oom accept the index values (by default set to 60 and 99
+respectively). A non-existent vmevent_level_low tunable is always set to 0
+
+When the system is short on idle pages, the new memory is allocated by
+reclaiming least recently used resources: kernel scans pages to be
+reclaimed (e.g. from file caches, mmap(2) volatile ranges, etc.; and
+potentially swapping some pages out), and the index shows the relative
+time spent by the kernel uselessly scanning pages, or, in other words, the
+percentage of scans of pages (vmevent_window) that were not reclaimed. The
+higher the index, the more it should be evident that new allocations' cost
+becomes higher.
+
+When index equals to 0, this means that the kernel is reclaiming, but
+every scanned page has been successfully reclaimed (so the pressure is
+low). 100 means that the kernel is trying to reclaim, but nothing can be
+reclaimed (close to OOM).
+
+Window size is used as a rate-limit tunable for VMEVENT_PRESSURE_LOW
+notifications and for averaging for VMEVENT_PRESSURE_{MED,OOM} levels. So,
+using small window sizes can cause lot of false positives for _MED and
+_OOM levels, but too big window size may delay notifications.
+
+By default the window size equals to 256 pages (1MB).
+
+==============================================================
+
 oom_dump_tasks
 
 Enables a system-wide task dump (excluding kernel threads) to be
diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
index b1c4016..a0e6641 100644
--- a/include/linux/vmevent.h
+++ b/include/linux/vmevent.h
@@ -10,10 +10,18 @@ enum {
 	VMEVENT_ATTR_NR_AVAIL_PAGES	= 1UL,
 	VMEVENT_ATTR_NR_FREE_PAGES	= 2UL,
 	VMEVENT_ATTR_NR_SWAP_PAGES	= 3UL,
+	VMEVENT_ATTR_PRESSURE		= 4UL,
 
 	VMEVENT_ATTR_MAX		/* non-ABI */
 };
 
+/* We spread the values, reserving room for new levels, if ever needed. */
+enum {
+	VMEVENT_PRESSURE_LOW = 1 << 10,
+	VMEVENT_PRESSURE_MED = 1 << 11,
+	VMEVENT_PRESSURE_OOM = 1 << 12,
+};
+
 /*
  * Attribute state bits for threshold
  */
@@ -97,4 +105,38 @@ struct vmevent_event {
 	struct vmevent_attr	attrs[];
 };
 
+#ifdef __KERNEL__
+
+struct mem_cgroup;
+
+extern void __vmevent_pressure(struct mem_cgroup *memcg,
+			       ulong scanned,
+			       ulong reclaimed);
+
+static inline void vmevent_pressure(struct mem_cgroup *memcg,
+				    ulong scanned,
+				    ulong reclaimed)
+{
+	if (!scanned)
+		return;
+
+	if (IS_BUILTIN(CONFIG_MEMCG) && memcg) {
+		/*
+		 * The vmevent API reports system pressure, for per-cgroup
+		 * pressure, we'll chain cgroups notifications, this is to
+		 * be implemented.
+		 *
+		 * memcg_vm_pressure(target_mem_cgroup, scanned, reclaimed);
+		 */
+		return;
+	}
+	__vmevent_pressure(memcg, scanned, reclaimed);
+}
+
+extern uint vmevent_window;
+extern uint vmevent_level_med;
+extern uint vmevent_level_oom;
+
+#endif
+
 #endif /* _LINUX_VMEVENT_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 87174ef..e00d3fb 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -50,6 +50,7 @@
 #include <linux/dnotify.h>
 #include <linux/syscalls.h>
 #include <linux/vmstat.h>
+#include <linux/vmevent.h>
 #include <linux/nfs_fs.h>
 #include <linux/acpi.h>
 #include <linux/reboot.h>
@@ -1317,6 +1318,29 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= numa_zonelist_order_handler,
 	},
 #endif
+#ifdef CONFIG_VMEVENT
+	{
+		.procname	= "vmevent_window",
+		.data		= &vmevent_window,
+		.maxlen		= sizeof(vmevent_window),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "vmevent_level_med",
+		.data		= &vmevent_level_med,
+		.maxlen		= sizeof(vmevent_level_med),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "vmevent_level_oom",
+		.data		= &vmevent_level_oom,
+		.maxlen		= sizeof(vmevent_level_oom),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 #if (defined(CONFIG_X86_32) && !defined(CONFIG_UML))|| \
    (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
 	{
diff --git a/mm/vmevent.c b/mm/vmevent.c
index 8195897..11ce5ef 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -4,6 +4,7 @@
 #include <linux/vmevent.h>
 #include <linux/syscalls.h>
 #include <linux/workqueue.h>
+#include <linux/mutex.h>
 #include <linux/file.h>
 #include <linux/list.h>
 #include <linux/poll.h>
@@ -28,8 +29,22 @@ struct vmevent_watch {
 
 	/* poll */
 	wait_queue_head_t		waitq;
+
+	/* Our node in the pressure watchers list. */
+	struct list_head		pwatcher;
 };
 
+static atomic64_t vmevent_pressure_sr;
+static uint vmevent_pressure_val;
+
+static LIST_HEAD(vmevent_pwatchers);
+static DEFINE_MUTEX(vmevent_pwatchers_lock);
+
+/* Our sysctl tunables, see Documentation/sysctl/vm.txt */
+uint __read_mostly vmevent_window = SWAP_CLUSTER_MAX * 16;
+uint vmevent_level_med = 60;
+uint vmevent_level_oom = 99;
+
 typedef u64 (*vmevent_attr_sample_fn)(struct vmevent_watch *watch,
 				      struct vmevent_attr *attr);
 
@@ -97,10 +112,21 @@ static u64 vmevent_attr_avail_pages(struct vmevent_watch *watch,
 	return totalram_pages;
 }
 
+static u64 vmevent_attr_pressure(struct vmevent_watch *watch,
+				 struct vmevent_attr *attr)
+{
+	if (vmevent_pressure_val >= vmevent_level_oom)
+		return VMEVENT_PRESSURE_OOM;
+	else if (vmevent_pressure_val >= vmevent_level_med)
+		return VMEVENT_PRESSURE_MED;
+	return VMEVENT_PRESSURE_LOW;
+}
+
 static vmevent_attr_sample_fn attr_samplers[] = {
 	[VMEVENT_ATTR_NR_AVAIL_PAGES]   = vmevent_attr_avail_pages,
 	[VMEVENT_ATTR_NR_FREE_PAGES]    = vmevent_attr_free_pages,
 	[VMEVENT_ATTR_NR_SWAP_PAGES]    = vmevent_attr_swap_pages,
+	[VMEVENT_ATTR_PRESSURE]		= vmevent_attr_pressure,
 };
 
 static u64 vmevent_sample_attr(struct vmevent_watch *watch, struct vmevent_attr *attr)
@@ -239,6 +265,73 @@ static void vmevent_start_timer(struct vmevent_watch *watch)
 	vmevent_schedule_watch(watch);
 }
 
+static uint vmevent_calc_pressure(uint win, uint s, uint r)
+{
+	ulong p;
+
+	/*
+	 * We calculate the ratio (in percents) of how many pages were
+	 * scanned vs. reclaimed in a given time frame (window). Note that
+	 * time is in VM reclaimer's "ticks", i.e. number of pages
+	 * scanned. This makes it possible set desired reaction time and
+	 * serves as a ratelimit.
+	 */
+	p = win - (r * win / s);
+	p = p * 100 / win;
+
+	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, p, s, r);
+
+	return p;
+}
+
+#define VMEVENT_SCANNED_SHIFT (sizeof(u64) * 8 / 2)
+
+static void vmevent_pressure_wk_fn(struct work_struct *wk)
+{
+	struct vmevent_watch *watch;
+	u64 sr = atomic64_xchg(&vmevent_pressure_sr, 0);
+	u32 s = sr >> VMEVENT_SCANNED_SHIFT;
+	u32 r = sr & (((u64)1 << VMEVENT_SCANNED_SHIFT) - 1);
+
+	vmevent_pressure_val = vmevent_calc_pressure(vmevent_window, s, r);
+
+	mutex_lock(&vmevent_pwatchers_lock);
+	list_for_each_entry(watch, &vmevent_pwatchers, pwatcher)
+		vmevent_sample(watch);
+	mutex_unlock(&vmevent_pwatchers_lock);
+}
+static DECLARE_WORK(vmevent_pressure_wk, vmevent_pressure_wk_fn);
+
+void __vmevent_pressure(struct mem_cgroup *memcg,
+			ulong scanned,
+			ulong reclaimed)
+{
+	/*
+	 * Store s/r combined, so we don't have to worry to synchronize
+	 * them. On modern machines it will be truly atomic; on arches w/o
+	 * 64 bit atomics it will turn into a spinlock (for a small amount
+	 * of CPUs it's not a problem).
+	 *
+	 * Using int-sized atomics is a bad idea as it would only allow to
+	 * count (1 << 16) - 1 pages (256MB), which we can scan pretty
+	 * fast.
+	 *
+	 * We can't have per-CPU counters as this will not catch a case
+	 * when many CPUs scan small amounts (so none of them hit the
+	 * window size limit, and thus we won't send a notification in
+	 * time).
+	 *
+	 * So we shouldn't place vmevent_pressure() into a very hot path.
+	 */
+	atomic64_add(scanned << VMEVENT_SCANNED_SHIFT | reclaimed,
+		     &vmevent_pressure_sr);
+
+	scanned = atomic64_read(&vmevent_pressure_sr) >> VMEVENT_SCANNED_SHIFT;
+	if (scanned >= vmevent_window &&
+			!work_pending(&vmevent_pressure_wk))
+		schedule_work(&vmevent_pressure_wk);
+}
+
 static unsigned int vmevent_poll(struct file *file, poll_table *wait)
 {
 	struct vmevent_watch *watch = file->private_data;
@@ -300,6 +393,11 @@ static int vmevent_release(struct inode *inode, struct file *file)
 
 	cancel_delayed_work_sync(&watch->work);
 
+	if (watch->pwatcher.next) {
+		mutex_lock(&vmevent_pwatchers_lock);
+		list_del(&watch->pwatcher);
+		mutex_unlock(&vmevent_pwatchers_lock);
+	}
 	kfree(watch);
 
 	return 0;
@@ -328,6 +426,7 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
 {
 	struct vmevent_config *config = &watch->config;
 	struct vmevent_attr *attrs = NULL;
+	bool pwatcher = 0;
 	unsigned long nr;
 	int i;
 
@@ -340,6 +439,8 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
 
 		if (attr->type >= VMEVENT_ATTR_MAX)
 			continue;
+		else if (attr->type == VMEVENT_ATTR_PRESSURE)
+			pwatcher = 1;
 
 		size = sizeof(struct vmevent_attr) * (nr + 1);
 
@@ -363,6 +464,12 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
 	watch->sample_attrs	= attrs;
 	watch->nr_attrs		= nr;
 
+	if (pwatcher) {
+		mutex_lock(&vmevent_pwatchers_lock);
+		list_add(&watch->pwatcher, &vmevent_pwatchers);
+		mutex_unlock(&vmevent_pwatchers_lock);
+	}
+
 	return 0;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99b434b..cd3bd19 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -20,6 +20,7 @@
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/vmstat.h>
+#include <linux/vmevent.h>
 #include <linux/file.h>
 #include <linux/writeback.h>
 #include <linux/blkdev.h>
@@ -1846,6 +1847,9 @@ restart:
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 
+	vmevent_pressure(sc->target_mem_cgroup,
+			 sc->nr_scanned - nr_scanned, nr_reclaimed);
+
 	/* reclaim/compaction might need reclaim to continue */
 	if (should_continue_reclaim(lruvec, nr_reclaimed,
 				    sc->nr_scanned - nr_scanned, sc))
@@ -2068,6 +2072,21 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		count_vm_event(ALLOCSTALL);
 
 	do {
+		/*
+		 * OK, we're cheating. The thing is, we have to average
+		 * s/r ratio by gathering a lot of scans (otherwise we
+		 * might get some local false-positives index of '100').
+		 *
+		 * But... when we're almost OOM we might be getting the
+		 * last reclaimable pages slowly, scanning all the queues,
+		 * and so we never catch the OOM case via averaging.
+		 * Although the priority will show it for sure. 3 is an
+		 * empirically taken priority: we never observe it under
+		 * any load, except for last few allocations before OOM.
+		 */
+		if (sc->priority <= 3)
+			vmevent_pressure(sc->target_mem_cgroup,
+					 vmevent_window, 0);
 		sc->nr_scanned = 0;
 		aborted_reclaim = shrink_zones(zonelist, sc);
 
-- 
1.7.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
