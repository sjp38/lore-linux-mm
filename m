Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBDDB6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 07:12:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 144so117881588pfv.5
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 04:12:12 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c19si21138590pgk.317.2016.12.12.04.12.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 04:12:11 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161208132714.GA26530@dhcp22.suse.cz>
	<201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
	<20161209144624.GB4334@dhcp22.suse.cz>
	<201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
	<20161212090702.GD18163@dhcp22.suse.cz>
In-Reply-To: <20161212090702.GD18163@dhcp22.suse.cz>
Message-Id: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
Date: Mon, 12 Dec 2016 21:12:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

Michal Hocko wrote:
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index ed65d7df72d5..c2ba51cec93d 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -3024,11 +3024,14 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> > >  	unsigned int filter = SHOW_MEM_FILTER_NODES;
> > >  	struct va_format vaf;
> > >  	va_list args;
> > > +	static DEFINE_MUTEX(warn_lock);
> > >  
> > >  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
> > >  	    debug_guardpage_minorder() > 0)
> > >  		return;
> > >  
> > 
> > if (gfp_mask & __GFP_DIRECT_RECLAIM)
> 
> Why?

Because warn_alloc() is also called by !__GFP_DIRECT_RECLAIM allocation
requests when allocation failed. We are not allowed to sleep in that case.

> 
> > > +	mutex_lock(&warn_lock);
> > > +
> > >  	/*
> > >  	 * This documents exceptions given to allocations in certain
> > >  	 * contexts that are allowed to allocate outside current's set
> > > @@ -3054,6 +3057,8 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> > >  	dump_stack();
> > >  	if (!should_suppress_show_mem())
> > >  		show_mem(filter);
> > > +
> > 
> > if (gfp_mask & __GFP_DIRECT_RECLAIM)
> > 
> > > +	mutex_unlock(&warn_lock);
> > >  }
> > >  
> > >  static inline struct page *
> > 
> > and I think "s/warn_lock/oom_lock/" because out_of_memory() might
> > call show_mem() concurrently.
> 
> I would rather not mix the two. Even if both use show_mem then there is
> no reason to abuse the oom_lock.
> 
> Maybe I've missed that but you haven't responded to the question whether
> the warn_lock actually resolves the problem you are seeing.

I haven't tried warn_lock, but is warn_lock in warn_alloc() better than
serializing oom_lock in __alloc_pages_may_oom() ? I think we don't need to
waste CPU cycles before the OOM killer sends SIGKILL.

> 
> > I think this warn_alloc() is too much noise. When something went
> > wrong, multiple instances of Thread-2 tend to call warn_alloc()
> > concurrently. We don't need to report similar memory information.
> 
> That is why we have ratelimitting. It is needs a better tunning then
> just let's do it.

I think that calling show_mem() once per a series of warn_alloc() threads is
sufficient. Since the amount of output by dump_stack() and that by show_mem()
are nearly equals, we can save nearly 50% of output if we manage to avoid
the same show_mem() calls.

> > > OK, so the reason of the lock up must be something different. If we are
> > > really {dead,live}locking on the printk because of warn_alloc then that
> > > path should be tweaked instead. Something like below should rule this
> > > out:
> > 
> > Last year I proposed disabling preemption at
> > http://lkml.kernel.org/r/201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp
> > but it was not accepted. "while (1);" in userspace corresponds with
> > pointless "direct reclaim and warn_alloc()" in kernel space. This time,
> > I'm proposing serialization by oom_lock and replace warn_alloc() with kmallocwd
> > in order to make printk() not to flood.
> 
> The way how you are trying to push your kmallocwd on any occasion is
> quite annoying to be honest. If that approach would be so much better
> than I am pretty sure you wouldn't have such a problem to have it
> merged. warn_alloc is a simple and straightforward approach. If it can
> cause floods of messages then we should tune it not replace by a big
> hammer.

I wrote kmallocwd ( https://lkml.org/lkml/2016/11/6/7 )
with the following precautions in mind.

 (1) Can trigger even if the allocating tasks got stuck before reaching
     warn_alloc(), as shown by kswapd v.s. shrink_inactive_list() example.
     Will trigger even if new bugs are unexpectedly added in the future.

 (2) Do not printk() too much at once. There are enterprise servers which
     cannot print to serial console faster than 9600bps. By waiting as
     needed, we can reduce the risk of hitting stall warnings and dropping
     messages. Although currently there is no API which waits until
     specified amounts are printed to console, kmallocwd can call such API
     when such API is added.

 (3) Report memory information only once per a series of reports.
     Printing memory information for each thread generates too much
     output.

 (4) Report kswapd threads which might be relevant with memory allocation
     stalls.

 (5) Report workqueues status if debug is enabled, for in many cases
     workqueues being unable to make progress is observed when stalling.

 (6) Allow administrators to capture vmcore (i.e. panic if stall detected)
     without adding sysctl tunables for triggering panic, for administrators
     can install a trigger for calling panic() using SystemTap. One sysctl
     tunable that controls timeout if kmallocwd is enabled is enough.

 (7) Allow technical staff at support centers to analyze vmcore based on
     last minutes memory allocation behavior.

 (8) Allow kernel developers to implement and call functions such as
     /proc/*stat which are currently mostly available for only file
     interface.

Maybe more, but no need to enumerate in this thread.
How many of these precautions can be achieved by tuning warn_alloc() ?
printk() tries to solve unbounded delay problem by using (I guess) a
dedicated kernel thread. I don't think we can achieve these precautions
without a centralized state tracking which can sleep and synchronize as
needed.

Quite few people are responding to discussions regarding almost
OOM situation. I beg for your joining to discussions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
