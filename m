Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id B33C06B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 09:44:28 -0500 (EST)
Date: Thu, 12 Jan 2012 15:44:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] mm, oom: do not emit oom killer warning if chosen
 thread is already exiting
Message-ID: <20120112144425.GB1300@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1201111924050.3982@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1201111924050.3982@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed 11-01-12 19:24:28, David Rientjes wrote:
> If a thread is chosen for oom kill and is already PF_EXITING, then the
> oom killer simply sets TIF_MEMDIE and returns.  This allows the thread to
> have access to memory reserves so that it may quickly exit.  This logic
> is preceeded with a comment saying there's no need to alarm the sysadmin.
> This patch adds truth to that statement.
> 
> There's no need to emit any warning about the oom condition if the thread
> is already exiting since it will not be killed.  In this condition, just
> silently return the oom killer since its only giving access to memory
> reserves and is otherwise a no-op.

Definitely

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -445,9 +445,6 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	struct mm_struct *mm;
>  	unsigned int victim_points = 0;
>  
> -	if (printk_ratelimit())
> -		dump_header(p, gfp_mask, order, mem, nodemask);
> -
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> @@ -457,6 +454,9 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		return;
>  	}
>  
> +	if (printk_ratelimit())
> +		dump_header(p, gfp_mask, order, mem, nodemask);
> +
>  	task_lock(p);
>  	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
>  		message, task_pid_nr(p), p->comm, points);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
