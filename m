Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id AE3226B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 11:51:11 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so96961099wic.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 08:51:11 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id s12si4900152wik.40.2015.09.19.08.51.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 08:51:10 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so62907445wic.1
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 08:51:09 -0700 (PDT)
Date: Sat, 19 Sep 2015 17:51:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150919155108.GA9094@dhcp22.suse.cz>
References: <20150917192204.GA2728@redhat.com>
 <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
 <20150918162423.GA18136@redhat.com>
 <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
 <20150919083218.GD28815@dhcp22.suse.cz>
 <201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: cl@linux.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Sat 19-09-15 23:33:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > This has been posted in various forms many times over past years. I
> > still do not think this is a right approach of dealing with the problem.
> 
> I do not think "GFP_NOFS can fail" patch is a right approach because
> that patch easily causes messages like below.
> 
>   Buffer I/O error on dev sda1, logical block 34661831, lost async page write
>   XFS: possible memory allocation deadlock in kmem_alloc (mode:0x8250)
>   XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
>   XFS: possible memory allocation deadlock in kmem_zone_alloc (mode:0x8250)

These messages just tell you that the allocation fails repeatedly. Have
a look and check the code. They are basically opencoded NOFAIL
allocations. They haven't been converted to actually tell the MM layer
that they cannot fail because Dave said they have a long term plan to
change this code and basically implement different failing strategies.

> Adding __GFP_NOFAIL will hide these messages but OOM stall remains anyway.
> 
> I believe choosing more OOM victims is the only way which can solve OOM stalls.

I am very well aware of your position and all the attempts to tweak
different code paths to actually pass your corner case. I, however, care
for the longer term goals more. And I believe that the page allocator
and the reclaim should strive for being less deadlock prone in the
first place.  That includes a more natural semantic and non-failing
default semantic is really error prone IMHO. We have been through this
discussion many times already and I've tried to express this is a long
term goal with incremental steps.
I really hate to do "easy" things now just to feel better about
particular case which will kick us back little bit later. And from my
own experience I can tell you that a more non-deterministic OOM behavior
is thing people complain about.

> > You can quickly deplete memory reserves this way without making further
> > progress (I am afraid you can even trigger this from userspace without
> > having big privileges) so even administrator will have no way to
> > intervene.
> 
> I think that use of ALLOC_NO_WATERMARKS via TIF_MEMDIE is the underlying
> cause. ALLOC_NO_WATERMARKS via TIF_MEMDIE is intended for terminating the
> OOM victim task as soon as possible, but it turned out that it will not
> work if there is invisible lock dependency.

Of course. This is a heurstic and as such it cannot ever work in 100%
situations. And it is not the first heuristic we have for the OOM
killer. The last time this has been all rewritten was because the OOM
killer was too unreliable/non-deterministic. Reports have decreased
considerable since then.

> Therefore, why not to give up
> "there should be only up to 1 TIF_MEMDIE task" rule?

This has been explained several times. There is no guaranteed this would
help and _your_ own usecase shows how you can end up with such a long
lock dependency chains that you can easily eat up the whole memory
reserves before you can make any progress.

I do agree that a hand break mechanism is really desirable for those who
really care.

> What this patch (and many others posted in various forms many times over
> past years) does is to give up "there should be only up to 1 TIF_MEMDIE
> task" rule. I think that we need to tolerate more than 1 TIF_MEMDIE tasks
> and somehow manage in a way memory reserves will not deplete.

But those two goes against each other.

[...]

> If you still want to keep "there should be only up to 1 TIF_MEMDIE task"
> rule, what alternative do you have? (I do not like panic_on_oom_timeout
> because it is more data-lossy approach than choosing next OOM victim.)

I am not married to 1 TIF_MEMDIE task thing. I just think that there is
still a lot of room for other improvements. The original issue which
triggered this discussion again is a good example. I completely miss why
a writer has to be unkillable when the fs is frozen. There are others
which are more complicated of course. Including the whole class
represented by GFP_NOFS allocations as you have noted. But we still have
a room for improvements even in the reclaim. It has been suggested quite
some time ago that the memory mapped by the OOM victim might be
unmapped. Basically what Oleg is proposing in other email. I didn't get
to read his email yet properly but that should certainly help to reduce
the problem space.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
