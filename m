Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 529E66B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:47:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so29253319wme.1
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:47:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q190si9001684wmd.73.2016.07.22.01.47.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 01:47:07 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Fri, 22 Jul 2016 18:46:57 +1000
Subject: Re: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE tasks
In-Reply-To: <1468831285-27242-2-git-send-email-mhocko@kernel.org>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org>
Message-ID: <87oa5q5abi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, Michal Hocko <mhocko@suse.com>

--=-=-=
Content-Type: text/plain

On Mon, Jul 18 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
>
> Mikulas has reported that a swap backed by dm-crypt doesn't work
> properly because the swapout cannot make a sufficient forward progress
> as the writeout path depends on dm_crypt worker which has to allocate
> memory to perform the encryption. In order to guarantee a forward
> progress it relies on the mempool allocator. mempool_alloc(), however,
> prefers to use the underlying (usually page) allocator before it grabs
> objects from the pool. Such an allocation can dive into the memory
> reclaim and consequently to throttle_vm_writeout.

That's just broken.
I used to think mempool should always use the pre-allocated reserves
first.  That is surely the most logical course of action.  Otherwise
that memory is just sitting there doing nothing useful.

I spoke to Nick Piggin about this some years ago and he pointed out that
the kmalloc allocation paths are much better optimized for low overhead
when there is plenty of memory.  They can just pluck a free block of a
per-CPU list without taking any locks.   By contrast, accessing the
preallocated pool always requires a spinlock.

So it makes lots of sense to prefer the underlying allocator if it can
provide a quick response.  If it cannot, the sensible thing is to use
the pool, or wait for the pool to be replenished.

So the allocator should never wait at all, never enter reclaim, never
throttle.

Looking at the current code, __GFP_DIRECT_RECLAIM is disabled the first
time through, but if the pool is empty, direct-reclaim is allowed on the
next attempt.  Presumably this is where the throttling comes in ??  I
suspect that it really shouldn't do that. It should leave kswapd to do
reclaim (so __GFP_KSWAPD_RECLAIM is appropriate) and only wait in
mempool_alloc where pool->wait can wake it up.

If I'm following the code properly, the stack trace below can only
happen if the first pool->alloc() attempt, with direct-reclaim disabled,
fails and the pool is empty, so mempool_alloc() calls prepare_to_wait()
and io_schedule_timeout().
I suspect the timeout *doesn't* fire (5 seconds is along time) so it
gets woken up when there is something in the pool.  It then loops around
and tries pool->alloc() again, even though there is something in the
pool.  This might be justified if that ->alloc would never block, but
obviously it does.

I would very strongly recommend just changing mempool_alloc() to
permanently mask out __GFP_DIRECT_RECLAIM.

Quite separately I don't think PF_LESS_THROTTLE is at all appropriate.
It is "LESS" throttle, not "NO" throttle, but you have made
throttle_vm_writeout never throttle PF_LESS_THROTTLE threads.
The purpose of that flag is to allow a thread to dirty a page-cache page
as part of cleaning another page-cache page.
So it makes sense for loop and sometimes for nfsd.  It would make sense
for dm-crypt if it was putting the encrypted version in the page cache.
But if dm-crypt is just allocating a transient page (which I think it
is), then a mempool should be sufficient (and we should make sure it is
sufficient) and access to an extra 10% (or whatever) of the page cache
isn't justified.

Thanks,
NeilBrown



 If there are too many
> dirty or pages under writeback it will get throttled even though it is
> in fact a flusher to clear pending pages.
>
> [  345.352536] kworker/u4:0    D ffff88003df7f438 10488     6      2 0x00000000
> [  345.352536] Workqueue: kcryptd kcryptd_crypt [dm_crypt]
> [  345.352536]  ffff88003df7f438 ffff88003e5d0380 ffff88003e5d0380 ffff88003e5d8e80
> [  345.352536]  ffff88003dfb3240 ffff88003df73240 ffff88003df80000 ffff88003df7f470
> [  345.352536]  ffff88003e5d0380 ffff88003e5d0380 ffff88003df7f828 ffff88003df7f450
> [  345.352536] Call Trace:
> [  345.352536]  [<ffffffff818d466c>] schedule+0x3c/0x90
> [  345.352536]  [<ffffffff818d96a8>] schedule_timeout+0x1d8/0x360
> [  345.352536]  [<ffffffff81135e40>] ? detach_if_pending+0x1c0/0x1c0
> [  345.352536]  [<ffffffff811407c3>] ? ktime_get+0xb3/0x150
> [  345.352536]  [<ffffffff811958cf>] ? __delayacct_blkio_start+0x1f/0x30
> [  345.352536]  [<ffffffff818d39e4>] io_schedule_timeout+0xa4/0x110
> [  345.352536]  [<ffffffff8121d886>] congestion_wait+0x86/0x1f0
> [  345.352536]  [<ffffffff810fdf40>] ? prepare_to_wait_event+0xf0/0xf0
> [  345.352536]  [<ffffffff812061d4>] throttle_vm_writeout+0x44/0xd0
> [  345.352536]  [<ffffffff81211533>] shrink_zone_memcg+0x613/0x720
> [  345.352536]  [<ffffffff81211720>] shrink_zone+0xe0/0x300
> [  345.352536]  [<ffffffff81211aed>] do_try_to_free_pages+0x1ad/0x450
> [  345.352536]  [<ffffffff81211e7f>] try_to_free_pages+0xef/0x300
> [  345.352536]  [<ffffffff811fef19>] __alloc_pages_nodemask+0x879/0x1210
> [  345.352536]  [<ffffffff810e8080>] ? sched_clock_cpu+0x90/0xc0
> [  345.352536]  [<ffffffff8125a8d1>] alloc_pages_current+0xa1/0x1f0
> [  345.352536]  [<ffffffff81265ef5>] ? new_slab+0x3f5/0x6a0
> [  345.352536]  [<ffffffff81265dd7>] new_slab+0x2d7/0x6a0
> [  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
> [  345.352536]  [<ffffffff812678cb>] ___slab_alloc+0x3fb/0x5c0
> [  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
> [  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
> [  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
> [  345.352536]  [<ffffffff81267ae1>] __slab_alloc+0x51/0x90
> [  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
> [  345.352536]  [<ffffffff81267d9b>] kmem_cache_alloc+0x27b/0x310
> [  345.352536]  [<ffffffff811f71bd>] mempool_alloc_slab+0x1d/0x30
> [  345.352536]  [<ffffffff811f6f11>] mempool_alloc+0x91/0x230
> [  345.352536]  [<ffffffff8141a02d>] bio_alloc_bioset+0xbd/0x260
> [  345.352536]  [<ffffffffc02f1a54>] kcryptd_crypt+0x114/0x3b0 [dm_crypt]

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXkd2BAAoJEDnsnt1WYoG5DXYP/2Wahjd8QLg/mSTV+nU9/Ayg
JDaF1xG/+GUGx6YqJMclRLkj4UPDEQIaPhTw114hpiAq2XjbBMrtO/Omaj8J4YTR
VJYshzOVYtMS+OAFgNFz3z5z5CFtjun+p7+TBkx6qtNvhcxw2VVTY+tEL0SI7TbE
uCfRDUR3zsDv7UAGgMk+aWZ/M3l/GT7BiHSnzIxLewTScaOGlCFtrP1LD/M7HxcO
NQBxdHfRi67NAe17IgZJ9TyP6eXBsGaVtHhcduvSaTWgD94DqmmQglFxqEZmuzPY
BDQT5tbzVkMtVz0iKxQMaF0XFmiadxrj2x/eERloX82B/MjP6iNraHPVRjBxzrcv
N8w+HnB1ldPvVocoU1sLxvMQFV2iYC8LJGLI9UkN9FaVuqsT3eKfGLoQEiS3GtuC
ik2suzds15rx66ZWZAtDE+eXoM6N6FF4a6gn7BiIGUDbe/UbBLJmUWXv+PYm7PHw
M+dyOQPAfLzD/TjdPE+1l4HNhfChG6KXsYW3nbqAK2HO5kF72lpxFUP1Ea1T+LS4
gkqxsC0gouOiqO6xdGMCIg/8hkBnWjHfEVafUp8gy62jo2Z9pKxHU4WEUfjWH1n3
xmViC9990BW+m1ELVxZRcxJvPw19V5EUFIq+vEoPfyKU27B1u3ZqtLZ+0YNHn7ZT
3lOs+V43bU9gbNPw4pAA
=V2Zk
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
