Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B034F6B0071
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:20:07 -0400 (EDT)
Received: by pvg11 with SMTP id 11so423100pvg.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 07:19:52 -0700 (PDT)
Date: Wed, 30 Jun 2010 23:19:44 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 03/11] oom: make oom_unkillable_task() helper function
Message-ID: <20100630141944.GE15644@barrios-desktop>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
 <20100630182752.AA4E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630182752.AA4E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 06:28:37PM +0900, KOSAKI Motohiro wrote:
> Now, we have the same task check in two places. Unify it.
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |   33 ++++++++++++++++++++++-----------
>  1 files changed, 22 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dc8589e..a4a5439 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -101,6 +101,26 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
>  	return NULL;
>  }
>  
> +/* return true if the task is not adequate as candidate victim task. */
> +static bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *mem,
> +			   const nodemask_t *nodemask)
> +{
> +	if (is_global_init(p))
> +		return true;
> +	if (p->flags & PF_KTHREAD)
> +		return true;
> +
> +	/* When mem_cgroup_out_of_memory() and p is not member of the group */
> +	if (mem && !task_in_mem_cgroup(p, mem))
> +		return true;
> +
> +	/* p may not have freeable memory in nodemask */
> +	if (!has_intersects_mems_allowed(p, nodemask))
> +		return true;
> +
> +	return false;
> +}
> +

I returend this patch as review 7/11. 
Why didn't you check p->signal->oom_adj == OOM_DISABLE in here?
I don't figure out code after your patches are applied totally.
But I think it would be check it in this function as function's name says.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
