Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC886B0070
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 03:48:45 -0500 (EST)
Received: by wesw62 with SMTP id w62so3238023wes.12
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 00:48:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id am1si33871468wjc.40.2015.02.18.00.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 00:48:44 -0800 (PST)
Date: Wed, 18 Feb 2015 09:48:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150218084842.GB4478@dhcp22.suse.cz>
References: <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
 <20150216154201.GA27295@phnom.home.cmpxchg.org>
 <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
 <20150217131618.GA14778@phnom.home.cmpxchg.org>
 <20150217165024.GI32017@dhcp22.suse.cz>
 <20150217232552.GK4251@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150217232552.GK4251@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Wed 18-02-15 10:25:52, Dave Chinner wrote:
> On Tue, Feb 17, 2015 at 05:50:24PM +0100, Michal Hocko wrote:
> > On Tue 17-02-15 08:16:18, Johannes Weiner wrote:
> > > On Tue, Feb 17, 2015 at 08:57:05PM +0900, Tetsuo Handa wrote:
> > > > Johannes Weiner wrote:
> > > > > On Mon, Feb 16, 2015 at 08:23:16PM +0900, Tetsuo Handa wrote:
> > > > > >   (2) Implement TIF_MEMDIE timeout.
> > > > > 
> > > > > How about something like this?  This should solve the deadlock problem
> > > > > in the page allocator, but it would also simplify the memcg OOM killer
> > > > > and allow its use by in-kernel faults again.
> > > > 
> > > > Yes, basic idea would be same with
> > > > http://marc.info/?l=linux-mm&m=142002495532320&w=2 .
> > > > 
> > > > But Michal and David do not like the timeout approach.
> > > > http://marc.info/?l=linux-mm&m=141684783713564&w=2
> > > > http://marc.info/?l=linux-mm&m=141686814824684&w=2
> > 
> > Yes I really hate time based solutions for reasons already explained in
> > the referenced links.
> >  
> > > I'm open to suggestions, but we can't just stick our heads in the sand
> > > and pretend that these are just unrelated bugs.  They're not. 
> > 
> > Requesting GFP_NOFAIL allocation with locks held is IMHO a bug and
> > should be fixed.
> 
> That's rather naive.
> 
> Filesystems do demand paging of metadata within transactions, which
> means we are guaranteed to be holding locks when doing memory
> allocation. Indeed, this is what the GFP_NOFS allocation context is
> supposed to convey - we currently *hold locks* and so reclaim needs
> to be careful about recursion. I'll also argue that it means the OOM
> killer cannot kill the process attempting memory allocation for the
> same reason.

I am not sure I understand. Do you mean that OOM killer should attempt
to select a victim which is doing doing GFP_NOFS allocation or an
allocation in general?

> We are also guaranteed to be in a state where memory allocation
> failure *cannot be tolerated* because failure to complete the
> modification leaves the filesystem in a "corrupt in memory" state.
> We don't use GFP_NOFAIL because it's deprecated, but the reality is
> that we need to ensure memory allocation eventually succeeds because
> we *cannot go backwards*.
> 
> The choice is simple: memory allocation fails, we shut down the
> filesystem and guarantee that we DOS the entire machine because the
> filesystems have gone AWOL; or we keep trying memory allocation
> until it succeeds.

Would it be possible to drop the locks and retry the allocations?
Is the context which is doing this transaction a killable context?

> So, memory allocation generally succeeds eventually, so we have
> these loops around kmalloc(), kmem_cache_alloc() and alloc_page()
> that ensure allocation succeeds. Those loops also guarantee we get
> warnings when allocation is repeatedly failing and we might have
> actually hit a OOM deadlock situation.

As pointed in another email this should be done in the page allocator
IMO.

> > Hopelessly looping in the page allocator without GFP_NOFAIL is too risky
> > as well and we should get rid of this.
> 
> Yet the exact situation we need GFP_NOFAIL is the situation that you
> are calling a bug.
> 
> > Why should we still try to loop
> > when previous 1000 attempts failed with OOM killer invocation? Can we
> > simply fail after a configurable number of attempts?
> 
> OTOH, why should the memory allocator care what failure policy the
> callers have?

It is not about failure policy of the caller. It is about how long the
allocator tries before it gives up. A good allocator tries hard but not
too much if the caller is able to handle the failure because it is the
caller who defines the fallback policy.

> > This is prone to
> > reveal unchecked allocation failures but those are bugs as well and we
> > shouldn't pretend otherwise.
> > 
> > > As long
> > > as it's legal to enter the allocator with *anything* that can prevent
> > > another random task in the system from making progress, we have this
> > > deadlock potential.  One side has to give up, and it can't be the page
> > > allocator because it has to support __GFP_NOFAIL allocations, which
> > > are usually exactly the allocations that are buried in hard-to-unwind
> > > state that is likely to trip up exiting OOM victims.
> > 
> > I am not convinced that GFP_NOFAIL is the biggest problem. Most if
> > OOM livelocks I have seen were either due to GFP_KERNEL treated as
> > GFP_NOFAIL or an incorrect gfp mask (e.g. GFP_FS added where not
> > appropriate). I think we should focus on this part before we start
> > adding heuristics into OOM killer.
> 
> Having the OOM killer being able to kill the process that triggered
> it would be a good start.

Not sure I understand. Do you mean sysctl_oom_kill_allocating_task?

> More often than not, that is the process
> that needs killing, and the oom killer implementation currently
> cannot do anything about that process.

Can you elaborate? AFAICS the process which has triggered the OOM is the
easiest to kill victim. It is not blocked on any locks so it just needs
to get outside of the kernel.

> Make the OOM killer only be
> invoked by kswapd or some other independent kernel thread so that it
> is independent of the allocation context that needs to invoke it,
> and have the invoker wait to be told what to do.

Again, I am not sure I understand. The OOM killer doesn't block the
context which has triggered OOM condition. Allocation is retried after
OOM killer invocation and if the current context is the victim the
allocation failure is expedited.

> That way it can kill the invoking process if that's the one that
> needs to be killed, and then all "can't kill processes because the
> invoker holds locks they depend on" go away.

Except that killing the messenger is not the best strategy...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
