Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id B4AE56B0081
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 07:16:06 -0500 (EST)
Received: by wevm14 with SMTP id m14so757581wev.8
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 04:16:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si34770425wja.117.2015.02.18.04.16.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 04:16:04 -0800 (PST)
Date: Wed, 18 Feb 2015 13:16:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150218121602.GC4478@dhcp22.suse.cz>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150218082502.GA4478@dhcp22.suse.cz>
 <20150218104859.GM12722@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150218104859.GM12722@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed 18-02-15 21:48:59, Dave Chinner wrote:
> On Wed, Feb 18, 2015 at 09:25:02AM +0100, Michal Hocko wrote:
> > On Wed 18-02-15 09:54:30, Dave Chinner wrote:
[...]
> Also, this reads as an excuse for the OOM killer being broken and
> not fixing it.  Keep in mind that we tell the memory alloc/reclaim
> subsystem that *we hold locks* when we call into it. That's what
> GFP_NOFS originally meant, and it's what it still means today in an
> XFS context.

Sure, and OOM killer will not be invoked in NOFS context. See
__alloc_pages_may_oom and __GFP_FS check in there. So I do not see where
is the OOM killer broken.

The crucial problem we are dealing with is not GFP_NOFAIL triggering the
OOM killer but a lock dependency introduced by the following sequence:

	taskA			taskB			taskC
lock(A)							alloc()
alloc(gfp | __GFP_NOFAIL)	lock(A)			  out_of_memory
# looping for ever if we				    select_bad_process
# cannot make any progress				      victim = taskB

There is no way OOM killer can tell taskB is blocked and that there is
dependency between A and B (without lockdep). That is why I call NOFAIL
under a lock as dangerous and a bug.

> If the OOM killer is not obeying GFP_NOFS and deadlocking on locks
> that the invoking context holds, then that is a OOM killer bug, not
> a bug in the subsystem calling kmalloc(GFP_NOFS).

I guess we are talking about different things here or what am I missing?
 
[...]
> > In the meantime page allocator
> > should develop a proper diagnostic to help identify all the potential
> > dependencies. Next we should start thinking whether all the existing
> > GFP_NOFAIL paths are really necessary or the code can be
> > refactored/reimplemented to accept allocation failures.
> 
> Last time the "just make filesystems handle memory allocation
> failures" I pointed out what that meant for XFS: dirty transaction
> rollback is required. That's freakin' complex, will double the
> memory footprint of transactions, roughly double the CPU cost, and
> greatly increase the complexity of the transaction subsystem. It's a
> *major* rework of a significant amount of the XFS codebase and will
> take at least a couple of years design, test and stabilise before
> it could be rolled out to production.
> 
> I'm not about to spend a couple of years rewriting XFS just so the
> VM can get rid of a GFP_NOFAIL user. Especially as the we already
> tell the Hammer of Last Resort the context in which it can work.
> 
> Move the OOM killer to kswapd - get it out of the direct reclaim
> path altogether.

This doesn't change anything as explained in other email. The triggering
path doesn't wait for the victim to die.

> If the system is that backed up on locks that it
> cannot free any memory and has no reserves to satisfy the allocation
> that kicked the OOM killer, then the OOM killer was not invoked soon
> enough.
> 
> Hell, if you want a better way to proceed, then how about you allow
> us to tell the MM subsystem how much memory reserve a specific set
> of operations is going to require to complete? That's something that
> we can do rough calculations for, and it integrates straight into
> the existing transaction reservation system we already use for log
> space and disk space, and we can tell the mm subsystem when the
> reserve is no longer needed (i.e. last thing in transaction commit).
> 
> That way we don't start a transaction until the mm subsystem has
> reserved enough pages for us to work with, and the reserve only
> needs to be used when normal allocation has already failed. i.e
> rather than looping we get a page allocated from the reserve pool.

I am not sure I understand the above but isn't the mempools a tool for
this purpose?
 
> The reservations wouldn't be perfect, but the majority of the time
> we'd be able to make progress and not need the OOM killer. And best
> of all, there's no responsibilty on the MM subsystem for preventing
> OOM - getting the reservations right is the responsibiity of the
> subsystem using them.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
