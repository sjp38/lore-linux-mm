Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B624E6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 10:06:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a66so73837997wme.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:06:41 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id y142si616689wme.31.2016.06.27.07.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 07:06:40 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a66so24847423wme.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:06:39 -0700 (PDT)
Date: Mon, 27 Jun 2016 16:06:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
Message-ID: <20160627140637.GM31799@dhcp22.suse.cz>
References: <20160624095439.GA20203@dhcp22.suse.cz>
 <201606241956.IDD09840.FSFOOVMJOHQLtF@I-love.SAKURA.ne.jp>
 <20160624120454.GB20203@dhcp22.suse.cz>
 <201606250119.IIJ30735.FMSHQFVtOLOJOF@I-love.SAKURA.ne.jp>
 <20160627113709.GG31799@dhcp22.suse.cz>
 <201606272232.BCF78614.LHFFFOSQOMtVOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606272232.BCF78614.LHFFFOSQOMtVOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

On Mon 27-06-16 22:32:17, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 25-06-16 01:19:12, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index 4c21f744daa6..97be9324a58b 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -671,6 +671,22 @@ void mark_oom_victim(struct task_struct *tsk)
> > > >  	/* OOM killer might race with memcg OOM */
> > > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > >  		return;
> > > > +#ifndef CONFIG_MMU
> > > > +	/*
> > > > +	 * we shouldn't risk setting TIF_MEMDIE on a task which has passed its
> > > > +	 * exit_mm task->mm = NULL and exit_oom_victim otherwise it could
> > > > +	 * theoretically keep its TIF_MEMDIE for ever while waiting for a parent
> > > > +	 * to get it out of zombie state. MMU doesn't have this problem because
> > > > +	 * it has the oom_reaper to clear the flag asynchronously.
> > > > +	 */
> > > > +	task_lock(tsk);
> > > > +	if (!tsk->mm) {
> > > > +		clear_tsk_thread_flag(tsk, TIF_MEMDIE);
> > > > +		task_unlock(tsk);
> > > > +		return;
> > > > +	}
> > > > +	taks_unlock(tsk);
> > > 
> > > This makes mark_oom_victim(tsk) for tsk->mm == NULL a no-op unless tsk is
> > > currently doing memory allocation. And it is possible that tsk is blocked
> > > waiting for somebody else's memory allocation after returning from
> > > exit_mm() from do_exit(), isn't it? Then, how is this better than current
> > > code (i.e. sets TIF_MEMDIE to a mm-less thread group leader)?
> > 
> > Well, the whole point of the check is to not set the flag after we
> > could have passed exit_mm->exit_oom_victim and keep it for the rest of
> > (unbounded) victim life as there is nothing else to do so.
> 
> OK. Based on commit 3da88fb3bacfaa33 ("mm, oom: move GFP_NOFS check to
> out_of_memory") and an assumption that any OOM-killed thread shall eventually
> win the mutex_trylock(&oom_lock) competition in __alloc_pages_may_oom() no
> matter how disturbing factors (e.g. scheduling priority) delay OOM-killed
> threads, you prefer asking each OOM-killed thread to get TIF_MEMDIE via
> 
>   if (current->mm && task_will_free_mem(current))
> 
> shortcut in out_of_memory() by keeping
> 
>   if (task_will_free_mem(p))
> 
> shortcut in oom_kill_process() a no-op. Yes, it should be harmless.

OK, I understand your point finally. Thanks for the clarification! And
you are right, I really do not care all that much about the latency
here. All I am looking for is the most simplistic solution for the
potential, albeit highly unlikely, race for a configuration for which
nobody actually complained/reported a bug.
 
> But I prefer not to wait for each OOM-killed thread to win the
> mutex_trylock(&oom_lock) competition in __alloc_pages_may_oom().
> Setting TIF_MEMDIE at
> 
>   if (task_will_free_mem(p))
> 
> shortcut in oom_kill_process() can save somebody which got TIF_MEMDIE from
> participating in the mutex_trylock(&oom_lock) competition which is needed for
> calling
> 
>   if (current->mm && task_will_free_mem(current))
> 
> shortcut in out_of_memory().

The code is complex enough that keeping it simpler makes a lot of sense
to me. Your dances with the find_lock_task_mm really didn't make it
easier to follow IMHO. The explicit check at a single place seems more
obious and easier to maintain to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
