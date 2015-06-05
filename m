Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B83D7900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 10:35:37 -0400 (EDT)
Received: by wiam3 with SMTP id m3so21378298wia.1
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 07:35:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si13673474wjx.75.2015.06.05.07.35.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Jun 2015 07:35:36 -0700 (PDT)
Date: Fri, 5 Jun 2015 16:35:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150605143534.GD26113@dhcp22.suse.cz>
References: <20150603031544.GC7579@mtj.duckdns.org>
 <20150603144414.GG16201@dhcp22.suse.cz>
 <20150603193639.GH20091@mtj.duckdns.org>
 <20150604093031.GB4806@dhcp22.suse.cz>
 <20150604192936.GR20091@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604192936.GR20091@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri 05-06-15 04:29:36, Tejun Heo wrote:
> Hello, Michal.
> 
> On Thu, Jun 04, 2015 at 11:30:31AM +0200, Michal Hocko wrote:
> > > Hmmm?  In -mm, if __alloc_page_may_oom() fails trylock, it never calls
> > > out_of_memory().
> > 
> > Sure but the oom_lock might be free already. out_of_memory doesn't wait
> > for the victim to finish. It just does schedule_timeout_killable.
> 
> That doesn't matter because the detection and TIF_MEMDIE assertion are
> atomic w.r.t. oom_lock and TIF_MEMDIE essentially extends the locking
> by preventing further OOM kills.  Am I missing something?

This is true but TIF_MEMDIE releasing is not atomic wrt. the allocation
path. So the oom victim could have released memory and dropped
TIF_MEMDIE but the allocation path hasn't noticed that because it's passed
        /*
         * Go through the zonelist yet one more time, keep very high watermark
         * here, this is only to catch a parallel oom killing, we must fail if
         * we're still under heavy pressure.
         */
        page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
                                        ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);

and goes on to kill another task because there is no TIF_MEMDIE
anymore.
 
> > > The main difference here is that the alloc path does the whole thing
> > > synchrnously and thus the OOM detection and killing can be put in the
> > > same critical section which isn't the case for the memcg OOM handling.
> > 
> > This is true but there is still a time window between the last
> > allocation attempt and out_of_memory when the OOM victim might have
> > exited and another task would be selected.
> 
> Please see above.
> 
> > > > This is not the only reason. In-kernel memcg oom handling needs it
> > > > as well. See 3812c8c8f395 ("mm: memcg: do not trap chargers with
> > > > full callstack on OOM"). In fact it was the in-kernel case which has
> > > > triggered this change. We simply cannot wait for oom with the stack and
> > > > all the state the charge is called from.
> > > 
> > > Why should this be any different from OOM handling from page allocator
> > > tho? 
> > 
> > Yes the global OOM is prone to deadlock. This has been discussed a lot
> > and we still do not have a good answer for that. The primary problem
> > is that small allocations do not fail and retry indefinitely so an OOM
> > victim might be blocked on a lock held by a task which is the allocator.
> > This is less likely and harder to trigger with standard loads than in
> > memcg environment though.
> 
> Deadlocks from infallible allocations getting interlocked are
> different.  OOM killer can't really get around that by itself but I'm
> not talking about those deadlocks but at the same time they're a lot
> less likely.  It's about OOM victim trapped in a deadlock failing to
> release memory because someone else is waiting for that memory to be
> released while blocking the victim. 

I thought those would be in the allocator context - which was the
example I've provided. What kind of context do you have in mind?

> Sure, the two issues are related
> but once you solve things getting blocked on single OOM victim, it
> becomes a lot less of an issue.
> 
> > There have been suggestions to add an OOM timeout and ignore the
> > previous OOM victim after the timeout expires and select a new
> > victim. This sounds attractive but this approach has its own problems
> > (http://marc.info/?l=linux-mm&m=141686814824684&w=2).
> 
> Here are the the issues the message lists

Let's focus on discussing those points in reply to Johannes' email. AFAIU
your notes very in line with his.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
