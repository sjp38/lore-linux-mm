Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0265F6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:55:22 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so27182539wgy.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 05:55:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e10si43671072wjq.166.2015.04.29.05.55.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 05:55:20 -0700 (PDT)
Date: Wed, 29 Apr 2015 08:55:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
Message-ID: <20150429125506.GB7148@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
 <201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
 <20150428135535.GE2659@dhcp22.suse.cz>
 <201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, aarcange@redhat.com, david@fromorbit.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 29, 2015 at 12:50:37AM +0900, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 28-04-15 19:34:47, Tetsuo Handa wrote:
> > [...]
> > > [PATCH 8/9] makes the speed of allocating __GFP_FS pages extremely slow (5
> > > seconds / page) because out_of_memory() serialized by the oom_lock sleeps for
> > > 5 seconds before returning true when the OOM victim got stuck. This throttling
> > > also slows down !__GFP_FS allocations when there is a thread doing a __GFP_FS
> > > allocation, for __alloc_pages_may_oom() is serialized by the oom_lock
> > > regardless of gfp_mask.
> > 
> > This is indeed unnecessary.
> > 
> > > How long will the OOM victim is blocked when the
> > > allocating task needs to allocate e.g. 1000 !__GFP_FS pages before allowing
> > > the OOM victim waiting at mutex_lock(&inode->i_mutex) to continue? It will be
> > > a too-long-to-wait stall which is effectively a deadlock for users. I think
> > > we should not sleep with the oom_lock held.
> > 
> > I do not see why sleeping with oom_lock would be a problem. It simply
> > doesn't make much sense to try to trigger OOM killer when there is/are
> > OOM victims still exiting.
> 
> Because thread A's memory allocation is deferred by threads B, C, D...'s memory
> allocation which are holding (or waiting for) the oom_lock when the OOM victim
> is waiting for thread A's allocation. I think that a memory allocator which
> allocates at average 5 seconds is considered as unusable. If we sleep without
> the oom_lock held, the memory allocator can allocate at average
> (5 / number_of_allocating_threads) seconds. Sleeping with the oom_lock held
> can effectively prevent thread A from making progress.

I agree with that.  The problem with the sleeping is that it has to be
long enough to give the OOM victim a fair chance to exit, but short
enough to not make the page allocator unusable in case there is a
genuine deadlock.  And you are right, the context blocking the OOM
victim from exiting might do a whole string of allocations, not just
one, before releasing any locks.

What we can do to mitigate this is tie the timeout to the setting of
TIF_MEMDIE so that the wait is not 5s from the point of calling
out_of_memory() but from the point of where TIF_MEMDIE was set.
Subsequent allocations will then go straight to the reserves.

> > >   (2) oom_kill_process() can determine when to kill next OOM victim.
> > > 
> > >   (3) oom_scan_process_thread() can take TIF_MEMDIE timeout into
> > >       account when choosing an OOM victim.
> > 
> > You have heard my opinions about this and I do not plan to repeat them
> > here again.
> 
> Yes, I've heard your opinions. But neither ALLOC_NO_WATERMARKS nor WMARK_OOM
> is a perfect measure for avoiding deadlock. We want to solve "Without any
> extra measures the above situation will result in a deadlock" problem.
> When WMARK_OOM failed to avoid the deadlock, and we don't want to go to
> ALLOC_NO_WATERMARKS, I think somehow choosing and killing more victims is
> the only possible measure. Maybe choosing next OOM victim upon reaching
> WMARK_OOM?

I also think that the argument against moving on to the next victim is
completely missing the tradeoff we are making here.  When the victim
is stuck and we run out of memory reserves, the machine *deadlocks*
while there are still tasks that might be able to release memory.
It's irresponsible not to go after them.  Why *shouldn't* we try?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
