Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 36BE06B0083
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 07:29:10 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so1814076wiw.1
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 04:29:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bp14si34580732wib.111.2015.02.18.04.29.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 04:29:08 -0800 (PST)
Date: Wed, 18 Feb 2015 13:29:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150218122903.GD4478@dhcp22.suse.cz>
References: <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
 <20150217131618.GA14778@phnom.home.cmpxchg.org>
 <20150217165024.GI32017@dhcp22.suse.cz>
 <20150217232552.GK4251@dastard>
 <20150218084842.GB4478@dhcp22.suse.cz>
 <201502182023.EEJ12920.QFFMOVtOSJLHFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502182023.EEJ12920.QFFMOVtOSJLHFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

On Wed 18-02-15 20:23:19, Tetsuo Handa wrote:
> [ cc fsdevel list - watch out for side effect of 9879de7373fc (mm: page_alloc:
> embed OOM killing naturally into allocation slowpath) which was merged between
> 3.19-rc6 and 3.19-rc7 , started from
> http://marc.info/?l=linux-mm&m=142348457310066&w=2 ]
> 
> Replying in this post picked up from several posts in this thread.
> 
> Michal Hocko wrote:
> > Besides that __GFP_WAIT callers should be prepared for the allocation
> > failure and should better cope with it. So no, I really hate something
> > like the above.
> 
> Those who do not want to retry with invoking the OOM killer are using
> __GFP_WAIT + __GFP_NORETRY allocations.
> 
> Those who want to retry with invoking the OOM killer are using
> __GFP_WAIT allocations.
> 
> Those who must retry forever with invoking the OOM killer, no matter how
> many processes the OOM killer kills, are using __GFP_WAIT + __GFP_NOFAIL
> allocations.
> 
> However, since use of __GFP_NOFAIL is prohibited,

IT IS NOT PROHIBITED. It is highly discouraged because GFP_NOFAIL is a
strong requirement and the caller should be really aware of the
consequences. Especially when the allocation is done under locked
context.

> I think many of
> __GFP_WAIT users are expecting that the allocation fails only when
> "the OOM killer set TIF_MEMDIE flag to the caller but the caller
> failed to allocate from memory reserves".

This is not what __GFP_WAIT is defined for. It says that the allocator
might sleep.

> Also, the implementation
> before 9879de7373fc (mm: page_alloc: embed OOM killing naturally
> into allocation slowpath) effectively supported __GFP_WAIT users
> with such expectation.

same as GFP_KERNEL == GFP_NOFAIL for small allocations currently which
causes a lot of troubles which were not anticipated at the time this
was introduced. And we _should_ move away from that model. Because
GFP_NOFAIL should be really explicit rather than implicit.

> Michal Hocko wrote:
> > Because they cannot perform any IO/FS transactions and that would lead
> > to a premature OOM conditions way too easily. OOM killer is a _last
> > resort_ reclaim opportunity not something that would happen just because
> > you happen to be not able to flush dirty pages. 
> 
> But you should not have applied such change without making necessary
> changes to GFP_NOFS / GFP_NOIO users with such expectation and testing
> at linux-next.git . Applying such change after 3.19-rc6 is a sucker punch.

This is a nonsense. OOM was disbaled for !__GFP_FS for ages (since
before git era).
 
> Michal Hocko wrote:
> > Well, you are beating your machine to death so you can hardly get any
> > time guarantee. It would be nice to have a better feedback mechanism to
> > know when to back off and fail the allocation attempt which might be
> > blocking OOM victim to pass away. This is extremely tricky because we
> > shouldn't be too eager to fail just because of a sudden memory pressure.
> 
> Michal Hocko wrote:
> > >   I wish only somebody like kswapd repeats the loop on behalf of all
> > >   threads waiting at memory allocation slowpath...
> > 
> > This is the case when the kswapd is _able_ to cope with the memory
> > pressure.
> 
> It looks wasteful for me that so many threads (greater than number of
> available CPUs) are sleeping at cond_resched() in shrink_slab() when
> checking SysRq-t. Imagine 1000 threads sleeping at cond_resched() in
> shrink_slab() on a machine with only 1 CPU. Each thread gets a chance
> to try calling reclaim function only when all other threads gave that
> thread a chance at cond_resched(). Such situation is almost mutually
> preventing from making progress. I wish the following mechanism.

Feel free to send patches which are not breaking other loads...
[...]

> Michal Hocko wrote:
> > Failing __GFP_WAIT allocation is perfectly fine IMO. Why do you think
> > this is a problem?
> 
> Killing a user space process or taking filesystem error actions (e.g.
> remount-ro or kernel panic), which choice is less painful for users?
> I believe that !(gfp_mask & __GFP_FS) check is a bug and should be removed.

pre-mature OOM killer just because the current allocator context doesn't
allow for real reclaim is even worse.

> Rather, shouldn't allocations without __GFP_FS get more chance to succeed
> than allocations with __GFP_FS? If I were the author, I might have added
> below check instead.
> 
>    /* This is not a critical allocation. Don't invoke the OOM killer. */
>    if (gfp_mask & __GFP_FS)
>            goto out;

This doesn't make any sense what so ever. So regular GFP_KERNEL|USER
allocations wouldn't invoke oom killer. This includes page faults and
basically most of allocations.

> Falling into retry loop with same watermark might prevent rescuer threads from
> doing memory allocation which is needed for making free memory. Maybe we should
> use lower watermark for GFP_NOIO and below, middle watermark for GFP_NOFS, high
> watermark for GFP_KERNEL and above.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
