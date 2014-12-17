Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EE83C6B006E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 06:54:59 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so16253915pad.17
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 03:54:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bg5si5401110pbc.38.2014.12.17.03.54.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 03:54:58 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412122254.AJJ57896.OLFOOJQHSMtFVF@I-love.SAKURA.ne.jp>
	<20141216124714.GF22914@dhcp22.suse.cz>
In-Reply-To: <20141216124714.GF22914@dhcp22.suse.cz>
Message-Id: <201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
Date: Wed, 17 Dec 2014 20:54:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > ---
> >  include/linux/oom.h |  3 +++
> >  mm/memcontrol.c     |  8 +++++++-
> >  mm/oom_kill.c       | 12 +++++++++---
> >  3 files changed, 19 insertions(+), 4 deletions(-)
> >
> [...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c6ac50e..6d9532d 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1558,8 +1558,14 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >       * If current has a pending SIGKILL or is exiting, then automatically
> >       * select it.  The goal is to allow it to allocate so that it may
> >       * quickly exit and free its memory.
> > +     *
> > +     * However, if current is calling out_of_memory() by doing memory
> > +     * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
> > +     * was set by exit_signals() and mm was released by exit_mm(), it is
> > +     * wrong to expect current to exit and free its memory quickly.
> >       */
> > -     if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
> > +     if ((fatal_signal_pending(current) || current->flags & PF_EXITING) &&
> > +         current->mm && !oom_unkillable_task(current, memcg, NULL)) {
> >            set_thread_flag(TIF_MEMDIE);
> >            return;
> >       }
>
> Why do you check oom_unkillable_task for memcg OOM killer?
>

I'm not familiar with memcg. But I think the condition whether TIF_MEMDIE
flag should be set or not should be same between the memcg OOM killer and
the global OOM killer, for a thread inside some memcg with TIF_MEMDIE flag
can prevent the global OOM killer from killing other threads when the memcg
OOM killer and the global OOM killer run concurrently (the worst corner case).
When a malicious user runs a memory consumer program which triggers memcg OOM
killer deadlock inside some memcg, it will result in the global OOM killer
deadlock when the global OOM killer is triggered by other user's tasks.

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 481d550..01719d6 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> [...]
> > @@ -649,8 +649,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >       * If current has a pending SIGKILL or is exiting, then automatically
> >       * select it.  The goal is to allow it to allocate so that it may
> >       * quickly exit and free its memory.
> > +     *
> > +     * However, if current is calling out_of_memory() by doing memory
> > +     * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
> > +     * was set by exit_signals() and mm was released by exit_mm(), it is
> > +     * wrong to expect current to exit and free its memory quickly.
> >       */
> > -     if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> > +     if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
> > +         current->mm && !oom_unkillable_task(current, NULL, nodemask)) {
> >            set_thread_flag(TIF_MEMDIE);
> >            return;
> >       }
>
> Calling oom_unkillable_task doesn't make much sense to me. Even if it made
> sense it should be in a separate patch, no?

At least for the global OOM case, current may be a kernel thread, doesn't it?
Such kernel thread can do memory allocation from exit_task_work(), and trigger
the global OOM killer, and disable the global OOM killer and prevent other
threads from allocating memory, can't it?

We can utilize memcg for reducing the possibility of triggering the global
OOM killer. But if we failed to prevent the global OOM killer from triggering,
the global OOM killer is responsible for solving the OOM condition than keeping
the system stalled for presumably forever. Panic on TIF_MEMDIE timeout can act
like /proc/sys/vm/panic_on_oom only when the OOM killer chose (by chance or
by a trap) an unkillable (due to e.g. lock dependency loop) task. Of course,
for those who prefer the system kept stalled over the OOM condition solved,
such action should be optional and thus I'm happy to propose sysctl-tunable
version.

I think that

    if (!task->mm && test_tsk_thread_flag(task, TIF_MEMDIE))
        return true;

check should be added to oom_unkillable_task() because mm-less thread can
release little memory (except invisible memory if any). And if we add
TIF_MEMDIE timeout check to oom_unkillable_task(), we can wait for mm-less
TIF_MEMDIE thread for a short period before trying to kill other threads
(as with with-mm TIF_MEMDIE threads which I demonstrated you off-list on
Sat, 13 Dec 2014 23:28:33 +0900).

The post exit_mm() issues will remain as long as OOM deadlock by pre
exit_mm() issues remains. And as I demonstrated you off-list, OOM deadlock
by pre exit_mm() issues is too difficult to solve because you will need to
track every lock dependency like lockdep does. Thus, I think that this
"oom: Don't count on mm-less current process." patch itself is a junk and
I added "the whole paragraph" for guiding you to "how to handle TIF_MEMDIE
deadlock caused by pre exit_mm() issues".

Generally memcg should work, but memcg depends on coordination with userspace
where the targets I'm troubleshooting (i.e. currently deployed enterprise
servers) do not have. The cause of deadlock/slowdown may be not a malicious
user's attacks but bugs in enterprise applications or kernel modules. To debug
troubles in currently deployed enterprise servers, I want a solution to "handle
TIF_MEMDIE deadlock caused by pre exit_mm() issues without depending on memcg".
But to backport the solution to currently deployed enterprise servers, it needs
to be first accepted by upstream. You say "Upstream kernels do not need
TIF_MEMDIE timeout. Use memcg and you will not see the global OOM condition."
but I can't force the targets to use memcg. Well, it's a chicken-and-egg
situation...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
