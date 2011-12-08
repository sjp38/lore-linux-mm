Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 452B76B005C
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 22:45:02 -0500 (EST)
Received: by ggni2 with SMTP id i2so1692444ggn.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 19:45:01 -0800 (PST)
Date: Wed, 7 Dec 2011 19:44:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 RESEND] oom: fix integer overflow of points in
 oom_badness
In-Reply-To: <20111202174526.GA11483@dhcp-26-164.brq.redhat.com>
Message-ID: <alpine.DEB.2.00.1112071944210.636@chino.kir.corp.google.com>
References: <1320048865-13175-1-git-send-email-fhrbata@redhat.com> <20111202174526.GA11483@dhcp-26-164.brq.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, minchan.kim@gmail.com, stable@kernel.org, eteo@redhat.com, pmatouse@redhat.com, Greg Kroah-Hartman <gregkh@suse.de>

On Fri, 2 Dec 2011, Frantisek Hrbata wrote:

> An integer overflow will happen on 64bit archs if task's sum of rss, swapents
> and nr_ptes exceeds (2^31)/1000 value. This was introduced by commit
> 
> f755a04 oom: use pte pages in OOM score
> 
> where the oom score computation was divided into several steps and it's no
> longer computed as one expression in unsigned long(rss, swapents, nr_pte are
> unsigned long), where the result value assigned to points(int) is in
> range(1..1000). So there could be an int overflow while computing
> 
> 176          points *= 1000;
> 
> and points may have negative value. Meaning the oom score for a mem hog task
> will be one.
> 
> 196          if (points <= 0)
> 197                  return 1;
> 
> For example:
> [ 3366]     0  3366 35390480 24303939   5       0             0 oom01
> Out of memory: Kill process 3366 (oom01) score 1 or sacrifice child
> 
> Here the oom1 process consumes more than 24303939(rss)*4096~=92GB physical
> memory, but it's oom score is one.
> 
> In this situation the mem hog task is skipped and oom killer kills another and
> most probably innocent task with oom score greater than one.
> 
> The points variable should be of type long instead of int to prevent the int
> overflow.
> 
> Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: stable@kernel.org [2.6.36+]

Andrew, this looks like 3.2-rc5 material.

> ---
>  mm/oom_kill.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 626303b..e9a1785 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -162,7 +162,7 @@ static bool oom_unkillable_task(struct task_struct *p,
>  unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  		      const nodemask_t *nodemask, unsigned long totalpages)
>  {
> -	int points;
> +	long points;
>  
>  	if (oom_unkillable_task(p, mem, nodemask))
>  		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
