Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 925DD6B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 16:07:11 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf1so6694805pab.24
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 13:07:10 -0700 (PDT)
Date: Mon, 9 Sep 2013 13:07:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] OOM killer: wait for tasks with pending SIGKILL to
 exit
In-Reply-To: <1378740624-2456-1-git-send-email-dserrg@gmail.com>
Message-ID: <alpine.DEB.2.02.1309091303010.12523@chino.kir.corp.google.com>
References: <1378740624-2456-1-git-send-email-dserrg@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rusty Russell <rusty@rustcorp.com.au>, Sha Zhengju <handai.szj@taobao.com>, Oleg Nesterov <oleg@redhat.com>

On Mon, 9 Sep 2013, Sergey Dyasly wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 98e75f2..ef83b81 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -275,13 +275,16 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task->flags & PF_EXITING && !force_kill) {
> +	if ((task->flags & PF_EXITING || fatal_signal_pending(task)) &&
> +	    !force_kill) {

This makes sense.

>  		/*
>  		 * If this task is not being ptraced on exit, then wait for it
>  		 * to finish before killing some other task unnecessarily.
>  		 */
> -		if (!(task->group_leader->ptrace & PT_TRACE_EXIT))
> +		if (!(task->group_leader->ptrace & PT_TRACE_EXIT)) {
> +			set_tsk_thread_flag(task, TIF_MEMDIE);

This does not, we do not give access to memory reserves unless the process 
needs it to allocate memory.  The task here, which is not current, can 
call into the oom killer and be granted memory reserves if necessary.

>  			return OOM_SCAN_ABORT;
> +		}
>  	}
>  	return OOM_SCAN_OK;
>  }
> @@ -412,16 +415,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
>  
> -	/*
> -	 * If the task is already exiting, don't alarm the sysadmin or kill
> -	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> -	 */
> -	if (p->flags & PF_EXITING) {
> -		set_tsk_thread_flag(p, TIF_MEMDIE);
> -		put_task_struct(p);
> -		return;
> -	}

I think you misunderstood the point of this; if a selected process is 
already in the exit path then this is simply avoiding dumping oom kill 
lines to the kernel log.  We want to keep doing that.

> -
>  	if (__ratelimit(&oom_rs))
>  		dump_header(p, gfp_mask, order, memcg, nodemask);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
