Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8E06B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 03:16:08 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so97300828wml.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 00:16:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 131si12765558wmg.123.2016.03.07.00.16.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 00:16:06 -0800 (PST)
Date: Mon, 7 Mar 2016 09:16:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom: Do not sleep with oom_lock held.
Message-ID: <20160307081603.GA29372@dhcp22.suse.cz>
References: <201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp>
 <20160304160519.GG31257@dhcp22.suse.cz>
 <201603052337.EHH60964.VLJMHFQSFOOtFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603052337.EHH60964.VLJMHFQSFOOtFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Sat 05-03-16 23:37:14, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 03-03-16 19:42:00, Tetsuo Handa wrote:
> > > Michal, before we think about whether to add preempt_disable()/preempt_enable_no_resched()
> > > to oom_kill_process(), will you accept this patch?
> > > This is one of problems which annoy kmallocwd patch on CONFIG_PREEMPT_NONE=y kernels.
> > 
> > I dunno. It makes the code worse and it doesn't solve the underlying
> > problem (have a look at OOM notifiers which are blockable). Also
> > !PREEMPT only solution doesn't sound very useful as most of the
> > configurations will have PREEMPT enabled. I agree that having the OOM
> > killer preemptible is far from ideal, though, but this is harder than
> > just this sleep. Long term we should focus on making the oom context
> > not preemptible.
> > 
> 
> I think we are holding oom_lock inappropriately.
> 
>   /**
>    * mark_oom_victim - mark the given task as OOM victim
>    * @tsk: task to mark
>    *
>    * Has to be called with oom_lock held and never after
>    * oom has been disabled already.
> 
> This assumption is not true when lowmemorykiller is used.

To be honest I do not really care about the LMK. It abuses TIF_MEMDIE
and should be fixed to not do so. I would even go further and rather see
it go away from the tree completely. It is full of misconseptions and I
am not sure few fixes will make it work properly.

>    */
>   void mark_oom_victim(struct task_struct *tsk)
>   {
>   	WARN_ON(oom_killer_disabled);
>   	/* OOM killer might race with memcg OOM */
>   	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
>   		return;
> 
> Since both global OOM and memcg OOM hold oom_lock, global OOM and memcg
> OOM cannot race. Global OOM and memcg OOM can race with lowmemorykiller.
> 
> If we use per memcg oom_lock, we would be able to reduce latency when
> concurrent memcg OOMs are in progress.

I haven't heard any reports about memcg oom latencies being a
problem. Moreover the synchronization is more about oom_disable vs. oom.

> I'm wondering why freezing_slow_path() allows TIF_MEMDIE threads to escape from
> the __refrigerator().

If it didn't you could hide a memory hog into the fridge and livelock
the system. Feel free to use git blame to find the respective changelog
which should explain it.

> If the purpose of escaping is to release memory, waiting
> for existing TIF_MEMDIE threads is not sufficient if an mm is shared by multiple
> threads. We need to let all threads sharing that mm to escape when we choose an
> OOM victim. If we can assume that freezer depends on CONFIG_MMU=y, we can reclaim
> memory using the OOM reaper without setting TIF_MEMDIE. That will get rid of
> oom_killer_disable() and related exclusion code based on oom_lock.

You are free to send a patch if you believe you can simplify the code.
But be prepared that this is a land of many subtle issues.

> If we allow dying (SIGKILL pending or PF_EXITING) threads to access some of
> memory reserves, lowmemorykiller will be able to stop using TIF_MEMDIE.

LMK doesn't need TIF_MEMDIE at all because it kills tasks while there is
_some_ memory available. It tries to prevent from memory pressure before
we actually hit the OOM.

> And
> above assumption becomes always true. Also, since memcg OOMs are less urgent
> than global OOM, memcg OOMs might be able to stop using TIF_MEMDIE as well.

This is not so easy. Memcg OOM needs to be able to kill a frozen task
and that is where TIF_MEMDIE is used currently. We also need it for
synchronization with the freezer and oom_disable
 
> Then, only global OOM will use global oom_lock and TIF_MEMDIE. That is, we
> can offload handling of global OOM to a kernel thread which can run on any
> CPU with preemption disabled. The oom_lock will become unneeded because only
> one kernel thread will use it. If we add timestamp field to task_struct or
> signal_struct for recording when SIGKILL was delivered, we can emit warnings
> when victims cannot terminate.
> 
> I think we are in chicken-and-egg riddle about oom_lock and TIF_MEMDIE.

I am not really sure I see your problem. The lock itself is not the
biggest problem. If you want to have the OOM killer non-preemptible
there are different issues to address as I've tried to point out.

> > Anyway, wouldn't this be simpler?
> 
> Yes, I'm OK with your version.
> 
[...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1993894b4219..496498c4c32c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2888,6 +2881,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  	}
> >  out:
> >  	mutex_unlock(&oom_lock);
> > +	if (*did_some_progress) {
> 
> I think this line should be
> 
> 	if (*did_some_progress && !page)
> 
> because oom_killer_disabled && __GFP_NOFAIL likely makes page != NULL

Yes it doesn't make any sense to sleep when we allocated a page.
 
> > +		/*
> > +		 * Give the killed process a good chance to exit before trying
> > +		 * to allocate memory again.
> > +		 */
> > +		schedule_timeout_killable(1);
> > +	}
> 
> and this closing } is not needed.

I prefer brackets when there is a multi line comment...

> Sleeping when out_of_memory() was not called due to !__GFP_NOFAIL && !__GFP_FS
> will help somebody else to make a progress for us? (My version did not change it.)

It will throttle the request a bit which shouldn't be of any harm as the
context hasn't done any progress.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
