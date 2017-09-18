Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 327996B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:05:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so16048095pgn.7
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:05:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6si4341791plo.427.2017.09.17.23.05.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:05:40 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:05:24 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
Message-ID: <20170918060524.sut26yl65j2cf3jk@dhcp22.suse.cz>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
 <20170915143732.GA8397@cmpxchg.org>
 <201709160023.CAE05229.MQHFSJFOOFOVtL@I-love.SAKURA.ne.jp>
 <20170915184449.GA9859@cmpxchg.org>
 <201709160925.GAC18219.FFVOtHJOQFOSLM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709160925.GAC18219.FFVOtHJOQFOSLM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, yuwang668899@gmail.com, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com, akpm@linux-foundation.org

On Sat 16-09-17 09:25:26, Tetsuo Handa wrote:
> Johannes Weiner wrote:
> > On Sat, Sep 16, 2017 at 12:23:53AM +0900, Tetsuo Handa wrote:
> > > Johannes Weiner wrote:
> > > > How can we figure out if there is a bug here? Can we time the calls to
> > > > __alloc_pages_direct_reclaim() and __alloc_pages_direct_compact() and
> > > > drill down from there? Print out the number of times we have retried?
> > > > We're counting no_progress_loops, but we are also very much interested
> > > > in progress_loops that didn't result in a successful allocation. Too
> > > > many of those and I think we want to OOM kill as per above.
> > > > 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index bec5e96f3b88..01736596389a 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -3830,6 +3830,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  			"page allocation stalls for %ums, order:%u",
> > > >  			jiffies_to_msecs(jiffies-alloc_start), order);
> > > >  		stall_timeout += 10 * HZ;
> > > > +		goto oom;
> > > >  	}
> > > >  
> > > >  	/* Avoid recursion of direct reclaim */
> > > > @@ -3882,6 +3883,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  	if (read_mems_allowed_retry(cpuset_mems_cookie))
> > > >  		goto retry_cpuset;
> > > >  
> > > > +oom:
> > > >  	/* Reclaim has failed us, start killing things */
> > > >  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
> > > >  	if (page)
> > > > 
> > > 
> > > According to my stress tests, it is mutex_trylock() in __alloc_pages_may_oom()
> > > that causes warn_alloc() to be called for so many times. The comment
> > > 
> > > 	/*
> > > 	 * Acquire the oom lock.  If that fails, somebody else is
> > > 	 * making progress for us.
> > > 	 */
> > > 
> > > is true only if the owner of oom_lock can call out_of_memory() and is __GFP_FS
> > > allocation. Consider a situation where there are 1 GFP_KERNEL allocating thread
> > > and 99 GFP_NOFS/GFP_NOIO allocating threads contending the oom_lock. How likely
> > > the OOM killer is invoked? It is very unlikely because GFP_KERNEL allocating thread
> > > likely fails to grab oom_lock because GFP_NOFS/GFP_NOIO allocating threads is
> > > grabing oom_lock. And GFP_KERNEL allocating thread yields CPU time for
> > > GFP_NOFS/GFP_NOIO allocating threads to waste pointlessly.
> > > s/!mutex_trylock(&oom_lock)/mutex_lock_killable()/ significantly improves
> > > this situation for my stress tests. How is your case?
> > 
> > Interesting analysis, that definitely sounds plausible.
> > 
> > It just started happening to us in production and I haven't isolated
> > it yet. If you already have a reproducer, that's excellent.
> 
> Well, my reproducer is an artificial stressor. I think you want to test
> using natural programs used in your production environment.
> 
> > 
> > The synchronization has worked this way for a long time (trylock
> > failure assuming progress, but the order/NOFS/zone bailouts from
> > actually OOM-killing inside the locked section). We should really fix
> > *that* rather than serializing warn_alloc().
> > 
> > For GFP_NOFS, it seems to go back to 9879de7373fc ("mm: page_alloc:
> > embed OOM killing naturally into allocation slowpath"). Before that we
> > didn't use to call __alloc_pages_may_oom() for NOFS allocations. So I
> > still wonder why this only now appears to be causing problems.
> > 
> > In any case, converting that trylock to a sleeping lock in this case
> > makes sense to me. Nobody is blocking under this lock (except that one
> > schedule_timeout_killable(1) after dispatching a victim) and it's not
> > obvious to me why we'd need that level of concurrency under OOM.
> 
> You can try http://lkml.kernel.org/r/1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> and http://lkml.kernel.org/r/1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp together.
> Then, we can remove mutex_lock(&oom_lock) serialization from __oom_reap_task_mm()
> which still exists because Andrea's patch was accepted instead of Michal's patch.

We can safely drop the oom_lock from __oom_reap_task_mm now. Andrea
didn't want to do it in his patch because that is a separate thing
logically. But nothing should prefent the removal now that AFAICS.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
