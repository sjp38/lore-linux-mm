Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD66F6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 08:47:21 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so6353410wmd.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 05:47:21 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id i189si13327004wmi.6.2016.12.08.05.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 05:47:20 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so3681023wmu.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 05:47:20 -0800 (PST)
Date: Thu, 8 Dec 2016 14:47:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161208134718.GC26530@dhcp22.suse.cz>
References: <20161201152517.27698-3-mhocko@kernel.org>
 <201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
 <20161205141009.GJ30758@dhcp22.suse.cz>
 <201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
 <20161206192242.GA10273@dhcp22.suse.cz>
 <201612082153.BHC81241.VtMFFHOLJOOFSQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612082153.BHC81241.VtMFFHOLJOOFSQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 08-12-16 21:53:44, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 06-12-16 19:38:38, Tetsuo Handa wrote:
> > > You are trying to increase possible locations of lockups by changing
> > > default behavior of __GFP_NOFAIL.
> > 
> > I disagree. I have tried to explain that it is much more important to
> > have fewer silent side effects than optimize for the very worst case.  I
> > simply do not see __GFP_NOFAIL lockups so common to even care or tweak
> > their semantic in a weird way. It seems you prefer to optimize for the
> > absolute worst case and even for that case you cannot offer anything
> > better than randomly OOM killing random processes until the system
> > somehow resurrects or panics. I consider this a very bad design. So
> > let's agree to disagree here.
> 
> You think that invoking the OOM killer with __GFP_NOFAIL is worse than
> locking up with __GFP_NOFAIL.

Yes and I have explained why.

> But I think that locking up with __GFP_NOFAIL
> is worse than invoking the OOM killer with __GFP_NOFAIL.

Without any actual arguments based just on handwaving.

> If we could agree
> with calling __alloc_pages_nowmark() before out_of_memory() if __GFP_NOFAIL
> is given, we can avoid locking up while minimizing possibility of invoking
> the OOM killer...

I do not understand. We do __alloc_pages_nowmark even when oom is called
for GFP_NOFAIL.

> I suggest "when you change something, ask users who are affected by
> your change" because patch 2 has values-based conflict.
> 
[...]
> > > Those callers which prefer lockup over panic can specify both
> > > __GFP_NORETRY and __GFP_NOFAIL.
> > 
> > No! This combination just doesn't make any sense. The same way how
> > __GFP_REPEAT | GFP_NOWAIT or __GFP_REPEAT | __GFP_NORETRY make no sense
> > as well. Please use a common sense!
> 
> I wonder why I'm accused so much. I mentioned that patch 2 might be a
> garbage because patch 1 alone unexpectedly provided a mean to retry forever
> without invoking the OOM killer.

Which is the whole point of the patch and the changelog is vocal about
that. Even explaining why it is desirable to not override decisions when
the oom killer is not invoked. Please reread that and object if the
argument is not correct.

> You are not describing that fact in the
> description. You are not describing what combinations are valid and
> which flag is stronger requirement in gfp.h (e.g. __GFP_NOFAIL v.s.
> __GFP_NORETRY).

Sigh... I really fail to see why I should describe an impossible gfp
mask combination which is _not_ used in the kernel. Please stop this
strawman, I am really tired of it.
 
> > Invoking or not invoking the oom killer is the page allocator internal
> > business. No code outside of the MM is to talk about those decisions.
> > The fact that we provide a lightweight allocation mode which doesn't
> > invoke the OOM killer is a mere implementation detail.
> 
> __GFP_NOFAIL allocation requests for e.g. fs writeback is considered as
> code inside the MM because they are operations for reclaiming memory.
> Such __GFP_NOFAIL allocation requests should be given a chance to choose
> which one (possibility of lockup by not invoking the OOM killer or
> possibility of panic by invoking the OOM killer) they prefer.

Please be more specific. How and why they should choose that. Which
allocation are we talking about and why do you believe that the current
implementation with access to memory reserves is not sufficient.

> Therefore,
> 
> > If you believe that my argumentation is incorrect then you are free to
> > nak the patch with your reasoning. But please stop this nit picking on
> > nonsense combination of flags.
> 
> Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> on patch 2 unless "you explain these patches to __GFP_NOFAIL users and
> provide a mean to invoke the OOM killer if someone chose possibility of
> panic"

I believe that the changelog contains my reasonining and so far I
haven't heard any _argument_ from you why they are wrong. You just
managed to nitpick on an impossible and pointless gfp_mask combination
and some handwaving on possible lockups without any backing arguments.
This is not something I would consider as a basis for a serious nack. So
if you really hate this patch then do please start being reasonable and
put some real arguments into your review without any off topics and/or
strawman arguments without any relevance.

> or "you accept kmallocwd".

Are you serious? Are you really suggesting that your patch has to be
accepted in order to have this one in?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
