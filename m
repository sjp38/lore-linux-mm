Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id C7E886B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 05:21:52 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id l15so15587280wiw.5
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 02:21:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si60747409wjx.203.2015.02.23.02.21.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 02:21:50 -0800 (PST)
Date: Mon, 23 Feb 2015 11:21:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: __GFP_NOFAIL and oom_killer_disabled?
Message-ID: <20150223102147.GB24272@dhcp22.suse.cz>
References: <20150219225217.GY12722@dastard>
 <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
 <20150220231511.GH12722@dastard>
 <20150221032000.GC7922@thunk.org>
 <20150221011907.2d26c979.akpm@linux-foundation.org>
 <201502222348.GFH13009.LOHOMFVtFQSFOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502222348.GFH13009.LOHOMFVtFQSFOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

On Sun 22-02-15 23:48:01, Tetsuo Handa wrote:
> Andrew Morton wrote:
> > And yes, I agree that sites such as xfs's kmem_alloc() should be
> > passing __GFP_NOFAIL to tell the page allocator what's going on.  I
> > don't think it matters a lot whether kmem_alloc() retains its retry
> > loop.  If __GFP_NOFAIL is working correctly then it will never loop
> > anyway...
> 
> __GFP_NOFAIL fails to work correctly if oom_killer_disabled == true.
> I'm wondering how oom_killer_disable() interferes with __GFP_NOFAIL
> allocation. We had race check after setting oom_killer_disabled to true
> in 3.19.
[...]
> I worry that commit c32b3cbe0d067a9c "oom, PM: make OOM detection in
> the freezer path raceless" might have opened a race window for
> __alloc_pages_may_oom(__GFP_NOFAIL) allocation to fail when OOM killer
> is disabled.

This commit hasn't introduced any behavior changes. GFP_NOFAIL
allocations fail when OOM killer is disabled since beginning
7f33d49a2ed5 (mm, PM/Freezer: Disable OOM killer when tasks are frozen).

> I think something like
> 
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -789,7 +789,7 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	bool ret = false;
>  
>  	down_read(&oom_sem);
> -	if (!oom_killer_disabled) {
> +	if (!oom_killer_disabled || (gfp_mask & __GFP_NOFAIL)) {
>  		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
>  		ret = true;
>  	}
> 
> is needed.

> But such change can race with up_write() and wait_event() in
> oom_killer_disable(). 

Not only it races with the above but also breaks the core assumption
that no userspace task might interact with later stages of the suspend.

> While the comment of oom_killer_disable() says
> "The function cannot be called when there are runnable user tasks because
> the userspace would see unexpected allocation failures as a result.",
> aren't there still kernel threads which might do __GFP_NOFAIL allocations?

OK, this is a fair point. My assumption was that kernel threads rarely
do __GFP_NOFAIL allocations. It seems I was wrong here. This makes the
logic much more trickier. I can see 3 possible ways to handle this:

1) move oom_killer_disable after kernel threads are frozen. This has a
   risk that the OOM victim wouldn't be able to finish because it would
   depend on an already frozen kernel thread. This would be really
   tricky to debug.
2) do not fail GFP_NOFAIL allocation no matter what and risk a potential
   (and silent) endless loop during suspend. On the other hand the
   chances that __GFP_NOFAIL comes from a freezable kernel thread rather
   than from deep pm suspend path is considerably higher.
   So now that I am thinking about that it indeed makes more sense to
   simply warn when OOM is disabled and retry the allocation. Freezable
   kernel threads will loop and fail the suspend. Incidental allocations
   after kernel threads are frozen will at least dump a warning - if we
   are lucky and the serial console is still active of course...
3) do nothing ;)

But whatever we do there is simply no way to guarantee __GFP_NOFAIL
after OOM killer has been disabled. So we are risking between endless
loops and possible crashes due to unexpected allocation failures. Not a
nice choice. We can only chose the less risky way and it sounds like 2)
is that option. Considering that we haven't seen any crashes with the
current behavior I would be tempted to simply declare this a corner case
which doesn't need any action but well, I hate to debug nasty issues so
better be prepared...

What about something like the following?
---
