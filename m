Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id C57756B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:22:14 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so8678314pbc.1
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:22:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sa6si11634755pbb.23.2013.12.10.14.22.12
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 14:22:13 -0800 (PST)
Date: Tue, 10 Dec 2013 14:22:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 17/18] sched: Add tracepoints related to NUMA task
 migration
Message-Id: <20131210142211.099fe782c361707ab3c04742@linux-foundation.org>
In-Reply-To: <1386690695-27380-18-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
	<1386690695-27380-18-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 10 Dec 2013 15:51:35 +0000 Mel Gorman <mgorman@suse.de> wrote:

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
> ...
>
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

I'll zap that semicolon...

> +		trace_sched_stick_numa(p, env.src_cpu, task_cpu(env.best_task));
>  	put_task_struct(env.best_task);
>  	return ret;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
