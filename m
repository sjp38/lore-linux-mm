Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58C126B0279
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:45 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id v132-v6so7862570ywb.15
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:45 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h129-v6si26059987ywe.313.2018.11.05.08.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:42 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 02/13] ktask: multithread CPU-intensive kernel work
Date: Mon,  5 Nov 2018 11:55:47 -0500
Message-Id: <20181105165558.11698-3-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

A single CPU can spend an excessive amount of time in the kernel operating on
large amounts of data.  Often these situations arise during initialization- and
destruction-related tasks, where the data involved scales with system size.
These long-running jobs can slow startup and shutdown of applications and the
system itself while extra CPUs sit idle.

To ensure that applications and the kernel continue to perform well as
core counts and memory sizes increase, harness these idle CPUs to
complete such jobs more quickly.

ktask is a generic framework for parallelizing CPU-intensive work in the
kernel.  The API is generic enough to add concurrency to many different
kinds of tasks--for example, zeroing a range of pages or evicting a list
of inodes--and aims to save its clients the trouble of splitting up the
work, choosing the number of threads to use, maintaining an efficient
concurrency level, starting these threads, and load balancing the work
between them.

The Documentation patch earlier in this series, from which the above was
swiped, has more background.

Inspired by work from Pavel Tatashin, Steve Sistare, and Jonathan Adams.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Suggested-by: Pavel Tatashin <Pavel.Tatashin@microsoft.com>
Suggested-by: Steve Sistare <steven.sistare@oracle.com>
Suggested-by: Jonathan Adams <jwadams@google.com>
---
 include/linux/ktask.h | 237 +++++++++++++++++++
 init/Kconfig          |  11 +
 init/main.c           |   2 +
 kernel/Makefile       |   2 +-
 kernel/ktask.c        | 526 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 777 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/ktask.h
 create mode 100644 kernel/ktask.c

diff --git a/include/linux/ktask.h b/include/linux/ktask.h
new file mode 100644
index 000000000000..9c75a93b51b9
--- /dev/null
+++ b/include/linux/ktask.h
@@ -0,0 +1,237 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * ktask.h - framework to parallelize CPU-intensive kernel work
+ *
+ * For more information, see Documentation/core-api/ktask.rst.
+ *
+ * Copyright (c) 2018 Oracle Corporation
+ * Author: Daniel Jordan <daniel.m.jordan@oracle.com>
+ */
+#ifndef _LINUX_KTASK_H
+#define _LINUX_KTASK_H
+
+#include <linux/mm.h>
+#include <linux/types.h>
+
+#define	KTASK_RETURN_SUCCESS	0
+
+/**
+ * struct ktask_node - Holds per-NUMA-node information about a task.
+ *
+ * @kn_start: An object that describes the start of the task on this NUMA node.
+ * @kn_task_size: size of this node's work (units are task-specific)
+ * @kn_nid: NUMA node id to run threads on
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
+ * Called on each chunk of work that a ktask thread does.  A thread may call
+ * this multiple times during one task.
+ *
+ * @start: An object that describes the start of the chunk.
+ * @end: An object that describes the end of the chunk.
+ * @arg: The thread function argument (provided with struct ktask_ctl).
+ *
+ * RETURNS:
+ * KTASK_RETURN_SUCCESS or a client-specific nonzero error code.
+ */
+typedef int (*ktask_thread_func)(void *start, void *end, void *arg);
+
+/**
+ * typedef ktask_iter_func
+ *
+ * An iterator function that advances the position by size units.
+ *
+ * @position: An object that describes the current position in the task.
+ * @size: The amount to advance in the task (in task-specific units).
+ *
+ * RETURNS:
+ * An object representing the new position.
+ */
+typedef void *(*ktask_iter_func)(void *position, size_t size);
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
+ * @size: The amount to advance in the task (in task-specific units).
+ *
+ * RETURNS:
+ * (position + size)
+ */
+void *ktask_iter_range(void *position, size_t size);
+
+/**
+ * struct ktask_ctl - Client-provided per-task control information.
+ *
+ * @kc_thread_func: A thread function that completes one chunk of the task per
+ *                  call.
+ * @kc_func_arg: An argument to be passed to the thread and undo functions.
+ * @kc_iter_func: An iterator function to advance the iterator by some number
+ *                   of task-specific units.
+ * @kc_min_chunk_size: The minimum chunk size in task-specific units.  This
+ *                     allows the client to communicate the minimum amount of
+ *                     work that's appropriate for one worker thread to do at
+ *                     once.
+ * @kc_max_threads: max threads to use for the task, actual number may be less
+ *                  depending on CPU count, task size, and minimum chunk size.
+ */
+struct ktask_ctl {
+	/* Required arguments set with DEFINE_KTASK_CTL. */
+	ktask_thread_func	kc_thread_func;
+	void			*kc_func_arg;
+	size_t			kc_min_chunk_size;
+
+	/* Optional, can set with ktask_ctl_set_*.  Defaults on the right. */
+	ktask_iter_func		kc_iter_func;    /* ktask_iter_range */
+	size_t			kc_max_threads;  /* 0 (uses internal limit) */
+};
+
+#define KTASK_CTL_INITIALIZER(thread_func, func_arg, min_chunk_size)	     \
+	{								     \
+		.kc_thread_func = (ktask_thread_func)(thread_func),	     \
+		.kc_func_arg = (func_arg),				     \
+		.kc_min_chunk_size = (min_chunk_size),			     \
+		.kc_iter_func = (ktask_iter_range),			     \
+		.kc_max_threads = 0,					     \
+	}
+
+/*
+ * KTASK_CTL_INITIALIZER casts 'thread_func' to be of type ktask_thread_func so
+ * clients can write cleaner thread functions by relieving them of the need to
+ * cast the three void * arguments.  Clients can just use the actual argument
+ * types instead.
+ */
+#define DEFINE_KTASK_CTL(ctl_name, thread_func, func_arg, min_chunk_size)    \
+	struct ktask_ctl ctl_name =					     \
+		KTASK_CTL_INITIALIZER(thread_func, func_arg, min_chunk_size) \
+
+/**
+ * ktask_ctl_set_iter_func - Set a task-specific iterator
+ *
+ * Overrides the default iterator, ktask_iter_range.
+ *
+ * Casts the type of the iterator function so its arguments can be
+ * client-specific (see the comment above DEFINE_KTASK_CTL).
+ *
+ * @ctl:  A control structure containing information about the task.
+ * @iter_func:  Walks a given number of units forward in the task, returning
+ *              an iterator corresponding to the new position.
+ */
+#define ktask_ctl_set_iter_func(ctl, iter_func)				\
+	((ctl)->kc_iter_func = (ktask_iter_func)(iter_func))
+
+/**
+ * ktask_ctl_set_max_threads - Set a task-specific maximum number of threads
+ *
+ * This overrides the default maximum, which is KTASK_DEFAULT_MAX_THREADS.
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
+/*
+ * The minimum chunk sizes for tasks that operate on ranges of memory.  For
+ * now, say 128M.
+ */
+#define	KTASK_MEM_CHUNK		(1ul << 27)
+#define	KTASK_PTE_MINCHUNK	(KTASK_MEM_CHUNK / PAGE_SIZE)
+#define	KTASK_PMD_MINCHUNK	(KTASK_MEM_CHUNK / PMD_SIZE)
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
+ * KTASK_RETURN_SUCCESS or a client-specific nonzero error code.
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
+ * @nodes: An array of nodes.
+ * @nr_nodes:  Length of the 'nodes' array.
+ * @ctl:  Control structure containing information about the task.
+ *
+ * RETURNS:
+ * KTASK_RETURN_SUCCESS or a client-specific nonzero error code.
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
+	return ctl->kc_thread_func(start, ctl->kc_iter_func(start, task_size),
+				   ctl->kc_func_arg);
+}
+
+static inline int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
+				 struct ktask_ctl *ctl)
+{
+	size_t i;
+	int err = KTASK_RETURN_SUCCESS;
+
+	for (i = 0; i < nr_nodes; ++i) {
+		void *start = nodes[i].kn_start;
+		void *end = ctl->kc_iter_func(start, nodes[i].kn_task_size);
+
+		err = ctl->kc_thread_func(start, end, ctl->kc_func_arg);
+		if (err != KTASK_RETURN_SUCCESS)
+			break;
+	}
+
+	return err;
+}
+
+static inline void ktask_init(void) { }
+
+#endif /* CONFIG_KTASK */
+#endif /* _LINUX_KTASK_H */
diff --git a/init/Kconfig b/init/Kconfig
index 41583f468cb4..ed82f76ed0b7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -346,6 +346,17 @@ config AUDIT_TREE
 	depends on AUDITSYSCALL
 	select FSNOTIFY
 
+config KTASK
+	bool "Multithread CPU-intensive kernel work"
+	depends on SMP
+	default y
+	help
+	  Parallelize CPU-intensive kernel work.  This feature is designed for
+          big machines that can take advantage of their extra CPUs to speed up
+	  large kernel tasks.  When enabled, kworker threads may occupy more
+          CPU time during these kernel tasks, but these threads are throttled
+          when other tasks on the system need CPU time.
+
 source "kernel/irq/Kconfig"
 source "kernel/time/Kconfig"
 source "kernel/Kconfig.preempt"
diff --git a/init/main.c b/init/main.c
index ee147103ba1b..c689f00eab95 100644
--- a/init/main.c
+++ b/init/main.c
@@ -92,6 +92,7 @@
 #include <linux/rodata_test.h>
 #include <linux/jump_label.h>
 #include <linux/mem_encrypt.h>
+#include <linux/ktask.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -1145,6 +1146,7 @@ static noinline void __init kernel_init_freeable(void)
 
 	smp_init();
 	sched_init_smp();
+	ktask_init();
 
 	page_alloc_init_late();
 
diff --git a/kernel/Makefile b/kernel/Makefile
index 63b643eb7e70..ce238cb7add5 100644
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
index 000000000000..a7b2b5a62737
--- /dev/null
+++ b/kernel/ktask.c
@@ -0,0 +1,526 @@
+// SPDX-License-Identifier: GPL-2.0+
+/*
+ * ktask.c - framework to parallelize CPU-intensive kernel work
+ *
+ * For more information, see Documentation/core-api/ktask.rst.
+ *
+ * Copyright (c) 2018 Oracle Corporation
+ * Author: Daniel Jordan <daniel.m.jordan@oracle.com>
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
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+
+/* Resource limits on the amount of workqueue items queued through ktask. */
+static DEFINE_SPINLOCK(ktask_rlim_lock);
+/* Work items queued on all nodes (includes NUMA_NO_NODE) */
+static size_t ktask_rlim_cur;
+static size_t ktask_rlim_max;
+/* Work items queued per node */
+static size_t *ktask_rlim_node_cur;
+static size_t *ktask_rlim_node_max;
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
+static struct ktask_work *ktask_works;
+
+/* Represents one task.  This is for internal use only. */
+struct ktask_task {
+	struct ktask_ctl	kt_ctl;
+	size_t			kt_total_size;
+	size_t			kt_chunk_size;
+	/* protects this struct and struct ktask_work's of a running task */
+	struct mutex		kt_mutex;
+	struct ktask_node	*kt_nodes;
+	size_t			kt_nr_nodes;
+	size_t			kt_nr_nodes_left;
+	size_t			kt_nworks;
+	size_t			kt_nworks_fini;
+	int			kt_error; /* first error from thread_func */
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
+static void ktask_init_work(struct ktask_work *kw, struct ktask_task *kt,
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
+	if (!IS_ENABLED(CONFIG_NUMA) || !(current->flags & PF_KTHREAD) ||
+	    kn->kn_nid == old_kn->kn_nid || num_online_nodes() == 1)
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
+static void ktask_thread(struct work_struct *work)
+{
+	struct ktask_work  *kw = container_of(work, struct ktask_work, kw_work);
+	struct ktask_task  *kt = kw->kw_task;
+	struct ktask_ctl   *kc = &kt->kt_ctl;
+	struct ktask_node  *kn = &kt->kt_nodes[kw->kw_ktask_node_i];
+	bool               done;
+
+	mutex_lock(&kt->kt_mutex);
+
+	while (kt->kt_total_size > 0 && kt->kt_error == KTASK_RETURN_SUCCESS) {
+		void *start, *end;
+		size_t size;
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
+		size = min(kt->kt_chunk_size, kn->kn_task_size);
+		end = kc->kc_iter_func(start, size);
+		kn->kn_start = end;
+		kn->kn_task_size -= size;
+		WARN_ON(kt->kt_total_size < size);
+		kt->kt_total_size -= size;
+		if (kn->kn_task_size == 0) {
+			WARN_ON(kt->kt_nr_nodes_left == 0);
+			kt->kt_nr_nodes_left--;
+		}
+
+		mutex_unlock(&kt->kt_mutex);
+
+		ret = kc->kc_thread_func(start, end, kc->kc_func_arg);
+
+		mutex_lock(&kt->kt_mutex);
+
+		/* Save first error code only. */
+		if (kt->kt_error == KTASK_RETURN_SUCCESS && ret != kt->kt_error)
+			kt->kt_error = ret;
+	}
+
+	WARN_ON(kt->kt_nr_nodes_left > 0 &&
+		kt->kt_error == KTASK_RETURN_SUCCESS);
+
+	++kt->kt_nworks_fini;
+	WARN_ON(kt->kt_nworks_fini > kt->kt_nworks);
+	done = (kt->kt_nworks_fini == kt->kt_nworks);
+	mutex_unlock(&kt->kt_mutex);
+
+	if (done)
+		complete(&kt->kt_ktask_done);
+}
+
+/*
+ * Returns the number of chunks to break this task into.
+ *
+ * The number of chunks will be at least the number of works, but in the common
+ * case of a large task, the number of chunks will be greater to load balance
+ * between the workqueue threads in case some of them finish more quickly than
+ * others.
+ */
+static size_t ktask_chunk_size(size_t task_size, size_t min_chunk_size,
+			       size_t nworks)
+{
+	size_t chunk_size;
+
+	if (nworks == 1)
+		return task_size;
+
+	chunk_size = (task_size / nworks) >> KTASK_LOAD_BAL_SHIFT;
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
+ * Returns the number of works to be used in the task.  This number includes
+ * the current thread, so a return value of 1 means no extra threads are
+ * started.
+ */
+static size_t ktask_init_works(struct ktask_node *nodes, size_t nr_nodes,
+			       struct ktask_task *kt,
+			       struct list_head *works_list)
+{
+	size_t i, nr_works, nr_works_check;
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
+	nr_works_check = DIV_ROUND_UP(kt->kt_total_size, min_chunk_size);
+	nr_works_check = min_t(size_t, nr_works_check, num_online_cpus());
+	nr_works_check = min_t(size_t, nr_works_check, max_threads);
+
+	/*
+	 * Use at least the current thread for this task; check whether
+	 * ktask_rlim allows additional work items to be queued.
+	 */
+	nr_works = 1;
+	spin_lock(&ktask_rlim_lock);
+	for (i = nr_works; i < nr_works_check; ++i) {
+		/* Allocate works evenly over the task's given nodes. */
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
+		WARN_ON(list_empty(&ktask_free_works));
+		kw = list_first_entry(&ktask_free_works, struct ktask_work,
+				      kw_list);
+		list_move_tail(&kw->kw_list, works_list);
+		ktask_init_work(kw, kt, ktask_node_i, queue_nid);
+
+		++ktask_rlim_cur;
+		++nr_works;
+	}
+	spin_unlock(&ktask_rlim_lock);
+
+	return nr_works;
+}
+
+static void ktask_fini_works(struct ktask_task *kt,
+			     struct list_head *works_list)
+{
+	struct ktask_work *work;
+
+	spin_lock(&ktask_rlim_lock);
+
+	/* Put the works back on the free list, adjusting rlimits. */
+	list_for_each_entry(work, works_list, kw_list) {
+		if (work->kw_queue_nid != NUMA_NO_NODE) {
+			WARN_ON(ktask_rlim_node_cur[work->kw_queue_nid] == 0);
+			--ktask_rlim_node_cur[work->kw_queue_nid];
+		}
+		WARN_ON(ktask_rlim_cur == 0);
+		--ktask_rlim_cur;
+	}
+	list_splice(works_list, &ktask_free_works);
+
+	spin_unlock(&ktask_rlim_lock);
+}
+
+int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
+		   struct ktask_ctl *ctl)
+{
+	size_t i;
+	struct ktask_work kw;
+	struct ktask_work *work;
+	LIST_HEAD(works_list);
+	struct ktask_task kt = {
+		.kt_ctl             = *ctl,
+		.kt_total_size      = 0,
+		.kt_nodes           = nodes,
+		.kt_nr_nodes        = nr_nodes,
+		.kt_nr_nodes_left   = nr_nodes,
+		.kt_nworks_fini     = 0,
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
+	init_completion(&kt.kt_ktask_done);
+
+	kt.kt_nworks = ktask_init_works(nodes, nr_nodes, &kt, &works_list);
+	kt.kt_chunk_size = ktask_chunk_size(kt.kt_total_size,
+					    ctl->kc_min_chunk_size,
+					    kt.kt_nworks);
+
+	list_for_each_entry(work, &works_list, kw_list)
+		ktask_queue_work(work);
+
+	/* Use the current thread, which saves starting a workqueue worker. */
+	ktask_init_work(&kw, &kt, 0, nodes[0].kn_nid);
+	ktask_thread(&kw.kw_work);
+
+	/* Wait for all the jobs to finish. */
+	wait_for_completion(&kt.kt_ktask_done);
+
+	ktask_fini_works(&kt, &works_list);
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
+static bool __init ktask_rlim_init(void)
+{
+	int node, nr_cpus;
+	unsigned int nr_node_cpus;
+
+	nr_cpus = num_online_cpus();
+
+	/* XXX Handle CPU hotplug. */
+	if (nr_cpus == 1)
+		return false;
+
+	ktask_rlim_node_cur = kcalloc(num_possible_nodes(), sizeof(size_t),
+				      GFP_KERNEL);
+
+	ktask_rlim_node_max = kmalloc_array(num_possible_nodes(),
+					    sizeof(size_t), GFP_KERNEL);
+
+	ktask_rlim_max = mult_frac(nr_cpus, KTASK_CPUFRAC_NUMER,
+				   KTASK_CPUFRAC_DENOM);
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
+	for (i = 0; i < ktask_rlim_max; ++i)
+		list_add_tail(&ktask_works[i].kw_list, &ktask_free_works);
+
+	ktask_wq = alloc_workqueue("ktask_wq", WQ_UNBOUND, 0);
+	if (!ktask_wq) {
+		pr_warn("disabled (failed to alloc ktask_wq)");
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
+		pr_warn("disabled (failed to alloc ktask_nonuma_wq)");
+		goto alloc_fail;
+	}
+
+	attrs = alloc_workqueue_attrs(GFP_KERNEL);
+	if (!attrs) {
+		pr_warn("disabled (couldn't alloc wq attrs)");
+		goto alloc_fail;
+	}
+
+	attrs->no_numa = true;
+
+	ret = apply_workqueue_attrs(ktask_nonuma_wq, attrs);
+	if (ret != 0) {
+		pr_warn("disabled (couldn't apply attrs to ktask_nonuma_wq)");
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
+	if (ktask_wq)
+		destroy_workqueue(ktask_wq);
+	if (ktask_nonuma_wq)
+		destroy_workqueue(ktask_nonuma_wq);
+	ktask_wq = NULL;
+	ktask_nonuma_wq = NULL;
+}
+
+#endif /* CONFIG_KTASK */
+
+/*
+ * This function is defined outside CONFIG_KTASK so it can be called in the
+ * !CONFIG_KTASK versions of ktask_run and ktask_run_numa.
+ */
+void *ktask_iter_range(void *position, size_t size)
+{
+	return (char *)position + size;
+}
+EXPORT_SYMBOL_GPL(ktask_iter_range);
-- 
2.19.1
