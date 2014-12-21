Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EC4086B0032
	for <linux-mm@kvack.org>; Sun, 21 Dec 2014 15:42:55 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so4531356pdi.35
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 12:42:55 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id cg3si22459031pdb.231.2014.12.21.12.42.52
        for <linux-mm@kvack.org>;
        Sun, 21 Dec 2014 12:42:54 -0800 (PST)
Date: Mon, 22 Dec 2014 07:42:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141221204249.GL15665@dastard>
References: <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: dchinner@redhat.com, mhocko@suse.cz, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Sun, Dec 21, 2014 at 05:45:32PM +0900, Tetsuo Handa wrote:
> Thank you for detailed explanation.
> 
> Dave Chinner wrote:
> > So, going back to the lockup, doesn't hte fact that so many
> > processes are spinning in the shrinker tell you that there's a
> > problem in that area? i.e. this:
> > 
> > [  398.861602]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
> > [  398.863195]  [<ffffffff81122119>] shrink_slab+0x139/0x150
> > [  398.864799]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
> > 
> > tells me a shrinker is not making progress for some reason.  I'd
> > suggest that you run some tracing to find out what shrinker it is
> > stuck in. there are tracepoints in shrink_slab that will tell you
> > what shrinker is iterating for long periods of time. i.e instead of
> > ranting and pointing fingers at everyone, you need to keep digging
> > until you know exactly where reclaim progress is stalling.
> 
> I checked using below patch that shrink_slab() is called for many times but
> each call took 0 jiffies and freed 0 objects. I think shrink_slab() is merely
> reported since it likely works as a location for yielding CPU resource.

So we've got a situation where memory reclaim is not making
progress because there's nothing left to free, and everything is
backed up waiting for memory allocation to complete so that locks
can be released.


> Since trying to trigger the OOM killer means that memory reclaim subsystem
> has gave up, the memory reclaim subsystem had been unable to find
> reclaimable memory after PID=12718 got TIF_MEMDIE at 548 sec.
> Is this interpretation correct?

"memory reclaim gave up"? So why the hell isn't it returning a
failure to the caller?

i.e. We have a perfectly good page cache allocation failure error
path here all the way back to userspace, but we're invoking the
OOM-killer to kill random processes rather than returning ENOMEM to
the processes that are generating the memory demand?

Further: when did the oom-killer become the primary method
of handling situations when memory allocation needs to fail?
__GFP_WAIT does *not* mean memory allocation can't fail - that's what
__GFP_NOFAIL means. And none of the page cache allocations use
__GFP_NOFAIL, so why aren't we getting an allocation failure before
the oom-killer is kicked?

> I guess __alloc_pages_direct_reclaim() returns NULL with did_some_progress > 0
> so that __alloc_pages_may_oom() will not be called easily. As long as
> try_to_free_pages() returns non-zero, __alloc_pages_direct_reclaim() might
> return NULL with did_some_progress > 0. So, do_try_to_free_pages() is called
> for many times and is likely to return non-zero. And when
> __alloc_pages_may_oom() is called, TIF_MEMDIE is set on the thread waiting
> for mutex_lock(&"struct inode"->i_mutex) at xfs_file_buffered_aio_write()
> and I see no further progress.

Of course - TIF_MEMDIE doesn't do anything to the task that is
blocked, and the SIGKILL signal can't be delivered until the syscall
completes or the kernel code checks for pending signals and handles
EINTR directly. Mutexes are uninterruptible by design so there's no
EINTR processing, hence the oom killer cannot make progress when
everything is blocked on mutexes waiting for memory allocation to
succeed or fail.

i.e. until the lock holder exists from direct memory reclaim and
releases the locks it holds, the oom killer will not be able to save
the system. IOWs, the problem is that memory allocation is not
failing when it should....

Focussing on the OOM killer here is the wrong way to solve this
problem - the problem that needs to be solved is sane handling of
OOM conditions to avoid needing to invoke the OOM-killer...

> I don't know where to examine next. Would you please teach me command line
> for tracepoints to examine?

Tracepoints for what purpose?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
