Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id A7C866B00DA
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 13:54:57 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so1772688eek.27
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 10:54:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 5si10759512eei.123.2013.12.09.10.54.56
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 10:54:56 -0800 (PST)
Message-ID: <52A611FB.7000305@redhat.com>
Date: Mon, 09 Dec 2013 13:54:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/18] sched: Tracepoint task movement
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-18-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Drew Jones <drjones@redhat.com>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> move_task() is called from move_one_task and move_tasks and is an
> approximation of load balancer activity. We should be able to track
> tasks that move between CPUs frequently. If the tracepoint included node
> information then we could distinguish between in-node and between-node
> traffic for load balancer decisions. The tracepoint allows us to track
> local migrations, remote migrations and average task migrations.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Does this replicate the task_sched_migrate_task tracepoint in
set_task_cpu() ?

I know Drew has been using that tracepoint in his (still experimental)
numatop script. Drew, does this tracepoint look better than the trace
point that you are currently using, or is it similar enough that we do
not really benefit from this addition?

> diff --git a/include/trace/events/sched.h b/include/trace/events/sched.h
> index 04c3084..cf1694c 100644
> --- a/include/trace/events/sched.h
> +++ b/include/trace/events/sched.h
> @@ -443,6 +443,41 @@ TRACE_EVENT(sched_process_hang,
>  );
>  #endif /* CONFIG_DETECT_HUNG_TASK */
>  
> +/*
> + * Tracks migration of tasks from one runqueue to another. Can be used to
> + * detect if automatic NUMA balancing is bouncing between nodes
> + */
> +TRACE_EVENT(sched_move_task,
> +
> +	TP_PROTO(struct task_struct *tsk, int src_cpu, int dst_cpu),
> +
> +	TP_ARGS(tsk, src_cpu, dst_cpu),
> +
> +	TP_STRUCT__entry(
> +		__field( pid_t,	pid			)
> +		__field( pid_t,	tgid			)
> +		__field( pid_t,	ngid			)
> +		__field( int,	src_cpu			)
> +		__field( int,	src_nid			)
> +		__field( int,	dst_cpu			)
> +		__field( int,	dst_nid			)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pid		= task_pid_nr(tsk);
> +		__entry->tgid		= task_tgid_nr(tsk);
> +		__entry->ngid		= task_numa_group_id(tsk);
> +		__entry->src_cpu	= src_cpu;
> +		__entry->src_nid	= cpu_to_node(src_cpu);
> +		__entry->dst_cpu	= dst_cpu;
> +		__entry->dst_nid	= cpu_to_node(dst_cpu);
> +	),
> +
> +	TP_printk("pid=%d tgid=%d ngid=%d src_cpu=%d src_nid=%d dst_cpu=%d dst_nid=%d",
> +			__entry->pid, __entry->tgid, __entry->ngid,
> +			__entry->src_cpu, __entry->src_nid,
> +			__entry->dst_cpu, __entry->dst_nid)
> +);
>  #endif /* _TRACE_SCHED_H */
>  
>  /* This part must be outside protection */
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 1ce1615..41021c8 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -4770,6 +4770,8 @@ static void move_task(struct task_struct *p, struct lb_env *env)
>  	set_task_cpu(p, env->dst_cpu);
>  	activate_task(env->dst_rq, p, 0);
>  	check_preempt_curr(env->dst_rq, p, 0);
> +
> +	trace_sched_move_task(p, env->src_cpu, env->dst_cpu);
>  }
>  
>  /*
> 


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
