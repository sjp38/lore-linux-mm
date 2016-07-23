Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C51286B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 20:12:37 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so82908806lfi.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 17:12:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q190si12442980wmg.17.2016.07.22.17.12.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 17:12:36 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Sat, 23 Jul 2016 10:12:24 +1000
Subject: Re: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE tasks
In-Reply-To: <20160722091558.GF794@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz>
Message-ID: <878twt5i1j.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 22 2016, Michal Hocko wrote:

> On Fri 22-07-16 18:46:57, Neil Brown wrote:
>> On Mon, Jul 18 2016, Michal Hocko wrote:
>>=20
>> > From: Michal Hocko <mhocko@suse.com>
>> >
>> > Mikulas has reported that a swap backed by dm-crypt doesn't work
>> > properly because the swapout cannot make a sufficient forward progress
>> > as the writeout path depends on dm_crypt worker which has to allocate
>> > memory to perform the encryption. In order to guarantee a forward
>> > progress it relies on the mempool allocator. mempool_alloc(), however,
>> > prefers to use the underlying (usually page) allocator before it grabs
>> > objects from the pool. Such an allocation can dive into the memory
>> > reclaim and consequently to throttle_vm_writeout.
>>=20
>> That's just broken.
>> I used to think mempool should always use the pre-allocated reserves
>> first.  That is surely the most logical course of action.  Otherwise
>> that memory is just sitting there doing nothing useful.
>>=20
>> I spoke to Nick Piggin about this some years ago and he pointed out that
>> the kmalloc allocation paths are much better optimized for low overhead
>> when there is plenty of memory.  They can just pluck a free block of a
>> per-CPU list without taking any locks.   By contrast, accessing the
>> preallocated pool always requires a spinlock.
>>=20
>> So it makes lots of sense to prefer the underlying allocator if it can
>> provide a quick response.  If it cannot, the sensible thing is to use
>> the pool, or wait for the pool to be replenished.
>>=20
>> So the allocator should never wait at all, never enter reclaim, never
>> throttle.
>>=20
>> Looking at the current code, __GFP_DIRECT_RECLAIM is disabled the first
>> time through, but if the pool is empty, direct-reclaim is allowed on the
>> next attempt.  Presumably this is where the throttling comes in ??
>
> Yes that is correct.
>
>> I suspect that it really shouldn't do that. It should leave kswapd to
>> do reclaim (so __GFP_KSWAPD_RECLAIM is appropriate) and only wait in
>> mempool_alloc where pool->wait can wake it up.
>
> Mikulas was already suggesting that and my concern was that this would
> give up prematurely even under mild page cache load when there are many
> clean page cache pages.

That's a valid point - freeing up clean pages is a reasonable thing for
a mempool allocator to try to do.

>                          If we just back off and rely on kswapd which
> might get stuck on the writeout then the IO throughput can be reduced

If I were king of MM, I would make a decree to be proclaimed throughout
the land
    kswapd must never sleep except when it explicitly chooses to

Maybe that is impractical, but having firm rules like that would go a
long way to make it possible to actually understand and reason about how
MM works.  As it is, there seems to be a tendency to put bandaids over
bandaids.

> I believe which would make the whole memory pressure just worse. So I am
> not sure this is a good idea in general. I completely agree with you
> that the mempool request shouldn't be throttled unless there is a strong
> reason for that. More on that below.
>
>> If I'm following the code properly, the stack trace below can only
>> happen if the first pool->alloc() attempt, with direct-reclaim disabled,
>> fails and the pool is empty, so mempool_alloc() calls prepare_to_wait()
>> and io_schedule_timeout().
>
> mempool_alloc retries immediatelly without any sleep after the first
> no-reclaim attempt.

I missed that ... I see it now... I wonder if anyone has contemplated
using some modern programming techniques like, maybe, a "while" loop in
there..
Something like the below...

>
>> I suspect the timeout *doesn't* fire (5 seconds is along time) so it
>> gets woken up when there is something in the pool.  It then loops around
>> and tries pool->alloc() again, even though there is something in the
>> pool.  This might be justified if that ->alloc would never block, but
>> obviously it does.
>>=20
>> I would very strongly recommend just changing mempool_alloc() to
>> permanently mask out __GFP_DIRECT_RECLAIM.
>>=20
>> Quite separately I don't think PF_LESS_THROTTLE is at all appropriate.
>> It is "LESS" throttle, not "NO" throttle, but you have made
>> throttle_vm_writeout never throttle PF_LESS_THROTTLE threads.
>
> Yes that is correct. But it still allows to throttle on congestion:
> shrink_inactive_list:
> 	/*
> 	 * Stall direct reclaim for IO completions if underlying BDIs or zone
> 	 * is congested. Allow kswapd to continue until it starts encountering
> 	 * unqueued dirty pages or cycling through the LRU too quickly.
> 	 */
> 	if (!sc->hibernation_mode && !current_is_kswapd() &&
> 	    current_may_throttle())
> 		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
>
> My thinking was that throttle_vm_writeout is there to prevent from
> dirtying too many pages from the reclaim the context.  PF_LESS_THROTTLE
> is part of the writeout so throttling it on too many dirty pages is
> questionable (well we get some bias but that is not really reliable). It
> still makes sense to throttle when the backing device is congested
> because the writeout path wouldn't make much progress anyway and we also
> do not want to cycle through LRU lists too quickly in that case.

"dirtying ... from the reclaim context" ??? What does that mean?
According to
  Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
From=20the history tree, the purpose of throttle_vm_writeout() is to
limit the amount of memory that is concurrently under I/O.
That seems strange to me because I thought it was the responsibility of
each backing device to impose a limit - a maximum queue size of some
sort.
I remember when NFS didn't impose a limit and you could end up with lots
of memory in NFS write-back, and very long latencies could result.

So I wonder what throttle_vm_writeout() really achieves these days.  Is
it just a bandaid that no-one is brave enough to remove?

I guess it could play a role in balancing the freeing of clean pages,
which can be done instantly, against dirty pages, which require
writeback.  Without some throttling, might all clean pages being cleaned
too quickly, just trashing our read caches?

>
> Or is this assumption wrong for nfsd_vfs_write? Can it cause unbounded
> dirtying of memory?

In most cases, nfsd it just like any other application and needs to be
throttled like any other application when it writes too much data.
The only time nfsd *needs* PF_LESS_THROTTLE when when a loop-back mount
is active.  When the same page cache is the source and destination of
writes.
So nfsd needs to be able to dirty a few more pages when nothing else
can due to high dirty count.  Otherwise it deadlocks.
The main use of PF_LESS_THROTTLE is in zone_dirty_limit() and
domain_dirty_limits() where an extra 25% is allowed to overcome this
deadlock.

The use of PF_LESS_THROTTLE in current_may_throttle() in vmscan.c is to
avoid a live-lock.  A key premise is that nfsd only allocates unbounded
memory when it is writing to the page cache.  So it only needs to be
throttled when the backing device it is writing to is congested.  It is
particularly important that it *doesn't* get throttled just because an
NFS backing device is congested, because nfsd might be trying to clear
that congestion.

In general, callers of try_to_free_pages() might get throttled when any
backing device is congested.  This is a reasonable default when we don't
know what they are allocating memory for.  When we do know the purpose of
the allocation, we can be more cautious about throttling.

If a thread is allocating just to dirty pages for a given backing
device, we only need to throttle the allocation if the backing device is
congested.  Any further throttling needed happens in
balance_dirty_pages().

If a thread is only making transient allocations, ones which will be
freed shortly afterwards (not, for example, put in a cache), then I
don't think it needs to be throttled at all.  I think this universally
applies to mempools.
In the case of dm_crypt, if it is writing too fast it will eventually be
throttled in generic_make_request when the underlying device has a full
queue and so blocks waiting for requests to be completed, and thus parts
of them returned to the mempool.


>
>> The purpose of that flag is to allow a thread to dirty a page-cache page
>> as part of cleaning another page-cache page.
>> So it makes sense for loop and sometimes for nfsd.  It would make sense
>> for dm-crypt if it was putting the encrypted version in the page cache.
>> But if dm-crypt is just allocating a transient page (which I think it
>> is), then a mempool should be sufficient (and we should make sure it is
>> sufficient) and access to an extra 10% (or whatever) of the page cache
>> isn't justified.
>
> If you think that PF_LESS_THROTTLE (ab)use in mempool_alloc is not
> appropriate then would a PF_MEMPOOL be any better?

Why a PF rather than a GFP flag?
NFSD uses a PF because there is no GFP interface for filesystem write.
But mempool can pass down a GFP flag, so I think it should.
The meaning of the flag is, in my opinion, that a 'transient' allocation
is being requested.  i.e. an allocation which will be used for a single
purpose for a short amount of time and will then be freed.  In
particularly it will never be placed in a cache, and if it is ever
placed on a queue, that is certain to be a queue with an upper bound on
the size and with guaranteed forward progress in the face of memory
pressure.
Any allocation request for a use case with those properties should be
allowed to set GFP_TRANSIENT (for example) with the effect that the
allocation will not be throttled.
A key point with the name is to identify the purpose of the flag, not a
specific use case (mempool) which we want it for.

At least, that is what I think we should do today...

NeilBrown


>
> Thanks!
> --=20
> Michal Hocko
> SUSE Labs


diff --git a/mm/mempool.c b/mm/mempool.c
index 8f65464da5de..2dded8c1b9d7 100644
=2D-- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -313,7 +313,6 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	void *element;
 	unsigned long flags;
 	wait_queue_t wait;
=2D	gfp_t gfp_temp;
=20
 	/* If oom killed, memory reserves are essential to prevent livelock */
 	VM_WARN_ON_ONCE(gfp_mask & __GFP_NOMEMALLOC);
@@ -325,67 +324,47 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	gfp_mask |=3D __GFP_NORETRY;	/* don't loop in __alloc_pages */
 	gfp_mask |=3D __GFP_NOWARN;	/* failures are OK */
=20
=2D	gfp_temp =3D gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
+	element =3D pool->alloc(gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO),
+			      pool->pool_data);
=20
=2Drepeat_alloc:
=2D	if (likely(pool->curr_nr)) {
=2D		/*
=2D		 * Don't allocate from emergency reserves if there are
=2D		 * elements available.  This check is racy, but it will
=2D		 * be rechecked each loop.
=2D		 */
=2D		gfp_temp |=3D __GFP_NOMEMALLOC;
=2D	}
+	while (!element) {
+		spin_lock_irqsave(&pool->lock, flags);
+		if (likely(pool->curr_nr)) {
+			element =3D remove_element(pool, gfp_mask);
+			spin_unlock_irqrestore(&pool->lock, flags);
+			/* paired with rmb in mempool_free(), read comment there */
+			smp_wmb();
+			/*
+			 * Update the allocation stack trace as this is more useful
+			 * for debugging.
+			 */
+			kmemleak_update_trace(element);
+			break;
+		}
+
+		/* We must not sleep if !__GFP_DIRECT_RECLAIM */
+		if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
+			spin_unlock_irqrestore(&pool->lock, flags);
+			break;
+		}
=20
=2D	element =3D pool->alloc(gfp_temp, pool->pool_data);
=2D	if (likely(element !=3D NULL))
=2D		return element;
+		/* Let's wait for someone else to return an element to @pool */
+		init_wait(&wait);
+		prepare_to_wait(&pool->wait, &wait, TASK_UNINTERRUPTIBLE);
=20
=2D	spin_lock_irqsave(&pool->lock, flags);
=2D	if (likely(pool->curr_nr)) {
=2D		element =3D remove_element(pool, gfp_temp);
 		spin_unlock_irqrestore(&pool->lock, flags);
=2D		/* paired with rmb in mempool_free(), read comment there */
=2D		smp_wmb();
+
 		/*
=2D		 * Update the allocation stack trace as this is more useful
=2D		 * for debugging.
+		 * FIXME: this should be io_schedule().  The timeout is there as a
+		 * workaround for some DM problems in 2.6.18.
 		 */
=2D		kmemleak_update_trace(element);
=2D		return element;
=2D	}
+		io_schedule_timeout(5*HZ);
=20
=2D	/*
=2D	 * We use gfp mask w/o direct reclaim or IO for the first round.  If
=2D	 * alloc failed with that and @pool was empty, retry immediately.
=2D	 */
=2D	if ((gfp_temp & ~__GFP_NOMEMALLOC) !=3D gfp_mask) {
=2D		spin_unlock_irqrestore(&pool->lock, flags);
=2D		gfp_temp =3D gfp_mask;
=2D		goto repeat_alloc;
=2D	}
=2D	gfp_temp =3D gfp_mask;
+		finish_wait(&pool->wait, &wait);
=20
=2D	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
=2D	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
=2D		spin_unlock_irqrestore(&pool->lock, flags);
=2D		return NULL;
+		element =3D pool->alloc(gfp_mask, pool->pool_data);
 	}
=2D
=2D	/* Let's wait for someone else to return an element to @pool */
=2D	init_wait(&wait);
=2D	prepare_to_wait(&pool->wait, &wait, TASK_UNINTERRUPTIBLE);
=2D
=2D	spin_unlock_irqrestore(&pool->lock, flags);
=2D
=2D	/*
=2D	 * FIXME: this should be io_schedule().  The timeout is there as a
=2D	 * workaround for some DM problems in 2.6.18.
=2D	 */
=2D	io_schedule_timeout(5*HZ);
=2D
=2D	finish_wait(&pool->wait, &wait);
=2D	goto repeat_alloc;
+	return element;
 }
 EXPORT_SYMBOL(mempool_alloc);
=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXkrZoAAoJEDnsnt1WYoG57k8QAJqQbfMhE0Vqhd6xK9i3+MT3
LK4YpnyowV+VpOF/rF8SMG9yBsu/Xhjc+DemDDaTrfl3WwtV1qp5gjyb1U8cYIQj
tmW4RIDeVbf+fZ98iclxT8bMziklgyOFD1h9KuakXFDMn8zkQ3SibAza9PbJXtna
Xiwu6hXVhXAFNJQd0lVjP3+TcGB4N0iTC3KfpxbfATduGjXqyxwiwRqk/hdglGNJ
noEWYcZY7bcHdun4tqAhh4SU/XiPnlAv4PBVCvf5RNlWwDBY9N1W0KaSV3MzsknN
QTVr4ZjkmSpXVH88hFmXgdWHmB50oPO23wWnPbLNY1Hi3ZdQeXuleHwnL+c1Z7Bj
6sRAswwpr+cYADDI5fJUpFJq4NmiyUYLxfdmNteEQvBr/6p/X3B72BzPPlhQ8iHj
DXuQDpHJOzV23AdrJl59M2G9vsnvbUbpz83DiMvppPj3KrCau0dJGPYHrPddfU3i
PhxUjKAWCVzGCZxEN6E4kZCzSTZokwlZTHri06/1JIOwhN++ONjSDshnv5hqkwmv
0gjdcRvq62Qtnk242wj932EGaKieTzKKeYGOf0tkUDdxZg9FkK0h+pZhC8YtCEM+
bmWFEgDLiAXE7TGrRxKzNmOVyK+Wc4eKQibGZxHZbXpXk2Xi8dCnGhBL6f6X+QXw
eL7DgQLm/wNQ3w+AZuex
=nUz8
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
