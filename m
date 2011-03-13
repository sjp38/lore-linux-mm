Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA5FC8D003B
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 20:14:16 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p2D1EEJ4031286
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:14:14 -0800
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz29.hot.corp.google.com with ESMTP id p2D1EC4u020774
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:14:12 -0800
Received: by pwi5 with SMTP id 5so1152868pwi.31
        for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:14:11 -0800 (PST)
Date: Sat, 12 Mar 2011 17:14:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] oom: oom_kill_task: mark every thread as
 TIF_MEMDIE
In-Reply-To: <20110312134411.GB27275@redhat.com>
Message-ID: <alpine.DEB.2.00.1103121712430.10317@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <20110312134411.GB27275@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Sat, 12 Mar 2011, Oleg Nesterov wrote:

> --- 38/mm/oom_kill.c~oom_kill_spread_memdie	2011-03-12 14:19:36.000000000 +0100
> +++ 38/mm/oom_kill.c	2011-03-12 14:20:42.000000000 +0100
> @@ -401,6 +401,18 @@ static void dump_header(struct task_stru
>  		dump_tasks(mem, nodemask);
>  }
>  
> +static void do_oom_kill(struct task_struct *p)
> +{
> +	struct task_struct *t;
> +
> +	t = p;
> +	do {
> +		set_tsk_thread_flag(t, TIF_MEMDIE);
> +	} while_each_thread(p, t);
> +
> +	force_sig(SIGKILL, p);
> +}
> +
>  #define K(x) ((x) << (PAGE_SHIFT-10))
>  static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
>  {
> @@ -436,12 +448,10 @@ static int oom_kill_task(struct task_str
>  			pr_err("Kill process %d (%s) sharing same memory\n",
>  				task_pid_nr(q), q->comm);
>  			task_unlock(q);
> -			force_sig(SIGKILL, q);
> +			do_oom_kill(q);
>  		}
>  
> -	set_tsk_thread_flag(p, TIF_MEMDIE);
> -	force_sig(SIGKILL, p);
> -
> +	do_oom_kill(p);
>  	/*
>  	 * We give our sacrificial lamb high priority and access to
>  	 * all the memory it needs. That way it should be able to

As mentioned in the first posting of this patch, this isn't appropraite: 
we don't want to set TIF_MEMDIE to all threads unless they can't reclaim 
memory in the page allocator and are still in an oom condition.  The point 
is to try to limit TIF_MEMDIE to only those threads that are guaranteed to 
already be in the exit path or handling SIGKILLs, otherwise we risk 
depleting memory reserves entirely and there's no sanity checking here 
that would suggest that can't happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
