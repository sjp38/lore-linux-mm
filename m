Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 28C7B6B0072
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:30 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id d17so1320875eek.25
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p46si8242969eem.63.2013.12.08.23.09.29
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:29 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/18] sched: Tracepoint task movement
Date: Mon,  9 Dec 2013 07:09:11 +0000
Message-Id: <1386572952-1191-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

move_task() is called from move_one_task and move_tasks and is an
approximation of load balancer activity. We should be able to track
tasks that move between CPUs frequently. If the tracepoint included node
information then we could distinguish between in-node and between-node
traffic for load balancer decisions. The tracepoint allows us to track
local migrations, remote migrations and average task migrations.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/sched.h | 35 +++++++++++++++++++++++++++++++++++
 kernel/sched/fair.c          |  2 ++
 2 files changed, 37 insertions(+)

diff --git a/include/trace/events/sched.h b/include/trace/events/sched.h
index 04c3084..cf1694c 100644
--- a/include/trace/events/sched.h
+++ b/include/trace/events/sched.h
@@ -443,6 +443,41 @@ TRACE_EVENT(sched_process_hang,
 );
 #endif /* CONFIG_DETECT_HUNG_TASK */
 
+/*
+ * Tracks migration of tasks from one runqueue to another. Can be used to
+ * detect if automatic NUMA balancing is bouncing between nodes
+ */
+TRACE_EVENT(sched_move_task,
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
 #endif /* _TRACE_SCHED_H */
 
 /* This part must be outside protection */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 1ce1615..41021c8 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -4770,6 +4770,8 @@ static void move_task(struct task_struct *p, struct lb_env *env)
 	set_task_cpu(p, env->dst_cpu);
 	activate_task(env->dst_rq, p, 0);
 	check_preempt_curr(env->dst_rq, p, 0);
+
+	trace_sched_move_task(p, env->src_cpu, env->dst_cpu);
 }
 
 /*
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
