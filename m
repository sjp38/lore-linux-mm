Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id 224726B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 13:36:33 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so7571094qeb.41
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 10:36:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h17si21161216qej.3.2013.11.28.10.36.31
        for <linux-mm@kvack.org>;
        Thu, 28 Nov 2013 10:36:31 -0800 (PST)
Date: Thu, 28 Nov 2013 19:37:02 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Message-ID: <20131128183702.GC20740@redhat.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ma, Xindong" <xindong.ma@intel.com>, Sameer Nanda <snanda@chromium.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "rientjes@google.com" <rientjes@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Peter Zijlstra' <peterz@infradead.org>, "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>

On 11/28, Ma, Xindong wrote:
>
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -412,16 +412,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
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
> -
>  	if (__ratelimit(&oom_rs))
>  		dump_header(p, gfp_mask, order, memcg, nodemask);
>  
> @@ -437,6 +427,16 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 * still freeing memory.
>  	 */
>  	read_lock(&tasklist_lock);
> +	/*
> +	 * If the task is already exiting, don't alarm the sysadmin or kill
> +	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> +	 */
> +	if (p->flags & PF_EXITING) {
> +		set_tsk_thread_flag(p, TIF_MEMDIE);
> +		put_task_struct(p);
> +		read_unlock(&tasklist_lock);
> +		return;
> +	}

I got lost... didn't we recently discussed the similar patch from Sameer?

This one doesn't look right. find_lock_task_mm() after unlock(tasklist)
can hit the same problem.

I belive the patch from Sameer was correct.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
