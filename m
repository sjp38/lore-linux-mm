Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id D10E16B00DC
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 14:06:45 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so1740760eek.26
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 11:06:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l2si10828707een.41.2013.12.09.11.06.44
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 11:06:45 -0800 (PST)
Message-ID: <52A614C0.7030502@redhat.com>
Date: Mon, 09 Dec 2013 14:06:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 18/18] sched: Add tracepoints related to NUMA task migration
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-19-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> This patch adds three tracepoints
>  o trace_sched_move_numa	when a task is moved to a node
>  o trace_sched_swap_numa	when a task is swapped with another task
>  o trace_sched_stick_numa	when a numa-related migration fails
> 
> The tracepoints allow the NUMA scheduler activity to be monitored and the
> following high-level metrics can be calculated
> 
>  o NUMA migrated stuck	 nr trace_sched_stick_numa
>  o NUMA migrated idle	 nr trace_sched_move_numa
>  o NUMA migrated swapped nr trace_sched_swap_numa
>  o NUMA local swapped	 trace_sched_swap_numa src_nid == dst_nid (should never happen)
>  o NUMA remote swapped	 trace_sched_swap_numa src_nid != dst_nid (should == NUMA migrated swapped)
>  o NUMA group swapped	 trace_sched_swap_numa src_ngid == dst_ngid
> 			 Maybe a small number of these are acceptable
> 			 but a high number would be a major surprise.
> 			 It would be even worse if bounces are frequent.
>  o NUMA avg task migs.	 Average number of migrations for tasks
>  o NUMA stddev task mig	 Self-explanatory
>  o NUMA max task migs.	 Maximum number of migrations for a single task
> 
> In general the intent of the tracepoints is to help diagnose problems
> where automatic NUMA balancing appears to be doing an excessive amount of
> useless work.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

> diff --git a/include/trace/events/sched.h b/include/trace/events/sched.h
> index cf1694c..f0c54e3 100644
> --- a/include/trace/events/sched.h
> +++ b/include/trace/events/sched.h
> @@ -443,11 +443,7 @@ TRACE_EVENT(sched_process_hang,
>  );
>  #endif /* CONFIG_DETECT_HUNG_TASK */
>  
> -/*
> - * Tracks migration of tasks from one runqueue to another. Can be used to
> - * detect if automatic NUMA balancing is bouncing between nodes
> - */
> -TRACE_EVENT(sched_move_task,
> +DECLARE_EVENT_CLASS(sched_move_task_template,
>  
>  	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
>  
> @@ -478,6 +474,68 @@ TRACE_EVENT(sched_move_task,
>  			__entry->src_cpu, __entry->src_nid,
>  			__entry->dst_cpu, __entry->dst_nid)
>  );
> +
> +/*
> + * Tracks migration of tasks from one runqueue to another. Can be used to
> + * detect if automatic NUMA balancing is bouncing between nodes
> + */
> +DEFINE_EVENT(sched_move_task_template, sched_move_task,
> +	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
> +
> +	TP_ARGS(tsk, src_cpu, dst_cpu)
> +);
> +
> +DEFINE_EVENT(sched_move_task_template, sched_move_numa,
> +	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
> +
> +	TP_ARGS(tsk, src_cpu, dst_cpu)
> +);
> +
> +DEFINE_EVENT(sched_move_task_template, sched_stick_numa,
> +	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
> +
> +	TP_ARGS(tsk, src_cpu, dst_cpu)
> +);
> +
> +TRACE_EVENT(sched_swap_numa,
> +
> +	TP_PROTO(struct task_struct *src_tsk, int src_cpu,
> +		 struct task_struct *dst_tsk, int dst_cpu),
> +
> +	TP_ARGS(src_tsk, src_cpu, dst_tsk, dst_cpu),
> +
> +	TP_STRUCT__entry(
> +		__field( pid_t,	src_pid			)
> +		__field( pid_t,	src_tgid		)
> +		__field( pid_t,	src_ngid		)
> +		__field( int,	src_cpu			)
> +		__field( int,	src_nid			)
> +		__field( pid_t,	dst_pid			)
> +		__field( pid_t,	dst_tgid		)
> +		__field( pid_t,	dst_ngid		)
> +		__field( int,	dst_cpu			)
> +		__field( int,	dst_nid			)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->src_pid	= task_pid_nr(src_tsk);
> +		__entry->src_tgid	= task_tgid_nr(src_tsk);
> +		__entry->src_ngid	= task_numa_group_id(src_tsk);
> +		__entry->src_cpu	= src_cpu;
> +		__entry->src_nid	= cpu_to_node(src_cpu);
> +		__entry->dst_pid	= task_pid_nr(dst_tsk);
> +		__entry->dst_tgid	= task_tgid_nr(dst_tsk);
> +		__entry->dst_ngid	= task_numa_group_id(dst_tsk);
> +		__entry->dst_cpu	= dst_cpu;
> +		__entry->dst_nid	= cpu_to_node(dst_cpu);
> +	),
> +
> +	TP_printk("src_pid=%d src_tgid=%d src_ngid=%d src_cpu=%d src_nid=%d dst_pid=%d dst_tgid=%d dst_ngid=%d dst_cpu=%d dst_nid=%d",
> +			__entry->src_pid, __entry->src_tgid, __entry->src_ngid,
> +			__entry->src_cpu, __entry->src_nid,
> +			__entry->dst_pid, __entry->dst_tgid, __entry->dst_ngid,
> +			__entry->dst_cpu, __entry->dst_nid)
> +);
>  #endif /* _TRACE_SCHED_H */
>  
>  /* This part must be outside protection */
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index c180860..3980110 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1108,6 +1108,7 @@ int migrate_swap(struct task_struct *cur, struct task_struct *p)
>  	if (!cpumask_test_cpu(arg.src_cpu, tsk_cpus_allowed(arg.dst_task)))
>  		goto out;
>  
> +	trace_sched_swap_numa(cur, arg.src_cpu, p, arg.dst_cpu);
>  	ret = stop_two_cpus(arg.dst_cpu, arg.src_cpu, migrate_swap_stop, &arg);
>  
>  out:
> @@ -4091,6 +4092,7 @@ int migrate_task_to(struct task_struct *p, int target_cpu)
>  
>  	/* TODO: This is not properly updating schedstats */
>  
> +	trace_sched_move_numa(p, curr_cpu, target_cpu);
>  	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
>  }
>  
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 41021c8..aac8c65 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1272,11 +1272,13 @@ static int task_numa_migrate(struct task_struct *p)
>  	p->numa_scan_period = task_scan_min(p);
>  
>  	if (env.best_task == NULL) {
> -		int ret = migrate_task_to(p, env.best_cpu);
> +		if ((ret = migrate_task_to(p, env.best_cpu)) != 0)
> +			trace_sched_stick_numa(p, env.src_cpu, env.best_cpu);
>  		return ret;
>  	}
>  
> -	ret = migrate_swap(p, env.best_task);
> +	if ((ret = migrate_swap(p, env.best_task)) != 0);
> +		trace_sched_stick_numa(p, env.src_cpu, task_cpu(env.best_task));
>  	put_task_struct(env.best_task);
>  	return ret;
>  }
> 


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
