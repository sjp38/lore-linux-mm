Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFB0B6B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 09:37:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so59539894pfj.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:37:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h64si7066509pfd.152.2017.10.09.06.37.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 06:37:36 -0700 (PDT)
Date: Mon, 9 Oct 2017 15:37:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171009133734.u544mwyjipamc566@dhcp22.suse.cz>
References: <201710022344.JII17368.HQtLOMJOOSFFVF@I-love.SAKURA.ne.jp>
 <201710072030.HGE12424.HFFMVLJOOStFQO@I-love.SAKURA.ne.jp>
 <20171009074625.b7qztlyoa4u7lyy7@dhcp22.suse.cz>
 <201710091706.FAG81243.MOFLSJVtQFOFOH@I-love.SAKURA.ne.jp>
 <20171009122817.t2kd7pcqmh3xaay5@dhcp22.suse.cz>
 <201710092231.AEG21310.LFOtMQFFSJVOOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710092231.AEG21310.LFOtMQFFSJVOOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mst@redhat.com, linux-mm@kvack.org

On Mon 09-10-17 22:31:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 09-10-17 17:06:51, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Sat 07-10-17 20:30:19, Tetsuo Handa wrote:
> > > > [...]
> > > > > >From 6a0fd8a5e013ac63a6bcd06bd2ae6fdb25a4f3de Mon Sep 17 00:00:00 2001
> > > > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > > Date: Sat, 7 Oct 2017 19:29:21 +0900
> > > > > Subject: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
> > > > > 
> > > > > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > > > > serialize against fill_balloon(). But in fill_balloon(),
> > > > > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > > > > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
> > > > > implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
> > > > > is specified, this allocation attempt might depend on somebody else's
> > > > > __GFP_DIRECT_RECLAIM memory allocation.
> > > > 
> > > > How would that dependency look like? Is the holder of the lock doing
> > > > only __GFP_NORETRY?
> > > 
> > > __GFP_NORETRY makes difference only after reclaim attempt failed.
> > > 
> > > Reclaim attempt of __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS request can
> > > indirectly wait for somebody else's GFP_NOFS and/or GFP_NOIO request (e.g.
> > > blocked on filesystem's fs lock). And such indirect GFP_NOFS and/or
> > > GFP_NOIO request can reach __alloc_pages_may_oom() unless they also have
> > > __GFP_NORETRY. And such indirect GFP_NOFS and/or GFP_NOIO request can call
> > > OOM notifier callback and try to hold balloon_lock at leak_balloon() which
> > > fill_balloon() has already held before doing
> > > GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY request.
> > 
> > OK, so let me decipher.
> >  Thread1				Thread2						Thread3
> >  alloc_pages(GFP_KERNEL)		  fill_balloon					fs_lock #1	
> >    out_of_memory			    balloon_lock #2				alloc_page(GFP_NOFS)
> >      blocking_notifier_call_chain	    balloon_page_enqueue			  # keep retrying
> >        leak_balloon			      alloc_page(GFP_HIGHUSER_MOVABLE)
> >          balloon_lock #2		        direct_reclaim (__GFP_FS context)
> > 	 				          fs_lock #1
> > 
> > in other words, let's make the description understandable even for
> > somebody not really familiar with the allocation&reclaim internals.
> > The whole point is that the dependency is indirect and it requires
> > more actors and an example call grapg should be easier to follow.
> 
> 
> Yes. But it is more simple. Only two threads are needed.
> 
>   Thread1                                       Thread2
>     fill_balloon
>       balloon_lock #1
>       balloon_page_enqueue
>         alloc_page(GFP_HIGHUSER_MOVABLE)
>           direct reclaim (__GFP_FS context)       fs lock #2
>             fs lock #2                              alloc_page(GFP_NOFS)
>                                                       __alloc_pages_may_oom()
>                                                         oom_lock
>                                                         out_of_memory()
>                                                           blocking_notifier_call_chain()
>                                                             leak_balloon
>                                                               balloon_lock #1     # dead lock

Oh, right. I forgot we are allowed oom notifiers from NOFS context.
 
> And other __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations (if any) will keep
> retrying forever because oom_lock is held by Thread2.
> 
> > 
> > One more nit. If there is a way to estimate how much memory could be
> > freed by the notifier when the trylock would succeed I would print that
> > value for debugging purposes.
> 
> I don't know internal of virtio-balloon.

Maybe Michael can help here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
