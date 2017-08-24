Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05405440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:48:48 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 50so356700uaf.9
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:48:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d3si1220540uai.324.2017.08.24.13.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 13:48:46 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 2/7] ktask: multithread cpu-intensive kernel work
Date: Thu, 24 Aug 2017 16:49:59 -0400
Message-Id: <20170824205004.18502-3-daniel.m.jordan@oracle.com>
In-Reply-To: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
References: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

ktask is a generic framework for parallelizing cpu-intensive work in the
kernel.  The intended use is for big machines that can use their cpu power to
speed up large tasks that can't otherwise be multithreaded in userland.  The
API is generic enough to add concurrency to many different kinds of tasks--for
example, zeroing a range of pages or evicting a list of inodes--and aims to
save its clients the trouble of splitting up the work, choosing the number of
threads to use, starting these threads, and load balancing the work between
them.

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
 include/linux/ktask.h          | 235 ++++++++++++++++++++++++
 include/linux/ktask_internal.h |  19 ++
 include/linux/mm.h             |   6 +
 init/Kconfig                   |   7 +
 init/main.c                    |   2 +
 kernel/Makefile                |   2 +-
 kernel/ktask.c                 | 396 +++++++++++++++++++++++++++++++++++++++++
 7 files changed, 666 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/ktask.h
 create mode 100644 include/linux/ktask_internal.h
 create mode 100644 kernel/ktask.c

diff --git a/include/linux/ktask.h b/include/linux/ktask.h
new file mode 100644
index 000000000000..269c795039e7
--- /dev/null
+++ b/include/linux/ktask.h
@@ -0,0 +1,235 @@
+/*
+ * ktask.h
+ *
+ * Framework to parallelize cpu-intensive kernel work such as zeroing
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
+struct ktask_ctl;
+struct ktask_node;
+
+#define	KTASK_RETURN_SUCCESS	0
+#define	KTASK_RETURN_ERROR	(-1)
+
+#ifdef CONFIG_KTASK
+
+/**
+ * ktask_run - Runs one task.  It doesn't account for NUMA locality.
+ *
+ * @start: An object that describes the start of the task.  The client thread
+ *         function interprets the object however it sees fit (e.g. an array
+ *         index, a simple pointer, or a pointer to a more complicated
+ *         representation of job position.
+ * @task_size:  The size of the task (units are task-specific).
+ * @ctl:  A control structure containing information about the task, including
+ *        the client thread function (see the definition of struct ktask_ctl).
+ *
+ * RETURNS:
+ * KTASK_RETURN_SUCCESS or KTASK_RETURN_ERROR.
+ */
+int ktask_run(void *start, size_t task_size, struct ktask_ctl *ctl);
+
+/**
+ * ktask_run_numa - Runs one task while accounting for NUMA locality.
+ *
+ * The ktask framework ensures worker threads are scheduled on a CPU local to
+ * each chunk of a task.  The client is responsible for organizing the work
+ * along NUMA boundaries in the 'nodes' array.
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
+/*
+ * Two possible future enhancements related to error handling, should the
+ * need arise, are:
+ *
+ * - Add client specific error reporting.  It's possible for tasks to fail for
+ *   different reasons, so let the client pass a pointer for its own error
+ *   information.
+ *
+ * - Allow clients to pass an "undo" callback to ktask that is responsible for
+ *   undoing those parts of the task that fail if an error occurs.
+ */
+
+void ktask_init(void);
+
+#else  /* CONFIG_KTASK */
+
+#define ktask_run(start, task_size, ctl)				      \
+	((ctl)->kc_thread_func((start),				              \
+			       (ctl)->kc_iter_advance((start), (task_size)),  \
+			       (ctl)->kc_thread_func_arg))
+
+#define ktask_run_numa(nodes, nr_nodes, ctl)				      \
+({									      \
+	size_t __i;							      \
+	int __ret = KTASK_RETURN_SUCCESS;				      \
+									      \
+	for (__i = 0; __i < (nr_nodes); ++__i) {			      \
+		__ret = (ctl)->kc_thread_func(				      \
+			    (nodes)->kn_start,				      \
+			    (ctl)->kc_iter_advance((nodes)->kn_start,	      \
+						   (nodes)->kn_task_size),    \
+			    (ctl)->kc_thread_func_arg);			      \
+									      \
+		if (__ret == KTASK_RETURN_ERROR)			      \
+			break;						      \
+	}								      \
+									      \
+	__ret;								      \
+})
+
+static inline void ktask_init(void) { }
+
+#endif /* CONFIG_KTASK */
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
+ * range.  Clients should use this to avoid reinventing the wheel for this
+ * common case.
+ *
+ * This is an instance of 'ktask_iter_func' where 'position' is interpreted as
+ * an unsigned long.
+ *
+ * @position: An object that describes the current position in the task.
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
+ * @kc_iter_advance: An iterator function to advance the iterator by some number
+ *                   of task-specific units.
+ * @kc_min_chunk_size: The minimum chunk size in task-specific units.  This
+ *                     allows the client to communicate the minimum amount of
+ *                     work that's appropriate for one worker thread to do at
+ *                     once.
+ * @kc_max_threads: The maximum number of threads to use for the task.
+ *                  The actual number used may be less than this if the
+ *                  framework determines that fewer threads would be better,
+ *                  taking into account such things as total cpu count and
+ *                  task size.  Pass 0 to use ktask's default maximum.
+ * @kc_gfp_flags: gfp flags for allocating ktask metadata during the task.
+ */
+struct ktask_ctl {
+	ktask_thread_func	kc_thread_func;
+	void			*kc_thread_func_arg;
+	ktask_iter_func		kc_iter_advance;
+	size_t			kc_min_chunk_size;
+	size_t			kc_max_threads;
+	gfp_t			kc_gfp_flags;
+};
+
+#define KTASK_CTL_INITIALIZER(thread_func, thread_func_arg, iter_advance, \
+			      min_chunk_size, max_threads, gfp_flags)	  \
+	{								  \
+		.kc_thread_func = (ktask_thread_func)(thread_func),	  \
+		.kc_thread_func_arg = (thread_func_arg),		  \
+		.kc_iter_advance = (iter_advance),			  \
+		.kc_min_chunk_size = (min_chunk_size),			  \
+		.kc_max_threads = (max_threads),			  \
+		.kc_gfp_flags = (gfp_flags),				  \
+	}
+
+/*
+ * Note that KTASK_CTL_INITIALIZER casts 'thread_func' to be of type
+ * ktask_thread_func.  This is to help clients write cleaner thread functions
+ * by relieving them of the need to cast the three void * arguments.  Clients
+ * can just use the actual argument types instead.
+ */
+#define DEFINE_KTASK_CTL(ctl_name, thread_func, thread_func_arg,	  \
+			 iter_advance, min_chunk_size, max_threads,	  \
+			 gfp_flags)					  \
+	struct ktask_ctl ctl_name =					  \
+		KTASK_CTL_INITIALIZER(thread_func, thread_func_arg,	  \
+				      iter_advance, min_chunk_size,	  \
+				      kc_max_threads, gfp_flags)
+/*
+ * Similar to DEFINE_KTASK_CTL, but omits the iterator argument in favor of
+ * using ktask_iter_range.
+ */
+#define DEFINE_KTASK_CTL_RANGE(ctl_name, thread_func, thread_func_arg,	  \
+			 min_chunk_size, kc_max_threads, gfp_flags)	  \
+	struct ktask_ctl ctl_name =					  \
+		KTASK_CTL_INITIALIZER(thread_func, thread_func_arg,	  \
+				      ktask_iter_range, min_chunk_size,	  \
+				      kc_max_threads, gfp_flags)
+
+#endif /* _LINUX_KTASK_H */
diff --git a/include/linux/ktask_internal.h b/include/linux/ktask_internal.h
new file mode 100644
index 000000000000..7b576f4b0ada
--- /dev/null
+++ b/include/linux/ktask_internal.h
@@ -0,0 +1,19 @@
+/*
+ * ktask_internal.h
+ *
+ * Framework to parallelize cpu-intensive kernel work such as zeroing
+ * huge pages or freeing many pages at once.  For more information, see
+ * Documentation/core-api/ktask.rst.
+ *
+ * This file contains implementation details of ktask for core kernel code that
+ * needs to be aware of them.  ktask clients should not include this file.
+ */
+#ifndef _LINUX_KTASK_INTERNAL_H
+#define _LINUX_KTASK_INTERNAL_H
+
+#ifdef CONFIG_KTASK
+/* Caps the number of threads that are allowed to be used in one task. */
+extern int ktask_max_threads;
+#endif
+
+#endif /* _LINUX_KTASK_INTERNAL_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5e8569..ccf9e8957098 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2557,5 +2557,11 @@ void __init setup_nr_node_ids(void);
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
index 8514b25db21c..80ebb5296a38 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -332,6 +332,13 @@ config AUDIT_TREE
 	depends on AUDITSYSCALL
 	select FSNOTIFY
 
+config KTASK
+	bool "Multithread cpu-intensive kernel tasks"
+	depends on SMP
+	default n
+	help
+          Parallelize expensive kernel tasks such as zeroing huge pages.
+
 source "kernel/irq/Kconfig"
 source "kernel/time/Kconfig"
 
diff --git a/init/main.c b/init/main.c
index 052481fbe363..1b7ddb6db6ad 100644
--- a/init/main.c
+++ b/init/main.c
@@ -88,6 +88,7 @@
 #include <linux/io.h>
 #include <linux/cache.h>
 #include <linux/rodata_test.h>
+#include <linux/ktask.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -1051,6 +1052,7 @@ static noinline void __init kernel_init_freeable(void)
 
 	smp_init();
 	sched_init_smp();
+	ktask_init();
 
 	page_alloc_init_late();
 
diff --git a/kernel/Makefile b/kernel/Makefile
index 4cb8e8b23c6e..297fe901be14 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -9,7 +9,7 @@ obj-y     = fork.o exec_domain.o panic.o \
 	    extable.o params.o \
 	    kthread.o sys_ni.o nsproxy.o \
 	    notifier.o ksysfs.o cred.o reboot.o \
-	    async.o range.o smpboot.o ucount.o
+	    async.o range.o smpboot.o ucount.o ktask.o
 
 obj-$(CONFIG_MULTIUSER) += groups.o
 
diff --git a/kernel/ktask.c b/kernel/ktask.c
new file mode 100644
index 000000000000..3a414b65d59f
--- /dev/null
+++ b/kernel/ktask.c
@@ -0,0 +1,396 @@
+/*
+ * ktask.c
+ *
+ * Framework to parallelize cpu-intensive kernel work such as zeroing
+ * huge pages or freeing many pages at once.  For more information, see
+ * Documentation/core-api/ktask.rst.
+ *
+ * This is the ktask implementation; everything in this file is private to
+ * ktask.
+ */
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
+#include <linux/mutex.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/slab.h>
+#include <linux/workqueue.h>
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
+
+/* Used to pass ktask state to the workqueue API. */
+struct ktask_work {
+	struct work_struct kw_work;
+	void               *kw_state;
+};
+
+/* Internal per-task state hidden from clients. */
+struct ktask_state {
+	struct ktask_ctl	ks_ctl;
+	size_t			ks_total_size;
+	size_t			ks_chunk_size;
+	/* mutex protects nodes, nr_nodes_left, nthreads_fini, error */
+	struct mutex		ks_mutex;
+	struct ktask_node	*ks_nodes;
+	size_t			ks_nr_nodes;
+	size_t			ks_nr_nodes_left;
+	size_t			ks_nthreads;
+	size_t			ks_nthreads_fini;
+	int			ks_error; /* tracks error(s) from thread_func */
+	struct completion	ks_ktask_done;
+};
+
+static inline size_t ktask_get_start_node(struct ktask_node *nodes,
+					  size_t nr_nodes)
+{
+	int cur_nid = numa_node_id();
+	size_t fallback_i = 0;
+	size_t i;
+
+	for (i = 0; i < nr_nodes; ++i) {
+		if (nodes[i].kn_nid == cur_nid)
+			break;
+		else if (nodes[i].kn_nid == NUMA_NO_NODE)
+			fallback_i = i;
+	}
+
+	if (i >= nr_nodes)
+		i = fallback_i;
+
+	return i;
+}
+
+static void ktask_node_migrate(cpumask_var_t *saved_cpumask,
+			       struct ktask_node *old_kn,
+			       struct ktask_node *kn,
+			       gfp_t gfp_flags, bool *migratedp)
+{
+	struct task_struct *p = current;
+	const struct cpumask *node_cpumask;
+	int ret;
+
+	/*
+	 * Don't migrate a user thread, migrating to NUMA_NO_NODE is
+	 * nonsense, and no need to migrate if it's the same node.
+	 */
+	if (!(p->flags & PF_KTHREAD) || kn->kn_nid == NUMA_NO_NODE ||
+	    kn->kn_nid == old_kn->kn_nid)
+		return;
+
+	node_cpumask = cpumask_of_node(kn->kn_nid);
+	/* No cpu to migrate to. */
+	if (cpumask_empty(node_cpumask))
+		return;
+
+	if (!*migratedp) {
+		/*
+		 * Save the workqueue thread's original mask so we can restore
+		 * it after the task is done.
+		 */
+		if (!alloc_cpumask_var(saved_cpumask, gfp_flags))
+			return;
+
+		cpumask_copy(*saved_cpumask, &p->cpus_allowed);
+	}
+
+	ret = set_cpus_allowed_ptr(current, node_cpumask);
+	if (ret == 0)
+		*migratedp = true;
+	else if (!*migratedp)
+		free_cpumask_var(*saved_cpumask);
+}
+
+static void ktask_task(struct work_struct *work)
+{
+	struct ktask_work  *kw;
+	struct ktask_state *ks;
+	struct ktask_ctl   *kc;
+	struct ktask_node  *kn;
+	size_t             nidx;
+	bool               done;
+	bool               migrated = false;
+	cpumask_var_t      saved_cpumask;
+
+	kw = container_of(work, struct ktask_work, kw_work);
+	ks = kw->kw_state;
+	kc = &ks->ks_ctl;
+
+	if (ks->ks_nr_nodes > 1)
+		nidx = ktask_get_start_node(ks->ks_nodes, ks->ks_nr_nodes);
+	else
+		nidx = 0;
+
+	WARN_ON(nidx >= ks->ks_nr_nodes);
+	kn = &ks->ks_nodes[nidx];
+
+	mutex_lock(&ks->ks_mutex);
+
+	while (ks->ks_total_size > 0 && ks->ks_error == KTASK_RETURN_SUCCESS) {
+		void *start, *end;
+		size_t nsteps;
+		int ret;
+
+		if (kn->kn_task_size == 0) {
+			/* The current node is out of work; pick a new one. */
+			size_t remaining_nodes_seen = 0;
+			size_t new_idx = prandom_u32_max(ks->ks_nr_nodes_left);
+			struct ktask_node *old_kn;
+
+			WARN_ON(ks->ks_nr_nodes_left == 0);
+			WARN_ON(new_idx >= ks->ks_nr_nodes_left);
+			for (nidx = 0; nidx < ks->ks_nr_nodes; ++nidx) {
+				if (ks->ks_nodes[nidx].kn_task_size == 0)
+					continue;
+
+				if (remaining_nodes_seen >= new_idx)
+					break;
+
+				++remaining_nodes_seen;
+			}
+			/* We should have found work on another node. */
+			WARN_ON(nidx >= ks->ks_nr_nodes);
+
+			old_kn = kn;
+			kn = &ks->ks_nodes[nidx];
+
+			/* Temporarily migrate to the node we just chose. */
+			ktask_node_migrate(&saved_cpumask, old_kn, kn,
+					   kc->kc_gfp_flags, &migrated);
+		}
+
+		start = kn->kn_start;
+		nsteps = min(ks->ks_chunk_size, kn->kn_task_size);
+		end = kc->kc_iter_advance(start, nsteps);
+		kn->kn_start = end;
+		WARN_ON(kn->kn_task_size < nsteps);
+		kn->kn_task_size -= nsteps;
+		WARN_ON(ks->ks_total_size < nsteps);
+		ks->ks_total_size -= nsteps;
+		if (kn->kn_task_size == 0) {
+			WARN_ON(ks->ks_nr_nodes_left == 0);
+			ks->ks_nr_nodes_left--;
+		}
+
+		mutex_unlock(&ks->ks_mutex);
+
+		ret = kc->kc_thread_func(start, end, kc->kc_thread_func_arg);
+
+		mutex_lock(&ks->ks_mutex);
+
+		if (ret == KTASK_RETURN_ERROR)
+			ks->ks_error = KTASK_RETURN_ERROR;
+	}
+
+	WARN_ON(ks->ks_nr_nodes_left > 0 &&
+		ks->ks_error == KTASK_RETURN_SUCCESS);
+
+	++ks->ks_nthreads_fini;
+	WARN_ON(ks->ks_nthreads_fini > ks->ks_nthreads);
+	done = (ks->ks_nthreads_fini == ks->ks_nthreads);
+	mutex_unlock(&ks->ks_mutex);
+
+	if (migrated) {
+		set_cpus_allowed_ptr(current, saved_cpumask);
+		free_cpumask_var(saved_cpumask);
+	}
+
+	if (done)
+		complete(&ks->ks_ktask_done);
+}
+
+/* Returns the number of threads to use for this task. */
+static inline size_t ktask_nthreads(size_t task_size, size_t min_chunk_size,
+				    size_t max_threads)
+{
+	size_t nthreads;
+
+	if (max_threads == 0)
+		max_threads = ktask_max_threads;
+
+	/* Ensure at least one thread when task_size < min_chunk_size. */
+	nthreads = DIV_ROUND_UP(task_size, min_chunk_size);
+
+	nthreads = min_t(size_t, nthreads, num_online_cpus());
+
+	nthreads = min_t(size_t, nthreads, max_threads);
+
+	return nthreads;
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
+int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
+		   struct ktask_ctl *ctl)
+{
+	size_t i;
+	struct ktask_work *kw;
+	struct ktask_state ks = {
+		.ks_ctl             = *ctl,
+		.ks_total_size        = 0,
+		.ks_nodes           = nodes,
+		.ks_nr_nodes        = nr_nodes,
+		.ks_nr_nodes_left   = nr_nodes,
+		.ks_nthreads_fini   = 0,
+		.ks_error           = KTASK_RETURN_SUCCESS,
+	};
+
+	for (i = 0; i < nr_nodes; ++i) {
+		ks.ks_total_size += nodes[i].kn_task_size;
+		if (nodes[i].kn_task_size == 0)
+			ks.ks_nr_nodes_left--;
+
+		WARN_ON(nodes[i].kn_nid >= MAX_NUMNODES);
+	}
+
+	if (ks.ks_total_size == 0)
+		return KTASK_RETURN_SUCCESS;
+
+	mutex_init(&ks.ks_mutex);
+
+	ks.ks_nthreads = ktask_nthreads(ks.ks_total_size,
+					ctl->kc_min_chunk_size,
+					ctl->kc_max_threads);
+
+	ks.ks_chunk_size = ktask_chunk_size(ks.ks_total_size,
+					ctl->kc_min_chunk_size, ks.ks_nthreads);
+
+	init_completion(&ks.ks_ktask_done);
+
+	kw = kmalloc_array(ks.ks_nthreads, sizeof(struct ktask_work),
+			    ctl->kc_gfp_flags);
+	if (unlikely(!kw || !ktask_wq)) {
+		/* Low on memory; fall back to a single thread. */
+		struct ktask_work kw = {
+			.kw_work = __WORK_INITIALIZER(kw.kw_work, ktask_task),
+			.kw_state = &ks
+		};
+
+		ks.ks_nthreads = 1;
+
+		ktask_task(&kw.kw_work);
+		mutex_destroy(&ks.ks_mutex);
+
+		return ks.ks_error;
+	}
+
+	for (i = 1; i < ks.ks_nthreads; ++i) {
+		int cpu;
+		struct ktask_node *kn;
+
+		INIT_WORK(&kw[i].kw_work, ktask_task);
+		kw[i].kw_state = &ks;
+
+		/*
+		 * Spread workers evenly across nodes with work to do,
+		 * starting each worker on a cpu local to the nid of their
+		 * part of the task.
+		 */
+		kn = &nodes[i % nr_nodes];
+
+		if (kn->kn_nid == NUMA_NO_NODE) {
+			cpu = smp_processor_id();
+		} else {
+			/*
+			 * WQ_UNBOUND workqueues execute work on a cpu from
+			 * the node of the cpu we pass to queue_work_on, so
+			 * just pick any cpu to stand for the node.
+			 */
+			cpu = cpumask_any(cpumask_of_node(kn->kn_nid));
+		}
+
+		queue_work_on(cpu, ktask_wq, &kw[i].kw_work);
+	}
+
+	/*
+	 * Make ourselves one of the threads, which saves launching a workqueue
+	 * worker.
+	 */
+	INIT_WORK(&kw[0].kw_work, ktask_task);
+	kw[0].kw_state = &ks;
+	ktask_task(&kw[0].kw_work);
+
+	/* Wait for all the jobs to finish. */
+	wait_for_completion(&ks.ks_ktask_done);
+
+	kfree(kw);
+	mutex_destroy(&ks.ks_mutex);
+
+	return ks.ks_error;
+}
+EXPORT_SYMBOL_GPL(ktask_run_numa);
+
+int ktask_run(void *start, size_t task_size, struct ktask_ctl *ctl)
+{
+	struct ktask_node node;
+
+	node.kn_start = start;
+	node.kn_task_size = task_size;
+	node.kn_nid = NUMA_NO_NODE;
+
+	return ktask_run_numa(&node, 1, ctl);
+}
+EXPORT_SYMBOL_GPL(ktask_run);
+
+void __init ktask_init(void)
+{
+	ktask_wq = alloc_workqueue("ktask_wq", WQ_UNBOUND, 0);
+	if (!ktask_wq)
+		pr_warn("%s: alloc_workqueue failed", __func__);
+}
+
+#endif /* CONFIG_KTASK */
+
+/*
+ * This function is defined outside CONFIG_KTASK so it can be called in the
+ * ktask_run and ktask_run_numa macros defined in ktask.h for CONFIG_KTASK=n
+ * kernels.
+ */
+void *ktask_iter_range(void *position, size_t nsteps)
+{
+	return (char *)position + nsteps;
+}
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
