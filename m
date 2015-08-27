Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E8C816B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 04:40:48 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so67352220wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 01:40:48 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id b8si3467379wiz.119.2015.08.27.01.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 01:40:47 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so37511494wid.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 01:40:47 -0700 (PDT)
Date: Thu, 27 Aug 2015 10:40:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150827084045.GD14367@dhcp22.suse.cz>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
 <201508270003.FCD17618.FFVOFJHOQMSOtL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508270003.FCD17618.FFVOFJHOQMSOtL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 27-08-15 00:03:13, Tetsuo Handa wrote:
> Reposting updated version as it turned out that we can call do_send_sig_info()
> with task_lock held. ;-) ( http://marc.info/?l=linux-mm&m=144059948628905&w=2 )
> ----------------------------------------
> >From 69489b37171d9a84ccbb00e7441f8f73bc526e11 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 26 Aug 2015 23:54:12 +0900
> Subject: [PATCH] mm,oom: Reverse the order of setting TIF_MEMDIE and sending
>  SIGKILL.
> 
> It is observed that a multi-threaded program can deplete memory reserves
> using time lag between the OOM killer sets TIF_MEMDIE and the OOM killer
> sends SIGKILL. This is because a thread group leader who gets TIF_MEMDIE
> received SIGKILL too lately when there is a lot of child threads sharing
> the same memory due to doing a lot of printk() inside for_each_process()
> loop which can take many seconds.
> 
> Before starting oom-depleter process:
> 
>     Node 0 DMA: 3*4kB (UM) 6*8kB (U) 4*16kB (UEM) 0*32kB 0*64kB 1*128kB (M) 2*256kB (EM) 2*512kB (UE) 2*1024kB (EM) 1*2048kB (E) 1*4096kB (M) = 9980kB
>     Node 0 DMA32: 31*4kB (UEM) 27*8kB (UE) 32*16kB (UE) 13*32kB (UE) 14*64kB (UM) 7*128kB (UM) 8*256kB (UM) 8*512kB (UM) 3*1024kB (U) 4*2048kB (UM) 362*4096kB (UM) = 1503220kB
> 
> As of invoking the OOM killer:
> 
>     Node 0 DMA: 11*4kB (UE) 8*8kB (UEM) 6*16kB (UE) 2*32kB (EM) 0*64kB 1*128kB (U) 3*256kB (UEM) 2*512kB (UE) 3*1024kB (UEM) 1*2048kB (U) 0*4096kB = 7308kB
>     Node 0 DMA32: 1049*4kB (UEM) 507*8kB (UE) 151*16kB (UE) 53*32kB (UEM) 83*64kB (UEM) 52*128kB (EM) 25*256kB (UEM) 11*512kB (M) 6*1024kB (UM) 1*2048kB (M) 0*4096kB = 44556kB
> 
> Between the thread group leader got TIF_MEMDIE and receives SIGKILL:
> 
>     Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
>     Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> 
> The oom-depleter's thread group leader which got TIF_MEMDIE started
> memset() in user space after the OOM killer set TIF_MEMDIE, and it
> was free to abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE for memset()
> in user space until SIGKILL is delivered. If SIGKILL is delivered
> before TIF_MEMDIE is set, the oom-depleter can terminate without
> touching memory reserves.

The comment could have been a bit better because it doesn't exmplain
why but this is much much better.
 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

I guess you want to add Andrew to the CC because he might miss it this
way easily.

I would also consider marking this for stable.

Thanks!

> ---
>  mm/oom_kill.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5249e7e..408aa8e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -555,6 +555,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	/* Get a reference to safely compare mm after task_unlock(victim) */
>  	mm = victim->mm;
>  	atomic_inc(&mm->mm_users);
> +	/* Send SIGKILL before setting TIF_MEMDIE. */
> +	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>  	mark_oom_victim(victim);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> @@ -586,7 +588,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  		}
>  	rcu_read_unlock();
>  
> -	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>  	mmput(mm);
>  	put_task_struct(victim);
>  }
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
