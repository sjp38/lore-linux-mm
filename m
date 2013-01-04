Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id B88256B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 03:33:09 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id u1so2531925ggl.9
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 00:33:08 -0800 (PST)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 2/2] Add shrinker interface for mempressure cgroup
Date: Fri,  4 Jan 2013 00:29:12 -0800
Message-Id: <1357288152-23625-2-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20130104082751.GA22227@lizard.gateway.2wire.net>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

This commit implements Andrew Morton's idea of kernel-controlled userland
reclaimer. This is very similar to the in-kernel shrinker, with one major
difference: it is asynchronous, i.e. like kswapd.

Note that the shrinker interface is not a substitution for the levels, the
two interfaces report different kinds information (i.e. with the shrinker
you don't know the actual system state -- how bad/good the memory
situation is).

The interface is well documented and comes with a stress-test utility.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 Documentation/cgroups/mempressure.txt    |  53 +++++++-
 Documentation/cgroups/mempressure_test.c | 213 +++++++++++++++++++++++++++++++
 init/Kconfig                             |   5 +-
 mm/mempressure.c                         | 157 +++++++++++++++++++++++
 4 files changed, 423 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/cgroups/mempressure_test.c

diff --git a/Documentation/cgroups/mempressure.txt b/Documentation/cgroups/mempressure.txt
index dbc0aca..5094749 100644
--- a/Documentation/cgroups/mempressure.txt
+++ b/Documentation/cgroups/mempressure.txt
@@ -16,10 +16,55 @@
 
   After the hierarchy is mounted, you can use the following API:
 
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
   /sys/fs/cgroup/.../mempressure.level
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-  To maintain the interactivity/memory allocation cost, one can use the
-  pressure level notifications, and the levels are defined like this:
+  Instead of working on the bytes level (like shrinkers), one may decide
+  to maintain the interactivity/memory allocation cost.
+
+  For this, the cgroup has memory pressure level notifications, and the
+  levels are defined like this:
 
   The "low" level means that the system is reclaiming memory for new
   allocations. Monitoring reclaiming activity might be useful for
@@ -30,7 +75,9 @@
   The "medium" level means that the system is experiencing medium memory
   pressure, there is some mild swapping activity. Upon this event
   applications may decide to free any resources that can be easily
-  reconstructed or re-read from a disk.
+  reconstructed or re-read from a disk. Note that for a fine-grained
+  control, you should probably use the shrinker interface, as described
+  above.
 
   The "oom" level means that the system is actively thrashing, it is about
   to out of memory (OOM) or even the in-kernel OOM killer is on its way to
diff --git a/Documentation/cgroups/mempressure_test.c b/Documentation/cgroups/mempressure_test.c
new file mode 100644
index 0000000..a6c770c
--- /dev/null
+++ b/Documentation/cgroups/mempressure_test.c
@@ -0,0 +1,213 @@
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
+	pabort(ret == -1, ret, "control string");
+	printf("%s\n", str);
+
+	ret = write(cfd, str, ret + 1);
+	pabort(ret == -1, ret, "write() to event_control");
+
+	free(str);
+}
+
+static void add_reclaimable(int chunks)
+{
+	int ret;
+	char *str;
+
+	ret = asprintf(&str, "%d %d\n", efd, chunks);
+	pabort(ret == -1, ret, "add_reclaimable, asprintf");
+
+	ret = write(sfd, str, ret + 1);
+	pabort(ret <= 0, ret, "add_reclaimable, write");
+
+	free(str);
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
diff --git a/init/Kconfig b/init/Kconfig
index d526249..bdb5ba2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -896,8 +896,9 @@ config CGROUP_MEMPRESSURE
 	help
 	  The memory pressure monitor cgroup provides a facility for
 	  userland programs so that they could easily assist the kernel
-	  with the memory management. So far the API provides simple,
-	  levels-based memory pressure notifications.
+	  with the memory management. The API provides simple,
+	  levels-based memory pressure notifications and a full-fledged
+	  userland reclaimer.
 
 	  For more information see Documentation/cgroups/mempressure.txt
 
diff --git a/mm/mempressure.c b/mm/mempressure.c
index ea312bb..5512326 100644
--- a/mm/mempressure.c
+++ b/mm/mempressure.c
@@ -35,6 +35,10 @@ static void mpc_vmpressure(struct mem_cgroup *memcg, ulong s, ulong r);
  * and for averaging medium/oom levels. Using small window sizes can cause
  * lot of false positives, but too big window size will delay the
  * notifications.
+ *
+ * The same window size also used for the shrinker, so be aware. It might
+ * be a good idea to derive the window size from the machine size, similar
+ * to what we do for the vmstat.
  */
 static const uint vmpressure_win = SWAP_CLUSTER_MAX * 16;
 static const uint vmpressure_level_med = 60;
@@ -111,6 +115,13 @@ struct mpc_event {
 	struct list_head node;
 };
 
+struct mpc_shrinker {
+	struct eventfd_ctx *efd;
+	size_t chunks;
+	size_t chunk_sz;
+	struct list_head node;
+};
+
 struct mpc_state {
 	struct cgroup_subsys_state css;
 
@@ -121,6 +132,9 @@ struct mpc_state {
 	struct list_head events;
 	struct mutex events_lock;
 
+	struct list_head shrinkers;
+	struct mutex shrinkers_lock;
+
 	struct work_struct work;
 };
 
@@ -144,6 +158,54 @@ static struct mpc_state *cg2mpc(struct cgroup *cg)
 	return css2mpc(cgroup_subsys_state(cg, mpc_cgroup_subsys_id));
 }
 
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
 static void mpc_event(struct mpc_state *mpc, ulong s, ulong r)
 {
 	struct mpc_event *ev;
@@ -172,6 +234,7 @@ static void mpc_vmpressure_wk_fn(struct work_struct *wk)
 	mpc->reclaimed = 0;
 	mutex_unlock(&mpc->sr_lock);
 
+	mpc_shrinker(mpc, s, r);
 	mpc_event(mpc, s, r);
 }
 
@@ -233,7 +296,9 @@ static struct cgroup_subsys_state *mpc_css_alloc(struct cgroup *cg)
 
 	mutex_init(&mpc->sr_lock);
 	mutex_init(&mpc->events_lock);
+	mutex_init(&mpc->shrinkers_lock);
 	INIT_LIST_HEAD(&mpc->events);
+	INIT_LIST_HEAD(&mpc->shrinkers);
 	INIT_WORK(&mpc->work, mpc_vmpressure_wk_fn);
 
 	return &mpc->css;
@@ -311,6 +376,92 @@ static void mpc_unregister_level(struct cgroup *cg, struct cftype *cft,
 	mutex_unlock(&mpc->events_lock);
 }
 
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
 static struct cftype mpc_files[] = {
 	{
 		.name = "level",
@@ -318,6 +469,12 @@ static struct cftype mpc_files[] = {
 		.register_event = mpc_register_level,
 		.unregister_event = mpc_unregister_level,
 	},
+	{
+		.name = "shrinker",
+		.register_event = mpc_register_shrinker,
+		.unregister_event = mpc_unregister_shrinker,
+		.write_string = mpc_write_shrinker,
+	},
 	{},
 };
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
