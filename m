Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C04126B0260
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 17:06:36 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hh10so104600278pac.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 14:06:36 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id cz10si5289645pad.214.2016.07.20.14.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 14:06:35 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id x72so22585883pfd.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 14:06:35 -0700 (PDT)
Date: Wed, 20 Jul 2016 14:06:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from
 the reclaim path
In-Reply-To: <20160720081541.GF11249@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1607201353230.22427@chino.kir.corp.google.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <20160719135426.GA31229@cmpxchg.org> <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
 <20160720081541.GF11249@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Wed, 20 Jul 2016, Michal Hocko wrote:

> > Any mempool_alloc() user that then takes a contended mutex can do this.  
> > An example:
> > 
> > 	taskA		taskB		taskC
> > 	-----		-----		-----
> > 	mempool_alloc(a)
> > 			mutex_lock(b)
> > 	mutex_lock(b)
> > 					mempool_alloc(a)
> > 
> > Imagine the mempool_alloc() done by taskA depleting all free elements so 
> > we rely on it to do mempool_free() before any other mempool allocator can 
> > be guaranteed.
> > 
> > If taskC is oom killed, or has PF_MEMALLOC set, it cannot access memory 
> > reserves from the page allocator if __GFP_NOMEMALLOC is automatic in 
> > mempool_alloc().  This livelocks the page allocator for all processes.
> > 
> > taskB in this case need only stall after taking mutex_lock() successfully; 
> > that could be because of the oom livelock, it is contended on another 
> > mutex held by an allocator, etc.
> 
> But that falls down to the deadlock described by Johannes above because
> then the mempool user would _depend_ on an "unguarded page allocation"
> via that particular lock and that is a bug.
>  

It becomes a deadlock because of mempool_alloc(a) forcing 
__GFP_NOMEMALLOC, I agree.

For that not to be the case, it must be required that between 
mempool_alloc() and mempool_free() that we take no mutex that may be held 
by any other thread on the system, in any context, that is allocating 
memory.  If that's a caller's bug as you describe it, and only enabled by 
mempool_alloc() forcing __GFP_NOMEMALLOC, then please add the relevant 
lockdep detection, which would be trivial to add, so we can determine if 
any users are unsafe and prevent this issue in the future.  The 
overwhelming goal here should be to prevent possible problems in the 
future especially if an API does not allow you to opt-out of the behavior.

> > My point is that I don't think we should be forcing any behavior wrt 
> > memory reserves as part of the mempool implementation. 
> 
> Isn't the reserve management the whole point of the mempool approach?
> 

No, the whole point is to maintain the freelist of elements that are 
guaranteed; my suggestion is that we cannot make that guarantee if we are 
blocked from freeing elements.  It's trivial to fix by allowing 
__GFP_NOMEMALLOC from the caller in cases where you cannot possibly be 
blocked by an oom victim.

> Or it would get stuck because even page allocator memory reserves got
> depleted. Without any way to throttle there is no guarantee to make
> further progress. In fact this is not a theoretical situation. It has
> been observed with the swap over dm-crypt and there shouldn't be any
> lock dependeces you are describing above there AFAIU.
> 

They should do mempool_alloc(__GFP_NOMEMALLOC), no argument.

> > The mempool_alloc() user may construct their 
> > set of gfp flags as appropriate just like any other memory allocator in 
> > the kernel.
> 
> So which users of mempool_alloc would benefit from not having
> __GFP_NOMEMALLOC and why?
> 

Any mempool_alloc() user that would be blocked on returning the element 
back to the freelist by an oom condition.  I think the dm-crypt case is 
quite unique on how it is able to deplete memory reserves.

> Anway, I feel we are looping in a circle. We have a clear regression
> caused by your patch. It might solve some oom livelock you are seeing
> but there are only very dim details about it and the patch might very
> well paper over a bug in mempool usage somewhere else. We definitely
> need more details to know that better.
> 

What is the objection to allowing __GFP_NOMEMALLOC from the caller with 
clear documentation on how to use it?  It can be described to not allow 
depletion of memory reserves with the caveat that the caller must ensure 
mempool_free() cannot be blocked in lowmem situations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
