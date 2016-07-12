Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECE616B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:01:40 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id u25so36730624ioi.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:01:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o37si1594729otc.168.2016.07.12.07.01.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 07:01:40 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607080104.JDA41505.OtOFMSLOQVJFHF@I-love.SAKURA.ne.jp>
	<20160711131618.GG1811@dhcp22.suse.cz>
	<201607122238.HJI78681.QOHVSMFtFJOOFL@I-love.SAKURA.ne.jp>
	<20160712134657.GJ14586@dhcp22.suse.cz>
	<20160712135506.GK14586@dhcp22.suse.cz>
In-Reply-To: <20160712135506.GK14586@dhcp22.suse.cz>
Message-Id: <201607122301.FFD43735.SOVOFFMHLQFJtO@I-love.SAKURA.ne.jp>
Date: Tue, 12 Jul 2016 23:01:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Tue 12-07-16 15:46:57, Michal Hocko wrote:
> > On Tue 12-07-16 22:38:42, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > >  #define MAX_OOM_REAP_RETRIES 10
> > > > > -static void oom_reap_task(struct task_struct *tsk)
> > > > > +static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
> > > > >  {
> > > > >  	int attempts = 0;
> > > > > -	struct mm_struct *mm = NULL;
> > > > > -	struct task_struct *p = find_lock_task_mm(tsk);
> > > > >  
> > > > >  	/*
> > > > > -	 * Make sure we find the associated mm_struct even when the particular
> > > > > -	 * thread has already terminated and cleared its mm.
> > > > > -	 * We might have race with exit path so consider our work done if there
> > > > > -	 * is no mm.
> > > > > +	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
> > > > > +	 * pinned.
> > > > >  	 */
> > > > > -	if (!p)
> > > > > -		goto done;
> > > > > -	mm = p->mm;
> > > > > -	atomic_inc(&mm->mm_count);
> > > > > -	task_unlock(p);
> > > > > +	if (test_bit(MMF_OOM_REAPED, &mm->flags))
> > > > > +		return;
> > > > >  
> > > > >  	/* Retry the down_read_trylock(mmap_sem) a few times */
> > > > >  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
> > > > >  		schedule_timeout_idle(HZ/10);
> > > > >  
> > > > >  	if (attempts <= MAX_OOM_REAP_RETRIES)
> > > > > -		goto done;
> > > > > +		return;
> > > > >  
> > > > >  	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
> > > > >  	set_bit(MMF_OOM_REAPED, &mm->flags);
> > > > 
> > > > This seems unnecessary when oom_reaper always calls exit_oom_mm. The
> > > > same applies to __oom_reap_task. Which then means that the flag is
> > > > turning into a misnomer. MMF_SKIP_OOM would fit better its current
> > > > meaning.
> > > 
> > > Large oom_score_adj value or being a child process of highest OOM score
> > > might cause the same mm being selected again. I think these set_bit() are
> > > necessary in order to avoid the same mm being selected again.
> > 
> > I do not understand. Child will have a different mm struct from the
> > parent and I do not see how oom_score_adj is relevant here. Could you
> > elaborate, please?
> 
> OK, I guess I got your point. You mean we can select the same child/task
> again after it has passed its exit_oom_mm. Trying to oom_reap such a
> task would be obviously pointless. Then it would be better to stich that
> set_bit into exit_oom_mm. Renaming it would be also better in that
> context.
> 

Right.

oom_kill_process() receives a task which oom_badness() returned highest
score. But list_for_each_entry(child, &t->children, sibling) selects a
child process if that task has any OOM killable child process. The OOM
killer will kill that child process and the OOM reaper reaps memory from
that child process. But if the OOM reaper does not set MMF_OOM_REAPED after
reaping that child's memory, next round of the OOM killer will select that
child process again. It is possible that the child process was consuming
too little memory to solve the OOM situation.

Even if that task does not have any OOM killable child process, it is
possible that that task was consuming too little memory to solve the OOM
situation. We can misguide the OOM killer to select such process by
setting oom_score_adj to 1000.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
