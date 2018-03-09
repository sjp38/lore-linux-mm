Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 084656B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 08:11:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x7so1627721pfd.19
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 05:11:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m37-v6si843345plg.372.2018.03.09.05.11.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Mar 2018 05:11:03 -0800 (PST)
Subject: Re: [PATCH] mm: oom: Fix race condition between oom_badness and do_exit of task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <22ebd655-ece4-37e5-5a98-e9750cb20665@codeaurora.org>
	<d73682f9-f214-64c4-ce09-fd1ff3ffe252@I-love.SAKURA.ne.jp>
	<14ba6c44-d444-bd0a-0bac-0c6851b19344@codeaurora.org>
	<201803091948.FBC21396.LHOMSFFOVFtQJO@I-love.SAKURA.ne.jp>
	<c3b8dd2a-2636-2ce1-f7e7-c78a43608be1@codeaurora.org>
In-Reply-To: <c3b8dd2a-2636-2ce1-f7e7-c78a43608be1@codeaurora.org>
Message-Id: <201803092118.CCH34154.HOVLQFOFMJtFOS@I-love.SAKURA.ne.jp>
Date: Fri, 9 Mar 2018 21:18:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gkohli@codeaurora.org, rientjes@google.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

Kohli, Gaurav wrote:
> On 3/9/2018 4:18 PM, Tetsuo Handa wrote:
> 
> > Kohli, Gaurav wrote:
> >>> t->alloc_lock is still held when leaving find_lock_task_mm(), which means
> >>> that t->mm != NULL. But nothing prevents t from setting t->mm = NULL at
> >>> exit_mm() from do_exit() and calling exit_creds() from __put_task_struct(t)
> >>> after task_unlock(t) is called. Seems difficult to trigger race window. Maybe
> >>> something has preempted because oom_badness() becomes outside of RCU grace
> >>> period upon leaving find_lock_task_mm() when called from proc_oom_score().
> >> Hi Tetsuo,
> >>
> >> Yes it is not easy to reproduce seen twice till now and i agree with
> >> your analysis. But David has already fixing this in different way,
> >> So that also looks better to me:
> >>
> >> https://patchwork.kernel.org/patch/10265641/
> >>
> > Yes, I'm aware of that patch.
> >
> >> But if need to keep that code, So we have to bump up the task
> >> reference that's only i can think of now.
> > I don't think so, for I think it is safe to call
> > has_capability_noaudit(p) with p->alloc_lock held.
> >
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index f2e7dfb..4efcfb8 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -222,7 +222,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> >   	 */
> >   	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
> >   		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
> > -	task_unlock(p);
> >   
> >   	/*
> >   	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> > @@ -230,6 +229,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> >   	 */
> >   	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> >   		points -= (points * 3) / 100;
> > +	task_unlock(p);
> 
> Earlier i have thought the same to post this, but this may create 
> problem if there are sleeping calls in
> 
> has_capability_noaudit ?

has_capability_noaudit() does not sleep. See what has_ns_capability_noaudit() is doing.

> 
> >   
> >   	/* Normalize to oom_score_adj units */
> >   	adj *= totalpages / 1000;
> >
> -- 
> Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> a Linux Foundation Collaborative Project.
> 
> 
