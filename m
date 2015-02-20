Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E0A456B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 07:38:59 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id em10so2668767wid.1
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 04:38:59 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ha8si2501708wib.44.2015.02.20.04.38.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 04:38:58 -0800 (PST)
Date: Fri, 20 Feb 2015 13:38:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150220123855.GG21248@dhcp22.suse.cz>
References: <20150218121602.GC4478@dhcp22.suse.cz>
 <20150219110124.GC15569@phnom.home.cmpxchg.org>
 <20150219122914.GH28427@dhcp22.suse.cz>
 <201502192229.FCJ73987.MFQLOHSJFFtOOV@I-love.SAKURA.ne.jp>
 <20150220091001.GC21248@dhcp22.suse.cz>
 <201502202120.GHE87026.OFSHLFFOJMVtOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502202120.GHE87026.OFSHLFFOJMVtOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

On Fri 20-02-15 21:20:58, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 19-02-15 22:29:37, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Thu 19-02-15 06:01:24, Johannes Weiner wrote:
> > > > [...]
> > > > > Preferrably, we'd get rid of all nofail allocations and replace them
> > > > > with preallocated reserves.  But this is not going to happen anytime
> > > > > soon, so what other option do we have than resolving this on the OOM
> > > > > killer side?
> > > > 
> > > > As I've mentioned in other email, we might give GFP_NOFAIL allocator
> > > > access to memory reserves (by giving it __GFP_HIGH). This is still not a
> > > > 100% solution because reserves could get depleted but this risk is there
> > > > even with multiple oom victims. I would still argue that this would be a
> > > > better approach because selecting more victims might hit pathological
> > > > case more easily (other victims might be blocked on the very same lock
> > > > e.g.).
> > > > 
> > > Does "multiple OOM victims" mean "select next if first does not die"?
> > > Then, I think my timeout patch http://marc.info/?l=linux-mm&m=142002495532320&w=2
> > > does not deplete memory reserves. ;-)
> > 
> > It doesn't because
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2603,9 +2603,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> >  		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
> >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > -		else if (!in_interrupt() &&
> > -				((current->flags & PF_MEMALLOC) ||
> > -				 unlikely(test_thread_flag(TIF_MEMDIE))))
> > +		else if (!in_interrupt() && (current->flags & PF_MEMALLOC))
> >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > 
> > you disabled the TIF_MEMDIE heuristic and use it only for OOM exclusion
> > and break out from the allocator. Exiting task might need a memory to do
> > so and you make all those allocations fail basically. How do you know
> > this is not going to blow up?
> > 
> 
> Well, treat exiting tasks to imply __GFP_NOFAIL for clean up?
> 
> We cannot determine correct task to kill + allow access to memory reserves
> based on lock dependency. Therefore, this patch evenly allow no tasks to
> access to memory reserves.
> 
> Exiting task might need some memory to exit, and not allowing access to
> memory reserves can retard exit of that task. But that task will eventually
> get memory released by other tasks killed by timeout-based kill-more
> mechanism. If no more killable tasks or expired panic-timeout, it is
> the same result with depletion of memory reserves.
> 
> I think that this situation (automatically making forward progress as if
> the administrator is periodically doing SysRq-f until the OOM condition
> is solved, or is doing SysRq-c if no more killable tasks or stalled too
> long) is better than current situation (not making forward progress since
> the exiting task cannot exit due to lock dependency, caused by failing to
> determine correct task to kill + allow access to memory reserves).

If you really believe this is an improvement then send a proper patch
with justification. But I am _really_ skeptical about such a change to
be honest.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
