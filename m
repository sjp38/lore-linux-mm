Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 900F46B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:38:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u186so34775639ita.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:38:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j123si2185219ioe.157.2016.07.12.06.38.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:38:50 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
	<201607080104.JDA41505.OtOFMSLOQVJFHF@I-love.SAKURA.ne.jp>
	<20160711131618.GG1811@dhcp22.suse.cz>
In-Reply-To: <20160711131618.GG1811@dhcp22.suse.cz>
Message-Id: <201607122238.HJI78681.QOHVSMFtFJOOFL@I-love.SAKURA.ne.jp>
Date: Tue, 12 Jul 2016 22:38:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> >  #define MAX_OOM_REAP_RETRIES 10
> > -static void oom_reap_task(struct task_struct *tsk)
> > +static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
> >  {
> >  	int attempts = 0;
> > -	struct mm_struct *mm = NULL;
> > -	struct task_struct *p = find_lock_task_mm(tsk);
> >  
> >  	/*
> > -	 * Make sure we find the associated mm_struct even when the particular
> > -	 * thread has already terminated and cleared its mm.
> > -	 * We might have race with exit path so consider our work done if there
> > -	 * is no mm.
> > +	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
> > +	 * pinned.
> >  	 */
> > -	if (!p)
> > -		goto done;
> > -	mm = p->mm;
> > -	atomic_inc(&mm->mm_count);
> > -	task_unlock(p);
> > +	if (test_bit(MMF_OOM_REAPED, &mm->flags))
> > +		return;
> >  
> >  	/* Retry the down_read_trylock(mmap_sem) a few times */
> >  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
> >  		schedule_timeout_idle(HZ/10);
> >  
> >  	if (attempts <= MAX_OOM_REAP_RETRIES)
> > -		goto done;
> > +		return;
> >  
> >  	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
> >  	set_bit(MMF_OOM_REAPED, &mm->flags);
> 
> This seems unnecessary when oom_reaper always calls exit_oom_mm. The
> same applies to __oom_reap_task. Which then means that the flag is
> turning into a misnomer. MMF_SKIP_OOM would fit better its current
> meaning.

Large oom_score_adj value or being a child process of highest OOM score
might cause the same mm being selected again. I think these set_bit() are
necessary in order to avoid the same mm being selected again.

Other than that, I sent v3 patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
