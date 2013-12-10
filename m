Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id C83456B006E
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:49 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so2382757eek.9
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si14879081eeo.95.2013.12.10.07.51.48
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:49 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/18] sched: Add tracepoints related to NUMA task migration
Date: Tue, 10 Dec 2013 15:51:35 +0000
Message-Id: <1386690695-27380-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch adds three tracepoints
 o trace_sched_move_numa	when a task is moved to a node
 o trace_sched_swap_numa	when a task is swapped with another task
 o trace_sched_stick_numa	when a numa-related migration fails

The tracepoints allow the NUMA scheduler activity to be monitored and the
following high-level metrics can be calculated

 o NUMA migrated stuck	 nr trace_sched_stick_numa
 o NUMA migrated idle	 nr trace_sched_move_numa
 o NUMA migrated swapped nr trace_sched_swap_numa
 o NUMA local swapped	 trace_sched_swap_numa src_nid == dst_nid (should never happen)
 o NUMA remote swapped	 trace_sched_swap_numa src_nid != dst_nid (should == NUMA migrated swapped)
 o NUMA group swapped	 trace_sched_swap_numa src_ngid == dst_ngid
			 Maybe a small number of these are acceptable
			 but a high number would be a major surprise.
			 It would be even worse if bounces are frequent.
 o NUMA avg task migs.	 Average number of migrations for tasks
 o NUMA stddev task mig	 Self-explanatory
 o NUMA max task migs.	 Maximum number of migrations for a single task

In general the intent of the tracepoints is to help diagnose problems
where automatic NUMA balancing appears to be doing an excessive amount of
useless work.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/trace/events/sched.h | 87 ++++++++++++++++++++++++++++++++++++++++++++
 kernel/sched/core.c          |  2 +
 kernel/sched/fair.c          |  6 ++-
 3 files changed, 93 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sched.h b/include/trace/events/sched.h
index 04c3084..67e1bbf 100644
--- a/include/trace/events/sched.h
+++ b/include/trace/events/sched.h
@@ -443,6 +443,93 @@ TRACE_EVENT(sched_process_hang,
 );
 #endif /* CONFIG_DETECT_HUNG_TASK */
 
+DECLARE_EVENT_CLASS(sched_move_task_template,
+
+	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
+
+	TP_ARGS(tsk, src_cpu, dst_cpu),
+
+	TP_STRUCT__entry(
+		__field( pid_t,	pid			)
+		__field( pid_t,	tgid			)
+		__field( pid_t,	ngid			)
+		__field( int,	src_cpu			)
+		__field( int,	src_nid			)
+		__field( int,	dst_cpu			)
+		__field( int,	dst_nid			)
+	),
+
+	TP_fast_assign(
+		__entry->pid		= task_pid_nr(tsk);
+		__entry->tgid		= task_tgid_nr(tsk);
+		__entry->ngid		= task_numa_group_id(tsk);
+		__entry->src_cpu	= src_cpu;
+		__entry->src_nid	= cpu_to_node(src_cpu);
+		__entry->dst_cpu	= dst_cpu;
+		__entry->dst_nid	= cpu_to_node(dst_cpu);
+	),
+
+	TP_printk("pid=%d tgid=%d ngid=%d src_cpu=%d src_nid=%d dst_cpu=%d dst_nid=%d",
+			__entry->pid, __entry->tgid, __entry->ngid,
+			__entry->src_cpu, __entry->src_nid,
+			__entry->dst_cpu, __entry->dst_nid)
+);
+
+/*
+ * Tracks migration of tasks from one runqueue to another. Can be used to
+ * detect if automatic NUMA balancing is bouncing between nodes
+ */
+DEFINE_EVENT(sched_move_task_template, sched_move_numa,
+	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
+
+	TP_ARGS(tsk, src_cpu, dst_cpu)
+);
+
+DEFINE_EVENT(sched_move_task_template, sched_stick_numa,
+	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
+
+	TP_ARGS(tsk, src_cpu, dst_cpu)
+);
+
+TRACE_EVENT(sched_swap_numa,
+
+	TP_PROTO(struct task_struct *src_tsk, int src_cpu,
+		 struct task_struct *dst_tsk, int dst_cpu),
+
+	TP_ARGS(src_tsk, src_cpu, dst_tsk, dst_cpu),
+
+	TP_STRUCT__entry(
+		__field( pid_t,	src_pid			)
+		__field( pid_t,	src_tgid		)
+		__field( pid_t,	src_ngid		)
+		__field( int,	src_cpu			)
+		__field( int,	src_nid			)
+		__field( pid_t,	dst_pid			)
+		__field( pid_t,	dst_tgid		)
+		__field( pid_t,	dst_ngid		)
+		__field( int,	dst_cpu			)
+		__field( int,	dst_nid			)
+	),
+
+	TP_fast_assign(
+		__entry->src_pid	= task_pid_nr(src_tsk);
+		__entry->src_tgid	= task_tgid_nr(src_tsk);
+		__entry->src_ngid	= task_numa_group_id(src_tsk);
+		__entry->src_cpu	= src_cpu;
+		__entry->src_nid	= cpu_to_node(src_cpu);
+		__entry->dst_pid	= task_pid_nr(dst_tsk);
+		__entry->dst_tgid	= task_tgid_nr(dst_tsk);
+		__entry->dst_ngid	= task_numa_group_id(dst_tsk);
+		__entry->dst_cpu	= dst_cpu;
+		__entry->dst_nid	= cpu_to_node(dst_cpu);
+	),
+
+	TP_printk("src_pid=%d src_tgid=%d src_ngid=%d src_cpu=%d src_nid=%d dst_pid=%d dst_tgid=%d dst_ngid=%d dst_cpu=%d dst_nid=%d",
+			__entry->src_pid, __entry->src_tgid, __entry->src_ngid,
+			__entry->src_cpu, __entry->src_nid,
+			__entry->dst_pid, __entry->dst_tgid, __entry->dst_ngid,
+			__entry->dst_cpu, __entry->dst_nid)
+);
 #endif /* _TRACE_SCHED_H */
 
 /* This part must be outside protection */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index e85cda2..e485d2b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1108,6 +1108,7 @@ int migrate_swap(struct task_struct *cur, struct task_struct *p)
 	if (!cpumask_test_cpu(arg.src_cpu, tsk_cpus_allowed(arg.dst_task)))
 		goto out;
 
+	trace_sched_swap_numa(cur, arg.src_cpu, p, arg.dst_cpu);
 	ret = stop_two_cpus(arg.dst_cpu, arg.src_cpu, migrate_swap_stop, &arg);
 
 out:
@@ -4090,6 +4091,7 @@ int migrate_task_to(struct task_struct *p, int target_cpu)
 
 	/* TODO: This is not properly updating schedstats */
 
+	trace_sched_move_numa(p, curr_cpu, target_cpu);
 	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
 }
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 18bf84e..26fe588 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1272,11 +1272,13 @@ static int task_numa_migrate(struct task_struct *p)
 	p->numa_scan_period = task_scan_min(p);
 
 	if (env.best_task == NULL) {
-		int ret = migrate_task_to(p, env.best_cpu);
+		if ((ret = migrate_task_to(p, env.best_cpu)) != 0)
+			trace_sched_stick_numa(p, env.src_cpu, env.best_cpu);
 		return ret;
 	}
 
-	ret = migrate_swap(p, env.best_task);
+	if ((ret = migrate_swap(p, env.best_task)) != 0);
+		trace_sched_stick_numa(p, env.src_cpu, task_cpu(env.best_task));
 	put_task_struct(env.best_task);
 	return ret;
 }
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
