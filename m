Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 615E66B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 04:15:45 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so27182476lfw.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 01:15:45 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id m194si25802682wmd.66.2016.07.20.01.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 01:15:43 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id o80so56700217wme.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 01:15:43 -0700 (PDT)
Date: Wed, 20 Jul 2016 10:15:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
Message-ID: <20160720081541.GF11249@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <20160719135426.GA31229@cmpxchg.org>
 <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Tue 19-07-16 13:45:52, David Rientjes wrote:
> On Tue, 19 Jul 2016, Johannes Weiner wrote:
> 
> > Mempool guarantees forward progress by having all necessary memory
> > objects for the guaranteed operation in reserve. Think about it this
> > way: you should be able to delete the pool->alloc() call entirely and
> > still make reliable forward progress. It would kill concurrency and be
> > super slow, but how could it be affected by a system OOM situation?
> > 
> > If our mempool_alloc() is waiting for an object that an OOM victim is
> > holding, where could that OOM victim get stuck before giving it back?
> > As I asked in the previous thread, surely you wouldn't do a mempool
> > allocation first and then rely on an unguarded page allocation to make
> > forward progress, right? It would defeat the purpose of using mempools
> > in the first place. And surely the OOM victim wouldn't be waiting for
> > a lock that somebody doing mempool_alloc() *against the same mempool*
> > is holding. That'd be an obvious ABBA deadlock.
> > 
> > So maybe I'm just dense, but could somebody please outline the exact
> > deadlock diagram? Who is doing what, and how are they getting stuck?
> > 
> > cpu0:                     cpu1:
> >                           mempool_alloc(pool0)
> > mempool_alloc(pool0)
> >   wait for cpu1
> >                           not allocating memory - would defeat mempool
> >                           not taking locks held by cpu0* - would ABBA
> >                           ???
> >                           mempool_free(pool0)
> > 
> > Thanks
> > 
> > * or any other task that does mempool_alloc(pool0) before unlock
> > 
> 
> I'm approaching this from a perspective of any possible mempool usage, not 
> with any single current user in mind.
> 
> Any mempool_alloc() user that then takes a contended mutex can do this.  
> An example:
> 
> 	taskA		taskB		taskC
> 	-----		-----		-----
> 	mempool_alloc(a)
> 			mutex_lock(b)
> 	mutex_lock(b)
> 					mempool_alloc(a)
> 
> Imagine the mempool_alloc() done by taskA depleting all free elements so 
> we rely on it to do mempool_free() before any other mempool allocator can 
> be guaranteed.
> 
> If taskC is oom killed, or has PF_MEMALLOC set, it cannot access memory 
> reserves from the page allocator if __GFP_NOMEMALLOC is automatic in 
> mempool_alloc().  This livelocks the page allocator for all processes.
> 
> taskB in this case need only stall after taking mutex_lock() successfully; 
> that could be because of the oom livelock, it is contended on another 
> mutex held by an allocator, etc.

But that falls down to the deadlock described by Johannes above because
then the mempool user would _depend_ on an "unguarded page allocation"
via that particular lock and that is a bug.
 
> Obviously taskB stalling while holding a mutex that is contended by a 
> mempool user holding an element is not preferred, but it's possible.  (A 
> simplified version is also possible with 0-size mempools, which are also 
> allowed.)
> 
> My point is that I don't think we should be forcing any behavior wrt 
> memory reserves as part of the mempool implementation. 

Isn't the reserve management the whole point of the mempool approach?

> In the above, 
> taskC mempool_alloc() would succeed and not livelock unless 
> __GFP_NOMEMALLOC is forced. 

Or it would get stuck because even page allocator memory reserves got
depleted. Without any way to throttle there is no guarantee to make
further progress. In fact this is not a theoretical situation. It has
been observed with the swap over dm-crypt and there shouldn't be any
lock dependeces you are describing above there AFAIU.

> The mempool_alloc() user may construct their 
> set of gfp flags as appropriate just like any other memory allocator in 
> the kernel.

So which users of mempool_alloc would benefit from not having
__GFP_NOMEMALLOC and why?

> The alternative would be to ensure no mempool users ever take a lock that 
> another thread can hold while contending another mutex or allocating 
> memory itself.

I am not sure how can we enforce that but surely that would detect a
clear mempool usage bug. Lockdep could be probably extended to do so.

Anway, I feel we are looping in a circle. We have a clear regression
caused by your patch. It might solve some oom livelock you are seeing
but there are only very dim details about it and the patch might very
well paper over a bug in mempool usage somewhere else. We definitely
need more details to know that better.

That being said, f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC
if there are free elements") should be either reverted or
http://lkml.kernel.org/r/1468831285-27242-1-git-send-email-mhocko@kernel.org
should be applied as a temporal workaround because it would make a
lockup less likely for now until we find out more about your issue.

Does that sound like a way forward?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
