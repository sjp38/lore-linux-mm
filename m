Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A71B76B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:47:00 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so11905527lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:47:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 202si3391476wmt.105.2016.07.12.06.46.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:46:59 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:46:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
Message-ID: <20160712134657.GJ14586@dhcp22.suse.cz>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
 <201607080104.JDA41505.OtOFMSLOQVJFHF@I-love.SAKURA.ne.jp>
 <20160711131618.GG1811@dhcp22.suse.cz>
 <201607122238.HJI78681.QOHVSMFtFJOOFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607122238.HJI78681.QOHVSMFtFJOOFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 12-07-16 22:38:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > >  #define MAX_OOM_REAP_RETRIES 10
> > > -static void oom_reap_task(struct task_struct *tsk)
> > > +static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
> > >  {
> > >  	int attempts = 0;
> > > -	struct mm_struct *mm = NULL;
> > > -	struct task_struct *p = find_lock_task_mm(tsk);
> > >  
> > >  	/*
> > > -	 * Make sure we find the associated mm_struct even when the particular
> > > -	 * thread has already terminated and cleared its mm.
> > > -	 * We might have race with exit path so consider our work done if there
> > > -	 * is no mm.
> > > +	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
> > > +	 * pinned.
> > >  	 */
> > > -	if (!p)
> > > -		goto done;
> > > -	mm = p->mm;
> > > -	atomic_inc(&mm->mm_count);
> > > -	task_unlock(p);
> > > +	if (test_bit(MMF_OOM_REAPED, &mm->flags))
> > > +		return;
> > >  
> > >  	/* Retry the down_read_trylock(mmap_sem) a few times */
> > >  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
> > >  		schedule_timeout_idle(HZ/10);
> > >  
> > >  	if (attempts <= MAX_OOM_REAP_RETRIES)
> > > -		goto done;
> > > +		return;
> > >  
> > >  	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
> > >  	set_bit(MMF_OOM_REAPED, &mm->flags);
> > 
> > This seems unnecessary when oom_reaper always calls exit_oom_mm. The
> > same applies to __oom_reap_task. Which then means that the flag is
> > turning into a misnomer. MMF_SKIP_OOM would fit better its current
> > meaning.
> 
> Large oom_score_adj value or being a child process of highest OOM score
> might cause the same mm being selected again. I think these set_bit() are
> necessary in order to avoid the same mm being selected again.

I do not understand. Child will have a different mm struct from the
parent and I do not see how oom_score_adj is relevant here. Could you
elaborate, please?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
