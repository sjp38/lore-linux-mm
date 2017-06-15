Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 204D56B02B4
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:43:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u127so21803101itg.11
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:43:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p134si406396iod.36.2017.06.15.14.43.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 14:43:51 -0700 (PDT)
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is freed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201706152032.BFE21313.MSHQOtLVFFJOOF@I-love.SAKURA.ne.jp>
	<20170615120335.GJ1486@dhcp22.suse.cz>
	<20170615121315.GK1486@dhcp22.suse.cz>
	<201706152201.CAB48456.FtHOJMFOVLSFQO@I-love.SAKURA.ne.jp>
	<20170615132203.GM1486@dhcp22.suse.cz>
In-Reply-To: <20170615132203.GM1486@dhcp22.suse.cz>
Message-Id: <201706160643.CAB86439.JOMFOtOQVFFLHS@I-love.SAKURA.ne.jp>
Date: Fri, 16 Jun 2017 06:43:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 15-06-17 22:01:33, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Thu 15-06-17 14:03:35, Michal Hocko wrote:
> > > > On Thu 15-06-17 20:32:39, Tetsuo Handa wrote:
> > > > > @@ -556,25 +553,21 @@ static void oom_reap_task(struct task_struct *tsk)
> > > > >  	struct mm_struct *mm = tsk->signal->oom_mm;
> > > > >  
> > > > >  	/* Retry the down_read_trylock(mmap_sem) a few times */
> > > > > -	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
> > > > > +	while (__oom_reap_task_mm(tsk, mm), !test_bit(MMF_OOM_SKIP, &mm->flags)
> > > > > +	       && attempts++ < MAX_OOM_REAP_RETRIES)
> > > > >  		schedule_timeout_idle(HZ/10);
> > > > >  
> > > > > -	if (attempts <= MAX_OOM_REAP_RETRIES)
> > > > > -		goto done;
> > > > > -
> > > > > -
> > > > > -	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> > > > > -		task_pid_nr(tsk), tsk->comm);
> > > > > -	debug_show_all_locks();
> > > > > -
> > > > > -done:
> > > > > -	tsk->oom_reaper_list = NULL;
> > > > > -
> > > > >  	/*
> > > > >  	 * Hide this mm from OOM killer because it has been either reaped or
> > > > >  	 * somebody can't call up_write(mmap_sem).
> > > > >  	 */
> > > > > -	set_bit(MMF_OOM_SKIP, &mm->flags);
> > > > > +	if (!test_and_set_bit(MMF_OOM_SKIP, &mm->flags)) {
> > > > > +		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> > > > > +			task_pid_nr(tsk), tsk->comm);
> > > > > +		debug_show_all_locks();
> > > > > +	}
> > > > > +
> > > > 
> > > > How does this _solve_ anything? Why would you even retry when you
> > > > _know_ that the reference count dropped to zero. It will never
> > > > increment. So the above is basically just schedule_timeout_idle(HZ/10) *
> > > > MAX_OOM_REAP_RETRIES before we set MMF_OOM_SKIP.
> > 
> > If the OOM reaper knows that mm->users == 0, it gives __mmput() some time
> > to "complete exit_mmap() etc. and set MMF_OOM_SKIP". If __mmput() released
> > some memory, subsequent OOM killer invocation is automatically avoided.
> > If __mmput() did not release some memory, let the OOM killer invoke again.
> > 
> > > 
> > > Just to make myself more clear. The above assumes that the victim hasn't
> > > passed exit_mmap and MMF_OOM_SKIP in __mmput. Which is the case we want to
> > > address here.
> > 
> > David is trying to avoid setting MMF_OOM_SKIP when the OOM reaper found that
> > mm->users == 0. But we must not wait forever because __mmput() might fail to
> > release some memory immediately. If __mmput() did not release some memory within
> > schedule_timeout_idle(HZ/10) * MAX_OOM_REAP_RETRIES sleep, let the OOM killer
> > invoke again. So, this is the case we want to address here, isn't it?
> 
> And we are back with a timeout based approach... Sigh. Just imagine that
> you have a really large process which will take some time to tear down.
> While it frees memory that might be in a different oom domain. Now you
> pretend to keep retrying and eventually give up to allow a new oom
> victim from that oom domain.

We are already using timeout based approach at down_read_trylock(&mm->mmap_sem)
in __oom_reap_task_mm(). It is possible that down_read_trylock(&mm->mmap_sem)
succeeds if the OOM reaper waited for one more second, for the thread which is
holding mmap_sem for write could just be failing to get TIF_MEMDIE due to
oom_lock contention among unrelated threads, but we allow the OOM reaper to
give up after one second.

Even if the victim is a really large process which will take some time to tear
down """inside __mmput()""", subsequent OOM killer invocation will be _automatically
avoided_ if __mmput() released _some_ memory. Thus, giving up __mmput() after one
second as well as giving up down_read_trylock(&mm->mmap_sem) after one second is
reasonable.

> 
> If we want to handle oom victims with mm_users == 0 then let's do it
> properly, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
