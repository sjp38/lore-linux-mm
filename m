Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5CC16B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 07:53:59 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j65so23962113iof.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 04:53:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t6si9253337itb.13.2016.12.08.04.53.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 04:53:58 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161201152517.27698-3-mhocko@kernel.org>
	<201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
	<20161205141009.GJ30758@dhcp22.suse.cz>
	<201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
	<20161206192242.GA10273@dhcp22.suse.cz>
In-Reply-To: <20161206192242.GA10273@dhcp22.suse.cz>
Message-Id: <201612082153.BHC81241.VtMFFHOLJOOFSQ@I-love.SAKURA.ne.jp>
Date: Thu, 8 Dec 2016 21:53:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 06-12-16 19:38:38, Tetsuo Handa wrote:
> > You are trying to increase possible locations of lockups by changing
> > default behavior of __GFP_NOFAIL.
> 
> I disagree. I have tried to explain that it is much more important to
> have fewer silent side effects than optimize for the very worst case.  I
> simply do not see __GFP_NOFAIL lockups so common to even care or tweak
> their semantic in a weird way. It seems you prefer to optimize for the
> absolute worst case and even for that case you cannot offer anything
> better than randomly OOM killing random processes until the system
> somehow resurrects or panics. I consider this a very bad design. So
> let's agree to disagree here.

You think that invoking the OOM killer with __GFP_NOFAIL is worse than
locking up with __GFP_NOFAIL. But I think that locking up with __GFP_NOFAIL
is worse than invoking the OOM killer with __GFP_NOFAIL. If we could agree
with calling __alloc_pages_nowmark() before out_of_memory() if __GFP_NOFAIL
is given, we can avoid locking up while minimizing possibility of invoking
the OOM killer...

I suggest "when you change something, ask users who are affected by
your change" because patch 2 has values-based conflict.

> > "[PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath"
> > silently changes __GFP_NOFAIL vs. __GFP_NORETRY priority.
> > 
> > Currently, __GFP_NORETRY is stronger than __GFP_NOFAIL; __GFP_NOFAIL
> > allocation requests fail without invoking the OOM killer when both
> > __GFP_NORETRY and __GFP_NOFAIL are given.
> 
> Sigh... __GFP_NORETRY | __GFP_NOFAIL _doesn't_ make _any_ sense what so
> ever.
> 
> > With [PATCH 1/2], __GFP_NOFAIL becomes stronger than __GFP_NORETRY;
> > __GFP_NOFAIL allocation requests will loop forever without invoking
> > the OOM killer when both __GFP_NORETRY and __GFP_NOFAIL are given.
> 
> So what? Strictly speaking __GFP_NOFAIL should be always stronger but I
> really fail to see why we should even consider __GFP_NORETRY in that
> context. I definitely do not want to complicate the page fault path for
> a nonsense combination of flags.
> 
> > Those callers which prefer lockup over panic can specify both
> > __GFP_NORETRY and __GFP_NOFAIL.
> 
> No! This combination just doesn't make any sense. The same way how
> __GFP_REPEAT | GFP_NOWAIT or __GFP_REPEAT | __GFP_NORETRY make no sense
> as well. Please use a common sense!

I wonder why I'm accused so much. I mentioned that patch 2 might be a
garbage because patch 1 alone unexpectedly provided a mean to retry forever
without invoking the OOM killer. You are not describing that fact in the
description. You are not describing what combinations are valid and
which flag is stronger requirement in gfp.h (e.g. __GFP_NOFAIL v.s.
__GFP_NORETRY).

> Invoking or not invoking the oom killer is the page allocator internal
> business. No code outside of the MM is to talk about those decisions.
> The fact that we provide a lightweight allocation mode which doesn't
> invoke the OOM killer is a mere implementation detail.

__GFP_NOFAIL allocation requests for e.g. fs writeback is considered as
code inside the MM because they are operations for reclaiming memory.
Such __GFP_NOFAIL allocation requests should be given a chance to choose
which one (possibility of lockup by not invoking the OOM killer or
possibility of panic by invoking the OOM killer) they prefer.

Therefore,

> If you believe that my argumentation is incorrect then you are free to
> nak the patch with your reasoning. But please stop this nit picking on
> nonsense combination of flags.

Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

on patch 2 unless "you explain these patches to __GFP_NOFAIL users and
provide a mean to invoke the OOM killer if someone chose possibility of
panic" or "you accept kmallocwd".

> > > Full stop. There is no guaranteed way to make a forward progress with
> > > the current page allocator implementation.
> > 
> > Then, will you accept kmallocwd until page allocator implementation
> > can provide a guaranteed way to make a forward progress?
> 
> No, I find your kmallocwd too complex for the advantage it provides.

My kmallocwd provides us two advantages.

One is that, if the cause of lockup is not memory allocation request,
kmallocwd gives us a proof that you are doing well. You seriously tend to
ignore corner cases with your wish that the absolute worst case won't
happen; that makes me seriously explorer corner cases as a secure coder
for proactive protection; that irritates you further.
You say that I constantly push to the extreme with very strong statements
without any actual data point, but I say that you constantly reject
without any proof just because you have never heard. The reality is that
we can hardly expect people to have knowledge/skills for reporting corner
cases.

The other is that, synchronous mechanism (like warn_alloc()) is prone to
corner cases. We won't be able to catch all corner cases before people
are trapped by them. If the cause of lockup is memory allocation request,
kmallocwd gives us a trigger to take actions. This keeps me away from
exploring corner cases which you think unlikely happen. This helps you
to choose whatever semantic/logic you prefer.

Since I'm not a __GFP_NOFAIL user, I don't care as long as lockups are
detected and reported using a catch-all approach (i.e. asynchronous
mechanism). Instead of cruelly rejecting kmallocwd with "too complex",
will you explain why you feel complex (as a reply to kmallocwd thread)?
I have my goal for written as such, but there would be room for reducing
complexity if you explain details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
