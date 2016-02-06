Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B363A440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 03:30:17 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so55846690wme.0
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 00:30:17 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id j187si3413135wma.69.2016.02.06.00.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Feb 2016 00:30:16 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id r129so6496918wmr.0
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 00:30:16 -0800 (PST)
Date: Sat, 6 Feb 2016 09:30:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160206083014.GA25220@dhcp22.suse.cz>
References: <1454505240-23446-4-git-send-email-mhocko@kernel.org>
 <201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
 <20160204144319.GD14425@dhcp22.suse.cz>
 <201602050008.HEG12919.FFOMOHVtQFSLJO@I-love.SAKURA.ne.jp>
 <20160204163113.GF14425@dhcp22.suse.cz>
 <201602052014.HBG52666.HFMOQVLFOSFJtO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602052014.HBG52666.HFMOQVLFOSFJtO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 05-02-16 20:14:40, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 05-02-16 00:08:25, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > > +	/*
> > > > > > +	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> > > > > > +	 * reasonably reclaimable memory anymore. OOM killer can continue
> > > > > > +	 * by selecting other victim if unmapping hasn't led to any
> > > > > > +	 * improvements. This also means that selecting this task doesn't
> > > > > > +	 * make any sense.
> > > > > > +	 */
> > > > > > +	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> > > > > > +	exit_oom_victim(tsk);
> > > > >
> > > > > I noticed that updating only one thread group's oom_score_adj disables
> > > > > further wake_oom_reaper() calls due to rough-grained can_oom_reap check at
> > > > >
> > > > >   p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN
> > > > >
> > > > > in oom_kill_process(). I think we need to either update all thread groups'
> > > > > oom_score_adj using the reaped mm equally or use more fine-grained can_oom_reap
> > > > > check which ignores OOM_SCORE_ADJ_MIN if all threads in that thread group are
> > > > > dying or exiting.
> > > >
> > > > I do not understand. Why would you want to reap the mm again when
> > > > this has been done already? The mm is shared, right?
> > >
> > > The mm is shared between previous victim and next victim, but these victims
> > > are in different thread groups. The OOM killer selects next victim whose mm
> > > was already reaped due to sharing previous victim's memory.
> >
> > OK, now I got your point. From your previous email it sounded like you
> > were talking about oom_reaper and its invocation which is was confusing.
> >
> > > We don't want the OOM killer to select such next victim.
> >
> > Yes, selecting such a task doesn't make much sense. It has been killed
> > so it has fatal_signal_pending. If it wanted to allocate it would get
> > TIF_MEMDIE already and it's address space has been reaped so there is
> > nothing to free left. These CLONE_VM without CLONE_SIGHAND is really
> > crazy combo, it is just causing troubles all over and I am not convinced
> > it is actually that helpful </rant>.
> >
> 
> I think moving "whether a mm is reapable or not" check to the OOM reaper
> is preferable (shown below). In most cases, mm_is_reapable() will return
> true.

Why should we select such a task in the first place when it's been
already oom reaped? I think it belongs to oom_scan_process_thread.
 
> ----------------------------------------
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b42c6bc..fc114b3 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -426,6 +426,39 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
>  static LIST_HEAD(oom_reaper_list);
>  static DEFINE_SPINLOCK(oom_reaper_lock);
>  
> +static bool mm_is_reapable(struct mm_struct *mm)
> +{
> +	struct task_struct *g;
> +	struct task_struct *p;
> +
> +	/*
> +	 * Since it is possible that p voluntarily called do_exit() or
> +	 * somebody other than the OOM killer sent SIGKILL on p, this mm used
> +	 * by p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN is reapable if p
> +	 * has pending SIGKILL or already reached do_exit().
> +	 *
> +	 * On the other hand, it is possible that mark_oom_victim(p) is called
> +	 * without sending SIGKILL to all tasks using this mm. In this case,
> +	 * the OOM reaper cannot reap this mm unless p is the only task using
> +	 * this mm.
> +	 *
> +	 * Therefore, determine whether this mm is reapable by testing whether
> +	 * all tasks using this mm are dying or already exiting rather than
> +	 * depending on p->signal->oom_score_adj value which is updated by the
> +	 * OOM reaper.
> +	 */
> +	rcu_read_lock();
> +	for_each_process_thread(g, p) {
> +		if (mm != READ_ONCE(p->mm) ||
> +		    fatal_signal_pending(p) || (p->flags & PF_EXITING))
> +			continue;
> +		mm = NULL;
> +		goto out;
> +	}
> + out:
> +	rcu_read_unlock();
> +	return mm != NULL;
> +}
>  
>  static bool __oom_reap_task(struct task_struct *tsk)
>  {
> @@ -455,7 +488,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  
>  	task_unlock(p);
>  
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> +	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
>  		ret = false;
>  		goto out;
>  	}
> @@ -596,6 +629,7 @@ void mark_oom_victim(struct task_struct *tsk)
>  	 */
>  	__thaw_task(tsk);
>  	atomic_inc(&oom_victims);
> +	wake_oom_reaper(tsk);
>  }
>  
>  /**
> @@ -680,7 +714,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> -	bool can_oom_reap = true;
>  
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
> @@ -771,23 +804,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
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
> -
>  	mmdrop(mm);
>  	put_task_struct(victim);
>  }
> ----------------------------------------

this is unnecessarily too complex IMO

> Then, I think we need to kill two lies in allocation retry loop.

This is completely unrelated to the topic discussed here.
[...]

> By moving "whether a mm is reapable or not" check to the OOM reaper, we can
> delegate the duty of clearing TIF_MEMDIE to the OOM reaper because the OOM
> reaper is tracking all TIF_MEMDIE tasks. Since mm_is_reapable() can return
> true for most situations, it becomes an unlikely corner case that we need to
> clear TIF_MEMDIE and prevent the OOM killer from setting TIF_MEMDIE on the
> same task again when the OOM reaper gave up. Like you commented in [PATCH 5/5],
> falling back to simple timer would be sufficient for handling such corner cases.

I am not really sure I understand what you are trying to tell here to be honest
but no I am not going to add any timers at this stage.

> | I would really prefer to go a simpler way first and extend the code when
> | we see the current approach insufficient for real life loads. Please do
> | not get me wrong, of course the code can be enhanced in many different
> | ways and optimize for lots of pathological cases but I really believe
> | that we should start with correctness first and only later care about
> | optimizing corner cases.
> 
> >
> > > Maybe set MMF_OOM_REAP_DONE on
> > > the previous victim's mm and check it instead of TIF_MEMDIE when selecting
> > > a victim? That will also avoid problems caused by clearing TIF_MEMDIE?
> >
> > Hmm, it doesn't seem we are under MMF_ availabel bits pressure right now
> > so using the flag sounds like the easiest way to go. Then we even do not
> > have to play with OOM_SCORE_ADJ_MIN which might be updated from the
> > userspace after the oom reaper has done that. Care to send a patch?
> 
> Not only we don't need to worry about ->oom_score_adj being modified from
> outside the SIGKILL pending tasks, I think we also don't need to clear remote
> TIF_MEMDIE if we use MMF_OOM_REAP_DONE. Something like below untested patch?

Dropping TIF_MEMDIE will help to unlock OOM killer as soon as we know
the current victim is no longer interesting for the OOM killer to allow
further victims selection. If we add MMF_OOM_REAP_DONE after reaping and
oom_scan_process_thread is taught to ignore those you will get all cases
of shared memory handles properly AFAICS. Such a patch should be really
trivial enhancement on top of the current code.

[...]

> I suggested many changes in this post because [PATCH 3/5] and [PATCH 5/5]
> made it possible for us to simplify [PATCH 1/5] like old versions. I think
> you want to rebuild this series with these changes merged as appropriate.

I would really _appreciate_ incremental changes as mentioned several
times already. And it would be really helpful if you could stick to
that. If you want to propose additional enhancements on top of the
current code you are free to do so but I am really reluctant to respin
everything to add more stuff into each patch and risk introduction of new
bugs. As things stand now patches are aiming to be as simple as possible
they do not introduce new bugs (except for the PM freezer which should
be fixable by a trivial patch which I will post after I get back from
vacation) and they improve things considerably in its current form
already.

I would like to target the next merge window rather than have this out
of tree for another release cycle which means that we should really
focus on the current functionality and make sure we haven't missed
anything. As there is no fundamental disagreement to the approach all
the rest are just technicalities.

Thanks

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
