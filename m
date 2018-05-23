Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 664CB6B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:56:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r2-v6so1178793wrm.15
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:56:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q44-v6si4080469edq.344.2018.05.23.07.56.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 07:56:44 -0700 (PDT)
Date: Wed, 23 May 2018 16:56:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180523145639.GT20441@dhcp22.suse.cz>
References: <20180518122045.GG21711@dhcp22.suse.cz>
 <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
 <20180522061850.GB20020@dhcp22.suse.cz>
 <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
 <20180523115726.GP20441@dhcp22.suse.cz>
 <201805232245.IGI00539.HLtMFOQSJFFOOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805232245.IGI00539.HLtMFOQSJFFOOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Wed 23-05-18 22:45:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 23-05-18 19:24:48, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > I don't understand why you are talking about PF_WQ_WORKER case.
> > > > 
> > > > Because that seems to be the reason to have it there as per your
> > > > comment.
> > > 
> > > OK. Then, I will fold below change into my patch.
> > > 
> > >         if (did_some_progress) {
> > >                 no_progress_loops = 0;
> > >  +              /*
> > > -+               * This schedule_timeout_*() serves as a guaranteed sleep for
> > > -+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > > ++               * Try to give the OOM killer/reaper/victims some time for
> > > ++               * releasing memory.
> > >  +               */
> > >  +              if (!tsk_is_oom_victim(current))
> > >  +                      schedule_timeout_uninterruptible(1);
> > 
> > Do you really need this? You are still fiddling with this path at all? I
> > see how removing the timeout might be reasonable after recent changes
> > but why do you insist in adding it outside of the lock.
> 
> Sigh... We can't remove this sleep without further changes. That's why I added
> 
>  * This schedule_timeout_*() serves as a guaranteed sleep for
>  * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> 
> so that we won't by error remove this sleep without further changes.

Look. I am fed up with this discussion. You are fiddling with the code
and moving hacks around with a lot of hand waving. Rahter than trying to
look at the underlying problem. Your patch completely ignores PREEMPT as
I've mentioned in previous versions.

I do admit that the underlying problem is non-trivial to handle and it
requires a deeper consideration. Fair enough. You can spend that time on
the matter and come up with something clever. That would be great. But
moving a sleep around because of some yada yada yada is not a way we
want to treat this code.

I would be OK with removing the sleep from the out_of_memory path based
on your argumentation that we have a _proper_ synchronization with the
exit path now. That would be a patch that has actually a solid
background behind. Is it possible that something would wait longer or
wouldn't preempt etc.? Yes possible but those need to be analyzed and
thing through properly. See the difference from "we may need it because
we've always been doing that and there is here and there that might
happen". This cargo cult way of programming will only grow more and more
hacks nobody can reason about long term.
-- 
Michal Hocko
SUSE Labs
