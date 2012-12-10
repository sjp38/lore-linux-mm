Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E19EC6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 05:01:59 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1831977pbc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 02:01:59 -0800 (PST)
Date: Mon, 10 Dec 2012 01:58:38 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC v2] Add mempressure cgroup
Message-ID: <20121210095838.GA21065@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

The main changes for the mempressure cgroup:

- Added documentation, describes APIs and the purpose;

- Implemented shrinker interface, this is based on Andrew's idea and
  supersedes my "balance" level idea;

- The shrinker interface comes with a stress-test utility, that is what
  Andrew was also asking for. A simple app that we can run and see if the
  thing works as expected;

- Added reclaimer's target_mem_cgroup handling;

- As promised, added support for multiple listeners, and fixed some other
  comments on the previous RFC.

Just for the reference, the first mempressure RFC:

  http://lkml.org/lkml/2012/11/28/109

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 Documentation/cgroups/mempressure.txt    |  89 ++++++
 Documentation/cgroups/mempressure_test.c | 209 +++++++++++++
 include/linux/cgroup_subsys.h            |   6 +
 include/linux/vmstat.h                   |  11 +
 init/Kconfig                             |  12 +
 mm/Makefile                              |   1 +
 mm/mempressure.c                         | 488 +++++++++++++++++++++++++++++++
 mm/vmscan.c                              |   4 +
 8 files changed, 820 insertions(+)
 create mode 100644 Documentation/cgroups/mempressure.txt
 create mode 100644 Documentation/cgroups/mempressure_test.c
 create mode 100644 mm/mempressure.c

diff --git a/Documentation/cgroups/mempressure.txt b/Documentation/cgroups/mempressure.txt
new file mode 100644
index 0000000..913accc
--- /dev/null
+++ b/Documentation/cgroups/mempressure.txt
@@ -0,0 +1,89 @@
+  Memory pressure cgroup
+~~~~~~~~~~~~~~~~~~~~~~~~~~
+  Before using the mempressure cgroup, make sure you have it mounted:
+
+   # cd /sys/fs/cgroup/
+   # mkdir mempressure
+   # mount -t cgroup cgroup ./mempressure -o mempressure
+
+  After that, you can use the following files:
+
+  /sys/fs/cgroup/.../mempressure.shrinker
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+  The file implements userland shrinker (memory reclaimer) interface, so
+  that the kernel can ask userland to help with the memory reclaiming
+  process.
+
+  There are two basic concepts: chunks and chunks' size. The program must
+  tell the kernel the granularity of its allocations (chunk size) and the
+  number of reclaimable chunks. The granularity may be not 100% accurate,
+  but the more it is accurate, the better. I.e. suppose the application
+  has 200 page renders cached (but not displayed), 1MB each. So the chunk
+  size is 1MB, and the number of chunks is 200.
+
+  The granularity is specified during shrinker registration (i.e. via
+  argument to the event_control cgroup file; and it is OK to register
+  multiple shrinkers for different granularities). The number of
+  reclaimable chunks is specified by writing to the mempressure.shrinker
+  file.
+
+  The notification comes through the eventfd() interface. Upon the
+  notification, a read() from the eventfd returns the number of chunks to
+  reclaim (free).
+
+  It is assumed that the application will free the specified amount of
+  chunks before reading from the eventfd again. If that is not the case,
+  suppose the program was not able to reclaim the chunks, then application
+  should re-add the amount of chunks by writing to the
+  mempressure.shrinker file (otherwise the chunks won't be accounted by
+  the kernel, since it assumes that they were reclaimed).
+
+  Event control:
+    Used to setup shrinker events. There is only one argument for the
+    event control: chunk size in bytes.
+  Read:
+    Not implemented.
+  Write:
+    Writes must be in "<eventfd> <number of chunks>" format. Positive
+    numbers increment the internal counter, negative numbers decrement it
+    (but the kernel prevents the counter from falling down below zero).
+  Test:
+    See mempressure_test.c
+
+  /sys/fs/cgroup/.../mempressure.level
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+  Instead of working on the bytes level (like shrinkers), one may decide
+  to maintain the interactivity/memory allocation cost.
+
+  For this, the cgroup has memory pressure level notifications, and the
+  levels are defined like this:
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
+  reconstructed or re-read from a disk. Note that for a fine-grained
+  control, you should probably use the shrinker interface, as described
+  above.
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
diff --git a/Documentation/cgroups/mempressure_test.c b/Documentation/cgroups/mempressure_test.c
new file mode 100644
index 0000000..9747fd6
--- /dev/null
+++ b/Documentation/cgroups/mempressure_test.c
@@ -0,0 +1,209 @@
+/*
+ * mempressure shrinker test
+ *
+ * Copyright 2012 Linaro Ltd.
+ *		  Anton Vorontsov <anton.vorontsov@linaro.org>
+ *
+ * It is pretty simple: we create two threads, the first one constantly
+ * tries to allocate memory (more than we physically have), the second
+ * thread listens to the kernel shrinker notifications and frees asked
+ * amount of chunks. When we allocate more than available RAM, the two
+ * threads start to fight. Idially, we should not OOM (but if we reclaim
+ * slower than we allocate, things might OOM). Also, ideally we should not
+ * grow swap too much.
+ *
+ * The test accepts no arguments, so you can just run it and observe the
+ * output and memory usage (e.g. 'watch -n 0.2 free -m'). Upon ctrl+c, the
+ * test prints total amount of bytes we helped to reclaim.
+ *
+ * Compile with -pthread.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation.
+ */
+
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <stdbool.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <pthread.h>
+#include <signal.h>
+#include <errno.h>
+#include <sys/eventfd.h>
+#include <sys/sysinfo.h>
+
+#define CG			"/sys/fs/cgroup/mempressure"
+#define CG_EVENT_CONTROL	(CG "/cgroup.event_control")
+#define CG_SHRINKER		(CG "/mempressure.shrinker")
+
+#define CHUNK_SIZE (1 * 1024 * 1024)
+
+static size_t num_chunks;
+
+static void **chunks;
+static pthread_mutex_t *locks;
+static int efd;
+static int sfd;
+
+static inline void pabort(bool f, int code, const char *str)
+{
+	if (!f)
+		return;
+	perror(str);
+	printf("(%d)\n", code);
+	abort();
+}
+
+static void init_shrinker(void)
+{
+	int cfd;
+	int ret;
+	char *str;
+
+	cfd = open(CG_EVENT_CONTROL, O_WRONLY);
+	pabort(cfd < 0, cfd, CG_EVENT_CONTROL);
+
+	sfd = open(CG_SHRINKER, O_RDWR);
+	pabort(sfd < 0, sfd, CG_SHRINKER);
+
+	efd = eventfd(0, 0);
+	pabort(efd < 0, efd, "eventfd()");
+
+	ret = asprintf(&str, "%d %d %d\n", efd, sfd, CHUNK_SIZE);
+	printf("%s\n", str);
+	pabort(ret == -1, ret, "control string");
+
+	ret = write(cfd, str, ret + 1);
+	pabort(ret == -1, ret, "write() to event_control");
+}
+
+static void add_reclaimable(int chunks)
+{
+	int ret;
+	char *str;
+
+	ret = asprintf(&str, "%d %d\n", efd, CHUNK_SIZE);
+	pabort(ret == -1, ret, "add_reclaimable, asprintf");
+
+	ret = write(sfd, str, ret + 1);
+	pabort(ret <= 0, ret, "add_reclaimable, write");
+}
+
+static int chunks_to_reclaim(void)
+{
+	uint64_t n = 0;
+	int ret;
+
+	ret = read(efd, &n, sizeof(n));
+	pabort(ret <= 0, ret, "read() from eventfd");
+
+	printf("%d chunks to reclaim\n", (int)n);
+
+	return n;
+}
+
+static unsigned int reclaimed;
+
+static void print_stats(int signum)
+{
+	printf("\nTOTAL: helped to reclaim %d chunks (%d MB)\n",
+	       reclaimed, reclaimed * CHUNK_SIZE / 1024 / 1024);
+	exit(0);
+}
+
+static void *shrinker_thr_fn(void *arg)
+{
+	puts("shrinker thread started");
+
+	sigaction(SIGINT, &(struct sigaction){.sa_handler = print_stats}, NULL);
+
+	while (1) {
+		unsigned int i = 0;
+		int n;
+
+		n = chunks_to_reclaim();
+
+		reclaimed += n;
+
+		while (n) {
+			pthread_mutex_lock(&locks[i]);
+			if (chunks[i]) {
+				free(chunks[i]);
+				chunks[i] = NULL;
+				n--;
+			}
+			pthread_mutex_unlock(&locks[i]);
+
+			i = (i + 1) % num_chunks;
+		}
+	}
+	return NULL;
+}
+
+static void consume_memory(void)
+{
+	unsigned int i = 0;
+	unsigned int j = 0;
+
+	puts("consuming memory...");
+
+	while (1) {
+		pthread_mutex_lock(&locks[i]);
+		if (!chunks[i]) {
+			chunks[i] = malloc(CHUNK_SIZE);
+			pabort(!chunks[i], 0, "chunks alloc failed");
+			memset(chunks[i], 0, CHUNK_SIZE);
+			j++;
+		}
+		pthread_mutex_unlock(&locks[i]);
+
+		if (j >= num_chunks / 10) {
+			add_reclaimable(num_chunks / 10);
+			printf("added %d reclaimable chunks\n", j);
+			j = 0;
+		}
+
+		i = (i + 1) % num_chunks;
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	int ret;
+	int i;
+	pthread_t shrinker_thr;
+	struct sysinfo si;
+
+	ret = sysinfo(&si);
+	pabort(ret != 0, ret, "sysinfo()");
+
+	num_chunks = (si.totalram + si.totalswap) * si.mem_unit / 1024 / 1024;
+
+	chunks = malloc(sizeof(*chunks) * num_chunks);
+	locks = malloc(sizeof(*locks) * num_chunks);
+	pabort(!chunks || !locks, ENOMEM, NULL);
+
+	init_shrinker();
+
+	for (i = 0; i < num_chunks; i++) {
+		ret = pthread_mutex_init(&locks[i], NULL);
+		pabort(ret != 0, ret, "pthread_mutex_init");
+	}
+
+	ret = pthread_create(&shrinker_thr, NULL, shrinker_thr_fn, NULL);
+	pabort(ret != 0, ret, "pthread_create(shrinker)");
+
+	consume_memory();
+
+	ret = pthread_join(shrinker_thr, NULL);
+	pabort(ret != 0, ret, "pthread_join(shrinker)");
+
+	return 0;
+}
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
index 92a86b2..3f7f7d2 100644
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
index 6fdd6e3..5c308be 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -826,6 +826,18 @@ config MEMCG_KMEM
 	  the kmem extension can use it to guarantee that no group of processes
 	  will ever exhaust kernel resources alone.
 
+config CGROUP_MEMPRESSURE
+	bool "Memory pressure monitor for Control Groups"
+	help
+	  The memory pressure monitor cgroup provides a facility for
+	  userland programs so that they could easily assist the kernel
+	  with the memory management. This includes simple memory pressure
+	  notifications and a full-fledged userland reclaimer.
+
+	  For more information see Documentation/cgroups/mempressure.txt
+
+	  If unsure, say N.
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
index 0000000..e39a33d
--- /dev/null
+++ b/mm/mempressure.c
@@ -0,0 +1,488 @@
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
+ *
+ * The same window size also used for the shrinker, so be aware. It might
+ * be a good idea to derive the window size from the machine size, similar
+ * to what we do for the vmstat.
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
+struct mpc_shrinker {
+	struct eventfd_ctx *efd;
+	size_t chunks;
+	size_t chunk_sz;
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
+	struct list_head shrinkers;
+	struct mutex shrinkers_lock;
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
+static void mpc_shrinker(struct mpc_state *mpc, ulong s, ulong r)
+{
+	struct mpc_shrinker *sh;
+	ssize_t to_reclaim_pages = s - r;
+
+	if (!to_reclaim_pages)
+		return;
+
+	mutex_lock(&mpc->shrinkers_lock);
+
+	/*
+	 * To make accounting more precise and to avoid excessive
+	 * communication with the kernel, we operate on chunks instead of
+	 * bytes. Say, asking to free 8 KBs makes little sense if
+	 * granularity of allocations is 10 MBs. Also, knowing the
+	 * granularity (chunk size) and the number of reclaimable chunks,
+	 * we just ask that N chunks should be freed, and we assume that
+	 * it will be freed, thus we decrement our internal counter
+	 * straight away (i.e. userland does not need to respond how much
+	 * was reclaimed). But, if userland could not free it, it is
+	 * responsible to increment the counter back.
+	 */
+	list_for_each_entry(sh, &mpc->shrinkers, node) {
+		size_t to_reclaim_chunks;
+
+		if (!sh->chunks)
+			continue;
+
+		to_reclaim_chunks = to_reclaim_pages *
+				    PAGE_SIZE / sh->chunk_sz;
+		to_reclaim_chunks = min(sh->chunks, to_reclaim_chunks);
+
+		if (!to_reclaim_chunks)
+			continue;
+
+		sh->chunks -= to_reclaim_chunks;
+
+		eventfd_signal(sh->efd, to_reclaim_chunks);
+
+		to_reclaim_pages -= to_reclaim_chunks *
+				    sh->chunk_sz / PAGE_SIZE;
+		if (to_reclaim_pages <= 0)
+			break;
+	}
+
+	mutex_unlock(&mpc->shrinkers_lock);
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
+	mpc_shrinker(mpc, s, r);
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
+static struct cgroup_subsys_state *mpc_create(struct cgroup *cg)
+{
+	struct mpc_state *mpc;
+
+	mpc = kzalloc(sizeof(*mpc), GFP_KERNEL);
+	if (!mpc)
+		return ERR_PTR(-ENOMEM);
+
+	mutex_init(&mpc->sr_lock);
+	mutex_init(&mpc->events_lock);
+	mutex_init(&mpc->shrinkers_lock);
+	INIT_LIST_HEAD(&mpc->events);
+	INIT_LIST_HEAD(&mpc->shrinkers);
+	INIT_WORK(&mpc->work, mpc_vmpressure_wk_fn);
+
+	return &mpc->css;
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
+static int mpc_register_level_event(struct cgroup *cg, struct cftype *cft,
+				    struct eventfd_ctx *eventfd,
+				    const char *args)
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
+static void mpc_unregister_event(struct cgroup *cg, struct cftype *cft,
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
+static int mpc_register_shrinker(struct cgroup *cg, struct cftype *cft,
+				 struct eventfd_ctx *eventfd,
+				 const char *args)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	struct mpc_shrinker *sh;
+	ulong chunk_sz;
+	int ret;
+
+	ret = kstrtoul(args, 10, &chunk_sz);
+	if (ret)
+		return ret;
+
+	sh = kzalloc(sizeof(*sh), GFP_KERNEL);
+	if (!sh)
+		return -ENOMEM;
+
+	sh->efd = eventfd;
+	sh->chunk_sz = chunk_sz;
+
+	mutex_lock(&mpc->shrinkers_lock);
+	list_add(&sh->node, &mpc->shrinkers);
+	mutex_unlock(&mpc->shrinkers_lock);
+
+	return 0;
+}
+
+static void mpc_unregister_shrinker(struct cgroup *cg, struct cftype *cft,
+				 struct eventfd_ctx *eventfd)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	struct mpc_shrinker *sh;
+
+	mutex_lock(&mpc->shrinkers_lock);
+	list_for_each_entry(sh, &mpc->shrinkers, node) {
+		if (sh->efd != eventfd)
+			continue;
+		list_del(&sh->node);
+		kfree(sh);
+		break;
+	}
+	mutex_unlock(&mpc->shrinkers_lock);
+}
+
+static int mpc_write_shrinker(struct cgroup *cg, struct cftype *cft,
+			      const char *str)
+{
+	struct mpc_state *mpc = cg2mpc(cg);
+	struct mpc_shrinker *sh;
+	struct eventfd_ctx *eventfd;
+	struct file *file;
+	ssize_t chunks;
+	int fd;
+	int ret;
+
+	ret = sscanf(str, "%d %zd\n", &fd, &chunks);
+	if (ret != 2)
+		return -EINVAL;
+
+	file = fget(fd);
+	if (!file)
+		return -EBADF;
+
+	eventfd = eventfd_ctx_fileget(file);
+
+	mutex_lock(&mpc->shrinkers_lock);
+
+	/* Can avoid the loop once we introduce ->priv for eventfd_ctx. */
+	list_for_each_entry(sh, &mpc->shrinkers, node) {
+		if (sh->efd != eventfd)
+			continue;
+		if (chunks < 0 && abs(chunks) > sh->chunks)
+			sh->chunks = 0;
+		else
+			sh->chunks += chunks;
+		break;
+	}
+
+	mutex_unlock(&mpc->shrinkers_lock);
+
+	eventfd_ctx_put(eventfd);
+	fput(file);
+
+	return 0;
+}
+
+static struct cftype mpc_files[] = {
+	{
+		.name = "level",
+		.read = mpc_read_level,
+		.register_event = mpc_register_level_event,
+		.unregister_event = mpc_unregister_event,
+	},
+	{
+		.name = "shrinker",
+		.register_event = mpc_register_shrinker,
+		.unregister_event = mpc_unregister_shrinker,
+		.write_string = mpc_write_shrinker,
+	},
+	{},
+};
+
+struct cgroup_subsys mpc_cgroup_subsys = {
+	.name = "mempressure",
+	.subsys_id = mpc_cgroup_subsys_id,
+	.create = mpc_create,
+	.destroy = mpc_destroy,
+	.base_cftypes = mpc_files,
+};
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 48550c6..d8ff846 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1877,6 +1877,9 @@ restart:
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 
+	vmpressure(sc->target_mem_cgroup,
+		   sc->nr_scanned - nr_scanned, nr_reclaimed);
+
 	/* reclaim/compaction might need reclaim to continue */
 	if (should_continue_reclaim(lruvec, nr_reclaimed,
 				    sc->nr_scanned - nr_scanned, sc))
@@ -2099,6 +2102,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		count_vm_event(ALLOCSTALL);
 
 	do {
+		vmpressure_prio(sc->target_mem_cgroup, sc->priority);
 		sc->nr_scanned = 0;
 		aborted_reclaim = shrink_zones(zonelist, sc);
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
