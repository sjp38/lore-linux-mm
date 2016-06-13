Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5156B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:37:29 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id wy7so42839079lbb.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:37:29 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y75si14493165wmc.75.2016.06.13.04.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 04:37:27 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id k184so14146028wme.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:37:27 -0700 (PDT)
Date: Mon, 13 Jun 2016 13:37:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_HARD with more useful semantic
Message-ID: <20160613113726.GE6518@dhcp22.suse.cz>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-2-git-send-email-mhocko@kernel.org>
 <7fb7e035-7795-839b-d1b0-4a68fcf8e9c9@I-love.SAKURA.ne.jp>
 <20160607123149.GK12305@dhcp22.suse.cz>
 <201606112335.HBG09891.OLFJOFtVMOQHSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606112335.HBG09891.OLFJOFtVMOQHSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org

On Sat 11-06-16 23:35:49, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 07-06-16 21:11:03, Tetsuo Handa wrote:
> > > Remaining __GFP_REPEAT users are not always doing costly allocations.
> > 
> > Yes but...
> > 
> > > Sometimes they pass __GFP_REPEAT because the size is given from userspace.
> > > Thus, unconditional s/__GFP_REPEAT/__GFP_RETRY_HARD/g is not good.
> > 
> > Would that be a regression though? Strictly speaking the __GFP_REPEAT
> > documentation was explicit to not loop for ever. So nobody should have
> > expected nofail semantic pretty much by definition. The fact that our
> > previous implementation was not fully conforming to the documentation is
> > just an implementation detail.  All the remaining users of __GFP_REPEAT
> > _have_ to be prepared for the allocation failure. So what exactly is the
> > problem with them?
> 
> A !costly allocation becomes weaker than now if __GFP_RETRY_HARD is passed.

That is true. But it is not weaker than the __GFP_REPEAT actually ever
promissed. __GFP_REPEAT explicitly said to not retry _for_ever_. The
fact that we have ignored it is sad but that is what I am trying to
address here.

> > > >  	/* Reclaim has failed us, start killing things */
> > > >  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
> > > >  	if (page)
> > > > @@ -3719,6 +3731,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  	/* Retry as long as the OOM killer is making progress */
> > > >  	if (did_some_progress) {
> > > >  		no_progress_loops = 0;
> > > > +		passed_oom = true;
> > > 
> > > This is too premature. did_some_progress != 0 after returning from
> > > __alloc_pages_may_oom() does not mean the OOM killer was invoked. It only means
> > > that mutex_trylock(&oom_lock) was attempted.
> > 
> > which means that we have reached the OOM condition and _somebody_ is
> > actaully handling the OOM on our behalf.
> 
> That _somebody_ might release oom_lock without invoking the OOM killer (e.g.
> doing !__GFP_FS allocation), which means that we have reached the OOM condition
> and nobody is actually handling the OOM on our behalf. __GFP_RETRY_HARD becomes
> as weak as __GFP_NORETRY. I think this is a regression.

I really fail to see your point. We are talking about a gfp flag which
tells the allocator to retry as much as it is feasible. Getting through
all the reclaim attempts two times without any progress sounds like a
fair criterion. Well, we could try $NUM times but that wouldn't make too
much difference to what you are writing above. The fact whether somebody
has been killed or not is not really that important IMHO.

> > > What I think more important is hearing from __GFP_REPEAT users how hard they
> > > want to retry. It is possible that they want to retry unless SIGKILL is
> > > delivered, but passing __GFP_NOFAIL is too hard, and therefore __GFP_REPEAT
> > > is used instead. It is possible that they use __GFP_NOFAIL || __GFP_KILLABLE
> > > if __GFP_KILLABLE were available. In my module (though I'm not using
> > > __GFP_REPEAT), I want to retry unless SIGKILL is delivered.
> > 
> > To be honest killability for a particular allocation request sounds
> > like a hack to me. Just consider the expected semantic. How do you
> > handle when one path uses explicit __GFP_KILLABLE while other path (from
> > the same syscall) is not... If anything this would have to be process
> > context wise.
> 
> I didn't catch your question. But making code killable should be considered
> good unless it complicates error handling paths.

What I meant was this
	kmalloc(GFP_KILLABLE)
	func1
	  kmalloc(GFP_KERNEL)

is still not killable context because whatever you call (func1) might
have a different view about killability. So the per allocation context
will not work reliably.

> Since we are not setting TIF_MEMDIE to all OOM-killed threads, OOM-killed
> threads will have to loop until mutex_trylock(&oom_lock) succeeds in order
> to get TIF_MEMDIE by calling out_of_memory(), which is a needless delay.
> 
> Many allocations from syscall context can give up upon SIGKILL. We don't
> need to allow OOM-killed threads to use memory reserves if that allocation
> is killable.
> 
> Converting down_write(&mm->mmap_sem) to down_write_killable(&mm->mmap_sem)
> is considered good. But converting kmalloc(GFP_KERNEL) to
> kmalloc(GFP_KERNEL | __GFP_KILLABLE) is considered hack. Why?

Because unblocking the killable context is meant to help others who want
to take the lock to make a forward progress. While the killable
allocation context is only about the particular allocation to fail when
the task is killed. There is no direct resource to release. So unless
all the allocation in the same scope are killable this will not help
anything. See my point?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
