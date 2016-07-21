Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEEF828FF
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:52:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so8325388wmp.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:52:06 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id e73si3256166lji.68.2016.07.21.01.52.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 01:52:04 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id i5so16350682wmg.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:52:04 -0700 (PDT)
Date: Thu, 21 Jul 2016 10:52:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
Message-ID: <20160721085202.GC26379@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <20160719135426.GA31229@cmpxchg.org>
 <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
 <20160720081541.GF11249@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607201353230.22427@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607201353230.22427@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Wed 20-07-16 14:06:26, David Rientjes wrote:
> On Wed, 20 Jul 2016, Michal Hocko wrote:
> 
> > > Any mempool_alloc() user that then takes a contended mutex can do this.  
> > > An example:
> > > 
> > > 	taskA		taskB		taskC
> > > 	-----		-----		-----
> > > 	mempool_alloc(a)
> > > 			mutex_lock(b)
> > > 	mutex_lock(b)
> > > 					mempool_alloc(a)
> > > 
> > > Imagine the mempool_alloc() done by taskA depleting all free elements so 
> > > we rely on it to do mempool_free() before any other mempool allocator can 
> > > be guaranteed.
> > > 
> > > If taskC is oom killed, or has PF_MEMALLOC set, it cannot access memory 
> > > reserves from the page allocator if __GFP_NOMEMALLOC is automatic in 
> > > mempool_alloc().  This livelocks the page allocator for all processes.
> > > 
> > > taskB in this case need only stall after taking mutex_lock() successfully; 
> > > that could be because of the oom livelock, it is contended on another 
> > > mutex held by an allocator, etc.
> > 
> > But that falls down to the deadlock described by Johannes above because
> > then the mempool user would _depend_ on an "unguarded page allocation"
> > via that particular lock and that is a bug.
> >  
> 
> It becomes a deadlock because of mempool_alloc(a) forcing 
> __GFP_NOMEMALLOC, I agree.
> 
> For that not to be the case, it must be required that between 
> mempool_alloc() and mempool_free() that we take no mutex that may be held 
> by any other thread on the system, in any context, that is allocating 
> memory.  If that's a caller's bug as you describe it, and only enabled by 
> mempool_alloc() forcing __GFP_NOMEMALLOC, then please add the relevant 
> lockdep detection, which would be trivial to add, so we can determine if 
> any users are unsafe and prevent this issue in the future.

I am sorry but I am neither familiar with the lockdep internals nor I
have a time to add this support.

> The 
> overwhelming goal here should be to prevent possible problems in the 
> future especially if an API does not allow you to opt-out of the behavior.

The __GFP_NOMEMALLOC enforcement is there since b84a35be0285 ("[PATCH]
mempool: NOMEMALLOC and NORETRY") so more than 10 years ago. So I think
it is quite reasonable to expect that users are familiar with this fact
and handle it properly in the vast majority cases. In fact mempool
deadlocks are really rare.

[...]

> > Or it would get stuck because even page allocator memory reserves got
> > depleted. Without any way to throttle there is no guarantee to make
> > further progress. In fact this is not a theoretical situation. It has
> > been observed with the swap over dm-crypt and there shouldn't be any
> > lock dependeces you are describing above there AFAIU.
> > 
> 
> They should do mempool_alloc(__GFP_NOMEMALLOC), no argument.

How that would be any different from any other mempool user which can be
invoked from the swap out path - aka any other IO path?

> What is the objection to allowing __GFP_NOMEMALLOC from the caller with 
> clear documentation on how to use it?  It can be described to not allow 
> depletion of memory reserves with the caveat that the caller must ensure 
> mempool_free() cannot be blocked in lowmem situations.

Look, there are
$ git grep mempool_alloc | wc -l
304

many users of this API and we do not want to flip the default behavior
which is there for more than 10 years. So far you have been arguing
about potential deadlocks and haven't shown any particular path which
would have a direct or indirect dependency between mempool and normal
allocator and it wouldn't be a bug. As the matter of fact the change
we are discussing here causes a regression. If you want to change the
semantic of mempool allocator then you are absolutely free to do so. In
a separate patch which would be discussed with IO people and other
users, though. But we _absolutely_ want to fix the regression first
and have a simple fix for 4.6 and 4.7 backports. At this moment there
are revert and patch 1 on the table.  The later one should make your
backtrace happy and should be only as a temporal fix until we find out
what is actually misbehaving on your systems. If you are not interested
to pursue that way I will simply go with the revert.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
