Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D659E6B0260
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:49:33 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id v30so1098149qtg.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:49:33 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z9si226630qkb.211.2017.12.05.11.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 11:49:32 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v3 2/7] ktask: multithread CPU-intensive kernel work
Date: Tue,  5 Dec 2017 14:52:15 -0500
Message-Id: <20171205195220.28208-3-daniel.m.jordan@oracle.com>
In-Reply-To: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

ktask is a generic framework for parallelizing CPU-intensive work in the
kernel.  The intended use is for big machines that can use their CPU power to
speed up large tasks that can't otherwise be multithreaded in userland.  The
API is generic enough to add concurrency to many different kinds of tasks--for
example, zeroing a range of pages or evicting a list of inodes--and aims to
save its clients the trouble of splitting up the work, choosing the number of
threads to use, maintaining an efficient concurrency level, starting these
threads, and load balancing the work between them.

The Documentation patch earlier in this series has more background.

Introduces the ktask API; consumers appear in subsequent patches.

Based on work by Pavel Tatashin, Steve Sistare, and Jonathan Adams.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Suggested-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Suggested-by: Steve Sistare <steven.sistare@oracle.com>
Suggested-by: Jonathan Adams <jonathan.adams@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Tim Chen <tim.c.chen@intel.com>
---
 include/linux/ktask.h          | 255 +++++++++++++++++++
 include/linux/ktask_internal.h |  22 ++
 include/linux/mm.h             |   6 +
 init/Kconfig                   |  12 +
 init/main.c                    |   2 +
 kernel/Makefile                |   2 +-
 kernel/ktask.c                 | 556 +++++++++++++++++++++++++++++++++++++++++
 7 files changed, 854 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/ktask.h
 create mode 100644 include/linux/ktask_internal.h
 create mode 100644 kernel/ktask.c

diff --git a/include/linux/ktask.h b/include/linux/ktask.h
new file mode 100644
index 000000000000..16232bdcaaef
--- /dev/null
+++ b/include/linux/ktask.h
@@ -0,0 +1,255 @@
+/*
+ * ktask.h
+ *
+ * Framework to parallelize CPU-intensive kernel work such as zeroing
+ * huge pages or freeing many pages at once.  For more information, see
+ * Documentation/core-api/ktask.rst.
+ *
+ * This is the interface to ktask; everything in this file is
+ * accessible to ktask clients.
+ *
+ * If CONFIG_KTASK=n, calls to the ktask API are simply #define'd to run the
+ * thread function that the client provides so that the task is completed
+ * without concurrency in the current thread.
+ */
+
+#ifndef _LINUX_KTASK_H
+#define _LINUX_KTASK_H
+
+#include <linux/types.h>
+
+#define	KTASK_RETURN_SUCCESS	0
+#define	KTASK_RETURN_ERROR	(-1)
+
+/**
+ * struct ktask_node - Holds per-NUMA-node information about a task.
+ *
+ * @kn_start: An object that describes the start of the task on this NUMA node.
+ * @kn_task_size: The size of the task on this NUMA node (units are
+ *                task-specific).
+ * @kn_nid: The NUMA node id (or NUMA_NO_NODE, in which case the work is done on
+ *          the current node).
+ */
+struct ktask_node {
+	void		*kn_start;
+	size_t		kn_task_size;
+	int		kn_nid;
+};
+
+/**
+ * typedef ktask_thread_func
+ *
+ * Called on each chunk of work that a ktask thread does, where the chunk is
+ * delimited by [start, end).  A thread may call this multiple times during one
+ * task.
+ *
+ * @start: An object that describes the start of the chunk.
+ * @end: An object that describes the end of the chunk.
+ * @arg: The thread function argument (provided with struct ktask_ctl).
+ *
+ * RETURNS:
+ * KTASK_RETURN_SUCCESS or KTASK_RETURN_ERROR.
+ */
+typedef int (*ktask_thread_func)(void *start, void *end, void *arg);
+
+/**
+ * typedef ktask_iter_func
+ *
+ * An iterator function that advances the position by a given number of steps.
+ *
+ * @position: An object that describes the current position in the task.
+ * @nsteps: The number of steps to advance in the task (in task-specific
+ *          units).
+ *
+ * RETURNS:
+ * An object representing the new position.
+ */
+typedef void *(*ktask_iter_func)(void *position, size_t nsteps);
+
+/**
+ * ktask_iter_range
+ *
+ * An iterator function for a contiguous range such as an array or address
+ * range.  This is the default iterator; clients may override with
+ * ktask_ctl_set_iter_func.
+ *
+ * @position: An object that describes the current position in the task.
+ *            Interpreted as an unsigned long.
+ * @nsteps: The number of steps to advance in the task (in task-specific
+ *          units).
+ *
+ * RETURNS:
+ * (position + nsteps)
+ */
+void *ktask_iter_range(void *position, size_t nsteps);
+
+/**
+ * struct ktask_ctl - Client-provided per-task control information.
+ *
+ * @kc_thread_func: A thread function that completes one chunk of the task per
+ *                  call.
+ * @kc_thread_func_arg: An argument to be passed to the thread function.
+ * @kc_iter_func: An iterator function to advance the iterator by some number
+ *                   of task-specific units.
+ * @kc_min_chunk_size: The minimum chunk size in task-specific units.  This
+ *                     allows the client to communicate the minimum amount of
+ *                     work that's appropriate for one worker thread to do at
+ *                     once.
+ * @kc_max_threads: The maximum number of threads to use for the task.
+ *                  The actual number used may be less than this if the
+ *                  framework determines that fewer threads would be better,
+ *                  taking into account such things as total CPU count and
+ *                  task size.  Pass 0 to use ktask's default maximum.
+ */
+struct ktask_ctl {
+	/* Required arguments set with DEFINE_KTASK_CTL. */
+	ktask_thread_func	kc_thread_func;
+	void			*kc_thread_func_arg;
+	size_t			kc_min_chunk_size;
+
+	/*
+	 * Optional arguments set with ktask_ctl_set_* functions.  Defaults
+	 * listed to the side.
+	 */
+	ktask_iter_func		kc_iter_func;    /* ktask_iter_range */
+	size_t			kc_max_threads;  /* 0 (uses internal limit) */
+};
+
+#define KTASK_CTL_INITIALIZER(thread_func, thread_func_arg, min_chunk_size)  \
+	{								     \
+		.kc_thread_func = (ktask_thread_func)(thread_func),	     \
+		.kc_thread_func_arg = (thread_func_arg),		     \
+		.kc_min_chunk_size = (min_chunk_size),			     \
+		.kc_iter_func = (ktask_iter_range),			     \
+		.kc_max_threads = (0),					     \
+	}
+
+/*
+ * Note that KTASK_CTL_INITIALIZER casts 'thread_func' to be of type
+ * ktask_thread_func.  This is to help clients write cleaner thread functions
+ * by relieving them of the need to cast the three void * arguments.  Clients
+ * can just use the actual argument types instead.
+ */
+#define DEFINE_KTASK_CTL(ctl_name, thread_func, thread_func_arg,	  \
+			 min_chunk_size)				  \
+	struct ktask_ctl ctl_name =					  \
+		KTASK_CTL_INITIALIZER(thread_func, thread_func_arg,	  \
+				      min_chunk_size)
+
+/**
+ * ktask_ctl_set_iter_func - Set a task-specific iterator
+ *
+ * This overrides the default iterator, ktask_iter_range.
+ *
+ * @ctl:  A control structure containing information about the task.
+ * @iter_func:  Client-provided iterator function that conforms to the
+ *              declaration of ktask_iter_func.
+ */
+static inline void ktask_ctl_set_iter_func(struct ktask_ctl *ctl,
+					   ktask_iter_func iter_func)
+{
+	ctl->kc_iter_func = iter_func;
+}
+
+/**
+ * ktask_ctl_set_max_threads - Set a task-specific maximum number of threads
+ *
+ * This overrides the default maximum, which is KTASK_DEFAULT_MAX_THREADS
+ * initially and may be changed via /proc/sys/debug/ktask_max_threads.
+ *
+ * @ctl:  A control structure containing information about the task.
+ * @max_threads:  The maximum number of threads to be started for this task.
+ *                The actual number of threads may be less than this.
+ */
+static inline void ktask_ctl_set_max_threads(struct ktask_ctl *ctl,
+					     size_t max_threads)
+{
+	ctl->kc_max_threads = max_threads;
+}
+
+#ifdef CONFIG_KTASK
+
+/**
+ * ktask_run - Runs one task.
+ *
+ * Starts threads to complete one task with the given thread function.  Waits
+ * for the task to finish before returning.
+ *
+ * On a NUMA system, threads run on the current node.  This is designed to
+ * mirror other parts of the kernel that favor locality, such as the default
+ * memory policy of allocating pages from the same node as the calling thread.
+ * ktask_run_numa may be used to get more control over where threads run.
+ *
+ * @start: An object that describes the start of the task.  The client thread
+ *         function interprets the object however it sees fit (e.g. an array
+ *         index, a simple pointer, or a pointer to a more complicated
+ *         representation of job position).
+ * @task_size:  The size of the task (units are task-specific).
+ * @ctl:  A control structure containing information about the task, including
+ *        the client thread function.
+ *
+ * RETURNS:
+ * KTASK_RETURN_SUCCESS or KTASK_RETURN_ERROR.
+ */
+int ktask_run(void *start, size_t task_size, struct ktask_ctl *ctl);
+
+/**
+ * ktask_run_numa - Runs one task while accounting for NUMA locality.
+ *
+ * Starts threads on the requested nodes to complete one task with the given
+ * thread function.  The client is responsible for organizing the work along
+ * NUMA boundaries in the 'nodes' array.  Waits for the task to finish before
+ * returning.
+ *
+ * In the special case of NUMA_NO_NODE, threads are allowed to run on any node.
+ * This is distinct from ktask_run, which runs threads on the current node.
+ *
+ * @nodes: An array of struct ktask_node's, each of which describes the task on
+ *         a NUMA node (see struct ktask_node).
+ * @nr_nodes:  The length of the 'nodes' array.
+ * @ctl:  A control structure containing information about the task (see
+ *        the definition of struct ktask_ctl).
+ *
+ * RETURNS:
+ * KTASK_RETURN_SUCCESS or KTASK_RETURN_ERROR.
+ */
+int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
+		   struct ktask_ctl *ctl);
+
+void ktask_init(void);
+
+#else  /* CONFIG_KTASK */
+
+static inline int ktask_run(void *start, size_t task_size,
+			    struct ktask_ctl *ctl)
+{
+	return ctl->kc_thread_func(start,
+				   ctl->kc_iter_func(start, task_size),
+				   ctl->kc_thread_func_arg);
+}
+
+static inline int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
+				 struct ktask_ctl *ctl)
+{
+	size_t i;
+	int err = KTASK_RETURN_SUCCESS;
+
+	for (i = 0; i < nr_nodes; ++i) {
+		err = ctl->kc_thread_func(
+			    nodes[i].kn_start,
+			    ctl->kc_iter_func(nodes[i].kn_start,
+						 nodes[i].kn_task_size),
+			    ctl->kc_thread_func_arg);
+
+		if (err == KTASK_RETURN_ERROR)
+			break;
+	}
+
+	return err;
+}
+
+static inline void ktask_init(void) { }
+
+#endif /* CONFIG_KTASK */
+
+#endif /* _LINUX_KTASK_H */
diff --git a/include/linux/ktask_internal.h b/include/linux/ktask_internal.h
new file mode 100644
index 000000000000..50d339d6eed1
--- /dev/null
+++ b/include/linux/ktask_internal.h
@@ -0,0 +1,22 @@
+/*
+ * ktask_internal.h
+ *
+ * Framework to parallelize CPU-intensive kernel work such as zeroing
+ * huge pages or freeing many pages at once.  For more information, see
+ * Documentation/core-api/ktask.rst.
+ *
+ * This file contains implementation details of ktask for core kernel code that
+ * needs to be aware of them.  ktask clients should not include this file.
+ */
+#ifndef _LINUX_KTASK_INTERNAL_H
+#define _LINUX_KTASK_INTERNAL_H
+
+#include <linux/ktask.h>
+
+#ifdef CONFIG_KTASK
+/* Caps the number of threads that are allowed to be used in one task. */
+extern int ktask_max_threads;
+
+#endif /* CONFIG_KTASK */
+
+#endif /* _LINUX_KTASK_INTERNAL_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..50fa9b3d9d2c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2669,5 +2669,11 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+/*
+ * The minimum chunk size for a task that uses base page units.  For now, say
+ * 1G's worth of pages.
+ */
+#define	KTASK_BPGS_MINCHUNK		((1ul << 30) / PAGE_SIZE)
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/init/Kconfig b/init/Kconfig
index 2934249fba46..2a7b120de4d4 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -319,6 +319,18 @@ config AUDIT_TREE
 	depends on AUDITSYSCALL
 	select FSNOTIFY
 
+config KTASK
+	bool "Multithread cpu-intensive kernel tasks"
+	depends on SMP
+	depends on NR_CPUS > 16
+	default n
+	help
+	  Parallelize expensive kernel tasks such as zeroing huge pages.  This
+          feature is designed for big machines that can take advantage of their
+          cpu count to speed up large kernel tasks.
+
+          If unsure, say 'N'.
+
 source "kernel/irq/Kconfig"
 source "kernel/time/Kconfig"
 
diff --git a/init/main.c b/init/main.c
index dfec3809e740..e771199f0c60 100644
--- a/init/main.c
+++ b/init/main.c
@@ -88,6 +88,7 @@
 #include <linux/io.h>
 #include <linux/cache.h>
 #include <linux/rodata_test.h>
+#include <linux/ktask.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -1060,6 +1061,7 @@ static noinline void __init kernel_init_freeable(void)
 
 	smp_init();
 	sched_init_smp();
+	ktask_init();
 
 	page_alloc_init_late();
 
diff --git a/kernel/Makefile b/kernel/Makefile
index 172d151d429c..f8d1ed267ebd 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -10,7 +10,7 @@ obj-y     = fork.o exec_domain.o panic.o \
 	    extable.o params.o \
 	    kthread.o sys_ni.o nsproxy.o \
 	    notifier.o ksysfs.o cred.o reboot.o \
-	    async.o range.o smpboot.o ucount.o
+	    async.o range.o smpboot.o ucount.o ktask.o
 
 obj-$(CONFIG_MODULES) += kmod.o
 obj-$(CONFIG_MULTIUSER) += groups.o
diff --git a/kernel/ktask.c b/kernel/ktask.c
new file mode 100644
index 000000000000..7b075075b56b
--- /dev/null
+++ b/kernel/ktask.c
@@ -0,0 +1,556 @@
+/*
+ * ktask.c
+ *
+ * Framework to parallelize CPU-intensive kernel work such as zeroing
+ * huge pages or freeing many pages at once.  For more information, see
+ * Documentation/core-api/ktask.rst.
+ *
+ * This is the ktask implementation; everything in this file is private to
+ * ktask.
+ */
+
+#define pr_fmt(fmt)	"ktask: " fmt
+
+#include <linux/ktask.h>
+
+#ifdef CONFIG_KTASK
+
+#include <linux/cpu.h>
+#include <linux/cpumask.h>
+#include <linux/completion.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/ktask_internal.h>
+#include <linux/mutex.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+
+/* Resource limits on the amount of workqueue items queued through ktask. */
+spinlock_t ktask_rlim_lock;
+/* Work items queued on all nodes (includes NUMA_NO_NODE) */
+size_t ktask_rlim_cur;
+size_t ktask_rlim_max;
+/* Work items queued per node */
+size_t *ktask_rlim_node_cur;
+size_t *ktask_rlim_node_max;
+
+/* Allow only 80% of the cpus to be running additional ktask threads. */
+#define	KTASK_CPUFRAC_NUMER	4
+#define	KTASK_CPUFRAC_DENOM	5
+
+/* Used to pass ktask data to the workqueue API. */
+struct ktask_work {
+	struct work_struct	kw_work;
+	struct ktask_task	*kw_task;
+	int			kw_ktask_node_i;
+	int			kw_queue_nid;
+	struct list_head	kw_list;	/* ktask_free_works linkage */
+};
+
+static LIST_HEAD(ktask_free_works);
+struct ktask_work *ktask_works;
+
+/* Represents one task.  This is for internal use only. */
+struct ktask_task {
+	struct ktask_ctl	kt_ctl;
+	size_t			kt_total_size;
+	size_t			kt_chunk_size;
+	/* mutex protects nodes, nr_nodes_left, nthreads_fini, error */
+	struct mutex		kt_mutex;
+	struct ktask_node	*kt_nodes;
+	size_t			kt_nr_nodes;
+	size_t			kt_nr_nodes_left;
+	size_t			kt_nthreads;
+	size_t			kt_nthreads_fini;
+	int			kt_error; /* tracks error(s) from thread_func */
+	struct completion	kt_ktask_done;
+};
+
+/*
+ * Shrink the size of each job by this shift amount to load balance between the
+ * worker threads.
+ */
+#define	KTASK_LOAD_BAL_SHIFT		2
+
+#define	KTASK_DEFAULT_MAX_THREADS	4
+
+/* Maximum number of threads for a single task. */
+int ktask_max_threads = KTASK_DEFAULT_MAX_THREADS;
+
+static struct workqueue_struct *ktask_wq;
+static struct workqueue_struct *ktask_nonuma_wq;
+
+static void ktask_thread(struct work_struct *work);
+
+static inline void ktask_init_work(struct ktask_work *kw, struct ktask_task *kt,
+			    size_t ktask_node_i, size_t queue_nid)
+{
+	INIT_WORK(&kw->kw_work, ktask_thread);
+	kw->kw_task = kt;
+	kw->kw_ktask_node_i = ktask_node_i;
+	kw->kw_queue_nid = queue_nid;
+}
+
+static void ktask_queue_work(struct ktask_work *kw)
+{
+	struct workqueue_struct *wq;
+	int cpu;
+
+	if (kw->kw_queue_nid == NUMA_NO_NODE) {
+		/*
+		 * If no node is specified, use ktask_nonuma_wq to
+		 * allow the thread to run on any node, but fall back
+		 * to ktask_wq if we couldn't allocate ktask_nonuma_wq.
+		 */
+		cpu = WORK_CPU_UNBOUND;
+		wq = (ktask_nonuma_wq) ?: ktask_wq;
+	} else {
+		/*
+		 * WQ_UNBOUND workqueues, such as the one ktask uses,
+		 * execute work on some CPU from the node of the CPU we
+		 * pass to queue_work_on, so just pick any CPU to stand
+		 * for the node on NUMA systems.
+		 *
+		 * On non-NUMA systems, cpumask_of_node becomes
+		 * cpu_online_mask.
+		 */
+		cpu = cpumask_any(cpumask_of_node(kw->kw_queue_nid));
+		wq = ktask_wq;
+	}
+
+	WARN_ON(!queue_work_on(cpu, wq, &kw->kw_work));
+}
+
+#ifdef CONFIG_NUMA
+
+/* Returns true if we're migrating this part of the task to another node. */
+static bool ktask_node_migrate(struct ktask_node *old_kn, struct ktask_node *kn,
+			       size_t ktask_node_i, struct ktask_work *kw,
+			       struct ktask_task *kt)
+{
+	int new_queue_nid;
+
+	/*
+	 * Don't migrate a user thread, otherwise migrate only if we're going
+	 * to a different node.
+	 */
+	if (!(current->flags & PF_KTHREAD) || kn->kn_nid == old_kn->kn_nid ||
+	    num_online_nodes() == 1)
+		return false;
+
+	/* Adjust resource limits. */
+	spin_lock(&ktask_rlim_lock);
+	if (kw->kw_queue_nid != NUMA_NO_NODE)
+		--ktask_rlim_node_cur[kw->kw_queue_nid];
+
+	if (kn->kn_nid != NUMA_NO_NODE &&
+	    ktask_rlim_node_cur[kw->kw_queue_nid] <
+	    ktask_rlim_node_max[kw->kw_queue_nid]) {
+		new_queue_nid = kn->kn_nid;
+		++ktask_rlim_node_cur[new_queue_nid];
+	} else {
+		new_queue_nid = NUMA_NO_NODE;
+	}
+	spin_unlock(&ktask_rlim_lock);
+
+	ktask_init_work(kw, kt, ktask_node_i, new_queue_nid);
+	ktask_queue_work(kw);
+
+	return true;
+}
+
+#else /* CONFIG_NUMA */
+
+static bool ktask_node_migrate(struct ktask_node *old_kn, struct ktask_node *kn,
+			       size_t ktask_node_i, struct ktask_work *kw,
+			       struct ktask_task *kt)
+{
+	return false;
+}
+
+#endif /* CONFIG_NUMA */
+
+static void ktask_thread(struct work_struct *work)
+{
+	struct ktask_work  *kw;
+	struct ktask_task  *kt;
+	struct ktask_ctl   *kc;
+	struct ktask_node  *kn;
+	bool               done;
+
+	kw = container_of(work, struct ktask_work, kw_work);
+	kt = kw->kw_task;
+	kc = &kt->kt_ctl;
+	kn = &kt->kt_nodes[kw->kw_ktask_node_i];
+
+	mutex_lock(&kt->kt_mutex);
+
+	while (kt->kt_total_size > 0 && kt->kt_error == KTASK_RETURN_SUCCESS) {
+		void *start, *end;
+		size_t nsteps;
+		int ret;
+
+		if (kn->kn_task_size == 0) {
+			/* The current node is out of work; pick a new one. */
+			size_t remaining_nodes_seen = 0;
+			size_t new_idx = prandom_u32_max(kt->kt_nr_nodes_left);
+			struct ktask_node *old_kn;
+			size_t i;
+
+			WARN_ON(kt->kt_nr_nodes_left == 0);
+			WARN_ON(new_idx >= kt->kt_nr_nodes_left);
+			for (i = 0; i < kt->kt_nr_nodes; ++i) {
+				if (kt->kt_nodes[i].kn_task_size == 0)
+					continue;
+
+				if (remaining_nodes_seen >= new_idx)
+					break;
+
+				++remaining_nodes_seen;
+			}
+			/* We should have found work on another node. */
+			WARN_ON(i >= kt->kt_nr_nodes);
+
+			old_kn = kn;
+			kn = &kt->kt_nodes[i];
+
+			/* Start another worker on the node we've chosen. */
+			if (ktask_node_migrate(old_kn, kn, i, kw, kt)) {
+				mutex_unlock(&kt->kt_mutex);
+				return;
+			}
+		}
+
+		start = kn->kn_start;
+		nsteps = min(kt->kt_chunk_size, kn->kn_task_size);
+		end = kc->kc_iter_func(start, nsteps);
+		kn->kn_start = end;
+		WARN_ON(kn->kn_task_size < nsteps);
+		kn->kn_task_size -= nsteps;
+		WARN_ON(kt->kt_total_size < nsteps);
+		kt->kt_total_size -= nsteps;
+		if (kn->kn_task_size == 0) {
+			WARN_ON(kt->kt_nr_nodes_left == 0);
+			kt->kt_nr_nodes_left--;
+		}
+
+		mutex_unlock(&kt->kt_mutex);
+
+		ret = kc->kc_thread_func(start, end, kc->kc_thread_func_arg);
+
+		mutex_lock(&kt->kt_mutex);
+
+		if (ret == KTASK_RETURN_ERROR)
+			kt->kt_error = KTASK_RETURN_ERROR;
+	}
+
+	WARN_ON(kt->kt_nr_nodes_left > 0 &&
+		kt->kt_error == KTASK_RETURN_SUCCESS);
+
+	++kt->kt_nthreads_fini;
+	WARN_ON(kt->kt_nthreads_fini > kt->kt_nthreads);
+	done = (kt->kt_nthreads_fini == kt->kt_nthreads);
+	mutex_unlock(&kt->kt_mutex);
+
+	if (done)
+		complete(&kt->kt_ktask_done);
+}
+
+/*
+ * Returns the number of chunks to break this task into.
+ *
+ * The number of chunks will be at least the number of threads, but in the
+ * common case of a large task, the number of chunks will be greater to load
+ * balance the work between threads in case some threads finish their work more
+ * quickly than others.
+ */
+static inline size_t ktask_chunk_size(size_t task_size, size_t min_chunk_size,
+				    size_t nthreads)
+{
+	size_t chunk_size;
+
+	if (nthreads == 1)
+		return task_size;
+
+	chunk_size = (task_size / nthreads) >> KTASK_LOAD_BAL_SHIFT;
+
+	/*
+	 * chunk_size should be a multiple of min_chunk_size for tasks that
+	 * need to operate in fixed-size batches.
+	 */
+	if (chunk_size > min_chunk_size)
+		chunk_size = rounddown(chunk_size, min_chunk_size);
+
+	return max(chunk_size, min_chunk_size);
+}
+
+/*
+ * Prepares to run the task by computing the number of threads, checking
+ * the ktask resource limits, finding the chunk size, and initializing the
+ * work items.
+ */
+static size_t ktask_prepare_threads(struct ktask_node *nodes, size_t nr_nodes,
+				    struct ktask_task *kt,
+				    struct list_head *to_queue)
+{
+	size_t i, nthreads, nthreads_check;
+	size_t min_chunk_size = kt->kt_ctl.kc_min_chunk_size;
+	size_t max_threads    = kt->kt_ctl.kc_max_threads;
+
+	if (!ktask_wq)
+		return 1;
+
+	if (max_threads == 0)
+		max_threads = ktask_max_threads;
+
+	/* Ensure at least one thread when task_size < min_chunk_size. */
+	nthreads_check = DIV_ROUND_UP(kt->kt_total_size, min_chunk_size);
+	nthreads_check = min_t(size_t, nthreads_check, num_online_cpus());
+	nthreads_check = min_t(size_t, nthreads_check, max_threads);
+
+	/*
+	 * Use at least the current thread for this task; check whether
+	 * ktask_rlim allows additional work items to be queued.
+	 */
+	nthreads = 1;
+	spin_lock(&ktask_rlim_lock);
+	for (i = nthreads; i < nthreads_check; ++i) {
+		/* Spread threads across nodes evenly. */
+		size_t ktask_node_i = i % nr_nodes;
+		struct ktask_node *kn = &nodes[ktask_node_i];
+		struct ktask_work *kw;
+		int nid = kn->kn_nid;
+		int queue_nid;
+
+		WARN_ON(ktask_rlim_cur > ktask_rlim_max);
+		if (ktask_rlim_cur == ktask_rlim_max)
+			break;	/* No more work items allowed to be queued. */
+
+		/* Allowed to queue on requested node? */
+		if (nid != NUMA_NO_NODE &&
+		    ktask_rlim_node_cur[nid] < ktask_rlim_node_max[nid]) {
+			WARN_ON(ktask_rlim_node_cur[nid] > ktask_rlim_cur);
+			++ktask_rlim_node_cur[nid];
+			queue_nid = nid;
+		} else {
+			queue_nid = NUMA_NO_NODE;
+		}
+
+		BUG_ON(list_empty(&ktask_free_works));
+		kw = list_first_entry(&ktask_free_works, struct ktask_work,
+				      kw_list);
+		list_move_tail(&kw->kw_list, to_queue);
+		ktask_init_work(kw, kt, ktask_node_i, queue_nid);
+
+		++ktask_rlim_cur;
+		++nthreads;
+	}
+	spin_unlock(&ktask_rlim_lock);
+
+	return nthreads;
+}
+
+int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
+		   struct ktask_ctl *ctl)
+{
+	size_t i;
+	struct ktask_work kw;
+	struct ktask_work *kw_cur, *kw_next;
+	LIST_HEAD(to_queue);
+	struct ktask_task kt = {
+		.kt_ctl             = *ctl,
+		.kt_total_size      = 0,
+		.kt_nodes           = nodes,
+		.kt_nr_nodes        = nr_nodes,
+		.kt_nr_nodes_left   = nr_nodes,
+		.kt_nthreads_fini   = 0,
+		.kt_error           = KTASK_RETURN_SUCCESS,
+	};
+
+	for (i = 0; i < nr_nodes; ++i) {
+		kt.kt_total_size += nodes[i].kn_task_size;
+		if (nodes[i].kn_task_size == 0)
+			kt.kt_nr_nodes_left--;
+
+		WARN_ON(nodes[i].kn_nid >= MAX_NUMNODES);
+	}
+
+	if (kt.kt_total_size == 0)
+		return KTASK_RETURN_SUCCESS;
+
+	mutex_init(&kt.kt_mutex);
+
+	kt.kt_nthreads = ktask_nthreads(kt.kt_total_size,
+					ctl->kc_min_chunk_size,
+					ctl->kc_max_threads);
+
+	kt.kt_chunk_size = ktask_chunk_size(kt.kt_total_size,
+					ctl->kc_min_chunk_size, kt.kt_nthreads);
+
+	init_completion(&kt.kt_ktask_done);
+
+	kt.kt_nthreads = ktask_prepare_threads(nodes, nr_nodes, &kt, &to_queue);
+	kt.kt_chunk_size = ktask_chunk_size(kt.kt_total_size,
+					    ctl->kc_min_chunk_size,
+					    kt.kt_nthreads);
+
+	list_for_each_entry_safe(kw_cur, kw_next, &to_queue, kw_list)
+		ktask_queue_work(kw_cur);
+
+	/*
+	 * Make ourselves one of the threads, which saves launching a workqueue
+	 * worker.
+	 */
+	INIT_WORK(&kw.kw_work, ktask_thread);
+	kw.kw_task = &kt;
+	kw.kw_ktask_node_i = 0;
+	ktask_thread(&kw.kw_work);
+
+	/* Wait for all the jobs to finish. */
+	wait_for_completion(&kt.kt_ktask_done);
+
+	spin_lock(&ktask_rlim_lock);
+
+	/* Put the works back on the free list, adjusting rlimits. */
+	list_for_each_entry_safe(kw_cur, kw_next, &to_queue, kw_list) {
+		if (kw_cur->kw_queue_nid != NUMA_NO_NODE) {
+			WARN_ON(ktask_rlim_node_cur[kw_cur->kw_queue_nid] == 0);
+			--ktask_rlim_node_cur[kw_cur->kw_queue_nid];
+		}
+		WARN_ON(ktask_rlim_cur == 0);
+		--ktask_rlim_cur;
+	}
+	list_splice(&to_queue, &ktask_free_works);
+	spin_unlock(&ktask_rlim_lock);
+
+	mutex_destroy(&kt.kt_mutex);
+
+	return kt.kt_error;
+}
+EXPORT_SYMBOL_GPL(ktask_run_numa);
+
+int ktask_run(void *start, size_t task_size, struct ktask_ctl *ctl)
+{
+	struct ktask_node node;
+
+	node.kn_start = start;
+	node.kn_task_size = task_size;
+	node.kn_nid = numa_node_id();
+
+	return ktask_run_numa(&node, 1, ctl);
+}
+EXPORT_SYMBOL_GPL(ktask_run);
+
+/*
+ * Initialize internal limits on work items queued.  Work items submitted to
+ * cmwq capped at 80% of online cpus both system-wide and per-node to maintain
+ * an efficient level of parallelization at these respective levels.
+ */
+bool ktask_rlim_init(void)
+{
+	int node;
+	unsigned nr_node_cpus;
+
+	spin_lock_init(&ktask_rlim_lock);
+
+	ktask_rlim_node_cur = kcalloc(num_possible_nodes(),
+					       sizeof(size_t),
+					       GFP_KERNEL);
+	if (!ktask_rlim_node_cur) {
+		pr_warn("can't alloc rlim counts (ktask disabled)");
+		return false;
+	}
+
+	ktask_rlim_node_max = kmalloc_array(num_possible_nodes(),
+						     sizeof(size_t),
+						     GFP_KERNEL);
+	if (!ktask_rlim_node_max) {
+		kfree(ktask_rlim_node_cur);
+		pr_warn("can't alloc rlim maximums (ktask disabled)");
+		return false;
+	}
+
+	ktask_rlim_max = mult_frac(num_online_cpus(), KTASK_CPUFRAC_NUMER,
+						      KTASK_CPUFRAC_DENOM);
+	for_each_node(node) {
+		nr_node_cpus = cpumask_weight(cpumask_of_node(node));
+		ktask_rlim_node_max[node] = mult_frac(nr_node_cpus,
+						      KTASK_CPUFRAC_NUMER,
+						      KTASK_CPUFRAC_DENOM);
+	}
+
+	return true;
+}
+
+void __init ktask_init(void)
+{
+	struct workqueue_attrs *attrs;
+	int i, ret;
+
+	if (!ktask_rlim_init())
+		goto out;
+
+	ktask_works = kmalloc_array(ktask_rlim_max, sizeof(struct ktask_work),
+				    GFP_KERNEL);
+	if (!ktask_works) {
+		pr_warn("failed to alloc ktask_works (ktask disabled)");
+		goto out;
+	}
+	for (i = 0; i < ktask_rlim_max; ++i)
+		list_add_tail(&ktask_works[i].kw_list, &ktask_free_works);
+
+	ktask_wq = alloc_workqueue("ktask_wq", WQ_UNBOUND, 0);
+	if (!ktask_wq) {
+		pr_warn("failed to alloc ktask_wq (ktask disabled)");
+		goto out;
+	}
+
+	/*
+	 * Threads executing work from this workqueue can run on any node on
+	 * the system.  If we get any failures below, use ktask_wq in its
+	 * place.  It's better than nothing.
+	 */
+	ktask_nonuma_wq = alloc_workqueue("ktask_nonuma_wq", WQ_UNBOUND, 0);
+	if (!ktask_nonuma_wq) {
+		pr_warn("failed to alloc ktask_nonuma_wq");
+		goto out;
+	}
+
+	attrs = alloc_workqueue_attrs(GFP_KERNEL);
+	if (!attrs) {
+		pr_warn("alloc_workqueue_attrs failed");
+		goto alloc_fail;
+	}
+
+	attrs->no_numa = true;
+
+	ret = apply_workqueue_attrs(ktask_nonuma_wq, attrs);
+	if (ret != 0) {
+		pr_warn("apply_workqueue_attrs failed");
+		goto apply_fail;
+	}
+
+	free_workqueue_attrs(attrs);
+out:
+	return;
+
+apply_fail:
+	free_workqueue_attrs(attrs);
+alloc_fail:
+	destroy_workqueue(ktask_nonuma_wq);
+	ktask_nonuma_wq = NULL;
+}
+
+#endif /* CONFIG_KTASK */
+
+/*
+ * This function is defined outside CONFIG_KTASK so it can be called in the
+ * !CONFIG_KTASK versions of ktask_run and ktask_run_numa.
+ */
+void *ktask_iter_range(void *position, size_t nsteps)
+{
+	return (char *)position + nsteps;
+}
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
