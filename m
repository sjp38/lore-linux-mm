Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C84C76B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 07:55:39 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so24623997wjc.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 04:55:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1si44154024wjf.235.2016.12.12.04.55.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 04:55:38 -0800 (PST)
Date: Mon, 12 Dec 2016 13:55:36 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161212125535.GA3185@dhcp22.suse.cz>
References: <20161208132714.GA26530@dhcp22.suse.cz>
 <201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
 <20161209144624.GB4334@dhcp22.suse.cz>
 <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

On Mon 12-12-16 21:12:06, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index ed65d7df72d5..c2ba51cec93d 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -3024,11 +3024,14 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> > > >  	unsigned int filter = SHOW_MEM_FILTER_NODES;
> > > >  	struct va_format vaf;
> > > >  	va_list args;
> > > > +	static DEFINE_MUTEX(warn_lock);
> > > >  
> > > >  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
> > > >  	    debug_guardpage_minorder() > 0)
> > > >  		return;
> > > >  
> > > 
> > > if (gfp_mask & __GFP_DIRECT_RECLAIM)
> > 
> > Why?
> 
> Because warn_alloc() is also called by !__GFP_DIRECT_RECLAIM allocation
> requests when allocation failed. We are not allowed to sleep in that case.

Dohh, right. I have forgotten that warn_alloc is called when in the
nopage path. Sorry about that! We can make the lock non-sleepable...

> > 
> > > > +	mutex_lock(&warn_lock);
> > > > +
> > > >  	/*
> > > >  	 * This documents exceptions given to allocations in certain
> > > >  	 * contexts that are allowed to allocate outside current's set
> > > > @@ -3054,6 +3057,8 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> > > >  	dump_stack();
> > > >  	if (!should_suppress_show_mem())
> > > >  		show_mem(filter);
> > > > +
> > > 
> > > if (gfp_mask & __GFP_DIRECT_RECLAIM)
> > > 
> > > > +	mutex_unlock(&warn_lock);
> > > >  }
> > > >  
> > > >  static inline struct page *
> > > 
> > > and I think "s/warn_lock/oom_lock/" because out_of_memory() might
> > > call show_mem() concurrently.
> > 
> > I would rather not mix the two. Even if both use show_mem then there is
> > no reason to abuse the oom_lock.
> > 
> > Maybe I've missed that but you haven't responded to the question whether
> > the warn_lock actually resolves the problem you are seeing.
> 
> I haven't tried warn_lock, but is warn_lock in warn_alloc() better than
> serializing oom_lock in __alloc_pages_may_oom() ? I think we don't need to
> waste CPU cycles before the OOM killer sends SIGKILL.

Yes, I find a separate lock better because there is no real reason to
abuse an unrelated lock.

> > > I think this warn_alloc() is too much noise. When something went
> > > wrong, multiple instances of Thread-2 tend to call warn_alloc()
> > > concurrently. We don't need to report similar memory information.
> > 
> > That is why we have ratelimitting. It is needs a better tunning then
> > just let's do it.
> 
> I think that calling show_mem() once per a series of warn_alloc() threads is
> sufficient. Since the amount of output by dump_stack() and that by show_mem()
> are nearly equals, we can save nearly 50% of output if we manage to avoid
> the same show_mem() calls.

I do not mind such an update. Again, that is what we have the
ratelimitting for. The fact that it doesn't throttle properly means that
we should tune its parameters.

> > > > OK, so the reason of the lock up must be something different. If we are
> > > > really {dead,live}locking on the printk because of warn_alloc then that
> > > > path should be tweaked instead. Something like below should rule this
> > > > out:
> > > 
> > > Last year I proposed disabling preemption at
> > > http://lkml.kernel.org/r/201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp
> > > but it was not accepted. "while (1);" in userspace corresponds with
> > > pointless "direct reclaim and warn_alloc()" in kernel space. This time,
> > > I'm proposing serialization by oom_lock and replace warn_alloc() with kmallocwd
> > > in order to make printk() not to flood.
> > 
> > The way how you are trying to push your kmallocwd on any occasion is
> > quite annoying to be honest. If that approach would be so much better
> > than I am pretty sure you wouldn't have such a problem to have it
> > merged. warn_alloc is a simple and straightforward approach. If it can
> > cause floods of messages then we should tune it not replace by a big
> > hammer.
> 
> I wrote kmallocwd ( https://lkml.org/lkml/2016/11/6/7 )
> with the following precautions in mind.
> 

Skipping your points about kmallocwd which is (for the N+1th times) not
related to this thread and which belongs to the changelog of your
paatch.

[...]

> Maybe more, but no need to enumerate in this thread.
> How many of these precautions can be achieved by tuning warn_alloc() ?
> printk() tries to solve unbounded delay problem by using (I guess) a
> dedicated kernel thread. I don't think we can achieve these precautions
> without a centralized state tracking which can sleep and synchronize as
> needed.
> 
> Quite few people are responding to discussions regarding almost
> OOM situation. I beg for your joining to discussions.

I have already stated my position. I do not think that the code this
patch introduces is really justified for the advantages it provides over
a simple warn_alloc approach. Additional debugging information might be
nice but not necessary in 99% cases. If there are definciences in
warn_alloc (which I agree there are if there are thousands of contexts
hitting the path) then let's try to address them.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
