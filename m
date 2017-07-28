Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4556B0557
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 10:07:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v102so38734471wrb.2
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 07:07:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 204si3550915wmw.252.2017.07.28.07.07.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 07:07:08 -0700 (PDT)
Date: Fri, 28 Jul 2017 16:07:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170728140706.GT2274@dhcp22.suse.cz>
References: <20170728123235.GN2274@dhcp22.suse.cz>
 <46e1e3ee-af9a-4e67-8b4b-5cf21478ad21@I-love.SAKURA.ne.jp>
 <20170728130723.GP2274@dhcp22.suse.cz>
 <201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
 <20170728132952.GQ2274@dhcp22.suse.cz>
 <201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 28-07-17 22:55:51, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 28-07-17 22:15:01, Tetsuo Handa wrote:
> > > task_will_free_mem(current) in out_of_memory() returning false due to
> > > MMF_OOM_SKIP already set allowed each thread sharing that mm to select a new
> > > OOM victim. If task_will_free_mem(current) in out_of_memory() did not return
> > > false, threads sharing MMF_OOM_SKIP mm would not have selected new victims
> > > to the level where all OOM killable processes are killed and calls panic().
> > 
> > I am not sure I understand. Do you mean this?
> 
> Yes.
> 
> > ---
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 9e8b4f030c1c..671e4a4107d0 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -779,13 +779,6 @@ static bool task_will_free_mem(struct task_struct *task)
> >  	if (!__task_will_free_mem(task))
> >  		return false;
> >  
> > -	/*
> > -	 * This task has already been drained by the oom reaper so there are
> > -	 * only small chances it will free some more
> > -	 */
> > -	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> > -		return false;
> > -
> >  	if (atomic_read(&mm->mm_users) <= 1)
> >  		return true;
> >  
> > If yes I would have to think about this some more because that might
> > have weird side effects (e.g. oom_victims counting after threads passed
> > exit_oom_victim).
> 
> But this check should not be removed unconditionally. We should still return
> false if returning true was not sufficient to solve the OOM situation, for
> we need to select next OOM victim in that case.
> 
> > 
> > Anyway the proper fix for this is to allow reaping mlocked pages.
> 
> Different approach is to set TIF_MEMDIE to all threads sharing the same
> memory so that threads sharing MMF_OOM_SKIP mm do not need to call
> out_of_memory() in order to get TIF_MEMDIE. 

This is not so simple. If it were we could simply remove TIF_MEMDIE
altogether and rely on tsk_is_oom_victim.

> Yet another apporach is to use __GFP_KILLABLE (we can start it as
> best effort basis).
> 
> >                                                                   Is
> > something other than the LTP test affected to give this more priority?
> > Do we have other usecases where something mlocks the whole memory?
> 
> This panic was caused by 50 threads sharing MMF_OOM_SKIP mm exceeding
> number of OOM killable processes. Whether memory is locked or not isn't
> important.

You are wrong here I believe. The whole problem is that the OOM victim
is consuming basically all the memory (that is what the test case
actually does IIRC) and that memory is mlocked. oom_reaper is much
faster to evaluate the mm of the victim and bail out sooner than the
exit path actually manages to tear down the address space. And so we
have to find other oom victims until we simply kill everything and
panic.

> If a multi-threaded process which consumes little memory was
> selected as an OOM victim (and reaped by the OOM reaper and MMF_OOM_SKIP
> was set immediately), it might be still possible to select next OOM victims
> needlessly.

This would be true if the address space itself only contained a little
amount of memory and the large part of the memory was in page tables or
other resources which oom_reaper cannot work with. This is not a usual
case though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
