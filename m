Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFF776B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 08:51:18 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j8so8773083lfd.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:51:18 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id gk7si3466502wjb.5.2016.05.17.05.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 05:51:17 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so4527558wmw.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:51:16 -0700 (PDT)
Date: Tue, 17 May 2016 14:51:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160517125115.GI14453@dhcp22.suse.cz>
References: <20160426135402.GB20813@dhcp22.suse.cz>
 <201604271943.GAC60432.FFJHtFVSOQOOLM@I-love.SAKURA.ne.jp>
 <20160427111147.GI2179@dhcp22.suse.cz>
 <201605140939.BFG05745.FJOOOSVQtLFMHF@I-love.SAKURA.ne.jp>
 <20160516141829.GK23146@dhcp22.suse.cz>
 <201605172008.FGB26547.OSMFVOQtLFHJOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605172008.FGB26547.OSMFVOQtLFHJOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Tue 17-05-16 20:08:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
[... Skipping parts unrelated to this discussion ...]

> > You are basically DoSing your machine and that leads to corner cases of
> > course. We can and should try to plug them but I still do not see any
> > reason to rush into any solutions.
> 
> My intent of doing what-you-call-DoS stress tests is
> 
>    You had better realize that we can't find all corner cases.
>    It is not a responsible attitude that you knowingly preserve
>    corner cases with "can you trigger it?".

You are still missing the important point. Scenarios you are testing are
killing the machine anyway. This is interesting to catch some corner
cases which might happen even without killing the machine and that is
why they are interesting but they are light years away from any
reasonably working systems. And that is probably why nobody give a damn
about possible deadlocks during OOM all those years. Don't you think?

> The OOM killer is a safety net in case something went wrong (e.g.
> a ranaway program).

OOM killer is a best effort to handle out-of-memory condition. It's
never been perfect and never will be. Full stop. If you want your system
behave reasonably, better configure it properly that you do not hit the
OOM situation. This is what every reasonable admin will tell you.

> You refuse to care about corner cases.

Pardon me but it's been some time since I've tried to understand and
cope with those corner cases much as reasonable without introducing new
wormholes.

> How can it be
> called "robust / reliable" without the ability to handle corner cases?
> As long as minimal infrastructure for handling the OOM situation (e.g.
> scheduler) is alive, we should strive for recovering from the OOM situation
> (as with you strive for making the OOM reaper context reliable as much as
> possible).

I am not going to repeat my arguments here for 101st time.

> > You seem to be bound to the timeout solution so much that you even
> > refuse to think about any other potential ways to move on. I think that
> > is counter productive. I have tried to explain many times that once you
> > define a _user_ _visible_ knob you should better define a proper semantic
> > for it. Do something with a random outcome is not it.
> 
> Waiting for feedback without offering a workaround is counterproductive
> when we are already aware of bugs. Offering a workaround first and then
> trying to fix easily triggerable bugs is appreciated for those who can not
> update kernels for their systems due to their constraints. It is up to
> users to decide whether to use workarounds.

Not if the workaround is a user visible api which basically gets carved
in stone once we release it. We have a good history of doing this
mistake over and over.

> The reason I insist on the timeout based approach is the robustness.
> 
>    (A) It can work on CONFIG_MMU=n kernels.
> 
>    (B) It can work even if kthread_run(oom_reaper, NULL, "oom_reaper")
>        returned an error.
> 
>    (C) It gives more accurately bounded delay (compared to waiting for
>        TIF_MEMDIE being sequentially cleared by the OOM reaper) even if
>        there are so many threads on the oom_reaper_list list.
> 
>    (D) It can work even if the OOM reaper cannot run for long time
>        for unknown reasons (e.g. preempted by realtime priority tasks).
> 
>    (E) We can handle all corner cases without proving that they are
>        triggerable issues in the real life.

This just doesn't make any sense to answer. Most of those points have
been discussed in the past and I am not going to waste my time on them
again.

> > So let's move on and try to think outside of the box:
> > ---
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index df8778e72211..027d5bc1e874 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -513,6 +513,7 @@ static inline int get_dumpable(struct mm_struct *mm)
> >  #define MMF_HAS_UPROBES		19	/* has uprobes */
> >  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
> >  #define MMF_OOM_REAPED		21	/* mm has been already reaped */
> > +#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
> >  
> >  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
> >  
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index c0e37dd1422f..b1a1e3317231 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -538,8 +538,27 @@ static void oom_reap_task(struct task_struct *tsk)
> >  		schedule_timeout_idle(HZ/10);
> >  
> >  	if (attempts > MAX_OOM_REAP_RETRIES) {
> > +		struct task_struct *p;
> > +
> >  		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> >  				task_pid_nr(tsk), tsk->comm);
> > +
> > +		/*
> > +		 * If we've already tried to reap this task in the past and
> > +		 * failed it probably doesn't make much sense to try yet again
> > +		 * so hide the mm from the oom killer so that it can move on
> > +		 * to another task with a different mm struct.
> > +		 */
> > +		p = find_lock_task_mm(tsk);
> > +		if (p) {
> > +			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
> > +				pr_info("oom_reaper: giving up pid:%d (%s)\n",
> > +						task_pid_nr(tsk), tsk->comm);
> > +				set_bit(MMF_OOM_REAPED, &p->mm->flags);
> > +			}
> > +			task_unlock(p);
> > +		}
> > +
> >  		debug_show_all_locks();
> >  	}
> >  
> > 
> > See the difference? This is 11LOC and we do not have export any knobs
> > which would tie us for future implementations. We will cap the number
> > of times each mm struct is attempted for OOM killer and do not have
> > to touch any subtle oom killer paths so the patch would be quite easy
> > to review. We can change this implementation if it turns out to be
> > impractical, too optimistic or pesimistic.
> 
> Oh, this is a drastic change for you. You are trying to be very conservative
> and you refused to select next OOM victim unless progress are made.

Right. And, unlike with previous attempts, this approach would be
justifiable because it is based on an actual feedback. We know why the
oom killer/reaper cannot make any progress so let's kill something
else. We know that all of our efforts have failed and we know why! So we
can actually make an educated decision. This is a huge difference to
any timeout based decision.

> If you can accept selecting next OOM victim when progress are not made,
> I might be able to get away from timeout based approach.

OK, so let's focus on being productive, reasonable and make educated
decisions ideally in small and understandable steps. If you absolutely
want to have a guaranteed hand break user tunable then I have told you
what is my requirement for its semantic in order to support you in that.

I am skipping your further points, sorry about that, but I have more
important tasks on my todo list than end up in an endless discussion
again.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
