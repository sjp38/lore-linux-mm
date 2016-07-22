Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6DA06B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:16:02 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so68683235lfw.1
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 02:16:02 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id s70si9087352wme.140.2016.07.22.02.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 02:16:01 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id x83so5324794wma.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 02:16:01 -0700 (PDT)
Date: Fri, 22 Jul 2016 11:15:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE
 tasks
Message-ID: <20160722091558.GF794@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-2-git-send-email-mhocko@kernel.org>
 <87oa5q5abi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87oa5q5abi.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Fri 22-07-16 18:46:57, Neil Brown wrote:
> On Mon, Jul 18 2016, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> >
> > Mikulas has reported that a swap backed by dm-crypt doesn't work
> > properly because the swapout cannot make a sufficient forward progress
> > as the writeout path depends on dm_crypt worker which has to allocate
> > memory to perform the encryption. In order to guarantee a forward
> > progress it relies on the mempool allocator. mempool_alloc(), however,
> > prefers to use the underlying (usually page) allocator before it grabs
> > objects from the pool. Such an allocation can dive into the memory
> > reclaim and consequently to throttle_vm_writeout.
> 
> That's just broken.
> I used to think mempool should always use the pre-allocated reserves
> first.  That is surely the most logical course of action.  Otherwise
> that memory is just sitting there doing nothing useful.
> 
> I spoke to Nick Piggin about this some years ago and he pointed out that
> the kmalloc allocation paths are much better optimized for low overhead
> when there is plenty of memory.  They can just pluck a free block of a
> per-CPU list without taking any locks.   By contrast, accessing the
> preallocated pool always requires a spinlock.
> 
> So it makes lots of sense to prefer the underlying allocator if it can
> provide a quick response.  If it cannot, the sensible thing is to use
> the pool, or wait for the pool to be replenished.
> 
> So the allocator should never wait at all, never enter reclaim, never
> throttle.
> 
> Looking at the current code, __GFP_DIRECT_RECLAIM is disabled the first
> time through, but if the pool is empty, direct-reclaim is allowed on the
> next attempt.  Presumably this is where the throttling comes in ??

Yes that is correct.

> I suspect that it really shouldn't do that. It should leave kswapd to
> do reclaim (so __GFP_KSWAPD_RECLAIM is appropriate) and only wait in
> mempool_alloc where pool->wait can wake it up.

Mikulas was already suggesting that and my concern was that this would
give up prematurely even under mild page cache load when there are many
clean page cache pages. If we just back off and rely on kswapd which
might get stuck on the writeout then the IO throughput can be reduced
I believe which would make the whole memory pressure just worse. So I am
not sure this is a good idea in general. I completely agree with you
that the mempool request shouldn't be throttled unless there is a strong
reason for that. More on that below.

> If I'm following the code properly, the stack trace below can only
> happen if the first pool->alloc() attempt, with direct-reclaim disabled,
> fails and the pool is empty, so mempool_alloc() calls prepare_to_wait()
> and io_schedule_timeout().

mempool_alloc retries immediatelly without any sleep after the first
no-reclaim attempt.

> I suspect the timeout *doesn't* fire (5 seconds is along time) so it
> gets woken up when there is something in the pool.  It then loops around
> and tries pool->alloc() again, even though there is something in the
> pool.  This might be justified if that ->alloc would never block, but
> obviously it does.
> 
> I would very strongly recommend just changing mempool_alloc() to
> permanently mask out __GFP_DIRECT_RECLAIM.
> 
> Quite separately I don't think PF_LESS_THROTTLE is at all appropriate.
> It is "LESS" throttle, not "NO" throttle, but you have made
> throttle_vm_writeout never throttle PF_LESS_THROTTLE threads.

Yes that is correct. But it still allows to throttle on congestion:
shrink_inactive_list:
	/*
	 * Stall direct reclaim for IO completions if underlying BDIs or zone
	 * is congested. Allow kswapd to continue until it starts encountering
	 * unqueued dirty pages or cycling through the LRU too quickly.
	 */
	if (!sc->hibernation_mode && !current_is_kswapd() &&
	    current_may_throttle())
		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);

My thinking was that throttle_vm_writeout is there to prevent from
dirtying too many pages from the reclaim the context.  PF_LESS_THROTTLE
is part of the writeout so throttling it on too many dirty pages is
questionable (well we get some bias but that is not really reliable). It
still makes sense to throttle when the backing device is congested
because the writeout path wouldn't make much progress anyway and we also
do not want to cycle through LRU lists too quickly in that case.

Or is this assumption wrong for nfsd_vfs_write? Can it cause unbounded
dirtying of memory?

> The purpose of that flag is to allow a thread to dirty a page-cache page
> as part of cleaning another page-cache page.
> So it makes sense for loop and sometimes for nfsd.  It would make sense
> for dm-crypt if it was putting the encrypted version in the page cache.
> But if dm-crypt is just allocating a transient page (which I think it
> is), then a mempool should be sufficient (and we should make sure it is
> sufficient) and access to an extra 10% (or whatever) of the page cache
> isn't justified.

If you think that PF_LESS_THROTTLE (ab)use in mempool_alloc is not
appropriate then would a PF_MEMPOOL be any better?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
