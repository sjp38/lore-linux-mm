Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22DD86B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 08:13:20 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n18so3155945wra.11
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 05:13:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si2804013wrb.209.2017.06.15.05.13.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 05:13:18 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:13:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <20170615121315.GK1486@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
 <20170615103909.GG1486@dhcp22.suse.cz>
 <201706151953.HFH78657.tFFLOOOQHSMVFJ@I-love.SAKURA.ne.jp>
 <20170615110119.GI1486@dhcp22.suse.cz>
 <201706152032.BFE21313.MSHQOtLVFFJOOF@I-love.SAKURA.ne.jp>
 <20170615120335.GJ1486@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615120335.GJ1486@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-06-17 14:03:35, Michal Hocko wrote:
> On Thu 15-06-17 20:32:39, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > An alternative would be to allow reaping and exit_mmap race. The unmap
> > > part should just work I guess. We just have to be careful to not race
> > > with free_pgtables and that shouldn't be too hard to implement (e.g.
> > > (ab)use mmap_sem for write there). I haven't thought that through
> > > completely though so I might miss something of course.
> > 
> > I think below one is simpler.
> [...]
> > @@ -556,25 +553,21 @@ static void oom_reap_task(struct task_struct *tsk)
> >  	struct mm_struct *mm = tsk->signal->oom_mm;
> >  
> >  	/* Retry the down_read_trylock(mmap_sem) a few times */
> > -	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
> > +	while (__oom_reap_task_mm(tsk, mm), !test_bit(MMF_OOM_SKIP, &mm->flags)
> > +	       && attempts++ < MAX_OOM_REAP_RETRIES)
> >  		schedule_timeout_idle(HZ/10);
> >  
> > -	if (attempts <= MAX_OOM_REAP_RETRIES)
> > -		goto done;
> > -
> > -
> > -	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> > -		task_pid_nr(tsk), tsk->comm);
> > -	debug_show_all_locks();
> > -
> > -done:
> > -	tsk->oom_reaper_list = NULL;
> > -
> >  	/*
> >  	 * Hide this mm from OOM killer because it has been either reaped or
> >  	 * somebody can't call up_write(mmap_sem).
> >  	 */
> > -	set_bit(MMF_OOM_SKIP, &mm->flags);
> > +	if (!test_and_set_bit(MMF_OOM_SKIP, &mm->flags)) {
> > +		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> > +			task_pid_nr(tsk), tsk->comm);
> > +		debug_show_all_locks();
> > +	}
> > +
> 
> How does this _solve_ anything? Why would you even retry when you
> _know_ that the reference count dropped to zero. It will never
> increment. So the above is basically just schedule_timeout_idle(HZ/10) *
> MAX_OOM_REAP_RETRIES before we set MMF_OOM_SKIP.

Just to make myself more clear. The above assumes that the victim hasn't
passed exit_mmap and MMF_OOM_SKIP in __mmput. Which is the case we want to
address here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
