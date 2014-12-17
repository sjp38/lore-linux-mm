Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 744F96B006E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 08:08:10 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so16016637wiv.7
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 05:08:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si27174634wiy.81.2014.12.17.05.08.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 05:08:09 -0800 (PST)
Date: Wed, 17 Dec 2014 14:08:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141217130807.GB24704@dhcp22.suse.cz>
References: <201412122254.AJJ57896.OLFOOJQHSMtFVF@I-love.SAKURA.ne.jp>
 <20141216124714.GF22914@dhcp22.suse.cz>
 <201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Wed 17-12-14 20:54:53, Tetsuo Handa wrote:
[...]
> I'm not familiar with memcg.

This check doesn't make any sense for this path because the task is part
of the memcg, otherwise it wouldn't trigger charge for it and couldn't
cause the OOM killer. Kernel threads do not have their address space
they cannot trigger memcg OOM killer. As you provide NULL nodemask then
this is basically a check for task being part of the memcg. The check
for current->mm is not needed as well because task will not trigger a
charge after exit_mm.

> But I think the condition whether TIF_MEMDIE
> flag should be set or not should be same between the memcg OOM killer and
> the global OOM killer, for a thread inside some memcg with TIF_MEMDIE flag
> can prevent the global OOM killer from killing other threads when the memcg
> OOM killer and the global OOM killer run concurrently (the worst corner case).
> When a malicious user runs a memory consumer program which triggers memcg OOM
> killer deadlock inside some memcg, it will result in the global OOM killer
> deadlock when the global OOM killer is triggered by other user's tasks.

Hope that the above exaplains your concerns here.

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 481d550..01719d6 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > [...]
> > > @@ -649,8 +649,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> > >       * If current has a pending SIGKILL or is exiting, then automatically
> > >       * select it.  The goal is to allow it to allocate so that it may
> > >       * quickly exit and free its memory.
> > > +     *
> > > +     * However, if current is calling out_of_memory() by doing memory
> > > +     * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
> > > +     * was set by exit_signals() and mm was released by exit_mm(), it is
> > > +     * wrong to expect current to exit and free its memory quickly.
> > >       */
> > > -     if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> > > +     if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
> > > +         current->mm && !oom_unkillable_task(current, NULL, nodemask)) {
> > >            set_thread_flag(TIF_MEMDIE);
> > >            return;
> > >       }
> >
> > Calling oom_unkillable_task doesn't make much sense to me. Even if it made
> > sense it should be in a separate patch, no?
> 
> At least for the global OOM case, current may be a kernel thread, doesn't it?

then mm would be NULL most of the time so current->mm check wouldn't
give it TIF_MEMDIE and the task itself will be exluded later on during
tasks scanning.

> Such kernel thread can do memory allocation from exit_task_work(), and trigger
> the global OOM killer, and disable the global OOM killer and prevent other
> threads from allocating memory, can't it?
> 
> We can utilize memcg for reducing the possibility of triggering the global
> OOM killer.

I do not get this. Memcg charge happens after the allocation is done so
the global OOM killer would trigger before memcg one.

> But if we failed to prevent the global OOM killer from triggering,
> the global OOM killer is responsible for solving the OOM condition than keeping
> the system stalled for presumably forever. Panic on TIF_MEMDIE timeout can act
> like /proc/sys/vm/panic_on_oom only when the OOM killer chose (by chance or
> by a trap) an unkillable (due to e.g. lock dependency loop) task. Of course,
> for those who prefer the system kept stalled over the OOM condition solved,
> such action should be optional and thus I'm happy to propose sysctl-tunable
> version.

You are getting offtopic again (which is pretty annoying to be honest as
it is going all over again and again). Please focus on a single thing at
a time.

> I think that
> 
>     if (!task->mm && test_tsk_thread_flag(task, TIF_MEMDIE))
>         return true;
> 
> check should be added to oom_unkillable_task() because mm-less thread can
> release little memory (except invisible memory if any).

Why do you think this makes more sense than handling this very special
case in out_of_memory? I really do not see any reason to to make
oom_unkillable_task more complicated.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
