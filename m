Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A83AB6B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:55:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so14141602wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:55:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t138si3499646wmd.116.2016.07.12.06.55.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:55:07 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:55:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
Message-ID: <20160712135506.GK14586@dhcp22.suse.cz>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
 <201607080104.JDA41505.OtOFMSLOQVJFHF@I-love.SAKURA.ne.jp>
 <20160711131618.GG1811@dhcp22.suse.cz>
 <201607122238.HJI78681.QOHVSMFtFJOOFL@I-love.SAKURA.ne.jp>
 <20160712134657.GJ14586@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160712134657.GJ14586@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 12-07-16 15:46:57, Michal Hocko wrote:
> On Tue 12-07-16 22:38:42, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > >  #define MAX_OOM_REAP_RETRIES 10
> > > > -static void oom_reap_task(struct task_struct *tsk)
> > > > +static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
> > > >  {
> > > >  	int attempts = 0;
> > > > -	struct mm_struct *mm = NULL;
> > > > -	struct task_struct *p = find_lock_task_mm(tsk);
> > > >  
> > > >  	/*
> > > > -	 * Make sure we find the associated mm_struct even when the particular
> > > > -	 * thread has already terminated and cleared its mm.
> > > > -	 * We might have race with exit path so consider our work done if there
> > > > -	 * is no mm.
> > > > +	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
> > > > +	 * pinned.
> > > >  	 */
> > > > -	if (!p)
> > > > -		goto done;
> > > > -	mm = p->mm;
> > > > -	atomic_inc(&mm->mm_count);
> > > > -	task_unlock(p);
> > > > +	if (test_bit(MMF_OOM_REAPED, &mm->flags))
> > > > +		return;
> > > >  
> > > >  	/* Retry the down_read_trylock(mmap_sem) a few times */
> > > >  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
> > > >  		schedule_timeout_idle(HZ/10);
> > > >  
> > > >  	if (attempts <= MAX_OOM_REAP_RETRIES)
> > > > -		goto done;
> > > > +		return;
> > > >  
> > > >  	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
> > > >  	set_bit(MMF_OOM_REAPED, &mm->flags);
> > > 
> > > This seems unnecessary when oom_reaper always calls exit_oom_mm. The
> > > same applies to __oom_reap_task. Which then means that the flag is
> > > turning into a misnomer. MMF_SKIP_OOM would fit better its current
> > > meaning.
> > 
> > Large oom_score_adj value or being a child process of highest OOM score
> > might cause the same mm being selected again. I think these set_bit() are
> > necessary in order to avoid the same mm being selected again.
> 
> I do not understand. Child will have a different mm struct from the
> parent and I do not see how oom_score_adj is relevant here. Could you
> elaborate, please?

OK, I guess I got your point. You mean we can select the same child/task
again after it has passed its exit_oom_mm. Trying to oom_reap such a
task would be obviously pointless. Then it would be better to stich that
set_bit into exit_oom_mm. Renaming it would be also better in that
context.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
