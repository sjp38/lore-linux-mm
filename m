Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 600146B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:31:56 -0400 (EDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNW00F0EVOIKTI0@mailout3.samsung.com> for linux-mm@kvack.org;
 Wed, 05 Jun 2013 17:31:30 +0900 (KST)
From: =?UTF-8?B?6rmA7ZiE7Z2s?= <hyunhee.kim@samsung.com>
References: <20130403035923.GA4752@lizard.gateway.2wire.net>
In-reply-to: <20130403035923.GA4752@lizard.gateway.2wire.net>
Subject: RE: [PATCH v4] memcg: Add memory.pressure_level events
Date: Wed, 05 Jun 2013 17:31:30 +0900
Message-id: <012701ce61c7$141c53b0$3c54fb10$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: quoted-printable
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Anton Vorontsov' <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, =?UTF-8?B?J+uwleqyveuvvCc=?= <kyungmin.park@samsung.com>, 'Bartlomiej Zolnierkiewicz' <b.zolnierkie@samsung.com>

Hi, Anton,

When calculating pressure level in vmpressure_calc_level, I observed =
that "reclaimed" becomes larger than "scanned".
In this case, since these values are "unsigned long", pressure returns =
wrong value and critical event is triggered even on low state.
Do you think that it is possible?=20
If so, in this case, should we make "reclaimed" equal to "scanned"?
When I tested as below, it could trigger reasonable events.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+static enum vmpressure_levels vmpressure_calc_level(unsigned long =
scanned,
+						    unsigned long reclaimed)
+{
+	unsigned long scale =3D scanned + reclaimed;
+	unsigned long pressure;
+	if (reclaimed > scanned)
+		reclaimed =3D scanned;
+	/*
+	 * We calculate the ratio (in percents) of how many pages were
+	 * scanned vs. reclaimed in a given time frame (window). Note that
+	 * time is in VM reclaimer's "ticks", i.e. number of pages
+	 * scanned. This makes it possible to set desired reaction time
+	 * and serves as a ratelimit.
+	 */
+	pressure =3D scale - (reclaimed * scale / scanned);
+	pressure =3D pressure * 100 / scale;
+	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
+		 scanned, reclaimed);
+
+	return vmpressure_level(pressure);
+}

Thanks,
Hyunhee Kim.


-----Original Message-----
From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On =
Behalf Of Anton Vorontsov
Sent: Wednesday, April 03, 2013 12:59 PM
To: cgroups@vger.kernel.org
Cc: Tejun Heo; David Rientjes; Pekka Enberg; Mel Gorman; Glauber Costa; =
Michal Hocko; Kirill A. Shutemov; Kamezawa Hiroyuki; Luiz Capitulino; =
Andrew Morton; Greg Thelen; Leonid Moiseichuk; KOSAKI Motohiro; Minchan =
Kim; Bartlomiej Zolnierkiewicz; John Stultz; linux-mm@kvack.org; =
linux-kernel@vger.kernel.org; linaro-kernel@lists.linaro.org; =
patches@linaro.org; kernel-team@android.com
Subject: [PATCH v4] memcg: Add memory.pressure_level events

With this patch userland applications that want to maintain the
interactivity/memory allocation cost can use the pressure level
notifications. The levels are defined like this:

The "low" level means that the system is reclaiming memory for new
allocations. Monitoring this reclaiming activity might be useful for
maintaining cache level. Upon notification, the program (typically
"Activity Manager") might analyze vmstat and act in advance (i.e.
prematurely shutdown unimportant services).

The "medium" level means that the system is experiencing medium memory
pressure, the system might be making swap, paging out active file =
caches,
etc. Upon this event applications may decide to further analyze
vmstat/zoneinfo/memcg or internal memory usage statistics and free any
resources that can be easily reconstructed or re-read from a disk.

The "critical" level means that the system is actively thrashing, it is
about to out of memory (OOM) or even the in-kernel OOM killer is on its
way to trigger. Applications should do whatever they can to help the
system. It might be too late to consult with vmstat or any other
statistics, so it's advisable to take an immediate action.

The events are propagated upward until the event is handled, i.e. the
events are not pass-through. Here is what this means: for example you =
have
three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
and C, and suppose group C experiences some pressure. In this situation,
only group C will receive the notification, i.e. groups A and B will not
receive it. This is done to avoid excessive "broadcasting" of messages,
which disturbs the system and which is especially bad if we are low on
memory or thrashing. So, organize the cgroups wisely, or propagate the
events manually (or, ask us to implement the pass-through events,
explaining why would you need them.)

Performance wise, the memory pressure notifications feature itself is
lightweight and does not require much of bookkeeping, in contrast to the
rest of memcg features. Unfortunately, as of current memcg =
implementation,
pages accounting is an inseparable part and cannot be turned off. The =
good
news is that there are some efforts[1] to improve the situation; plus,
implementing the same, fully API-compatible[2] interface for
CONFIG_MEMCG=3Dn case (e.g. embedded) is also a viable option, so it =
will
not require any changes on the userland side.

[1] http://permalink.gmane.org/gmane.linux.kernel.cgroups/6291
[2] http://lkml.org/lkml/2013/2/21/454

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---

Hi all,

Thanks for the previous reviews!

In v4 I addressed Andrew's and Kamezawa's comments:

- Documented public interfaces and tunables;

- Added documentation for eventfd interface;

- Some cosmetic changes: code rearrangements and variables renames
  (wk->work, lvl->level, etc.);

- Changed types for page counters from 'unsigned int' to 'unsigned =
long',
  this avoids possible overflows;

- Added Kamezawa's Ack, and rebased onto 3.9.0-rc5-next-20130402+.

In v3:

- No changes in the code, just updated commit message to incorporate the
  answer to Minchan Kim's comment regarding applicability to embedded =
use
  cases in the light of memcg performance overhead, plus gave some
  references to Glauber Costa's memcg work.

- Rebased onto 3.9.0-rc3-next-20130321.

Old changelogs/submissions:

  v3: http://lkml.org/lkml/2013/3/22/31
  v2: http://lkml.org/lkml/2013/2/18/577
  v1: http://lkml.org/lkml/2013/2/10/140
  mempressure cgroup: http://lkml.org/lkml/2013/1/4/55

 Documentation/cgroups/memory.txt |  70 +++++++-
 include/linux/vmpressure.h       |  48 +++++
 mm/Makefile                      |   2 +-
 mm/memcontrol.c                  |  29 +++
 mm/vmpressure.c                  | 374 =
+++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                      |   8 +
 6 files changed, 529 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/vmpressure.h
 create mode 100644 mm/vmpressure.c

diff --git a/Documentation/cgroups/memory.txt =
b/Documentation/cgroups/memory.txt
index 3aaa984..1178e23 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -40,6 +40,7 @@ Features:
  - soft limit
  - moving (recharging) account at moving a task is selectable.
  - usage threshold notifier
+ - memory pressure notifier
  - oom-killer disable knob and oom-notifier
  - Root cgroup has no limit controls.
=20
@@ -65,6 +66,7 @@ Brief summary of control files.
  memory.stat			 # show various statistics
  memory.use_hierarchy		 # set/show hierarchical account enabled
  memory.force_empty		 # trigger forced move charge to parent
+ memory.pressure_level		 # set memory pressure notifications
  memory.swappiness		 # set/show swappiness parameter of vmscan
 				 (See sysctl's vm.swappiness)
  memory.move_charge_at_immigrate # set/show controls of moving charges
@@ -778,7 +780,73 @@ At reading, current status of OOM is shown.
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
=20
-11. TODO
+11. Memory Pressure
+
+The pressure level notifications can be used to monitor the memory
+allocation cost; based on the pressure, applications can implement
+different strategies of managing their memory resources. The pressure
+levels are defined as following:
+
+The "low" level means that the system is reclaiming memory for new
+allocations. Monitoring this reclaiming activity might be useful for
+maintaining cache level. Upon notification, the program (typically
+"Activity Manager") might analyze vmstat and act in advance (i.e.
+prematurely shutdown unimportant services).
+
+The "medium" level means that the system is experiencing medium memory
+pressure, the system might be making swap, paging out active file =
caches,
+etc. Upon this event applications may decide to further analyze
+vmstat/zoneinfo/memcg or internal memory usage statistics and free any
+resources that can be easily reconstructed or re-read from a disk.
+
+The "critical" level means that the system is actively thrashing, it is
+about to out of memory (OOM) or even the in-kernel OOM killer is on its
+way to trigger. Applications should do whatever they can to help the
+system. It might be too late to consult with vmstat or any other
+statistics, so it's advisable to take an immediate action.
+
+The events are propagated upward until the event is handled, i.e. the
+events are not pass-through. Here is what this means: for example you =
have
+three cgroups: A->B->C. Now you set up an event listener on cgroups A, =
B
+and C, and suppose group C experiences some pressure. In this =
situation,
+only group C will receive the notification, i.e. groups A and B will =
not
+receive it. This is done to avoid excessive "broadcasting" of messages,
+which disturbs the system and which is especially bad if we are low on
+memory or thrashing. So, organize the cgroups wisely, or propagate the
+events manually (or, ask us to implement the pass-through events,
+explaining why would you need them.)
+
+The file memory.pressure_level is only used to setup an eventfd. To
+register a notification, an application must:
+
+- create an eventfd using eventfd(2);
+- open memory.pressure_level;
+- write string like "<event_fd> <fd of memory.pressure_level> <level>"
+  to cgroup.event_control.
+
+Application will be notified through eventfd when memory pressure is at
+the specific level (or higher). Read/write operations to
+memory.pressure_level are no implemented.
+
+Test:
+
+   Here is a small script example that makes a new cgroup, sets up a
+   memory limit, sets up a notification in the cgroup and then makes =
child
+   cgroup experience a critical pressure:
+
+   # cd /sys/fs/cgroup/memory/
+   # mkdir foo
+   # cd foo
+   # cgroup_event_listener memory.pressure_level low &
+   # echo 8000000 > memory.limit_in_bytes
+   # echo 8000000 > memory.memsw.limit_in_bytes
+   # echo $$ > tasks
+   # dd if=3D/dev/zero | read x
+
+   (Expect a bunch of notifications, and eventually, the oom-killer =
will
+   trigger.)
+
+12. TODO
=20
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
new file mode 100644
index 0000000..2e86259
--- /dev/null
+++ b/include/linux/vmpressure.h
@@ -0,0 +1,48 @@
+#ifndef __LINUX_VMPRESSURE_H
+#define __LINUX_VMPRESSURE_H
+
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/workqueue.h>
+#include <linux/gfp.h>
+#include <linux/types.h>
+#include <linux/cgroup.h>
+
+struct vmpressure {
+	unsigned long scanned;
+	unsigned long reclaimed;
+	/* The lock is used to keep the scanned/reclaimed above in sync. */
+	struct mutex sr_lock;
+
+	/* The list of vmpressure_event structs. */
+	struct list_head events;
+	/* Have to grab the lock on events traversal or modifications. */
+	struct mutex events_lock;
+
+	struct work_struct work;
+};
+
+struct mem_cgroup;
+
+#ifdef CONFIG_MEMCG
+extern void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
+		       unsigned long scanned, unsigned long reclaimed);
+extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int =
prio);
+#else
+static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
+			      unsigned long scanned, unsigned long reclaimed) {}
+static inline void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg,
+				   int prio) {}
+#endif /* CONFIG_MEMCG */
+
+extern void vmpressure_init(struct vmpressure *vmpr);
+extern struct vmpressure *memcg_to_vmpressure(struct mem_cgroup =
*memcg);
+extern struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure =
*vmpr);
+extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state =
*css);
+extern int vmpressure_register_event(struct cgroup *cg, struct cftype =
*cft,
+				     struct eventfd_ctx *eventfd,
+				     const char *args);
+extern void vmpressure_unregister_event(struct cgroup *cg, struct =
cftype *cft,
+					struct eventfd_ctx *eventfd);
+
+#endif /* __LINUX_VMPRESSURE_H */
diff --git a/mm/Makefile b/mm/Makefile
index 3a46287..72c5acb 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -50,7 +50,7 @@ obj-$(CONFIG_FS_XIP) +=3D filemap_xip.o
 obj-$(CONFIG_MIGRATION) +=3D migrate.o
 obj-$(CONFIG_QUICKLIST) +=3D quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) +=3D huge_memory.o
-obj-$(CONFIG_MEMCG) +=3D memcontrol.o page_cgroup.o
+obj-$(CONFIG_MEMCG) +=3D memcontrol.o page_cgroup.o vmpressure.o
 obj-$(CONFIG_CGROUP_HUGETLB) +=3D hugetlb_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) +=3D memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) +=3D hwpoison-inject.o
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f608546..64d75a2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,7 @@
 #include <linux/fs.h>
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
+#include <linux/vmpressure.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
@@ -315,6 +316,9 @@ struct mem_cgroup {
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_thresholds memsw_thresholds;
=20
+	/* vmpressure notifications */
+	struct vmpressure vmpressure;
+
 	union {
 		/* For oom notifier event fd */
 		struct list_head oom_notify;
@@ -376,6 +380,7 @@ struct mem_cgroup {
 	atomic_t	numainfo_events;
 	atomic_t	numainfo_updating;
 #endif
+
 	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
@@ -576,6 +581,24 @@ struct mem_cgroup *mem_cgroup_from_css(struct =
cgroup_subsys_state *s)
 	return container_of(s, struct mem_cgroup, css);
 }
=20
+/* Some nice accessors for the vmpressure. */
+struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
+{
+	if (!memcg)
+		memcg =3D root_mem_cgroup;
+	return &memcg->vmpressure;
+}
+
+struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr)
+{
+	return &container_of(vmpr, struct mem_cgroup, vmpressure)->css;
+}
+
+struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css)
+{
+	return &mem_cgroup_from_css(css)->vmpressure;
+}
+
 static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 {
 	return (memcg =3D=3D root_mem_cgroup);
@@ -6074,6 +6097,11 @@ static struct cftype mem_cgroup_files[] =3D {
 		.unregister_event =3D mem_cgroup_oom_unregister_event,
 		.private =3D MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name =3D "pressure_level",
+		.register_event =3D vmpressure_register_event,
+		.unregister_event =3D vmpressure_unregister_event,
+	},
 #ifdef CONFIG_NUMA
 	{
 		.name =3D "numa_stat",
@@ -6365,6 +6393,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 	memcg->move_charge_at_immigrate =3D 0;
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
+	vmpressure_init(&memcg->vmpressure);
=20
 	return &memcg->css;
=20
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
new file mode 100644
index 0000000..ccbdc9e
--- /dev/null
+++ b/mm/vmpressure.c
@@ -0,0 +1,374 @@
+/*
+ * Linux VM pressure
+ *
+ * Copyright 2012 Linaro Ltd.
+ *		  Anton Vorontsov <anton.vorontsov@linaro.org>
+ *
+ * Based on ideas from Andrew Morton, David Rientjes, KOSAKI Motohiro,
+ * Leonid Moiseichuk, Mel Gorman, Minchan Kim and Pekka Enberg.
+ *
+ * This program is free software; you can redistribute it and/or modify =
it
+ * under the terms of the GNU General Public License version 2 as =
published
+ * by the Free Software Foundation.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/log2.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/vmstat.h>
+#include <linux/eventfd.h>
+#include <linux/swap.h>
+#include <linux/printk.h>
+#include <linux/vmpressure.h>
+
+/*
+ * The window size (vmpressure_win) is the number of scanned pages =
before
+ * we try to analyze scanned/reclaimed ratio. So the window is used as =
a
+ * rate-limit tunable for the "low" level notification, and also for
+ * averaging the ratio for medium/critical levels. Using small window
+ * sizes can cause lot of false positives, but too big window size will
+ * delay the notifications.
+ *
+ * As the vmscan reclaimer logic works with chunks which are multiple =
of
+ * SWAP_CLUSTER_MAX, it makes sense to use it for the window size as =
well.
+ *
+ * TODO: Make the window size depend on machine size, as we do for =
vmstat
+ * thresholds. Currently we set it to 512 pages (2MB for 4KB pages).
+ */
+static const unsigned long vmpressure_win =3D SWAP_CLUSTER_MAX * 16;
+
+/*
+ * These thresholds are used when we account memory pressure through
+ * scanned/reclaimed ratio. The current values were chosen empirically. =
In
+ * essence, they are percents: the higher the value, the more number
+ * unsuccessful reclaims there were.
+ */
+static const unsigned int vmpressure_level_med =3D 60;
+static const unsigned int vmpressure_level_critical =3D 95;
+
+/*
+ * When there are too little pages left to scan, vmpressure() may miss =
the
+ * critical pressure as number of pages will be less than "window =
size".
+ * However, in that case the vmscan priority will raise fast as the
+ * reclaimer will try to scan LRUs more deeply.
+ *
+ * The vmscan logic considers these special priorities:
+ *
+ * prio =3D=3D DEF_PRIORITY (12): reclaimer starts with that value
+ * prio <=3D DEF_PRIORITY - 2 : kswapd becomes somewhat overwhelmed
+ * prio =3D=3D 0                : close to OOM, kernel scans every page =
in an lru
+ *
+ * Any value in this range is acceptable for this tunable (i.e. from 12 =
to
+ * 0). Current value for the vmpressure_level_critical_prio is chosen
+ * empirically, but the number, in essence, means that we consider
+ * critical level when scanning depth is ~10% of the lru size (vmscan
+ * scans 'lru_size >> prio' pages, so it is actually 12.5%, or one
+ * eights).
+ */
+static const unsigned int vmpressure_level_critical_prio =3D ilog2(100 =
/ 10);
+
+static struct vmpressure *work_to_vmpressure(struct work_struct *work)
+{
+	return container_of(work, struct vmpressure, work);
+}
+
+static struct vmpressure *cg_to_vmpressure(struct cgroup *cg)
+{
+	return css_to_vmpressure(cgroup_subsys_state(cg, =
mem_cgroup_subsys_id));
+}
+
+static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
+{
+	struct cgroup *cg =3D vmpressure_to_css(vmpr)->cgroup;
+	struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cg);
+
+	memcg =3D parent_mem_cgroup(memcg);
+	if (!memcg)
+		return NULL;
+	return memcg_to_vmpressure(memcg);
+}
+
+enum vmpressure_levels {
+	VMPRESSURE_LOW =3D 0,
+	VMPRESSURE_MEDIUM,
+	VMPRESSURE_CRITICAL,
+	VMPRESSURE_NUM_LEVELS,
+};
+
+static const char *vmpressure_str_levels[] =3D {
+	[VMPRESSURE_LOW] =3D "low",
+	[VMPRESSURE_MEDIUM] =3D "medium",
+	[VMPRESSURE_CRITICAL] =3D "critical",
+};
+
+static enum vmpressure_levels vmpressure_level(unsigned long pressure)
+{
+	if (pressure >=3D vmpressure_level_critical)
+		return VMPRESSURE_CRITICAL;
+	else if (pressure >=3D vmpressure_level_med)
+		return VMPRESSURE_MEDIUM;
+	return VMPRESSURE_LOW;
+}
+
+static enum vmpressure_levels vmpressure_calc_level(unsigned long =
scanned,
+						    unsigned long reclaimed)
+{
+	unsigned long scale =3D scanned + reclaimed;
+	unsigned long pressure;
+
+	/*
+	 * We calculate the ratio (in percents) of how many pages were
+	 * scanned vs. reclaimed in a given time frame (window). Note that
+	 * time is in VM reclaimer's "ticks", i.e. number of pages
+	 * scanned. This makes it possible to set desired reaction time
+	 * and serves as a ratelimit.
+	 */
+	pressure =3D scale - (reclaimed * scale / scanned);
+	pressure =3D pressure * 100 / scale;
+
+	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
+		 scanned, reclaimed);
+
+	return vmpressure_level(pressure);
+}
+
+struct vmpressure_event {
+	struct eventfd_ctx *efd;
+	enum vmpressure_levels level;
+	struct list_head node;
+};
+
+static bool vmpressure_event(struct vmpressure *vmpr,
+			     unsigned long scanned, unsigned long reclaimed)
+{
+	struct vmpressure_event *ev;
+	enum vmpressure_levels level;
+	bool signalled =3D false;
+
+	level =3D vmpressure_calc_level(scanned, reclaimed);
+
+	mutex_lock(&vmpr->events_lock);
+
+	list_for_each_entry(ev, &vmpr->events, node) {
+		if (level >=3D ev->level) {
+			eventfd_signal(ev->efd, 1);
+			signalled =3D true;
+		}
+	}
+
+	mutex_unlock(&vmpr->events_lock);
+
+	return signalled;
+}
+
+static void vmpressure_work_fn(struct work_struct *work)
+{
+	struct vmpressure *vmpr =3D work_to_vmpressure(work);
+	unsigned long scanned;
+	unsigned long reclaimed;
+
+	/*
+	 * Several contexts might be calling vmpressure(), so it is
+	 * possible that the work was rescheduled again before the old
+	 * work context cleared the counters. In that case we will run
+	 * just after the old work returns, but then scanned might be zero
+	 * here. No need for any locks here since we don't care if
+	 * vmpr->reclaimed is in sync.
+	 */
+	if (!vmpr->scanned)
+		return;
+
+	mutex_lock(&vmpr->sr_lock);
+	scanned =3D vmpr->scanned;
+	reclaimed =3D vmpr->reclaimed;
+	vmpr->scanned =3D 0;
+	vmpr->reclaimed =3D 0;
+	mutex_unlock(&vmpr->sr_lock);
+
+	do {
+		if (vmpressure_event(vmpr, scanned, reclaimed))
+			break;
+		/*
+		 * If not handled, propagate the event upward into the
+		 * hierarchy.
+		 */
+	} while ((vmpr =3D vmpressure_parent(vmpr)));
+}
+
+/**
+ * vmpressure() - Account memory pressure through scanned/reclaimed =
ratio
+ * @gfp:	reclaimer's gfp mask
+ * @memcg:	cgroup memory controller handle
+ * @scanned:	number of pages scanned
+ * @reclaimed:	number of pages reclaimed
+ *
+ * This function should be called from the vmscan reclaim path to =
account
+ * "instantaneous" memory pressure (scanned/reclaimed ratio). The raw
+ * pressure index is then further refined and averaged over time.
+ *
+ * This function does not return any value.
+ */
+void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
+		unsigned long scanned, unsigned long reclaimed)
+{
+	struct vmpressure *vmpr =3D memcg_to_vmpressure(memcg);
+
+	/*
+	 * Here we only want to account pressure that userland is able to
+	 * help us with. For example, suppose that DMA zone is under
+	 * pressure; if we notify userland about that kind of pressure,
+	 * then it will be mostly a waste as it will trigger unnecessary
+	 * freeing of memory by userland (since userland is more likely to
+	 * have HIGHMEM/MOVABLE pages instead of the DMA fallback). That
+	 * is why we include only movable, highmem and FS/IO pages.
+	 * Indirect reclaim (kswapd) sets sc->gfp_mask to GFP_KERNEL, so
+	 * we account it too.
+	 */
+	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
+		return;
+
+	/*
+	 * If we got here with no pages scanned, then that is an indicator
+	 * that reclaimer was unable to find any shrinkable LRUs at the
+	 * current scanning depth. But it does not mean that we should
+	 * report the critical pressure, yet. If the scanning priority
+	 * (scanning depth) goes too high (deep), we will be notified
+	 * through vmpressure_prio(). But so far, keep calm.
+	 */
+	if (!scanned)
+		return;
+
+	mutex_lock(&vmpr->sr_lock);
+	vmpr->scanned +=3D scanned;
+	vmpr->reclaimed +=3D reclaimed;
+	scanned =3D vmpr->scanned;
+	mutex_unlock(&vmpr->sr_lock);
+
+	if (scanned < vmpressure_win || work_pending(&vmpr->work))
+		return;
+	schedule_work(&vmpr->work);
+}
+
+/**
+ * vmpressure_prio() - Account memory pressure through reclaimer =
priority level
+ * @gfp:	reclaimer's gfp mask
+ * @memcg:	cgroup memory controller handle
+ * @prio:	reclaimer's priority
+ *
+ * This function should be called from the reclaim path every time when
+ * the vmscan's reclaiming priority (scanning depth) changes.
+ *
+ * This function does not return any value.
+ */
+void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
+{
+	/*
+	 * We only use prio for accounting critical level. For more info
+	 * see comment for vmpressure_level_critical_prio variable above.
+	 */
+	if (prio > vmpressure_level_critical_prio)
+		return;
+
+	/*
+	 * OK, the prio is below the threshold, updating vmpressure
+	 * information before shrinker dives into long shrinking of long
+	 * range vmscan. Passing scanned =3D vmpressure_win, reclaimed =3D 0
+	 * to the vmpressure() basically means that we signal 'critical'
+	 * level.
+	 */
+	vmpressure(gfp, memcg, vmpressure_win, 0);
+}
+
+/**
+ * vmpressure_register_event() - Bind vmpressure notifications to an =
eventfd
+ * @cg:		cgroup that is interested in vmpressure notifications
+ * @cft:	cgroup control files handle
+ * @eventfd:	eventfd context to link notifications with
+ * @args:	event arguments (used to set up a pressure level threshold)
+ *
+ * This function associates eventfd context with the vmpressure
+ * infrastructure, so that the notifications will be delivered to the
+ * @eventfd. The @args parameter is a string that denotes pressure =
level
+ * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
+ * "critical").
+ *
+ * This function should not be used directly, just pass it to (struct
+ * cftype).register_event, and then cgroup core will handle everything =
by
+ * itself.
+ */
+int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
+			      struct eventfd_ctx *eventfd, const char *args)
+{
+	struct vmpressure *vmpr =3D cg_to_vmpressure(cg);
+	struct vmpressure_event *ev;
+	int level;
+
+	for (level =3D 0; level < VMPRESSURE_NUM_LEVELS; level++) {
+		if (!strcmp(vmpressure_str_levels[level], args))
+			break;
+	}
+
+	if (level >=3D VMPRESSURE_NUM_LEVELS)
+		return -EINVAL;
+
+	ev =3D kzalloc(sizeof(*ev), GFP_KERNEL);
+	if (!ev)
+		return -ENOMEM;
+
+	ev->efd =3D eventfd;
+	ev->level =3D level;
+
+	mutex_lock(&vmpr->events_lock);
+	list_add(&ev->node, &vmpr->events);
+	mutex_unlock(&vmpr->events_lock);
+
+	return 0;
+}
+
+/**
+ * vmpressure_unregister_event() - Unbind eventfd from vmpressure
+ * @cg:		cgroup handle
+ * @cft:	cgroup control files handle
+ * @eventfd:	eventfd context that was used to link vmpressure with the =
@cg
+ *
+ * This function does internal manipulations to detach the @eventfd =
from
+ * the vmpressure notifications, and then frees internal resources
+ * associated with the @eventfd (but the @eventfd itself is not freed).
+ *
+ * This function should not be used directly, just pass it to (struct
+ * cftype).unregister_event, and then cgroup core will handle =
everything
+ * by itself.
+ */
+void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
+				 struct eventfd_ctx *eventfd)
+{
+	struct vmpressure *vmpr =3D cg_to_vmpressure(cg);
+	struct vmpressure_event *ev;
+
+	mutex_lock(&vmpr->events_lock);
+	list_for_each_entry(ev, &vmpr->events, node) {
+		if (ev->efd !=3D eventfd)
+			continue;
+		list_del(&ev->node);
+		kfree(ev);
+		break;
+	}
+	mutex_unlock(&vmpr->events_lock);
+}
+
+/**
+ * vmpressure_init() - Initialize vmpressure control structure
+ * @vmpr:	Structure to be initialized
+ *
+ * This function should be called on every allocated vmpressure =
structure
+ * before any usage.
+ */
+void vmpressure_init(struct vmpressure *vmpr)
+{
+	mutex_init(&vmpr->sr_lock);
+	mutex_init(&vmpr->events_lock);
+	INIT_LIST_HEAD(&vmpr->events);
+	INIT_WORK(&vmpr->work, vmpressure_work_fn);
+}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index df78d17..616e2bb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -19,6 +19,7 @@
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/vmpressure.h>
 #include <linux/vmstat.h>
 #include <linux/file.h>
 #include <linux/writeback.h>
@@ -1982,6 +1983,11 @@ static void shrink_zone(struct zone *zone, struct =
scan_control *sc)
 			}
 			memcg =3D mem_cgroup_iter(root, memcg, &reclaim);
 		} while (memcg);
+
+		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
+			   sc->nr_scanned - nr_scanned,
+			   sc->nr_reclaimed - nr_reclaimed);
+
 	} while (should_continue_reclaim(zone, sc->nr_reclaimed - =
nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 }
@@ -2167,6 +2173,8 @@ static unsigned long do_try_to_free_pages(struct =
zonelist *zonelist,
 		count_vm_event(ALLOCSTALL);
=20
 	do {
+		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
+				sc->priority);
 		sc->nr_scanned =3D 0;
 		aborted_reclaim =3D shrink_zones(zonelist, sc);
=20
--=20
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
