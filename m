Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5946B000C
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:37:36 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d17-v6so5023883pll.8
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:37:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si130334pgr.588.2018.03.13.06.37.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 06:37:35 -0700 (PDT)
Date: Tue, 13 Mar 2018 14:37:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: oom: Fix race condition between oom_badness and
 do_exit of task
Message-ID: <20180313133732.GS12772@dhcp22.suse.cz>
References: <1520427454-22813-1-git-send-email-gkohli@codeaurora.org>
 <alpine.DEB.2.20.1803071254410.165297@chino.kir.corp.google.com>
 <22ebd655-ece4-37e5-5a98-e9750cb20665@codeaurora.org>
 <d73682f9-f214-64c4-ce09-fd1ff3ffe252@I-love.SAKURA.ne.jp>
 <14ba6c44-d444-bd0a-0bac-0c6851b19344@codeaurora.org>
 <201803091948.FBC21396.LHOMSFFOVFtQJO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803091948.FBC21396.LHOMSFFOVFtQJO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: gkohli@codeaurora.org, rientjes@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

[Sorry about the slow response but I was offline for almost two weeks
and catching up with a tsunami in my inbox now]

On Fri 09-03-18 19:48:46, Tetsuo Handa wrote:
> Kohli, Gaurav wrote:
> > > t->alloc_lock is still held when leaving find_lock_task_mm(), which means
> > > that t->mm != NULL. But nothing prevents t from setting t->mm = NULL at
> > > exit_mm() from do_exit() and calling exit_creds() from __put_task_struct(t)
> > > after task_unlock(t) is called. Seems difficult to trigger race window. Maybe
> > > something has preempted because oom_badness() becomes outside of RCU grace
> > > period upon leaving find_lock_task_mm() when called from proc_oom_score().
> > 
> > Hi Tetsuo,
> > 
> > Yes it is not easy to reproduce seen twice till now and i agree with
> > your analysis. But David has already fixing this in different way,
> > So that also looks better to me:
> > 
> > https://patchwork.kernel.org/patch/10265641/
> > 
> 
> Yes, I'm aware of that patch.
> 
> > But if need to keep that code, So we have to bump up the task
> > reference that's only i can think of now.
> 
> I don't think so, for I think it is safe to call
> has_capability_noaudit(p) with p->alloc_lock held.

This however adds a subtle assumption on locking here and we should
rather not do so. The scope of alloc_lock is quite messy already and
adding on top is definitely not an improvement.

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f2e7dfb..4efcfb8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -222,7 +222,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	 */
>  	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
>  		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
> -	task_unlock(p);
>  
>  	/*
>  	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> @@ -230,6 +229,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	 */
>  	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
>  		points -= (points * 3) / 100;
> +	task_unlock(p);
>  
>  	/* Normalize to oom_score_adj units */
>  	adj *= totalpages / 1000;

-- 
Michal Hocko
SUSE Labs
