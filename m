Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 529EA8D003B
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 20:08:49 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p2D18lpK000432
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:08:47 -0800
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by kpbe19.cbf.corp.google.com with ESMTP id p2D18jrf007004
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:08:46 -0800
Received: by pwi3 with SMTP id 3so688238pwi.9
        for <linux-mm@kvack.org>; Sat, 12 Mar 2011 17:08:45 -0800 (PST)
Date: Sat, 12 Mar 2011 17:08:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] oom_kill_task: mark every thread as TIF_MEMDIE
In-Reply-To: <20110310154110.GB29044@redhat.com>
Message-ID: <alpine.DEB.2.00.1103121706210.10317@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309110606.GA16719@redhat.com>
 <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com> <20110310120519.GA18415@redhat.com> <20110310154032.GA29044@redhat.com> <20110310154110.GB29044@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Thu, 10 Mar 2011, Oleg Nesterov wrote:

> --- 38/mm/oom_kill.c~oom_kill_spread_memdie	2011-03-08 14:45:49.000000000 +0100
> +++ 38/mm/oom_kill.c	2011-03-10 16:08:51.000000000 +0100
> @@ -401,6 +401,17 @@ static void dump_header(struct task_stru
>  		dump_tasks(mem, nodemask);
>  }
>  
> +static void do_oom_kill(struct task_struct *p)
> +{
> +	struct task_struct *t;
> +
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
> @@ -436,12 +447,10 @@ static int oom_kill_task(struct task_str
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
> 
> 

This isn't appropriate: we specifically try to limit TIF_MEMDIE to only 
threads that need it (those that need it in the exit path), otherwise we 
risk completely depleting all memory, which would result in an oom 
deadlock.  TIF_MEMDIE isn't supposed to be used as a flag to detect oom 
killed task despite its use in select_bad_process() -- if a thread needs 
access to memory reserves after receiving a SIGKILL then out_of_memory() 
provides that appropriately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
