Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4266B026E
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:37 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id q188-v6so7891885ywd.2
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:37 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 84-v6si7647388yby.78.2018.11.05.08.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:36 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 03/13] ktask: add undo support
Date: Mon,  5 Nov 2018 11:55:48 -0500
Message-Id: <20181105165558.11698-4-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Tasks can fail midway through their work.  To recover, the finished
chunks of work need to be undone in a task-specific way.

Allow ktask clients to pass an "undo" callback that is responsible for
undoing one chunk of work.  To avoid multiple levels of error handling,
do not allow the callback to fail.  For simplicity and because it's a
slow path, undoing is not multithreaded.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/ktask.h |  36 +++++++++++-
 kernel/ktask.c        | 125 +++++++++++++++++++++++++++++++++++-------
 2 files changed, 138 insertions(+), 23 deletions(-)

diff --git a/include/linux/ktask.h b/include/linux/ktask.h
index 9c75a93b51b9..30a6a88e5dad 100644
--- a/include/linux/ktask.h
+++ b/include/linux/ktask.h
@@ -10,6 +10,7 @@
 #ifndef _LINUX_KTASK_H
 #define _LINUX_KTASK_H
 
+#include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/types.h>
 
@@ -23,9 +24,14 @@
  * @kn_nid: NUMA node id to run threads on
  */
 struct ktask_node {
-	void		*kn_start;
-	size_t		kn_task_size;
-	int		kn_nid;
+	void			*kn_start;
+	size_t			kn_task_size;
+	int			kn_nid;
+
+	/* Private fields below - do not touch these. */
+	void			*kn_position;
+	size_t			kn_remaining_size;
+	struct list_head	kn_failed_works;
 };
 
 /**
@@ -43,6 +49,14 @@ struct ktask_node {
  */
 typedef int (*ktask_thread_func)(void *start, void *end, void *arg);
 
+/**
+ * typedef ktask_undo_func
+ *
+ * The same as ktask_thread_func, with the exception that it must always
+ * succeed, so it doesn't return anything.
+ */
+typedef void (*ktask_undo_func)(void *start, void *end, void *arg);
+
 /**
  * typedef ktask_iter_func
  *
@@ -77,6 +91,11 @@ void *ktask_iter_range(void *position, size_t size);
  *
  * @kc_thread_func: A thread function that completes one chunk of the task per
  *                  call.
+ * @kc_undo_func: A function that undoes one chunk of the task per call.
+ *                If non-NULL and error(s) occur during the task, this is
+ *                called on all successfully completed chunks of work.  The
+ *                chunk(s) in which failure occurs should be handled in
+ *                kc_thread_func.
  * @kc_func_arg: An argument to be passed to the thread and undo functions.
  * @kc_iter_func: An iterator function to advance the iterator by some number
  *                   of task-specific units.
@@ -90,6 +109,7 @@ void *ktask_iter_range(void *position, size_t size);
 struct ktask_ctl {
 	/* Required arguments set with DEFINE_KTASK_CTL. */
 	ktask_thread_func	kc_thread_func;
+	ktask_undo_func		kc_undo_func;
 	void			*kc_func_arg;
 	size_t			kc_min_chunk_size;
 
@@ -101,6 +121,7 @@ struct ktask_ctl {
 #define KTASK_CTL_INITIALIZER(thread_func, func_arg, min_chunk_size)	     \
 	{								     \
 		.kc_thread_func = (ktask_thread_func)(thread_func),	     \
+		.kc_undo_func = NULL,					     \
 		.kc_func_arg = (func_arg),				     \
 		.kc_min_chunk_size = (min_chunk_size),			     \
 		.kc_iter_func = (ktask_iter_range),			     \
@@ -132,6 +153,15 @@ struct ktask_ctl {
 #define ktask_ctl_set_iter_func(ctl, iter_func)				\
 	((ctl)->kc_iter_func = (ktask_iter_func)(iter_func))
 
+/**
+ * ktask_ctl_set_undo_func - Designate an undo function to unwind from error
+ *
+ * @ctl:  A control structure containing information about the task.
+ * @undo_func:  Undoes a piece of the task.
+ */
+#define ktask_ctl_set_undo_func(ctl, undo_func)				\
+	((ctl)->kc_undo_func = (ktask_undo_func)(undo_func))
+
 /**
  * ktask_ctl_set_max_threads - Set a task-specific maximum number of threads
  *
diff --git a/kernel/ktask.c b/kernel/ktask.c
index a7b2b5a62737..b91c62f14dcd 100644
--- a/kernel/ktask.c
+++ b/kernel/ktask.c
@@ -20,6 +20,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
+#include <linux/list_sort.h>
 #include <linux/mutex.h>
 #include <linux/printk.h>
 #include <linux/random.h>
@@ -46,7 +47,12 @@ struct ktask_work {
 	struct ktask_task	*kw_task;
 	int			kw_ktask_node_i;
 	int			kw_queue_nid;
-	struct list_head	kw_list;	/* ktask_free_works linkage */
+	/* task units from kn_start to kw_error_start */
+	size_t			kw_error_offset;
+	void			*kw_error_start;
+	void			*kw_error_end;
+	/* ktask_free_works, kn_failed_works linkage */
+	struct list_head	kw_list;
 };
 
 static LIST_HEAD(ktask_free_works);
@@ -170,11 +176,11 @@ static void ktask_thread(struct work_struct *work)
 	mutex_lock(&kt->kt_mutex);
 
 	while (kt->kt_total_size > 0 && kt->kt_error == KTASK_RETURN_SUCCESS) {
-		void *start, *end;
-		size_t size;
+		void *position, *end;
+		size_t size, position_offset;
 		int ret;
 
-		if (kn->kn_task_size == 0) {
+		if (kn->kn_remaining_size == 0) {
 			/* The current node is out of work; pick a new one. */
 			size_t remaining_nodes_seen = 0;
 			size_t new_idx = prandom_u32_max(kt->kt_nr_nodes_left);
@@ -184,7 +190,7 @@ static void ktask_thread(struct work_struct *work)
 			WARN_ON(kt->kt_nr_nodes_left == 0);
 			WARN_ON(new_idx >= kt->kt_nr_nodes_left);
 			for (i = 0; i < kt->kt_nr_nodes; ++i) {
-				if (kt->kt_nodes[i].kn_task_size == 0)
+				if (kt->kt_nodes[i].kn_remaining_size == 0)
 					continue;
 
 				if (remaining_nodes_seen >= new_idx)
@@ -205,27 +211,40 @@ static void ktask_thread(struct work_struct *work)
 			}
 		}
 
-		start = kn->kn_start;
-		size = min(kt->kt_chunk_size, kn->kn_task_size);
-		end = kc->kc_iter_func(start, size);
-		kn->kn_start = end;
-		kn->kn_task_size -= size;
+		position = kn->kn_position;
+		position_offset = kn->kn_task_size - kn->kn_remaining_size;
+		size = min(kt->kt_chunk_size, kn->kn_remaining_size);
+		end = kc->kc_iter_func(position, size);
+		kn->kn_position = end;
+		kn->kn_remaining_size -= size;
 		WARN_ON(kt->kt_total_size < size);
 		kt->kt_total_size -= size;
-		if (kn->kn_task_size == 0) {
+		if (kn->kn_remaining_size == 0) {
 			WARN_ON(kt->kt_nr_nodes_left == 0);
 			kt->kt_nr_nodes_left--;
 		}
 
 		mutex_unlock(&kt->kt_mutex);
 
-		ret = kc->kc_thread_func(start, end, kc->kc_func_arg);
+		ret = kc->kc_thread_func(position, end, kc->kc_func_arg);
 
 		mutex_lock(&kt->kt_mutex);
 
-		/* Save first error code only. */
-		if (kt->kt_error == KTASK_RETURN_SUCCESS && ret != kt->kt_error)
-			kt->kt_error = ret;
+		if (ret != KTASK_RETURN_SUCCESS) {
+			/* Save first error code only. */
+			if (kt->kt_error == KTASK_RETURN_SUCCESS)
+				kt->kt_error = ret;
+			/*
+			 * If this task has an undo function, save information
+			 * about where this thread failed for ktask_undo.
+			 */
+			if (kc->kc_undo_func) {
+				list_move(&kw->kw_list, &kn->kn_failed_works);
+				kw->kw_error_start = position;
+				kw->kw_error_offset = position_offset;
+				kw->kw_error_end = end;
+			}
+		}
 	}
 
 	WARN_ON(kt->kt_nr_nodes_left > 0 &&
@@ -335,26 +354,85 @@ static size_t ktask_init_works(struct ktask_node *nodes, size_t nr_nodes,
 }
 
 static void ktask_fini_works(struct ktask_task *kt,
+			     struct ktask_work *stack_work,
 			     struct list_head *works_list)
 {
-	struct ktask_work *work;
+	struct ktask_work *work, *next;
 
 	spin_lock(&ktask_rlim_lock);
 
 	/* Put the works back on the free list, adjusting rlimits. */
-	list_for_each_entry(work, works_list, kw_list) {
+	list_for_each_entry_safe(work, next, works_list, kw_list) {
+		if (work == stack_work) {
+			/* On this thread's stack, so not subject to rlimits. */
+			list_del(&work->kw_list);
+			continue;
+		}
 		if (work->kw_queue_nid != NUMA_NO_NODE) {
 			WARN_ON(ktask_rlim_node_cur[work->kw_queue_nid] == 0);
 			--ktask_rlim_node_cur[work->kw_queue_nid];
 		}
 		WARN_ON(ktask_rlim_cur == 0);
 		--ktask_rlim_cur;
+		list_move(&work->kw_list, &ktask_free_works);
 	}
-	list_splice(works_list, &ktask_free_works);
-
 	spin_unlock(&ktask_rlim_lock);
 }
 
+static int ktask_error_cmp(void *unused, struct list_head *a,
+			   struct list_head *b)
+{
+	struct ktask_work *work_a = list_entry(a, struct ktask_work, kw_list);
+	struct ktask_work *work_b = list_entry(b, struct ktask_work, kw_list);
+
+	if (work_a->kw_error_offset < work_b->kw_error_offset)
+		return -1;
+	else if (work_a->kw_error_offset > work_b->kw_error_offset)
+		return 1;
+	return 0;
+}
+
+static void ktask_undo(struct ktask_node *nodes, size_t nr_nodes,
+		       struct ktask_ctl *ctl, struct list_head *works_list)
+{
+	size_t i;
+
+	for (i = 0; i < nr_nodes; ++i) {
+		struct ktask_node *kn = &nodes[i];
+		struct list_head *failed_works = &kn->kn_failed_works;
+		struct ktask_work *failed_work;
+		void *undo_pos = kn->kn_start;
+		void *undo_end;
+
+		/* Sort so the failed ranges can be checked as we go. */
+		list_sort(NULL, failed_works, ktask_error_cmp);
+
+		/* Undo completed work on this node, skipping failed ranges. */
+		while (undo_pos != kn->kn_position) {
+			failed_work = list_first_entry_or_null(failed_works,
+							      struct ktask_work,
+							      kw_list);
+			if (failed_work)
+				undo_end = failed_work->kw_error_start;
+			else
+				undo_end = kn->kn_position;
+
+			if (undo_pos != undo_end) {
+				ctl->kc_undo_func(undo_pos, undo_end,
+						  ctl->kc_func_arg);
+			}
+
+			if (failed_work) {
+				undo_pos = failed_work->kw_error_end;
+				list_move(&failed_work->kw_list, works_list);
+			} else {
+				undo_pos = undo_end;
+			}
+		}
+		WARN_ON(!list_empty(failed_works));
+	}
+}
+
 int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
 		   struct ktask_ctl *ctl)
 {
@@ -374,6 +452,9 @@ int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
 
 	for (i = 0; i < nr_nodes; ++i) {
 		kt.kt_total_size += nodes[i].kn_task_size;
+		nodes[i].kn_position = nodes[i].kn_start;
+		nodes[i].kn_remaining_size = nodes[i].kn_task_size;
+		INIT_LIST_HEAD(&nodes[i].kn_failed_works);
 		if (nodes[i].kn_task_size == 0)
 			kt.kt_nr_nodes_left--;
 
@@ -396,12 +477,16 @@ int ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
 
 	/* Use the current thread, which saves starting a workqueue worker. */
 	ktask_init_work(&kw, &kt, 0, nodes[0].kn_nid);
+	INIT_LIST_HEAD(&kw.kw_list);
 	ktask_thread(&kw.kw_work);
 
 	/* Wait for all the jobs to finish. */
 	wait_for_completion(&kt.kt_ktask_done);
 
-	ktask_fini_works(&kt, &works_list);
+	if (kt.kt_error && ctl->kc_undo_func)
+		ktask_undo(nodes, nr_nodes, ctl, &works_list);
+
+	ktask_fini_works(&kt, &kw, &works_list);
 	mutex_destroy(&kt.kt_mutex);
 
 	return kt.kt_error;
-- 
2.19.1
