Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 652B26B0012
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:29:09 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p4ANT7ks030062
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:29:07 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by hpaq7.eem.corp.google.com with ESMTP id p4ANT4T2013387
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:29:05 -0700
Received: by pwi10 with SMTP id 10so4551353pwi.0
        for <linux-mm@kvack.org>; Tue, 10 May 2011 16:29:03 -0700 (PDT)
Date: Tue, 10 May 2011 16:29:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] oom: improve dump_tasks() show items
In-Reply-To: <20110510171600.16AB.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105101623220.12477@chino.kir.corp.google.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com> <20110510171600.16AB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, 10 May 2011, KOSAKI Motohiro wrote:

> Recently, oom internal logic was dramatically changed. Thus
> dump_tasks() is no longer useful. it has some meaningless
> items and don't have some oom socre related items.
> 

This changelog is inaccurate.

dump_tasks() is actually useful as it currently stands; there are things 
that you may add or remove but saying that it is "no longer useful" is an 
exaggeration.

> This patch adapt displaying fields to new oom logic.
> 
> details
> ==========
> removed: pid (we always kill process. don't need thread id),
>          mm->total_vm (we no longer uses virtual memory size)

Showing mm->total_vm is still interesting to know what the old heuristic 
would have used rather than the new heuristic, I'd prefer if we kept it.

>          signal->oom_adj (we no longer uses it internally)
> added: ppid (we often kill sacrifice child process)
> modify: RSS (account mm->nr_ptes too)

I'd prefer if ptes were shown independently from rss instead of adding it 
to the thread's true rss usage and representing it as such.

I think the cpu should also be removed.

For the next version, could you show the old output and comparsion to new 
output in the changelog?

> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> 
> Strictly speaking. this is NOT a part of oom fixing patches. but it's
> necessary when I parse QAI's test result.
> 
> 
>  mm/oom_kill.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f52e85c..118d958 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -355,7 +355,7 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
>  	struct task_struct *p;
>  	struct task_struct *task;
>  
> -	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
> +	pr_info("[   pid]   ppid   uid      rss  cpu score_adj name\n");
>  	for_each_process(p) {
>  		if (oom_unkillable_task(p, mem, nodemask))
>  			continue;
> @@ -370,11 +370,13 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
>  			continue;
>  		}
>  
> -		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
> -			task->pid, task_uid(task), task->tgid,
> -			task->mm->total_vm, get_mm_rss(task->mm),
> -			task_cpu(task), task->signal->oom_adj,
> -			task->signal->oom_score_adj, task->comm);
> +		pr_info("[%6d] %6d %5d %8lu %4u %9d %s\n",
> +			task_tgid_nr(task), task_tgid_nr(task->real_parent),
> +			task_uid(task),
> +			get_mm_rss(task->mm) + p->mm->nr_ptes,
> +			task_cpu(task),
> +			task->signal->oom_score_adj,
> +			task->comm);
>  		task_unlock(task);
>  	}
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
