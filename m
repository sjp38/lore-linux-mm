Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C2C9E6B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:18:10 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so65836061wic.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:18:10 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id ey16si30915995wjc.79.2015.08.24.02.18.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 02:18:09 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so65637190wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:18:09 -0700 (PDT)
Date: Mon, 24 Aug 2015 11:18:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 1/2] mm,oom: Fix potentially killing unrelated
 process.
Message-ID: <20150824091806.GE17078@dhcp22.suse.cz>
References: <201508231618.CEC87056.VLStMFFHOJQFOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508231618.CEC87056.VLStMFFHOJQFOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Sun 23-08-15 16:18:00, Tetsuo Handa wrote:
[...]
> >From 2c5c4da4c9c5a124820f53f138c456e07c9248bb Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 31 Jul 2015 13:37:31 +0900
> Subject: [PATCH 1/2] mm,oom: Fix potentially killing unrelated process.
> 
> At the for_each_process() loop in oom_kill_process(), we are comparing
> address of OOM victim's mm without holding a reference to that mm.
> If there are a lot of processes to compare or a lot of "Kill process
> %d (%s) sharing same memory" messages to print, for_each_process() loop
> could take very long time.
> 
> It is possible that meanwhile the OOM victim exits and releases its mm,
> and then mm is allocated with the same address and assigned to some
> unrelated process. When we hit such race, the unrelated process will be
> killed by error. To make sure that the OOM victim's mm does not go away
> until for_each_process() loop finishes, get a reference on the OOM
> victim's mm before calling task_unlock(victim).

The race is quite unlikely but I guess it is possible

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1ecc0bc..5249e7e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -552,8 +552,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  		victim = p;
>  	}
>  
> -	/* mm cannot safely be dereferenced after task_unlock(victim) */
> +	/* Get a reference to safely compare mm after task_unlock(victim) */
>  	mm = victim->mm;
> +	atomic_inc(&mm->mm_users);
>  	mark_oom_victim(victim);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> @@ -586,6 +587,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	rcu_read_unlock();
>  
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> +	mmput(mm);
>  	put_task_struct(victim);
>  }
>  #undef K
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
