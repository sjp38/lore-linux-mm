Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1730E6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:23:56 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id d205so20300627oia.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:23:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u60si31680271otb.182.2017.01.04.06.23.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 06:23:54 -0800 (PST)
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170102154858.GC18048@dhcp22.suse.cz>
	<201701031036.IBE51044.QFLFSOHtFOJVMO@I-love.SAKURA.ne.jp>
	<20170103084211.GB30111@dhcp22.suse.cz>
	<201701032338.EFH69294.VOMSHFLOFOtQFJ@I-love.SAKURA.ne.jp>
	<20170103204014.GA13873@dhcp22.suse.cz>
In-Reply-To: <20170103204014.GA13873@dhcp22.suse.cz>
Message-Id: <201701042322.EEG05759.FOMOVLSFJFHOQt@I-love.SAKURA.ne.jp>
Date: Wed, 4 Jan 2017 23:22:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 03-01-17 23:38:30, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 03-01-17 10:36:31, Tetsuo Handa wrote:
> > > [...]
> > > > I'm OK with "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator
> > > > slowpath" given that we describe that we make __GFP_NOFAIL stronger than
> > > > __GFP_NORETRY with this patch in the changelog.
> > > 
> > > Again. __GFP_NORETRY | __GFP_NOFAIL is nonsense! I do not really see any
> > > reason to describe all the nonsense combinations of gfp flags.
> > 
> > Before [PATCH 1/3]:
> > 
> >   __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
> >   request even if __GFP_NOFAIL is specified if direct reclaim/compaction
> >   did not help."
> > 
> >   __GFP_NOFAIL is used as "Never fail allocation request unless __GFP_NORETRY
> >   is specified even if direct reclaim/compaction did not help."
> > 
> > After [PATCH 1/3]:
> > 
> >   __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
> >   request unless __GFP_NOFAIL is specified."
> > 
> >   __GFP_NOFAIL is used as "Never fail allocation request even if direct
> >   reclaim/compaction did not help. Invoke the OOM killer unless __GFP_NORETRY is
> >   specified."
> > 
> > Thus, __GFP_NORETRY | __GFP_NOFAIL perfectly makes sense as
> > "Never fail allocation request if direct reclaim/compaction did not help.
> > But do not invoke the OOM killer even if direct reclaim/compaction did not help."
> 
> Stop this! Seriously... This is just wasting time...

You are free to ignore me. But

> 
>  * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
>  *   return NULL when direct reclaim and memory compaction have failed to allow
>  *   the allocation to succeed.  The OOM killer is not called with the current
>  *   implementation.
> 
>  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
>  *   cannot handle allocation failures. New users should be evaluated carefully
>  *   (and the flag should be used only when there is no reasonable failure
>  *   policy) but it is definitely preferable to use the flag rather than
>  *   opencode endless loop around allocator.
> 
> Can you see how the two are asking for opposite behavior?  Asking for
> not retrying for ever and not failing and rather retrying for ever
> simply doesn't make any sense in any reasonable universe I can think
> of. Therefore I think that it is fair to say that behavior is undefined
> when both are specified.

I consider that I'm using __GFP_NORETRY as a mean to avoid calling the OOM
killer rather than avoid retrying indefinitely. Therefore, I want

  __GFP_NOOOMKILL: The VM implementation must not call the OOM killer when
  direct reclaim and memory compaction have failed to allow the allocation
  to succeed.

and __GFP_NOOOMKILL | __GFP_NOFAIL makes sense.

Technically PATCH 1/3 allows __GFP_NOOOMKILL | __GFP_NOFAIL emulation
via __GFP_NOFAIL | __GFP_NOFAIL. If you don't like such emulation,
I welcome __GFP_NOOOMKILL.

> 
> Considering there are _no_ users which would do that any further
> discussion about this is just pointless and I will not respond to any
> further emails in this direction.
> 
> This is just ridiculous!

Regardless of whether we define __GFP_NOOOMKILL, I wonder we need PATCH 2/3 now
because currently premature OOM killer invocation due to !__GFP_FS && __GFP_NOFAIL
is a prophetical problem. We can consider PATCH 2/3 (or __GFP_NOOOMKILL) when
someone reported OOM killer invocation via !__GFP_FS && __GFP_NOFAIL and
confirmed that the memory counter says premature enough to suppress the OOM
killer invocation.

> 
> [...]
> >  void *kvmalloc_node(size_t size, gfp_t flags, int node)
> >  {
> >  	gfp_t kmalloc_flags = flags;
> >  	void *ret;
> >  
> >  	/*
> >  	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
> >  	 * so the given set of flags has to be compatible.
> >  	 */
> >  	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> >  
> >  	/*
> >  	 * Make sure that larger requests are not too disruptive - no OOM
> >  	 * killer and no allocation failure warnings as we have a fallback
> >  	 */
> > -	if (size > PAGE_SIZE)
> > +	if (size > PAGE_SIZE) {
> >  		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> > +		kmalloc_flags &= ~__GFP_NOFAIL;
> > +	}
> 
> No there are simply no users of this and even if had one which would be
> legitimate it wouldn't be as simple as this. vmalloc _doesn't_ support
> GFP_NOFAIL and it would be really non-trivial to implement it. If for
> nothing else there are unconditional GFP_KERNEL allocations in some
> vmalloc paths (which is btw. the reason why vmalloc is not GFP_NOFS
> unsafe). It would take much more to add the non-failing semantic. And I
> see _no_ reason to argue with this possibility when a) there is no such
> user currently and b) it is even not clear whether we want to support
> such a usecase.

I didn't know vmalloc() doesn't support GFP_NOFAIL.
Anyway, we don't need to make such change now because of a).

> 
> [...]
> > > > in http://lkml.kernel.org/r/20161218163727.GC8440@dhcp22.suse.cz .
> > > > Indeed that trace is a __GFP_DIRECT_RECLAIM and it might not be blocking
> > > > other workqueue items which a regular I/O depend on, I think there are
> > > > !__GFP_DIRECT_RECLAIM memory allocation requests for issuing SCSI commands
> > > > which could potentially start failing due to helping GFP_NOFS | __GFP_NOFAIL
> > > > allocations with memory reserves. If a SCSI disk I/O request fails due to
> > > > GFP_ATOMIC memory allocation failures because we allow a FS I/O request to
> > > > use memory reserves, it adds a new problem.
> > > 
> > > Do you have any example of such a request? Anything that requires
> > > a forward progress during IO should be using mempools otherwise it
> > > is broken pretty much by design already. Also IO depending on NOFS
> > > allocations sounds pretty much broken already. So I suspect the above
> > > reasoning is just bogus.
> > 
> > You are missing my point. My question is "who needs memory reserves".
> > I'm not saying that disk I/O depends on GFP_NOFS allocation. I'm worrying
> > that [PATCH 3/3] consumes memory reserves when disk I/O also depends on
> > memory reserves.
> > 
> > My understanding is that when accessing SCSI disks, SCSI protocol is used.
> > SCSI driver allocates memory at runtime for using SCSI protocol using
> > GFP_ATOMIC. And GFP_ATOMIC uses some of memory reserves. But [PATCH 3/3]
> > also uses memory reserves. If memory reserves are consumed by [PATCH 3/3]
> > to the level where GFP_ATOMIC cannot succeed, I think it causes troubles.
> 
> Yes and GFP_ATOMIC will have a deeper access to memory reserves than what
> we are giving access to in patch 3. There is difference between
> ALLOC_HARDER and ALLOC_HIGH. This is described in the changelog. Sure
> GFP_NOFAIL will eat into part of the reserves which GFP_ATOMIC (aka
> GFP_HIGH) could have used but a) this shouldn't happen unless we are
> really getting out of memory and b) it should help other presumably
> important allocations (why would they be GFP_NOFAIL otherwise right?).
> So it is not just a free ticket to a scarce resource and IMHO it is
> justified.

If you try to allow !__GFP_FS allocations to fail rather than retry,
someone might start scattering __GFP_NOFAIL regardless of importance.

> 
> > I'm unable to obtain nice backtraces, but I think we can confirm that
> > there are GFP_ATOMIC allocations (e.g. sg_alloc_table_chained() calls
> > __sg_alloc_table(GFP_ATOMIC)) when we are using SCSI disks.
> 
> How are those blocking further progress? Failing atomic allocations are
> nothing to lose sleep over. They cannot be, pretty by definition, relied
> on to make a further progress.

So, regarding simple SCSI disk case, it is guaranteed that disk I/O request
can recover from transient failures (e.g. timeout?) and complete unless
fatal failures (e.g. hardware out of order?) occur, isn't it? Then,
PATCH 3/3 would be helpful for this case.

What about other cases, such as loopback devices ( /dev/loopX ) and/or
networking storage? Are they also guaranteed that I/O requests never be
blocked on memory allocation requests which are not allowed to access
memory reserves? If yes, PATCH 3/3 would be helpful. If no, I think
what we need is a mechanism to propagate allowing access to memory
reserves similar to scope GFP_NOFS API.

> 
> [...]
> 
> I am _really_ getting tired of this discussion. You are making wrong or
> unfounded claims again and again. I have no idea what are you trying to
> achieve here but I simply do not see any sense in continuing in this
> discussion.
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
