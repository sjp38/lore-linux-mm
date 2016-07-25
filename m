Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 622A36B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 04:32:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so111027992lfw.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 01:32:51 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t185si22936868wma.107.2016.07.25.01.32.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 01:32:49 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so15653123wma.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 01:32:49 -0700 (PDT)
Date: Mon, 25 Jul 2016 10:32:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE
 tasks
Message-ID: <20160725083247.GD9401@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-2-git-send-email-mhocko@kernel.org>
 <87oa5q5abi.fsf@notabene.neil.brown.name>
 <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878twt5i1j.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Sat 23-07-16 10:12:24, NeilBrown wrote:
> On Fri, Jul 22 2016, Michal Hocko wrote:
[...]
> >                          If we just back off and rely on kswapd which
> > might get stuck on the writeout then the IO throughput can be reduced
> 
> If I were king of MM, I would make a decree to be proclaimed throughout
> the land
>     kswapd must never sleep except when it explicitly chooses to
> 
> Maybe that is impractical, but having firm rules like that would go a
> long way to make it possible to actually understand and reason about how
> MM works.  As it is, there seems to be a tendency to put bandaids over
> bandaids.

Ohh, I would definitely wish for this to be more clear but as it turned
out over time there are quite some interdependencies between MM/FS/IO
layers which make the picture really blur. If there is a brave soul to
make that more clear without breaking any of that it would be really
cool ;)

> > I believe which would make the whole memory pressure just worse. So I am
> > not sure this is a good idea in general. I completely agree with you
> > that the mempool request shouldn't be throttled unless there is a strong
> > reason for that. More on that below.
> >
> >> If I'm following the code properly, the stack trace below can only
> >> happen if the first pool->alloc() attempt, with direct-reclaim disabled,
> >> fails and the pool is empty, so mempool_alloc() calls prepare_to_wait()
> >> and io_schedule_timeout().
> >
> > mempool_alloc retries immediatelly without any sleep after the first
> > no-reclaim attempt.
> 
> I missed that ... I see it now... I wonder if anyone has contemplated
> using some modern programming techniques like, maybe, a "while" loop in
> there..
> Something like the below...

Heh, why not, the code could definitely see some more love. Care to send
a proper patch so that we are not mixing two different things here.

> >> I suspect the timeout *doesn't* fire (5 seconds is along time) so it
> >> gets woken up when there is something in the pool.  It then loops around
> >> and tries pool->alloc() again, even though there is something in the
> >> pool.  This might be justified if that ->alloc would never block, but
> >> obviously it does.
> >> 
> >> I would very strongly recommend just changing mempool_alloc() to
> >> permanently mask out __GFP_DIRECT_RECLAIM.
> >> 
> >> Quite separately I don't think PF_LESS_THROTTLE is at all appropriate.
> >> It is "LESS" throttle, not "NO" throttle, but you have made
> >> throttle_vm_writeout never throttle PF_LESS_THROTTLE threads.
> >
> > Yes that is correct. But it still allows to throttle on congestion:
> > shrink_inactive_list:
> > 	/*
> > 	 * Stall direct reclaim for IO completions if underlying BDIs or zone
> > 	 * is congested. Allow kswapd to continue until it starts encountering
> > 	 * unqueued dirty pages or cycling through the LRU too quickly.
> > 	 */
> > 	if (!sc->hibernation_mode && !current_is_kswapd() &&
> > 	    current_may_throttle())
> > 		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
> >
> > My thinking was that throttle_vm_writeout is there to prevent from
> > dirtying too many pages from the reclaim the context.  PF_LESS_THROTTLE
> > is part of the writeout so throttling it on too many dirty pages is
> > questionable (well we get some bias but that is not really reliable). It
> > still makes sense to throttle when the backing device is congested
> > because the writeout path wouldn't make much progress anyway and we also
> > do not want to cycle through LRU lists too quickly in that case.
> 
> "dirtying ... from the reclaim context" ??? What does that mean?

Say you would cause a swapout from the reclaim context. You would
effectively dirty that anon page until it gets written down to the
storage.

> According to
>   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
> From the history tree, the purpose of throttle_vm_writeout() is to
> limit the amount of memory that is concurrently under I/O.
> That seems strange to me because I thought it was the responsibility of
> each backing device to impose a limit - a maximum queue size of some
> sort.

We do throttle on the congestion during the reclaim so in some
sense this is already implemented but I am not really sure that is
sufficient. Maybe this is something to re-evaluate because
wait_iff_congested came in much later after throttle_vm_writeout. Let me
think about it some more.

> I remember when NFS didn't impose a limit and you could end up with lots
> of memory in NFS write-back, and very long latencies could result.
> 
> So I wonder what throttle_vm_writeout() really achieves these days.  Is
> it just a bandaid that no-one is brave enough to remove?

Maybe yes. It is sitting there quietly and you do not know about it
until it bites. Like in this particular case.
 
> I guess it could play a role in balancing the freeing of clean pages,
> which can be done instantly, against dirty pages, which require
> writeback.  Without some throttling, might all clean pages being cleaned
> too quickly, just trashing our read caches?

I do not see how that would happen. kswapd has its reclaim targets
depending on watermarks and direct reclaim has SWAP_CLUSTER_MAX. So none
of them should go too wild and reclaim way too many clean pages.

> > Or is this assumption wrong for nfsd_vfs_write? Can it cause unbounded
> > dirtying of memory?
> 
> In most cases, nfsd it just like any other application and needs to be
> throttled like any other application when it writes too much data.
> The only time nfsd *needs* PF_LESS_THROTTLE when when a loop-back mount
> is active.  When the same page cache is the source and destination of
> writes.
> So nfsd needs to be able to dirty a few more pages when nothing else
> can due to high dirty count.  Otherwise it deadlocks.
> The main use of PF_LESS_THROTTLE is in zone_dirty_limit() and
> domain_dirty_limits() where an extra 25% is allowed to overcome this
> deadlock.
> 
> The use of PF_LESS_THROTTLE in current_may_throttle() in vmscan.c is to
> avoid a live-lock.  A key premise is that nfsd only allocates unbounded
> memory when it is writing to the page cache.  So it only needs to be
> throttled when the backing device it is writing to is congested.  It is
> particularly important that it *doesn't* get throttled just because an
> NFS backing device is congested, because nfsd might be trying to clear
> that congestion.

Thanks for the clarification. IIUC then removing throttle_vm_writeout
for the nfsd writeout should be harmless as well, right?

> In general, callers of try_to_free_pages() might get throttled when any
> backing device is congested.  This is a reasonable default when we don't
> know what they are allocating memory for.  When we do know the purpose of
> the allocation, we can be more cautious about throttling.
> 
> If a thread is allocating just to dirty pages for a given backing
> device, we only need to throttle the allocation if the backing device is
> congested.  Any further throttling needed happens in
> balance_dirty_pages().
> 
> If a thread is only making transient allocations, ones which will be
> freed shortly afterwards (not, for example, put in a cache), then I
> don't think it needs to be throttled at all.  I think this universally
> applies to mempools.
> In the case of dm_crypt, if it is writing too fast it will eventually be
> throttled in generic_make_request when the underlying device has a full
> queue and so blocks waiting for requests to be completed, and thus parts
> of them returned to the mempool.

Makes sense to me.

> >> The purpose of that flag is to allow a thread to dirty a page-cache page
> >> as part of cleaning another page-cache page.
> >> So it makes sense for loop and sometimes for nfsd.  It would make sense
> >> for dm-crypt if it was putting the encrypted version in the page cache.
> >> But if dm-crypt is just allocating a transient page (which I think it
> >> is), then a mempool should be sufficient (and we should make sure it is
> >> sufficient) and access to an extra 10% (or whatever) of the page cache
> >> isn't justified.
> >
> > If you think that PF_LESS_THROTTLE (ab)use in mempool_alloc is not
> > appropriate then would a PF_MEMPOOL be any better?
> 
> Why a PF rather than a GFP flag?

Well, short answer is that gfp masks are almost depleted.

> NFSD uses a PF because there is no GFP interface for filesystem write.
> But mempool can pass down a GFP flag, so I think it should.
> The meaning of the flag is, in my opinion, that a 'transient' allocation
> is being requested.  i.e. an allocation which will be used for a single
> purpose for a short amount of time and will then be freed.  In
> particularly it will never be placed in a cache, and if it is ever
> placed on a queue, that is certain to be a queue with an upper bound on
> the size and with guaranteed forward progress in the face of memory
> pressure.
> Any allocation request for a use case with those properties should be
> allowed to set GFP_TRANSIENT (for example) with the effect that the
> allocation will not be throttled.
> A key point with the name is to identify the purpose of the flag, not a
> specific use case (mempool) which we want it for.

Agreed. But let's first explore throttle_vm_writeout and its potential
removal.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
