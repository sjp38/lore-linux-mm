Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B5B2D6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:16:29 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4NMGKFk009605
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:16:22 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by kpbe13.cbf.corp.google.com with ESMTP id p4NMGI6h028354
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:16:19 -0700
Received: by pvg7 with SMTP id 7so3424051pvg.37
        for <linux-mm@kvack.org>; Mon, 23 May 2011 15:16:18 -0700 (PDT)
Date: Mon, 23 May 2011 15:16:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] oom: improve dump_tasks() show items
In-Reply-To: <4DD61FE2.1020303@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105231514350.17840@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD61FE2.1020303@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, caiqian@redhat.com, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>

On Fri, 20 May 2011, KOSAKI Motohiro wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f52e85c..43d32ae 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -355,7 +355,7 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
>  	struct task_struct *p;
>  	struct task_struct *task;
> 
> -	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
> +	pr_info("[   pid]   ppid   uid total_vm      rss     swap score_adj name\n");
>  	for_each_process(p) {
>  		if (oom_unkillable_task(p, mem, nodemask))
>  			continue;
> @@ -370,11 +370,14 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
>  			continue;
>  		}
> 
> -		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
> -			task->pid, task_uid(task), task->tgid,
> -			task->mm->total_vm, get_mm_rss(task->mm),
> -			task_cpu(task), task->signal->oom_adj,
> -			task->signal->oom_score_adj, task->comm);
> +		pr_info("[%6d] %6d %5d %8lu %8lu %8lu %9d %s\n",
> +			task_tgid_nr(task), task_tgid_nr(task->real_parent),
> +			task_uid(task),
> +			task->mm->total_vm,
> +			get_mm_rss(task->mm) + p->mm->nr_ptes,
> +			get_mm_counter(p->mm, MM_SWAPENTS),
> +			task->signal->oom_score_adj,
> +			task->comm);
>  		task_unlock(task);
>  	}
>  }

Looks good, with the exception that the "score_adj" header should remain 
"oom_score_adj" since that is its name within procfs that changes the 
tunable.

After that's fixed:

	Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
