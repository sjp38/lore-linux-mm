Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6385B828E4
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 17:47:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so241433894pfa.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:47:39 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id 65si963864pfo.47.2016.07.15.14.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 14:47:38 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id p64so11102080pfb.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:47:38 -0700 (PDT)
Date: Fri, 15 Jul 2016 14:47:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160715072242.GB11811@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1607151426420.121215@chino.kir.corp.google.com>
References: <20160712064905.GA14586@dhcp22.suse.cz> <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
 <20160714152913.GC12289@dhcp22.suse.cz> <alpine.DEB.2.10.1607141326500.68666@chino.kir.corp.google.com> <20160715072242.GB11811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Jul 2016, Michal Hocko wrote:

> > If PF_MEMALLOC context is allocating too much memory reserves, then I'd 
> > argue that is a problem independent of using mempool_alloc() since 
> > mempool_alloc() can evolve directly into a call to the page allocator.  
> > How does such a process guarantee that it cannot deplete memory reserves 
> > with a simple call to the page allocator?  Since nothing in the page 
> > allocator is preventing complete depletion of reserves (it simply uses 
> > ALLOC_NO_WATERMARKS), the caller in a PF_MEMALLOC context must be 
> > responsible.
> 
> Well, the reclaim throttles the allocation request if there are too many
> pages under writeback and that should slow down the allocation rate and
> give the writeback some time to complete. But yes you are right there is
> nothing to prevent from memory depletion and it is really hard to come
> up with something with no fail semantic.
> 

If the reclaimer is allocating memory, it can fully deplete memory 
reserves with ALLOC_NO_WATERMARKS without any direct reclaim itself and 
we're relying on kswapd entirely if nothing else is reclaiming in parallel 
(and depleting memory reserves itself in parallel).  It's a difficult 
problem because memory reserves can be very small and concurrent 
PF_MEMALLOC allocation contexts can lead to quick depletion.  I don't 
think it's a throttling problem itself, it's more scalability.

> I would like separate TIF_MEMDIE as an access to memory reserves from
> oom selection selection semantic. And let me repeat your proposed patch
> has a undesirable side effects so we should think about a way to deal
> with those cases. It might work for your setups but it shouldn't break
> others at the same time. OOM situation is quite unlikely compared to
> simple memory depletion by writing to a swap...
>  

I haven't proposed any patch, not sure what the reference is to.  There's 
two fundamental ways to go about it: (1) ensure mempool_alloc() can make 
forward progress (whether that's by way of gfp flags or access to memory 
reserves, which may depend on the process context such as PF_MEMALLOC) or 
(2) rely on an implementation detail of mempools to never access memory 
reserves, although it is shown to not livelock systems on 4.7 and earlier 
kernels, and instead rely on users of the same mempool to return elements 
to the freelist in all contexts, including oom contexts.  The mempool 
implementation itself shouldn't need any oom awareness, that should be a 
page allocator issue.

If the mempool user can guarantee that elements will be returned to the 
freelist in all contexts, we could relax the restriction that mempool 
users cannot use __GFP_NOMEMALLOC and leave it up to them to prevent 
access to memory reserves but only in situations where forward progress 
can be guaranteed.  That's a simple change and doesn't change mempool or 
page allocator behavior for everyone, but rather only for those that 
opt-in.  I think this is the way the dm folks should proceed, but let's 
not encode any special restriction on access to memory reserves as an 
implementation detail to mempools, specifically for processes that have 
PF_MEMALLOC set.

> Just to make sure I understand properly:
> Task A				Task B			Task C
> current->flags = PF_MEMALLOC
> mutex_lock(&foo)		mutex_lock(&foo)	out_of_memory
> mempool_alloc()						  select_bad__process = Task B
>   alloc_pages(__GFP_NOMEMALLOC)
> 

Not sure who is grabbing foo first with this, I assume Task A and Task B 
is contending.  If that's the case, then yes, this is the dm_request() oom 
livelock that went unresolved for two hours on our machines and timed 
them all out.  This is a swapless environment that heavily oversubscribes 
the machine, so not everybody's use case, but it needs to be resolved.

> That would be really unfortunate but it doesn't really differ much from
> other oom deadlocks when the victim is stuck behind an allocating task.

I'm well aware of many of the system oom and memcg oom livelocks from 
experience, unfortunately :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
