Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9FB56B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:46:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so58894215pfb.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 13:46:09 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ln1si34469790pab.135.2016.07.19.13.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 13:46:06 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id iw10so10309514pac.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 13:46:00 -0700 (PDT)
Date: Tue, 19 Jul 2016 13:45:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from
 the reclaim path
In-Reply-To: <20160719135426.GA31229@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <20160719135426.GA31229@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, Michal Hocko <mhocko@suse.com>

On Tue, 19 Jul 2016, Johannes Weiner wrote:

> Mempool guarantees forward progress by having all necessary memory
> objects for the guaranteed operation in reserve. Think about it this
> way: you should be able to delete the pool->alloc() call entirely and
> still make reliable forward progress. It would kill concurrency and be
> super slow, but how could it be affected by a system OOM situation?
> 
> If our mempool_alloc() is waiting for an object that an OOM victim is
> holding, where could that OOM victim get stuck before giving it back?
> As I asked in the previous thread, surely you wouldn't do a mempool
> allocation first and then rely on an unguarded page allocation to make
> forward progress, right? It would defeat the purpose of using mempools
> in the first place. And surely the OOM victim wouldn't be waiting for
> a lock that somebody doing mempool_alloc() *against the same mempool*
> is holding. That'd be an obvious ABBA deadlock.
> 
> So maybe I'm just dense, but could somebody please outline the exact
> deadlock diagram? Who is doing what, and how are they getting stuck?
> 
> cpu0:                     cpu1:
>                           mempool_alloc(pool0)
> mempool_alloc(pool0)
>   wait for cpu1
>                           not allocating memory - would defeat mempool
>                           not taking locks held by cpu0* - would ABBA
>                           ???
>                           mempool_free(pool0)
> 
> Thanks
> 
> * or any other task that does mempool_alloc(pool0) before unlock
> 

I'm approaching this from a perspective of any possible mempool usage, not 
with any single current user in mind.

Any mempool_alloc() user that then takes a contended mutex can do this.  
An example:

	taskA		taskB		taskC
	-----		-----		-----
	mempool_alloc(a)
			mutex_lock(b)
	mutex_lock(b)
					mempool_alloc(a)

Imagine the mempool_alloc() done by taskA depleting all free elements so 
we rely on it to do mempool_free() before any other mempool allocator can 
be guaranteed.

If taskC is oom killed, or has PF_MEMALLOC set, it cannot access memory 
reserves from the page allocator if __GFP_NOMEMALLOC is automatic in 
mempool_alloc().  This livelocks the page allocator for all processes.

taskB in this case need only stall after taking mutex_lock() successfully; 
that could be because of the oom livelock, it is contended on another 
mutex held by an allocator, etc.

Obviously taskB stalling while holding a mutex that is contended by a 
mempool user holding an element is not preferred, but it's possible.  (A 
simplified version is also possible with 0-size mempools, which are also 
allowed.)

My point is that I don't think we should be forcing any behavior wrt 
memory reserves as part of the mempool implementation.  In the above, 
taskC mempool_alloc() would succeed and not livelock unless 
__GFP_NOMEMALLOC is forced.  The mempool_alloc() user may construct their 
set of gfp flags as appropriate just like any other memory allocator in 
the kernel.

The alternative would be to ensure no mempool users ever take a lock that 
another thread can hold while contending another mutex or allocating 
memory itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
