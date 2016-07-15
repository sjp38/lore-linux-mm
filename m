Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2F1B6B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:22:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so8583639wmr.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 00:22:45 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id b190si3628662wmf.127.2016.07.15.00.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 00:22:44 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id f126so14505187wma.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 00:22:44 -0700 (PDT)
Date: Fri, 15 Jul 2016 09:22:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160715072242.GB11811@dhcp22.suse.cz>
References: <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
 <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
 <20160714152913.GC12289@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607141326500.68666@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607141326500.68666@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 14-07-16 13:38:42, David Rientjes wrote:
> On Thu, 14 Jul 2016, Michal Hocko wrote:
> 
> > > It prevents the whole system from livelocking due to an oom killed process 
> > > stalling forever waiting for mempool_alloc() to return.  No other threads 
> > > may be oom killed while waiting for it to exit.
> > 
> > But it is true that the patch has unintended side effect for any mempool
> > allocation from the reclaim path (aka PF_MEMALLOC context).
> 
> If PF_MEMALLOC context is allocating too much memory reserves, then I'd 
> argue that is a problem independent of using mempool_alloc() since 
> mempool_alloc() can evolve directly into a call to the page allocator.  
> How does such a process guarantee that it cannot deplete memory reserves 
> with a simple call to the page allocator?  Since nothing in the page 
> allocator is preventing complete depletion of reserves (it simply uses 
> ALLOC_NO_WATERMARKS), the caller in a PF_MEMALLOC context must be 
> responsible.

Well, the reclaim throttles the allocation request if there are too many
pages under writeback and that should slow down the allocation rate and
give the writeback some time to complete. But yes you are right there is
nothing to prevent from memory depletion and it is really hard to come
up with something with no fail semantic.

Or do you have an idea how to throttle withou knowing how much memory
will be actually consumed on the writeout path?

> > So do you
> > think we should rework your additional patch to be explicit about
> > TIF_MEMDIE?
> 
> Not sure which additional patch you're referring to, the only patch that I 
> proposed was commit f9054c70d28b which solved hundreds of machines from 
> timing out.

I would like separate TIF_MEMDIE as an access to memory reserves from
oom selection selection semantic. And let me repeat your proposed patch
has a undesirable side effects so we should think about a way to deal
with those cases. It might work for your setups but it shouldn't break
others at the same time. OOM situation is quite unlikely compared to
simple memory depletion by writing to a swap...
 
> > Something like the following (not even compile tested for
> > illustration). Tetsuo has properly pointed out that this doesn't work
> > for multithreaded processes reliable but put that aside for now as that
> > needs a fix on a different layer. I believe we can fix that quite
> > easily after recent/planned changes.
> > ---
> > diff --git a/mm/mempool.c b/mm/mempool.c
> > index 8f65464da5de..ea26d75c8adf 100644
> > --- a/mm/mempool.c
> > +++ b/mm/mempool.c
> > @@ -322,20 +322,20 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  
> >  	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
> >  
> > +	gfp_mask |= __GFP_NOMEMALLOC;   /* don't allocate emergency reserves */
> >  	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
> >  	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
> >  
> >  	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
> >  
> >  repeat_alloc:
> > -	if (likely(pool->curr_nr)) {
> > -		/*
> > -		 * Don't allocate from emergency reserves if there are
> > -		 * elements available.  This check is racy, but it will
> > -		 * be rechecked each loop.
> > -		 */
> > -		gfp_temp |= __GFP_NOMEMALLOC;
> > -	}
> > +	/*
> > +	 * Make sure that the OOM victim will get access to memory reserves
> > +	 * properly if there are no objects in the pool to prevent from
> > +	 * livelocks.
> > +	 */
> > +	if (!likely(pool->curr_nr) && test_thread_flag(TIF_MEMDIE))
> > +		gfp_temp &= ~__GFP_NOMEMALLOC;
> >  
> >  	element = pool->alloc(gfp_temp, pool->pool_data);
> >  	if (likely(element != NULL))
> > @@ -359,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> >  	 * We use gfp mask w/o direct reclaim or IO for the first round.  If
> >  	 * alloc failed with that and @pool was empty, retry immediately.
> >  	 */
> > -	if ((gfp_temp & ~__GFP_NOMEMALLOC) != gfp_mask) {
> > +	if ((gfp_temp & __GFP_DIRECT_RECLAIM) != (gfp_mask & __GFP_DIRECT_RECLAIM)) {
> >  		spin_unlock_irqrestore(&pool->lock, flags);
> >  		gfp_temp = gfp_mask;
> >  		goto repeat_alloc;
> 
> This is bogus and quite obviously leads to oom livelock: if a process is 
> holding a mutex and does mempool_alloc(), since __GFP_WAIT is allowed in 
> process context for mempool allocation, it can stall here in an oom 
> condition if there are no elements available on the mempool freelist.  If 
> the oom victim contends the same mutex, the system livelocks and the same 
> bug arises because the holder of the mutex loops forever.  This is the 
> exact behavior that f9054c70d28b also fixes.

Just to make sure I understand properly:
Task A				Task B			Task C
current->flags = PF_MEMALLOC
mutex_lock(&foo)		mutex_lock(&foo)	out_of_memory
mempool_alloc()						  select_bad__process = Task B
  alloc_pages(__GFP_NOMEMALLOC)


That would be really unfortunate but it doesn't really differ much from
other oom deadlocks when the victim is stuck behind an allocating task.
This is a generic problem and our answer for that is the oom reaper
which will tear down the address space of the victim asynchronously.
Sure there is no guarantee it will free enough to get us unstuck because
we are freeing only private unlocked memory but we rather fallback to
another oom victim if the situation prevails even after the unmapping
pass. So we shouldn't be stuck for ever.

That being said should we rely for the mempool allocations the same as
any other oom deadlock due to locks?

> These aren't hypothetical situations, the patch fixed hundreds of machines 
> from regularly timing out.  The fundamental reason is that mempool_alloc() 
> must not loop forever in process context: that is needed when the 
> allocator is either an oom victim itself or the oom victim is blocked by 
> an allocator.  mempool_alloc() must guarantee forward progress in such a 
> context.
> 
> The end result is that when in PF_MEMALLOC context, allocators must be 
> responsible and not deplete all memory reserves.

How do you propose to guarantee that? You might have really complex IO
setup and mempools have been the answer for guaranteeing forward progress
for ages.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
