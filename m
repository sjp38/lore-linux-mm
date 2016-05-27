Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECF76B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 08:23:11 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 132so24564818lfz.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 05:23:11 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id i192si4470073wmd.116.2016.05.27.05.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 05:23:10 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so13938379wmn.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 05:23:10 -0700 (PDT)
Date: Fri, 27 May 2016 14:23:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task more
 than twice
Message-ID: <20160527122308.GJ27686@dhcp22.suse.cz>
References: <1464276476-25136-1-git-send-email-mhocko@kernel.org>
 <201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@parallels.com

On Fri 27-05-16 19:31:19, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Hi,
> > I believe that after [1] and this patch we can reasonably expect that
> > the risk of the oom lockups is so low that we do not need to employ
> > timeout based solutions. I am sending this as an RFC because there still
> > might be better ways to accomplish the similar effect. I just like this
> > one because it is nicely grafted into the oom reaper which will now be
> > invoked for basically all oom victims.
> > 
> > [1] http://lkml.kernel.org/r/1464266415-15558-1-git-send-email-mhocko@kernel.org
> 
> I still cannot agree with "we do not need to employ timeout based solutions".
> 
> While it is true that OOM-reap is per "struct mm_struct" action, we don't
> need to change user visible oom_score_adj interface by [1] in order to
> enforce OOM-kill being per "struct mm_struct" action.

We want to change the oom_score_adj behavior for the pure consistency I
believe.

[...]

> Yes, commit 449d777d7ad6d7f9 ("mm, oom_reaper: clear TIF_MEMDIE for all tasks
> queued for oom_reaper") which went to Linux 4.7-rc1 will clear TIF_MEMDIE and
> decrement task->signal->oom_victims even if __oom_reap_task() cannot reap
> so that oom_scan_process_thread() will not return OOM_SCAN_ABORT forever.
> But still, such unlocking depends on an assumption that wake_oom_reaper() is
> always called.

which is practically the case. The only real exception are use_mm()
users. I want to look at those but I guess they need a special handling.

> What we need to have is "always call wake_oom_reaper() in order to let the
> OOM reaper clear TIF_MEMDIE and mark as no longer OOM-killable" or "ignore
> TIF_MEMDIE after some timeout". As you hate timeout, I propose below patch
> instead of [1] and your "[RFC PATCH] mm, oom_reaper: do not attempt to reap
> a task more than twice".
[...]
> @@ -849,22 +867,18 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
> -		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
> -		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> -			/*
> -			 * We cannot use oom_reaper for the mm shared by this
> -			 * process because it wouldn't get killed and so the
> -			 * memory might be still used.
> -			 */
> -			can_oom_reap = false;
> +		if (unlikely(p->flags & PF_KTHREAD))
>  			continue;
> -		}
> +		if (is_global_init(p))
> +			continue;
> +		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +			continue;
> +
>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>  	}
>  	rcu_read_unlock();
>  
> -	if (can_oom_reap)
> -		wake_oom_reaper(victim);
> +	wake_oom_reaper(victim);
>  
>  	mmdrop(mm);
>  	put_task_struct(victim);

So this is the biggest change to my approach. And I think it is
incorrect because you cannot simply reap the memory when you have active
users of that memory potentially. Shared with global init is just non
existant problem. Such a system would be crippled enough to not bother.
But use_mm is potentially real and I believe we should find some way
around it and even not consider such tasks. Fortunately we do not have
many users of use_mm in the kernel and most users will not use them.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
