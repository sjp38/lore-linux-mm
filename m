Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 018586B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 11:05:38 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so4560647lbb.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 08:05:37 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id u187si16145756wmb.54.2016.06.07.08.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 08:05:36 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r5so6765729wmr.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 08:05:36 -0700 (PDT)
Date: Tue, 7 Jun 2016 17:05:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
Message-ID: <20160607150534.GO12305@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
 <20160603122030.GG20676@dhcp22.suse.cz>
 <201606040017.HDI52680.LFFOVMJQOFSOHt@I-love.SAKURA.ne.jp>
 <20160606083651.GE11895@dhcp22.suse.cz>
 <201606072330.AHH81886.OOMVHFOFLtFSQJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606072330.AHH81886.OOMVHFOFLtFSQJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 07-06-16 23:30:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > To be honest, I don't think we need to apply this pile.
> > 
> > So you do not think that the current pile is making the code easier to
> > understand and more robust as well as the semantic more consistent?
> 
> Right. It is getting too complicated for me to understand.

Yeah, this code is indeed very complicated with subtle side effects. I
believe there are much less side effects with these patches applied.
I might be biased of course and that is for others to judge.

> Below patch on top of 4.7-rc2 will do the job and can do for
> CONFIG_MMU=n kernels as well.
[...]
> @@ -179,7 +184,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	 * unkillable or have been already oom reaped.
>  	 */
>  	adj = (long)p->signal->oom_score_adj;
> -	if (adj == OOM_SCORE_ADJ_MIN ||
> +	if (adj == OOM_SCORE_ADJ_MIN || p->signal->oom_killed ||
>  			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
>  		task_unlock(p);
>  		return 0;
[...]
> @@ -284,7 +289,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
>  	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
> -		return OOM_SCAN_ABORT;
> +		return timer_pending(&oomkiller_victim_wait_timer) ?
> +			OOM_SCAN_ABORT : OOM_SCAN_CONTINUE;
>  
>  	/*
>  	 * If task is allocating a lot of memory and has been marked to be
> @@ -678,6 +684,8 @@ void mark_oom_victim(struct task_struct *tsk)
>  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
>  		return;
>  	atomic_inc(&tsk->signal->oom_victims);
> +	mod_timer(&oomkiller_victim_wait_timer, jiffies + 3 * HZ);
> +	tsk->signal->oom_killed = true;
>  	/*
>  	 * Make sure that the task is woken up from uninterruptible sleep
>  	 * if it is frozen because OOM killer wouldn't be able to free

OK, so you are arming the timer for each mark_oom_victim regardless
of the oom context. This means that you have replaced one potential
lockup by other potential livelocks. Tasks from different oom domains
might interfere here...

Also this code doesn't even seem easier. It is surely less lines of
code but it is really hard to realize how would the timer behave for
different oom contexts.

> > > What is missing for
> > > handling subtle and unlikely issues is "eligibility check for not to select
> > > the same victim forever" (i.e. always set MMF_OOM_REAPED or OOM_SCORE_ADJ_MIN,
> > > and check them before exercising the shortcuts).
> > 
> > Which is a hard problem as we do not have enough context for that. Most
> > situations are covered now because we are much less optimistic when
> > bypassing the oom killer and basically most sane situations are oom
> > reapable.
> 
> What is wrong with above patch? How much difference is there compared to
> calling schedule_timeout_killable(HZ) in oom_kill_process() before
> releasing oom_lock and later checking MMF_OOM_REAPED after re-taking
> oom_lock when we can't wake up the OOM reaper?

I fail to see how much this is different, really. Your patch is checking
timer_pending with a global context in the same path and that is imho
much harder to argue about than something which is task->mm based.
 
> > > Current 4.7-rc1 code will be sufficient (and sometimes even better than
> > > involving user visible changes / selecting next OOM victim without delay)
> > > if we started with "decision by timer" (e.g.
> > > http://lkml.kernel.org/r/201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp )
> > > approach.
> > > 
> > > As long as you insist on "decision by feedback from the OOM reaper",
> > > we have to guarantee that the OOM reaper is always invoked in order to
> > > handle subtle and unlikely cases.
> > 
> > And I still believe that a decision based by a feedback is a better
> > solution than a timeout. So I am pretty much for exploring that way
> > until we really find out we cannot really go forward any longer.
> 
> I'm OK with "a decision based by a feedback" but you don't like waking up
> the OOM reaper ("invoking the oom reaper just to find out what we know
> already and it is unlikely to change after oom_kill_process just doesn't
> make much sense."). So what feedback mechanisms are possible other than
> timeout like above patch?

Is this about the patch 10? Well, yes, there is a case where oom reaper
cannot be invoked and we have no feedback. Then we have no other way
than to wait for some time. I believe it is easier to wait in the oom
context directly than to add a global timer. Both approaches would need
some code in the oom victim selection code and it is much easier to
argue about the victim specific context than a global one as mentioned
above.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
