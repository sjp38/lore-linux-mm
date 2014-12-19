Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C7E176B0073
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 07:49:05 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so1227932wgh.22
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 04:49:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si3163785wif.101.2014.12.19.04.49.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 04:49:04 -0800 (PST)
Date: Fri, 19 Dec 2014 13:49:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141219124903.GB18397@dhcp22.suse.cz>
References: <20141216124714.GF22914@dhcp22.suse.cz>
 <201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
 <20141217130807.GB24704@dhcp22.suse.cz>
 <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
 <20141218153341.GB832@dhcp22.suse.cz>
 <201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Fri 19-12-14 21:07:53, Tetsuo Handa wrote:
[...]
> >From 3c68c66a72f0dbfc66f9799a00fbaa1f0217befb Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 19 Dec 2014 20:49:06 +0900
> Subject: [PATCH v2] oom: Don't count on mm-less current process.
> 
> out_of_memory() doesn't trigger the OOM killer if the current task is already
> exiting or it has fatal signals pending, and gives the task access to memory
> reserves instead. However, doing so is wrong if out_of_memory() is called by
> an allocation (e.g. from exit_task_work()) after the current task has already
> released its memory and cleared TIF_MEMDIE at exit_mm(). If we again set
> TIF_MEMDIE to post-exit_mm() current task, the OOM killer will be blocked by
> the task sitting in the final schedule() waiting for its parent to reap it.
> It will trigger an OOM livelock if its parent is unable to reap it due to
> doing an allocation and waiting for the OOM killer to kill it.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.cz>

Just a nit, You could start the condition with current->mm because it
is the simplest check. We do not have to check for signals pending or
PF_EXITING at all if it is NULL. But this is not a hot path so it
doesn't matter much. It is just a good practice to start with the
simplest tests first.

Please also make sure to add Andrew to CC when sending the patch again
so that he knows about it and picks it up.

Thanks!

> ---
>  mm/oom_kill.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 481d550..e87391f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -649,8 +649,12 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	 * If current has a pending SIGKILL or is exiting, then automatically
>  	 * select it.  The goal is to allow it to allocate so that it may
>  	 * quickly exit and free its memory.
> +	 *
> +	 * But don't select if current has already released its mm and cleared
> +	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
>  	 */
> -	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> +	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
> +	    current->mm) {
>  		set_thread_flag(TIF_MEMDIE);
>  		return;
>  	}
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
